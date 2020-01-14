module EditorTest exposing (suite)

import Test exposing (..)
import Tests.Insert as Insert
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
            , describe "Insert"
                [ Insert.one ]
            ]
        ]
