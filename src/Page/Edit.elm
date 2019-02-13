module Page.Edit exposing (Model, Msg(..), init, update, view)

import Browser.Navigation as Navigation
import Element exposing (Element, row, text)
import Element.Input as Input exposing (button, labelAbove)
import Route
import State exposing (Msg(..), State)


type Msg
    = SetText String
    | GoBack
    | StateMsg State.Msg


type alias Model =
    { select : Int
    , text : String
    }


init : State -> Int -> Model
init state select =
    { select = select
    , text = State.getIssue state select
    }


update : Navigation.Key -> Msg -> Model -> ( Model, Cmd Msg, Maybe State.Msg )
update key msg model =
    case msg of
        SetText text ->
            ( { model | text = text }, Cmd.none, Nothing )

        GoBack ->
            ( model, Route.pushUrl key Route.List, Nothing )

        StateMsg stateMsg ->
            ( model, Cmd.none, Just stateMsg )


view : Model -> Element Msg
view model =
    row []
        [ Input.text
            []
            { onChange = SetText
            , text = model.text
            , placeholder = Nothing
            , label = labelAbove [] (text "")
            }
        , button [] { label = text "edit", onPress = Just (StateMsg (EditIssue model.select model.text)) }
        , text " "
        , button [] { label = text "back", onPress = Just GoBack }
        ]
