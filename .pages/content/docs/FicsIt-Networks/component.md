---
title: FIN.Component.Api
date: "2023-12-06"
---

# FIN.Component.Api
**Lua Lib:** `component`

The Component API provides structures, functions and signals for interacting with the network itself like returning network components.


## component.proxy(id: FIN.UUID) -> component: FIN.Component?

Generates and returns instances of the network component with the given UUID.
If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | FIN.UUID | UUID of a network component. |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| component | FIN.Component? |  |

## component.proxy(...FIN.UUID) -> ...FIN.Component?

Generates and returns instances of the network components with the given UUIDs.
You can pass any amount of parameters and each parameter will then have a corresponding return value.
If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | FIN.UUID | UUIDs |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | FIN.Component? | components |

## component.proxy(ids: FIN.UUID[]) -> components: FIN.Component[]

Generates and returns instances of the network components with the given UUIDs.
You can pass any amount of parameters and each parameter will then have a corresponding return value.
If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ids | FIN.UUID[] |  |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| components | FIN.Component[] |  |

## component.proxy(...FIN.UUID[]) -> ...FIN.Component[]

Generates and returns instances of the network components with the given UUIDs.
You can pass any amount of parameters and each parameter will then have a corresponding return value.
If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | FIN.UUID[] |  |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | FIN.Component[] | components |

## component.findComponent(query: string) -> UUIDs: FIN.UUID[]

Searches the component network for components with the given query.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| query | string |  |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| UUIDs | FIN.UUID[] |  |

## component.findComponent(...string) -> ...FIN.UUID[]

Searches the component network for components with the given query.
You can pass multiple parameters and each parameter will be handled separately and returns a corresponding return value.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | string | querys |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | FIN.UUID[] | UUIDs |

## component.findComponent(type: FIN.Class) -> UUIDs: FIN.UUID[]

Searches the component network for components with the given type.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| type | FIN.Class |  |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| UUIDs | FIN.UUID[] |  |

## component.findComponent(...FIN.Class) -> ...FIN.UUID[]

Searches the component network for components with the given type.
You can pass multiple parameters and each parameter will be handled separately and returns a corresponding return value.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | FIN.Class | classes to search for |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | FIN.UUID[] | UUIDs |
