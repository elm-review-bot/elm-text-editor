module Main exposing (Msg(..), main)


import Browser
import Buffer exposing (Buffer)
import Editor exposing (EditorConfig, PEEditorMsg, State)
import Editor.Config exposing (WrapOption(..))
import Html exposing (Html, div, text, button)
import Html.Attributes as HA exposing(style)
import Html.Events exposing(onClick)
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
    = EditorMsg PEEditorMsg
    | Test
    | FindTreasure
    | GetSpeech
    | Reset
    | SliderMsg Slider.Msg


type alias Model =
    { editorBuffer : Buffer
    , editorState : State
    }



init : () -> ( Model, Cmd Msg )
init () =
    ( { editorBuffer = Buffer.init Text.jabberwocky
      , editorState = Editor.init config
      }
    , Cmd.none
    )


-- config : { editorMsg : PEEditorMsg -> Msg, sliderMsg : Slider.Msg -> Msg, editorStyle : List (Html.Attribute msg), width : Int, lines : Int, showInfoPanel : Bool, wrapParams : { maximumWidth : Int, optimalWidth : Int, stringWidth : String -> Int }, wrapOption : WrapOption }


config =
    { editorMsg = EditorMsg
    , sliderMsg = SliderMsg
    , editorStyle = editorStyle
    , width = 550
    , lines = 30
    , showInfoPanel = True
    , wrapParams = { maximumWidth = 55, optimalWidth = 50, stringWidth = String.length }
    , wrapOption = DontWrap
    }


editorStyle : List (Html.Attribute msg)
editorStyle =
    [ HA.style "background-color" "#dddddd"
    , HA.style "border" "solid 0.5px"
    ]


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

        Test ->
            load DontWrap Text.info model

        GetSpeech ->
            load DoWrap Text.gettysburgAddress model

        Reset ->
            load DontWrap Text.jabberwocky model

        FindTreasure ->
            highlightText "treasure" model

        SliderMsg sliderMsg ->
          let
            (newEditorState, cmd) = Editor.sliderUpdate sliderMsg  model.editorState model.editorBuffer
          in
            ( { model | editorState = newEditorState }, cmd  |> Cmd.map SliderMsg )



-- HELPER FUNCTIONS FOR UPDATE


load : WrapOption -> String -> Model -> ( Model, Cmd Msg )
load wrapOption str model =
    let
        ( newEditorState, newEditorBuffer ) =
            Editor.load wrapOption str model.editorState
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
    div [HA.style "margin" "60px"]
        [ title
        , Editor.embedded config  model.editorState model.editorBuffer
        , footer model
        ]



title : Html Msg
title =
    div [ HA.style "font-size" "16px", HA.style "font-style" "bold", HA.style "margin-bottom" "10px" ]
        [ text "A Pure Elm Text Editor" ]


footer : Model -> Html Msg
footer model =
    div
        [ HA.style "font-size" "14px", HA.style "position" "absolute", HA.style "top" "520px", HA.style "left" "80px" ]
        [ div [  ]
            [ Html.a [ HA.href "https://github.com/jxxcarlson/elm-text-editor" ] [ text "Source code (Work in Progress) Dec 27, 2009 — present" ]
            ]
        , div [ HA.style "margin-top" "10px" ] [ text "This is an unpublished fork of work of Sydney Nemzer: ", Html.a [ HA.href "https://github.com/SidneyNemzer/elm-text-editor" ] [ text "Source code" ] ]
        , div [ HA.style "margin-top" "10px" ] [ text "Press the 'Help' button upper-right for a list of key commands." ]
        , div [ HA.style "margin-top" "10px" ] [ text "ctrl-shift i to toggle info panel." ]
        , div [ HA.style "margin-top" "10px" ] [ testButton, resetButton, treasureButton, speechTextButton ]
        ]



-- BUTTONS


testButton =
    rowButton 80 Test "Info" []


treasureButton =
    rowButton 120 FindTreasure "Find treasure" []


speechTextButton =
    rowButton 160 GetSpeech "Gettysburg Address" []


resetButton =
    rowButton 80 Reset "Reset" []


-- STYLE --

rowButtonStyle =
    [ style "font-size" "12px"
    , style "border" "none"
    , style "margin-right" "8px"
    , style "float" "left"
    ]


rowButtonLabelStyle width =
    [ style "font-size" "12px"
    , style "background-color" "#666"
    , style "color" "#eee"
    , style "width" (String.fromInt width ++ "px")
    , style "height" "24px"
    , style "border" "none"
    ]


rowButton width msg str attr =
    div (rowButtonStyle ++ attr)
        [ button ([ onClick msg ] ++ rowButtonLabelStyle width) [ text str ] ]

