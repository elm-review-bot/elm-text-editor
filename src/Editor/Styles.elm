module Editor.Styles exposing (styles)

import Html exposing (Html, text)
import String.Interpolate exposing (interpolate)


style : List (Html.Attribute msg) -> List (Html msg) -> Html msg
style =
    Html.node "style"


styleText : { width : Int } -> String
styleText data =
    interpolate styleTemplate [ String.fromInt data.width, String.fromInt (data.width + 50) ]


styleTemplate : String
styleTemplate =
    """
.elm-editor-container {
  font-family: monospace;
  border: 1px solid lightgray;
  width: {0}px;
  user-select: none;
  -webkit-user-select: none;
  display: flex;
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
    opacity: 1;
  }
}

.input-range-container {
     transform: rotate(-270deg) translateY(-{1}px) translateX(315px)

"""


styles : { width : Int } -> Html msg
styles data =
    style [] [ text (styleText data) ]
