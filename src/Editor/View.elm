module Editor.View exposing (view)

import Char
import Editor.Keymap
import Editor.Model exposing (InternalState)
import Editor.Update exposing (Msg(..))
import Html exposing (Attribute, Html, div, span, text, button, input)
import Html.Attributes as Attribute exposing (class, classList, style)
import Html.Events as Event exposing(onClick, onInput)
import Json.Decode as Decode
import Position exposing (Position)
import Window exposing(Window)
import RollingList
import Editor.Widget as Widget


name : String
name =
    "elm-editor"


selected : Position -> Maybe Position -> Position -> Bool
selected cursor maybeSelection char =
    maybeSelection
        |> Maybe.map (\selection -> Position.between cursor selection char)
        |> Maybe.withDefault False


{-| The non-breaking space character will not get whitespace-collapsed like a
regular space.
-}
nonBreakingSpace : Char
nonBreakingSpace =
    Char.fromCode 160


ensureNonBreakingSpace : Char -> Char
ensureNonBreakingSpace char =
    if char == ' ' then
        nonBreakingSpace

    else
        char


withTrue : a -> ( a, Bool )
withTrue a =
    ( a, True )

captureOnMouseDown : Msg -> Attribute Msg
captureOnMouseDown msg =
    Event.stopPropagationOn
        "mousedown"
        (Decode.map withTrue (Decode.succeed msg))


captureOnMouseOver : Msg -> Attribute Msg
captureOnMouseOver msg =
    Event.stopPropagationOn
        "mouseover"
        (Decode.map withTrue (Decode.succeed msg))


character : Window -> Position -> Maybe Position -> Position -> Char -> Html Msg
character window cursor selection position char =
    span
        [ classList
            [ ( name ++ "-line__character", True )
            , ( name ++ "-line__character--has-cursor", cursor == Window.shiftPosition_ window position )
            , ( name ++ "-line__character--selected"
              , selected cursor selection position
              )
            ]
         , captureOnMouseDown (MouseDown (Window.shiftPosition_ window position))
         , captureOnMouseOver (MouseOver (Window.shiftPosition_ window position))
        ]
        [ text <| String.fromChar <| ensureNonBreakingSpace char
        , if  cursor ==  Window.shiftPosition_ window position then
            span [ class <| name ++ "-cursor" ] [ text " " ]

          else
            text ""
        ]


line : Window -> Position -> Maybe Position -> Int -> String -> Html Msg
line window cursor selection index content =
    let
        length =
            String.length content

        endPosition =
            { line = index , column = length }

        {- Used below to correctly position and display the cursor -}
        offset = window.first -- (Window.getOffset window cursor.line)

    in
    div
        [ class <| name ++ "-line"
        , captureOnMouseDown (MouseDown endPosition)
        , captureOnMouseOver (MouseOver endPosition)
        ]
    <|
        List.concat
            [ [ span
                    [ class <| name ++ "-line__gutter-padding"
                    , captureOnMouseDown (MouseDown { line = index + 0, column = 0 })
                    , captureOnMouseOver (MouseOver { line = index + 0, column = 0 })
                    ]
                    [ text <| String.fromChar nonBreakingSpace ]
              ]
            , List.indexedMap
                ( Window.identity window index  >>  character window cursor selection)
                (String.toList content)
            , if index  == (Window.shiftPosition__ window cursor).line && cursor.column >= length  then
                [ span
                    [ class <| name ++ "-line__character"
                    , class <| name ++ "-line__character--has-cursor"
                    ]
                    [ text " "
                    , span [ class <| name ++ "-cursor" ] [ text " " ]
                    ]
                ]

              else
                []
            ]


onTripleClick : msg -> Attribute msg
onTripleClick msg =
    Event.on
        "click"
        (Decode.field "detail" Decode.int
            |> Decode.andThen
                (\detail ->
                    if detail >= 3 then
                        Decode.succeed msg

                    else
                        Decode.fail ""
                )
        )


lineNumber : Int -> Html Msg
lineNumber number =
    span
        [ class <| name ++ "-line-number"
        , captureOnMouseDown (MouseDown { line = number, column = 0 })
        , captureOnMouseOver (MouseOver { line = number, column = 0 })
        ]
        [ text <| String.fromInt (number + 0) ]


gutter : Position -> Window -> Html Msg
gutter cursor window =
    div [ class <| name ++ "-gutter" ] <|
        List.map lineNumber (List.range (window.first + 1) (window.last + 1))


linesContainer : List (Html Msg) -> Html Msg
linesContainer =
    div [ class <| name ++ "-lines"  ]


view : List String -> InternalState -> Html Msg
view lines state =
    div [ Attribute.style "background-color" "#eeeeee",  Attribute.style "width" "700px" , Attribute.style "position" "absolute" ]
     [
        goToLinePanel state
      ,  searchPanel state

      , div
        [ class <| name ++ "-container"
        , Event.preventDefaultOn
            "keydown"
            (Decode.map withTrue Editor.Keymap.decoder)
        , Event.onMouseUp MouseUp
        , Event.onDoubleClick SelectGroup
        , onTripleClick SelectLine
        , Attribute.tabindex 0
        , Attribute.style "width" "700px"
        ]
        [ gutter state.cursor state.window
        , linesContainer <|
            List.indexedMap (line state.window state.cursor state.selection) (Window.select state.window lines)
        , div [Attribute.style "width" "100px"] [
               toggleHelpButton state
              , scrollPosition state
              , cursorPosition state
              , lineCount lines
              , wordCount lines
            ]
        ]
         ]

searchPanel state =
    let
      opacity = if state.showSearchPanel == True then
        "0.7"
        else
        "0.0"
    in
    div [    Attribute.style "width" "600px"
           , Attribute.style "padding-top" "10px"
           ,  Attribute.style "height" "36px"
           , Attribute.style "padding-left" "8px"
           , Attribute.style "background-color" "#bbb"
           , Attribute.style "opacity" opacity
           , Attribute.style "font-size" "14px"
           , Attribute.style "position" "absolute"
           , Attribute.style "right" "8px"
           , Attribute.style "top" "80px"
       ]
       [
           searchTextButton
         , acceptSearchText
         , numberOfHitsDisplay state
         , replaceTextButton
         , acceptReplaceText
         , searchForwardButton
         , searchBackwardButton
       ]

 --  [text <| "Matches : " ++ (searchResultDisplay state)]
--         , div [ Attribute.style "float" "left", Attribute.style "width" "200px" ]


goToLinePanel state =
    let
      opacity = if state.showGoToLinePanel == True then
        "0"
        else
        "0.8"
    in
    div [  Attribute.style "width" "140px"
         , Attribute.style "height" "36px"
         ,  Attribute.style "padding" "ipx"
         ,  Attribute.style "opacity" opacity
         ,  Attribute.style "position" "absolute"
         ,  Attribute.style "right" "120px"
         ,  Attribute.style "top" "0px"
         ,  Attribute.style "background-color" "#aab"
       ]
       [       goToLineButton
             , acceptLineNumber

        ]

numberOfHitsDisplay : InternalState -> Html Msg
numberOfHitsDisplay state =
    let
       n = state.searchResults
            |> RollingList.toList
            |> List.length
            |> String.fromInt

    in
       Widget.rowButton 40 NoOp n []


searchResultDisplay : InternalState -> String
searchResultDisplay state =
    let
      lines = state.searchResults
            |> RollingList.toList
            |> List.map (Tuple.first >> .line)
            |> List.map ((\i -> i + 1) >> String.fromInt)

      fewerLines =
             List.take 5 lines
    in
      if List.length lines > List.length fewerLines then
        (String.join ", " fewerLines) ++ " ..."
      else
        String.join ", " lines


lineCount : List String -> Html Msg
lineCount lines =
    div Widget.columnButtonStyle  [text ("Lines: " ++ String.fromInt (List.length lines))]

wordCount : List String -> Html Msg
wordCount lines =
  let
      words = List.map String.words lines |> List.concat
  in
   div Widget.columnButtonStyle  [text ("Words: " ++ String.fromInt (List.length words))]




cursorPosition : InternalState -> Html Msg
cursorPosition state =
    div Widget.columnButtonStyle  [text ("Cursor: " ++ String.fromInt (state.cursor.line + 1))]

scrollPosition : InternalState -> Html Msg
scrollPosition state =
    div Widget.columnButtonStyle  [text ("Scroll: " ++ String.fromInt state.window.first)]

-- BUTTONS --

toggleHelpButton state =
  let
      label = if state.showHelp == True then
                "Help"
              else
                 "Back"
  in
   Widget.columnButton 80 ToggleHelp label []




upButton = Widget.columnButton 80 (ScrollUp 1) "Line Up" []

downButton = Widget.columnButton 80 (ScrollDown 1) "Line Down" []

jumpUpButton = Widget.columnButton 80 (ScrollUp 20) "Page Up" []

jumpDownButton = Widget.columnButton 80 (ScrollDown 20) "Page Down" []

clearButton = Widget.columnButton 80 Clear "Clear" []

firstLineButton = Widget.columnButton 80 FirstLine "First" []

lastLineButton = Widget.columnButton 80 LastLine "Last" []

wrapTextButton = Widget.columnButton 80 WrapText "Wrap" []

goToLineButton = Widget.rowButton 80 NoOp "Go to line" [
    Attribute.style "position" "absolute", Attribute.style "left" "8px",  Attribute.style "top" "6px"]

searchForwardButton = Widget.rowButton 30 RollSearchSelectionForward ">" [Attribute.style "float" "left"]

searchBackwardButton = Widget.rowButton 30 RollSearchSelectionBackward "<" [Attribute.style "float" "left"]

searchTextButton = Widget.rowButton 60 NoOp "Search" [Attribute.style "float" "left"]

replaceTextButton = Widget.rowButton 70 ReplaceCurrentSelection "Replace" [Attribute.style "float" "left"]

acceptLineNumber = Widget.myInput 30 AcceptLineNumber "" [
                              Attribute.style "position" "absolute", Attribute.style "left" "98px",  Attribute.style "top" "6px"]

acceptSearchText = Widget.myInput 130 AcceptSearchText "" [ Attribute.style "float" "left" ]

acceptReplaceText = Widget.myInput 130  AcceptReplacementText "" [ Attribute.style "float" "left" ]


