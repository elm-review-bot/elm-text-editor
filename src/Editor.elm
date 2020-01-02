module Editor exposing (Msg, lift, init, update, view, view2, State, load, scrollToString, EditorData)

import Buffer exposing (Buffer)
import Editor.History
import Editor.Model exposing (InternalState, Config)
import Editor.Update
import Editor.View
import Html exposing (Html)
import Position exposing (Position)
import RollingList


type alias Msg =
    Editor.Update.Msg


type State
    = State InternalState

toInternal : State -> InternalState
toInternal (State s) = s

fromInternal : InternalState -> State
fromInternal s = State s

clearState : State -> State
clearState (State state) =
    State (Editor.Update.clearInternalState state)

type alias EditorData = {
     state : State
   , buffer : Buffer
   }

load : String ->  State -> (State, Buffer)
load str state =
  (clearState state, Buffer.fromString str)

scrollToString : String -> State -> Buffer -> (State, Buffer)
scrollToString  =
     (\str state buffer -> (lift (Editor.Update.scrollToText_ str)) state buffer)



map : (InternalState -> InternalState) -> State -> State
map f (State s) =
    (State (f s))


lift : (InternalState -> Buffer -> (InternalState, Buffer)) -> (State -> Buffer -> (State, Buffer))
lift f =
    \s b -> f (toInternal s) b |> (\(is, b_) -> (State is, b_))



init : Config -> State
init config =
    State
        { config = config
        , scrolledLine = 0
        , cursor = Position 0 0
        , window = {first = 0, last = config.lines - 1}
        , selection = Nothing
        , selectedText = Nothing
        , dragging = False
        , history = Editor.History.empty
        , searchTerm = ""
        , replacementText = ""
        , searchResults = RollingList.fromList []
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
