# SprocketsUglifierWithSourceMaps

Create source maps when compressing assets in your Rails 4.2 applications.

This gem uses Uglifier to create source maps for your concatenated javascripts in Rails.
It is meant to be used as a replacement for javascript compressor.

Source maps are useful for debugging javascript and many errors monitoring services utilize them,
for example [Rollbar](https://rollbar.com/docs/source-maps/).


## Installation

Add this line to your application's Gemfile:

    gem 'sprockets_uglifier_with_source_maps'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sprockets_uglifier_with_source_maps


## Usage

In your Rails applications environment configuration:

    config.assets.js_compressor = :uglifier_with_source_maps

If you need to pass options to uglifier:

    config.assets.uglifier = {output: {beautify: true, indent_level: 2}, compress: {angular: true}} 

Your assets will be built as normal, also maps and concatenated sources will be provided as well in `public/assets/maps` and `public/assets/sources`.
These subdirs may be configured:

    config.assets.sourcemaps_prefix = 'my_maps'
    config.assets.uncompressed_prefix = 'my_sources'


## Example

    $ rm -rf tmp/cache && rm -rf public/assets && DISABLE_SPRING=true RAILS_ENV=production bin/rake assets:precompile

    $ tree public/assets
    public/assets
    ├── application-f925f01bc55e9831029c1eb2c20ee889.js
    ├── maps
    │   └── application-a3aff92c860f3876615c2d158f724865.js.map
    └── sources
        └── application-73a007cf2d51c423a4420b649344b52e.js

    $ tail -n1 public/assets/application-f925f01bc55e9831029c1eb2c20ee889.js
    //# sourceMappingURL=/assets/maps/application-a3aff92c860f3876615c2d158f724865.js.map

    $ head -c115 public/assets/maps/application-a3aff92c860f3876615c2d158f724865.js.map
    {"version":3,"file":"application.js","sources":["/assets/sources/application-73a007cf2d51c423a4420b649344b52e.js"],


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
