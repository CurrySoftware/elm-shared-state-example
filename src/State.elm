module State exposing (Msg(..), OldState(..), State, getIssue, init, update)

import List
import List.Extra as List


type Msg
    = EditIssue Int String
    | RemoveIssue Int
    | AddIssue


type alias State =
    { list : List String
    , oldState : OldState
    , lastAction : Maybe Msg
    }


type OldState
    = NoState -- maybe Maybe
    | JustState State


init : List String -> State
init list =
    { list = list
    , oldState = NoState
    , lastAction = Nothing
    }


update : Msg -> State -> State
update msg state =
    let
        newState =
            case msg of
                EditIssue index newText ->
                    { state | list = List.setAt index newText state.list }

                RemoveIssue index ->
                    { state
                        | list =
                            List.append
                                (List.take index state.list)
                                (List.drop (index + 1) state.list)
                    }

                AddIssue ->
                    { state | list = List.append state.list [ "Issue #" ++ (String.fromInt <| 1 + List.length state.list) ] }
    in
    { newState | oldState = JustState state, lastAction = Just msg }


getIssue : State -> Int -> String
getIssue state index =
    Maybe.withDefault "" <| List.getAt index state.list
