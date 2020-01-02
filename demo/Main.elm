module Main exposing (main)

import Browser
import Buffer exposing (Buffer)
import Editor exposing(State)
import Editor.Model
import Editor.Styles
import Editor.Model
import Text
import Html exposing (Html, div,  text)
import Html.Events as Event
import Html.Attributes as HA
import Json.Decode as Decode exposing (Decoder)
import Html.Attributes as Attributes
import Editor.Widget as Widget
import Text


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

-- INIT


type alias Model =
    { editorBuffer : Buffer
    , editorState : State
    , lastKeyPress : Maybe String
    }


defaultConfig = Editor.Model.defaultConfig


init : () -> ( Model, Cmd Msg )
init () =
    ( { editorBuffer = Buffer.init Text.tolstoy
      , editorState = Editor.init {defaultConfig | lines = 25}
      , lastKeyPress = Nothing
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = EditorMsg Editor.Msg
    | KeyPress String
    | Test
    | FindTreasure
    | Reset


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditorMsg msg_ ->
            let
                ( editor, content, cmd ) =
                    Editor.update model.editorBuffer msg_ model.editorState
            in
            ( { model
                | editorState = editor
                , editorBuffer = content
              }
            , Cmd.map EditorMsg cmd
            )

        KeyPress key ->
            ( { model | lastKeyPress = Just key }, Cmd.none )

        Test ->
            load Text.testString model

        Reset ->
            load Text.jabberwocky model

        FindTreasure ->
            highlightText"treasure" model



-- HELPER FUNCTIONS FOR UPDATE

load : String -> Model ->  (Model, Cmd Msg)
load str model =
   let
     (newEditorState, newEditorBuffer) = Editor.load str model.editorState
   in
    ( { model | editorState = newEditorState, editorBuffer = newEditorBuffer }, Cmd.none)


highlightText : String -> Model -> (Model, Cmd Msg)
highlightText str model =
    let
       (newEditorState, newEditorBuffer) = Editor.scrollToString str model.editorState model.editorBuffer
    in
      ( {model | editorState = newEditorState, editorBuffer = newEditorBuffer}, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


keyDecoder : (String -> msg) -> Decoder msg
keyDecoder keyToMsg =
    Decode.field "key" Decode.string
        |> Decode.map keyToMsg


view : Model -> Html Msg
view model =
    div [] [
               title
             , embeddedEditor model
             , footer
           ]

title : Html Msg
title =
  div [HA.style "font-size" "16px", HA.style "font-style" "bold" , HA.style "margin-bottom" "10px" ]
            [text "A Pure Elm Text Editor"]

embeddedEditor : Model -> Html Msg
embeddedEditor model =
    div
        [   Event.on "keydown" (keyDecoder KeyPress)
          , HA.style  "backround-color" "#dddddd"
          , HA.style "border" "solid 0.5px"
          , HA.style "width" "700px"
        ]
        [  Editor.Styles.styles
         , model.editorState
            |> Editor.view model.editorBuffer
            |> Html.map EditorMsg
        ]

footer : Html Msg
footer =
       div [HA.style "font-size" "14px"] [
           div [HA.style "margin-top" "30px"] [
              Html.a [Attributes.href "https://github.com/jxxcarlson/elm-text-editor"] [text "Source code: "]
             , text "needs lots of testing and issue posting/fixing" ]
           , div [HA.style "margin-top" "10px"] [text "This is a fork of work of Sydney Nemzer: ", Html.a [Attributes.href "https://github.com/SidneyNemzer/elm-text-editor"] [text "Source code"]]
           , div [HA.style "margin-top" "10px"] [text "ctrl-c to copy selection; ctrl-x to cut; ctrl-v to paste copied text"]
           , div [HA.style "margin-top" "10px"] [text "New wrap function needs a lot of work."]
           , div [Attributes.style "margin-top" "20px"] [testButton, resetButton, treasureButton]
          ]


testButton = Widget.rowButton 80 Test "Test" []

treasureButton = Widget.rowButton 120 FindTreasure "Find treasure" []

resetButton = Widget.rowButton 80 Reset "Reset" []
