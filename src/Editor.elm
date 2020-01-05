module Editor exposing
    ( Editor
    , EditorConfig
    , PEEditorMsg
    , State
    , embedded
    , getCursor
    , getSelectedText
    , getSmallConfig
    , init
    , insert
    , load
    , scrollToLine
    , scrollToString
    , setSelectedText
    , slider
    , sliderUpdate
    , sliderView
    , update
    , updateSlider
    , view
    )

import Buffer exposing (Buffer)
import Editor.Config exposing (Config, WrapOption(..), WrapParams)
import Editor.History
import Editor.Model exposing (InternalState)
import Editor.Styles
import Editor.Text
import Editor.Update
import Editor.View
import Html exposing (Attribute, Html, div)
import Html.Attributes as HA exposing (style)
import Position exposing (Position)
import RollingList
import SingleSlider as Slider


type alias PEEditorMsg =
    Editor.Update.Msg


type alias Editor =
    { buffer : Buffer
    , state : State
    }


type State
    = State InternalState


getCursor : Editor -> Position
getCursor editor =
    editor.state
        |> toInternal
        |> .cursor


getSelectedText : State -> Maybe String
getSelectedText (State s) =
    s.selectedText


setSelectedText : String -> State -> State
setSelectedText str (State s) =
    State { s | selectedText = Just str }


getSmallConfig : State -> SmallEditorConfig
getSmallConfig (State s) =
    s.config


init : EditorConfig a -> String -> Editor
init editorConfig text =
    { buffer = Buffer.init text
    , state =
        State
            { config = smallConfig editorConfig
            , scrolledLine = 0
            , cursor = Position 0 0
            , window = { first = 0, last = editorConfig.lines - 1 }
            , selection = Nothing
            , selectedText = Nothing
            , dragging = False
            , history = Editor.History.empty
            , searchTerm = ""
            , replacementText = ""
            , canReplace = False
            , searchResults = RollingList.fromList []
            , showHelp = True
            , showInfoPanel = editorConfig.showInfoPanel
            , showGoToLinePanel = False
            , showSearchPanel = False
            , savedBuffer = Buffer.fromString ""
            , slider = Editor.Model.slider
            }
    }



-- EMBEDDED EDITOR --


type alias EditorConfig a =
    { editorMsg : PEEditorMsg -> a
    , sliderMsg : Slider.Msg -> a
    , editorStyle : List (Html.Attribute a)
    , width : Int
    , lines : Int
    , lineHeight : Float
    , showInfoPanel : Bool
    , wrapParams : { maximumWidth : Int, optimalWidth : Int, stringWidth : String -> Int }
    , wrapOption : WrapOption
    }


type alias SmallEditorConfig =
    { lines : Int
    , showInfoPanel : Bool
    , wrapParams : { maximumWidth : Int, optimalWidth : Int, stringWidth : String -> Int }
    , wrapOption : WrapOption
    }



-- NEW STUFF --


insert : Position -> String -> Editor -> Editor
insert position string editor =
    { editor | buffer = Buffer.insert position string editor.buffer }



-- /NEW STUFF --


smallConfig : EditorConfig a -> SmallEditorConfig
smallConfig c =
    { lines = c.lines
    , showInfoPanel = c.showInfoPanel
    , wrapParams = c.wrapParams
    , wrapOption = c.wrapOption
    }


embedded : EditorConfig a -> Editor -> Html a
embedded editorConfig editor =
    div [ style "position" "absolute" ]
        [ div editorConfig.editorStyle
            [ Editor.Styles.styles { width = editorConfig.width, lineHeight = editorConfig.lineHeight, numberOfLines = editorConfig.lines }
            , editor.state
                |> view [ style "background-color" "#eeeeee" ] editor.buffer
                |> Html.map editorConfig.editorMsg
            , div [ HA.style "position" "absolute" ]
                [ sliderView editor |> Html.map editorConfig.sliderMsg ]
            ]
        ]


elementWidth : Int -> Attribute msg
elementWidth k =
    style "width" (String.fromInt k ++ "px")



-- UPDATE --


update : PEEditorMsg -> Editor -> ( Editor, Cmd PEEditorMsg )
update msg editor =
    let
        ( is, b, cmd ) =
            Editor.Update.update editor.buffer msg (toInternal editor.state)
    in
    ( { state = State is, buffer = b }, cmd )


sliderUpdate : Slider.Msg -> Editor -> ( Editor, Cmd Slider.Msg )
sliderUpdate sliderMsg editor =
    let
        ( newSlider, cmd, updateResults ) =
            Slider.update sliderMsg (slider editor)

        newEditorState_ =
            updateSlider newSlider editor

        numberOfLines =
            Buffer.lines editor.buffer
                |> List.length
                |> toFloat

        line =
            newSlider.value
                / 100.0
                |> (\x -> x * numberOfLines)
                |> round

        newCmd =
            if updateResults then
                cmd

            else
                Cmd.none
    in
    ( scrollToLine line editor, newCmd )



-- VIEW --


view : List (Attribute PEEditorMsg) -> Buffer -> State -> Html PEEditorMsg
view attr buffer (State state) =
    Editor.View.view attr (Buffer.lines buffer) state



-- SLIDER --


slider : Editor -> Slider.Model
slider editor =
    editor
        |> (.state >> toInternal >> .slider)


updateSlider : Slider.Model -> Editor -> Editor
updateSlider slider_ editor =
    let
        is =
            toInternal editor.state
    in
    { editor | state = State { is | slider = slider_ } }


sliderView : Editor -> Html Slider.Msg
sliderView editor =
    Html.div
        [ style "position" "absolute", style "right" "0px", style "top" "0px" ]
        [ Slider.view (toInternal editor.state).slider ]



--  STATE FUNCTIONS --


clearState : Editor -> Editor
clearState editor =
    { editor | state = State (Editor.Update.clearInternalState (toInternal editor.state)) }


load : WrapOption -> String -> Editor -> Editor
load wrapOption content editor =
    let
        config =
            (toInternal editor.state).config

        lineLengths =
            String.lines content |> List.map String.length

        maxLineLength =
            List.maximum lineLengths |> Maybe.withDefault 1000

        buffer =
            if wrapOption == DoWrap && maxLineLength > config.wrapParams.maximumWidth then
                Buffer.fromString (Editor.Text.prepareLines config content)

            else
                Buffer.fromString content

        newEditor =
            clearState editor
    in
    { newEditor | buffer = buffer }


scrollToString : String -> Editor -> Editor
scrollToString str editor =
    let
        ( is, b ) =
            Editor.Update.scrollToText_ str (toInternal editor.state) editor.buffer
    in
    { state = State is, buffer = b }


scrollToLine : Int -> Editor -> Editor
scrollToLine k editor =
    let
        ( is, b ) =
            Editor.Update.scrollToLine k (toInternal editor.state) editor.buffer
    in
    { state = State is, buffer = b }


toInternal : State -> InternalState
toInternal (State s) =
    s



-- MAP AND LIFT: UTILITY --


map : (InternalState -> InternalState) -> State -> State
map f (State s) =
    State (f s)


lift : (InternalState -> Buffer -> ( InternalState, Buffer )) -> (State -> Buffer -> ( State, Buffer ))
lift f =
    \s b -> f (toInternal s) b |> (\( is, b_ ) -> ( State is, b_ ))
