
module Editor.Config exposing (Config, default)

type alias Config = {
     lines : Int
   , wrapParams : WrapParams
  }

type alias WrapParams = {
    maximumWidth : Int
   , optimalWidth : Int
   , stringWidth : String -> Int
  }

default : Config
default = {
      lines = 20
   ,  wrapParams = { maximumWidth = 50
           , optimalWidth = 45
           , stringWidth = String.length
           }
  }