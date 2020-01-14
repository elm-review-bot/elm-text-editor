module Tests.Common exposing (Msg(..), app, config, initModel, insertBlank, insertOne, modelToString, msgFuzzer, msgTostring, noOp, removeCharAfter, removeCharBefore)

import ArchitectureTest exposing (..)
import Editor exposing (..)
import Editor.Config exposing (WrapOption(..))
import Editor.Update exposing (..)
import Fuzz exposing (Fuzzer, int, list, string)
import SingleSlider as Slider


app : TestedApp Editor EditorMsg
app =
    { model = ConstantModel initModel
    , update = NormalUpdate Editor.update
    , msgFuzzer = weightedMsgFuzzer
    , msgToString = msgTostring
    , modelToString = modelToString
    }


type Msg
    = EditorMsg EditorMsg
    | SliderMsg Slider.Msg


modelToString : Editor -> String
modelToString editor =
    "buffer: " ++ getSource editor


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


msgFuzzer : Fuzzer EditorMsg
msgFuzzer =
    Fuzz.oneOf
        [ noOp
        , firstLine
        , insert
        , removeCharBefore
        , removeCharAfter
        ]


weightedMsgFuzzer : Fuzzer EditorMsg
weightedMsgFuzzer =
    Fuzz.frequency
        [ ( 1, noOp )
        , ( 1, firstLine )
        , ( 10, insertOne )
        , ( 2, insertBlank )
        , ( 1, removeCharBefore )
        , ( 1, removeCharAfter )
        ]


noOp : Fuzzer EditorMsg
noOp =
    Fuzz.constant NoOp


firstLine : Fuzzer EditorMsg
firstLine =
    Fuzz.constant FirstLine


insertOne : Fuzzer EditorMsg
insertOne =
    Fuzz.string |> Fuzz.map oneCharString |> Fuzz.map Insert


oneCharString : String -> String
oneCharString str =
    case String.left 1 str of
        "" ->
            " "

        _ ->
            str


insert : Fuzzer EditorMsg
insert =
    Fuzz.string |> Fuzz.map Insert


insertBlank : Fuzzer EditorMsg
insertBlank =
    Fuzz.constant " " |> Fuzz.map Insert


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
