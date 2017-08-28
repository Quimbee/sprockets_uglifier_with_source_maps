require "sprockets/digest_utils"
require "sprockets/uglifier_compressor"

module SprocketsUglifierWithSM
  class Compressor < Sprockets::UglifierCompressor
    DEFAULTS = { comments: false }.freeze

    def initialize(options = {})
      @options = DEFAULTS.merge(Rails.application.config.assets.uglifier.to_h).merge!(options)
      super @options
    end

    def call(input)
      data = input.fetch(:data)
      name = input.fetch(:name)

      uglifier = Sprockets::Autoload::Uglifier.new(@options)

      compressed_data, sourcemap_json = uglifier.compile_with_map(data)

      sourcemap = JSON.parse(sourcemap_json)

      if Rails.application.config.assets.sourcemaps_embed_source
        sourcemap["sourcesContent"] = [data]
      end

      uncompressed_path, uncompressed_url = get_file_data(name, digest(data))

      generate_file(data, uncompressed_path)

      sourcemap["sources"] = [uncompressed_url]

      sourcemap["file"] = "#{name}.js"

      sourcemap_json = sourcemap.to_json

      sourcemap_path, sourcemap_url = get_file_data(name, digest(sourcemap_json), true)

      generate_file(sourcemap_json, sourcemap_path)

      compressed_data.concat "\n//# sourceMappingURL=#{sourcemap_url}\n"
    end

    private

    def gzip?
      config = Rails.application.config.assets
      config.sourcemaps_gzip || (config.sourcemaps_gzip.nil? && config.gzip)
    end

    def gzip_file(path)
      Zlib::GzipWriter.open("#{path}.gz") do |gz|
        gz.mtime     = File.mtime(path)
        gz.orig_name = path
        gz.write IO.binread(path)
      end
    end

    def filename_to_url(filename)
      url_root = Rails.application.config.assets.sourcemaps_url_root
      case url_root
      when FalseClass
        filename
      when Proc
        url_root.call filename
      else
        File.join url_root.to_s, filename
      end
    end

    def digest(io)
      Sprockets::DigestUtils.pack_hexdigest Sprockets::DigestUtils.digest(io)
    end

    def get_file_data(name, suffix, map = false)
      prefix = map ? Rails.application.config.assets.sourcemaps_prefix : Rails.application.config.assets.uncompressed_prefix
      ext = map ? ".js.map" : ".js"
      uncompressed_filename = File.join(Rails.application.config.assets.prefix, prefix.to_s, "#{name}-#{suffix}#{ext}")
      uncompressed_path     = File.join(Rails.public_path, uncompressed_filename)
      uncompressed_url      = filename_to_url(uncompressed_filename)

      [uncompressed_path, uncompressed_url]
    end

    def generate_file(content, path)
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, "w") { |f| f.write content }
      gzip_file(path) if gzip?
    end
  end
end
