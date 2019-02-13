module Route exposing (Route(..), fromUrl, pushUrl, replaceUrl)

import Browser.Navigation as Navigation
import List.Extra
import Url exposing (Url)
import Url.Parser as Url exposing ((</>), Parser, int, oneOf, s)


type Route
    = Edit Int
    | Item Int
    | List


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Edit (s "edit" </> int)
        , Url.map Item (s "item" </> int)
        , Url.map List (s "list")
        ]


toString : Route -> String
toString rt =
    let
        pieces =
            case rt of
                Edit index ->
                    [ "edit", String.fromInt index ]

                Item index ->
                    [ "item", String.fromInt index ]

                List ->
                    [ "list" ]
    in
    "#/" ++ String.join "/" pieces


fromUrl : Url -> Maybe Route
fromUrl url =
    let
        fragment =
            Maybe.withDefault "" url.fragment
    in
    if String.isEmpty fragment then
        Just List

    else
        let
            elements =
                String.split "?" fragment
        in
        Url.parse route
            { url
                | query = Just <| (Maybe.withDefault "" <| List.Extra.last elements)
                , path = Maybe.withDefault "" <| List.head elements
                , fragment = Nothing
            }


pushUrl : Navigation.Key -> Route -> Cmd msg
pushUrl key =
    toString >> Navigation.pushUrl key


replaceUrl : Navigation.Key -> Route -> Cmd msg
replaceUrl key =
    toString >> Navigation.replaceUrl key
