# Pure Elm Text Editor

*January 4, 2020*

This project is a fork of 
[work by Sydney Nemzer](https://github.com/SidneyNemzer/elm-text-editor).
His [demo](https://sidneynemzer.github.io/elm-text-editor/), 
 inspired by prior work of Martin Janiczek, shows the 
feasibility of writing a pure Elm text editor. There is a lot of power 
in Nemzer's code, and its architecture makes it easy to work with.
My
[forked repo](https://github.com/jxxcarlson/elm-text-editor) adds 
scrolling, copy, cut, and paste, search and replace, text wrap,
and an API for embedding the editor in another app.  Here are two demos
of this code:

1. [Basic editor](https://jxxcarlson.github.io/app/editor/index.html)

2. [MiniLaTeX Demo](https://jxxcarlson.github.io/app/minilatex3/index.html)

I sent a PR to Sydney on December 27, and have updated it
regularly since then,  Haven't heard back from him
yet.  Ideally, the code here can be incorporated in his.
If some members of the community take up an interest in the 
editor and contribute code to it, I think that a workable
editor package could be published in the not too distant future.
I believe that many of us would find uses for such a package
(see Sydney's Road Map).

My plan, pending hearing back from Sydney, is to forge ahead but not 
to publish a package.  I'm going to post issues on my repo as I encounter
them, and encourage others to do the same.  I'll push both my own
changes and any merged PRs to the PR I sent Sydney.

## Embedding the Editor

See the notes in `Embedding.md` and also the code in the two demo apps.
