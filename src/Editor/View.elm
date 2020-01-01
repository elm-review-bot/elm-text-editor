module Editor.View exposing (view,view2)

import Char
import Editor.Keymap
import Editor.Model exposing (InternalState)
import Editor.Update exposing (Msg(..))
import Html exposing (Attribute, Html, div, span, text, button, input)
import Html.Attributes as Attribute exposing (class, classList)
import Html.Events as Event exposing(onClick, onInput)
import Json.Decode as Decode
import Position exposing (Position)
import Window exposing(Window)
import RollingList


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
    div [ Attribute.style "background-color" "#eeeeee",  Attribute.style "width" "700px" ] [
      div
        [ class <| name ++ "-container"
        , Event.preventDefaultOn
            "keydown"
            (Decode.map withTrue Editor.Keymap.decoder)
        , Event.onMouseUp MouseUp
        , Event.onDoubleClick SelectGroup
        , onTripleClick SelectLine
        , Attribute.tabindex 0
        ]
        [ gutter state.cursor state.window
        , linesContainer <|
            List.indexedMap (line state.window state.cursor state.selection) (Window.select state.window lines)
        , div [Attribute.style "width" "100px"] [
               firstLineButton
              , upButton
              , downButton
              , lastLineButton
              , scrollPosition state
              , cursorPosition state
              , lineCount lines
              , resetButton
              , clearButton
            ]
        ]
        , div [Attribute.style "width" "692px", Attribute.style "padding-top" "10px",Attribute.style "height" "72px", Attribute.style "padding-left" "8px", Attribute.style "background-color" "#bbb"] [
            div [Attribute.style "width" "690px"] [ goToLineButton, acceptLineNumber, searchTextButton, acceptSearchText, replaceTextButton, acceptReplaceText]
          , div [Attribute.style "width" "690px", Attribute.style "height" "36px",  Attribute.style "margin-top" "0px"]
              [
                  div [ Attribute.style "float" "left", Attribute.style "width" "241px" ]
                        [text <| "Matches : " ++ (searchResultDisplay state)]
                  , searchForwardButton
                  , searchBackwardButton
              ]
         ]
         ]



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
    div columnButtonStyle  [text ("Lines: " ++ String.fromInt (List.length lines))]

cursorPosition : InternalState -> Html Msg
cursorPosition state =
    div columnButtonStyle  [text ("Cursor: " ++ String.fromInt (state.cursor.line + 1))]

scrollPosition : InternalState -> Html Msg
scrollPosition state =
    div columnButtonStyle  [text ("Scroll: " ++ String.fromInt state.window.first)]

view2 : List String -> InternalState -> Html Msg
view2 lines state =
    div
        [ class <| name ++ "-container" ]
        [ linesContainer <|
            List.indexedMap (line state.window state.cursor state.selection) lines
        ]


upButton = columnButton 80 ScrollUp "Up" []

downButton = columnButton 80 ScrollDown "Down" []

resetButton = columnButton 80 Reset "Reset" []

clearButton = columnButton 80 Clear "Clear" []

firstLineButton = columnButton 80 FirstLine "First" []

lastLineButton = columnButton 80 LastLine "Last" []

goToLineButton = rowButton 90 NoOp "Go to line" [Attribute.style "float" "left"]

searchForwardButton = rowButton 78 RollSearchSelectionForward "Next" [Attribute.style "float" "left"]

searchBackwardButton = rowButton 78 RollSearchSelectionBackward "Prev" [Attribute.style "float" "left"]

searchTextButton = rowButton 90 NoOp "Search" [Attribute.style "float" "left"]

replaceTextButton = rowButton 90 ReplaceCurrentSelection "Replace" [Attribute.style "float" "left"]

acceptLineNumber = myInput 30 AcceptLineNumber "" [ Attribute.style "float" "left" ]

acceptSearchText = myInput 155 AcceptSearchText "" [ Attribute.style "float" "left" ]

acceptReplaceText = myInput2 155  AcceptReplacementText "" [ Attribute.style "float" "left" ]

{-- WIDGETS -}


columnButtonStyle = [
      Attribute.style "margin-top" "10px"
     ,  Attribute.style "font-size" "12px"
     ,  Attribute.style "border" "none"
     , Attribute.style "margin-right" "8px"
  ]

rowButtonStyle = [
       Attribute.style "font-size" "12px"
     , Attribute.style "border" "none"
     , Attribute.style "margin-right" "8px"
  ]

buttonLabelStyle width = [  Attribute.style "font-size" "12px"
                    , Attribute.style "background-color" "#666"
                    , Attribute.style "color" "#eee"
                    , Attribute.style "width"  (String.fromInt width ++ "px")
                    , Attribute.style "height"  "24px"
                    , Attribute.style "border" "none"
                    ]

columnButton width msg str attr =
   div (columnButtonStyle ++ attr)
     [ button ([onClick msg] ++ buttonLabelStyle width ) [text str]]

rowButton width msg str attr =
   div (rowButtonStyle ++ attr)
     [ button ([onClick msg] ++ buttonLabelStyle width ) [text str]]

myInput width msg str attr =
    div ([ Attribute.style "margin-bottom" "10px" ] ++ attr)
        [ input [  Attribute.style "height"  "18px"
                 , Attribute.style "width" (String.fromInt width ++ "px")
                 , Attribute.type_ "text"
                 , Attribute.placeholder str
                 , Attribute.style "margin-right" "8px"
                 , onInput msg ] []
        ]


myInput2 width msg str attr =
    div ([ Attribute.style "margin-bottom" "10px" ] ++ attr)
        [ input [  Attribute.style "height"  "18px"
                 , Attribute.style "width" (String.fromInt width ++ "px")
                 , Attribute.type_ "text"
                 , Attribute.placeholder str
                 , onInput msg ] []
        ]