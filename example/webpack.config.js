// Example webpack configuration for React with live reloading in development
// and asset fingerprinting in production.
"use strict";

var path = require("path");
var webpack = require("webpack");

// Helpers are hardcoded to expect dev assets at http://localhost:3808/webpack/*
var devServerPort = 3808;

// set TARGET=production on the environment to add asset fingerprints &
// omit hot-reloading
var production = process.env.TARGET === "production";

var config = {
    entry: {
        // Sources are expected to live in $app_root/webpack
        application: [
            "./webpack/application.js"
        ]
    },
    output: {
        // Build assets directly in to public/webpack/, let webpack know
        // that all webpacked assets start with webpack/
        path: path.join(__dirname, "public", "webpack"),
        publicPath: "/webpack",

        // Add asset fingerprinting to production compiled assets with 'chunkhash'
        filename: production ? "[name]-[chunkhash].js" : "[name].js"
    },

    module: {
        loaders: [
            // Example react JSX loader, with hot-reloading in development
            {
                test: /\.jsx?$/,
                loaders: production ? ["jsx?harmony"] : ["react-hot", "jsx?harmony"],
                include: path.join(__dirname, "webpack")
            }
        ]
    },
    resolve: {
        extensions: ["", ".js", ".jsx"]
    },

    // Sourcemaps in both production & development
    devtool: "cheap-module-eval-source-map"
};

if(!production) {
    config.devServer = {
        port: devServerPort
    };

    // react-hot-loader configuration bits
    config.plugins = [
        new webpack.HotModuleReplacementPlugin(),
        new webpack.NoErrorsPlugin()
    ];
    Object.keys(config.entry).forEach(function(entryPoint) {
        config.entry[entryPoint] = [
            "webpack-dev-server/client?http://0.0.0.0:" + devServerPort,
            "webpack/hot/only-dev-server"
        ].concat(config.entry[entryPoint]);
    });
}

module.exports = config;
