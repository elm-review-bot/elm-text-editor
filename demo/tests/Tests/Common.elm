module Tests.Common exposing (app, insert, msgFuzzer, noOp, removeCharAfter, removeCharBefore)

import ArchitectureTest exposing (..)
import Editor exposing (..)
import Editor.Config exposing (WrapOption(..))
import Editor.Update exposing (..)
import Fuzz exposing (Fuzzer, int, list, string)
import SingleSlider as Slider


app : TestedApp Editor EditorMsg
app =
    { model = ConstantModel initModel
    , update = NormalUpdate update
    , msgFuzzer = msgFuzzer
    , msgToString = msgTostring
    , modelToString = modelToString
    }


type Msg
    = EditorMsg EditorMsg
    | SliderMsg Slider.Msg


modelToString : Editor -> String
modelToString editor =
    getSource editor


msgTostring : EditorMsg -> String
msgTostring editorMsg =
    case editorMsg of
        NoOp ->
            "NoOp"

        _ ->
            "Undefined"


initModel : Editor
initModel =
    Editor.init config "abc\ndef\n"


config : EditorConfig Msg
config =
    { editorMsg = EditorMsg
    , sliderMsg = SliderMsg
    , width = 450
    , height = 544
    , lineHeight = 16.0
    , showInfoPanel = False
    , wrapParams = { maximumWidth = 55, optimalWidth = 50, stringWidth = String.length }
    , wrapOption = DontWrap
    }


msgFuzzer : Fuzzer Msg
msgFuzzer =
    Fuzz.oneOf
        [ noOp
        , insert
        , removeCharBefore
        , removeCharAfter
        ]


noOp : Fuzzer EditorMsg
noOp =
    Fuzz.constant NoOp


insert : Fuzzer EditorMsg
insert =
    Fuzz.string |> Fuzz.map Insert


removeCharBefore : Fuzzer EditorMsg
removeCharBefore =
    Fuzz.constant RemoveCharBefore


removeCharAfter : Fuzzer EditorMsg
removeCharAfter =
    Fuzz.constant RemoveCharAfter



--
--hover : Fuzzer Msg
--hover =
--    Fuzz.oneOf
--        [ Fuzz.constant NoHover
--        , Fuzz.map HoverLine Fuzz.int
--        , Fuzz.map2 (\line column -> HoverChar { line = line, column = column }) Fuzz.int Fuzz.int
--        ]
--        |> Fuzz.map Hover
--
--
--goToHoveredPosition : Fuzzer Msg
--goToHoveredPosition =
--    Fuzz.constant GoToHoveredPosition
