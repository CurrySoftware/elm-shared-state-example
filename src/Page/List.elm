module Page.List exposing (Msg(..), update, view)

import Browser.Navigation as Navigation
import Element exposing (Element, centerX, column, paragraph, px, rgba, row, spacing, text, width)
import Element.Background exposing (color)
import Element.Input exposing (button)
import Route
import State exposing (Msg(..), State)


type Msg
    = View Int
    | Edit Int
    | AddIssue Int
    | StateMsg State.Msg


update : Navigation.Key -> Msg -> ( Cmd Msg, Maybe State.Msg )
update key msg =
    case msg of
        View index ->
            ( Route.pushUrl key (Route.Item index), Nothing )

        Edit index ->
            ( Route.pushUrl key (Route.Edit index), Nothing )

        AddIssue index ->
            ( Route.pushUrl key (Route.Edit index), Just State.AddIssue )

        StateMsg stateMsg ->
            ( Cmd.none, Just stateMsg )


view : State -> Element Msg
view state =
    column []
        (List.append
            (state.list |> List.indexedMap Tuple.pair |> List.map viewRow)
            [ button [ centerX, color (rgba 0 1 0 0.3) ] { label = text "Add Issue", onPress = Just <| AddIssue <| List.length state.list } ]
        )


viewRow : ( Int, String ) -> Element Msg
viewRow ( index, content ) =
    row
        [ spacing 10 ]
        [ paragraph [ width <| px 350 ] [ text content ]
        , button [ color (rgba 1 1 0 0.3) ] { label = text "view", onPress = Just <| View index }
        , button [ color (rgba 0 1 1 0.3) ] { label = text "edit", onPress = Just <| Edit index }
        , button [ color (rgba 1 0 0 0.3) ] { label = text "remove", onPress = Just <| StateMsg <| RemoveIssue index }
        ]
