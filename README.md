# webpack-rails

[![Build Status](https://travis-ci.org/mipearson/webpack-rails.svg?branch=master)](https://travis-ci.org/mipearson/webpack-rails)

**webpack-rails** gives you tools to integrate Webpack in to an existing Ruby on Rails application.

It will happily co-exist with sprockets but does not use it for production fingerprinting or asset serving. **webpack-rails** is designed with the assumption that if you're using Webpack you treat Javascript as a first-class citizen. This means that you control the webpack config, package.json, and use npm to install Webpack & its plugins.

In development mode [webpack-dev-server](http://webpack.github.io/docs/webpack-dev-server.html) is used to serve webpacked entry points and offer hot module reloading. In production entry points are built in to `public/webpack`. **webpack-rails** uses [stats-webpack-plugin](https://www.npmjs.com/package/stats-webpack-plugin) to translate entry points in to asset paths.

It was designed for use at [Marketplacer](http://www.marketplacer.com) to assist us in migrating our Javascript (and possibly our SCSS) off of Sprockets. It first saw production use in June 2015.

As this is pre-1.0 software its API and configuration may change as we become more familiar with Webpack. This gem has been developed against Ruby 2.2 and Rails 4.2. Previous versions might work, but I haven't tested them. Assume Rails 3.2 and Ruby 1.9 as an absolute minimum.

## Getting Started

Have a look at the files in the `examples` directory. Of note:

  * We use [foreman](https://github.com/ddollar/foreman) and a `Procfile` to run our rails server & the webpack dev server in development at the same time
  * The webpack and gem configuration must be in sync - look at our railtie for configuration options
  * We require that **stats-webpack-plugin** is loaded to automatically generate a production manifest & resolve paths during development

To access webpacked assets from your views:

```erb
<%= javascript_include_tag *webpack_asset_paths("entry_point_name") %>
```

Take note of the splat (`*`): `webpack_asset_paths` returns an array, as one entry point can map to multiple paths, especially if hot reloading is enabled in Webpack.

### Configuration Defaults

  * Webpack configuration lives in `config/webpack.config.js`
  * Webpack & Webpack Dev Server binaries are in `node_modules/.bin/`
  * Webpack Dev Server will run on port 3808 on localhost
  * Webpack Dev Server is enabled in development & test, but not in production
  * Webpacked assets will be compiled to `public/webpack`
  * The manifest file is named `manifest.json`

### Working with browser tests

In development, we make sure that the `webpack-dev-server` is running when browser tests are running. In CI, we manually run `webpack` to compile the assets to public and set `config.webpack.dev_server.enabled` to false.

### Production Deployment

Add `rake webpack:compile` to your deployment. It serves a similar purpose as Sprockets' `assets:precompile` task. If you're using Webpack and Sprockets (as we are at Marketplacer) you'll need to run both tasks - but it doesn't matter which order they're run in.

If you're using `[chunkhash]` in your build asset filenames (which you should be, if you want to cache them in production), you'll need to persist built assets between deployments. Consider in-flight requests at the time of deployment: they'll receive paths based on the old `manifest.json`, not the new one.

## TODO

* Release gem
* travisci & codeclimate & gem badges
* Drive config via JSON, have webpack.config.js read same JSON?
* Generators for webpack config, Gemfile, Procfile, package.json
* Custom webpack-dev-server that exposes errors, stats, etc
* [react-rails](https://github.com/reactjs/react-rails) fork for use with this workflow
* Integration tests

## Contributing

Pull requests & issues welcome. Advice & criticism regarding webpack config approach also welcome.

Please ensure that pull requests pass both rubocop & rspec. New functionality should be discussed in an issue first.

## Acknowledgements

* Len Garvey for his [webpack-rails](https://github.com/lgarvey/webpack-rails) gem which inspired this implementation
* Sebastian Porto for [Rails with Webpack](https://reinteractive.net/posts/213-rails-with-webpack-why-and-how)
* Clark Dave for [How to use Webpack with Rails](http://clarkdave.net/2015/01/how-to-use-webpack-with-rails/)
