module Editor exposing (Msg, init, update, view, State, load, scrollToString)

import Buffer exposing (Buffer)
import Editor.History
import Editor.Model exposing (InternalState)
import Editor.Config exposing(Config)
import Editor.Update
import Editor.View
import Html exposing (Html)
import Position exposing (Position)
import RollingList
import Editor.Text


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
        , window = {first = 0, last = config.lines - 1}
        , selection = Nothing
        , selectedText = Nothing
        , dragging = False
        , history = Editor.History.empty
        , searchTerm = ""
        , replacementText = ""
        , searchResults = RollingList.fromList []
        , showHelp = True
        , showGoToLinePanel = False
        , showSearchPanel = False
        , savedBuffer = Buffer.fromString ""
        }


update : Buffer -> Msg -> State -> ( State, Buffer, Cmd Msg )
update buffer msg (State state) =
    Editor.Update.update buffer msg state
        |> (\( newState, newBuffer, cmd ) -> ( State newState, newBuffer, cmd ))

view : Buffer -> State -> Html Msg
view buffer (State state) =
    Editor.View.view (Buffer.lines buffer) state


--  STATE HELPERS --

toInternal : State -> InternalState
toInternal (State s) = s


clearState : State -> State
clearState (State state) =
    State (Editor.Update.clearInternalState state)


load : String ->  State -> (State, Buffer)
load content state =
   let
     config = (toInternal state).config
     lineLengths = String.lines content |> List.map String.length
     maxLineLength = List.maximum lineLengths |> Maybe.withDefault 1000
     buffer = if maxLineLength > config.wrapParams.maximumWidth then
                 Buffer.fromString (Editor.Text.prepareLines config content)
               else
                 Buffer.fromString content
   in
    (clearState state, buffer)

scrollToString : String -> State -> Buffer -> (State, Buffer)
scrollToString  =
     (\str state buffer -> (lift (Editor.Update.scrollToText_ str)) state buffer)



-- FANCY HA HA --

map : (InternalState -> InternalState) -> State -> State
map f (State s) =
    (State (f s))


lift : (InternalState -> Buffer -> (InternalState, Buffer)) -> (State -> Buffer -> (State, Buffer))
lift f =
    \s b -> f (toInternal s) b |> (\(is, b_) -> (State is, b_))

