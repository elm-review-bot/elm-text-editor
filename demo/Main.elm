module Main exposing (main)

import Browser
import Buffer exposing (Buffer)
import Editor exposing(State)
import Editor.Styles
import Html exposing (details, div, summary, text, textarea)
import Html.Events as Event exposing (onInput)
import Html.Attributes as HA
import Json.Decode as Decode exposing (Decoder)


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
    { content : Buffer
    , editor : State
    , lastKeyPress : Maybe String
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { content = Buffer.init """0 aaa
1 bbb
2 ccc
3 ddd
4 eee
5 fff
6 ggg
7 hhh
8 iii
9 jjj
"""
      , editor = Editor.init
      , lastKeyPress = Nothing
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = EditorMsg Editor.Msg
    | KeyPress String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditorMsg msg_ ->
            let
                ( editor, content, cmd ) =
                    Editor.update model.content msg_ model.editor
            in
            ( { model
                | editor = editor
                , content = content
              }
            , Cmd.map EditorMsg cmd
            )

        KeyPress key ->
            ( { model | lastKeyPress = Just key }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


keyDecoder : (String -> msg) -> Decoder msg
keyDecoder keyToMsg =
    Decode.field "key" Decode.string
        |> Decode.map keyToMsg


view : Model -> Html.Html Msg
view model =
    div
        [ Event.on "keydown" (keyDecoder KeyPress)
        ]
        [ Editor.Styles.styles
        , model.editor
            |> Editor.view model.content
            |> Html.map EditorMsg
        , details [HA.style "margin-top" "20px"]
            [ summary []
                [ text "Debug" ]

            , div [HA.style "margin-top" "20px"] [text <| "window: " ++ Debug.toString (Editor.internal model.editor).window]
            , div [] [text <| "cursor: " ++ Debug.toString (Editor.internal model.editor).cursor]

            , case model.lastKeyPress of
                Just key ->
                    div [HA.style "margin-top" "20px"] [ text <| "Last key press: " ++ key ]

                Nothing ->
                    text ""

            , div [HA.style "margin-top" "20px"] [ text <| Debug.toString model.editor ]
            ]
        ]
