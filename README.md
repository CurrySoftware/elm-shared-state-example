# Shared State in Elm

## Introduction

In Elm, nested or separate pages may want to share information among each other.
Realizing this comes with several challenges related to consistency and redundancy.
Every submodule could hold relevant information, -> prone to errors.
Common information can be organized across multiple sub-/ modules using a state which is held by the model of a higher level module, for example the `Main.elm`.

This example shows how a state of either a single page application or components in a more complex module may be shared among each other.
Individual components can access information stored in the state and mutate the state in a defined way.

## Previous Solutions

[Hanhinen](https://github.com/ohanhi) proposed a concept of a shared state which can be found at
[elm-shared-state](https://github.com/ohanhi/elm-shared-state).
In his version, the `SharedState` model holds information which is used by several submodules.
The information is sent to each submodule via the added parameter in the respective functions view and update:

```elm
view : SharedState -> Model -> Html Msg
```

Additionally, the `update` functions of the respective submodules return a `SharedStateUpdate` message which is processed by the `SharedState` module and used to update the state.
This way, the submodules using the state do not have a direct way to manipulate it.

Therefore, the `update` function now looks like this:

```elm
update : SharedState -> Msg -> Model -> ( Model, Cmd Msg, SharedStateUpdate )
```

## Description of our approach

We extended the approach from [Hanhinen](https://github.com/ohanhi) and showed our version with the help of a simple example single page application.
The example site is a simple issue tracker which keeps track of a list of issues.
The list of issues are stored in the shared `State`.

```elm
type alias State = { list : List String }
```

The set of possible changes to the `State` are defined as messages and only modifiable with the `update` function which is defined as follows:

```elm
update : Msg -> State -> State
```

### Modules

The application is comprised of the following four modules:

- The `List` module presents an overview of the issues. From here, issues may be added, deleted or edited.
- An issue can be edited on the `Edit` page.
- Issues can be inspected on the `Item` page.
- Additionally, a `Header` shows the current number of issues.

Every submodule needs information held by the `State`, thus it is passed to respective `view` functions.

### Update

The messages of the `Edit` submodule look like the following:

```elm
type Msg
    = SetText String      -- Edit the text in the TextField
    | GoBack              -- Go back to the Overview
    | StateMsg State.Msg  -- Change the State
```
The `StateMsg` is of great interest.
It is triggered whenever a change in the `State` is needed.
In our case, clicking the save button triggers the Message `StateMsg <| EditIssue selectIdx text`.

This message is passed to the following `update` function:

```elm
update : Key -> Msg -> Model -> ( Model, Cmd Msg, Maybe State.Msg )
update key msg model =
    case msg of
        SetText text ->
            ( { model | text = text }, Cmd.none, Nothing )

        GoBack ->
            ( model, Route.pushUrl key Route.List, Nothing )

        StateMsg stateMsg ->
            ( model, Cmd.none, Just stateMsg )
```

Note that the current state is not passed to the `update` function.
This is not needed since the `StateMsg` is self contained.

The `StateMsg` is only returned.

---
- Maybe StateMsg
- Introduce StateMsg in each subModule -> smaller update functions

## Try it yourself
