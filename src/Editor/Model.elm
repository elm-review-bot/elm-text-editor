module Editor.Model exposing (InternalState, Snapshot, lastLine, initialText)

import Buffer exposing (Buffer)
import Editor.History exposing (History)
import Position exposing (Position)
import Window exposing (Window)
import Text
import RollingList exposing(RollingList)
import Editor.Config exposing (Config)



type alias Snapshot =
    { cursor : Position
    , selection : Maybe Position
    , buffer : Buffer
    }

type alias InternalState =
    { config : Config
    , scrolledLine : Int
    , window : Window
    , cursor : Position
    , selection : Maybe Position
    , selectedText : Maybe String 
    , dragging : Bool
    , history : History Snapshot
    , searchTerm : String
    , replacementText : String
    , searchResults : RollingList (Position, Position)
    }

lastLine = 23

initialText = Text.jabberwocky
