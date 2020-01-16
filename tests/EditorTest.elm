module EditorTest exposing (suite)

import Test exposing (..)
import Tests.CursorLeft as CursorLeft
import Tests.CursorRight as CursorRight
import Tests.Insert as Insert
import Tests.Invariants as Invariants
import Tests.NoOp as NoOp


suite : Test
suite =
    concat
        [ --        describe "Invariants"
          --            [ describe "cursor"
          --                [ describe "line"
          --                    []
          --                , describe "column"
          --                    []
          --                ]
          --            ]
          describe "Msgs"
            [ describe "NoOp"
                [ NoOp.doesNothing
                ]
            , describe "Invariants"
                [ Invariants.cursorLineIsAlwaysPositive
                , Invariants.cursorColumnIsAlwaysPositive
                , Invariants.cursorLineNeverGetsToNonexistingLine
                , Invariants.cursorLineNeverGetsToBeyondEndOfLine
                ]
            , describe "Insert"
                [ Insert.one ]
            , describe
                "CursorLeft"
                [ CursorLeft.notNegativeColumn ]
            , describe "CursorRight"
                [ CursorRight.advance ]
            ]
        ]
