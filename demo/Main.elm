module Main exposing (main)

import Browser
import Buffer exposing (Buffer)
import Editor exposing(State)
import Editor.Model
import Editor.Styles
import Html exposing (details, div, summary, text, textarea)
import Html.Events as Event exposing (onInput)
import Html.Attributes as HA
import Json.Decode as Decode exposing (Decoder)
import Html.Attributes as Attributes


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
    ( { content = Buffer.init Editor.Model.initialText
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
        [ Event.on "keydown" (keyDecoder KeyPress), HA.style  "backround-color" "#dddddd"
        ]
        [ div [HA.style "font-size" "24px", HA.style "font-style" "bold" , HA.style "margin-bottom" "10px" ]
            [text "Pure Elm Text Editor"]
        , Editor.Styles.styles
        , model.editor
            |> Editor.view model.content
            |> Html.map EditorMsg
        , div [HA.style "margin-top" "50px"] [
           Html.a [Attributes.href "https://github.com/jxxcarlson/elm-text-editor"] [text "Source code"]
           , text " — needs lots of testing and issue posting/fixing"
           , div [HA.style "margin-top" "20px"] [text "This is a fork of work of SydneyNemzer"]
           , div [HA.style "margin-top" "20px"] [text "ctrl-c to copy selection; ctrl-x to cut; ctrl-v to paste copied text"]
           , div [HA.style "margin-top" "20px"] [text "Coming soon: search and replace.  Open console and enter a seardch to see what's up."]

          ]

        , details [HA.style "margin-top" "20px"]
            [ summary []
                [ text "Debug" ]

            , div [HA.style "margin-top" "20px"] [text <| "window: " ++ Debug.toString (Editor.internal model.editor).window]
            , div [HA.style "margin-top" "5px"] [text <| "cursor:  " ++ Debug.toString (Editor.internal model.editor).cursor]

            , case model.lastKeyPress of
                Just key ->
                    div [HA.style "margin-top" "20px"] [ text <| "Last key press: " ++ key ]

                Nothing ->
                    text ""

            , model.editor |> Editor.view2 model.content |>  Html.map EditorMsg
            --, div [HA.style "margin-top" "20px"] [ text <| Debug.toString model.editor ]
            ]
        ]

