module Page.Header exposing (view)

import Element exposing (Element, centerX, el, padding, text)
import State exposing (Msg(..), OldState(..), State)


view : State -> Element msg
view state =
    el [ centerX, padding 5 ] <| text (status state ++ " | " ++ actionState state ++ " | " ++ actionMsg state)


status : State -> String
status state =
    "Open Issues: " ++ String.fromInt (List.length state.list)


actionState : State -> String
actionState state =
    case state.oldState of
        JustState old ->
            if List.length old.list > List.length state.list then
                "Issue removed"

            else if List.length old.list < List.length state.list then
                "Issue added"

            else
                "Issue edited"

        NoState ->
            "No Changes"


actionMsg : State -> String
actionMsg state =
    case state.lastAction of
        Just action ->
            case action of
                EditIssue id str ->
                    "Issue " ++ String.fromInt id ++ " edited"

                RemoveIssue id ->
                    "Issue " ++ String.fromInt id ++ "removed"

                AddIssue ->
                    "Issue added."

        Nothing ->
            "No Changes"
