#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const childProcess = require('child_process');
const webpack = require('webpack');
const webpackDevServer = require('webpack-dev-server');
const createConfig = require('./webpack.config.js');
const pathExists = require('path-exists');

const readFileAsync = promisify(fs.readFile);
const exec = promisify(childProcess.exec);

const arg = process.argv[2];
const dir = arg ? path.resolve(arg) : process.cwd();

if (!pathExists.sync(path.resolve(dir, 'elm-package.json'))) {
  console.log(`I could not find an 'elm-package.json' file in ${dir}.`);
  console.log('Please make sure there is one.\n');
  process.exit(0);
}

const docsFile = path.join(__dirname, '.preview-docs.json');
const pathToElmMake = path.join(__dirname, 'node_modules/.bin/elm-make');

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
  //.then(handleErrors)
  .catch(console.log);
