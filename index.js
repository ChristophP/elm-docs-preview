const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const childProcess = require('child_process');
const webpack = promisify(require('webpack'));
const createConfig = require('./webpack.config.js');

const elmStaticHtml = require('elm-static-html-lib').default;

const readFileAsync = promisify(fs.readFile);
const exec = promisify(childProcess.exec);

const dir = process.argv[2];
if (!dir) {
  console.log("Please pass a directory name where you're elm-package.json is.");
}

const docsFile = 'docs_tmp.json';

exec(`elm make --docs=${docsFile}`, { cwd: dir })
  .then(console.log)
  .then(() => fs.readFileSync(docsFile, 'utf8'))
  .then(data => webpack(createConfig(JSON.parse(data))))
  .then(() => console.log('webpack done'))
  .catch(console.log)
  .then(() => process.exit(0));

//readFileAsync('./docs.json')
//.then(json => JSON.parse(json))
//.then(model => {
//const options = { model, decoder: 'Decoder.decodeModel' };

//return elmStaticHtml(
//process.cwd(),
//'View.view',
//options
//).then(generatedHtml => {
//fs.writeFileSync('docs.html', generatedHtml);
//});
//});
