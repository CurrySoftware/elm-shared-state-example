module Page.Header exposing (view)

import Element exposing (Element, centerX, el, padding, text)
import State exposing (State)


view : State -> Element msg
view state =
    el [ centerX, padding 5 ] <| text ("Open Issues: " ++ String.fromInt (List.length state.list))
