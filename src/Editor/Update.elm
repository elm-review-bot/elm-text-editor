module Editor.Update exposing (Msg(..), update)

import Buffer exposing (Buffer)
import Dict exposing (Dict)
import Editor.History
import Editor.Model exposing (InternalState, Snapshot)
import Position exposing (Position)
import Window
import RollingList


type Msg
    =  NoOp
    | MouseDown Position
    | MouseOver Position
    | MouseUp
    | Copy
    | Cut
    | CursorLeft
    | CursorRight
    | CursorUp
    | CursorDown
    | CursorToLineEnd
    | CursorToLineStart
    | CursorToGroupEnd
    | CursorToGroupStart
    | Insert String
    | FirstLine
    | AcceptLineNumber String
    | AcceptSearchText String
    | AcceptReplaceText String
    | LastLine
    | Paste
    | RemoveCharAfter
    | RemoveCharBefore
    | RemoveGroupAfter
    | RemoveGroupBefore
    | Indent
    | Deindent
    | SelectUp
    | SelectDown
    | SelectLeft
    | SelectRight
    | SelectToLineStart
    | SelectToLineEnd
    | SelectToGroupStart
    | SelectToGroupEnd
    | SelectAll
    | SelectGroup
    | SelectLine
    | Undo
    | Redo
    | ScrollUp
    | ScrollDown
    | ScrollToSelection (Position, Position)
    | RollSearchSelectionForward
    | RollSearchSelectionBackward
    | Reset
    | Clear


autoclose : Dict String String
autoclose =
    Dict.fromList
        [ ( "[", "]" )
        , ( "{", "}" )
        , ( "(", ")" )
        , ( "\"", "\"" )
        , ( "'", "'" )
        , ( "`", "`" )
        ]


stateToSnapshot : InternalState -> Buffer -> Snapshot
stateToSnapshot { cursor, selection } buffer =
    { cursor = cursor, selection = selection, buffer = buffer }


recordHistory :
    InternalState
    -> Buffer
    -> ( InternalState, Buffer, Cmd Msg )
    -> ( InternalState, Buffer, Cmd Msg )
recordHistory oldState oldBuffer ( state, buffer, cmd ) =
    ( { state
        | history =
            if oldBuffer /= buffer then
                Editor.History.push
                    (stateToSnapshot oldState oldBuffer)
                    state.history

            else
                state.history
      }
    , buffer
    , cmd
    )


update : Buffer -> Msg -> InternalState -> (  InternalState, Buffer, Cmd Msg )
update buffer msg state =
    case msg of
        NoOp -> (state, buffer, Cmd.none)

        MouseDown position ->
            ( { state
                | cursor = position
                , dragging = True
                , selection = Nothing
              }
            , buffer
            , Cmd.none
            )

        MouseOver position ->
            if state.dragging then
                ( { state
                    | selection =
                        case state.selection of
                            Just selection ->
                                if selection == position then
                                    Nothing

                                else 
                                    Just selection

                            Nothing ->
                                if position == state.cursor then
                                    Nothing

                                else
                                    Just state.cursor
                    , cursor = position
                  }
                , buffer
                , Cmd.none
                )

            else
                ( state, buffer, Cmd.none )

        MouseUp ->
            ( { state | dragging = False }, buffer, Cmd.none )

        CursorLeft ->
            let
                newCursor =
                    let
                        moveFrom =
                            case state.selection of
                                Just selection ->
                                    Position.order selection state.cursor
                                        |> Tuple.first

                                Nothing ->
                                    state.cursor
                    in
                    Position.previousColumn moveFrom
                        |> Buffer.clampPosition Buffer.Backward buffer
            in
            ( { state
                | cursor = newCursor
                , window = Window.scrollToIncludeCursor newCursor state.window
                , selection = Nothing
              }
            , buffer
            , Cmd.none
            )

        CursorRight ->
            let
                newCursor =
                    let
                        moveFrom =
                            case state.selection of
                                Just selection ->
                                    Position.order selection state.cursor
                                        |> Tuple.second

                                Nothing ->
                                    state.cursor
                    in
                    Position.nextColumn moveFrom
                        |> Buffer.clampPosition Buffer.Forward buffer
            in
            ( { state
                | cursor = newCursor
                , window = Window.scrollToIncludeCursor newCursor state.window
                , selection = Nothing
              }
            , buffer
            , Cmd.none
            )

        CursorUp ->
            let
               newCursor =
                  let
                    moveFrom =
                        case state.selection of
                            Just selection ->
                                Position.order selection state.cursor
                                    |> Tuple.first

                            Nothing ->
                                state.cursor
                  in
                    Position.previousLine moveFrom
                        |> Buffer.clampPosition Buffer.Backward buffer
               newWindow = Window.scroll -1 state.window
            in
             ( { state
                 | cursor = newCursor
                 , window = newWindow --  Window.scrollToIncludeCursor newCursor state.window
                 , selection = Nothing
               }
             , buffer
             , Cmd.none
             )

        CursorDown ->
            let
               newCursor =
                    let
                        moveFrom =
                            case state.selection of
                                Just selection ->
                                    Position.order selection state.cursor
                                        |> Tuple.second

                                Nothing ->
                                    state.cursor
                    in
                    Position.nextLine moveFrom
                        |> Buffer.clampPosition Buffer.Backward buffer

            in
             ( { state
                 | cursor = newCursor
                 , window = Window.scrollToIncludeCursor newCursor state.window
                 , selection = Nothing
               }
             , buffer
             , Cmd.none
             )


        CursorToLineEnd ->
            ( { state
                | cursor =
                    let
                        moveFrom =
                            case state.selection of
                                Just selection ->
                                    Position.order selection state.cursor
                                        |> Tuple.second

                                Nothing ->
                                    state.cursor
                    in
                    case Buffer.lineEnd moveFrom.line buffer of
                        Just column ->
                            Position.setColumn column state.cursor

                        Nothing ->
                            Buffer.clampPosition
                                Buffer.Backward
                                buffer
                                state.cursor
                , selection = Nothing
              }
            , buffer
            , Cmd.none
            )

        CursorToLineStart ->
            ( { state
                | cursor =
                    let
                        moveFrom =
                            case state.selection of
                                Just selection ->
                                    Position.order selection state.cursor
                                        |> Tuple.first

                                Nothing ->
                                    state.cursor
                    in
                    Position.setColumn 0 moveFrom
                , selection = Nothing
              }
            , buffer
            , Cmd.none
            )

        CursorToGroupEnd ->
            ( { state
                | cursor = Buffer.groupEnd state.cursor buffer
                , selection = Nothing
              }
            , buffer
            , Cmd.none
            )

        CursorToGroupStart ->
            ( { state
                | cursor = Buffer.groupStart state.cursor buffer
                , selection = Nothing
              }
            , buffer
            , Cmd.none
            )


        Paste ->
            case  state.selectedText of
                Nothing -> ( state, buffer, Cmd.none)
                Just text ->
                      (state, Buffer.insert state.cursor text buffer, Cmd.none)

        Insert string ->
            case ( state.selection, Dict.get string autoclose ) of
                ( Just selection, Just closing ) ->
                    let
                        ( start, end ) =
                            Position.order selection state.cursor

                        wrapped =
                            string
                                ++ Buffer.between start end buffer
                                ++ closing
                    in
                    ( { state
                        | cursor =
                            if state.cursor.line == start.line then
                                Position.nextColumn state.cursor

                            else
                                state.cursor
                        , selection =
                            Just <|
                                if selection.line == start.line then
                                    Position.nextColumn selection

                                else
                                    selection
                      }
                    , Buffer.replace start end wrapped buffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer

                ( Just selection, Nothing ) ->
                    let
                        ( start, end ) =
                            Position.order selection state.cursor
                    in
                    ( { state
                        | cursor =
                            if string == "\n" then
                                { line = start.line + 1
                                , column = 0
                                }

                            else
                                Position.nextColumn start
                        , selection = Nothing
                      }
                    , Buffer.replace start end string buffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer

                ( Nothing, maybeClosing ) ->
                    let
                        nearWordChar =
                            Buffer.nearWordChar state.cursor buffer

                        insertString =
                            if not nearWordChar then
                                Maybe.map ((++) string) maybeClosing
                                    |> Maybe.withDefault string

                            else
                                string
                    in
                      let
                          newCursor =
                            if string == "\n" then
                                { line = state.cursor.line + 1, column = 0 }

                            else
                                Position.nextColumn state.cursor
                      in
                        ( { state
                            | cursor = newCursor
                              , window = if string == "\n" then
                                    Window.scrollToIncludeCursor newCursor state.window
                                  else
                                    state.window
                          }
                        , Buffer.insert state.cursor insertString buffer
                        , Cmd.none
                        )
                            |> recordHistory state buffer

        FirstLine ->
           let
              cursor = {line = 0, column = 0}
              window = Window.scrollToIncludeCursor cursor state.window
           in
             ( {state | cursor = cursor, window = window, selection = Nothing }, buffer, Cmd.none) |> recordHistory state buffer

        AcceptLineNumber nString ->
            case String.toInt nString of
                Nothing -> (state, buffer, Cmd.none)
                Just n_ ->
                    let
                      n = clamp 0 ((List.length (Buffer.lines buffer)) - 1) (n_ - 1)
                      cursor = {line = n, column = 0}
                      window = Window.scrollToIncludeCursor cursor state.window
                   in
                     ( {state | cursor = cursor, window = window, selection = Nothing }, buffer, Cmd.none) |> recordHistory state buffer

        AcceptSearchText str ->
          let
            searchResults = Buffer.search str buffer
          in
          case List.head searchResults of
               Nothing -> ({state | searchResults = RollingList.fromList [], searchTerm = str}, buffer, Cmd.none)
               Just (cursor, end) ->
                  let
                     --(cursor_, end_) = (Window.shiftPosition_ state.window cursor, Window.shiftPosition_ state.window end)
                     -- (cursor_, end_) = ( cursor,  end)
                     window_ = Window.scrollToIncludeCursor cursor state.window
                     (cursor_, end_) = (Window.shiftPosition__ window_ cursor, Window.shiftPosition__ window_ end)
                  in
                     ({state | window = window_, cursor = cursor_, selection = Just end_, searchResults = RollingList.fromList searchResults, searchTerm = str}, buffer, Cmd.none)

        ScrollToSelection (start, end) ->
            (state, buffer,Cmd.none)

        RollSearchSelectionForward ->
            rollSearchSelectionForward  state buffer

        RollSearchSelectionBackward ->
            rollSearchSelectionForward  state buffer

        AcceptReplaceText str -> (state, buffer, Cmd.none)

        LastLine ->
            let
               cursor = {line = (List.length (Buffer.lines buffer)) - 1, column = 0}
               window = Window.scrollToIncludeCursor cursor state.window
            in
              ( {state | cursor = cursor, window = window, selection = Nothing }, buffer, Cmd.none) |> recordHistory state buffer

        RemoveCharAfter ->
            case state.selection of
                Just selection ->
                    let
                        ( start, end ) =
                            Position.order selection state.cursor
                    in
                    ( { state
                        | cursor = start
                        , selection = Nothing
                      }
                    , Buffer.replace start end "" buffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer

                Nothing ->
                    ( state
                    , Buffer.replace
                        state.cursor
                        (Position.nextColumn state.cursor)
                        ""
                        buffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer

        RemoveCharBefore ->
            case state.selection of
                Just selection ->
                    let
                        ( start, end ) =
                            Position.order selection state.cursor
                    in
                    ( { state
                        | cursor = start
                        , selection = Nothing
                      }
                    , Buffer.replace start end "" buffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer

                Nothing ->
                    ( { state
                        | cursor =
                            Position.previousColumn state.cursor
                                -- use old buffer to place cursor at the
                                -- end of the old line
                                |> Buffer.clampPosition Buffer.Backward buffer
                      }
                    , Buffer.removeBefore state.cursor buffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer

        RemoveGroupAfter ->
            case state.selection of
                Just selection ->
                    let
                        ( start, end ) =
                            Position.order selection state.cursor
                    in
                    ( { state
                        | cursor = start
                        , selection = Nothing
                      }
                    , Buffer.replace start end "" buffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer

                Nothing ->
                    let
                        end =
                            Buffer.groupEnd state.cursor buffer
                    in
                    ( state
                    , Buffer.replace state.cursor end "" buffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer


        Copy ->
            case  state.selection of
                Nothing -> ( {state | selectedText = Nothing}, buffer, Cmd.none) |> recordHistory state buffer
                Just sel ->
                    (let
                      (start, end) = Position.order sel state.cursor
                      selectedText = Buffer.between start end buffer
                    in
                      ({state | selectedText = Just selectedText}, buffer, Cmd.none))
                        |> recordHistory state buffer

        Cut ->
            case  state.selection of
                Nothing -> ( {state | selectedText = Nothing}, buffer, Cmd.none) |> recordHistory state buffer
                Just sel ->
                    (let
                      (start, end) = Position.order sel state.cursor
                      selectedText = Buffer.between start end buffer
                    in
                      ({state | selectedText = Just selectedText}, Buffer.replace start end "" buffer, Cmd.none))
                        |> recordHistory state buffer

        RemoveGroupBefore ->
            case state.selection of
                Just selection ->
                    let
                        ( start, end ) =
                            Position.order selection state.cursor
                    in
                    ( { state
                        | cursor = start
                        , selection = Nothing
                      }
                    , Buffer.replace start end "" buffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer

                Nothing ->
                    let
                        start =
                            Buffer.groupStart state.cursor buffer
                    in
                    ( { state | cursor = start }
                    , Buffer.replace start state.cursor "" buffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer


        Indent ->
            case state.selection of
                Just selection ->
                    ( { state
                        | cursor =
                            Position.addColumn
                                Buffer.indentSize
                                state.cursor
                        , selection =
                            Just <|
                                Position.addColumn
                                    Buffer.indentSize
                                    selection
                      }
                    , Buffer.indentBetween state.cursor selection buffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer

                Nothing ->
                    let
                        ( indentedBuffer, indentedColumn ) =
                            Buffer.indentFrom state.cursor buffer
                    in
                    ( { state
                        | cursor =
                            Position.setColumn indentedColumn state.cursor
                      }
                    , indentedBuffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer

        Deindent ->
            case state.selection of
                Just selection ->
                    let
                        ( deindentedBuffer, cursorColumn, selectionColumn ) =
                            Buffer.deindentBetween state.cursor selection buffer
                    in
                    ( { state
                        | cursor =
                            Position.setColumn cursorColumn state.cursor
                        , selection =
                            Just <|
                                Position.setColumn selectionColumn selection
                      }
                    , deindentedBuffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer

                Nothing ->
                    let
                        ( deindentedBuffer, deindentedColumn ) =
                            Buffer.deindentFrom state.cursor buffer
                    in
                    ( { state
                        | cursor =
                            Position.setColumn deindentedColumn state.cursor
                      }
                    , deindentedBuffer
                    , Cmd.none
                    )
                        |> recordHistory state buffer

        SelectUp ->
            let
                cursor =
                    Position.previousLine state.cursor
                        |> Buffer.clampPosition Buffer.Backward buffer
            in
            ( { state
                | cursor = cursor
                , selection =
                    if state.selection == Just cursor then
                        Nothing

                    else if
                        (state.selection == Nothing)
                            && (state.cursor /= cursor)
                    then
                        Just state.cursor

                    else
                        state.selection
              }
            , buffer
            , Cmd.none
            )

        SelectDown ->
            let
                cursor =
                    Position.nextLine state.cursor
                        |> Buffer.clampPosition Buffer.Backward buffer
            in
            ( { state
                | cursor = cursor
                , selection =
                    if state.selection == Just cursor then
                        Nothing

                    else if
                        (state.selection == Nothing)
                            && (state.cursor /= cursor)
                    then
                        Just state.cursor

                    else
                        state.selection
              }
            , buffer
            , Cmd.none
            )

        SelectLeft ->
            let
                cursor =
                    Position.previousColumn state.cursor
                        |> Buffer.clampPosition Buffer.Backward buffer
            in
            ( { state
                | cursor = cursor
                , selection =
                    if state.selection == Just cursor then
                        Nothing

                    else if
                        (state.selection == Nothing)
                            && (state.cursor /= cursor)
                    then
                        Just state.cursor

                    else
                        state.selection
              }
            , buffer
            , Cmd.none
            )

        SelectRight ->
            let
                cursor =
                    Position.nextColumn state.cursor
                        |> Buffer.clampPosition Buffer.Forward buffer
            in
            ( { state
                | cursor = cursor
                , selection =
                    if state.selection == Just cursor then
                        Nothing

                    else if
                        (state.selection == Nothing)
                            && (state.cursor /= cursor)
                    then
                        Just state.cursor

                    else
                        state.selection
              }
            , buffer
            , Cmd.none
            )

        SelectToLineStart ->
            let
                cursor =
                    Position.setColumn 0 state.cursor
            in
            ( { state
                | cursor = cursor
                , selection =
                    if state.selection == Just cursor then
                        Nothing

                    else if
                        (state.selection == Nothing)
                            && (state.cursor /= cursor)
                    then
                        Just state.cursor

                    else
                        state.selection
              }
            , buffer
            , Cmd.none
            )

        SelectToLineEnd ->
            let
                cursor =
                    Position.setColumn
                        (Buffer.lineEnd state.cursor.line buffer
                            |> Maybe.withDefault state.cursor.line
                        )
                        state.cursor
            in
            ( { state
                | cursor = cursor
                , selection =
                    if state.selection == Just cursor then
                        Nothing

                    else if
                        (state.selection == Nothing)
                            && (state.cursor /= cursor)
                    then
                        Just state.cursor

                    else
                        state.selection
              }
            , buffer
            , Cmd.none
            )

        SelectToGroupStart ->
            let
                cursor =
                    Buffer.groupStart state.cursor buffer
            in
            ( { state
                | cursor = cursor
                , selection =
                    if state.selection == Just cursor then
                        Nothing

                    else if
                        (state.selection == Nothing)
                            && (state.cursor /= cursor)
                    then
                        Just state.cursor

                    else
                        state.selection
              }
            , buffer
            , Cmd.none
            )

        SelectToGroupEnd ->
            let
                cursor =
                    Buffer.groupEnd state.cursor buffer
            in
            ( { state
                | cursor = cursor
                , selection =
                    if state.selection == Just cursor then
                        Nothing

                    else if
                        (state.selection == Nothing)
                            && (state.cursor /= cursor)
                    then
                        Just state.cursor

                    else
                        state.selection
              }
            , buffer
            , Cmd.none
            )

        SelectAll ->
            ( { state
                | cursor = Buffer.lastPosition buffer
                , selection = Just (Position 0 0)
              }
            , buffer
            , Cmd.none
            )

        SelectGroup ->
            let
                range =
                    Buffer.groupRange state.cursor buffer
            in
            case range of
                Just ( start, end ) ->
                    ( { state | cursor = end, selection = Just start }
                    , buffer
                    , Cmd.none
                    )

                Nothing ->
                    ( state, buffer, Cmd.none )

        SelectLine ->
            ( { state
                | cursor =
                    Buffer.lineEnd state.cursor.line buffer
                        |> Maybe.map
                            (\column ->
                                Position.setColumn column state.cursor
                            )
                        |> Maybe.withDefault state.cursor
                , selection = Just <| Position.setColumn 0 state.cursor
              }
            , buffer
            , Cmd.none
            )

        Undo ->
            case Editor.History.undo (stateToSnapshot state buffer) state.history of
                Just ( history, snapshot ) ->
                    ( { state
                        | cursor = snapshot.cursor
                        , selection = snapshot.selection
                        , history = history
                      }
                    , snapshot.buffer
                    , Cmd.none
                    )

                Nothing ->
                    ( state, buffer, Cmd.none )

        Redo ->
            case Editor.History.redo (stateToSnapshot state buffer) state.history of
                Just ( history, snapshot ) ->
                    ( { state
                        | cursor = snapshot.cursor
                        , selection = snapshot.selection
                        , history = history
                      }
                    , snapshot.buffer
                    , Cmd.none
                    )

                Nothing ->
                    ( state, buffer, Cmd.none )
        ScrollUp ->
             let
                  (newCursor, newWindow) =
                                if state.window.first > 0 then
                                  (Position.shift -1 state.cursor, Window.shift -1 state.window)
                                else
                                  (state.cursor, state.window)

             in
                ({state  | cursor = newCursor,  window = newWindow, selection = Nothing}, buffer, Cmd.none)

        ScrollDown ->
          let
             (newCursor, newWindow) =
               if state.window.last < List.length (Buffer.lines buffer) - 1 then
                 (Position.shift 1 state.cursor, Window.shift 1 state.window)
               else
                 (state.cursor, state.window)
          in
            ({state  | cursor = newCursor,  window = newWindow, selection = Nothing}, buffer, Cmd.none)


        Reset ->
             ( initialState,  Buffer.init Editor.Model.initialText, Cmd.none)

        Clear ->
              ( initialState,  Buffer.init "", Cmd.none)


scrollToSearchSelection  : InternalState ->  Buffer ->  (InternalState, Buffer, Cmd Msg)
scrollToSearchSelection  state buffer =
    case RollingList.current state.searchResults of
        Nothing -> (state, buffer, Cmd.none)
        Just (cursor, end) ->
          let
             -- (cursor_, end_) = (Window.shiftPosition_ state.window cursor, Window.shiftPosition_ state.window end)
             (cursor_, end_) = ( cursor,  end)
             window = Debug.log "New Window" <| Window.scrollToIncludeCursor cursor_ state.window
          in
             ({state | cursor = cursor_
                     , selection = Just end_
                     , window = window
               }, buffer, Cmd.none)

rollSearchSelectionForward  : InternalState ->  Buffer ->  (InternalState, Buffer, Cmd Msg)
rollSearchSelectionForward  state buffer =
    let
        searchResults_ = RollingList.roll state.searchResults
    in
    case RollingList.current searchResults_ of
            Nothing -> (state, buffer, Cmd.none)
            Just (cursor, end) ->
              let
                 window = Window.scrollToIncludeCursor cursor state.window
                --   cursor_, end_) = (Window.shiftPosition_  window cursor, Window.shiftPosition_ window end)

              in
                 ({state | cursor = cursor
                         , window = window
                         , selection = Just end
                         , searchResults = searchResults_
                  }, buffer, Cmd.none)

rollSearchSelectionBackward  : InternalState ->  Buffer ->  (InternalState, Buffer, Cmd Msg)
rollSearchSelectionBackward  state buffer =
    let
            searchResults_ = RollingList.rollBack state.searchResults
    in
        case RollingList.current searchResults_ of
                Nothing -> (state, buffer, Cmd.none)
                Just (cursor, end) ->
                  let
                     (cursor_, end_) = (Window.shiftPosition_ state.window cursor, Window.shiftPosition_ state.window end)
                  in
                     ({state | cursor = cursor_
                             , window = Window.scrollToIncludeCursor cursor_ state.window
                             , selection = Just end_
                             , searchResults = searchResults_
                      }, buffer, Cmd.none)

initialState = { scrolledLine = 0
        , cursor = Position 0 0
        , window = {first = 0, last = Editor.Model.lastLine}
        , selection = Nothing
        , selectedText = Nothing
        , dragging = False
        , history = Editor.History.empty
        , searchTerm = ""
        , searchResults = RollingList.fromList []
        }
