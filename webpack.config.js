const fs = require('fs');
const path = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const HtmlWebpackInlineSourcePlugin = require('html-webpack-inline-source-plugin');

// see: https://github.com/webpack/webpack/issues/2537
const isProd = process.argv.indexOf('-p') !== -1;

module.exports = data => ({
  entry: {
    bundle: './src/Page/PreviewDocumentation.elm',
  },
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'dist'),
    library: 'Advent',
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: isProd
            ? {}
            : {
                debug: true,
                warn: true,
              },
        },
      },
      {
        test: /\.js$/,
        exclude: [/node_modules/],
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['env'],
            plugins: ['transform-runtime'],
          },
        },
      },
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract({
          use: ['css-loader'],
        }),
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      title: 'Preview',
      template: 'src/index.html.ejs',
      filename: 'index.html',
      data,
      inject: 'head',
      minify: {
        html5: true,
        collapseWhitespace: true,
        removeComments: true,
        minifyJS: true,
        minifyCSS: true,
      },
      inlineSource: '.(js|css)$', // embed all javascript and css inline
    }),
    //new HtmlWebpackInlineSourcePlugin(),
    new ExtractTextPlugin('[name].css'),
  ],
  devServer: {
    stats: {
      colors: true,
    },
  },
});
