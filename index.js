#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const childProcess = require('child_process');
const webpack = require('webpack');
const webpackDevServer = require('webpack-dev-server');
const createConfig = require('./webpack.config.js');

const readFileAsync = promisify(fs.readFile);
const exec = promisify(childProcess.exec);

const arg = process.argv[2];
if (!arg) {
  console.log('Please pass a directory name, where your elm-package.json is.');
  console.log('Example: elm-docs-preview path/to/elm-package.json\n');
  process.exit(0);
}

const dir = path.resolve(arg);
const docsFile = path.join(__dirname, '.preview-docs.json');

const handleErrors = stats => {
  const info = stats.toJson();

  if (stats.hasErrors()) {
    info.errors.forEach(err => {
      console.error(err);
    });
    process.exit(1);
  }

  if (stats.hasWarnings()) {
    console.warn(info.warnings);
  }
};

exec(`elm make --docs=${docsFile}`, { cwd: dir })
  .then(() => console.log(`compiling elm in ${dir}`))
  .then(() => readFileAsync(docsFile, 'utf8'))
  .then(data => {
    const config = createConfig(JSON.parse(data));
    const compiler = webpack(config);
    const server = new webpackDevServer(compiler, config.devServer);
    server.listen(8080, '127.0.0.1', () => {
      console.log('Starting server on http://localhost:8080');
    });
  })
  //.then(handleErrors)
  .catch(console.log);
