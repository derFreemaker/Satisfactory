---@meta

--- **Lua Lib:** `filesystem`
---
--- The filesystem api provides structures, functions and variables for interacting with the virtual file systems.
---
--- You can’t access files outside the virtual filesystem. If you try to do so, the Lua runtime crashes.
---@class FIN.Filesystem.Api
filesystem = {}

---@alias FIN.Filesystem.Type
---|"tmpfs" # A temporary filesystem only existing at runtime in the memory of your computer. All data will be lost when the system stops.

--- Trys to create a new file system of the given type with the given name.
--- The created filesystem will be added to the system DevDevice.
---@param type FIN.Filesystem.Type - the type of the new filesystem
---@param name string - the name of the new filesystem you want to create
---@return boolean success - returns true if it was able to create the new filesystem
function filesystem.makeFileSystem(type, name) end

--- Trys to remove the filesystem with the given name from the system DevDevice.
--- All mounts of the device will run invalid.
---@param name string - the name of the new filesystem you want to remove
---@return boolean success - returns true if it was able to remove the new filesystem
function filesystem.removeFileSystem(name) end

--- Trys to mount the system DevDevice to the given location.
--- The DevDevice is special Device holding DeviceNodes for all filesystems added to the system. (like TmpFS and drives). It is unmountable as well as getting mounted a seccond time.
---@param path string - path to the mountpoint were the dev device should get mounted to
---@return boolean success - returns if it was able to mount the DevDevice
function filesystem.initFileSystem(path) end

---@alias FIN.Filesystem.File.Openmode
---|"r" read only -> file stream can just read from file. If file doesn’t exist, will return nil
---|"w" write -> file stream can read and write creates the file if it doesn’t exist
---|"a" end of file -> file stream can read and write cursor is set to the end of file
---|"+r" truncate -> file stream can read and write all previous data in file gets dropped
---|"+a" append -> file stream can read the full file but can only write to the end of the existing file

--- Opens a file-stream and returns it as File-table.
---@param path string
---@param mode FIN.Filesystem.File.Openmode
---@return FIN.Filesystem.File File
function filesystem.open(path, mode) end

--- Creates the folder path.
---@param path string - folder path the function should create
---@param all boolean? - if true creates all sub folders from the path
---@return boolean success - returns `true` if it was able to create the directory
function filesystem.createDir(path, all) end

--- Removes the filesystem object at the given path.
---@param path string - path to the filesystem object
---@param all boolean? - if true deletes everything
---@return boolean success - returns `true` if it was able to remove the node
function filesystem.remove(path, all) end

--- Moves the filesystem object from the given path to the other given path.
--- Function fails if it is not able to move the object.
---@param from string - path to the filesystem object you want to move
---@param to string - path to the filesystem object the target should get moved to
---@return boolean success - returns `true` if it was able to move the node
function filesystem.move(from, to) end

--- Renames the filesystem object at the given path to the given name.
---@param path string - path to the filesystem object you want to rename
---@param name string - the new name for your filesystem object
---@return boolean success - returns true if it was able to rename the node
function filesystem.rename(path, name) end

--- Checks if the given path exists.
---@param path string - path you want to check if it exists
---@return boolean exists - true if given path exists
function filesystem.exists(path) end

--- Lists all children of this node. (f.e. items in a folder)
---@param path string - path to the filesystem object you want to get the childs from
---@return string[] childs - array of string which are the names of the childs
function filesystem.childs(path) end

---@deprecated
--- Lists all children of this node. (f.e. items in a folder)
---@param path string - path to the filesystem object you want to get the childs from
---@return string[] childs - array of string which are the names of the childs
function filesystem.children(path) end

--- Checks if path refers to a file.
---@param path string - path you want to check if it refers to a file
---@return boolean isFile - true if path refers to a file
function filesystem.isFile(path) end

--- Checks if given path refers to a directory.
---@param path string - path you want to check if it refers to a directory
---@return boolean isDir - returns true if path refers to a directory
function filesystem.isDir(path) end

--- This function mounts the device referenced by the the path to a device node to the given mount point.
---@param device string - the path to the device you want to mount
---@param mountPoint string - the path to the point were the device should get mounted to
function filesystem.mount(device, mountPoint) end

--- This function unmounts the device referenced to the the given mount point.
---@param mountPoint string - the path to the point were the device is referenced to
function filesystem.unmount(mountPoint) end

--- Executes Lua code in the file referd by the given path.
--- Function fails if path doesn’t exist or path doesn’t refer to a file.
---@param path string - path to file you want to execute as Lua code
---@return any ... - Returned values from executed file.
function filesystem.doFile(path) end

--- Loads the file refered by the given path as a Lua function and returns it.
--- Functions fails if path doesn’t exist or path doesn’t reger to a file.
---@param path string - path to the file you want to load as Lua function
---@return function loadedFunction - the file compiled as Lua function
function filesystem.loadFile(path) end

---@alias FIN.Filesystem.PathParameters
---|0 Normalize the path. -> /my/../weird/./path → /weird/path
---|1 Normalizes and converts the path to an absolute path. -> my/abs/path → /my/abs/path
---|2 Normalizes and converts the path to an relative path. -> /my/relative/path → my/relative/path
---|3 Returns the whole file/folder name. -> /path/to/file.txt → file.txt
---|4 Returns the stem of the filename. -> /path/to/file.txt → file || /path/to/.file → .file
---|5 Returns the file-extension of the filename. -> /path/to/file.txt → .txt || /path/to/.file → empty-str || /path/to/file. → .

--- Combines a variable amount of strings as paths together to one big path.
---@param ... string - paths to be combined
---@return string path - the final combined path
function filesystem.path(...) end

--- Combines a variable amount of strings as paths together to one big path.
--- Additionally, applies given conversion.
---@param parameter FIN.Filesystem.PathParameters - defines a conversion that should get applied to the output path.
---@param ... string - paths to be combined
---@return string path - the final combined and converted output path
function filesystem.path(parameter, ...) end

---@alias FIN.Filesystem.PathRegister
---|1 Is filesystem root
---|2 Is Empty (includes if it is root-path)
---|3 Is absolute path
---|4 Is only a file/folder name
---|5 Filename has extension
---|6 Ends with a / → refers a directory

--- Will be checked for lexical features.
--- Return value which is a bit-flag-register describing those lexical features.
---@param path string - filesystem-path you want to get lexical features from.
---@return FIN.Filesystem.PathRegister BitRegister - bit-register describing the features of each path
function filesystem.analyzePath(path) end

--- Each string will be viewed as one filesystem-path and will be checked for lexical features.
--- Each of those string will then have a integer return value which is a bit-flag-register describing those lexical features.
---@param ... string - filesystem-paths you want to get lexical features from.
---@return FIN.Filesystem.PathRegister ... - bit-registers describing the features of each path
function filesystem.analyzePath(...) end

--- For given string, returns a bool to tell if string is a valid node (file/folder) name.
---@param node string - node-name you want to check.
---@return boolean isNode - True if node is a valid node-name.
function filesystem.isNode(node) end

--- For each given string, returns a bool to tell if string is a valid node (file/folder) name.
---@param ... string - node-names you want to check.
---@return boolean ... - True if the corresponding string is a valid node-name.
function filesystem.isNode(...) end
