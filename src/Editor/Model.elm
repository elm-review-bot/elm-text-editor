module Editor.Model exposing (InternalState, Snapshot, Config, defaultConfig, lastLine, initialText)

import Buffer exposing (Buffer)
import Editor.History exposing (History)
import Position exposing (Position)
import Window exposing (Window)
import Text
import RollingList exposing(RollingList)


type alias Config = {
     lines : Int
   , wrapParams : WrapParams
  }

type alias WrapParams = {
    maximumWidth : Int
   , optimalWidth : Int
   , stringWidth : String -> Int
  }

defaultConfig : Config
defaultConfig = {
     lines = 20
   ,  wrapParams = { maximumWidth = 50
           , optimalWidth = 45
           , stringWidth = String.length
           }
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

initialText = Text.jabberwocky
