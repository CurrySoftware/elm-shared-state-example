module Page.Header exposing (view)

import Element exposing (Element, text)
import State exposing (State)


view : State -> Element msg
view state =
    text ("Open Issues: " ++ String.fromInt (List.length state.list))
