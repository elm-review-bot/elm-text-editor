module Editor exposing (Msg, State, init, load, scrollToLine, scrollToString, slider, sliderView, update, updateSlider, view)

import Buffer exposing (Buffer)
import Editor.Config exposing (Config, WrapOption(..))
import Editor.History
import Editor.Model exposing (InternalState)
import Editor.Text
import Editor.Update
import Editor.View
import Html exposing (Html, Attribute)
import Position exposing (Position)
import RollingList
import SingleSlider as Slider


type alias Msg =
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
        , searchResults = RollingList.fromList []
        , showHelp = True
        , showInfoPanel = config.showInfoPanel
        , showGoToLinePanel = False
        , showSearchPanel = False
        , savedBuffer = Buffer.fromString ""
        , slider = Editor.Model.slider
        }


slider : State -> Slider.Model
slider (State s) =
    s.slider


updateSlider : Slider.Model -> State -> State
updateSlider slider_ (State s) =
    State { s | slider = slider_ }


update : Buffer -> Msg -> State -> ( State, Buffer, Cmd Msg )
update buffer msg (State state) =
    Editor.Update.update buffer msg state
        |> (\( newState, newBuffer, cmd ) -> ( State newState, newBuffer, cmd ))


view : List (Attribute Msg) -> Buffer -> State -> Html Msg
view attr buffer (State state) =
    Editor.View.view attr (Buffer.lines buffer) state


sliderView : State -> Html Slider.Msg
sliderView state =
    Html.div
        []
        [ Slider.view (toInternal state).slider ]


--  STATE HELPERS --


toInternal : State -> InternalState
toInternal (State s) =
    s


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
            if wrapOption == DoWrap && maxLineLength > config.wrapParams.maximumWidth  then
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



-- FANCY HA HA --


map : (InternalState -> InternalState) -> State -> State
map f (State s) =
    State (f s)


lift : (InternalState -> Buffer -> ( InternalState, Buffer )) -> (State -> Buffer -> ( State, Buffer ))
lift f =
    \s b -> f (toInternal s) b |> (\( is, b_ ) -> ( State is, b_ ))
