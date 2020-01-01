module Editor.Widget exposing (..)

import Html exposing (Attribute, Html, div, span, text, button, input)
import Html.Attributes as Attribute exposing (class, classList)
import Html.Events as Event exposing(onClick, onInput)

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
     , Attribute.style "float" "left"
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