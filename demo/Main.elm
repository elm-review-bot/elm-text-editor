module Main exposing (main)

import Browser
import Buffer exposing (Buffer)
import Editor exposing(State)
import Editor.Styles
import Editor.Config
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


defaultConfig = Editor.Config.default


init : () -> ( Model, Cmd Msg )
init () =
    ( { editorBuffer = Buffer.init Text.jabberwocky
      , editorState = Editor.init {defaultConfig | lines = 30}
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
    | GetSpeech
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

        GetSpeech ->
            load Text.gettysburgAddress model

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
             , footer model
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

footer : Model -> Html Msg
footer model =
       div [HA.style "font-size" "14px", HA.style "position" "absolute",  HA.style "top" "480px"] [
           div [HA.style "margin-top" "30px"] [
              Html.a [Attributes.href "https://github.com/jxxcarlson/elm-text-editor"] [text "Source code (Work in Progress)"] ]
           , div [HA.style "margin-top" "10px"] [text "This is a fork of work of Sydney Nemzer: ", Html.a [Attributes.href "https://github.com/SidneyNemzer/elm-text-editor"] [text "Source code"]]
           , div [HA.style "margin-top" "10px"] [text "Press the 'Help' button upper-right for a list of key commands."]
--           , div [HA.style "margin-top" "10px"] [text "The new wrap needs more thought"]
--           , lastKeyDisplay model.lastKeyPress
           , div [Attributes.style "margin-top" "10px"] [testButton, resetButton, treasureButton, speechTextButton]
          ]


testButton = Widget.rowButton 80 Test "Info" []

treasureButton = Widget.rowButton 120 FindTreasure "Find treasure" []

speechTextButton = Widget.rowButton 160 GetSpeech "Gettysburg Address" []

resetButton = Widget.rowButton 80 Reset "Reset" []


lastKeyDisplay : Maybe String -> Html Msg
lastKeyDisplay ms =
    let
      report = case ms of
                   Nothing -> "none"
                   Just m -> m
   in
      div [HA.style "margin-top" "10px"] [text <| "Last key pressed: " ++ report]