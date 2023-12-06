---
title: FIN.Event.Api
date: "2023-12-06"
---

# FIN.Event.Api
**Lua Lib:** `event`

The Event API provides classes, functions and variables for interacting with the component network.


## event.listen(component: FIN.Component)

Adds the running lua context to the listen queue of the given component.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| component | FIN.Component | The network component lua representation the computer should now listen to. |

## event.listening() -> components: FIN.Component[]

Returns all signal senders this computer is listening to.


**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| components | FIN.Component[] | An array containing instances to all sginal senders this computer is listening too. |

## event.pull(timeoutSeconds: number?) -> signalName: string, component: FIN.Component, ...any

Waits for a signal in the queue. Blocks the execution until a signal got pushed to the signal queue, or the timeout is reached.
Returns directly if there is already a signal in the queue (the tick doesn’t get yielded).

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| timeoutSeconds | number? | The amount of time needs to pass until pull unblocks when no signal got pushed. |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| signalName | string | The name of the returned signal. |
| component | FIN.Component | The component representation of the signal sender. |
| ... | any | The parameters passed to the signal. |

## event.ignore(component: FIN.Component)

Removes the running lua context from the listen queue of the given components. Basically the opposite of listen.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| component | FIN.Component | The network component lua representations the computer should stop listening to. |

## event.ignoreAll()

Stops listening to any signal sender. If afterwards there are still coming signals in, it might be the system itself or caching bug.


## event.clear()

Clears every signal from the signal queue.

