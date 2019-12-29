module Window exposing (Window, select, getOffset, scroll, scrollToIncludeCursor, shift)

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


shift  : Window -> Position -> Position
shift window position =
   { position | line = position.line + window.first }


scroll : Int -> Window -> Window
scroll k window =
   case window.first + k >= 0 of
       True -> {window | first = window.first + k, last = window.last + k}
       False -> window


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
