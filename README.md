# A Pure Elm Text Editor


This project, a text editor written in pure Elm, is a fork of 
[work by Sydney Nemzer](https://github.com/SidneyNemzer/elm-text-editor).
His [demo](https://sidneynemzer.github.io/elm-text-editor/), 
 inspired by prior work of Martin Janiczek, shows the 
feasibility of writing such a text editor and establishes an elegant and powerful foundation for future work.  Many kudos to Sydney.


This
[forked repo](https://github.com/jxxcarlson/elm-text-editor-simple) adds 
scrolling, copy, cut, and paste, search and replace, text wrap,
and an API for embedding the editor in another app.  Here is a simple demo of the code:

> [Demo-simple](https://jxxcarlson.github.io/app/editor-simple/index.html)

For a slightly more complex example that implements external
copy-paste, see

> [Demo](https://jxxcarlson.github.io/app/editor/index.html)

At the moment, external copy-paste only works in Chrome.

There is much work yet to be done.


## Embedding the Editor

- See the notes in `Embedding.md`
- Use the `demo-simple` and `demo` apps of this repo as models.
- In order to implement external copy-paste (ctrl-shift U), the second app imports module `Outside` into `Main` and references `outside.js` in `index.html`


## Plans

- I would very much like this to be a community project; it is a tool that many of us can use to good end. I've posted some issues on the repo, and welcome comments, pull requests, and more issues.


- I may post a Road Map later, but [Sydney Nemzer's README](https://github.com/SidneyNemzer/elm-text-editor/blob/master/README.md) is an excellent place to begin.


 


