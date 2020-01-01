module Editor.Model exposing (InternalState, Snapshot, Config, defaultConfig, lastLine, initialText)

import Buffer exposing (Buffer)
import Editor.History exposing (History)
import Position exposing (Position)
import Window exposing (Window)
import TextExample
import RollingList exposing(RollingList)


type alias Config = {
   lines : Int
  }

defaultConfig = {
   lines = 20
  }

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

initialText = TextExample.text2
