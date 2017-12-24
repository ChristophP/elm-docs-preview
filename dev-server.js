const fs = require('fs');
const webpack = require('webpack');
const webpackDevServer = require('webpack-dev-server');
const createConfig = require('./webpack.config.js');
const { promisify } = require('util');

const readFileAsync = promisify(fs.readFile);
const docsFile = 'docs_tmp.json';

readFileAsync(docsFile, 'utf8').then(data => {
  const config = createConfig(JSON.parse(data));
  const compiler = webpack(config);
  const server = new webpackDevServer(compiler, config.devServer);
  server.listen(8080, '127.0.0.1', () => {
    console.log('Starting server on http://localhost:8080');
  });
});
