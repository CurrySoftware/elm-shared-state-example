module Page.Header exposing (Model, Msg(..), init, update, view)

import Element exposing (Element, centerX, el, padding, text)
import State exposing (State)


type Msg
    = UpdateText String


type alias Model =
    { status : String
    }


view : State -> Element msg
view state =
    el [ centerX, padding 5 ] <| text ("Open Issues: " ++ String.fromInt (List.length state.list))


update : Msg -> Model -> Model
update msg model =
    model


init : Model
init =
    { status = "" }
