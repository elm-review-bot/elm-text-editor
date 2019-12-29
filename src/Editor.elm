module Editor exposing (Msg, init, update, view, view2, State, internal)

import Buffer exposing (Buffer)
import Editor.History
import Editor.Model exposing (InternalState)
import Editor.Update
import Editor.View
import Html exposing (Html)
import Position exposing (Position)


type alias Msg =
    Editor.Update.Msg


type State
    = State InternalState

map : (InternalState -> InternalState) -> State -> State
map f (State s) =
    (State (f s))

{-| TEMPORARY!!! -}
internal : State -> InternalState
internal (State s) = s


init : State
init =
    State
        { scrolledLine = 0
        , cursor = Position 0 0
        , window = {first = 0, last = 9}
        , selection = Nothing
        , dragging = False
        , history = Editor.History.empty
        }


update : Buffer -> Msg -> State -> ( State, Buffer, Cmd Msg )
update buffer msg (State state) =
    Editor.Update.update buffer msg state
        |> (\( newState, newBuffer, cmd ) -> ( State newState, newBuffer, cmd ))


view : Buffer -> State -> Html Msg
view buffer (State state) =
    Editor.View.view (Buffer.lines buffer) state


view2 : Buffer -> State -> Html Msg
view2 buffer (State state) =
    Editor.View.view2 (Buffer.lines buffer) state
