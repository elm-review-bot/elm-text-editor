module Main exposing (main)

import Browser
import Buffer exposing (Buffer)
import Editor exposing (State)
import Editor.Config
import Editor.Styles
import Editor.Widget as Widget
import Html exposing (Html, div, text)
import Html.Attributes as HA exposing(style)
import Html.Events as Event
import Json.Decode as Decode exposing (Decoder)
import SingleSlider as Slider
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


type Msg
    = EditorMsg Editor.Msg
    | KeyPress String
    | Test
    | FindTreasure
    | GetSpeech
    | Reset
    | SliderMsg Slider.Msg


type alias Model =
    { editorBuffer : Buffer
    , editorState : State
    , lastKeyPress : Maybe String
    }


defaultConfig =
    Editor.Config.default


init : () -> ( Model, Cmd Msg )
init () =
    ( { editorBuffer = Buffer.init Text.jabberwocky
      , editorState = Editor.init { defaultConfig | lines = 30, showInfoPanel = True }
      , lastKeyPress = Nothing
      }
    , Cmd.none
    )



-- UPDATE


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
            load Text.info model

        GetSpeech ->
            load Text.gettysburgAddress model

        Reset ->
            load Text.jabberwocky model

        FindTreasure ->
            highlightText "treasure" model

        SliderMsg sliderMsg ->
            let
                editorState =
                    model.editorState

                ( newSlider, cmd, updateResults ) =
                    Slider.update sliderMsg (Editor.slider editorState)

                newEditorState_ =
                    Editor.updateSlider newSlider editorState

                numberOfLines =
                    Buffer.lines model.editorBuffer
                        |> List.length
                        |> toFloat

                line =
                    newSlider.value
                        / 100.0
                        |> (\x -> x * numberOfLines)
                        |> round

                newEditorState =
                    Editor.scrollToLine line newEditorState_ model.editorBuffer |> Tuple.first

                newCmd =
                    if updateResults then
                        Cmd.batch [ Cmd.map SliderMsg cmd, Cmd.none ]

                    else
                        Cmd.none
            in
            ( { model | editorState = newEditorState }, newCmd )



-- HELPER FUNCTIONS FOR UPDATE


load : String -> Model -> ( Model, Cmd Msg )
load str model =
    let
        ( newEditorState, newEditorBuffer ) =
            Editor.load str model.editorState
    in
    ( { model | editorState = newEditorState, editorBuffer = newEditorBuffer }, Cmd.none )


highlightText : String -> Model -> ( Model, Cmd Msg )
highlightText str model =
    let
        ( newEditorState, newEditorBuffer ) =
            Editor.scrollToString str model.editorState model.editorBuffer
    in
    ( { model | editorState = newEditorState, editorBuffer = newEditorBuffer }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map SliderMsg <|
            Slider.subscriptions (Editor.slider model.editorState)
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div [ HA.style "position" "absolute", HA.style "top" "50px", HA.style "left" "50px" ]
        [ title
        , embeddedEditor model
        , div [ HA.style "font-size" "14px", HA.style "position" "absolute", HA.style "top" "440px", HA.style "left" "40px" ]
            [ Editor.sliderView model.editorState |> Html.map SliderMsg ]
        , footer model
        ]


title : Html Msg
title =
    div [ HA.style "font-size" "16px", HA.style "font-style" "bold", HA.style "margin-bottom" "10px" ]
        [ text "A Pure Elm Text Editor" ]


embeddedEditor : Model -> Html Msg
embeddedEditor model =
    div editorStyle
        [ Editor.Styles.styles
        , model.editorState
            |> Editor.view [style "background-color" "#eeeeee"] model.editorBuffer
            |> Html.map EditorMsg
        ]


editorStyle =
    [ Event.on "keydown" (keyDecoder KeyPress)
    , HA.style "background-color" "#dddddd"
    , HA.style "border" "solid 0.5px"
    , HA.style "width" "500px"
    ]


keyDecoder : (String -> msg) -> Decoder msg
keyDecoder keyToMsg =
    Decode.field "key" Decode.string
        |> Decode.map keyToMsg


footer : Model -> Html Msg
footer model =
    div [ HA.style "font-size" "14px", HA.style "position" "absolute", HA.style "top" "460px", HA.style "left" "40px" ]
        [ div [ HA.style "margin-top" "30px" ]
            [ Html.a [ HA.href "https://github.com/jxxcarlson/elm-text-editor" ] [ text "Source code (Work in Progress) Dec 27, 2009 — present" ]
            ]
        , div [ HA.style "margin-top" "10px" ] [ text "This is an unpublished fork of work of Sydney Nemzer: ", Html.a [ HA.href "https://github.com/SidneyNemzer/elm-text-editor" ] [ text "Source code" ] ]
        , div [ HA.style "margin-top" "10px" ] [ text "Press the 'Help' button upper-right for a list of key commands." ]
        , div [ HA.style "margin-top" "10px" ] [ testButton, resetButton, treasureButton, speechTextButton ]
        ]



-- BUTTONS


testButton =
    Widget.rowButton 80 Test "Info" []


treasureButton =
    Widget.rowButton 120 FindTreasure "Find treasure" []


speechTextButton =
    Widget.rowButton 160 GetSpeech "Gettysburg Address" []


resetButton =
    Widget.rowButton 80 Reset "Reset" []



-- WIDGETS


lastKeyDisplay : Maybe String -> Html Msg
lastKeyDisplay ms =
    let
        report =
            case ms of
                Nothing ->
                    "none"

                Just m ->
                    m
    in
    div [ HA.style "margin-top" "10px" ] [ text <| "Last key pressed: " ++ report ]
