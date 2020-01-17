module Example exposing (suite)

import Buffer exposing (..)
import Debounce
import Editor exposing (EditorConfig, EditorMsg)
import Editor.Config exposing (WrapOption(..))
import Editor.History
import Editor.Model exposing (InternalState)
import Editor.Update exposing (Msg(..))
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Position exposing (Position)
import RollingList
import SingleSlider as Slider
import Test exposing (..)


testBuffer =
    Buffer "a\nbc"


type Msg
    = EditorMsg EditorMsg
    | SliderMsg Slider.Msg


editorConfig : EditorConfig Msg
editorConfig =
    { editorMsg = EditorMsg
    , sliderMsg = SliderMsg
    , width = 450
    , height = 544
    , lineHeight = 16.0
    , showInfoPanel = False
    , wrapParams = { maximumWidth = 55, optimalWidth = 50, stringWidth = String.length }
    , wrapOption = DontWrap
    }


state : InternalState
state =
    { config = Editor.smallConfig editorConfig
    , scrolledLine = 0
    , cursor = Position 0 0
    , window = { first = 0, last = 10 }
    , selection = Nothing
    , selectedText = Nothing
    , clipboard = ""
    , currentLine = Nothing
    , dragging = False
    , history = Editor.History.empty
    , searchTerm = ""
    , replacementText = ""
    , canReplace = False
    , searchResults = RollingList.fromList []
    , showHelp = True
    , showInfoPanel = editorConfig.showInfoPanel
    , showGoToLinePanel = False
    , showSearchPanel = False
    , savedBuffer = Buffer.fromString ""
    , debounce = Debounce.init
    , slider = Editor.Model.slider
    }


suite : Test
suite =
    describe "Editor update"
        [ describe "CursorForward"
            -- Nest as many descriptions as you like.
            [ test "has no effect on a palindrome" <|
                \_ ->
                    let
                        palindrome =
                            "hannah"
                    in
                    Expect.equal palindrome (String.reverse palindrome)

            -- Expect.equal is designed to be used in pipeline style, like this.
            , test "reverses a known string" <|
                \_ ->
                    "ABCDEFG"
                        |> String.reverse
                        |> Expect.equal "GFEDCBA"

            -- fuzz runs the test 100 times with randomly-generated inputs!
            , fuzz string "restores the original string if you run it again" <|
                \randomlyGeneratedString ->
                    randomlyGeneratedString
                        |> String.reverse
                        |> String.reverse
                        |> Expect.equal randomlyGeneratedString
            ]
        ]
