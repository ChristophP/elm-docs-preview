const fs = require('fs');
const path = require('path');
const { promisify } = require('util');

const elmStaticHtml = require('elm-static-html-lib').default;

const readFileAsync = promisify(fs.readFile);

readFileAsync('./docs.json')
  .then(json => JSON.parse(json))
  .then(model => {
    const options = { model, decoder: 'Decoder.decodeModel' };

    return elmStaticHtml(
      process.cwd(),
      'View.view',
      options
    ).then(generatedHtml => {
      fs.writeFileSync('docs.html', generatedHtml);
    });
  });
