module Editor.Config exposing (Config, WrapOption(..), default, setMaximumWrapWidth,setOptimumWrapWidth )


type alias Config =
    { lines : Int
    , wrapParams : WrapParams
    , showInfoPanel : Bool
    , wrapOption : WrapOption
    }


type alias WrapParams =
    { maximumWidth : Int
    , optimalWidth : Int
    , stringWidth : String -> Int
    }

-- TODO: Make maximumWidth and optimalWidth configurable at startup and at runtime

setMaximumWrapWidth : Int -> Config -> Config
setMaximumWrapWidth k config =
    let
      w = config.wrapParams
      newWrapParams = { w | maximumWidth = k }
    in
      { config | wrapParams = newWrapParams }

setOptimumWrapWidth : Int -> Config -> Config
setOptimumWrapWidth k config =
    let
      w = config.wrapParams
      newWrapParams = { w | optimalWidth = k }
    in
      { config | wrapParams = newWrapParams }


default : Config
default =
    { lines = 20
    , wrapParams =
        { maximumWidth = 50
        , optimalWidth = 45
        , stringWidth = String.length
        }
     , showInfoPanel = True
     , wrapOption = DoWrap
    }

type WrapOption = DoWrap | DontWrap

