---
title: FIN.Filesystem.Api
date: "2023-12-06"
---

# FIN.Filesystem.Api
**Lua Lib:** `filesystem`

The filesystem api provides structures, functions and variables for interacting with the virtual file systems.

You can’t access files outside the virtual filesystem. If you try to do so, the Lua runtime crashes.


## filesystem.makeFileSystem(type: FIN.Filesystem.Type, name: string) -> success: boolean

Trys to create a new file system of the given type with the given name.
The created filesystem will be added to the system DevDevice.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| type | FIN.Filesystem.Type | the type of the new filesystem |
| name | string | the name of the new filesystem you want to create |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | boolean | returns true if it was able to create the new filesystem |

## filesystem.removeFileSystem(name: string) -> success: boolean

Trys to remove the filesystem with the given name from the system DevDevice.
All mounts of the device will run invalid.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| name | string | the name of the new filesystem you want to remove |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | boolean | returns true if it was able to remove the new filesystem |

## filesystem.initFileSystem(path: string) -> success: boolean

Trys to mount the system DevDevice to the given location.
The DevDevice is special Device holding DeviceNodes for all filesystems added to the system. (like TmpFS and drives). It is unmountable as well as getting mounted a seccond time.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | path to the mountpoint were the dev device should get mounted to |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | boolean | returns if it was able to mount the DevDevice |

## filesystem.open(path: string, mode: FIN.Filesystem.openmode) -> File: FIN.Filesystem.File

Opens a file-stream and returns it as File-table.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string |  |
| mode | FIN.Filesystem.openmode |  |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| File | FIN.Filesystem.File |  |

## filesystem.createDir(path: string, all: boolean?) -> success: boolean

Creates the folder path.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | folder path the function should create |
| all | boolean? | if true creates all sub folders from the path |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | boolean | returns if it was able to create the directory |

## filesystem.remove(path: string, all: boolean?) -> success: boolean

Removes the filesystem object at the given path.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | path to the filesystem object |
| all | boolean? | if true deletes everything |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | boolean | returns if it was able to remove the node |

## filesystem.move(from: string, to: string) -> success: boolean

Moves the filesystem object from the given path to the other given path.
Function fails if it is not able to move the object.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | string | path to the filesystem object you want to move |
| to | string | path to the filesystem object the target should get moved to |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | boolean | returns true if it was able to move the node |

## filesystem.rename(path: string, name: string) -> success: boolean

Renames the filesystem object at the given path to the given name.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | path to the filesystem object you want to rename |
| name | string | the new name for your filesystem object |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | boolean | returns true if it was able to rename the node |

## filesystem.exists(path: string) -> exists: boolean

Checks if the given path exists.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | path you want to check if it exists |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| exists | boolean | true if given path exists |

## filesystem.childs(path: string) -> childs: string[]

Lists all children of this node. (f.e. items in a folder)

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | path to the filesystem object you want to get the childs from |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| childs | string[] | array of string which are the names of the childs |

## filesystem.children(path: string) -> childs: string[]

@deprecated
Lists all children of this node. (f.e. items in a folder)

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | path to the filesystem object you want to get the childs from |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| childs | string[] | array of string which are the names of the childs |

## filesystem.isFile(path: string) -> isFile: boolean

Checks if path refers to a file.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | path you want to check if it refers to a file |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| isFile | boolean | true if path refers to a file |

## filesystem.isDir(path: string) -> isDir: boolean

Checks if given path refers to a directory.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | path you want to check if it refers to a directory |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| isDir | boolean | returns true if path refers to a directory |

## filesystem.mount(device: string, mountPoint: string)

This function mounts the device referenced by the the path to a device node to the given mount point.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| device | string | the path to the device you want to mount |
| mountPoint | string | the path to the point were the device should get mounted to |

## filesystem.unmount(mountPoint: string)

This function unmounts the device referenced to the the given mount point.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| mountPoint | string | the path to the point were the device is referenced to |

## filesystem.doFile(path: string) -> ...any

Executes Lua code in the file referd by the given path.
Function fails if path doesn’t exist or path doesn’t refer to a file.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | path to file you want to execute as Lua code |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | any | Returned values from executed file. |

## filesystem.loadFile(path: string) -> loadedFunction: function

Loads the file refered by the given path as a Lua function and returns it.
Functions fails if path doesn’t exist or path doesn’t reger to a file.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | path to the file you want to load as Lua function |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| loadedFunction | function | the file compiled as Lua function |

## filesystem.path(...string) -> path: string

Combines a variable amount of strings as paths together to one big path.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | string | paths to be combined |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | the final combined path |

## filesystem.path(parameter: FIN.Filesystem.PathParameters, ...string) -> path: string

Combines a variable amount of strings as paths together to one big path.
Additionally, applies given conversion.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| parameter | FIN.Filesystem.PathParameters | defines a conversion that should get applied to the output path. |
| ... | string | paths to be combined |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | the final combined and converted output path |

## filesystem.analyzePath(path: string) -> BitRegister: FIN.Filesystem.PathRegister

Will be checked for lexical features.
Return value which is a bit-flag-register describing those lexical features.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| path | string | filesystem-path you want to get lexical features from. |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| BitRegister | FIN.Filesystem.PathRegister | bit-register describing the features of each path |

## filesystem.analyzePath(...string) -> ...FIN.Filesystem.PathRegister

Each string will be viewed as one filesystem-path and will be checked for lexical features.
Each of those string will then have a integer return value which is a bit-flag-register describing those lexical features.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | string | filesystem-paths you want to get lexical features from. |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | FIN.Filesystem.PathRegister | bit-registers describing the features of each path |

## filesystem.isNode(node: string) -> isNode: boolean

For given string, returns a bool to tell if string is a valid node (file/folder) name.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| node | string | node-name you want to check. |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| isNode | boolean | True if node is a valid node-name. |

## filesystem.isNode(...string) -> ...boolean

For each given string, returns a bool to tell if string is a valid node (file/folder) name.

**Params**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | string | node-names you want to check. |

**Returns**

| Name | Type | Description |
| ---- | ---- | ----------- |
| ... | boolean | True if the corresponding string is a valid node-name. |
