module Main exposing (Msg(..), main)

import Browser
import Browser.Dom as Dom
import Dict exposing (Dict)
import Editor exposing (Editor, EditorConfig, EditorMsg)
import Editor.Config exposing (WrapOption(..))
import Editor.Update as E
import Html exposing (Html, button, div, span, text)
import Html.Attributes as HA exposing (style)
import Html.Events exposing (onClick)
import Json.Encode as E
import Markdown.Elm
import Markdown.Option exposing (..)
import Markdown.Parse as Parse
import Outside
import Strings
import Task exposing (Task)
import Tree exposing (Tree)


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


type Msg
    = NoOp
    | EditorMsg EditorMsg
    | Test
    | GotViewport (Result Dom.Error Dom.Viewport)
    | TestFile
    | ElmLesson
    | MarkdownExample
    | ChangeLog
    | About
    | Outside Outside.InfoForElm
    | LogErr String
    | SetViewPortForElement (Result Dom.Error ( Dom.Element, Dom.Viewport ))


documentDict : Dict String ( Msg, String )
documentDict =
    Dict.fromList
        [ ( "about", ( About, Strings.about ) )
        , ( "elmLesson", ( ElmLesson, Strings.lesson ) )
        , ( "changeLog", ( ChangeLog, Strings.changeLog ) )
        , ( "markdownExample", ( MarkdownExample, Strings.markdownExample ) )
        , ( "test", ( TestFile, Strings.test ) )
        ]


getMsgFromTitle : String -> Msg
getMsgFromTitle title_ =
    Dict.get title_ documentDict
        |> Maybe.withDefault ( About, Strings.about )
        |> Tuple.first


type alias Model =
    { editor : Editor
    , clipboard : String
    , message : String
    , sourceText : String
    , ast : Tree Parse.MDBlockWithId
    , currentDocumentTitle : String
    , width : Float
    , height : Float
    }


type alias Flags =
    { width : Float
    , height : Float
    }


windowProportion =
    { width = 0.4
    , height = 0.7
    }


px : Float -> String
px k =
    String.fromFloat k ++ "px"


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { editor =
            Editor.init
                { config
                    | width = windowProportion.width * flags.width
                    , height = windowProportion.height * flags.height
                }
                Strings.about
      , clipboard = ""
      , sourceText = Strings.about
      , ast = Parse.toMDBlockTree 0 Extended Strings.about
      , message = "Starting up"
      , currentDocumentTitle = "about"
      , width = flags.width
      , height = flags.height
      }
    , Cmd.none
    )


config : EditorConfig Msg
config =
    { editorMsg = EditorMsg
    , width = 450
    , height = 544
    , lineHeight = 20.0
    , showInfoPanel = False
    , wrapParams = { maximumWidth = 50, optimalWidth = 45, stringWidth = String.length }
    , wrapOption = DontWrap
    , fontProportion = 0.75
    , lineHeightFactor = 1.0
    }



-- UPDATE


verticalOffset =
    -5 * 16


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        EditorMsg editorMsg ->
            let
                ( newEditor, editorCmd ) =
                    Editor.update editorMsg model.editor
            in
            case editorMsg of
                E.CopyPasteClipboard ->
                    let
                        clipBoardCmd =
                            if editorMsg == E.CopyPasteClipboard then
                                Outside.sendInfo (Outside.AskForClipBoard E.null)

                            else
                                Cmd.none
                    in
                    ( { model | editor = newEditor, sourceText = Editor.getSource newEditor }, Cmd.batch [ clipBoardCmd, Cmd.map EditorMsg editorCmd ] )

                E.WriteToSystemClipBoard ->
                    ( { model | editor = newEditor }, Outside.sendInfo (Outside.WriteToClipBoard (Editor.getSelectedText newEditor |> Maybe.withDefault "Nothing!!")) )

                E.Unload _ ->
                    syncWithEditor model newEditor editorCmd

                E.RemoveCharAfter ->
                    syncWithEditor model newEditor editorCmd

                E.RemoveCharBefore ->
                    syncWithEditor model newEditor editorCmd

                E.Cut ->
                    syncWithEditor model newEditor editorCmd

                E.Paste ->
                    syncWithEditor model newEditor editorCmd

                E.Undo ->
                    syncWithEditor model newEditor editorCmd

                E.Redo ->
                    syncWithEditor model newEditor editorCmd

                E.WrapSelection ->
                    syncWithEditor model newEditor editorCmd

                E.Clear ->
                    syncWithEditor model newEditor editorCmd

                E.WrapAll ->
                    syncWithEditor model newEditor editorCmd

                E.SendLine ->
                    ( { model | editor = newEditor }, syncRenderedText (Editor.lineAtCursor newEditor) model )

                _ ->
                    ( { model | editor = newEditor }, Cmd.map EditorMsg editorCmd )

        SetViewPortForElement result ->
            case result of
                Ok ( element, viewport ) ->
                    ( { model | message = "synced" }, setViewPortForSelectedLine verticalOffset element viewport )

                Err _ ->
                    ( { model | message = "sync error" }, Cmd.none )

        TestFile ->
            loadDocument "test" model

        Test ->
            ( model, Dom.getViewportOf "__inner_editor__" |> Task.attempt GotViewport )

        GotViewport result ->
            case result of
                Ok vp ->
                    --                    let
                    --                        _ =
                    --                            Debug.log "VP" vp
                    --                    in
                    ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        About ->
            loadDocument "about" model

        ElmLesson ->
            loadDocument "elmLesson" model

        MarkdownExample ->
            loadDocument "markdownExample" model

        ChangeLog ->
            loadDocument "changeLog" model

        Outside infoForElm ->
            case infoForElm of
                Outside.GotClipboard clipboard ->
                    pasteToEditorClipboard model clipboard

        LogErr _ ->
            ( model, Cmd.none )



-- HELPER FUNCTIONS FOR UPDATE


syncWithEditor : Model -> Editor -> Cmd EditorMsg -> ( Model, Cmd Msg )
syncWithEditor model editor cmd =
    let
        newSource =
            Editor.getSource editor
    in
    ( { model
        | editor = editor
        , sourceText = newSource
        , ast = Parse.toMDBlockTree 0 Extended newSource
      }
    , Cmd.map EditorMsg cmd
    )


syncRenderedText : String -> Model -> Cmd Msg
syncRenderedText str model =
    let
        id =
            --            Debug.log "Rendered ID"
            getId (String.trim str) (Parse.sourceMap model.ast) |> Maybe.withDefault "__Not found__"
    in
    setViewportForElement id


{-| Return values whose keys contain the given string
-}
getId : String -> Dict String String -> Maybe String
getId str_ sourceMap =
    let
        str =
            Parse.toMDBlockTree 66 ExtendedMath str_ |> Parse.getLeadingTextFromAST |> String.trim
    in
    List.filter (\( k, _ ) -> String.contains str k) (Dict.toList sourceMap)
        |> List.map (\( _, id ) -> id)
        |> List.head


setViewportForElement : String -> Cmd Msg
setViewportForElement id =
    Dom.getViewportOf "__rt_scroll__"
        |> Task.andThen (\vp -> getElementWithViewPort vp id)
        |> Task.attempt SetViewPortForElement


getElementWithViewPort : Dom.Viewport -> String -> Task Dom.Error ( Dom.Element, Dom.Viewport )
getElementWithViewPort vp id =
    Dom.getElement id
        |> Task.map (\el -> ( el, vp ))


setViewPortForSelectedLine : Float -> Dom.Element -> Dom.Viewport -> Cmd Msg
setViewPortForSelectedLine offset element viewport =
    let
        y =
            viewport.viewport.y + element.element.y - element.element.height + offset
    in
    Task.attempt (\_ -> NoOp) (Dom.setViewportOf "__rt_scroll__" 0 y)



-- COPY-PASTE


{-| Paste contents of clipboard into Editor
-}
pasteToClipboard : Model -> String -> ( Model, Cmd msg )
pasteToClipboard model str =
    ( { model | editor = Editor.insert (Editor.getWrapOption model.editor) (Editor.getCursor model.editor) str model.editor }, Cmd.none )


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


loadDocument : String -> Model -> ( Model, Cmd Msg )
loadDocument title_ model =
    let
        ( _, content ) =
            Dict.get title_ documentDict |> Maybe.withDefault ( About, Strings.about )

        editor =
            Editor.load DontWrap content model.editor

        ast =
            Parse.toMDBlockTree 0 Extended content
    in
    ( { model | editor = editor, ast = ast, sourceText = content, currentDocumentTitle = title_ }, Cmd.none )


{-| Load text into Editor
-}
load : WrapOption -> String -> Model -> ( Model, Cmd Msg )
load wrapOption str model =
    let
        newEditor =
            Editor.load wrapOption str model.editor
    in
    ( { model | editor = newEditor, sourceText = str }, Cmd.none )


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
    Sub.batch
        [ Outside.getInfo Outside LogErr
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ HA.style "margin" "30px"
        , HA.class "flex-column"
        , HA.style "width" "1200px"
        , HA.attribute "id" "__outer_editor__"
        ]
        [ title
        , div
            [ HA.class "flex-row"
            , HA.style "width" (px model.width)
            , HA.style "align-items" "stretch"
            ]
            [ embeddedEditor model, renderedText model ]
        , footer model
        ]


embeddedEditor : Model -> Html Msg
embeddedEditor model =
    div [ style "width" (px <| min (maxPaneWidth + 30) (windowProportion.width * model.width + 40)) ]
        [ Editor.embedded
            { config
                | width = min maxPaneWidth (windowProportion.width * model.width + 30)
                , height = windowProportion.height * model.height + 24 - 20
            }
            model.editor
        ]


maxPaneWidth =
    450


renderedText model =
    div
        [ HA.style "flex" "row"
        , HA.style "width" (px <| min maxPaneWidth (windowProportion.width * model.width))
        , HA.style "height" (px <| windowProportion.height * model.height - 20)
        , HA.style "border" "solid"
        , HA.style "border-color" "#444"
        , HA.style "border-width" "0.5px"
        , HA.style "overflow-y" "scroll"
        , HA.style "order" "1"
        , HA.style "align-self" "left"
        , HA.style "padding" "12px"
        , HA.attribute "id" "__rt_scroll__"
        ]
        [ Markdown.Elm.toHtml Extended model.sourceText ]


title : Html Msg
title =
    div [ HA.style "font-size" "16px", HA.style "font-style" "bold", HA.style "margin-bottom" "10px" ]
        [ text "A Pure Elm Text Editor" ]


footer : Model -> Html Msg
footer model =
    div
        [ HA.style "font-size" "14px", HA.style "margin-top" "16px", HA.class "flex-column" ]
        [ div [ HA.style "margin-top" "20px", HA.class "flex-row-text-aligned" ]
            [ aboutButton model, testFileButton model, markdownExampleButton model, elmLessonButton model, changeLogButton model, div [ style "width" "200px", messageColor model.message ] [ text model.message ] ]
        , div [ HA.style "margin-top" "10px" ]
            [ Html.a [ HA.href "https://github.com/jxxcarlson/elm-text-editor" ] [ text "Source code (Work in Progress)." ]
            , text "The editor in this app is based on  "
            , Html.a [ HA.href "https://sidneynemzer.github.io/elm-text-editor/" ] [ text "work of Sydney Nemzer" ]
            ]
        , div [ HA.style "margin-top" "10px" ] [ text "ctrl-h to toggle help, ctrl-shift-i for info panel", testButton model ]
        ]


messageColor : String -> Html.Attribute msg
messageColor str =
    case String.contains "error" str of
        True ->
            HA.style "color" "#a00"

        False ->
            HA.style "color" "#444"



-- BUTTONS


testFileButton model =
    rowButton model 70 TestFile "Test file" []


testButton model =
    rowButton model 40 Test "Test" []


elmLessonButton model =
    rowButton model 120 ElmLesson "Elm Lesson" []


markdownExampleButton model =
    rowButton model 120 MarkdownExample "markdownExample" []


changeLogButton model =
    rowButton model 150 ChangeLog "Issues and Change Log" []


aboutButton model =
    rowButton model 80 About "About" []



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
    , style "margin-right" "10px"
    ]


activeRowButtonLabelStyle width =
    [ style "font-size" "12px"
    , style "background-color" "#922"
    , style "color" "#eee"
    , style "width" (String.fromInt width ++ "px")
    , style "height" "24px"
    , style "border" "none"
    , style "margin-right" "10px"
    ]


rowButton model width msg str attr =
    let
        style_ =
            case getMsgFromTitle model.currentDocumentTitle == msg of
                True ->
                    activeRowButtonLabelStyle width

                False ->
                    rowButtonLabelStyle width
    in
    div (rowButtonStyle ++ attr)
        [ button ([ onClick msg ] ++ style_) [ text str ] ]
