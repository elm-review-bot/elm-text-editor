module Editor exposing
    ( EditorConfig
    , PEEditorMsg
    , State
    , embedded
    , init
    , load
    , scrollToLine
    , scrollToString
    , slider
    , sliderUpdate
    , sliderView
    , update
    , updateSlider
    , view
    )

import Buffer exposing (Buffer)
import Editor.Config exposing (Config, WrapOption(..))
import Editor.History
import Editor.Model exposing (InternalState)
import Editor.Styles
import Editor.Text
import Editor.Update
import Editor.View
import Html exposing (Attribute, Html, div)
import Html.Attributes as HA exposing (style)
import Position exposing (Position)
import RollingList
import SingleSlider as Slider


type alias PEEditorMsg =
    Editor.Update.Msg


type State
    = State InternalState


init : Config -> State
init config =
    State
        { config = config
        , scrolledLine = 0
        , cursor = Position 0 0
        , window = { first = 0, last = config.lines - 1 }
        , selection = Nothing
        , selectedText = Nothing
        , dragging = False
        , history = Editor.History.empty
        , searchTerm = ""
        , replacementText = ""
        , canReplace = False
        , searchResults = RollingList.fromList []
        , showHelp = True
        , showInfoPanel = config.showInfoPanel
        , showGoToLinePanel = False
        , showSearchPanel = False
        , savedBuffer = Buffer.fromString ""
        , slider = Editor.Model.slider
        }



-- EMBEDDED EDITOR --


type alias EditorConfig a =
    { editorMsg : PEEditorMsg -> a
    , sliderMsg : Slider.Msg -> a
    , width : Int
    , editorStyle : List (Html.Attribute a)
    }


embedded : EditorConfig a -> State -> Buffer -> Html a
embedded editorConfig state buffer =
  div [style "position" "absolute"] [
    div ((elementWidth editorConfig.width) ::  editorConfig.editorStyle)
        [ Editor.Styles.styles
        , state
            |> view [ style "background-color" "#eeeeee" ] buffer
            |> Html.map editorConfig.editorMsg
        -- , div [ HA.style "font-size" "14px", HA.style "position" "absolute", HA.style "top" "440px", HA.style "left" "40px" ]
        , div [ HA.style "position" "absolute"]
            [ sliderView state |> Html.map editorConfig.sliderMsg ]
        ]
    ]

elementWidth : Int -> Attribute msg
elementWidth k =
   style "width" ((String.fromInt k) ++ "px")


-- UPDATE --


update : Buffer -> PEEditorMsg -> State -> ( State, Buffer, Cmd PEEditorMsg )
update buffer msg (State state) =
    Editor.Update.update buffer msg state
        |> (\( newState, newBuffer, cmd ) -> ( State newState, newBuffer, cmd ))

sliderUpdate : Slider.Msg -> State -> Buffer -> (State, Cmd Slider.Msg)
sliderUpdate sliderMsg state buffer =
   let
        ( newSlider, cmd, updateResults ) =
            Slider.update sliderMsg (slider state)

        newEditorState_ =
            updateSlider newSlider state

        numberOfLines =
            Buffer.lines buffer
                |> List.length
                |> toFloat

        line =
            newSlider.value
                / 100.0
                |> (\x -> x * numberOfLines)
                |> round

        newEditorState : State
        newEditorState =
            scrollToLine line newEditorState_ buffer |> Tuple.first

        newCmd =
            if updateResults then
                 cmd

            else
                Cmd.none
    in
    ( newEditorState, newCmd )

-- VIEW --


view : List (Attribute PEEditorMsg) -> Buffer -> State -> Html PEEditorMsg
view attr buffer (State state) =
    Editor.View.view attr (Buffer.lines buffer) state



-- SLIDER --


slider : State -> Slider.Model
slider (State s) =
    s.slider


updateSlider : Slider.Model -> State -> State
updateSlider slider_ (State s) =
    State { s | slider = slider_ }


sliderView : State -> Html Slider.Msg
sliderView state =
    Html.div
         [style "position" "absolute", style "right" "0px", style "top" "0px"]
        --[]
        [ Slider.view (toInternal state).slider ]



--  STATE FUNCTIONS --


clearState : State -> State
clearState (State state) =
    State (Editor.Update.clearInternalState state)


load : WrapOption -> String -> State -> ( State, Buffer )
load wrapOption content state =
    let
        config =
            (toInternal state).config

        lineLengths =
            String.lines content |> List.map String.length

        maxLineLength =
            List.maximum lineLengths |> Maybe.withDefault 1000

        buffer =
            if wrapOption == DoWrap && maxLineLength > config.wrapParams.maximumWidth then
                Buffer.fromString (Editor.Text.prepareLines config content)

            else
                Buffer.fromString content
    in
    ( clearState state, buffer )


scrollToString : String -> State -> Buffer -> ( State, Buffer )
scrollToString =
    \str state buffer -> lift (Editor.Update.scrollToText_ str) state buffer


scrollToLine : Int -> State -> Buffer -> ( State, Buffer )
scrollToLine =
    \k state buffer -> lift (Editor.Update.scrollToLine k) state buffer


toInternal : State -> InternalState
toInternal (State s) =
    s



-- MAP AND LIFT: UTILITY --


map : (InternalState -> InternalState) -> State -> State
map f (State s) =
    State (f s)


lift : (InternalState -> Buffer -> ( InternalState, Buffer )) -> (State -> Buffer -> ( State, Buffer ))
lift f =
    \s b -> f (toInternal s) b |> (\( is, b_ ) -> ( State is, b_ ))
