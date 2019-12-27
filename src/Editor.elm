module Editor exposing (Msg, State, init, update, view, internal)

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

-- TEMPORARY:

internal : State -> InternalState
internal (State internalState) = internalState

init : State
init =
    State
        { scrolledLine = 5
        , cursor = Position 0 0
        , window = {first = 0, last = 5}
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
