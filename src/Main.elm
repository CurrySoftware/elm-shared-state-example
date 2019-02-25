module Main exposing (main)

import Browser
import Browser.Navigation as Navigation
import Element exposing (centerX, column, layout)
import Errored exposing (PageLoadError)
import Html exposing (Html)
import Page.Edit
import Page.Header
import Page.Item
import Page.List
import Route exposing (Route)
import State exposing (State)
import Url exposing (Url)


type alias Model =
    { page : Page
    , currentRoute : Maybe Route
    , key : Navigation.Key
    , state : State
    }


type Page
    = Edit Page.Edit.Model
    | Item Page.Item.Model
    | List
    | Errored PageLoadError


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | SubPage PageMsg
    | StateMsg State.Msg


type PageMsg
    = EditMsg Page.Edit.Msg
    | ItemMsg Page.Item.Msg
    | ListMsg Page.List.Msg


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url key =
    setRoute (Route.fromUrl url)
        { page = List
        , currentRoute = Nothing
        , key = key
        , state =
            State.init
                [ "Issue #1"
                , "Issue #2"
                , "Issue #3"
                ]
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubPage subMsg ->
            updatePage model.key subMsg model

        ChangedUrl url ->
            setRoute (Route.fromUrl url) model

        a ->
            ( model, Cmd.none )


updatePage : Navigation.Key -> PageMsg -> Model -> ( Model, Cmd Msg )
updatePage key msg model =
    let
        executeStateMsg stateMsg =
            stateMsg
                |> Maybe.map (\s -> State.update s model.state)
                |> Maybe.withDefault model.state

        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd, stateMsg ) =
                    subUpdate key subMsg subModel
            in
            ( { model
                | page = toModel newModel
                , state = executeStateMsg stateMsg
              }
            , Cmd.map (SubPage << toMsg) newCmd
            )
    in
    case ( msg, model.page ) of
        ( EditMsg subMsg, Edit subModel ) ->
            toPage Edit EditMsg Page.Edit.update subMsg subModel

        ( ItemMsg subMsg, Item subModel ) ->
            toPage Item ItemMsg Page.Item.update subMsg subModel

        ( ListMsg subMsg, List ) ->
            let
                ( newCmd, stateMsg ) =
                    Page.List.update key subMsg
            in
            ( { model | state = executeStateMsg stateMsg }
            , Cmd.map (SubPage << ListMsg) newCmd
            )

        _ ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    let
        header =
            Page.Header.view model.state

        page =
            case model.page of
                Edit subModel ->
                    Page.Edit.view subModel
                        |> Element.map (SubPage << EditMsg)

                Item subModel ->
                    Page.Item.view model.state subModel
                        |> Element.map (SubPage << ItemMsg)

                List ->
                    Page.List.view model.state
                        |> Element.map (SubPage << ListMsg)

                Errored e ->
                    Errored.view e
    in
    Browser.Document "Titel" [ layout [] (column [ centerX ] [ header, page ]) ]


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition page =
            ( { model | page = page, currentRoute = maybeRoute }, Cmd.none )
    in
    if model.currentRoute == maybeRoute then
        ( model, Cmd.none )

    else
        case maybeRoute of
            Just route ->
                case route of
                    Route.Edit index ->
                        transition (Edit (Page.Edit.init model.state index))

                    Route.Item index ->
                        transition (Item (Page.Item.init index))

                    Route.List ->
                        transition List

            Nothing ->
                ( model, Cmd.none )


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , view = view
        , update = update
        , subscriptions = \a -> Sub.none
        }
