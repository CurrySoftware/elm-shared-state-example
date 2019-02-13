module Page.Item exposing (Model, Msg(..), init, update, view)

import Browser.Navigation as Navigation
import Element exposing (Element, row, text)
import Element.Input exposing (button)
import List.Extra as List
import Route
import State exposing (State)


type Msg
    = GoBack


type alias Model =
    { select : Int }


init : Int -> Model
init select =
    { select = select }


update : Navigation.Key -> Msg -> Model -> ( Model, Cmd Msg, Maybe State.Msg )
update key msg model =
    case msg of
        GoBack ->
            ( model, Route.pushUrl key Route.List, Nothing )


view : State -> Model -> Element Msg
view state model =
    row []
        [ text <| State.getIssue state model.select
        , text " "
        , button [] { label = text "back", onPress = Just GoBack }
        ]
