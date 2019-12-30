module Window exposing (Window, select, getOffset
  , scroll, scrollToIncludeCursor, scrollToIncludeCursor2
  , shiftPosition, shiftPosition_
  , shift)

import Position exposing(Position)

type alias Window = {first : Int, last : Int}


select : Window -> List String -> List String
select window strings =
   strings
      |> indexedFilterMap (\i x -> i >= window.first  && i <= window.last )

{-|
    indexedFilterMap (\i x -> i >= 1 && i <= 3) [0,1,2,3,4,5,6]
    --> [1,2,3] : List number
-}
indexedFilterMap : (Int -> a -> Bool) -> List a -> List a
indexedFilterMap filter list =
    list
      |> List.indexedMap (\k item -> (k,item))
      |> List.filter (\(i, item) -> filter i item)
      |> List.map Tuple.second

{-|
    Offset is <= 0
-}
getOffset : Window -> Int -> Int
getOffset window lineNumber_ =
    min (window.last - window.first - lineNumber_) 0


shiftPosition  : Window -> Position -> Position
shiftPosition window position =
    { position | line = position.line + window.first}


shiftPosition_ : Window -> Int -> Int -> Position
shiftPosition_ window  line column =
    shiftPosition window (Position line column)

shift : Int -> Window -> Window
shift k w =
    {w | first = w.first + k, last = w.last + k}


scroll : Int -> Window -> Window
scroll k window =
   case window.first + k >= 0 of
       False -> window
       True -> {window | first = window.first + k, last = window.last + k}


scrollToIncludeCursor : Position -> Window -> Window
scrollToIncludeCursor cursor window =
  let
    line = cursor.line
    _ = Debug.log "stic" (line, window)
    offset = Debug.log "OFFST" <| if line >= window.last then
                line - window.last
             else if line <= window.first then
                line - window.first
             else
                 0
  in
    {window | first = window.first + offset, last = window.last + offset}

scrollToIncludeCursor2 : Position -> Window -> Window
scrollToIncludeCursor2 cursor window =
  let
    line = cursor.line
    _ = Debug.log "stic" (line, window)
    offset = Debug.log "OFFST" <| if line >= window.last then
                line - 1
             else if line <= window.first then
                line + 1
             else
                 0
  in
    {window | first = window.first + offset, last = window.last + offset}
