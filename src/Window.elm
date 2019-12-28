module Window exposing (Window, select,size, getOffset, scroll, scrollToIncludeLine)

import Position exposing(Position)

type alias Window = {first : Int, last : Int}


select : Position -> Window -> List String -> List String
select cursor window strings =
  let
      offset_ = max 0 (cursor.line - size window + 1)
  in
      strings
        |> indexedFilterMap (\i x -> i >= window.first + offset_  && i <= window.last + offset_ )

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

size : Window -> Int
size window =
    window.last - window.first + 1

{-|
    Offset is <= 0
-}
getOffset : Window -> Int -> Int
getOffset window lineNumber_ =
    min (window.last - window.first - lineNumber_) 0


scroll : Int -> Window -> Window
scroll k window =
   case window.first + k >= 0 of
       True -> {window | first = window.first + k, last = window.last + k}
       False -> window


scrollToIncludeLine : Int -> Window -> Window
scrollToIncludeLine line window =
  let
    offset = if line > window.last then
               line - window.last
             else if line < window.first then
               line - window.first
             else
               0
  in
    {window | first = window.first + offset, last = window.last + offset}


