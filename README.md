# Goals

 * Javascript as a first-class citizen:
   * webpacked src outside the app/ dir
   * node-modules, package.json, npm - no vendoring in the gem
   * Fully configurable webpack configuration
 * Co-exist with but do not use sprockets
 * Start with own asset helpers for now
 * React hot-loading support:
   * necessitates use of webpack-dev-server
 * Fingerprinted assets in production:
   * start with own asset helpers
   * precompile to public/webpack
 * JS unit tests your responsibility - but works with integration tests

# TODO

* Generators:
  * package.json
  * webpack.config.js
  * Procfile

* Barebones example webback.config.js & full-service react/css/etc

* Configurable everything:
 * dev server port
 * webpack config location
 * webpack binary location
 * prod/dev mode
 * source location
 * destination location
 * url relative location

* Sanity checks:
 * does our webpack binary exist?
 * does webpack.config.js exist?
 * can we load the manifest? (in prod)
 * can we talk to the webpack-dev-server (in dev)

* Integration tests:
 * Ensure sprockets, webpack, react works with generated webpack.config.js

## Ideas

* Drive config via JSON, have webpack.config.js read same JSON?
* Custom webpack-dev-server that exposes errors, stats, etc
