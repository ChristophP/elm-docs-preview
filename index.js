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

const dir = process.argv[2] || process.cwd();
const docsFile = path.join(__dirname, '.preview-docs.json');
const pathToElmMake = path.join(__dirname, 'node_modules/.bin/elm-make');

exec(`${pathToElmMake} --yes --docs=${docsFile}`, { cwd: dir })
  .then(() => console.log(`Compiling elm in ${dir}`))
  .then(() => readFileAsync(docsFile, 'utf8'))
  .then(data => {
    const config = createConfig(JSON.parse(data));
    const compiler = webpack(config);
    const server = new webpackDevServer(compiler, config.devServer);
    server.listen(8080, '127.0.0.1', () => {
      console.log('Starting server on http://localhost:8080');
    });
  })
  .catch(console.log);
