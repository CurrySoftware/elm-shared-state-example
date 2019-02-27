# Shared State in Elm

## Introduction

In Elm, splitting up a module into multiple smaller modules may be cumbersome and result in issues relating to the **single source of truth** principle.
That's why, in real world Elm applications, it is not seldom to encounter very large modules.
This article will introduce an architectural concept to deal with this issue by allowing the division of modules into **logical**, **consistent** and **reusable** submodules.

This is often discouraged due to the additional complexity of the information that has to be available in several modules.
Instead, it is suggested that files are larger and consist of one rather complex module.

In [The life of a file](https://www.youtube.com/watch?v=XpDsk374LDE), [Czaplicki](https://github.com/evancz) talks about this refactoring task and proposes possible solutions.
He emphasizes that large files can still be controlled and are not more error prone because of cheap refactoring and the absence of 'sneaky mutations'.
If **independent** pieces of code exist which in addition may be reusable, he recommends to extract this functionality into a separate module.

We extend this refactoring concept by introducing a **shared state** that can be utilized when several parts of the code are **not independent**.

With the help of this example application, we propose how a state of either a single page application or components in a more complex module may be shared among each other.
In this case, the shared model `State` is stored in the higher level module `Main` and its information can be accessed and mutated by individual components using the predefined API using messages.

## Related Work

[Hanhinen](https://github.com/ohanhi) proposed a concept of a shared state which can be found at
[elm-shared-state](https://github.com/ohanhi/elm-shared-state).
In their version, the `SharedState` model holds information which is used by several submodules.
The information is sent to each submodule via the added parameter in the view and update functions:

```elm
view : SharedState -> Model -> Html Msg
```

Additionally, the `update` functions of respective submodules return a `SharedStateUpdate` message which is processed by the `SharedState` module and used to update the state.
This way, the submodules using the state do not have a direct way to manipulate it.

Therefore, the `update` function now looks like this:

```elm
update : SharedState -> Msg -> Model -> ( Model, Cmd Msg, SharedStateUpdate )
```

## Description of our approach

We extended the approach from [Hanhinen](https://github.com/ohanhi) and use an example single page application to show our findings.
The example site is a simple issue tracker:

 <img src="resources/ListView.png" alt="List of Issues" width="700"> 

It keeps track of a list of issues which are stored in the shared `State`.

```elm
type alias State = { list : List String }
```

The set of possible changes to the `State` are defined as messages and only modifiable with the `update` function which is defined as follows:

```elm
update : Msg -> State -> State
```

### Modules

In addition to the `State` module, the application has the following four view modules:

- The `List` module presents an overview of the issues. From here, issues may be created, viewed, updated or deleted.
- Issues can be viewed on the `Item` page.
- An issue can be updated on the `Edit` page.
- Additionally, a `Header` shows the current number of issues.

### Update

The following figure gives an overview of the `update` functionality using `Edit` as an example:

![Update Update](resources/OverviewUpdate.svg)

First, an update in Main is triggered.
Then, `Edit.update` is called with the present `Edit.Msg` message which looks like the following:

```elm
type Msg
    = SetText String      -- Edit the text in the TextField
    | GoBack              -- Go back to the Overview
    | StateMsg State.Msg  -- Change the State
```
The `StateMsg` is of great interest.
It is triggered whenever a change in the `State` is needed.
In our case, clicking the save button triggers the message `StateMsg (EditIssue selectIdx text)` which is then passed to the following `update` function:

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

The `StateMsg` is wrapped in a `Maybe` monad and only returned when an update of the `State` is needed.
The `update` function thus returns `Just (EditIssue selectIdx text)` as the state update message.

The message type `StateMsg State.Msg` is introduced in every submodule which needs to update the state (`Header` only consists of a view).
This makes the update functions both smaller and more easily extensible.

`Main` now calls the `update` function of the state with the returned message.
This only happens if a `StateMsg` is present, so steps four and five in the overview are optional.
The new state is returned and saved along side the `Edit.Module`.

### View

The following figure gives an overview of the `view` functionality:

![Overview View](resources/OverviewView.svg)

Since most submodules need information held by the `State`, it is passed to the `view` functions.
The modules display the respective view using both the shared state and their own module.

## Discussion

A shared state can be used to improve consistency and avoid redundancy when information needs to be shared among multiple modules.

### Advantages
The state module has a defined API which means that its model can only be mutated using the existing messages.
The implementation is therefore hidden from the user.
This is crucial to the design since it ensures data consistency and makes it easy to manage the set of possible state mutations.
In addition, the API can be tested more easily.

### Alternatives
Alternatively, submodules could each hold a respective subset of the higher level model.
This makes the implementation of submodules straightforward, but also error prone.
Since parts of the state are held in multiple models, the **single source of truth** principle is violated and redundancy is introduced.

Also, it could be an option to model the application in a single module.
Technically speaking, this would not harm data consistency or modeling capability.
However, breaking up the code in submodules is often times sensible because it improves the separation of concerns and makes the tasks of each module more apparent.

### Drawbacks

Improvements can still be made with respect to abstraction and separation of concerns.
Submodules, which are only allowed to mutate a subset of the state, still have access to any of the defined messages.
Different types of `update` messages may be defined in the shared state to mitigate this issue.

With the presented architecture, it is not intended for submodules to propagate updates to models of other submodules.
In essence, it is not possible for A to trigger an event that changes the model of B without the shared state holding the respective information.
However, this type of update is useful and as of now renders a drawback to the shared state approach.
For example, it would be beneficial if a change in a selection that is a state change would display a modal in a different module.

Perhaps, an extension in the form of a subscription system, may address this issue.
Submodules might subscribe to state messages and receive updates when respective messages are processed by the shared state.

## Try it yourself

You can try this example application by cloning this repository and building the elm app.

For example, run:

```sh
git clone https://github.com/CurrySoftware/elm-shared-state-example
cd elm-shared-state-example
elm reactor
```

Feel free to submit issues with the approach or request clarification.