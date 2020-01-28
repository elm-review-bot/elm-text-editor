module DemoSimple exposing (Msg(..), main)

import AppText
import Browser
import Editor exposing (Editor, EditorConfig, EditorMsg)
import Editor.Config exposing (WrapOption(..))
import Editor.Strings
import Html exposing (Html, button, div, text)
import Html.Attributes as HA exposing (style)
import Html.Events exposing (onClick)


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
    = EditorMsg EditorMsg
    | Test
    | FindTreasure
    | GetSpeech
    | GetLongLongLines
    | Reset
    | LogErr String


type alias Model =
    { editor : Editor
    , clipboard : String
    , document : Document
    }


type Document
    = Jabberwock
    | Gettysburg
    | LongLines


init : () -> ( Model, Cmd Msg )
init () =
    ( { editor = Editor.init config AppText.jabberwocky
      , clipboard = ""
      , document = Jabberwock
      }
    , Cmd.none
    )


config : EditorConfig Msg
config =
    { editorMsg = EditorMsg
    , width = 500
    , height = 480
    , lineHeight = 16.0
    , showInfoPanel = True
    , wrapParams = { maximumWidth = 55, optimalWidth = 50, stringWidth = String.length }
    , wrapOption = DontWrap
    }



--editorStyle : List (Html.Attribute msg)
--editorStyle =
--    [ HA.style "background-color" "#dddddd"
--    , HA.style "border" "solid 0.5px"
--    ]
-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditorMsg editorMsg ->
            let
                ( editor, cmd ) =
                    Editor.update editorMsg model.editor
            in
            ( { model | editor = editor }, Cmd.map EditorMsg cmd )

        Test ->
            load DontWrap Editor.Strings.info model

        GetSpeech ->
            load DoWrap AppText.gettysburgAddress { model | document = Gettysburg }

        GetLongLongLines ->
            load DontWrap AppText.longLines { model | document = LongLines }

        Reset ->
            load DontWrap AppText.jabberwocky { model | document = Jabberwock }

        FindTreasure ->
            highlightText "treasure" model

        LogErr _ ->
            ( model, Cmd.none )



-- HELPER FUNCTIONS FOR UPDATE


{-| Paste contents of clipboard into Editor
-}
pasteToClipboard : Model -> String -> ( Model, Cmd msg )
pasteToClipboard model editor =
    ( { model
        | editor =
            Editor.insert
                (Editor.getWrapOption model.editor)
                (Editor.getCursor model.editor)
                editor
                model.editor
      }
    , Cmd.none
    )


pasteToEditorClipboard : Model -> String -> ( Model, Cmd msg )
pasteToEditorClipboard model str =
    let
        cursor =
            Editor.getCursor model.editor

        wrapOption =
            Editor.getWrapOption model.editor

        editor2 =
            Editor.placeInClipboard str model.editor
    in
    ( { model | editor = Editor.insert wrapOption cursor str editor2 }, Cmd.none )


{-| Load text into Editor
-}
load : WrapOption -> String -> Model -> ( Model, Cmd Msg )
load wrapOption text model =
    let
        newEditor =
            Editor.load wrapOption text model.editor
    in
    ( { model | editor = newEditor }, Cmd.none )


{-| Find str and highlight it
-}
highlightText : String -> Model -> ( Model, Cmd Msg )
highlightText str model =
    let
        newEditor =
            Editor.scrollToString str model.editor
    in
    ( { model | editor = newEditor }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ HA.style "margin" "60px" ]
        [ title
        , Editor.embedded config model.editor
        , footer model
        ]


title : Html Msg
title =
    div [ HA.style "font-size" "16px", HA.style "font-style" "bold", HA.style "margin-bottom" "10px" ]
        [ text "A Pure Elm Text Editor (Simple)" ]


footer : Model -> Html Msg
footer model =
    div
        [ HA.style "font-size" "14px", HA.style "position" "absolute", HA.style "top" "590px", HA.style "left" "80px" ]
        [ div []
            [ Html.a [ HA.href "https://github.com/jxxcarlson/elm-text-editor" ] [ text "Source code (Work in Progress)" ]
            ]
        , div [ HA.style "margin-top" "10px" ] [ text "This app is based on  ", Html.a [ HA.href "https://sidneynemzer.github.io/elm-text-editor/" ] [ text "work of Sydney Nemzer" ] ]
        , div [ HA.style "margin-top" "10px" ] [ text "Press the 'Help' button upper-right for a list of key commands, or use ctrl-h to toggle" ]
        , div [ HA.style "margin-top" "10px" ] [ text "ctrl-shift i to toggle info panel." ]
        , div [ HA.style "margin-top" "10px" ] [ resetButton, treasureButton model, speechTextButton, longLinesTextButton ]
        ]



-- BUTTONS


testButton =
    rowButton 80 Test "Info" []


treasureButton model =
    case model.document of
        Jabberwock ->
            rowButton 120 FindTreasure "Find treasure" []

        _ ->
            Html.span [] []


speechTextButton =
    rowButton 160 GetSpeech "Gettysburg Address" []


longLinesTextButton =
    rowButton 160 GetLongLongLines "Long lines" []


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
