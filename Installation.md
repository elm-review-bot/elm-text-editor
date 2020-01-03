# Editor Installation

To install the Editor in app, use the outline below, 
consulting the code in `./demo` 

## Installation

```bash
elm install bemyak/elm-slider
elm install lovasoa/elm-rolling-list
elm install elm-community/string-extra
elm install elm-community/maybe-extra
elm install elm-community/list-extra
elm install folkertdev/elm-paragraph
```

## Imports

```
import Buffer exposing (Buffer)
import Editor exposing (EditorConfig, PEEditorMsg, State)
import Editor.Config exposing (WrapOption(..))   
import SingleSlider as Slider
```

## Msg

```elm
type Msg
    = EditorMsg PEEditorMsg
    | SliderMsg Slider.Msg
    | ...
```

## Model

```elm
type alias Model =
    { editorBuffer : Buffer
    , editorState : State
    , ...
    }
```

## Init

```elm
init : () -> ( Model, Cmd Msg )
init () =
    ( { editorBuffer = Buffer.init Text.jabberwocky
      , editorState = Editor.init config
      }
    , Cmd.none
    )
```


where (for example):

```elm
config =
    { lines = 30
    , showInfoPanel = True
    , wrapParams = { maximumWidth = 65, optimalWidth = 60, stringWidth = String.length }
    , wrapOption = DontWrap
    }
```

Or you could do this:

```elm
defaultConfing = Config.default

config = { defaultConfing | lines = 40}
```

or just this

```elm
config = Config.default
```



## Update

```elm
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

        SliderMsg sliderMsg ->
          let
            (newEditorState, cmd) = Editor.sliderUpdate sliderMsg  model.editorState model.editorBuffer
          in
            ( { model | editorState = newEditorState }, cmd  |> Cmd.map SliderMsg )

        Other cases ...
```

## Subscriptions

```elm

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map SliderMsg <|
            Slider.subscriptions (Editor.slider model.editorState)
        ]
```

## View

```elm
view : Model -> Html Msg
view model =
    div [ HA.style "position" "absolute", HA.style "top" "50px", HA.style "left" "50px" ]
        [ title
        , Editor.embedded editorConfig model.editorState model.editorBuffer
        , footer model
        ]
```