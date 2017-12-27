const fs = require('fs');
const path = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');

// see: https://github.com/webpack/webpack/issues/2537
const isProd = process.argv.indexOf('-p') !== -1;
const elmLoaderDefaults = { cwd: __dirname };

module.exports = data => ({
  entry: {
    bundle: path.resolve(__dirname, './src/Page/PreviewDocumentation.elm'),
  },
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'dist'),
    library: 'Elm',
  },
  context: __dirname,
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: isProd
            ? elmLoaderDefaults
            : {
                ...elmLoaderDefaults,
                debug: true,
                warn: true,
              },
        },
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      title: 'Preview',
      template: path.resolve(__dirname, 'src/index.html.ejs'),
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
  ],
  devServer: {
    stats: 'errors-only',
  },
});
