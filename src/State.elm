module State exposing (Msg(..), State, getIssue, init, update)

import List
import List.Extra as List


type Msg
    = EditIssue Int String
    | RemoveIssue Int
    | AddIssue


type alias State =
    { list : List String
    }


init : List String -> State
init list =
    { list = list
    }


update : Msg -> State -> State
update msg state =
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
            { state | list = List.append state.list [ "" ] }


getIssue : State -> Int -> String
getIssue state index =
    Maybe.withDefault "" <| List.getAt index state.list
