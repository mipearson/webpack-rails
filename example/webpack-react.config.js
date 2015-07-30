// Example webpack configuration for React with live reloading in development
// and asset fingerprinting in production.
'use strict';

// jshint camelcase:false

var path = require('path');
var webpack = require('webpack');
var StatsPlugin = require('stats-webpack-plugin');

// must match config.webpack.dev_server.port
var devServerPort = 3808;

// set TARGET=production on the environment to add asset fingerprints &
// omit hot-reloading
var production = process.env.TARGET === 'production';

// set NO_HOT_RELOAD=1 to disable hot reloading, even in development
var hotReload = !production && !process.env.NO_HOT_RELOAD;

var config = {
  entry: {
    // Sources are expected to live in $app_root/webpack
    // Entry points require extensions.
    'entry_a': './webpack/entry/entry_a.js',
    'entry_b': './webpack/entry/entry_b.js'
  },

  output: {
    // Build assets directly in to public/webpack/, let webpack know
    // that all webpacked assets start with webpack/

    // must match config.webpack.public_path and config.webpack.output_dir
    path: path.join(__dirname, '..', 'public', 'webpack'),
    publicPath: '/webpack/',

    filename: production ? '[name]-[chunkhash].js' : '[name].js'
  },

  module: {
    loaders: [
      // Example babel loader, with hot-reloading in development
      {
        test: /\.jsx?$/,
        loaders: hotReload ? ['react-hot', 'babel'] : ['babel'],
        include: path.join(__dirname, '..', 'webpack'),
        exclude: [
          path.join(__dirname, '..', 'webpack', 'vendor'),
          path.join(__dirname, '..', 'webpack', 'legacy')
        ]

      },

      // Expose React to the global context for use with the Chrome react plugin
      {
        test: require.resolve('react'), loader: 'expose?React'
      }
    ]
  },

  resolve: {
    extensions: ['', '.js', '.jsx'],
    root: path.join(__dirname, '..', 'webpack')
  },

  plugins: [
    // must match config.webpack.manifest_filename
    new StatsPlugin('manifest.json', {
      // We only need assetsByChunkName
      chunkModules: false,
      source: false,
      chunks: false,
      modules: false,
      assets: true
    })]
};

if (production) {
  config.plugins = config.plugins.concat([
    new webpack.optimize.UglifyJsPlugin(),
    new webpack.optimize.OccurenceOrderPlugin()
  ]);
} else {
  config.devServer = {
    port: devServerPort,
    headers: { 'Access-Control-Allow-Origin': '*' }
  };
  config.output.publicPath = '//localhost:' + devServerPort + '/webpack/';
  // Source maps
  config.devtool = 'cheap-module-eval-source-map';
}

if (hotReload) {
  // react-hot-loader configuration bits
  config.plugins = config.plugins.concat([
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin()
  ]);
  Object.keys(config.entry).forEach(function (entryPoint) {
    if (!Array.isArray(config.entry[entryPoint])) {
      config.entry[entryPoint] = [config.entry[entryPoint]];
    }
    config.entry[entryPoint] = [
      'webpack-dev-server/client?http://0.0.0.0:' + devServerPort,
      'webpack/hot/only-dev-server'
    ].concat(config.entry[entryPoint]);
  });
  config.devServer.hot = true;

}

module.exports = config;
