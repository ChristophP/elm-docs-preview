# Elm Docs Preview

Preview the docs for your awesome Elm libs locally. Sounds good? Just do this!

```sh
npm i -g elm-docs-preview
```

Then run it with a path to the directory of your package (which contains `elm-package.json`).

```sh
elm-docs-preview path/to/elm-package
```

This will spin up a server at `http://localhost:8080`, which will serve an HTML and show the compiled docs.

## What's happening?

When running `elm-docs-preview` this will:

- run `elm make` in the directory you specified to generate the `docs.json`.
- then it will generate an HTML page, which displays the JSON data in the format you as a package author are used to from [package.elm-lang.org](http://package.elm-lang.org/)
- spin up a server to display that page

## Room for improvement

- As live reloading is not implementing yet you'll have to run this again everytime you make changes and wanna preview them(should watch the exposed modules of a package)
- Code for the UI was shamelessly taken and adapted from [package.elm-lang.org](http://package.elm-lang.org/). The code likely still contains a bunch of unnecessary stuff from the original version, but this was the quickest way to make this previewer.
- assets are still fetched from [package.elm-lang.org](http://package.elm-lang.org/) (should maybe be copied into this package so it doesn't break if the package site is down)
- currently the server for previewing is `webpack-dev-server`. It makes generating everything very easy and I picked it mostly for comfort, but I'm not sure if there aren't better choices out there.
