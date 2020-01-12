module Editor.Styles exposing (editorStyles)

import Html exposing (Html, text)
import String.Interpolate exposing (interpolate)


style : List (Html.Attribute msg) -> List (Html msg) -> Html msg
style =
    Html.node "style"


styleText : { editorWidth : Int, numberOfLines : Int, lineHeight : Float } -> String
styleText data =
    let
        editorHeight =
            toFloat data.numberOfLines * data.lineHeight
    in
    interpolate styleTemplate
        [ String.fromInt data.editorWidth
        , String.fromFloat (sliderOffsetX data.editorWidth)
        , String.fromFloat (0.8 * data.lineHeight) -- {2} font size
        , String.fromFloat data.lineHeight -- {3}
        , String.fromFloat <| sliderOffsetY data.numberOfLines data.lineHeight -- {4}
        , String.fromFloat <| editorHeight -- {5}
        ]


sliderOffsetX : Int -> Float
sliderOffsetX k =
    (k + 50)
        |> toFloat
        |> (\x -> 1.0 * x)


sliderOffsetY : Int -> Float -> Float
sliderOffsetY numberOfLines lineHeight =
    0.8 * toFloat numberOfLines * lineHeight


styleTemplate : String
styleTemplate =
    """

body { font-size: {2}px;
       line-height: {3}px;}

.elm-editor-container {
  font-family: monospace;
  border: 1px solid lightgray;
  width: {0}px;
  user-select: none;
  -webkit-user-select: none;
  display: flex;
  overflow-x : scroll;
  overflow-y : hidden;
  height: {5}px;
}

.elm-editor-container:focus {
  outline: none;
}

.elm-editor-gutter {
  display: flex;
  flex-direction: column;
  flex-shrink: 0;
}

.elm-editor-lines {
  flex-grow: 1;
}

.elm-editor-line-number {
  display: inline-block;
  width: 35px;
  padding-right: 5px;
  text-align: right;
  background-color: lightgray;
  cursor: default;
}

.elm-editor-line {
  cursor: text;
}

.elm-editor-line__gutter-padding {
  width: 5px;
}

.elm-editor-line__character--has-cursor {
  position: relative;
}

.elm-editor-line__character--selected {
  background-color: cornflowerblue;
  color: white;
}

.elm-editor-cursor {
  position: absolute;
  border-left: 16px solid #990000;
  opacity: 0.2;
  left: 0;
  height: 100%;
}

.elm-editor-container:focus .elm-editor-cursor {
  animation: 1s blink step-start infinite;
  border-left: 4px solid #333333;
}

@keyframes blink {
  from, to {
    opacity: 0;
  }
  50% {
    opacity: 1;s
  }
}


body {
    font-family: sans-serif;
    background-color : #cccccc;

    }

.center-column {
    display: flex;
    flex-direction: column;
    align-items: center;
    background-color : #eeeeee;
    }

#editor-container {
    text-align: left;
    }

.input-range-labels-container { visibility: hidden }



.input-range-container {
     transform: rotate(-270deg) translateY(-{1}px) translateX({4}px)
}

"""


editorStyles : Config -> Html msg
editorStyles data =
    style [] [ text (styleText data) ]
