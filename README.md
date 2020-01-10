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

> [Basic editor](https://jxxcarlson.github.io/app/editor-simple/index.html)

There is much work yet to be done.

**NOTE.** Certain operations such as external copy-paste (pasting from the clipboard to the editor) require ports.  This is not a feature of the current release, but I hope to have something soon, if it is possible.  It works in the `demo` app of this repo if you use the `v0` tag and the repo source text.

## Embedding the Editor

- See the notes in `Embedding.md`
- See the `demo-simple` app of this repo.

## Plans

- I would very much like this to be a community project; it is a tool that many of us can use to good end. I've posted some issues on the repo, and welcome comments, pull requests, and more issues.


- I may post a Road Map later, but [Sydney Nemzer's README](https://github.com/SidneyNemzer/elm-text-editor/blob/master/README.md) is an excellent place to begin.


 


