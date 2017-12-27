# Elm Docs Preview

Preview the docs for your awesome Elm libs locally. Sounds good? Just do this!

```sh
npm i -g elm-docs-preview
```

Then run:

```
elm-docs-preview path/to/elm-package.json
```

This will spin up a server, which will serve an HTML and show the compiled docs.

## What's happening?

When running `elm-docs-preview` this will

- run `elm make` in the directory you specified to generate the `docs.json`.
- then it will generate an HTML page, which displays the JSON data in the format you as a package author are used to from `package.elm-lang.org`

## Room for improvement

- As live reloading is not implementing yet you'll have to run this again everytime you make changes and wanna preview them.
- Sometimes links are broken
- Code for the UI was shamelessly taken and adapted from `package.elm-lang.org`. The code likely still contains a bunch of unnecessary stuff from the original version, but this was the quickest way to make this previewer.

### Issues

- some links are broken => resolved
- assets are still fetched from `package.elm-lang.org` (should maybe be copied to local so it doesn't break if the package site is down)
- there is no live reload yet, which watches the exposed modules of a package
