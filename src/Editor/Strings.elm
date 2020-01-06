module Editor.Strings exposing (help, info)


help =
    """
-----------------------------------------------
                     Help
-----------------------------------------------
NEW: the Copy Button, lower right.  Pressing it
copies the computer's clipboard the editor's
clipboard.  Use ctrl-shift v to paste
the editor's clipboard to the current document
at the location of the cursor.  Right now this
is a clunky process: (1) use cmd-C (Mac) to
copy text to OS clipboard (2) use "Copy" button
to copy the text to the Editor keyboard,
(3) use ctrl-shift-v to paste the clipboard
into the Editor.  I am working on simplifying
it.

This works in Chrome 79 but not Firefox.
-----------------------------------------------



Partial list of key commands
----------------------------

Show help         ctrl-h         (Toggle)
Show info panel   ctrl-shift-i   (Toggle)

Lines
-----

Start of line     Home
End of line       End

Line Up           up-arrow
Line Down         down-arrow

First line        ctrl-option up-arrow
Last line         ctrl-option down-arrow

Go to line        ctrl-g         (Toggle)

Moves
-----
Page Up           option up-arrow
Page Down         option down-arrow

Selection
---------
Select word       Double-click
Select line       Triple-click
Select group      ctrl-d

Extend selection  shift-arrow: up | down | left | right

Copy selection    ctrl-c
Cut selection     ctrl-x
Paste selection   ctrl-v
Paste clipboard   ctrl-shift v


Text
------------

Indent            Tab
De-indent         shift-Tab

Wrap text         ctrl-w
Toggle wrap       ctrl-shift w   (for wrap on load)

Clear all        ctrl-shift c

Search
------

Search panel      ctrl-s (Toggle)
Replace panel     ctrl-r (Toggle)
Next search hit   ctrl-. (Think >)
Prev search hit   ctrl-. (Think <)

Undo/Redo
----------

Undo              ctrl-z
Redo              ctrl-y

"""


info =
    """This is a first test of how
the editor could be used as a package.
The 'Info' button is a proxy for loading new
content into the editor from an external
source.

Everything in this window is from `Editor.view`.  All
the rest is in `Main`, though of course it uses
functions exported by `Editor`, e.g., the slider.

The "Reset" button loads the initial text.
The "Gettysburg address" button loads
Abraham Lincoln's speech.  It contains three
very long lines which are wrapped by the editor
before you see them.  I need to devote more
thought to how best to do text wrapping —
it needs to be an option, for instance.
Am using Folkert de Vries' *elm-paragraph*
library for this.

NOTES

1. At present, all the editor controls
are key commands.  Press the "Help" button,
in hte info panel, upper right, for a partial
list of these. Full list coming soon.

2. More parameters are now configurable.
For example, one can do this in Main:

editorState = Editor.init
   { defaultConfig | lines = 30
                   , showInfoPanel = False
   }

to set up the embedded editor with a 30-line
display and the info panel not shown.

3. I've tested the editor on a file of 1700
lines and 7700 words. It works fine.  For
a file of 17,000 lines and 770,000 words,
moving around the text is extremely fast,
whereas double-clicking to select a word
fails.  I don't know why as of this writing.

4. In view of (3), I've set the gutter width
to accommodate files of up to 9,999 lines.

ROADMAP

There is still a lot to do.



"""
