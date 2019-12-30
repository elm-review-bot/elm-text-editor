module Editor.Model exposing (InternalState, Snapshot, lastLine)

import Buffer exposing (Buffer)
import Editor.History exposing (History)
import Position exposing (Position)
import Window exposing (Window)


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
    }

lastLine = 23
