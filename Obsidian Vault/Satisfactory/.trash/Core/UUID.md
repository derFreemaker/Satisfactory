---
tags:
  - Core
sticker: lucide//file-key
---
# Static__New
---
Creates a new UUID.
## Return:

|Name|Type|Description|
|---|---|---|
|uuid|Core.UUID|The new generated uuid.|

# Static__Empty
---
Returns an empty UUID.
## Return:

|Name|Type|Description|
|---|---|---|
|uuid|Core.UUID|The empty uuid. (000000-0000-000000)|

# Static__Parse
---
Parses an string like this (xxxxxx-xxxx-xxxxxx) to the UUID object.
## Parameter:

|Name|Type|Description|
|---|---|---|
|str|string|The string which contains the uuid. (template: "xxxxxx-xxxx-xxxxxx")|
## Return:

|Name|Type|Description|
|---|---|---|
|uuid|Core.UUID?|The parsed uuid from the string. Is `nil` if could not parse.|

# Constructor
---
## Parameter:

|Name|Type|Description|
|---|---|---|
|head|number[]|The first six characters of the uuid. (as number)|
|body|number[]|The middle four characters of the uuid. (as number)|
|tail|number[]|The last six characters of the uuid. (as number)|
