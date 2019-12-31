module Editor.Model exposing (InternalState, Snapshot, lastLine, initialText)

import Buffer exposing (Buffer)
import Editor.History exposing (History)
import Position exposing (Position)
import Window exposing (Window)
import TextExample
import RollingList exposing(RollingList)


type alias Snapshot =
    { cursor : Position
    , selection : Maybe Position
    , buffer : Buffer
    }


type alias InternalState =
    { scrolledLine : Int
    , window : Window
    , cursor : Position
    , selection : Maybe Position
    , selectedText : Maybe String 
    , dragging : Bool
    , history : History Snapshot
    , searchTerm : String
    , searchResults : RollingList (Position, Position)
    }

lastLine = 23

initialText = TextExample.text2
