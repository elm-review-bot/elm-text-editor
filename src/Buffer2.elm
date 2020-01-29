module Buffer2 exposing
    ( Buffer(..)
    , indexFromPosition
    , init
    , insert
    , insertInArray
    , nearWordChar
    )

import Array exposing (Array)
import List.Extra
import Maybe.Extra
import Position exposing (Position)
import String.Extra
import Util.Array


type Buffer
    = Buffer { content : String, lines : Array String }


{-| Create a new buffer from a string

    init "one\ntwo"
    --> Buffer { content = "one\ntwo", lines = Array.fromList ["one","two"] }

-}
init : String -> Buffer
init content =
    Buffer { content = content, lines = Array.fromList (String.lines content) }


{-| Returns true if the Position is at or after a word character. See isWordChar.

    import Position exposing(..)

    nearWordChar (Position 0 0) (init "one\ntwo")
    --> True

    nearWordChar (Position 0 10) (init "one\ntwo")
    --> False

-}
nearWordChar : Position -> Buffer -> Bool
nearWordChar position (Buffer data) =
    indexFromPosition data.content position
        |> Maybe.andThen
            (\index ->
                let
                    previousChar =
                        stringCharAt (index - 1) data.content

                    currentChar =
                        stringCharAt index data.content
                in
                Maybe.map isWordChar previousChar
                    |> Maybe.Extra.orElseLazy
                        (\() -> Maybe.map isWordChar currentChar)
            )
        |> Maybe.withDefault False


{-| Insert a string into the buffer.

    bb: Buffer
    bb = init "aaa\nbbb"
    --> Buffer { content = "aaa\nbbb", lines = Array.fromList ["aaa","bbb"] }

    insert (Position 0 1) "X" bb
    --> Buffer { content = "aXaa\nbbb", lines = Array.fromList ["aXaa","bbb"] }

-}
insert : Position -> String -> Buffer -> Buffer
insert position str (Buffer data) =
    let
        content =
            indexFromPosition data.content position
                |> Maybe.map (\index -> String.Extra.insertAt str index data.content)
                |> Maybe.withDefault data.content

        lines =
            insertInArray position str data.lines
    in
    Buffer { content = content, lines = lines }


{-|

    insertInArray (Position 0 1) "X" arrL
    --> Array.fromList ["aXaa","bbb"]

    insertInArray (Position 1 1) "X" arrL
    --> Array.fromList ["aaa","bXbb"]

-}
insertInArray : Position -> String -> Array String -> Array String
insertInArray position str array =
    case Array.get position.line array of
        Nothing ->
            array

        Just line ->
            let
                newLine =
                    String.Extra.insertAt str position.column line
            in
            Array.set position.line newLine array



-- HELPER FUNCTIONS THAT DO NOT REFERENCE BUFFER --


stringCharAt : Int -> String -> Maybe Char
stringCharAt index string =
    String.slice index (index + 1) string
        |> String.uncons
        |> Maybe.map Tuple.first


charsAround : Int -> String -> ( Maybe Char, Maybe Char, Maybe Char )
charsAround index string =
    ( stringCharAt (index - 1) string
    , stringCharAt index string
    , stringCharAt (index + 1) string
    )


tuple3MapAll : (a -> b) -> ( a, a, a ) -> ( b, b, b )
tuple3MapAll fn ( a1, a2, a3 ) =
    ( fn a1, fn a2, fn a3 )


tuple3CharsPred :
    (Char -> Bool)
    -> ( Maybe Char, Maybe Char, Maybe Char )
    -> ( Bool, Bool, Bool )
tuple3CharsPred pred =
    tuple3MapAll (Maybe.map pred >> Maybe.withDefault False)


{-| Internal function for getting the index of the position in a string

    indexFromPosition "reddish\ngreen" (Position 0 2)
    --> Just 2

    indexFromPosition "reddish\ngreen" (Position 1 2)
    --> Just 10

-}
indexFromPosition : String -> Position -> Maybe Int
indexFromPosition buffer position =
    -- Doesn't validate columns, only lines
    if position.line == 0 then
        Just position.column

    else
        String.indexes "\n" buffer
            |> List.Extra.getAt (position.line - 1)
            |> Maybe.map (\line -> line + position.column + 1)



-- GROUPING


isWhitespace : Char -> Bool
isWhitespace =
    String.fromChar >> String.trim >> (==) ""


isNonWordChar : Char -> Bool
isNonWordChar =
    String.fromChar >> (\a -> String.contains a "/\\()\"':,.;<>~!@#$%^&*|+=[]{}`?-…")


isWordChar : Char -> Bool
isWordChar char =
    not (isNonWordChar char) && not (isWhitespace char)


type Group
    = None
    | Word
    | NonWord


type Direction
    = Forward
    | Backward
