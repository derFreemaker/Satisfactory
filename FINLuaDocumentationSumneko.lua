error("I don't know what your misson is. But is file is not meant to be executed in any way. It's a meta file.")
---@meta

---@class FIN.classes
classes = {}

---@class FIN.structs
structs = {}

-- some more FicsIt-Networks things to support more type specific things and also adds documentation for `computer`, `component`, `event` and `filesystem` libraries in FicsIt-Networks (keep in mind this is all written by hand and can maybe not represent all features available)

--- # Not in FicsIt-Networks available #
package = nil

--- # Not in FicsIt-Networks available #
os = nil

--- # Not in FicsIt-Networks available #
collectgarbage = nil

--- # Not in FicsIt-Networks available #
io = nil

--- # Not in FicsIt-Networks available #
arg = nil

--- # Not in FicsIt-Networks available #
require = nil

---@class FIN.UUID : string


-- adding alias to make more descriptive correct naming and more plausible when using `computer.getPCIDevice()`

---@alias FIN.PCIDevice FIN.FINComputerModule

---@class Engine.Object
local Object = {}

--- The network id of this component.
---
--- ## Only on objects that are network components.
--- ### Flags:
--- * ? Runtime Synchronous - Can be called/changed in Game Tick ?
--- * ? Runtime Parallel - Can be called/changed in Satisfactory Factory Tick ?
--- * Read Only - The value of this property can not be changed by code
---@type FIN.UUID
Object.id = nil

--- The nick you gave the component in the network its in.
--- If it has no nick name it returns `nil`.
---
--- ## Only on objects that are network components.
--- ### Flags:
--- * ? Runtime Synchronous - Can be called/changed in Game Tick ?
--- * ? Runtime Parallel - Can be called/changed in Satisfactory Factory Tick ?
--- * Read Only - The value of this property can not be changed by code
---@type string
Object.nick = nil

-- global functions from FicsIt-Networks

--- Tries to find the item with the provided name.
---@param name string
---@return Engine.Object
function findItem(name) end

--- Tries to find the items or item provided via name.
---@param ... string
---@return Engine.Object[]
function getItems(...) end

---@param seconds number
function sleep(seconds) end

---@param func function Wraps the given thread/coroutine in a Lua-Future
---@return FIN.Future
function async(func) end

--- Allows to log the given strings to the Game Log.
---@param ... any A list of log messages that should get printed to the game console.
function debug.log(...) end



---@class FIN.Future
local Future = {}

--- Gets the data.
---@return any ...
function Future:get() end

---@return boolean success, number timeout
function Future:poll() end

--- Waits for the future to finish processing and returns the result.
---@async
---@return any ...
function Future:await() end

--- Checks if the Future is done processing.
---@return boolean isDone
function Future:canGet() end

--- **FicsIt-Networks Lua Lib:** `future`
---
--- This Module provides the Future type and all its necessary functionallity.
---@class FIN.Future.Api
future = {}

--- Wraps the given thread/coroutine in a Lua-Future
---@param thread thread
---@return FIN.Future
function future.async(thread) end

--- Creates a new Future that will only finish once all futures passed as parameters have finished.
---@param ... FIN.Future
---@return FIN.Future The Future that will finish once all other futures finished.
function future.join(...) end

--- Creates a future that returns after the given amount of seconds.
---@return FIN.Future
function future.sleep(seconds) end

--- A list of futures that are considered "Tasks".
--- Tasks could be seen as background threads. Effectively getting "joined" together.
--- Examples for tasks are callback invocations of timers and event listeners.
---@type FIN.Future[]
future.tasks = nil

--- Adds the given futures to the tasks list.
---@param ... FIN.Future
function future.addTask(...) end

--- Runs the default task scheduler once.
---@return integer left
---@return number timeout
function future.run() end

--- Runs the default task scheduler indefinitely until no tasks are left.
function future.loop() end



--- **FicsIt-Networks Lua Lib:** `event`
---
--- The Event API provides classes, functions and variables for interacting with the component network.
---@class FIN.Event.Api
event = {}

--- Adds the running lua context to the listen queue of the given component.
---@param component Engine.Object - The network component lua representation the computer should now listen to.
function event.listen(component) end

--- Returns all signal senders this computer is listening to.
---@return Engine.Object[] components - An array containing instances to all sginal senders this computer is listening too.
function event.listening() end

--- Waits for a signal in the queue. Blocks the execution until a signal got pushed to the signal queue, or the timeout is reached.
--- Returns directly if there is already a signal in the queue (the tick doesn’t get yielded).
---@param timeoutSeconds number? - The amount of time needs to pass until pull unblocks when no signal got pushed.
---@return string signalName - The name of the returned signal.
---@return Engine.Object component - The component representation of the signal sender.
---@return any ... - The parameters passed to the signal.
function event.pull(timeoutSeconds) end

--- Removes the running lua context from the listen queue of the given components. Basically the opposite of listen.
---@param component Engine.Object - The network component lua representations the computer should stop listening to.
function event.ignore(component) end

--- Stops listening to any signal sender. If afterwards there are still coming signals in, it might be the system itself or caching bug.
function event.ignoreAll() end

--- Clears every signal from the signal queue.
function event.clear() end

---@alias FIN.EventFilter.Supported_Types
---|nil
---|boolean
---|number
---|string
---|Engine.Object
---|FIN.Struct
---|FIN.Class
---|FIN.EventFilter.Supported_Types[]

---@class FIN.EventFilter.Config
---@field event string | string[] | nil
---@field sender Engine.Object | Engine.Object[] | nil
---@field values table<string, FIN.EventFilter.Supported_Types>

--- Creates an Event filter expression.
---@param filter FIN.EventFilter.Config
---@return FIN.EventFilter
function event.filter(filter) end

--- Registers the given function as a listener.
--- When `event.pull()` pulls a signal from the queue, that matches the given Event-Filter,
--- a Task will be created using the function and the signals parameters will be passed into the function.
---@param filter FIN.EventFilter
---@param func fun(event: string, sender: Engine.Object, ...: any)
function event.registerListener(filter, func) end

---@class FIN.EventQueue
local event_queue = {}

---@param timeout number
---@return string event
---@return Engine.Object sender
---@return any ...
function event_queue:pull(timeout) end

--- Returns a Future that resolves when a signal got added to the queue that matches the given Event Filter.
---@param filter FIN.EventFilter
---@return FIN.Future
function event_queue:wait_for(filter) end

--- Creates a new event queue.
--- When this variable closes or gets garbage collected, it will stop receiving signals.
---@param filter FIN.EventFilter
function event.queue(filter) end

--- Returns a Future that resolves when a signal got polled that matches the given Event Filter.
---@param filter FIN.EventFilter
---@return FIN.Future
function event:wait_for(filter) end

--- Runs an infinite loop or `future.run()`, `event.pull(0)` and `coroutine.yield()`.
function event.loop() end


--- **FicsIt-Networks Lua Lib:** `component`
---
--- The Component API provides structures, functions and signals for interacting with the network itself like returning network components.
---@class FIN.Component.Api
component = {}


--- Generates and returns instances of the network component with the given UUID.
--- If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.
---@generic T : Engine.Object
---@param id FIN.UUID - UUID of a network component.
---@return T? component
function component.proxy(id) end

--- Generates and returns instances of the network components with the given UUIDs.
--- You can pass any amount of parameters and each parameter will then have a corresponding return value.
--- If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.
---@generic T : Engine.Object
---@param ... FIN.UUID - UUIDs
---@return T? ... - components
function component.proxy(...) end

--- Generates and returns instances of the network components with the given UUIDs.
--- You can pass any amount of parameters and each parameter will then have a corresponding return value.
--- If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.
---@generic T : Engine.Object
---@param ids FIN.UUID[]
---@return T[] components
function component.proxy(ids) end

--- Generates and returns instances of the network components with the given UUIDs.
--- You can pass any amount of parameters and each parameter will then have a corresponding return value.
--- If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.
---@generic T : Engine.Object
---@param ... FIN.UUID[]
---@return T[] ... - components
function component.proxy(...) end

--- Searches the component network for components with the given query.
---@param query string
---@return FIN.UUID[] UUIDs
function component.findComponent(query) end

--- Searches the component network for components with the given query.
--- You can pass multiple parameters and each parameter will be handled separately and returns a corresponding return value.
---@param ... string - querys
---@return FIN.UUID[] ... - UUIDs
function component.findComponent(...) end

--- Searches the component network for components with the given type.
---@param type Engine.Object
---@return FIN.UUID[] UUIDs
function component.findComponent(type) end

--- Searches the component network for components with the given type.
--- You can pass multiple parameters and each parameter will be handled separately and returns a corresponding return value.
---@param ... Engine.Object - classes to search for
---@return FIN.UUID[] ... - UUIDs
function component.findComponent(...) end


--- **FicsIt-Networks Lua Lib:** `computer`
---
--- The Computer API provides a interface to the computer owns functionalities.
---@class FIN.Computer.Api
computer = {}

--- This function is mainly used to allow switching to a higher tick runtime state. Usually you use this when you want to make your code run faster when using functions that can run in asynchronous environment.
function computer.skip() end

--- Returns some kind of strange/mysterious time data from a unknown place (the real life).
---@return integer Timestamp - Unix Timestamp
---@return string DateTimeStamp - Serverside Formatted Date-Time-Stamp
---@return string DateTimeStamp - Date-Time-Stamp after ISO 8601
function computer.magicTime() end

--- Returns the current memory usage
---@return integer usage
---@return integer capacity
function computer.getMemory() end

--- Returns the current computer case instance
---@return FIN.ComputerCase
function computer.getInstance() end

--- This function allows you to get all installed PCI-Devices in a computer of a given type.
---@generic TPCIDevice : FIN.PCIDevice
---@param type TPCIDevice
---@return TPCIDevice[]
function computer.getPCIDevices(type) end

--- Returns the amount of milliseconds passed since the system started.
---@return integer milliseconds - Amount of milliseconds since system start
function computer.millis() end

--- Stops the current code execution immediately and queues the system to restart in the next tick.
function computer.reset() end

--- Stops the current code execution.
--- Basically kills the PC runtime immediately.
function computer.stop() end

--- Sets the code of the current eeprom. Doesn’t cause a system reset.
---@param code string - The code you want to place into the eeprom.
function computer.setEEPROM(code) end

--- Returns the code the current eeprom contents.
---@return string code - The code in the EEPROM
function computer.getEEPROM() end

--- Lets the computer emit a simple beep sound with the given pitch.
---@param pitch number - The pitch of the beep sound you want to play.
function computer.beep(pitch) end

--- Crashes the computer with the given error message.
---@param errorMsg string - The crash error message you want to use
function computer.panic(errorMsg) end

--- Shows a text notification to the player. If player is `nil` to all players.
---@param text string
---@param playerName string?
function computer.textNotification(text, playerName) end

--- Creates an attentionPing at the given position to the player. If player is `nil` to all players.
---@param position Engine.Vector
---@param playerName string?
function computer.attentionPing(position, playerName) end

--- Returns the number of game seconds passed since the save got created. A game day consists of 24 game hours, a game hour consists of 60 game minutes, a game minute consists of 60 game seconds.
---@return number time - The number of game seconds passed since the save got created.
function computer.time() end

--- Does the same as computer.skip
function computer.promote() end

--- Reverts effects of skip
function computer.demote() end

--- Returns `true` if the tick state is to higher
---@return boolean isPromoted
function computer.isPromoted() end

---@alias FIN.LogEntry.Verbosity
---|0 Debug
---|1 Info
---|2 Warning
---|3 Error
---|4 Fatal

---@param verbosity FIN.LogEntry.Verbosity
---@param format string
---@param ... any
function computer.log(verbosity, format, ...) end

--- Field containing a reference to the Media Subsystem.
---@type FIN.FINMediaSubsystem
computer.media = nil


--- **FicsIt-Networks Lua Lib:** `filesystem`
---
--- The filesystem api provides structures, functions and variables for interacting with the virtual file systems.
---
--- You can’t access files outside the virtual filesystem. If you try to do so, the Lua runtime crashes.
---@class FIN.Filesystem.Api
filesystem = {}

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

--- Combines a variable amount of strings as paths together.
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
---|4 Is absolute path
---|8 Is only a file/folder name
---|16 Filename has extension
---|32 Ends with a / → refers a directory

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

---@alias FIN.Filesystem.Meta
---|"File" A normal File
---|"Directory" A directory or folder that can hold multiple nodes.
---|"Device" A special type of Node that represents a filesystem and can be mounted.
---|"Unknown" The node type is not known to this utility function.

--- Returns for each given string path, a table that defines contains some meta information about node the string references.
---@param ... string
---@return { type: FIN.Filesystem.Meta } ...
function filesystem.meta(...) end


---@class FIN.Filesystem.File
local File = {}

---@param data string
function File:write(data) end

---@param length integer
function File:read(length) end

---@alias FIN.Filesystem.File.SeekMode
---|"set" # Base is beginning of the file.
---|"cur" # Base is current position.
---|"end" # Base is end of file.

---@param mode FIN.Filesystem.File.SeekMode
---@param offset integer
---@return integer offset
function File:seek(mode, offset) end

function File:close() end
do

--- The base class of every object.
---@class Engine.Object
local Object

---@class FIN.classes.Engine.Object : Engine.Object
classes.Object = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Object.hash = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
Object.internalName = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
Object.internalPath = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Object.hash = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
Object.internalName = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
Object.internalPath = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type string
Object.nick = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
Object.id = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
Object.isNetworkComponent = nil

--- Returns a hash of this object. This is a value that nearly uniquely identifies this object.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number hash The hash of this object.
function Object:getHash() end

--- Returns the type (aka class) of this object.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Class type The type of this object
function Object:getType() end

--- Checks if this Object is a child of the given typen.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param parent Engine.Object The parent we check if this object is a child of.
---@return boolean isChild True if this object is a child of the given type.
function Object:isA(parent) end

--- Descibes a layout of a sign.
---@class Satis.SignPrefab : Engine.Object
local SignPrefab

---@class FIN.classes.Satis.SignPrefab : Satis.SignPrefab
classes.SignPrefab = nil

--- A component/part of an actor in the world.
---@class Engine.ActorComponent : Engine.Object
local ActorComponent

---@class FIN.classes.Engine.ActorComponent : Engine.ActorComponent
classes.ActorComponent = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Engine.Actor
ActorComponent.owner = nil

--- This is the base class of all things that can exist within the world by them self.
---@class Engine.Actor : Engine.Object
local Actor

---@class FIN.classes.Engine.Actor : Engine.Actor
classes.Actor = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Engine.Vector
Actor.location = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Engine.Vector
Actor.scale = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Engine.Rotator
Actor.rotation = nil

--- Returns a list of power connectors this actor might have.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.PowerConnection[] connectors The power connectors this actor has.
function Actor:getPowerConnectors() end

--- Returns a list of factory connectors this actor might have.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.FactoryConnection[] connectors The factory connectors this actor has.
function Actor:getFactoryConnectors() end

--- Returns a list of pipe (fluid & hyper) connectors this actor might have.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.PipeConnectionBase[] connectors The pipe connectors this actor has.
function Actor:getPipeConnectors() end

--- Returns a list of inventories this actor might have.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Inventory[] inventories The inventories this actor has.
function Actor:getInventories() end

--- Returns the components that make-up this actor.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param componentType Engine.ActorComponent The class will be used as filter.
---@return Engine.ActorComponent[] components The components of this actor.
function Actor:getComponents(componentType) end

--- Returns the name of network connectors this actor might have.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Engine.ActorComponent[] connectors The factory connectors this actor has.
function Actor:getNetworkConnectors() end

--- A actor component that allows for a connection point to the power network. Basically a point were a power cable can get attached to.
---@class Satis.PowerConnection : Engine.ActorComponent
local PowerConnection

---@class FIN.classes.Satis.PowerConnection : Satis.PowerConnection
classes.PowerConnection = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerConnection.connections = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerConnection.maxConnections = nil

--- Returns the power info component of this power connection.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.PowerInfo power The power info compoent this power connection uses.
function PowerConnection:getPower() end

--- Returns the power circuit to which this connection component is attached to.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.PowerCircuit circuit The Power Circuit this connection component is attached to.
function PowerConnection:getCircuit() end

--- A actor component that is a connection point to which a conveyor or pipe can get attached to.
---@class Satis.FactoryConnection : Engine.ActorComponent
local FactoryConnection

---@class FIN.classes.Satis.FactoryConnection : Satis.FactoryConnection
classes.FactoryConnection = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
FactoryConnection.type = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
FactoryConnection.direction = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
FactoryConnection.isConnected = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Satis.ItemType
FactoryConnection.allowedItem = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
FactoryConnection.blocked = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
FactoryConnection.unblockedTransfers = nil

--- Adds the given count to the unblocked transfers counter. The resulting value gets clamped to >= 0. Negative values allow to decrease the counter manually. The returning int is the now set count.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param unblockedTransfers number The count of unblocked transfers to add.
---@return number newUnblockedTransfers The new count of unblocked transfers.
function FactoryConnection:addUnblockedTransfers(unblockedTransfers) end

--- Returns the internal inventory of the connection component.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Inventory inventory The internal inventory of the connection component.
function FactoryConnection:getInventory() end

--- Returns the connected factory connection component.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.FactoryConnection connected The connected factory connection component.
function FactoryConnection:getConnected() end

--- Triggers when the factory connection component transfers an item.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Item = event.pull()
--- ```
--- - `signalName: "ItemTransfer"`
--- - `component: FactoryConnection`
--- - `Item: Satis.Item` <br>
--- The transfered item
---@deprecated
---@type FIN.Signal
FactoryConnection.SIGNAL_ItemTransfer = nil

--- A actor component base that is a connection point to which a pipe for fluid or hyper can get attached to.
---@class Satis.PipeConnectionBase : Engine.ActorComponent
local PipeConnectionBase

---@class FIN.classes.Satis.PipeConnectionBase : Satis.PipeConnectionBase
classes.PipeConnectionBase = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
PipeConnectionBase.isConnected = nil

--- Returns the connected pipe connection component.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.PipeConnectionBase connected The connected pipe connection component.
function PipeConnectionBase:getConnection() end

--- A actor component that is a connection point to which a fluid pipe can get attached to.
---@class Satis.PipeConnection : Satis.PipeConnectionBase
local PipeConnection

---@class FIN.classes.Satis.PipeConnection : Satis.PipeConnection
classes.PipeConnection = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipeConnection.fluidBoxContent = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipeConnection.fluidBoxHeight = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipeConnection.fluidBoxLaminarHeight = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipeConnection.fluidBoxFlowThrough = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipeConnection.fluidBoxFlowFill = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipeConnection.fluidBoxFlowDrain = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipeConnection.fluidBoxFlowLimit = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipeConnection.networkID = nil

--- ?
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.ItemType fluidDescriptor ?
function PipeConnection:getFluidDescriptor() end

--- Flush the associated pipe network
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function PipeConnection:flushPipeNetwork() end

--- This is a actor component for railroad tracks that allows to connecto to other track connections and so to connection multiple tracks with each eather so you can build a train network.
---@class Satis.RailroadTrackConnection : Engine.ActorComponent
local RailroadTrackConnection

---@class FIN.classes.Satis.RailroadTrackConnection : Satis.RailroadTrackConnection
classes.RailroadTrackConnection = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Engine.Vector
RailroadTrackConnection.connectorLocation = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Engine.Vector
RailroadTrackConnection.connectorNormal = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
RailroadTrackConnection.isConnected = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
RailroadTrackConnection.isFacingSwitch = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
RailroadTrackConnection.isTrailingSwitch = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadTrackConnection.numSwitchPositions = nil

--- Returns the connected connection with the given index.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index number The index of the connected connection you want to get.
---@return Satis.RailroadTrackConnection connection The connected connection at the given index.
function RailroadTrackConnection:getConnection(index) end

--- Returns a list of all connected connections.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadTrackConnection[] connections A list of all connected connections.
function RailroadTrackConnection:getConnections() end

--- Returns the track pos at which this connection is.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadTrack track The track the track pos points to.
---@return number offset The offset of the track pos.
---@return number forward The forward direction of the track pos. 1 = with the track direction, -1 = against the track direction
function RailroadTrackConnection:getTrackPos() end

--- Returns the track of which this connection is part of.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadTrack track The track of which this connection is part of.
function RailroadTrackConnection:getTrack() end

--- Returns the switch control of this connection.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadSwitchControl switchControl The switch control of this connection.
function RailroadTrackConnection:getSwitchControl() end

--- Returns the station of which this connection is part of.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadStation station The station of which this connection is part of.
function RailroadTrackConnection:getStation() end

--- Returns the signal this connection is facing to.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadSignal signal The signal this connection is facing.
function RailroadTrackConnection:getFacingSignal() end

--- Returns the signal this connection is trailing from.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadSignal signal The signal this connection is trailing.
function RailroadTrackConnection:getTrailingSignal() end

--- Returns the opposite connection of the track this connection is part of.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadTrackConnection opposite The opposite connection of the track this connection is part of.
function RailroadTrackConnection:getOpposite() end

--- Returns the next connection in the direction of the track. (used the correct path switched point to)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadTrackConnection next The next connection in the direction of the track.
function RailroadTrackConnection:getNext() end

--- Sets the position (connection index) to which the track switch points to.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index number The connection index to which the switch should point to.
function RailroadTrackConnection:setSwitchPosition(index) end

--- Returns the current switch position.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number index The index of the connection connection the switch currently points to.
function RailroadTrackConnection:getSwitchPosition() end

--- Forces the switch position to a given location. Even autopilot will be forced to use this track. A negative number can be used to remove the forced track.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param index number The connection index to whcih the switch should be force to point to. Negative number to remove the lock.
function RailroadTrackConnection:forceSwitchPosition(index) end

--- A component that is used to connect two Train Platforms together.
---@class Satis.TrainPlatformConnection : Engine.ActorComponent
local TrainPlatformConnection

---@class FIN.classes.Satis.TrainPlatformConnection : Satis.TrainPlatformConnection
classes.TrainPlatformConnection = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Satis.TrainPlatformConnection
TrainPlatformConnection.connected = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Satis.RailroadTrackConnection
TrainPlatformConnection.trackConnection = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Satis.TrainPlatform
TrainPlatformConnection.platformOwner = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
TrainPlatformConnection.connectionType = nil

--- 
---@class FicsItNetworksCircuit.FINAdvancedNetworkConnectionComponent : Engine.ActorComponent
local FINAdvancedNetworkConnectionComponent

---@class FIN.classes.FicsItNetworksCircuit.FINAdvancedNetworkConnectionComponent : FicsItNetworksCircuit.FINAdvancedNetworkConnectionComponent
classes.FINAdvancedNetworkConnectionComponent = nil

--- <br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, changeType, ChangedComponent = event.pull()
--- ```
--- - `signalName: "NetworkUpdate"`
--- - `component: FINAdvancedNetworkConnectionComponent`
--- - `changeType: number` <br>
--- 
--- - `ChangedComponent: string` <br>
--- 
---@deprecated
---@type FIN.Signal
FINAdvancedNetworkConnectionComponent.SIGNAL_NetworkUpdate = nil

--- 
---@class FicsItNetworksCircuit.FINMCPAdvConnector : FicsItNetworksCircuit.FINAdvancedNetworkConnectionComponent
local FINMCPAdvConnector

---@class FIN.classes.FicsItNetworksCircuit.FINMCPAdvConnector : FicsItNetworksCircuit.FINMCPAdvConnector
classes.FINMCPAdvConnector = nil

--- This actor component contains all the infomation about the movement of a railroad vehicle.
---@class Satis.RailroadVehicleMovement : Engine.ActorComponent
local RailroadVehicleMovement

---@class FIN.classes.Satis.RailroadVehicleMovement : Satis.RailroadVehicleMovement
classes.RailroadVehicleMovement = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.orientation = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.mass = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.tareMass = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.payloadMass = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.speed = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.relativeSpeed = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.maxSpeed = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.gravitationalForce = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.tractiveForce = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.resistiveForce = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.gradientForce = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.brakingForce = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.airBrakingForce = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.dynamicBrakingForce = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.maxTractiveEffort = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.maxDynamicBrakingEffort = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.maxAirBrakingEffort = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.trackGrade = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.trackCurvature = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.wheelsetAngle = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.rollingResistance = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.curvatureResistance = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.airResistance = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.gradientResistance = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.wheelRotation = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicleMovement.numWheelsets = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
RailroadVehicleMovement.isMoving = nil

--- Returns the vehicle this movement component holds the movement information of.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadVehicle vehicle The vehicle this movement component holds the movement information of.
function RailroadVehicleMovement:getVehicle() end

--- Returns the current rotation of the given wheelset.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param wheelset number The index of the wheelset you want to get the rotation of.
---@return number x The wheelset's rotation X component.
---@return number y The wheelset's rotation Y component.
---@return number z The wheelset's rotation Z component.
function RailroadVehicleMovement:getWheelsetRotation(wheelset) end

--- Returns the offset of the wheelset with the given index from the start of the vehicle.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param wheelset number The index of the wheelset you want to get the offset of.
---@return number offset The offset of the wheelset.
function RailroadVehicleMovement:getWheelsetOffset(wheelset) end

--- Returns the normal vector and the extention of the coupler with the given index.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param coupler number The index of which you want to get the normal and extention of.
---@return number x The X component of the coupler normal.
---@return number y The Y component of the coupler normal.
---@return number z The Z component of the coupler normal.
---@return number extention The extention of the coupler.
function RailroadVehicleMovement:getCouplerRotationAndExtention(coupler) end

--- A actor component that can hold multiple item stacks.<br>
--- WARNING! Be aware of container inventories, and never open their UI, otherwise these function will not work as expected.
---@class Satis.Inventory : Engine.ActorComponent
local Inventory

---@class FIN.classes.Satis.Inventory : Satis.Inventory
classes.Inventory = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Inventory.itemCount = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Inventory.size = nil

--- Returns the item stack at the given index.<br>
--- Takes integers as input and returns the corresponding stacks.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param ... any @additional arguments as described
function Inventory:getStack(...) end

--- Sorts the whole inventory. (like the middle mouse click into a inventory)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function Inventory:sort() end

--- Swaps two given stacks inside the inventory.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index1 number The index of the first stack in the inventory.
---@param index2 number The index of the second stack in the inventory.
---@return boolean successful True if the swap was successful.
function Inventory:swapStacks(index1, index2) end

--- Removes all discardable items from the inventory completely. They will be gone! No way to get them back!
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
function Inventory:flush() end

--- Returns true if the item stack at the given index can be split.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index number The slot index of which you want to check if the stack can be split.
---@return boolean canSplit True if the stack at the given index can be split.
function Inventory:canSplitAtIndex(index) end

--- Tries to split the stack at the given index and puts the given amount of items into a free slot.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index number The index of the stack you want to split.
---@param num number The number of items you want to split off the stack at the given index.
function Inventory:splitAtIndex(index, num) end

--- A actor component that provides information and mainly statistics about the power connection it is attached to.
---@class Satis.PowerInfo : Engine.ActorComponent
local PowerInfo

---@class FIN.classes.Satis.PowerInfo : Satis.PowerInfo
classes.PowerInfo = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerInfo.dynProduction = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerInfo.baseProduction = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerInfo.maxDynProduction = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerInfo.targetConsumption = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerInfo.consumption = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
PowerInfo.hasPower = nil

--- Returns the power circuit this info component is part of.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.PowerCircuit circuit The Power Circuit this info component is attached to.
function PowerInfo:getCircuit() end

--- A base class for all vehicles.
---@class Satis.Vehicle : Engine.Actor
local Vehicle

---@class FIN.classes.Satis.Vehicle : Satis.Vehicle
classes.Vehicle = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Vehicle.health = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Vehicle.maxHealth = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
Vehicle.isSelfDriving = nil

--- The base class for any vehicle that drives on train tracks.
---@class Satis.RailroadVehicle : Satis.Vehicle
local RailroadVehicle

---@class FIN.classes.Satis.RailroadVehicle : Satis.RailroadVehicle
classes.RailroadVehicle = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadVehicle.length = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
RailroadVehicle.isDocked = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
RailroadVehicle.isReversed = nil

--- Returns the train of which this vehicle is part of.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Train train The train of which this vehicle is part of
function RailroadVehicle:getTrain() end

--- Allows to check if the given coupler is coupled to another car.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param coupler number The Coupler you want to check. 0 = Front, 1 = Back
---@return boolean coupled True of the give coupler is coupled to another car.
function RailroadVehicle:isCoupled(coupler) end

--- Allows to get the coupled vehicle at the given coupler.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param coupler number The Coupler you want to get the car from. 0 = Front, 1 = Back
---@return Satis.RailroadVehicle coupled The coupled car of the given coupler is coupled to another car.
function RailroadVehicle:getCoupled(coupler) end

--- Returns the track graph of which this vehicle is part of.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.TrackGraph track The track graph of which this vehicle is part of.
function RailroadVehicle:getTrackGraph() end

--- Returns the track pos at which this vehicle is.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadTrack track The track the track pos points to.
---@return number offset The offset of the track pos.
---@return number forward The forward direction of the track pos. 1 = with the track direction, -1 = against the track direction
function RailroadVehicle:getTrackPos() end

--- Returns the vehicle movement of this vehicle.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadVehicleMovement movement The movement of this vehicle.
function RailroadVehicle:getMovement() end

--- The base class for all vehicles that used wheels for movement.
---@class Satis.WheeledVehicle : Satis.Vehicle
local WheeledVehicle

---@class FIN.classes.Satis.WheeledVehicle : Satis.WheeledVehicle
classes.WheeledVehicle = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
WheeledVehicle.speed = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
WheeledVehicle.burnRatio = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
WheeledVehicle.hasFuel = nil

--- Returns the inventory that contains the fuel of the vehicle.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Inventory inventory The fuel inventory of the vehicle.
function WheeledVehicle:getFuelInv() end

--- Returns the inventory that contains the storage of the vehicle.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Inventory inventory The storage inventory of the vehicle.
function WheeledVehicle:getStorageInv() end

--- Allows to check if the given item type is a valid fuel for this vehicle.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param item Satis.ItemType The item type you want to check.
---@return boolean isValid True if the given item type is a valid fuel for this vehicle.
function WheeledVehicle:isValidFuel(item) end

--- Returns the index of the target that the vehicle tries to move to right now.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number index The index of the current target.
function WheeledVehicle:getCurrentTarget() end

--- Sets the current target to the next target in the list.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function WheeledVehicle:nextTarget() end

--- Sets the target with the given index as the target this vehicle tries to move to right now.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index number The index of the target this vehicle should move to now.
function WheeledVehicle:setCurrentTarget(index) end

--- Returns the list of targets/path waypoints.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.TargetList targetList The list of targets/path-waypoints.
function WheeledVehicle:getTargetList() end

--- 
---@class Satis.FGBuildableConveyorAttachment : Satis.Buildable
local FGBuildableConveyorAttachment

---@class FIN.classes.Satis.FGBuildableConveyorAttachment : Satis.FGBuildableConveyorAttachment
classes.FGBuildableConveyorAttachment = nil

--- The base class of all buildables.
---@class Satis.Buildable : Engine.Actor
local Buildable

---@class FIN.classes.Satis.Buildable : Satis.Buildable
classes.Buildable = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Buildable.numPowerConnections = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Buildable.numFactoryConnections = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Buildable.numFactoryOutputConnections = nil

--- Triggers when the production state of the buildable changes.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, State = event.pull()
--- ```
--- - `signalName: "ProductionChanged"`
--- - `component: Buildable`
--- - `State: number` <br>
--- The new production state.
---@deprecated
---@type FIN.Signal
Buildable.SIGNAL_ProductionChanged = nil

--- 
---@class Satis.FGBuildableAttachmentMerger : Satis.FGBuildableConveyorAttachment
local FGBuildableAttachmentMerger

---@class FIN.classes.Satis.FGBuildableAttachmentMerger : Satis.FGBuildableAttachmentMerger
classes.FGBuildableAttachmentMerger = nil

--- Merges up to three Conveyor Belts into one.
---@class Satis.Build_ConveyorAttachmentMerger_C : Satis.FGBuildableAttachmentMerger
local Build_ConveyorAttachmentMerger_C

---@class FIN.classes.Satis.Build_ConveyorAttachmentMerger_C : Satis.Build_ConveyorAttachmentMerger_C
classes.Build_ConveyorAttachmentMerger_C = nil

--- 
---@class Satis.FGBuildableAttachmentSplitter : Satis.FGBuildableConveyorAttachment
local FGBuildableAttachmentSplitter

---@class FIN.classes.Satis.FGBuildableAttachmentSplitter : Satis.FGBuildableAttachmentSplitter
classes.FGBuildableAttachmentSplitter = nil

--- Splits one Conveyor Belt into two or three. <br>
--- Useful for diverting parts and resources away from backlogged Conveyor Belts.
---@class Satis.Build_ConveyorAttachmentSplitter_C : Satis.FGBuildableAttachmentSplitter
local Build_ConveyorAttachmentSplitter_C

---@class FIN.classes.Satis.Build_ConveyorAttachmentSplitter_C : Satis.Build_ConveyorAttachmentSplitter_C
classes.Build_ConveyorAttachmentSplitter_C = nil

--- 
---@class Satis.FGBuildableConveyorAttachmentLightweight : Satis.FGBuildableConveyorAttachment
local FGBuildableConveyorAttachmentLightweight

---@class FIN.classes.Satis.FGBuildableConveyorAttachmentLightweight : Satis.FGBuildableConveyorAttachmentLightweight
classes.FGBuildableConveyorAttachmentLightweight = nil

--- 
---@class Satis.FGBuildableSplitterSmart : Satis.FGBuildableConveyorAttachment
local FGBuildableSplitterSmart

---@class FIN.classes.Satis.FGBuildableSplitterSmart : Satis.FGBuildableSplitterSmart
classes.FGBuildableSplitterSmart = nil

--- Splits one Conveyor Belt into two or three. <br>
--- Multiple filters can be set for each output to allow specific parts to pass through.
---@class Satis.Build_ConveyorAttachmentSplitterProgrammable_C : Satis.FGBuildableSplitterSmart
local Build_ConveyorAttachmentSplitterProgrammable_C

---@class FIN.classes.Satis.Build_ConveyorAttachmentSplitterProgrammable_C : Satis.Build_ConveyorAttachmentSplitterProgrammable_C
classes.Build_ConveyorAttachmentSplitterProgrammable_C = nil

--- Splits one Conveyor Belt into two or three.<br>
--- A filter can be set for each output to allow a specific part to pass through.
---@class Satis.Build_ConveyorAttachmentSplitterSmart_C : Satis.FGBuildableSplitterSmart
local Build_ConveyorAttachmentSplitterSmart_C

---@class FIN.classes.Satis.Build_ConveyorAttachmentSplitterSmart_C : Satis.Build_ConveyorAttachmentSplitterSmart_C
classes.Build_ConveyorAttachmentSplitterSmart_C = nil

--- 
---@class FIN.CodeableMerger : Satis.FGBuildableConveyorAttachment
local CodeableMerger

---@class FIN.classes.FIN.CodeableMerger : FIN.CodeableMerger
classes.CodeableMerger = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
CodeableMerger.canOutput = nil

--- Allows to transfer an item from the given input queue to the output queue if possible.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param input number The index of the input queue you want to transfer the next item to the output queue. (0 = right, 1 = middle, 2 = left)
---@return boolean transfered true if it was able to transfer the item.
function CodeableMerger:transferItem(input) end

--- Returns the next item in the given input queue.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param input number The index of the input queue you want to check (0 = right, 1 = middle, 2 = left)
---@return Satis.Item item The next item in the input queue.
function CodeableMerger:getInput(input) end

--- Triggers when a new item is ready in one of the input queues.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Input, Item = event.pull()
--- ```
--- - `signalName: "ItemRequest"`
--- - `component: CodeableMerger`
--- - `Input: number` <br>
--- The index of the input queue at which the item is ready.
--- - `Item: Satis.Item` <br>
--- The new item in the input queue.
---@deprecated
---@type FIN.Signal
CodeableMerger.SIGNAL_ItemRequest = nil

--- Triggers when an item is popped from the output queue (aka it got transferred to a conveyor).<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Item = event.pull()
--- ```
--- - `signalName: "ItemOutputted"`
--- - `component: CodeableMerger`
--- - `Item: Satis.Item` <br>
--- The item removed from the output queue.
---@deprecated
---@type FIN.Signal
CodeableMerger.SIGNAL_ItemOutputted = nil

--- The FicsIt-Networks Codeable Merger  is able to get connected to the component network and provides functions and signals for custom merger behaviour defenition.<br>
--- <br>
--- This allows you to change the merging behaviour in runtime by connected computers so it can f.e. depend on the amount of items in a storage container.
---@class FIN.Build_CodeableMerger_C : FIN.CodeableMerger
local Build_CodeableMerger_C

---@class FIN.classes.FIN.Build_CodeableMerger_C : FIN.Build_CodeableMerger_C
classes.Build_CodeableMerger_C = nil

--- 
---@class FIN.CodeableSplitter : Satis.FGBuildableConveyorAttachment
local CodeableSplitter

---@class FIN.classes.FIN.CodeableSplitter : FIN.CodeableSplitter
classes.CodeableSplitter = nil

--- Allows to transfer an item from the input queue to the given output queue if possible.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param output number The index of the output queue you want to transfer the next item to (0 = left, 1 = middle, 2 = right)
---@return boolean transfered true if it was able to transfer the item.
function CodeableSplitter:transferItem(output) end

--- Returns the next item in the input queue.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Item item The next item in the input queue.
function CodeableSplitter:getInput() end

--- Returns the factory connector associated with the given index.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param outputIndex number The integer used in TransferItem and ItemOutputted to reference a specific output. Valid Values: 0-3
---@return Satis.FactoryConnection ReturnValue 
function CodeableSplitter:getConnectorByIndex(outputIndex) end

--- Allows to check if we can transfer an item to the given output queue.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param output number The index of the output queue you want to check (0 = left, 1 = middle, 2 = right)
---@return boolean canTransfer True if you could transfer an item to the given output queue.
function CodeableSplitter:canOutput(output) end

--- Triggers when a new item is ready in the input queue.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Item = event.pull()
--- ```
--- - `signalName: "ItemRequest"`
--- - `component: CodeableSplitter`
--- - `Item: Satis.Item` <br>
--- The new item in the input queue.
---@deprecated
---@type FIN.Signal
CodeableSplitter.SIGNAL_ItemRequest = nil

--- Triggers when an item is popped from on of the output queues (aka it got transferred to a conveyor).<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Output, Item = event.pull()
--- ```
--- - `signalName: "ItemOutputted"`
--- - `component: CodeableSplitter`
--- - `Output: number` <br>
--- The index of the output queue from which the item got removed.
--- - `Item: Satis.Item` <br>
--- The item removed from the output queue.
---@deprecated
---@type FIN.Signal
CodeableSplitter.SIGNAL_ItemOutputted = nil

--- The FicsIt-Networks Codeable Splitter is able to get connected to the component network and provides functions and signals for custom splitter behaviour defenition.<br>
--- <br>
--- This allows you to change the splitting behaviour in runtime by connected computers so it can f.e. depend on the amount of items in a storage container.
---@class FIN.Build_CodeableSplitter_C : FIN.CodeableSplitter
local Build_CodeableSplitter_C

---@class FIN.classes.FIN.Build_CodeableSplitter_C : FIN.Build_CodeableSplitter_C
classes.Build_CodeableSplitter_C = nil

--- 
---@class Satis.FGBuildableAutomatedWorkBench : Satis.Manufacturer
local FGBuildableAutomatedWorkBench

---@class FIN.classes.Satis.FGBuildableAutomatedWorkBench : Satis.FGBuildableAutomatedWorkBench
classes.FGBuildableAutomatedWorkBench = nil

--- The base class of every machine that uses a recipe to produce something automatically.
---@class Satis.Manufacturer : Satis.Factory
local Manufacturer

---@class FIN.classes.Satis.Manufacturer : Satis.Manufacturer
classes.Manufacturer = nil

--- Returns the currently set recipe of the manufacturer.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Recipe recipe The currently set recipe.
function Manufacturer:getRecipe() end

--- Returns the list of recipes this manufacturer can get set to and process.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Recipe[] recipes The list of avalible recipes.
function Manufacturer:getRecipes() end

--- Sets the currently producing recipe of this manufacturer.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param recipe Satis.Recipe The recipe this manufacturer should produce.
---@return boolean gotSet True if the current recipe got successfully set to the new recipe.
function Manufacturer:setRecipe(recipe) end

--- Returns the input inventory of this manufacturer.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Inventory inventory The input inventory of this manufacturer
function Manufacturer:getInputInv() end

--- Returns the output inventory of this manufacturer.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Inventory inventory The output inventory of this manufacturer.
function Manufacturer:getOutputInv() end

--- The base class of most machines you can build.
---@class Satis.Factory : Satis.Buildable
local Factory

---@class FIN.classes.Satis.Factory : Satis.Factory
classes.Factory = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.progress = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.powerConsumProducing = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.productivity = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.cycleTime = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
Factory.canChangePotential = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.maxPotential = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.minPotential = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.maxDefaultPotential = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.currentPotential = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.potential = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Satis.Inventory
Factory.potentialInventory = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
Factory.canChangeProductionBoost = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.maxProductionBoost = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.maxDefaultProductionBoost = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.minDefaultProductionBoost = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.currentProductionBoost = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Factory.productionBoost = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
Factory.standby = nil

--- Changes the potential this factory is currently set to and 'should' use. (the overclock value)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param potential number The potential that should be used. 0 = 0%, 1 = 100%
function Factory:setPotential(potential) end

--- Changes the production boost this factory is currently set to and 'should' use.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param productionBoost number The production boost that should be used. 0 = 0%, 1 = 100%
function Factory:setProductionBoost(productionBoost) end

--- text here
---@class Satis.Build_AutomatedWorkBench_C : Satis.FGBuildableAutomatedWorkBench
local Build_AutomatedWorkBench_C

---@class FIN.classes.Satis.Build_AutomatedWorkBench_C : Satis.Build_AutomatedWorkBench_C
classes.Build_AutomatedWorkBench_C = nil

--- 
---@class Satis.FGBuildableManufacturerVariablePower : Satis.Manufacturer
local FGBuildableManufacturerVariablePower

---@class FIN.classes.Satis.FGBuildableManufacturerVariablePower : Satis.FGBuildableManufacturerVariablePower
classes.FGBuildableManufacturerVariablePower = nil

--- The Converter harnesses Reanimated SAM to enable precise matter and energy transmutation.<br>
--- <br>
--- Warning: Power usage is very high and unstable.
---@class Satis.Build_Converter_C : Satis.FGBuildableManufacturerVariablePower
local Build_Converter_C

---@class FIN.classes.Satis.Build_Converter_C : Satis.Build_Converter_C
classes.Build_Converter_C = nil

--- Uses electromagnetic fields to propel particles to very high speeds and energies. The specific design allows for a variety of processes, including matter generation and conversion.<br>
--- <br>
--- Warning: Power usage is extremely high and unstable, and varies per recipe.
---@class Satis.Build_HadronCollider_C : Satis.FGBuildableManufacturerVariablePower
local Build_HadronCollider_C

---@class FIN.classes.Satis.Build_HadronCollider_C : Satis.Build_HadronCollider_C
classes.Build_HadronCollider_C = nil

--- The Quantum Encoder uses Excited Photonic Matter to produce the most complex of parts, controlling development up to the quantum level.<br>
--- <br>
--- Warning: Power usage is extremely high and unstable.
---@class Satis.Build_QuantumEncoder_C : Satis.FGBuildableManufacturerVariablePower
local Build_QuantumEncoder_C

---@class FIN.classes.Satis.Build_QuantumEncoder_C : Satis.Build_QuantumEncoder_C
classes.Build_QuantumEncoder_C = nil

--- Crafts 2 parts into another part.<br>
--- <br>
--- Can be automated by feeding component parts in via Conveyor Belts connected to the input ports. The resulting parts can be automatically extracted by connecting a Conveyor Belt to the output port.
---@class Satis.Build_AssemblerMk1_C : Satis.Manufacturer
local Build_AssemblerMk1_C

---@class FIN.classes.Satis.Build_AssemblerMk1_C : Satis.Build_AssemblerMk1_C
classes.Build_AssemblerMk1_C = nil

--- Blends fluids together or combines them with solid parts in a wide variety of processes.<br>
--- Head Lift: 10 m<br>
--- (Allows fluids to be transported 10 meters upwards.)<br>
--- <br>
--- Has both Conveyor Belt and Pipeline input and output ports.
---@class Satis.Build_Blender_C : Satis.Manufacturer
local Build_Blender_C

---@class FIN.classes.Satis.Build_Blender_C : Satis.Build_Blender_C
classes.Build_Blender_C = nil

--- Crafts 1 part into another part.<br>
--- <br>
--- Can be automated by feeding component parts in via a Conveyor Belt connected to the input port. The resulting parts can be automatically extracted by connecting a Conveyor Belt to the output port.
---@class Satis.Build_ConstructorMk1_C : Satis.Manufacturer
local Build_ConstructorMk1_C

---@class FIN.classes.Satis.Build_ConstructorMk1_C : Satis.Build_ConstructorMk1_C
classes.Build_ConstructorMk1_C = nil

--- Smelts 2 resources into alloy ingots.<br>
--- <br>
--- Can be automated by feeding ore in via Conveyor Belts connected to the input ports. The resulting ingots can be automatically extracted by connecting a Conveyor Belt to the output port.
---@class Satis.Build_FoundryMk1_C : Satis.Manufacturer
local Build_FoundryMk1_C

---@class FIN.classes.Satis.Build_FoundryMk1_C : Satis.Build_FoundryMk1_C
classes.Build_FoundryMk1_C = nil

--- Crafts 3 or 4 parts into another part.<br>
--- <br>
--- Can be automated by feeding component parts in via Conveyor Belts connected to the input ports. The resulting parts can be automatically extracted by connecting a Conveyor Belt to the output port.
---@class Satis.Build_ManufacturerMk1_C : Satis.Manufacturer
local Build_ManufacturerMk1_C

---@class FIN.classes.Satis.Build_ManufacturerMk1_C : Satis.Build_ManufacturerMk1_C
classes.Build_ManufacturerMk1_C = nil

--- Refines fluid and/or solid parts into other parts.<br>
--- Head Lift: 10 m<br>
--- (Allows fluids to be transported 10 meters upwards.)<br>
--- <br>
--- Contains both Conveyor Belt and Pipeline input and output ports so that a wide range of recipes can be automated.
---@class Satis.Build_OilRefinery_C : Satis.Manufacturer
local Build_OilRefinery_C

---@class FIN.classes.Satis.Build_OilRefinery_C : Satis.Build_OilRefinery_C
classes.Build_OilRefinery_C = nil

--- Packages and unpackages fluids.<br>
--- Head Lift: 10 m<br>
--- (Allows fluids to be transported 10 meters upwards.)<br>
--- <br>
--- Contains both Conveyor Belt and Pipeline input and output ports so that a wide range of recipes can be automated.
---@class Satis.Build_Packager_C : Satis.Manufacturer
local Build_Packager_C

---@class FIN.classes.Satis.Build_Packager_C : Satis.Build_Packager_C
classes.Build_Packager_C = nil

--- Smelts ore into ingots.<br>
--- <br>
--- Can be automated by feeding ore in via a Conveyor Belt connected to the input port. The resulting ingots can be automatically extracted by connecting a Conveyor Belt to the output port.
---@class Satis.Build_SmelterMk1_C : Satis.Manufacturer
local Build_SmelterMk1_C

---@class FIN.classes.Satis.Build_SmelterMk1_C : Satis.Build_SmelterMk1_C
classes.Build_SmelterMk1_C = nil

--- 
---@class Satis.FGBuildableCheatFluidSink : Satis.Factory
local FGBuildableCheatFluidSink

---@class FIN.classes.Satis.FGBuildableCheatFluidSink : Satis.FGBuildableCheatFluidSink
classes.FGBuildableCheatFluidSink = nil

--- 
---@class Satis.FGBuildableCheatFluidSpawner : Satis.Factory
local FGBuildableCheatFluidSpawner

---@class FIN.classes.Satis.FGBuildableCheatFluidSpawner : Satis.FGBuildableCheatFluidSpawner
classes.FGBuildableCheatFluidSpawner = nil

--- 
---@class Satis.FGBuildableCheatItemSink : Satis.Factory
local FGBuildableCheatItemSink

---@class FIN.classes.Satis.FGBuildableCheatItemSink : Satis.FGBuildableCheatItemSink
classes.FGBuildableCheatItemSink = nil

--- 
---@class Satis.FGBuildableCheatItemSpawner : Satis.Factory
local FGBuildableCheatItemSpawner

---@class FIN.classes.Satis.FGBuildableCheatItemSpawner : Satis.FGBuildableCheatItemSpawner
classes.FGBuildableCheatItemSpawner = nil

--- Sends or receives resources to/from vehicles.<br>
--- <br>
--- Has 48 inventory slots.<br>
--- <br>
--- Transfers up to 120 stacks per minute to/from docked vehicles. <br>
--- Always refuels vehicles if it has access to a matching fuel type.
---@class Satis.Build_TruckStation_C : Satis.DockingStation
local Build_TruckStation_C

---@class FIN.classes.Satis.Build_TruckStation_C : Satis.Build_TruckStation_C
classes.Build_TruckStation_C = nil

--- A docking station for wheeled vehicles to transfer cargo.
---@class Satis.DockingStation : Satis.Factory
local DockingStation

---@class FIN.classes.Satis.DockingStation : Satis.DockingStation
classes.DockingStation = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
DockingStation.isLoadMode = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
DockingStation.isLoadUnloading = nil

--- Returns the fuel inventory of the docking station.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Inventory inventory The fuel inventory of the docking station.
function DockingStation:getFuelInv() end

--- Returns the cargo inventory of the docking staiton.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Inventory inventory The cargo inventory of this docking station.
function DockingStation:getInv() end

--- Returns the currently docked actor.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Engine.Actor docked The currently docked actor.
function DockingStation:getDocked() end

--- Undocked the currently docked vehicle from this docking station.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function DockingStation:undock() end

--- 
---@class Satis.FGBuildableDroneStation : Satis.Factory
local FGBuildableDroneStation

---@class FIN.classes.Satis.FGBuildableDroneStation : Satis.FGBuildableDroneStation
classes.FGBuildableDroneStation = nil

--- Functions as home Port to a single Drone, which transports available input back and forth between its home Port and destination Port.<br>
--- Drone Ports can have one other Port assigned as their transport destination.<br>
--- <br>
--- The Drone Port interface provides delivery details and allows management of Port connections.
---@class Satis.Build_DroneStation_C : Satis.FGBuildableDroneStation
local Build_DroneStation_C

---@class FIN.classes.Satis.Build_DroneStation_C : Satis.Build_DroneStation_C
classes.Build_DroneStation_C = nil

--- 
---@class Satis.FGBuildableFactorySimpleProducer : Satis.Factory
local FGBuildableFactorySimpleProducer

---@class FIN.classes.Satis.FGBuildableFactorySimpleProducer : Satis.FGBuildableFactorySimpleProducer
classes.FGBuildableFactorySimpleProducer = nil

--- A festively disguised production building. Reminder: Nothing is ever truly free.<br>
--- Produces 15 Gifts per minute.
---@class Satis.Build_TreeGiftProducer_C : Satis.FGBuildableFactorySimpleProducer
local Build_TreeGiftProducer_C

---@class FIN.classes.Satis.Build_TreeGiftProducer_C : Satis.Build_TreeGiftProducer_C
classes.Build_TreeGiftProducer_C = nil

--- Activates a Resource Well by pressurizing the underground resource. Must be placed on a Resource Well.<br>
--- Once activated, Resource Well Extractors can be placed on the surrounding sub-nodes to extract the resource.<br>
--- Requires power. Overclocking increases the output potential of the entire Resource Well.
---@class Satis.Build_FrackingSmasher_C : Satis.FGBuildableFrackingActivator
local Build_FrackingSmasher_C

---@class FIN.classes.Satis.Build_FrackingSmasher_C : Satis.Build_FrackingSmasher_C
classes.Build_FrackingSmasher_C = nil

--- 
---@class Satis.FGBuildableFrackingActivator : Satis.FGBuildableResourceExtractorBase
local FGBuildableFrackingActivator

---@class FIN.classes.Satis.FGBuildableFrackingActivator : Satis.FGBuildableFrackingActivator
classes.FGBuildableFrackingActivator = nil

--- 
---@class Satis.FGBuildableResourceExtractorBase : Satis.Factory
local FGBuildableResourceExtractorBase

---@class FIN.classes.Satis.FGBuildableResourceExtractorBase : Satis.FGBuildableResourceExtractorBase
classes.FGBuildableResourceExtractorBase = nil

--- Collects pressurized resources when placed on the activated sub-nodes of a Resource Well. Does not require power.<br>
--- <br>
--- Default Extraction Rate: 60 m³ of fluid per minute.<br>
--- Head Lift: 10 m<br>
--- (Allows fluids to be transported 10 meters upwards.)
---@class Satis.Build_FrackingExtractor_C : Satis.FGBuildableFrackingExtractor
local Build_FrackingExtractor_C

---@class FIN.classes.Satis.Build_FrackingExtractor_C : Satis.Build_FrackingExtractor_C
classes.Build_FrackingExtractor_C = nil

--- 
---@class Satis.FGBuildableFrackingExtractor : Satis.FGBuildableResourceExtractor
local FGBuildableFrackingExtractor

---@class FIN.classes.Satis.FGBuildableFrackingExtractor : Satis.FGBuildableFrackingExtractor
classes.FGBuildableFrackingExtractor = nil

--- 
---@class Satis.FGBuildableResourceExtractor : Satis.FGBuildableResourceExtractorBase
local FGBuildableResourceExtractor

---@class FIN.classes.Satis.FGBuildableResourceExtractor : Satis.FGBuildableResourceExtractor
classes.FGBuildableResourceExtractor = nil

--- Extracts water from the body of water it is built on.<br>
--- Note: the water needs to be sufficiently deep, and rivers are generally not deep enough.<br>
--- <br>
--- Default Extraction Rate: 120 m³ of water per minute.<br>
--- Head Lift: 10 m<br>
--- (Allows fluids to be transported 10 meters upwards.)
---@class Satis.Build_WaterPump_C : Satis.FGBuildableWaterPump
local Build_WaterPump_C

---@class FIN.classes.Satis.Build_WaterPump_C : Satis.Build_WaterPump_C
classes.Build_WaterPump_C = nil

--- 
---@class Satis.FGBuildableWaterPump : Satis.FGBuildableResourceExtractor
local FGBuildableWaterPump

---@class FIN.classes.Satis.FGBuildableWaterPump : Satis.FGBuildableWaterPump
classes.FGBuildableWaterPump = nil

--- Extracts solid resources from the resource node it is built on. <br>
--- Default extraction rate is 60 resources per minute. <br>
--- Extraction rate varies based on resource node purity. Outputs all extracted resources onto connected Conveyor Belts.
---@class Satis.Build_MinerMk1_C : Satis.FGBuildableResourceExtractor
local Build_MinerMk1_C

---@class FIN.classes.Satis.Build_MinerMk1_C : Satis.Build_MinerMk1_C
classes.Build_MinerMk1_C = nil

--- Extracts solid resources from the resource node it is built on. <br>
--- Default extraction rate is 120 resources per minute. <br>
--- Extraction rate varies based on resource node purity. Outputs all extracted resources onto connected Conveyor Belts.
---@class Satis.Build_MinerMk2_C : Satis.FGBuildableResourceExtractor
local Build_MinerMk2_C

---@class FIN.classes.Satis.Build_MinerMk2_C : Satis.Build_MinerMk2_C
classes.Build_MinerMk2_C = nil

--- Extracts solid resources from the resource node it is built on. <br>
--- Default extraction rate is 240 resources per minute. <br>
--- Extraction rate varies based on resource node purity. Outputs all extracted resources onto connected Conveyor Belts.
---@class Satis.Build_MinerMk3_C : Satis.Build_MinerMk2_C
local Build_MinerMk3_C

---@class FIN.classes.Satis.Build_MinerMk3_C : Satis.Build_MinerMk3_C
classes.Build_MinerMk3_C = nil

--- Extracts Crude Oil when built on an oil node. Extraction rates vary based on node purity.<br>
--- <br>
--- Default Extraction Rate: 120 m³ of oil per minute.<br>
--- Head Lift: 10 m<br>
--- (Allows fluids to be transported 10 meters upwards.)
---@class Satis.Build_OilPump_C : Satis.FGBuildableResourceExtractor
local Build_OilPump_C

---@class FIN.classes.Satis.Build_OilPump_C : Satis.Build_OilPump_C
classes.Build_OilPump_C = nil

--- 
---@class Satis.FGBuildableGeneratorFuel : Satis.FGBuildableGenerator
local FGBuildableGeneratorFuel

---@class FIN.classes.Satis.FGBuildableGeneratorFuel : Satis.FGBuildableGeneratorFuel
classes.FGBuildableGeneratorFuel = nil

--- 
---@class Satis.FGBuildableGenerator : Satis.Factory
local FGBuildableGenerator

---@class FIN.classes.Satis.FGBuildableGenerator : Satis.FGBuildableGenerator
classes.FGBuildableGenerator = nil

--- 
---@class Satis.FGBuildableGeneratorNuclear : Satis.FGBuildableGeneratorFuel
local FGBuildableGeneratorNuclear

---@class FIN.classes.Satis.FGBuildableGeneratorNuclear : Satis.FGBuildableGeneratorNuclear
classes.FGBuildableGeneratorNuclear = nil

--- Consumes Nuclear Fuel Rods and Water to produce electricity for the power grid.<br>
--- <br>
--- Produces Nuclear Waste, which is extracted via the Conveyor Belt output.<br>
--- <br>
--- Caution: Always generates power at the set clock speed. Shuts down if fuel requirements are not met.
---@class Satis.Build_GeneratorNuclear_C : Satis.FGBuildableGeneratorNuclear
local Build_GeneratorNuclear_C

---@class FIN.classes.Satis.Build_GeneratorNuclear_C : Satis.Build_GeneratorNuclear_C
classes.Build_GeneratorNuclear_C = nil

--- Burns Biomass to produce power. Biomass must be loaded manually and can be obtained by picking up flora in the world.<br>
--- <br>
--- Produces up to 20 MW of power while operating.
---@class Satis.Build_GeneratorIntegratedBiomass_C : Satis.FGBuildableGeneratorFuel
local Build_GeneratorIntegratedBiomass_C

---@class FIN.classes.Satis.Build_GeneratorIntegratedBiomass_C : Satis.Build_GeneratorIntegratedBiomass_C
classes.Build_GeneratorIntegratedBiomass_C = nil

--- Burns various forms of Biomass to generate electricity for the power grid.<br>
--- Has a Conveyor Belt input port that allows the Biomass supply to be automated.<br>
--- <br>
--- Resource consumption will automatically be lowered to meet power demands.
---@class Satis.Build_GeneratorBiomass_C : Satis.FGBuildableGeneratorFuel
local Build_GeneratorBiomass_C

---@class FIN.classes.Satis.Build_GeneratorBiomass_C : Satis.Build_GeneratorBiomass_C
classes.Build_GeneratorBiomass_C = nil

--- Burns various forms of Biomass to generate electricity for the power grid.<br>
--- Has a Conveyor Belt input port that allows the Biomass supply to be automated.<br>
--- <br>
--- Resource consumption will automatically be lowered to meet power demands.
---@class Satis.Build_GeneratorBiomass_Automated_C : Satis.FGBuildableGeneratorFuel
local Build_GeneratorBiomass_Automated_C

---@class FIN.classes.Satis.Build_GeneratorBiomass_Automated_C : Satis.Build_GeneratorBiomass_Automated_C
classes.Build_GeneratorBiomass_Automated_C = nil

--- Burns Coal to boil Water. The steam produced rotates turbines that generate electricity for the power grid.<br>
--- Has Conveyor Belt and Pipeline input ports that allow the Coal and Water supply to be automated.<br>
--- <br>
--- Caution: Always generates power at the set clock speed. Shuts down if fuel requirements are not met.
---@class Satis.Build_GeneratorCoal_C : Satis.FGBuildableGeneratorFuel
local Build_GeneratorCoal_C

---@class FIN.classes.Satis.Build_GeneratorCoal_C : Satis.Build_GeneratorCoal_C
classes.Build_GeneratorCoal_C = nil

--- Consumes Fuel to generate electricity for the power grid.<br>
--- Has a Pipeline input port that allows the Fuel supply to be automated.<br>
--- <br>
--- Caution: Always generates power at the set clock speed. Shuts down if fuel requirements are not met.
---@class Satis.Build_GeneratorFuel_C : Satis.FGBuildableGeneratorFuel
local Build_GeneratorFuel_C

---@class FIN.classes.Satis.Build_GeneratorFuel_C : Satis.Build_GeneratorFuel_C
classes.Build_GeneratorFuel_C = nil

--- 
---@class Satis.FGBuildableGeneratorGeoThermal : Satis.FGBuildableGenerator
local FGBuildableGeneratorGeoThermal

---@class FIN.classes.Satis.FGBuildableGeneratorGeoThermal : Satis.FGBuildableGeneratorGeoThermal
classes.FGBuildableGeneratorGeoThermal = nil

--- Harnesses geothermal energy to generate power. Must be built on a Geyser.<br>
--- <br>
--- Caution: Power production fluctuates.<br>
--- <br>
--- Power Production:<br>
--- Impure Geyser: 50-150 MW (100 MW average)<br>
--- Normal Geyser: 100-300 MW (200 MW average)<br>
--- Pure Geyser: 200-600 MW (400 MW average)
---@class Satis.Build_GeneratorGeoThermal_C : Satis.FGBuildableGeneratorGeoThermal
local Build_GeneratorGeoThermal_C

---@class FIN.classes.Satis.Build_GeneratorGeoThermal_C : Satis.Build_GeneratorGeoThermal_C
classes.Build_GeneratorGeoThermal_C = nil

--- 
---@class Satis.FGBuildableJumppad : Satis.Factory
local FGBuildableJumppad

---@class FIN.classes.Satis.FGBuildableJumppad : Satis.FGBuildableJumppad
classes.FGBuildableJumppad = nil

--- Launches pioneers for quick, vertical traversal.<br>
--- The launch angle can be adjusted while building.<br>
--- Caution: Be sure to land safely!
---@class Satis.Build_JumpPadAdjustable_C : Satis.FGBuildableJumppad
local Build_JumpPadAdjustable_C

---@class FIN.classes.Satis.Build_JumpPadAdjustable_C : Satis.Build_JumpPadAdjustable_C
classes.Build_JumpPadAdjustable_C = nil

--- 
---@class Satis.FGBuildablePipeHyperBooster : Satis.FGBuildablePipeHyperAttachment
local FGBuildablePipeHyperBooster

---@class FIN.classes.Satis.FGBuildablePipeHyperBooster : Satis.FGBuildablePipeHyperBooster
classes.FGBuildablePipeHyperBooster = nil

--- 
---@class Satis.FGBuildablePipeHyperAttachment : Satis.Factory
local FGBuildablePipeHyperAttachment

---@class FIN.classes.Satis.FGBuildablePipeHyperAttachment : Satis.FGBuildablePipeHyperAttachment
classes.FGBuildablePipeHyperAttachment = nil

--- 
---@class Satis.FGBuildablePipeHyperJunction : Satis.FGBuildablePipeHyperAttachment
local FGBuildablePipeHyperJunction

---@class FIN.classes.Satis.FGBuildablePipeHyperJunction : Satis.FGBuildablePipeHyperJunction
classes.FGBuildablePipeHyperJunction = nil

--- 
---@class Satis.FGBuildablePipelineAttachment : Satis.Factory
local FGBuildablePipelineAttachment

---@class FIN.classes.Satis.FGBuildablePipelineAttachment : Satis.FGBuildablePipelineAttachment
classes.FGBuildablePipelineAttachment = nil

--- 
---@class Satis.FGBuildablePipelineJunction : Satis.FGBuildablePipelineAttachment
local FGBuildablePipelineJunction

---@class FIN.classes.Satis.FGBuildablePipelineJunction : Satis.FGBuildablePipelineJunction
classes.FGBuildablePipelineJunction = nil

--- Attaches to a Pipeline, allowing it to be split up to 4 ways.
---@class Satis.Build_PipelineJunction_Cross_C : Satis.FGBuildablePipelineJunction
local Build_PipelineJunction_Cross_C

---@class FIN.classes.Satis.Build_PipelineJunction_Cross_C : Satis.Build_PipelineJunction_Cross_C
classes.Build_PipelineJunction_Cross_C = nil

--- A building that can pump fluids to a higher level within a pipeline.
---@class Satis.PipelinePump : Satis.FGBuildablePipelineAttachment
local PipelinePump

---@class FIN.classes.Satis.PipelinePump : Satis.PipelinePump
classes.PipelinePump = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipelinePump.maxHeadlift = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipelinePump.designedHeadlift = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipelinePump.indicatorHeadlift = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipelinePump.indicatorHeadliftPct = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
PipelinePump.userFlowLimit = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipelinePump.flowLimit = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipelinePump.flowLimitPct = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipelinePump.flow = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipelinePump.flowPct = nil

--- Can be attached to a Pipeline to apply Head Lift.<br>
--- Maximum Head Lift: 50 m<br>
--- (Allows fluids to be transported 50 meters upwards.)<br>
--- <br>
--- NOTE: Arrows and holograms when building indicate Head Lift direction.<br>
--- NOTE: Head Lift does not stack, so space between Pumps is recommended.
---@class Satis.Build_PipelinePumpMk2_C : Satis.PipelinePump
local Build_PipelinePumpMk2_C

---@class FIN.classes.Satis.Build_PipelinePumpMk2_C : Satis.Build_PipelinePumpMk2_C
classes.Build_PipelinePumpMk2_C = nil

--- A pump with a configurable head lift.
---@class Satis.Build_CheatFluidPump_C : Satis.Build_PipelinePumpMk2_C
local Build_CheatFluidPump_C

---@class FIN.classes.Satis.Build_CheatFluidPump_C : Satis.Build_CheatFluidPump_C
classes.Build_CheatFluidPump_C = nil

--- Attaches to a Pipeline to apply Head Lift.<br>
--- Maximum Head Lift: 20 m<br>
--- (Allows fluids to be transported 20 m upwards.)<br>
--- <br>
--- NOTE: Arrows and holograms when building indicate Head Lift direction.<br>
--- NOTE: Head Lift does not stack, so space between Pumps is recommended.
---@class Satis.Build_PipelinePump_C : Satis.PipelinePump
local Build_PipelinePump_C

---@class FIN.classes.Satis.Build_PipelinePump_C : Satis.Build_PipelinePump_C
classes.Build_PipelinePump_C = nil

--- Limits Pipeline flow rates.<br>
--- Can be attached to a Pipeline.<br>
--- <br>
--- NOTE: Has an in- and output direction.
---@class Satis.Build_Valve_C : Satis.PipelinePump
local Build_Valve_C

---@class FIN.classes.Satis.Build_Valve_C : Satis.Build_Valve_C
classes.Build_Valve_C = nil

--- 
---@class Satis.FGBuildablePipePart : Satis.Factory
local FGBuildablePipePart

---@class FIN.classes.Satis.FGBuildablePipePart : Satis.FGBuildablePipePart
classes.FGBuildablePipePart = nil

--- 
---@class Satis.FGBuildablePipeHyperPart : Satis.FGBuildablePipePart
local FGBuildablePipeHyperPart

---@class FIN.classes.Satis.FGBuildablePipeHyperPart : Satis.FGBuildablePipeHyperPart
classes.FGBuildablePipeHyperPart = nil

--- A actor that is a hypertube entrance buildable
---@class Satis.PipeHyperStart : Satis.FGBuildablePipeHyperPart
local PipeHyperStart

---@class FIN.classes.Satis.PipeHyperStart : Satis.PipeHyperStart
classes.PipeHyperStart = nil

--- Triggers when a players enters into this hypertube entrance.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Sucess = event.pull()
--- ```
--- - `signalName: "PlayerEntered"`
--- - `component: PipeHyperStart`
--- - `Sucess: boolean` <br>
--- True if the transfer was sucessfull
---@deprecated
---@type FIN.Signal
PipeHyperStart.SIGNAL_PlayerEntered = nil

--- Triggers when a players leaves through this hypertube entrance.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component = event.pull()
--- ```
--- - `signalName: "PlayerExited"`
--- - `component: PipeHyperStart`
---@deprecated
---@type FIN.Signal
PipeHyperStart.SIGNAL_PlayerExited = nil

--- Powers up a Hypertube system and allows it to be entered.
---@class Satis.Build_PipeHyperStart_C : Satis.PipeHyperStart
local Build_PipeHyperStart_C

---@class FIN.classes.Satis.Build_PipeHyperStart_C : Satis.Build_PipeHyperStart_C
classes.Build_PipeHyperStart_C = nil

--- The base class for all fluid tanks.
---@class Satis.PipeReservoir : Satis.Factory
local PipeReservoir

---@class FIN.classes.Satis.PipeReservoir : Satis.PipeReservoir
classes.PipeReservoir = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipeReservoir.fluidContent = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipeReservoir.maxFluidContent = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipeReservoir.flowFill = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipeReservoir.flowDrain = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PipeReservoir.flowLimit = nil

--- Emptys the whole fluid container.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function PipeReservoir:flush() end

--- Returns the type of the fluid.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.ItemType type The type of the fluid the tank contains.
function PipeReservoir:getFluidType() end

--- Holds up to 2400 m³ of fluid.<br>
--- Has Pipeline input and output ports.
---@class Satis.Build_IndustrialTank_C : Satis.PipeReservoir
local Build_IndustrialTank_C

---@class FIN.classes.Satis.Build_IndustrialTank_C : Satis.Build_IndustrialTank_C
classes.Build_IndustrialTank_C = nil

--- Holds up to 400 m³ of fluid.<br>
--- Has Pipeline input and output ports.
---@class Satis.Build_PipeStorageTank_C : Satis.PipeReservoir
local Build_PipeStorageTank_C

---@class FIN.classes.Satis.Build_PipeStorageTank_C : Satis.Build_PipeStorageTank_C
classes.Build_PipeStorageTank_C = nil

--- 
---@class Satis.FGBuildablePortal : Satis.FGBuildablePortalBase
local FGBuildablePortal

---@class FIN.classes.Satis.FGBuildablePortal : Satis.FGBuildablePortal
classes.FGBuildablePortal = nil

--- 
---@class Satis.FGBuildablePortalBase : Satis.Factory
local FGBuildablePortalBase

---@class FIN.classes.Satis.FGBuildablePortalBase : Satis.FGBuildablePortalBase
classes.FGBuildablePortalBase = nil

--- Enables pioneer teleportation between two linked Portals.<br>
--- <br>
--- Each Portal can only have a single link. <br>
--- A link can only be made between a Main and Satellite Portal.<br>
--- <br>
--- Singularity Cells need to be supplied to the Main Portal and will be consumed to establish and maintain the Portal link.<br>
--- <br>
--- WARNINGS:<br>
--- - Massive power draw will occur during start-up and usage.<br>
--- - Power draw on use increases with travel distance.<br>
--- - Link start-up will take time. Letting the connection expire is not recommended.<br>
--- - Failure to deliver sufficient Singularity Cells will cause the link to expire.<br>
--- - FICSIT does not condone the use of wormhole technology. Any usage of wormhole technology is at the user's own risk.
---@class Satis.Build_Portal_C : Satis.FGBuildablePortal
local Build_Portal_C

---@class FIN.classes.Satis.Build_Portal_C : Satis.Build_Portal_C
classes.Build_Portal_C = nil

--- 
---@class Satis.FGBuildablePortalSatellite : Satis.FGBuildablePortalBase
local FGBuildablePortalSatellite

---@class FIN.classes.Satis.FGBuildablePortalSatellite : Satis.FGBuildablePortalSatellite
classes.FGBuildablePortalSatellite = nil

--- Enables pioneer teleportation between two linked Portals.<br>
--- <br>
--- Each Portal can only have a single link. <br>
--- A link can only be made between a Main and Satellite Portal.<br>
--- <br>
--- Singularity Cells need to be supplied to the Main Portal and will be consumed to establish and maintain the Portal link.<br>
--- <br>
--- WARNINGS:<br>
--- - Massive power draw will occur during start-up and usage.<br>
--- - Power draw on use increases with travel distance.<br>
--- - Link start-up will take time. Letting the connection expire is not recommended.<br>
--- - Failure to deliver sufficient Singularity Cells will cause the link to expire.<br>
--- - FICSIT does not condone the use of wormhole technology. Any usage of wormhole technology is at the user's own risk.
---@class Satis.Build_PortalSatellite_C : Satis.FGBuildablePortalSatellite
local Build_PortalSatellite_C

---@class FIN.classes.Satis.Build_PortalSatellite_C : Satis.Build_PortalSatellite_C
classes.Build_PortalSatellite_C = nil

--- 
---@class Satis.FGBuildablePowerBooster : Satis.Factory
local FGBuildablePowerBooster

---@class FIN.classes.Satis.FGBuildablePowerBooster : Satis.FGBuildablePowerBooster
classes.FGBuildablePowerBooster = nil

--- Generates power based on the total amount of power on the attached power grid.<br>
--- <br>
--- This experimental technology is somehow able to extract power from the Somersloop by blasting it with energy.
---@class Satis.Build_AlienPowerBuilding_C : Satis.FGBuildablePowerBooster
local Build_AlienPowerBuilding_C

---@class FIN.classes.Satis.Build_AlienPowerBuilding_C : Satis.Build_AlienPowerBuilding_C
classes.Build_AlienPowerBuilding_C = nil

--- A building that can store power for later usage.
---@class Satis.PowerStorage : Satis.Factory
local PowerStorage

---@class FIN.classes.Satis.PowerStorage : Satis.PowerStorage
classes.PowerStorage = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerStorage.powerStore = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerStorage.powerCapacity = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerStorage.powerStorePercent = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerStorage.powerIn = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerStorage.powerOut = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerStorage.timeUntilFull = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerStorage.timeUntilEmpty = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerStorage.batteryStatus = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerStorage.batteryMaxIndicatorLevel = nil

--- Connects to a power grid to store excess power produced. The stored power can be harnessed if power grid consumption exceeds production.<br>
--- <br>
--- Storage Capacity: 100 MWh (100 MW for 1 hour)<br>
--- Maximum Charge Rate: 100 MW<br>
--- Maximum Discharge Rate: Unlimited
---@class Satis.Build_PowerStorageMk1_C : Satis.PowerStorage
local Build_PowerStorageMk1_C

---@class FIN.classes.Satis.Build_PowerStorageMk1_C : Satis.Build_PowerStorageMk1_C
classes.Build_PowerStorageMk1_C = nil

--- 
---@class Satis.FGBuildableRadarTower : Satis.Factory
local FGBuildableRadarTower

---@class FIN.classes.Satis.FGBuildableRadarTower : Satis.FGBuildableRadarTower
classes.FGBuildableRadarTower = nil

--- Scans the surrounding area to display additional information on the Map.<br>
--- <br>
--- Information revealed on the Map includes:<br>
--- - Resource node locations<br>
--- - Terrain data<br>
--- - Flora & fauna information<br>
--- - Notable signal readings
---@class Satis.Build_RadarTower_C : Satis.FGBuildableRadarTower
local Build_RadarTower_C

---@class FIN.classes.Satis.Build_RadarTower_C : Satis.Build_RadarTower_C
classes.Build_RadarTower_C = nil

--- The base class for all train station parts.
---@class Satis.TrainPlatform : Satis.Factory
local TrainPlatform

---@class FIN.classes.Satis.TrainPlatform : Satis.TrainPlatform
classes.TrainPlatform = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
TrainPlatform.status = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
TrainPlatform.isReversed = nil

--- Returns the track graph of which this platform is part of.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.TrackGraph graph The track graph of which this platform is part of.
function TrainPlatform:getTrackGraph() end

--- Returns the track pos at which this train platform is placed.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadTrack track The track the track pos points to.
---@return number offset The offset of the track pos.
---@return number forward The forward direction of the track pos. 1 = with the track direction, -1 = against the track direction
function TrainPlatform:getTrackPos() end

--- Returns the connected platform in the given direction.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param platformConnection Satis.TrainPlatformConnection The platform connection of which you want to find the opposite connection of.
---@return Satis.TrainPlatformConnection oppositeConnection The platform connection at the opposite side.
function TrainPlatform:getConnectedPlatform(platformConnection) end

--- Returns a list of all connected platforms in order.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.TrainPlatformConnection[] platforms The list of connected platforms
function TrainPlatform:getAllConnectedPlatforms() end

--- Returns the currently docked vehicle.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Vehicle vehicle The currently docked vehicle
function TrainPlatform:getDockedVehicle() end

--- Returns the master platform of this train station.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadVehicle master The master platform of this train station.
function TrainPlatform:getMaster() end

--- Returns the currently docked locomotive at the train station.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadVehicle locomotive The currently docked locomotive at the train station.
function TrainPlatform:getDockedLocomotive() end

--- The train station master platform. This platform holds the name and manages docking of trains.
---@class Satis.RailroadStation : Satis.TrainPlatform
local RailroadStation

---@class FIN.classes.Satis.RailroadStation : Satis.RailroadStation
classes.RailroadStation = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type string
RailroadStation.name = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadStation.dockedOffset = nil

--- Triggers when a train tries to dock onto the station.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Successful, Locomotive, Offset = event.pull()
--- ```
--- - `signalName: "StartDocking"`
--- - `component: RailroadStation`
--- - `Successful: boolean` <br>
--- True if the train successfully docked.
--- - `Locomotive: Satis.RailroadVehicle` <br>
--- The locomotive that tries to dock onto the station.
--- - `Offset: number` <br>
--- The offset at witch the train tried to dock.
---@deprecated
---@type FIN.Signal
RailroadStation.SIGNAL_StartDocking = nil

--- Triggers when a train finished the docking procedure and is ready to depart the station.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component = event.pull()
--- ```
--- - `signalName: "FinishDocking"`
--- - `component: RailroadStation`
---@deprecated
---@type FIN.Signal
RailroadStation.SIGNAL_FinishDocking = nil

--- Triggers when a train cancels the docking procedure.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component = event.pull()
--- ```
--- - `signalName: "CancelDocking"`
--- - `component: RailroadStation`
---@deprecated
---@type FIN.Signal
RailroadStation.SIGNAL_CancelDocking = nil

--- Serves as a hub for Locomotives, which can be set to navigate to and stop at a Train Station.<br>
--- You can connect power to a Train Station to power up the trains on the Railway as well as feed power to other stations.
---@class Satis.Build_TrainStation_C : Satis.RailroadStation
local Build_TrainStation_C

---@class FIN.classes.Satis.Build_TrainStation_C : Satis.Build_TrainStation_C
classes.Build_TrainStation_C = nil

--- A train platform that allows for loading and unloading cargo cars.
---@class Satis.TrainPlatformCargo : Satis.TrainPlatform
local TrainPlatformCargo

---@class FIN.classes.Satis.TrainPlatformCargo : Satis.TrainPlatformCargo
classes.TrainPlatformCargo = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
TrainPlatformCargo.isLoading = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
TrainPlatformCargo.isInLoadMode = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
TrainPlatformCargo.isUnloading = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
TrainPlatformCargo.dockedOffset = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
TrainPlatformCargo.outputFlow = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
TrainPlatformCargo.inputFlow = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
TrainPlatformCargo.fullLoad = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
TrainPlatformCargo.fullUnload = nil

--- Loads and unloads Freight Cars that stop at the Freight Platform.<br>
--- Loading and unloading options can be set by configuring the building.<br>
--- Snaps to other Platforms and Stations.<br>
--- Needs to be connected to a powered Railway to function.
---@class Satis.Build_TrainDockingStation_C : Satis.TrainPlatformCargo
local Build_TrainDockingStation_C

---@class FIN.classes.Satis.Build_TrainDockingStation_C : Satis.Build_TrainDockingStation_C
classes.Build_TrainDockingStation_C = nil

--- Loads and unloads Freight Cars that stop at the Freight Platform.<br>
--- Loading and unloading options can be set by configuring the building.<br>
--- Snaps to other Platforms and Stations.<br>
--- Needs to be connected to a powered Railway to function.
---@class Satis.Build_TrainDockingStationLiquid_C : Satis.TrainPlatformCargo
local Build_TrainDockingStationLiquid_C

---@class FIN.classes.Satis.Build_TrainDockingStationLiquid_C : Satis.Build_TrainDockingStationLiquid_C
classes.Build_TrainDockingStationLiquid_C = nil

--- 
---@class Satis.FGBuildableTrainPlatformEmpty : Satis.TrainPlatform
local FGBuildableTrainPlatformEmpty

---@class FIN.classes.Satis.FGBuildableTrainPlatformEmpty : Satis.FGBuildableTrainPlatformEmpty
classes.FGBuildableTrainPlatformEmpty = nil

--- Creates empty space where necessary.
---@class Satis.Build_TrainPlatformEmpty_C : Satis.FGBuildableTrainPlatformEmpty
local Build_TrainPlatformEmpty_C

---@class FIN.classes.Satis.Build_TrainPlatformEmpty_C : Satis.Build_TrainPlatformEmpty_C
classes.Build_TrainPlatformEmpty_C = nil

--- Creates empty space where necessary.
---@class Satis.Build_TrainPlatformEmpty_02_C : Satis.FGBuildableTrainPlatformEmpty
local Build_TrainPlatformEmpty_02_C

---@class FIN.classes.Satis.Build_TrainPlatformEmpty_02_C : Satis.Build_TrainPlatformEmpty_02_C
classes.Build_TrainPlatformEmpty_02_C = nil

--- The resource sink, also known a A.W.E.S.O.M.E Sink
---@class Satis.ResourceSink : Satis.Factory
local ResourceSink

---@class FIN.classes.Satis.ResourceSink : Satis.ResourceSink
classes.ResourceSink = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
ResourceSink.numPoints = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
ResourceSink.numCoupons = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
ResourceSink.numPointsToNextCoupon = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
ResourceSink.couponProgress = nil

--- Got excess resources? Fear not, for FICSIT does not waste! The newly developed AWESOME Sink turns any and all useful parts into research data just as fast as you can supply them! <br>
--- Participating pioneers will be compensated with Coupons that can be spent at the AWESOME Shop.
---@class Satis.Build_ResourceSink_C : Satis.ResourceSink
local Build_ResourceSink_C

---@class FIN.classes.Satis.Build_ResourceSink_C : Satis.Build_ResourceSink_C
classes.Build_ResourceSink_C = nil

--- 
---@class Satis.FGBuildableResourceSinkShop : Satis.Factory
local FGBuildableResourceSinkShop

---@class FIN.classes.Satis.FGBuildableResourceSinkShop : Satis.FGBuildableResourceSinkShop
classes.FGBuildableResourceSinkShop = nil

--- Redeem your FICSIT Coupons here! <br>
--- For those employees going the extra kilometer we have set aside special bonus milestones and rewards! Get your Coupons in the AWESOME Sink program now!<br>
--- <br>
--- *No refunds possible.
---@class Satis.Build_ResourceSinkShop_C : Satis.FGBuildableResourceSinkShop
local Build_ResourceSinkShop_C

---@class FIN.classes.Satis.Build_ResourceSinkShop_C : Satis.Build_ResourceSinkShop_C
classes.Build_ResourceSinkShop_C = nil

--- 
---@class Satis.FGBuildableSpaceElevator : Satis.Factory
local FGBuildableSpaceElevator

---@class FIN.classes.Satis.FGBuildableSpaceElevator : Satis.FGBuildableSpaceElevator
classes.FGBuildableSpaceElevator = nil

--- Requires deliveries of special Project Parts to complete Project Assembly Phases.<br>
--- Completing these Phases will unlock new Tiers in the HUB Terminal.
---@class Satis.Build_SpaceElevator_C : Satis.FGBuildableSpaceElevator
local Build_SpaceElevator_C

---@class FIN.classes.Satis.Build_SpaceElevator_C : Satis.Build_SpaceElevator_C
classes.Build_SpaceElevator_C = nil

--- The container that allows you to upload items to the dimensional depot. The dimensional depot is also known as central storage.
---@class Satis.DimensionalDepotUploader : Satis.FGBuildableStorage
local DimensionalDepotUploader

---@class FIN.classes.Satis.DimensionalDepotUploader : Satis.DimensionalDepotUploader
classes.DimensionalDepotUploader = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
DimensionalDepotUploader.isUploadingToCentralStorage = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
DimensionalDepotUploader.centralStorageUploadProgress = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
DimensionalDepotUploader.isUploadInventoryEmpty = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Satis.DimensionalDepot
DimensionalDepotUploader.centralStorage = nil

--- 
---@class Satis.FGBuildableStorage : Satis.Factory
local FGBuildableStorage

---@class FIN.classes.Satis.FGBuildableStorage : Satis.FGBuildableStorage
classes.FGBuildableStorage = nil

--- The Dimensional Depot Uploader is used to upload resources to a dimensional storage deposit.<br>
--- From here resources can be used by the Build Gun and Crafting Stations, as if they were in the pioneer Inventory.
---@class Satis.Build_CentralStorage_C : Satis.DimensionalDepotUploader
local Build_CentralStorage_C

---@class FIN.classes.Satis.Build_CentralStorage_C : Satis.Build_CentralStorage_C
classes.Build_CentralStorage_C = nil

--- Contains 25 slots for storing large amounts of items.
---@class Satis.Build_StorageIntegrated_C : Satis.FGBuildableStorage
local Build_StorageIntegrated_C

---@class FIN.classes.Satis.Build_StorageIntegrated_C : Satis.Build_StorageIntegrated_C
classes.Build_StorageIntegrated_C = nil

--- Contains 24 slots for storing large amounts of items.<br>
--- Has 1 Conveyor Belt input port and 1 Conveyor Belt output port.
---@class Satis.Build_StorageContainerMk1_C : Satis.FGBuildableStorage
local Build_StorageContainerMk1_C

---@class FIN.classes.Satis.Build_StorageContainerMk1_C : Satis.Build_StorageContainerMk1_C
classes.Build_StorageContainerMk1_C = nil

--- Contains 48 slots for storing large amounts of items.<br>
--- Has 2 Conveyor Belt input ports and 2 Conveyor Belt output ports.
---@class Satis.Build_StorageContainerMk2_C : Satis.FGBuildableStorage
local Build_StorageContainerMk2_C

---@class FIN.classes.Satis.Build_StorageContainerMk2_C : Satis.Build_StorageContainerMk2_C
classes.Build_StorageContainerMk2_C = nil

--- Blueprint Storage that parts are returned to when the Blueprint Designer is cleared.<br>
--- <br>
--- 40 slots.
---@class Satis.Build_StorageBlueprint_C : Satis.FGBuildableStorage
local Build_StorageBlueprint_C

---@class FIN.classes.Satis.Build_StorageBlueprint_C : Satis.Build_StorageBlueprint_C
classes.Build_StorageBlueprint_C = nil

--- Contains 25 slots for storing large amounts of items.
---@class Satis.Build_StorageHazard_C : Satis.FGBuildableStorage
local Build_StorageHazard_C

---@class FIN.classes.Satis.Build_StorageHazard_C : Satis.Build_StorageHazard_C
classes.Build_StorageHazard_C = nil

--- Contains 25 slots for storing large amounts of items.
---@class Satis.Build_StorageMedkit_C : Satis.FGBuildableStorage
local Build_StorageMedkit_C

---@class FIN.classes.Satis.Build_StorageMedkit_C : Satis.Build_StorageMedkit_C
classes.Build_StorageMedkit_C = nil

--- Contains 25 slots for storing large amounts of items.
---@class Satis.Build_StoragePlayer_C : Satis.FGBuildableStorage
local Build_StoragePlayer_C

---@class FIN.classes.Satis.Build_StoragePlayer_C : Satis.Build_StoragePlayer_C
classes.Build_StoragePlayer_C = nil

--- The heart of your factory. This is where you complete FICSIT milestones to unlock additional schematics for buildings, vehicles, parts, equipment, etc.
---@class Satis.Build_TradingPost_C : Satis.FGBuildableTradingPost
local Build_TradingPost_C

---@class FIN.classes.Satis.Build_TradingPost_C : Satis.Build_TradingPost_C
classes.Build_TradingPost_C = nil

--- 
---@class Satis.FGBuildableTradingPost : Satis.Factory
local FGBuildableTradingPost

---@class FIN.classes.Satis.FGBuildableTradingPost : Satis.FGBuildableTradingPost
classes.FGBuildableTradingPost = nil

--- 
---@class Satis.Build_CheatPowerSource_C : Satis.Factory
local Build_CheatPowerSource_C

---@class FIN.classes.Satis.Build_CheatPowerSource_C : Satis.Build_CheatPowerSource_C
classes.Build_CheatPowerSource_C = nil

--- 
---@class Satis.Build_CheatPowerSink_C : Satis.Factory
local Build_CheatPowerSink_C

---@class FIN.classes.Satis.Build_CheatPowerSink_C : Satis.Build_CheatPowerSink_C
classes.Build_CheatPowerSink_C = nil

--- Propels you upwards through the air.<br>
--- Make sure you land softly.
---@class Satis.Build_JumpPad_C : Satis.Factory
local Build_JumpPad_C

---@class FIN.classes.Satis.Build_JumpPad_C : Satis.Build_JumpPad_C
classes.Build_JumpPad_C = nil

--- Propels you forwards through the air.<br>
--- Make sure you land softly.
---@class Satis.Build_JumpPadTilted_C : Satis.Build_JumpPad_C
local Build_JumpPadTilted_C

---@class FIN.classes.Satis.Build_JumpPadTilted_C : Satis.Build_JumpPadTilted_C
classes.Build_JumpPadTilted_C = nil

--- Generates a speed-dampening jelly.<br>
--- Guarantees a safe landing.
---@class Satis.Build_LandingPad_C : Satis.Factory
local Build_LandingPad_C

---@class FIN.classes.Satis.Build_LandingPad_C : Satis.Build_LandingPad_C
classes.Build_LandingPad_C = nil

--- 
---@class Satis.FGBuildableBeam : Satis.FGBuildableFactoryBuilding
local FGBuildableBeam

---@class FIN.classes.Satis.FGBuildableBeam : Satis.FGBuildableBeam
classes.FGBuildableBeam = nil

--- 
---@class Satis.FGBuildableFactoryBuilding : Satis.Buildable
local FGBuildableFactoryBuilding

---@class FIN.classes.Satis.FGBuildableFactoryBuilding : Satis.FGBuildableFactoryBuilding
classes.FGBuildableFactoryBuilding = nil

--- 
---@class Satis.FGBuildableBeamLightweight : Satis.FGBuildableBeam
local FGBuildableBeamLightweight

---@class FIN.classes.Satis.FGBuildableBeamLightweight : Satis.FGBuildableBeamLightweight
classes.FGBuildableBeamLightweight = nil

--- Snaps to other Beams and various other structural buildings.<br>
--- Beams support multiple build modes for different use cases.
---@class Satis.Build_Beam_Painted_C : Satis.FGBuildableBeamLightweight
local Build_Beam_Painted_C

---@class FIN.classes.Satis.Build_Beam_Painted_C : Satis.Build_Beam_Painted_C
classes.Build_Beam_Painted_C = nil

--- Snaps to other Beams and various other structural buildings.<br>
--- Beams support multiple build modes for different use cases.
---@class Satis.Build_Beam_C : Satis.FGBuildableBeamLightweight
local Build_Beam_C

---@class FIN.classes.Satis.Build_Beam_C : Satis.Build_Beam_C
classes.Build_Beam_C = nil

--- 
---@class Satis.FGBuildableCornerWall : Satis.FGBuildableFactoryBuilding
local FGBuildableCornerWall

---@class FIN.classes.Satis.FGBuildableCornerWall : Satis.FGBuildableCornerWall
classes.FGBuildableCornerWall = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Roof_Metal_InCorner_01_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Metal_InCorner_01_C

---@class FIN.classes.Satis.Build_Roof_Metal_InCorner_01_C : Satis.Build_Roof_Metal_InCorner_01_C
classes.Build_Roof_Metal_InCorner_01_C = nil

--- 
---@class Satis.FGBuildableCornerWallLightweight : Satis.FGBuildableCornerWall
local FGBuildableCornerWallLightweight

---@class FIN.classes.Satis.FGBuildableCornerWallLightweight : Satis.FGBuildableCornerWallLightweight
classes.FGBuildableCornerWallLightweight = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Roof_Metal_InCorner_02_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Metal_InCorner_02_C

---@class FIN.classes.Satis.Build_Roof_Metal_InCorner_02_C : Satis.Build_Roof_Metal_InCorner_02_C
classes.Build_Roof_Metal_InCorner_02_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Roof_Metal_InCorner_03_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Metal_InCorner_03_C

---@class FIN.classes.Satis.Build_Roof_Metal_InCorner_03_C : Satis.Build_Roof_Metal_InCorner_03_C
classes.Build_Roof_Metal_InCorner_03_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Roof_Metal_OutCorner_01_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Metal_OutCorner_01_C

---@class FIN.classes.Satis.Build_Roof_Metal_OutCorner_01_C : Satis.Build_Roof_Metal_OutCorner_01_C
classes.Build_Roof_Metal_OutCorner_01_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Roof_Metal_OutCorner_02_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Metal_OutCorner_02_C

---@class FIN.classes.Satis.Build_Roof_Metal_OutCorner_02_C : Satis.Build_Roof_Metal_OutCorner_02_C
classes.Build_Roof_Metal_OutCorner_02_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Roof_Metal_OutCorner_03_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Metal_OutCorner_03_C

---@class FIN.classes.Satis.Build_Roof_Metal_OutCorner_03_C : Satis.Build_Roof_Metal_OutCorner_03_C
classes.Build_Roof_Metal_OutCorner_03_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Roof_Orange_InCorner_01_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Orange_InCorner_01_C

---@class FIN.classes.Satis.Build_Roof_Orange_InCorner_01_C : Satis.Build_Roof_Orange_InCorner_01_C
classes.Build_Roof_Orange_InCorner_01_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Roof_Orange_InCorner_02_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Orange_InCorner_02_C

---@class FIN.classes.Satis.Build_Roof_Orange_InCorner_02_C : Satis.Build_Roof_Orange_InCorner_02_C
classes.Build_Roof_Orange_InCorner_02_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Roof_Orange_InCorner_03_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Orange_InCorner_03_C

---@class FIN.classes.Satis.Build_Roof_Orange_InCorner_03_C : Satis.Build_Roof_Orange_InCorner_03_C
classes.Build_Roof_Orange_InCorner_03_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Roof_Orange_OutCorner_01_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Orange_OutCorner_01_C

---@class FIN.classes.Satis.Build_Roof_Orange_OutCorner_01_C : Satis.Build_Roof_Orange_OutCorner_01_C
classes.Build_Roof_Orange_OutCorner_01_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Roof_Orange_OutCorner_02_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Orange_OutCorner_02_C

---@class FIN.classes.Satis.Build_Roof_Orange_OutCorner_02_C : Satis.Build_Roof_Orange_OutCorner_02_C
classes.Build_Roof_Orange_OutCorner_02_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Roof_Orange_OutCorner_03_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Orange_OutCorner_03_C

---@class FIN.classes.Satis.Build_Roof_Orange_OutCorner_03_C : Satis.Build_Roof_Orange_OutCorner_03_C
classes.Build_Roof_Orange_OutCorner_03_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Roof_Tar_InCorner_01_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Tar_InCorner_01_C

---@class FIN.classes.Satis.Build_Roof_Tar_InCorner_01_C : Satis.Build_Roof_Tar_InCorner_01_C
classes.Build_Roof_Tar_InCorner_01_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Roof_Tar_InCorner_02_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Tar_InCorner_02_C

---@class FIN.classes.Satis.Build_Roof_Tar_InCorner_02_C : Satis.Build_Roof_Tar_InCorner_02_C
classes.Build_Roof_Tar_InCorner_02_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Roof_Tar_InCorner_03_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Tar_InCorner_03_C

---@class FIN.classes.Satis.Build_Roof_Tar_InCorner_03_C : Satis.Build_Roof_Tar_InCorner_03_C
classes.Build_Roof_Tar_InCorner_03_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Roof_Tar_OutCorner_01_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Tar_OutCorner_01_C

---@class FIN.classes.Satis.Build_Roof_Tar_OutCorner_01_C : Satis.Build_Roof_Tar_OutCorner_01_C
classes.Build_Roof_Tar_OutCorner_01_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Roof_Tar_OutCorner_02_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Tar_OutCorner_02_C

---@class FIN.classes.Satis.Build_Roof_Tar_OutCorner_02_C : Satis.Build_Roof_Tar_OutCorner_02_C
classes.Build_Roof_Tar_OutCorner_02_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Roof_Tar_OutCorner_03_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Tar_OutCorner_03_C

---@class FIN.classes.Satis.Build_Roof_Tar_OutCorner_03_C : Satis.Build_Roof_Tar_OutCorner_03_C
classes.Build_Roof_Tar_OutCorner_03_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Roof_Window_InCorner_01_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Window_InCorner_01_C

---@class FIN.classes.Satis.Build_Roof_Window_InCorner_01_C : Satis.Build_Roof_Window_InCorner_01_C
classes.Build_Roof_Window_InCorner_01_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Roof_Window_InCorner_02_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Window_InCorner_02_C

---@class FIN.classes.Satis.Build_Roof_Window_InCorner_02_C : Satis.Build_Roof_Window_InCorner_02_C
classes.Build_Roof_Window_InCorner_02_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Roof_Window_InCorner_03_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Window_InCorner_03_C

---@class FIN.classes.Satis.Build_Roof_Window_InCorner_03_C : Satis.Build_Roof_Window_InCorner_03_C
classes.Build_Roof_Window_InCorner_03_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Roof_Window_OutCorner_01_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Window_OutCorner_01_C

---@class FIN.classes.Satis.Build_Roof_Window_OutCorner_01_C : Satis.Build_Roof_Window_OutCorner_01_C
classes.Build_Roof_Window_OutCorner_01_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Roof_Window_OutCorner_02_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Window_OutCorner_02_C

---@class FIN.classes.Satis.Build_Roof_Window_OutCorner_02_C : Satis.Build_Roof_Window_OutCorner_02_C
classes.Build_Roof_Window_OutCorner_02_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Roof_Window_OutCorner_03_C : Satis.FGBuildableCornerWallLightweight
local Build_Roof_Window_OutCorner_03_C

---@class FIN.classes.Satis.Build_Roof_Window_OutCorner_03_C : Satis.Build_Roof_Window_OutCorner_03_C
classes.Build_Roof_Window_OutCorner_03_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_Wall_Orange_8x8_Corner_02_C : Satis.FGBuildableCornerWall
local Build_Wall_Orange_8x8_Corner_02_C

---@class FIN.classes.Satis.Build_Wall_Orange_8x8_Corner_02_C : Satis.Build_Wall_Orange_8x8_Corner_02_C
classes.Build_Wall_Orange_8x8_Corner_02_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Orange_8x4_Corner_02_C : Satis.FGBuildableCornerWall
local Build_Wall_Orange_8x4_Corner_02_C

---@class FIN.classes.Satis.Build_Wall_Orange_8x4_Corner_02_C : Satis.Build_Wall_Orange_8x4_Corner_02_C
classes.Build_Wall_Orange_8x4_Corner_02_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_Wall_Steel_8x8_Corner_01_C : Satis.FGBuildableCornerWall
local Build_Wall_Steel_8x8_Corner_01_C

---@class FIN.classes.Satis.Build_Wall_Steel_8x8_Corner_01_C : Satis.Build_Wall_Steel_8x8_Corner_01_C
classes.Build_Wall_Steel_8x8_Corner_01_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Steel_8x4_Corner_2_C : Satis.FGBuildableCornerWall
local Build_Wall_Steel_8x4_Corner_2_C

---@class FIN.classes.Satis.Build_Wall_Steel_8x4_Corner_2_C : Satis.Build_Wall_Steel_8x4_Corner_2_C
classes.Build_Wall_Steel_8x4_Corner_2_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Steel_8x4_Corner_01_C : Satis.FGBuildableCornerWall
local Build_Wall_Steel_8x4_Corner_01_C

---@class FIN.classes.Satis.Build_Wall_Steel_8x4_Corner_01_C : Satis.Build_Wall_Steel_8x4_Corner_01_C
classes.Build_Wall_Steel_8x4_Corner_01_C = nil

end
do

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_Wall_Steel_8x8_Corner_2_C : Satis.FGBuildableCornerWall
local Build_Wall_Steel_8x8_Corner_2_C

---@class FIN.classes.Satis.Build_Wall_Steel_8x8_Corner_2_C : Satis.Build_Wall_Steel_8x8_Corner_2_C
classes.Build_Wall_Steel_8x8_Corner_2_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_Wall_Orange_8x8_Corner_01_C : Satis.FGBuildableCornerWall
local Build_Wall_Orange_8x8_Corner_01_C

---@class FIN.classes.Satis.Build_Wall_Orange_8x8_Corner_01_C : Satis.Build_Wall_Orange_8x8_Corner_01_C
classes.Build_Wall_Orange_8x8_Corner_01_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Orange_8x4_Corner_01_C : Satis.FGBuildableCornerWall
local Build_Wall_Orange_8x4_Corner_01_C

---@class FIN.classes.Satis.Build_Wall_Orange_8x4_Corner_01_C : Satis.Build_Wall_Orange_8x4_Corner_01_C
classes.Build_Wall_Orange_8x4_Corner_01_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_Wall_Concrete_8x8_Corner_2_C : Satis.FGBuildableCornerWall
local Build_Wall_Concrete_8x8_Corner_2_C

---@class FIN.classes.Satis.Build_Wall_Concrete_8x8_Corner_2_C : Satis.Build_Wall_Concrete_8x8_Corner_2_C
classes.Build_Wall_Concrete_8x8_Corner_2_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_8x4_Corner_2_C : Satis.FGBuildableCornerWall
local Build_Wall_Concrete_8x4_Corner_2_C

---@class FIN.classes.Satis.Build_Wall_Concrete_8x4_Corner_2_C : Satis.Build_Wall_Concrete_8x4_Corner_2_C
classes.Build_Wall_Concrete_8x4_Corner_2_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_8x4_Corner_01_C : Satis.FGBuildableCornerWall
local Build_Wall_Concrete_8x4_Corner_01_C

---@class FIN.classes.Satis.Build_Wall_Concrete_8x4_Corner_01_C : Satis.Build_Wall_Concrete_8x4_Corner_01_C
classes.Build_Wall_Concrete_8x4_Corner_01_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_Wall_Concrete_8x8_Corner_01_C : Satis.FGBuildableCornerWall
local Build_Wall_Concrete_8x8_Corner_01_C

---@class FIN.classes.Satis.Build_Wall_Concrete_8x8_Corner_01_C : Satis.Build_Wall_Concrete_8x8_Corner_01_C
classes.Build_Wall_Concrete_8x8_Corner_01_C = nil

--- The base class of all doors.
---@class Satis.Door : Satis.FGBuildableWall
local Door

---@class FIN.classes.Satis.Door : Satis.Door
classes.Door = nil

--- Returns the Door Mode/Configuration.<br>
--- 0 = Automatic<br>
--- 1 = Always Closed<br>
--- 2 = Always Open
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number configuration The current door mode/configuration.
function Door:getConfiguration() end

--- Sets the Door Mode/Configuration, only some modes are allowed, if the mod you try to set is invalid, nothing changes.<br>
--- 0 = Automatic<br>
--- 1 = Always Closed<br>
--- 2 = Always Open
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param configuration number The new configuration for the door.
function Door:setConfiguration(configuration) end

--- 
---@class Satis.FGBuildableWall : Satis.FGBuildableFactoryBuilding
local FGBuildableWall

---@class FIN.classes.Satis.FGBuildableWall : Satis.FGBuildableWall
classes.FGBuildableWall = nil

--- Allows pioneers to pass through a wall.<br>
--- Door settings can be configured.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Door_8x4_01_C : Satis.BUILD_SingleDoor_Base_01_C
local Build_Wall_Door_8x4_01_C

---@class FIN.classes.Satis.Build_Wall_Door_8x4_01_C : Satis.Build_Wall_Door_8x4_01_C
classes.Build_Wall_Door_8x4_01_C = nil

--- 
---@class Satis.BUILD_SingleDoor_Base_01_C : Satis.Door
local BUILD_SingleDoor_Base_01_C

---@class FIN.classes.Satis.BUILD_SingleDoor_Base_01_C : Satis.BUILD_SingleDoor_Base_01_C
classes.BUILD_SingleDoor_Base_01_C = nil

--- Snaps to foundations and other walls.<br>
--- Useful for building multi-floor structures.
---@class Satis.Build_SteelWall_8x4_DoorC_01_C : Satis.BUILD_SingleDoor_Base_01_C
local Build_SteelWall_8x4_DoorC_01_C

---@class FIN.classes.Satis.Build_SteelWall_8x4_DoorC_01_C : Satis.Build_SteelWall_8x4_DoorC_01_C
classes.Build_SteelWall_8x4_DoorC_01_C = nil

--- Allows pioneers to pass through a wall.<br>
--- Door settings can be configured.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Door_8x4_01_Steel_C : Satis.Build_SteelWall_8x4_DoorC_01_C
local Build_Wall_Door_8x4_01_Steel_C

---@class FIN.classes.Satis.Build_Wall_Door_8x4_01_Steel_C : Satis.Build_Wall_Door_8x4_01_Steel_C
classes.Build_Wall_Door_8x4_01_Steel_C = nil

--- Snaps to foundations and other walls.<br>
--- Useful for building multi-floor structures.
---@class Satis.Build_SteelWall_8x4_DoorS_01_C : Satis.BUILD_SingleDoor_Base_01_C
local Build_SteelWall_8x4_DoorS_01_C

---@class FIN.classes.Satis.Build_SteelWall_8x4_DoorS_01_C : Satis.Build_SteelWall_8x4_DoorS_01_C
classes.Build_SteelWall_8x4_DoorS_01_C = nil

--- Allows pioneers to pass through a wall.<br>
--- Door settings can be configured.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Door_8x4_03_Steel_C : Satis.Build_SteelWall_8x4_DoorS_01_C
local Build_Wall_Door_8x4_03_Steel_C

---@class FIN.classes.Satis.Build_Wall_Door_8x4_03_Steel_C : Satis.Build_Wall_Door_8x4_03_Steel_C
classes.Build_Wall_Door_8x4_03_Steel_C = nil

--- Allows pioneers to pass through a wall.<br>
--- Door settings can be configured.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Door_8x4_03_C : Satis.BUILD_SingleDoor_Base_01_C
local Build_Wall_Door_8x4_03_C

---@class FIN.classes.Satis.Build_Wall_Door_8x4_03_C : Satis.Build_Wall_Door_8x4_03_C
classes.Build_Wall_Door_8x4_03_C = nil

--- Allows pioneers to pass through a wall.<br>
--- Door settings can be configured.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_SDoor_8x4_C : Satis.BUILD_SingleDoor_Base_01_C
local Build_Wall_Concrete_SDoor_8x4_C

---@class FIN.classes.Satis.Build_Wall_Concrete_SDoor_8x4_C : Satis.Build_Wall_Concrete_SDoor_8x4_C
classes.Build_Wall_Concrete_SDoor_8x4_C = nil

--- Allows pioneers to pass through a wall.<br>
--- Door settings can be configured.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_CDoor_8x4_C : Satis.BUILD_SingleDoor_Base_01_C
local Build_Wall_Concrete_CDoor_8x4_C

---@class FIN.classes.Satis.Build_Wall_Concrete_CDoor_8x4_C : Satis.Build_Wall_Concrete_CDoor_8x4_C
classes.Build_Wall_Concrete_CDoor_8x4_C = nil

--- Automatically opens when living beings or vehicles approach it.<br>
--- Gate settings can be configured.<br>
--- Snaps to Foundations and Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Gate_Automated_8x4_C : Satis.Door
local Build_Gate_Automated_8x4_C

---@class FIN.classes.Satis.Build_Gate_Automated_8x4_C : Satis.Build_Gate_Automated_8x4_C
classes.Build_Gate_Automated_8x4_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Wall_Orange_Tris_8x1_C : Satis.FGBuildableWallLightweight
local Build_Wall_Orange_Tris_8x1_C

---@class FIN.classes.Satis.Build_Wall_Orange_Tris_8x1_C : Satis.Build_Wall_Orange_Tris_8x1_C
classes.Build_Wall_Orange_Tris_8x1_C = nil

--- 
---@class Satis.FGBuildableWallLightweight : Satis.FGBuildableWall
local FGBuildableWallLightweight

---@class FIN.classes.Satis.FGBuildableWallLightweight : Satis.FGBuildableWallLightweight
classes.FGBuildableWallLightweight = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_Wall_Orange_Tris_8x8_C : Satis.FGBuildableWallLightweight
local Build_Wall_Orange_Tris_8x8_C

---@class FIN.classes.Satis.Build_Wall_Orange_Tris_8x8_C : Satis.Build_Wall_Orange_Tris_8x8_C
classes.Build_Wall_Orange_Tris_8x8_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Wall_Orange_FlipTris_8x1_C : Satis.FGBuildableWallLightweight
local Build_Wall_Orange_FlipTris_8x1_C

---@class FIN.classes.Satis.Build_Wall_Orange_FlipTris_8x1_C : Satis.Build_Wall_Orange_FlipTris_8x1_C
classes.Build_Wall_Orange_FlipTris_8x1_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_Wall_Orange_FlipTris_8x8_C : Satis.FGBuildableWallLightweight
local Build_Wall_Orange_FlipTris_8x8_C

---@class FIN.classes.Satis.Build_Wall_Orange_FlipTris_8x8_C : Satis.Build_Wall_Orange_FlipTris_8x8_C
classes.Build_Wall_Orange_FlipTris_8x8_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Wall_Orange_Tris_8x2_C : Satis.FGBuildableWallLightweight
local Build_Wall_Orange_Tris_8x2_C

---@class FIN.classes.Satis.Build_Wall_Orange_Tris_8x2_C : Satis.Build_Wall_Orange_Tris_8x2_C
classes.Build_Wall_Orange_Tris_8x2_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Wall_Orange_FlipTris_8x2_C : Satis.FGBuildableWallLightweight
local Build_Wall_Orange_FlipTris_8x2_C

---@class FIN.classes.Satis.Build_Wall_Orange_FlipTris_8x2_C : Satis.Build_Wall_Orange_FlipTris_8x2_C
classes.Build_Wall_Orange_FlipTris_8x2_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Orange_FlipTris_8x4_C : Satis.FGBuildableWallLightweight
local Build_Wall_Orange_FlipTris_8x4_C

---@class FIN.classes.Satis.Build_Wall_Orange_FlipTris_8x4_C : Satis.Build_Wall_Orange_FlipTris_8x4_C
classes.Build_Wall_Orange_FlipTris_8x4_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Orange_Tris_8x4_C : Satis.FGBuildableWallLightweight
local Build_Wall_Orange_Tris_8x4_C

---@class FIN.classes.Satis.Build_Wall_Orange_Tris_8x4_C : Satis.Build_Wall_Orange_Tris_8x4_C
classes.Build_Wall_Orange_Tris_8x4_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Orange_Angular_8x4_C : Satis.FGBuildableWallLightweight
local Build_Wall_Orange_Angular_8x4_C

---@class FIN.classes.Satis.Build_Wall_Orange_Angular_8x4_C : Satis.Build_Wall_Orange_Angular_8x4_C
classes.Build_Wall_Orange_Angular_8x4_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_Wall_Orange_Angular_8x8_C : Satis.FGBuildableWallLightweight
local Build_Wall_Orange_Angular_8x8_C

---@class FIN.classes.Satis.Build_Wall_Orange_Angular_8x8_C : Satis.Build_Wall_Orange_Angular_8x8_C
classes.Build_Wall_Orange_Angular_8x8_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_SteelWall_8x4_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_8x4_C

---@class FIN.classes.Satis.Build_SteelWall_8x4_C : Satis.Build_SteelWall_8x4_C
classes.Build_SteelWall_8x4_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_SteelWall_FlipTris_8x4_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_FlipTris_8x4_C

---@class FIN.classes.Satis.Build_SteelWall_FlipTris_8x4_C : Satis.Build_SteelWall_FlipTris_8x4_C
classes.Build_SteelWall_FlipTris_8x4_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_SteelWall_FlipTris_8x1_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_FlipTris_8x1_C

---@class FIN.classes.Satis.Build_SteelWall_FlipTris_8x1_C : Satis.Build_SteelWall_FlipTris_8x1_C
classes.Build_SteelWall_FlipTris_8x1_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_SteelWall_Tris_8x8_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_Tris_8x8_C

---@class FIN.classes.Satis.Build_SteelWall_Tris_8x8_C : Satis.Build_SteelWall_Tris_8x8_C
classes.Build_SteelWall_Tris_8x8_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_WallSet_Steel_Angular_8x4_C : Satis.FGBuildableWallLightweight
local Build_WallSet_Steel_Angular_8x4_C

---@class FIN.classes.Satis.Build_WallSet_Steel_Angular_8x4_C : Satis.Build_WallSet_Steel_Angular_8x4_C
classes.Build_WallSet_Steel_Angular_8x4_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_8x4_02_C : Satis.FGBuildableWallLightweight
local Build_Wall_8x4_02_C

---@class FIN.classes.Satis.Build_Wall_8x4_02_C : Satis.Build_Wall_8x4_02_C
classes.Build_Wall_8x4_02_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_WallSet_Steel_Angular_8x8_C : Satis.FGBuildableWallLightweight
local Build_WallSet_Steel_Angular_8x8_C

---@class FIN.classes.Satis.Build_WallSet_Steel_Angular_8x8_C : Satis.Build_WallSet_Steel_Angular_8x8_C
classes.Build_WallSet_Steel_Angular_8x8_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_SteelWall_Tris_8x4_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_Tris_8x4_C

---@class FIN.classes.Satis.Build_SteelWall_Tris_8x4_C : Satis.Build_SteelWall_Tris_8x4_C
classes.Build_SteelWall_Tris_8x4_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_SteelWall_Tris_8x2_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_Tris_8x2_C

---@class FIN.classes.Satis.Build_SteelWall_Tris_8x2_C : Satis.Build_SteelWall_Tris_8x2_C
classes.Build_SteelWall_Tris_8x2_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_SteelWall_Tris_8x1_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_Tris_8x1_C

---@class FIN.classes.Satis.Build_SteelWall_Tris_8x1_C : Satis.Build_SteelWall_Tris_8x1_C
classes.Build_SteelWall_Tris_8x1_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_SteelWall_FlipTris_8x2_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_FlipTris_8x2_C

---@class FIN.classes.Satis.Build_SteelWall_FlipTris_8x2_C : Satis.Build_SteelWall_FlipTris_8x2_C
classes.Build_SteelWall_FlipTris_8x2_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_SteelWall_8x1_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_8x1_C

---@class FIN.classes.Satis.Build_SteelWall_8x1_C : Satis.Build_SteelWall_8x1_C
classes.Build_SteelWall_8x1_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_8x4_01_C : Satis.FGBuildableWallLightweight
local Build_Wall_8x4_01_C

---@class FIN.classes.Satis.Build_Wall_8x4_01_C : Satis.Build_Wall_8x4_01_C
classes.Build_Wall_8x4_01_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Wall_Orange_8x1_C : Satis.FGBuildableWallLightweight
local Build_Wall_Orange_8x1_C

---@class FIN.classes.Satis.Build_Wall_Orange_8x1_C : Satis.Build_Wall_Orange_8x1_C
classes.Build_Wall_Orange_8x1_C = nil

--- Has 3 Conveyor Belt connections.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Conveyor_8x4_01_Steel_C : Satis.FGBuildableWallLightweight
local Build_Wall_Conveyor_8x4_01_Steel_C

---@class FIN.classes.Satis.Build_Wall_Conveyor_8x4_01_Steel_C : Satis.Build_Wall_Conveyor_8x4_01_Steel_C
classes.Build_Wall_Conveyor_8x4_01_Steel_C = nil

--- Allows pioneers to pass through a Wall.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_SteelWall_8x4_Gate_01_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_8x4_Gate_01_C

---@class FIN.classes.Satis.Build_SteelWall_8x4_Gate_01_C : Satis.Build_SteelWall_8x4_Gate_01_C
classes.Build_SteelWall_8x4_Gate_01_C = nil

--- Allows pioneers to pass through a Wall.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Gate_8x4_01_C : Satis.FGBuildableWallLightweight
local Build_Wall_Gate_8x4_01_C

---@class FIN.classes.Satis.Build_Wall_Gate_8x4_01_C : Satis.Build_Wall_Gate_8x4_01_C
classes.Build_Wall_Gate_8x4_01_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_SteelWall_8x4_Window_01_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_8x4_Window_01_C

---@class FIN.classes.Satis.Build_SteelWall_8x4_Window_01_C : Satis.Build_SteelWall_8x4_Window_01_C
classes.Build_SteelWall_8x4_Window_01_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Window_8x4_01_C : Satis.FGBuildableWallLightweight
local Build_Wall_Window_8x4_01_C

---@class FIN.classes.Satis.Build_Wall_Window_8x4_01_C : Satis.Build_Wall_Window_8x4_01_C
classes.Build_Wall_Window_8x4_01_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Window_8x4_03_C : Satis.FGBuildableWallLightweight
local Build_Wall_Window_8x4_03_C

---@class FIN.classes.Satis.Build_Wall_Window_8x4_03_C : Satis.Build_Wall_Window_8x4_03_C
classes.Build_Wall_Window_8x4_03_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_SteelWall_8x4_Window_04_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_8x4_Window_04_C

---@class FIN.classes.Satis.Build_SteelWall_8x4_Window_04_C : Satis.Build_SteelWall_8x4_Window_04_C
classes.Build_SteelWall_8x4_Window_04_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_SteelWall_8x4_Window_03_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_8x4_Window_03_C

---@class FIN.classes.Satis.Build_SteelWall_8x4_Window_03_C : Satis.Build_SteelWall_8x4_Window_03_C
classes.Build_SteelWall_8x4_Window_03_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Window_8x4_02_C : Satis.FGBuildableWallLightweight
local Build_Wall_Window_8x4_02_C

---@class FIN.classes.Satis.Build_Wall_Window_8x4_02_C : Satis.Build_Wall_Window_8x4_02_C
classes.Build_Wall_Window_8x4_02_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_SteelWall_8x4_Window_02_C : Satis.FGBuildableWallLightweight
local Build_SteelWall_8x4_Window_02_C

---@class FIN.classes.Satis.Build_SteelWall_8x4_Window_02_C : Satis.Build_SteelWall_8x4_Window_02_C
classes.Build_SteelWall_8x4_Window_02_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Window_8x4_04_C : Satis.FGBuildableWallLightweight
local Build_Wall_Window_8x4_04_C

---@class FIN.classes.Satis.Build_Wall_Window_8x4_04_C : Satis.Build_Wall_Window_8x4_04_C
classes.Build_Wall_Window_8x4_04_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_8x4_Window_01_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_8x4_Window_01_C

---@class FIN.classes.Satis.Build_Wall_Concrete_8x4_Window_01_C : Satis.Build_Wall_Concrete_8x4_Window_01_C
classes.Build_Wall_Concrete_8x4_Window_01_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Wall_Concrete_8x1_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_8x1_C

---@class FIN.classes.Satis.Build_Wall_Concrete_8x1_C : Satis.Build_Wall_Concrete_8x1_C
classes.Build_Wall_Concrete_8x1_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_Angular_8x4_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_Angular_8x4_C

---@class FIN.classes.Satis.Build_Wall_Concrete_Angular_8x4_C : Satis.Build_Wall_Concrete_Angular_8x4_C
classes.Build_Wall_Concrete_Angular_8x4_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Wall_Concrete_FlipTris_8x1_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_FlipTris_8x1_C

---@class FIN.classes.Satis.Build_Wall_Concrete_FlipTris_8x1_C : Satis.Build_Wall_Concrete_FlipTris_8x1_C
classes.Build_Wall_Concrete_FlipTris_8x1_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Wall_Concrete_Tris_8x2_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_Tris_8x2_C

---@class FIN.classes.Satis.Build_Wall_Concrete_Tris_8x2_C : Satis.Build_Wall_Concrete_Tris_8x2_C
classes.Build_Wall_Concrete_Tris_8x2_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Wall_Concrete_FlipTris_8x2_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_FlipTris_8x2_C

---@class FIN.classes.Satis.Build_Wall_Concrete_FlipTris_8x2_C : Satis.Build_Wall_Concrete_FlipTris_8x2_C
classes.Build_Wall_Concrete_FlipTris_8x2_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_8x4_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_8x4_C

---@class FIN.classes.Satis.Build_Wall_Concrete_8x4_C : Satis.Build_Wall_Concrete_8x4_C
classes.Build_Wall_Concrete_8x4_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_FlipTris_8x4_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_FlipTris_8x4_C

---@class FIN.classes.Satis.Build_Wall_Concrete_FlipTris_8x4_C : Satis.Build_Wall_Concrete_FlipTris_8x4_C
classes.Build_Wall_Concrete_FlipTris_8x4_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_Wall_Concrete_FlipTris_8x8_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_FlipTris_8x8_C

---@class FIN.classes.Satis.Build_Wall_Concrete_FlipTris_8x8_C : Satis.Build_Wall_Concrete_FlipTris_8x8_C
classes.Build_Wall_Concrete_FlipTris_8x8_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Wall_Concrete_Tris_8x1_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_Tris_8x1_C

---@class FIN.classes.Satis.Build_Wall_Concrete_Tris_8x1_C : Satis.Build_Wall_Concrete_Tris_8x1_C
classes.Build_Wall_Concrete_Tris_8x1_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_Tris_8x4_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_Tris_8x4_C

---@class FIN.classes.Satis.Build_Wall_Concrete_Tris_8x4_C : Satis.Build_Wall_Concrete_Tris_8x4_C
classes.Build_Wall_Concrete_Tris_8x4_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_Wall_Concrete_Angular_8x8_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_Angular_8x8_C

---@class FIN.classes.Satis.Build_Wall_Concrete_Angular_8x8_C : Satis.Build_Wall_Concrete_Angular_8x8_C
classes.Build_Wall_Concrete_Angular_8x8_C = nil

--- Has 1 Conveyor Belt connection.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_8x4_ConveyorHole_01_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_8x4_ConveyorHole_01_C

---@class FIN.classes.Satis.Build_Wall_Concrete_8x4_ConveyorHole_01_C : Satis.Build_Wall_Concrete_8x4_ConveyorHole_01_C
classes.Build_Wall_Concrete_8x4_ConveyorHole_01_C = nil

--- Has 2 Conveyor Belt connections.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_8x4_ConveyorHole_02_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_8x4_ConveyorHole_02_C

---@class FIN.classes.Satis.Build_Wall_Concrete_8x4_ConveyorHole_02_C : Satis.Build_Wall_Concrete_8x4_ConveyorHole_02_C
classes.Build_Wall_Concrete_8x4_ConveyorHole_02_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_8x4_Window_02_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_8x4_Window_02_C

---@class FIN.classes.Satis.Build_Wall_Concrete_8x4_Window_02_C : Satis.Build_Wall_Concrete_8x4_Window_02_C
classes.Build_Wall_Concrete_8x4_Window_02_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_8x4_Window_04_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_8x4_Window_04_C

---@class FIN.classes.Satis.Build_Wall_Concrete_8x4_Window_04_C : Satis.Build_Wall_Concrete_8x4_Window_04_C
classes.Build_Wall_Concrete_8x4_Window_04_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_8x4_Window_03_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_8x4_Window_03_C

---@class FIN.classes.Satis.Build_Wall_Concrete_8x4_Window_03_C : Satis.Build_Wall_Concrete_8x4_Window_03_C
classes.Build_Wall_Concrete_8x4_Window_03_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_Wall_Concrete_Tris_8x8_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_Tris_8x8_C

---@class FIN.classes.Satis.Build_Wall_Concrete_Tris_8x8_C : Satis.Build_Wall_Concrete_Tris_8x8_C
classes.Build_Wall_Concrete_Tris_8x8_C = nil

--- Allows pioneers to pass through a Wall.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_Gate_8x4_C : Satis.FGBuildableWallLightweight
local Build_Wall_Concrete_Gate_8x4_C

---@class FIN.classes.Satis.Build_Wall_Concrete_Gate_8x4_C : Satis.Build_Wall_Concrete_Gate_8x4_C
classes.Build_Wall_Concrete_Gate_8x4_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Window_Thin_8x4_02_C : Satis.FGBuildableWallLightweight
local Build_Wall_Window_Thin_8x4_02_C

---@class FIN.classes.Satis.Build_Wall_Window_Thin_8x4_02_C : Satis.Build_Wall_Window_Thin_8x4_02_C
classes.Build_Wall_Window_Thin_8x4_02_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Window_Thin_8x4_01_C : Satis.FGBuildableWallLightweight
local Build_Wall_Window_Thin_8x4_01_C

---@class FIN.classes.Satis.Build_Wall_Window_Thin_8x4_01_C : Satis.Build_Wall_Window_Thin_8x4_01_C
classes.Build_Wall_Window_Thin_8x4_01_C = nil

--- Creates a safer and more efficient working environment.
---@class Satis.Build_Barrier_Low_01_C : Satis.FGBuildableWallLightweight
local Build_Barrier_Low_01_C

---@class FIN.classes.Satis.Build_Barrier_Low_01_C : Satis.Build_Barrier_Low_01_C
classes.Build_Barrier_Low_01_C = nil

--- Creates a safer and more efficient working environment.
---@class Satis.Build_Barrier_Tall_01_C : Satis.FGBuildableWallLightweight
local Build_Barrier_Tall_01_C

---@class FIN.classes.Satis.Build_Barrier_Tall_01_C : Satis.Build_Barrier_Tall_01_C
classes.Build_Barrier_Tall_01_C = nil

--- Creates a safer and more efficient working environment.
---@class Satis.Build_Concrete_Barrier_01_C : Satis.FGBuildableWallLightweight
local Build_Concrete_Barrier_01_C

---@class FIN.classes.Satis.Build_Concrete_Barrier_01_C : Satis.Build_Concrete_Barrier_01_C
classes.Build_Concrete_Barrier_01_C = nil

--- Creates a safer working environment when built on the edge of Foundations.
---@class Satis.Build_Fence_01_C : Satis.FGBuildableWallLightweight
local Build_Fence_01_C

---@class FIN.classes.Satis.Build_Fence_01_C : Satis.Build_Fence_01_C
classes.Build_Fence_01_C = nil

--- The Fence can be built on the edges of floors to prevent you from falling off.
---@class Satis.Build_FenceRamp_8x1_L_C : Satis.FGBuildableWallLightweight
local Build_FenceRamp_8x1_L_C

---@class FIN.classes.Satis.Build_FenceRamp_8x1_L_C : Satis.Build_FenceRamp_8x1_L_C
classes.Build_FenceRamp_8x1_L_C = nil

--- The Fence can be built on the edges of floors to prevent you from falling off.
---@class Satis.Build_FenceRamp_8x1_R_C : Satis.FGBuildableWallLightweight
local Build_FenceRamp_8x1_R_C

---@class FIN.classes.Satis.Build_FenceRamp_8x1_R_C : Satis.Build_FenceRamp_8x1_R_C
classes.Build_FenceRamp_8x1_R_C = nil

--- The Fence can be built on the edges of floors to prevent you from falling off.
---@class Satis.Build_FenceRamp_8x2_L_C : Satis.FGBuildableWallLightweight
local Build_FenceRamp_8x2_L_C

---@class FIN.classes.Satis.Build_FenceRamp_8x2_L_C : Satis.Build_FenceRamp_8x2_L_C
classes.Build_FenceRamp_8x2_L_C = nil

--- The Fence can be built on the edges of floors to prevent you from falling off.
---@class Satis.Build_FenceRamp_8x2_R_C : Satis.FGBuildableWallLightweight
local Build_FenceRamp_8x2_R_C

---@class FIN.classes.Satis.Build_FenceRamp_8x2_R_C : Satis.Build_FenceRamp_8x2_R_C
classes.Build_FenceRamp_8x2_R_C = nil

--- The Fence can be built on the edges of floors to prevent you from falling off.
---@class Satis.Build_FenceRamp_8x4_L_C : Satis.FGBuildableWallLightweight
local Build_FenceRamp_8x4_L_C

---@class FIN.classes.Satis.Build_FenceRamp_8x4_L_C : Satis.Build_FenceRamp_8x4_L_C
classes.Build_FenceRamp_8x4_L_C = nil

--- The Fence can be built on the edges of floors to prevent you from falling off.
---@class Satis.Build_FenceRamp_8x4_R_C : Satis.FGBuildableWallLightweight
local Build_FenceRamp_8x4_R_C

---@class FIN.classes.Satis.Build_FenceRamp_8x4_R_C : Satis.Build_FenceRamp_8x4_R_C
classes.Build_FenceRamp_8x4_R_C = nil

--- Creates a safer working environment when built on the edge of Foundations.<br>
--- <br>
--- This Railing is 4 m long and automatically angles itself when built on Ramps.
---@class Satis.Build_Railing_01_C : Satis.FGBuildableWallLightweight
local Build_Railing_01_C

---@class FIN.classes.Satis.Build_Railing_01_C : Satis.Build_Railing_01_C
classes.Build_Railing_01_C = nil

--- The Fence can be built on the edges of floors to prevent you from falling off.
---@class Satis.Build_SM_RailingRamp_8x1_01_C : Satis.FGBuildableWallLightweight
local Build_SM_RailingRamp_8x1_01_C

---@class FIN.classes.Satis.Build_SM_RailingRamp_8x1_01_C : Satis.Build_SM_RailingRamp_8x1_01_C
classes.Build_SM_RailingRamp_8x1_01_C = nil

--- The Fence can be built on the edges of floors to prevent you from falling off.
---@class Satis.Build_SM_RailingRamp_8x2_01_C : Satis.FGBuildableWallLightweight
local Build_SM_RailingRamp_8x2_01_C

---@class FIN.classes.Satis.Build_SM_RailingRamp_8x2_01_C : Satis.Build_SM_RailingRamp_8x2_01_C
classes.Build_SM_RailingRamp_8x2_01_C = nil

--- The Fence can be built on the edges of floors to prevent you from falling off.
---@class Satis.Build_SM_RailingRamp_8x4_01_C : Satis.FGBuildableWallLightweight
local Build_SM_RailingRamp_8x4_01_C

---@class FIN.classes.Satis.Build_SM_RailingRamp_8x4_01_C : Satis.Build_SM_RailingRamp_8x4_01_C
classes.Build_SM_RailingRamp_8x4_01_C = nil

--- Creates a safer and more efficient working environment.
---@class Satis.Build_ChainLinkFence_C : Satis.FGBuildableWallLightweight
local Build_ChainLinkFence_C

---@class FIN.classes.Satis.Build_ChainLinkFence_C : Satis.Build_ChainLinkFence_C
classes.Build_ChainLinkFence_C = nil

--- Creates a safer and more efficient working environment.
---@class Satis.Build_TarpFence_C : Satis.FGBuildableWallLightweight
local Build_TarpFence_C

---@class FIN.classes.Satis.Build_TarpFence_C : Satis.Build_TarpFence_C
classes.Build_TarpFence_C = nil

--- Snaps to other structural buildings.<br>
--- Frames provide a more open factory aesthetic.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Frame_01_C : Satis.FGBuildableWallLightweight
local Build_Wall_Frame_01_C

---@class FIN.classes.Satis.Build_Wall_Frame_01_C : Satis.Build_Wall_Frame_01_C
classes.Build_Wall_Frame_01_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Window_8x4_05_C : Satis.FGBuildableWallLightweight
local Build_Wall_Window_8x4_05_C

---@class FIN.classes.Satis.Build_Wall_Window_8x4_05_C : Satis.Build_Wall_Window_8x4_05_C
classes.Build_Wall_Window_8x4_05_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Window_8x4_06_C : Satis.FGBuildableWallLightweight
local Build_Wall_Window_8x4_06_C

---@class FIN.classes.Satis.Build_Wall_Window_8x4_06_C : Satis.Build_Wall_Window_8x4_06_C
classes.Build_Wall_Window_8x4_06_C = nil

--- Snaps to Foundations and other Walls.<br>
--- The windows allow pioneers to see through a wall.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Window_8x4_07_C : Satis.FGBuildableWallLightweight
local Build_Wall_Window_8x4_07_C

---@class FIN.classes.Satis.Build_Wall_Window_8x4_07_C : Satis.Build_Wall_Window_8x4_07_C
classes.Build_Wall_Window_8x4_07_C = nil

--- Has 2 Conveyor Belt connections.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Conveyor_8x4_02_C : Satis.FGBuildableWall
local Build_Wall_Conveyor_8x4_02_C

---@class FIN.classes.Satis.Build_Wall_Conveyor_8x4_02_C : Satis.Build_Wall_Conveyor_8x4_02_C
classes.Build_Wall_Conveyor_8x4_02_C = nil

--- Has 3 Conveyor Belt connections.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Conveyor_8x4_01_C : Satis.FGBuildableWall
local Build_Wall_Conveyor_8x4_01_C

---@class FIN.classes.Satis.Build_Wall_Conveyor_8x4_01_C : Satis.Build_Wall_Conveyor_8x4_01_C
classes.Build_Wall_Conveyor_8x4_01_C = nil

--- Has 1 Conveyor Belt connection.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Conveyor_8x4_03_C : Satis.FGBuildableWall
local Build_Wall_Conveyor_8x4_03_C

---@class FIN.classes.Satis.Build_Wall_Conveyor_8x4_03_C : Satis.Build_Wall_Conveyor_8x4_03_C
classes.Build_Wall_Conveyor_8x4_03_C = nil

--- Has 1 Conveyor Belt connection.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Conveyor_8x4_03_Steel_C : Satis.FGBuildableWall
local Build_Wall_Conveyor_8x4_03_Steel_C

---@class FIN.classes.Satis.Build_Wall_Conveyor_8x4_03_Steel_C : Satis.Build_Wall_Conveyor_8x4_03_Steel_C
classes.Build_Wall_Conveyor_8x4_03_Steel_C = nil

--- Snaps to Foundations and other Walls.<br>
--- Useful for building multi-floor structures.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_SteelWall_FlipTris_8x8_C : Satis.FGBuildableWall
local Build_SteelWall_FlipTris_8x8_C

---@class FIN.classes.Satis.Build_SteelWall_FlipTris_8x8_C : Satis.Build_SteelWall_FlipTris_8x8_C
classes.Build_SteelWall_FlipTris_8x8_C = nil

--- Has 2 Conveyor Belt connections.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Conveyor_8x4_02_Steel_C : Satis.FGBuildableWall
local Build_Wall_Conveyor_8x4_02_Steel_C

---@class FIN.classes.Satis.Build_Wall_Conveyor_8x4_02_Steel_C : Satis.Build_Wall_Conveyor_8x4_02_Steel_C
classes.Build_Wall_Conveyor_8x4_02_Steel_C = nil

--- Has 3 Conveyor Belt connections.<br>
--- Snaps to Foundations and other Walls.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Wall_Concrete_8x4_ConveyorHole_03_C : Satis.FGBuildableWall
local Build_Wall_Concrete_8x4_ConveyorHole_03_C

---@class FIN.classes.Satis.Build_Wall_Concrete_8x4_ConveyorHole_03_C : Satis.Build_Wall_Concrete_8x4_ConveyorHole_03_C
classes.Build_Wall_Concrete_8x4_ConveyorHole_03_C = nil

--- 
---@class Satis.Build_DoorMiddle_C : Satis.FGBuildableWall
local Build_DoorMiddle_C

---@class FIN.classes.Satis.Build_DoorMiddle_C : Satis.Build_DoorMiddle_C
classes.Build_DoorMiddle_C = nil

--- Snaps to foundations and other walls.<br>
--- Useful for building multi-floor structures.
---@class Satis.Build_Construction_Beam_04_C : Satis.FGBuildableWall
local Build_Construction_Beam_04_C

---@class FIN.classes.Satis.Build_Construction_Beam_04_C : Satis.Build_Construction_Beam_04_C
classes.Build_Construction_Beam_04_C = nil

--- Connects to other Walls and Foundations. Use these to make buildings with several floors.<br>
--- Has 1 Conveyor Belt connection perpendicular to the wall.<br>
--- Height: 4 m
---@class Satis.Build_Wall_Conveyor_8x4_04_C : Satis.FGBuildableWall
local Build_Wall_Conveyor_8x4_04_C

---@class FIN.classes.Satis.Build_Wall_Conveyor_8x4_04_C : Satis.Build_Wall_Conveyor_8x4_04_C
classes.Build_Wall_Conveyor_8x4_04_C = nil

--- Connects to other Walls and Foundations. Use these to make buildings with several floors.<br>
--- Has 1 Conveyor Belt connection perpendicular to the wall.<br>
--- Height: 4 m
---@class Satis.Build_Wall_Conveyor_8x4_04_Steel_C : Satis.FGBuildableWall
local Build_Wall_Conveyor_8x4_04_Steel_C

---@class FIN.classes.Satis.Build_Wall_Conveyor_8x4_04_Steel_C : Satis.Build_Wall_Conveyor_8x4_04_Steel_C
classes.Build_Wall_Conveyor_8x4_04_Steel_C = nil

--- 
---@class Satis.FGBuildableFactoryBuildingLightweight : Satis.FGBuildableFactoryBuilding
local FGBuildableFactoryBuildingLightweight

---@class FIN.classes.Satis.FGBuildableFactoryBuildingLightweight : Satis.FGBuildableFactoryBuildingLightweight
classes.FGBuildableFactoryBuildingLightweight = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_DownQuarterPipe_Asphalt_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_DownQuarterPipe_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_DownQuarterPipe_Asphalt_8x4_C : Satis.Build_DownQuarterPipe_Asphalt_8x4_C
classes.Build_DownQuarterPipe_Asphalt_8x4_C = nil

--- 
---@class Satis.FGBuildableFoundationLightweight : Satis.FGBuildableFoundation
local FGBuildableFoundationLightweight

---@class FIN.classes.Satis.FGBuildableFoundationLightweight : Satis.FGBuildableFoundationLightweight
classes.FGBuildableFoundationLightweight = nil

--- 
---@class Satis.FGBuildableFoundation : Satis.FGBuildableFactoryBuilding
local FGBuildableFoundation

---@class FIN.classes.Satis.FGBuildableFoundation : Satis.FGBuildableFoundation
classes.FGBuildableFoundation = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_DownQuarterPipeInCorner_Asphalt_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_DownQuarterPipeInCorner_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_DownQuarterPipeInCorner_Asphalt_8x4_C : Satis.Build_DownQuarterPipeInCorner_Asphalt_8x4_C
classes.Build_DownQuarterPipeInCorner_Asphalt_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_DownQuarterPipeOutCorner_Asphalt_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_DownQuarterPipeOutCorner_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_DownQuarterPipeOutCorner_Asphalt_8x4_C : Satis.Build_DownQuarterPipeOutCorner_Asphalt_8x4_C
classes.Build_DownQuarterPipeOutCorner_Asphalt_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Foundation_Asphalt_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_Asphalt_8x1_C

---@class FIN.classes.Satis.Build_Foundation_Asphalt_8x1_C : Satis.Build_Foundation_Asphalt_8x1_C
classes.Build_Foundation_Asphalt_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Foundation_Asphalt_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_Asphalt_8x2_C

---@class FIN.classes.Satis.Build_Foundation_Asphalt_8x2_C : Satis.Build_Foundation_Asphalt_8x2_C
classes.Build_Foundation_Asphalt_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Foundation_Asphalt_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_Foundation_Asphalt_8x4_C : Satis.Build_Foundation_Asphalt_8x4_C
classes.Build_Foundation_Asphalt_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_InvertedRamp_DCorner_Asphalt_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_DCorner_Asphalt_8x1_C

---@class FIN.classes.Satis.Build_InvertedRamp_DCorner_Asphalt_8x1_C : Satis.Build_InvertedRamp_DCorner_Asphalt_8x1_C
classes.Build_InvertedRamp_DCorner_Asphalt_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_InvertedRamp_DCorner_Asphalt_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_DCorner_Asphalt_8x2_C

---@class FIN.classes.Satis.Build_InvertedRamp_DCorner_Asphalt_8x2_C : Satis.Build_InvertedRamp_DCorner_Asphalt_8x2_C
classes.Build_InvertedRamp_DCorner_Asphalt_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_InvertedRamp_DCorner_Asphalt_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_DCorner_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_InvertedRamp_DCorner_Asphalt_8x4_C : Satis.Build_InvertedRamp_DCorner_Asphalt_8x4_C
classes.Build_InvertedRamp_DCorner_Asphalt_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_InvertedRamp_UCorner_Asphalt_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_UCorner_Asphalt_8x1_C

---@class FIN.classes.Satis.Build_InvertedRamp_UCorner_Asphalt_8x1_C : Satis.Build_InvertedRamp_UCorner_Asphalt_8x1_C
classes.Build_InvertedRamp_UCorner_Asphalt_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_InvertedRamp_UCorner_Asphalt_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_UCorner_Asphalt_8x2_C

---@class FIN.classes.Satis.Build_InvertedRamp_UCorner_Asphalt_8x2_C : Satis.Build_InvertedRamp_UCorner_Asphalt_8x2_C
classes.Build_InvertedRamp_UCorner_Asphalt_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_InvertedRamp_UCorner_Asphalt_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_UCorner_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_InvertedRamp_UCorner_Asphalt_8x4_C : Satis.Build_InvertedRamp_UCorner_Asphalt_8x4_C
classes.Build_InvertedRamp_UCorner_Asphalt_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipe_Asphalt_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipe_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipe_Asphalt_8x4_C : Satis.Build_QuarterPipe_Asphalt_8x4_C
classes.Build_QuarterPipe_Asphalt_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeInCorner_Asphalt_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeInCorner_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeInCorner_Asphalt_8x4_C : Satis.Build_QuarterPipeInCorner_Asphalt_8x4_C
classes.Build_QuarterPipeInCorner_Asphalt_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_QuarterPipeMiddle_Asphalt_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_Asphalt_8x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_Asphalt_8x1_C : Satis.Build_QuarterPipeMiddle_Asphalt_8x1_C
classes.Build_QuarterPipeMiddle_Asphalt_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_QuarterPipeMiddle_Asphalt_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_Asphalt_8x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_Asphalt_8x2_C : Satis.Build_QuarterPipeMiddle_Asphalt_8x2_C
classes.Build_QuarterPipeMiddle_Asphalt_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeMiddle_Asphalt_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_Asphalt_8x4_C : Satis.Build_QuarterPipeMiddle_Asphalt_8x4_C
classes.Build_QuarterPipeMiddle_Asphalt_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_QuarterPipeMiddleInCorner_Asphalt_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_Asphalt_8x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_Asphalt_8x1_C : Satis.Build_QuarterPipeMiddleInCorner_Asphalt_8x1_C
classes.Build_QuarterPipeMiddleInCorner_Asphalt_8x1_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_QuarterPipeMiddleInCorner_Asphalt_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_Asphalt_8x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_Asphalt_8x2_C : Satis.Build_QuarterPipeMiddleInCorner_Asphalt_8x2_C
classes.Build_QuarterPipeMiddleInCorner_Asphalt_8x2_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeMiddleInCorner_Asphalt_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_Asphalt_8x4_C : Satis.Build_QuarterPipeMiddleInCorner_Asphalt_8x4_C
classes.Build_QuarterPipeMiddleInCorner_Asphalt_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 1 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_Asphalt_4x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_Asphalt_4x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_Asphalt_4x1_C : Satis.Build_QuarterPipeMiddleOutCorner_Asphalt_4x1_C
classes.Build_QuarterPipeMiddleOutCorner_Asphalt_4x1_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 2 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_Asphalt_4x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_Asphalt_4x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_Asphalt_4x2_C : Satis.Build_QuarterPipeMiddleOutCorner_Asphalt_4x2_C
classes.Build_QuarterPipeMiddleOutCorner_Asphalt_4x2_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 4 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_Asphalt_4x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_Asphalt_4x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_Asphalt_4x4_C : Satis.Build_QuarterPipeMiddleOutCorner_Asphalt_4x4_C
classes.Build_QuarterPipeMiddleOutCorner_Asphalt_4x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeOutCorner_Asphalt_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeOutCorner_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeOutCorner_Asphalt_8x4_C : Satis.Build_QuarterPipeOutCorner_Asphalt_8x4_C
classes.Build_QuarterPipeOutCorner_Asphalt_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_DownCorner_Asphalt_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_DownCorner_Asphalt_8x1_C

---@class FIN.classes.Satis.Build_Ramp_DownCorner_Asphalt_8x1_C : Satis.Build_Ramp_DownCorner_Asphalt_8x1_C
classes.Build_Ramp_DownCorner_Asphalt_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_DownCorner_Asphalt_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_DownCorner_Asphalt_8x2_C

---@class FIN.classes.Satis.Build_Ramp_DownCorner_Asphalt_8x2_C : Satis.Build_Ramp_DownCorner_Asphalt_8x2_C
classes.Build_Ramp_DownCorner_Asphalt_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_DownCorner_Asphalt_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_DownCorner_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_Ramp_DownCorner_Asphalt_8x4_C : Satis.Build_Ramp_DownCorner_Asphalt_8x4_C
classes.Build_Ramp_DownCorner_Asphalt_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_UpCorner_Asphalt_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_UpCorner_Asphalt_8x1_C

---@class FIN.classes.Satis.Build_Ramp_UpCorner_Asphalt_8x1_C : Satis.Build_Ramp_UpCorner_Asphalt_8x1_C
classes.Build_Ramp_UpCorner_Asphalt_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_UpCorner_Asphalt_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_UpCorner_Asphalt_8x2_C

---@class FIN.classes.Satis.Build_Ramp_UpCorner_Asphalt_8x2_C : Satis.Build_Ramp_UpCorner_Asphalt_8x2_C
classes.Build_Ramp_UpCorner_Asphalt_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_UpCorner_Asphalt_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_UpCorner_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_Ramp_UpCorner_Asphalt_8x4_C : Satis.Build_Ramp_UpCorner_Asphalt_8x4_C
classes.Build_Ramp_UpCorner_Asphalt_8x4_C = nil

--- Snaps to other structural buildings.<br>
--- Frames provide a more open factory aesthetic.<br>
--- <br>
--- Size: 8 m x 0.5 m
---@class Satis.Build_Flat_Frame_01_C : Satis.FGBuildableFoundationLightweight
local Build_Flat_Frame_01_C

---@class FIN.classes.Satis.Build_Flat_Frame_01_C : Satis.Build_Flat_Frame_01_C
classes.Build_Flat_Frame_01_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Foundation_8x1_01_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_8x1_01_C

---@class FIN.classes.Satis.Build_Foundation_8x1_01_C : Satis.Build_Foundation_8x1_01_C
classes.Build_Foundation_8x1_01_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Foundation_8x2_01_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_8x2_01_C

---@class FIN.classes.Satis.Build_Foundation_8x2_01_C : Satis.Build_Foundation_8x2_01_C
classes.Build_Foundation_8x2_01_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Foundation_8x4_01_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_8x4_01_C

---@class FIN.classes.Satis.Build_Foundation_8x4_01_C : Satis.Build_Foundation_8x4_01_C
classes.Build_Foundation_8x4_01_C = nil

--- Snaps to other structural buildings.<br>
--- Frames provide a more open factory aesthetic.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Foundation_Frame_01_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_Frame_01_C

---@class FIN.classes.Satis.Build_Foundation_Frame_01_C : Satis.Build_Foundation_Frame_01_C
classes.Build_Foundation_Frame_01_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_FoundationGlass_01_C : Satis.FGBuildableFoundationLightweight
local Build_FoundationGlass_01_C

---@class FIN.classes.Satis.Build_FoundationGlass_01_C : Satis.Build_FoundationGlass_01_C
classes.Build_FoundationGlass_01_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipe_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipe_C

---@class FIN.classes.Satis.Build_QuarterPipe_C : Satis.Build_QuarterPipe_C
classes.Build_QuarterPipe_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipe_02_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipe_02_C

---@class FIN.classes.Satis.Build_QuarterPipe_02_C : Satis.Build_QuarterPipe_02_C
classes.Build_QuarterPipe_02_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeCorner_01_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeCorner_01_C

---@class FIN.classes.Satis.Build_QuarterPipeCorner_01_C : Satis.Build_QuarterPipeCorner_01_C
classes.Build_QuarterPipeCorner_01_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeCorner_02_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeCorner_02_C

---@class FIN.classes.Satis.Build_QuarterPipeCorner_02_C : Satis.Build_QuarterPipeCorner_02_C
classes.Build_QuarterPipeCorner_02_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeCorner_03_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeCorner_03_C

---@class FIN.classes.Satis.Build_QuarterPipeCorner_03_C : Satis.Build_QuarterPipeCorner_03_C
classes.Build_QuarterPipeCorner_03_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeCorner_04_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeCorner_04_C

---@class FIN.classes.Satis.Build_QuarterPipeCorner_04_C : Satis.Build_QuarterPipeCorner_04_C
classes.Build_QuarterPipeCorner_04_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_DownQuarterPipe_Concrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_DownQuarterPipe_Concrete_8x4_C

---@class FIN.classes.Satis.Build_DownQuarterPipe_Concrete_8x4_C : Satis.Build_DownQuarterPipe_Concrete_8x4_C
classes.Build_DownQuarterPipe_Concrete_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_DownQuarterPipeInCorner_Concrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_DownQuarterPipeInCorner_Concrete_8x4_C

---@class FIN.classes.Satis.Build_DownQuarterPipeInCorner_Concrete_8x4_C : Satis.Build_DownQuarterPipeInCorner_Concrete_8x4_C
classes.Build_DownQuarterPipeInCorner_Concrete_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_DownQuarterPipeOutCorner_Concrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_DownQuarterPipeOutCorner_Concrete_8x4_C

---@class FIN.classes.Satis.Build_DownQuarterPipeOutCorner_Concrete_8x4_C : Satis.Build_DownQuarterPipeOutCorner_Concrete_8x4_C
classes.Build_DownQuarterPipeOutCorner_Concrete_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Foundation_Concrete_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_Concrete_8x1_C

---@class FIN.classes.Satis.Build_Foundation_Concrete_8x1_C : Satis.Build_Foundation_Concrete_8x1_C
classes.Build_Foundation_Concrete_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Foundation_Concrete_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_Concrete_8x2_C

---@class FIN.classes.Satis.Build_Foundation_Concrete_8x2_C : Satis.Build_Foundation_Concrete_8x2_C
classes.Build_Foundation_Concrete_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Foundation_Concrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_Concrete_8x4_C

---@class FIN.classes.Satis.Build_Foundation_Concrete_8x4_C : Satis.Build_Foundation_Concrete_8x4_C
classes.Build_Foundation_Concrete_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_InvertedRamp_DCorner_Concrete_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_DCorner_Concrete_8x1_C

---@class FIN.classes.Satis.Build_InvertedRamp_DCorner_Concrete_8x1_C : Satis.Build_InvertedRamp_DCorner_Concrete_8x1_C
classes.Build_InvertedRamp_DCorner_Concrete_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_InvertedRamp_DCorner_Concrete_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_DCorner_Concrete_8x2_C

---@class FIN.classes.Satis.Build_InvertedRamp_DCorner_Concrete_8x2_C : Satis.Build_InvertedRamp_DCorner_Concrete_8x2_C
classes.Build_InvertedRamp_DCorner_Concrete_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_InvertedRamp_DCorner_Concrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_DCorner_Concrete_8x4_C

---@class FIN.classes.Satis.Build_InvertedRamp_DCorner_Concrete_8x4_C : Satis.Build_InvertedRamp_DCorner_Concrete_8x4_C
classes.Build_InvertedRamp_DCorner_Concrete_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_InvertedRamp_UCorner_Concrete_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_UCorner_Concrete_8x1_C

---@class FIN.classes.Satis.Build_InvertedRamp_UCorner_Concrete_8x1_C : Satis.Build_InvertedRamp_UCorner_Concrete_8x1_C
classes.Build_InvertedRamp_UCorner_Concrete_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_InvertedRamp_UCorner_Concrete_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_UCorner_Concrete_8x2_C

---@class FIN.classes.Satis.Build_InvertedRamp_UCorner_Concrete_8x2_C : Satis.Build_InvertedRamp_UCorner_Concrete_8x2_C
classes.Build_InvertedRamp_UCorner_Concrete_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_InvertedRamp_UCorner_Concrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_UCorner_Concrete_8x4_C

---@class FIN.classes.Satis.Build_InvertedRamp_UCorner_Concrete_8x4_C : Satis.Build_InvertedRamp_UCorner_Concrete_8x4_C
classes.Build_InvertedRamp_UCorner_Concrete_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipe_Concrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipe_Concrete_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipe_Concrete_8x4_C : Satis.Build_QuarterPipe_Concrete_8x4_C
classes.Build_QuarterPipe_Concrete_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeInCorner_Concrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeInCorner_Concrete_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeInCorner_Concrete_8x4_C : Satis.Build_QuarterPipeInCorner_Concrete_8x4_C
classes.Build_QuarterPipeInCorner_Concrete_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_QuarterPipeMiddle_Concrete_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_Concrete_8x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_Concrete_8x1_C : Satis.Build_QuarterPipeMiddle_Concrete_8x1_C
classes.Build_QuarterPipeMiddle_Concrete_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_QuarterPipeMiddle_Concrete_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_Concrete_8x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_Concrete_8x2_C : Satis.Build_QuarterPipeMiddle_Concrete_8x2_C
classes.Build_QuarterPipeMiddle_Concrete_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeMiddle_Concrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_Concrete_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_Concrete_8x4_C : Satis.Build_QuarterPipeMiddle_Concrete_8x4_C
classes.Build_QuarterPipeMiddle_Concrete_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_QuarterPipeMiddleInCorner_Concrete_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_Concrete_8x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_Concrete_8x1_C : Satis.Build_QuarterPipeMiddleInCorner_Concrete_8x1_C
classes.Build_QuarterPipeMiddleInCorner_Concrete_8x1_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_QuarterPipeMiddleInCorner_Concrete_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_Concrete_8x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_Concrete_8x2_C : Satis.Build_QuarterPipeMiddleInCorner_Concrete_8x2_C
classes.Build_QuarterPipeMiddleInCorner_Concrete_8x2_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeMiddleInCorner_Concrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_Concrete_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_Concrete_8x4_C : Satis.Build_QuarterPipeMiddleInCorner_Concrete_8x4_C
classes.Build_QuarterPipeMiddleInCorner_Concrete_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 1 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_Concrete_4x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_Concrete_4x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_Concrete_4x1_C : Satis.Build_QuarterPipeMiddleOutCorner_Concrete_4x1_C
classes.Build_QuarterPipeMiddleOutCorner_Concrete_4x1_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 2 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_Concrete_4x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_Concrete_4x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_Concrete_4x2_C : Satis.Build_QuarterPipeMiddleOutCorner_Concrete_4x2_C
classes.Build_QuarterPipeMiddleOutCorner_Concrete_4x2_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 4 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_Concrete_4x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_Concrete_4x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_Concrete_4x4_C : Satis.Build_QuarterPipeMiddleOutCorner_Concrete_4x4_C
classes.Build_QuarterPipeMiddleOutCorner_Concrete_4x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeOutCorner_Concrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeOutCorner_Concrete_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeOutCorner_Concrete_8x4_C : Satis.Build_QuarterPipeOutCorner_Concrete_8x4_C
classes.Build_QuarterPipeOutCorner_Concrete_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_DownCorner_Concrete_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_DownCorner_Concrete_8x1_C

---@class FIN.classes.Satis.Build_Ramp_DownCorner_Concrete_8x1_C : Satis.Build_Ramp_DownCorner_Concrete_8x1_C
classes.Build_Ramp_DownCorner_Concrete_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_DownCorner_Concrete_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_DownCorner_Concrete_8x2_C

---@class FIN.classes.Satis.Build_Ramp_DownCorner_Concrete_8x2_C : Satis.Build_Ramp_DownCorner_Concrete_8x2_C
classes.Build_Ramp_DownCorner_Concrete_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_DownCorner_Concrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_DownCorner_Concrete_8x4_C

---@class FIN.classes.Satis.Build_Ramp_DownCorner_Concrete_8x4_C : Satis.Build_Ramp_DownCorner_Concrete_8x4_C
classes.Build_Ramp_DownCorner_Concrete_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_UpCorner_Concrete_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_UpCorner_Concrete_8x1_C

---@class FIN.classes.Satis.Build_Ramp_UpCorner_Concrete_8x1_C : Satis.Build_Ramp_UpCorner_Concrete_8x1_C
classes.Build_Ramp_UpCorner_Concrete_8x1_C = nil

end
do

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_UpCorner_Concrete_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_UpCorner_Concrete_8x2_C

---@class FIN.classes.Satis.Build_Ramp_UpCorner_Concrete_8x2_C : Satis.Build_Ramp_UpCorner_Concrete_8x2_C
classes.Build_Ramp_UpCorner_Concrete_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_UpCorner_Concrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_UpCorner_Concrete_8x4_C

---@class FIN.classes.Satis.Build_Ramp_UpCorner_Concrete_8x4_C : Satis.Build_Ramp_UpCorner_Concrete_8x4_C
classes.Build_Ramp_UpCorner_Concrete_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_QuarterPipeMiddle_Ficsit_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_Ficsit_8x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_Ficsit_8x1_C : Satis.Build_QuarterPipeMiddle_Ficsit_8x1_C
classes.Build_QuarterPipeMiddle_Ficsit_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_QuarterPipeMiddle_Ficsit_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_Ficsit_8x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_Ficsit_8x2_C : Satis.Build_QuarterPipeMiddle_Ficsit_8x2_C
classes.Build_QuarterPipeMiddle_Ficsit_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeMiddle_Ficsit_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_Ficsit_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_Ficsit_8x4_C : Satis.Build_QuarterPipeMiddle_Ficsit_8x4_C
classes.Build_QuarterPipeMiddle_Ficsit_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_QuarterPipeMiddleInCorner_Ficsit_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_Ficsit_8x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_Ficsit_8x1_C : Satis.Build_QuarterPipeMiddleInCorner_Ficsit_8x1_C
classes.Build_QuarterPipeMiddleInCorner_Ficsit_8x1_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_QuarterPipeMiddleInCorner_Ficsit_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_Ficsit_8x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_Ficsit_8x2_C : Satis.Build_QuarterPipeMiddleInCorner_Ficsit_8x2_C
classes.Build_QuarterPipeMiddleInCorner_Ficsit_8x2_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeMiddleInCorner_Ficsit_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_Ficsit_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_Ficsit_8x4_C : Satis.Build_QuarterPipeMiddleInCorner_Ficsit_8x4_C
classes.Build_QuarterPipeMiddleInCorner_Ficsit_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 1 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_Ficsit_4x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_Ficsit_4x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_Ficsit_4x1_C : Satis.Build_QuarterPipeMiddleOutCorner_Ficsit_4x1_C
classes.Build_QuarterPipeMiddleOutCorner_Ficsit_4x1_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 2 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_Ficsit_4x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_Ficsit_4x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_Ficsit_4x2_C : Satis.Build_QuarterPipeMiddleOutCorner_Ficsit_4x2_C
classes.Build_QuarterPipeMiddleOutCorner_Ficsit_4x2_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 4 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_Ficsit_4x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_Ficsit_4x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_Ficsit_4x4_C : Satis.Build_QuarterPipeMiddleOutCorner_Ficsit_4x4_C
classes.Build_QuarterPipeMiddleOutCorner_Ficsit_4x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_DownQuarterPipe_Grip_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_DownQuarterPipe_Grip_8x4_C

---@class FIN.classes.Satis.Build_DownQuarterPipe_Grip_8x4_C : Satis.Build_DownQuarterPipe_Grip_8x4_C
classes.Build_DownQuarterPipe_Grip_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_DownQuarterPipeInCorner_Grip_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_DownQuarterPipeInCorner_Grip_8x4_C

---@class FIN.classes.Satis.Build_DownQuarterPipeInCorner_Grip_8x4_C : Satis.Build_DownQuarterPipeInCorner_Grip_8x4_C
classes.Build_DownQuarterPipeInCorner_Grip_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_DownQuarterPipeOutCorner_Grip_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_DownQuarterPipeOutCorner_Grip_8x4_C

---@class FIN.classes.Satis.Build_DownQuarterPipeOutCorner_Grip_8x4_C : Satis.Build_DownQuarterPipeOutCorner_Grip_8x4_C
classes.Build_DownQuarterPipeOutCorner_Grip_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Foundation_Metal_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_Metal_8x1_C

---@class FIN.classes.Satis.Build_Foundation_Metal_8x1_C : Satis.Build_Foundation_Metal_8x1_C
classes.Build_Foundation_Metal_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Foundation_Metal_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_Metal_8x2_C

---@class FIN.classes.Satis.Build_Foundation_Metal_8x2_C : Satis.Build_Foundation_Metal_8x2_C
classes.Build_Foundation_Metal_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Foundation_Metal_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_Metal_8x4_C

---@class FIN.classes.Satis.Build_Foundation_Metal_8x4_C : Satis.Build_Foundation_Metal_8x4_C
classes.Build_Foundation_Metal_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_InvertedRamp_DCorner_Metal_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_DCorner_Metal_8x1_C

---@class FIN.classes.Satis.Build_InvertedRamp_DCorner_Metal_8x1_C : Satis.Build_InvertedRamp_DCorner_Metal_8x1_C
classes.Build_InvertedRamp_DCorner_Metal_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_InvertedRamp_DCorner_Metal_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_DCorner_Metal_8x2_C

---@class FIN.classes.Satis.Build_InvertedRamp_DCorner_Metal_8x2_C : Satis.Build_InvertedRamp_DCorner_Metal_8x2_C
classes.Build_InvertedRamp_DCorner_Metal_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_InvertedRamp_DCorner_Metal_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_DCorner_Metal_8x4_C

---@class FIN.classes.Satis.Build_InvertedRamp_DCorner_Metal_8x4_C : Satis.Build_InvertedRamp_DCorner_Metal_8x4_C
classes.Build_InvertedRamp_DCorner_Metal_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_InvertedRamp_UCorner_Metal_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_UCorner_Metal_8x1_C

---@class FIN.classes.Satis.Build_InvertedRamp_UCorner_Metal_8x1_C : Satis.Build_InvertedRamp_UCorner_Metal_8x1_C
classes.Build_InvertedRamp_UCorner_Metal_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_InvertedRamp_UCorner_Metal_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_UCorner_Metal_8x2_C

---@class FIN.classes.Satis.Build_InvertedRamp_UCorner_Metal_8x2_C : Satis.Build_InvertedRamp_UCorner_Metal_8x2_C
classes.Build_InvertedRamp_UCorner_Metal_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_InvertedRamp_UCorner_Metal_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_UCorner_Metal_8x4_C

---@class FIN.classes.Satis.Build_InvertedRamp_UCorner_Metal_8x4_C : Satis.Build_InvertedRamp_UCorner_Metal_8x4_C
classes.Build_InvertedRamp_UCorner_Metal_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipe_Grip_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipe_Grip_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipe_Grip_8x4_C : Satis.Build_QuarterPipe_Grip_8x4_C
classes.Build_QuarterPipe_Grip_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeInCorner_Grip_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeInCorner_Grip_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeInCorner_Grip_8x4_C : Satis.Build_QuarterPipeInCorner_Grip_8x4_C
classes.Build_QuarterPipeInCorner_Grip_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_QuarterPipeMiddle_Grip_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_Grip_8x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_Grip_8x1_C : Satis.Build_QuarterPipeMiddle_Grip_8x1_C
classes.Build_QuarterPipeMiddle_Grip_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_QuarterPipeMiddle_Grip_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_Grip_8x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_Grip_8x2_C : Satis.Build_QuarterPipeMiddle_Grip_8x2_C
classes.Build_QuarterPipeMiddle_Grip_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeMiddle_Grip_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_Grip_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_Grip_8x4_C : Satis.Build_QuarterPipeMiddle_Grip_8x4_C
classes.Build_QuarterPipeMiddle_Grip_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_QuarterPipeMiddleInCorner_Grip_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_Grip_8x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_Grip_8x1_C : Satis.Build_QuarterPipeMiddleInCorner_Grip_8x1_C
classes.Build_QuarterPipeMiddleInCorner_Grip_8x1_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_QuarterPipeMiddleInCorner_Grip_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_Grip_8x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_Grip_8x2_C : Satis.Build_QuarterPipeMiddleInCorner_Grip_8x2_C
classes.Build_QuarterPipeMiddleInCorner_Grip_8x2_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeMiddleInCorner_Grip_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_Grip_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_Grip_8x4_C : Satis.Build_QuarterPipeMiddleInCorner_Grip_8x4_C
classes.Build_QuarterPipeMiddleInCorner_Grip_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 1 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_Grip_4x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_Grip_4x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_Grip_4x1_C : Satis.Build_QuarterPipeMiddleOutCorner_Grip_4x1_C
classes.Build_QuarterPipeMiddleOutCorner_Grip_4x1_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 2 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_Grip_4x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_Grip_4x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_Grip_4x2_C : Satis.Build_QuarterPipeMiddleOutCorner_Grip_4x2_C
classes.Build_QuarterPipeMiddleOutCorner_Grip_4x2_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 4 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_Grip_4x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_Grip_4x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_Grip_4x4_C : Satis.Build_QuarterPipeMiddleOutCorner_Grip_4x4_C
classes.Build_QuarterPipeMiddleOutCorner_Grip_4x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeOutCorner_Grip_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeOutCorner_Grip_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeOutCorner_Grip_8x4_C : Satis.Build_QuarterPipeOutCorner_Grip_8x4_C
classes.Build_QuarterPipeOutCorner_Grip_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_DownCorner_Metal_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_DownCorner_Metal_8x1_C

---@class FIN.classes.Satis.Build_Ramp_DownCorner_Metal_8x1_C : Satis.Build_Ramp_DownCorner_Metal_8x1_C
classes.Build_Ramp_DownCorner_Metal_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_DownCorner_Metal_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_DownCorner_Metal_8x2_C

---@class FIN.classes.Satis.Build_Ramp_DownCorner_Metal_8x2_C : Satis.Build_Ramp_DownCorner_Metal_8x2_C
classes.Build_Ramp_DownCorner_Metal_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_DownCorner_Metal_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_DownCorner_Metal_8x4_C

---@class FIN.classes.Satis.Build_Ramp_DownCorner_Metal_8x4_C : Satis.Build_Ramp_DownCorner_Metal_8x4_C
classes.Build_Ramp_DownCorner_Metal_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_UpCorner_Metal_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_UpCorner_Metal_8x1_C

---@class FIN.classes.Satis.Build_Ramp_UpCorner_Metal_8x1_C : Satis.Build_Ramp_UpCorner_Metal_8x1_C
classes.Build_Ramp_UpCorner_Metal_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_UpCorner_Metal_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_UpCorner_Metal_8x2_C

---@class FIN.classes.Satis.Build_Ramp_UpCorner_Metal_8x2_C : Satis.Build_Ramp_UpCorner_Metal_8x2_C
classes.Build_Ramp_UpCorner_Metal_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_UpCorner_Metal_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_UpCorner_Metal_8x4_C

---@class FIN.classes.Satis.Build_Ramp_UpCorner_Metal_8x4_C : Satis.Build_Ramp_UpCorner_Metal_8x4_C
classes.Build_Ramp_UpCorner_Metal_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_DownQuarterPipe_ConcretePolished_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_DownQuarterPipe_ConcretePolished_8x4_C

---@class FIN.classes.Satis.Build_DownQuarterPipe_ConcretePolished_8x4_C : Satis.Build_DownQuarterPipe_ConcretePolished_8x4_C
classes.Build_DownQuarterPipe_ConcretePolished_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_DownQuarterPipeInCorner_ConcretePolished_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_DownQuarterPipeInCorner_ConcretePolished_8x4_C

---@class FIN.classes.Satis.Build_DownQuarterPipeInCorner_ConcretePolished_8x4_C : Satis.Build_DownQuarterPipeInCorner_ConcretePolished_8x4_C
classes.Build_DownQuarterPipeInCorner_ConcretePolished_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_DownQuarterPipeOutCorner_ConcretePolished_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_DownQuarterPipeOutCorner_ConcretePolished_8x4_C

---@class FIN.classes.Satis.Build_DownQuarterPipeOutCorner_ConcretePolished_8x4_C : Satis.Build_DownQuarterPipeOutCorner_ConcretePolished_8x4_C
classes.Build_DownQuarterPipeOutCorner_ConcretePolished_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Foundation_ConcretePolished_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_ConcretePolished_8x1_C

---@class FIN.classes.Satis.Build_Foundation_ConcretePolished_8x1_C : Satis.Build_Foundation_ConcretePolished_8x1_C
classes.Build_Foundation_ConcretePolished_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Foundation_ConcretePolished_8x2_2_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_ConcretePolished_8x2_2_C

---@class FIN.classes.Satis.Build_Foundation_ConcretePolished_8x2_2_C : Satis.Build_Foundation_ConcretePolished_8x2_2_C
classes.Build_Foundation_ConcretePolished_8x2_2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Foundation_ConcretePolished_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_Foundation_ConcretePolished_8x4_C

---@class FIN.classes.Satis.Build_Foundation_ConcretePolished_8x4_C : Satis.Build_Foundation_ConcretePolished_8x4_C
classes.Build_Foundation_ConcretePolished_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_InvertedRamp_DCorner_Polished_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_DCorner_Polished_8x1_C

---@class FIN.classes.Satis.Build_InvertedRamp_DCorner_Polished_8x1_C : Satis.Build_InvertedRamp_DCorner_Polished_8x1_C
classes.Build_InvertedRamp_DCorner_Polished_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_InvertedRamp_DCorner_Polished_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_DCorner_Polished_8x2_C

---@class FIN.classes.Satis.Build_InvertedRamp_DCorner_Polished_8x2_C : Satis.Build_InvertedRamp_DCorner_Polished_8x2_C
classes.Build_InvertedRamp_DCorner_Polished_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_InvertedRamp_DCorner_Polished_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_DCorner_Polished_8x4_C

---@class FIN.classes.Satis.Build_InvertedRamp_DCorner_Polished_8x4_C : Satis.Build_InvertedRamp_DCorner_Polished_8x4_C
classes.Build_InvertedRamp_DCorner_Polished_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_InvertedRamp_UCorner_Polished_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_UCorner_Polished_8x1_C

---@class FIN.classes.Satis.Build_InvertedRamp_UCorner_Polished_8x1_C : Satis.Build_InvertedRamp_UCorner_Polished_8x1_C
classes.Build_InvertedRamp_UCorner_Polished_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_InvertedRamp_UCorner_Polished_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_UCorner_Polished_8x2_C

---@class FIN.classes.Satis.Build_InvertedRamp_UCorner_Polished_8x2_C : Satis.Build_InvertedRamp_UCorner_Polished_8x2_C
classes.Build_InvertedRamp_UCorner_Polished_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_InvertedRamp_UCorner_Polished_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_InvertedRamp_UCorner_Polished_8x4_C

---@class FIN.classes.Satis.Build_InvertedRamp_UCorner_Polished_8x4_C : Satis.Build_InvertedRamp_UCorner_Polished_8x4_C
classes.Build_InvertedRamp_UCorner_Polished_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipe_ConcretePolished_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipe_ConcretePolished_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipe_ConcretePolished_8x4_C : Satis.Build_QuarterPipe_ConcretePolished_8x4_C
classes.Build_QuarterPipe_ConcretePolished_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeInCorner_ConcretePolished_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeInCorner_ConcretePolished_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeInCorner_ConcretePolished_8x4_C : Satis.Build_QuarterPipeInCorner_ConcretePolished_8x4_C
classes.Build_QuarterPipeInCorner_ConcretePolished_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_QuarterPipeMiddle_PolishedConcrete_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_PolishedConcrete_8x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_PolishedConcrete_8x1_C : Satis.Build_QuarterPipeMiddle_PolishedConcrete_8x1_C
classes.Build_QuarterPipeMiddle_PolishedConcrete_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_QuarterPipeMiddle_PolishedConcrete_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_PolishedConcrete_8x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_PolishedConcrete_8x2_C : Satis.Build_QuarterPipeMiddle_PolishedConcrete_8x2_C
classes.Build_QuarterPipeMiddle_PolishedConcrete_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeMiddle_PolishedConcrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddle_PolishedConcrete_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddle_PolishedConcrete_8x4_C : Satis.Build_QuarterPipeMiddle_PolishedConcrete_8x4_C
classes.Build_QuarterPipeMiddle_PolishedConcrete_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x1_C : Satis.Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x1_C
classes.Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x1_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x2_C : Satis.Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x2_C
classes.Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x2_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x4_C : Satis.Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x4_C
classes.Build_QuarterPipeMiddleInCorner_PolishedConcrete_8x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 1 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x1_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x1_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x1_C : Satis.Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x1_C
classes.Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x1_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 2 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x2_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x2_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x2_C : Satis.Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x2_C
classes.Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x2_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 4 m x 4 m
---@class Satis.Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x4_C

---@class FIN.classes.Satis.Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x4_C : Satis.Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x4_C
classes.Build_QuarterPipeMiddleOutCorner_PolishedConcrete_4x4_C = nil

--- Provides an optional factory look that is smoother and offers possibilities for recreational activities. <br>
--- Still utilizes the standard Foundation building grid for improved building placement.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_QuarterPipeOutCorner_ConcretePolished_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_QuarterPipeOutCorner_ConcretePolished_8x4_C

---@class FIN.classes.Satis.Build_QuarterPipeOutCorner_ConcretePolished_8x4_C : Satis.Build_QuarterPipeOutCorner_ConcretePolished_8x4_C
classes.Build_QuarterPipeOutCorner_ConcretePolished_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_DownCorner_Polished_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_DownCorner_Polished_8x1_C

---@class FIN.classes.Satis.Build_Ramp_DownCorner_Polished_8x1_C : Satis.Build_Ramp_DownCorner_Polished_8x1_C
classes.Build_Ramp_DownCorner_Polished_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_DownCorner_Polished_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_DownCorner_Polished_8x2_C

---@class FIN.classes.Satis.Build_Ramp_DownCorner_Polished_8x2_C : Satis.Build_Ramp_DownCorner_Polished_8x2_C
classes.Build_Ramp_DownCorner_Polished_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_DownCorner_Polished_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_DownCorner_Polished_8x4_C

---@class FIN.classes.Satis.Build_Ramp_DownCorner_Polished_8x4_C : Satis.Build_Ramp_DownCorner_Polished_8x4_C
classes.Build_Ramp_DownCorner_Polished_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_UpCorner_Polished_8x1_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_UpCorner_Polished_8x1_C

---@class FIN.classes.Satis.Build_Ramp_UpCorner_Polished_8x1_C : Satis.Build_Ramp_UpCorner_Polished_8x1_C
classes.Build_Ramp_UpCorner_Polished_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_UpCorner_Polished_8x2_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_UpCorner_Polished_8x2_C

---@class FIN.classes.Satis.Build_Ramp_UpCorner_Polished_8x2_C : Satis.Build_Ramp_UpCorner_Polished_8x2_C
classes.Build_Ramp_UpCorner_Polished_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_UpCorner_Polished_8x4_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_UpCorner_Polished_8x4_C

---@class FIN.classes.Satis.Build_Ramp_UpCorner_Polished_8x4_C : Satis.Build_Ramp_UpCorner_Polished_8x4_C
classes.Build_Ramp_UpCorner_Polished_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_Diagonal_8x1_01_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_Diagonal_8x1_01_C

---@class FIN.classes.Satis.Build_Ramp_Diagonal_8x1_01_C : Satis.Build_Ramp_Diagonal_8x1_01_C
classes.Build_Ramp_Diagonal_8x1_01_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_Diagonal_8x1_02_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_Diagonal_8x1_02_C

---@class FIN.classes.Satis.Build_Ramp_Diagonal_8x1_02_C : Satis.Build_Ramp_Diagonal_8x1_02_C
classes.Build_Ramp_Diagonal_8x1_02_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_Diagonal_8x2_01_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_Diagonal_8x2_01_C

---@class FIN.classes.Satis.Build_Ramp_Diagonal_8x2_01_C : Satis.Build_Ramp_Diagonal_8x2_01_C
classes.Build_Ramp_Diagonal_8x2_01_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_Diagonal_8x2_02_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_Diagonal_8x2_02_C

---@class FIN.classes.Satis.Build_Ramp_Diagonal_8x2_02_C : Satis.Build_Ramp_Diagonal_8x2_02_C
classes.Build_Ramp_Diagonal_8x2_02_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_Diagonal_8x4_01_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_Diagonal_8x4_01_C

---@class FIN.classes.Satis.Build_Ramp_Diagonal_8x4_01_C : Satis.Build_Ramp_Diagonal_8x4_01_C
classes.Build_Ramp_Diagonal_8x4_01_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_Diagonal_8x4_02_C : Satis.FGBuildableFoundationLightweight
local Build_Ramp_Diagonal_8x4_02_C

---@class FIN.classes.Satis.Build_Ramp_Diagonal_8x4_02_C : Satis.Build_Ramp_Diagonal_8x4_02_C
classes.Build_Ramp_Diagonal_8x4_02_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_RampInverted_8x1_Corner_01_C : Satis.FGBuildableFoundationLightweight
local Build_RampInverted_8x1_Corner_01_C

---@class FIN.classes.Satis.Build_RampInverted_8x1_Corner_01_C : Satis.Build_RampInverted_8x1_Corner_01_C
classes.Build_RampInverted_8x1_Corner_01_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_RampInverted_8x1_Corner_02_C : Satis.FGBuildableFoundationLightweight
local Build_RampInverted_8x1_Corner_02_C

---@class FIN.classes.Satis.Build_RampInverted_8x1_Corner_02_C : Satis.Build_RampInverted_8x1_Corner_02_C
classes.Build_RampInverted_8x1_Corner_02_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_RampInverted_8x2_Corner_01_C : Satis.FGBuildableFoundationLightweight
local Build_RampInverted_8x2_Corner_01_C

---@class FIN.classes.Satis.Build_RampInverted_8x2_Corner_01_C : Satis.Build_RampInverted_8x2_Corner_01_C
classes.Build_RampInverted_8x2_Corner_01_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_RampInverted_8x2_Corner_02_C : Satis.FGBuildableFoundationLightweight
local Build_RampInverted_8x2_Corner_02_C

---@class FIN.classes.Satis.Build_RampInverted_8x2_Corner_02_C : Satis.Build_RampInverted_8x2_Corner_02_C
classes.Build_RampInverted_8x2_Corner_02_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_RampInverted_8x4_Corner_01_C : Satis.FGBuildableFoundationLightweight
local Build_RampInverted_8x4_Corner_01_C

---@class FIN.classes.Satis.Build_RampInverted_8x4_Corner_01_C : Satis.Build_RampInverted_8x4_Corner_01_C
classes.Build_RampInverted_8x4_Corner_01_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_RampInverted_8x4_Corner_02_C : Satis.FGBuildableFoundationLightweight
local Build_RampInverted_8x4_Corner_02_C

---@class FIN.classes.Satis.Build_RampInverted_8x4_Corner_02_C : Satis.Build_RampInverted_8x4_Corner_02_C
classes.Build_RampInverted_8x4_Corner_02_C = nil

--- 
---@class Satis.FGBuildableRamp : Satis.FGBuildableFoundation
local FGBuildableRamp

---@class FIN.classes.Satis.FGBuildableRamp : Satis.FGBuildableRamp
classes.FGBuildableRamp = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_InvertedRamp_Asphalt_8x1_C : Satis.FGBuildableRampLightweight
local Build_InvertedRamp_Asphalt_8x1_C

---@class FIN.classes.Satis.Build_InvertedRamp_Asphalt_8x1_C : Satis.Build_InvertedRamp_Asphalt_8x1_C
classes.Build_InvertedRamp_Asphalt_8x1_C = nil

--- 
---@class Satis.FGBuildableRampLightweight : Satis.FGBuildableRamp
local FGBuildableRampLightweight

---@class FIN.classes.Satis.FGBuildableRampLightweight : Satis.FGBuildableRampLightweight
classes.FGBuildableRampLightweight = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_InvertedRamp_Asphalt_8x2_C : Satis.FGBuildableRampLightweight
local Build_InvertedRamp_Asphalt_8x2_C

---@class FIN.classes.Satis.Build_InvertedRamp_Asphalt_8x2_C : Satis.Build_InvertedRamp_Asphalt_8x2_C
classes.Build_InvertedRamp_Asphalt_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_InvertedRamp_Asphalt_8x4_C : Satis.FGBuildableRampLightweight
local Build_InvertedRamp_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_InvertedRamp_Asphalt_8x4_C : Satis.Build_InvertedRamp_Asphalt_8x4_C
classes.Build_InvertedRamp_Asphalt_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_Asphalt_8x1_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Asphalt_8x1_C

---@class FIN.classes.Satis.Build_Ramp_Asphalt_8x1_C : Satis.Build_Ramp_Asphalt_8x1_C
classes.Build_Ramp_Asphalt_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_Asphalt_8x2_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Asphalt_8x2_C

---@class FIN.classes.Satis.Build_Ramp_Asphalt_8x2_C : Satis.Build_Ramp_Asphalt_8x2_C
classes.Build_Ramp_Asphalt_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_Asphalt_8x4_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_Ramp_Asphalt_8x4_C : Satis.Build_Ramp_Asphalt_8x4_C
classes.Build_Ramp_Asphalt_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_RampDouble_Asphalt_8x1_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_Asphalt_8x1_C

---@class FIN.classes.Satis.Build_RampDouble_Asphalt_8x1_C : Satis.Build_RampDouble_Asphalt_8x1_C
classes.Build_RampDouble_Asphalt_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_RampDouble_Asphalt_8x2_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_Asphalt_8x2_C

---@class FIN.classes.Satis.Build_RampDouble_Asphalt_8x2_C : Satis.Build_RampDouble_Asphalt_8x2_C
classes.Build_RampDouble_Asphalt_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_RampDouble_Asphalt_8x4_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_RampDouble_Asphalt_8x4_C : Satis.Build_RampDouble_Asphalt_8x4_C
classes.Build_RampDouble_Asphalt_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Stair_Asphalt_8x1_C : Satis.FGBuildableRampLightweight
local Build_Stair_Asphalt_8x1_C

---@class FIN.classes.Satis.Build_Stair_Asphalt_8x1_C : Satis.Build_Stair_Asphalt_8x1_C
classes.Build_Stair_Asphalt_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Stair_Asphalt_8x2_C : Satis.FGBuildableRampLightweight
local Build_Stair_Asphalt_8x2_C

---@class FIN.classes.Satis.Build_Stair_Asphalt_8x2_C : Satis.Build_Stair_Asphalt_8x2_C
classes.Build_Stair_Asphalt_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Stair_Asphalt_8x4_C : Satis.FGBuildableRampLightweight
local Build_Stair_Asphalt_8x4_C

---@class FIN.classes.Satis.Build_Stair_Asphalt_8x4_C : Satis.Build_Stair_Asphalt_8x4_C
classes.Build_Stair_Asphalt_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_InvertedRamp_Concrete_8x1_C : Satis.FGBuildableRampLightweight
local Build_InvertedRamp_Concrete_8x1_C

---@class FIN.classes.Satis.Build_InvertedRamp_Concrete_8x1_C : Satis.Build_InvertedRamp_Concrete_8x1_C
classes.Build_InvertedRamp_Concrete_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_InvertedRamp_Concrete_8x2_C : Satis.FGBuildableRampLightweight
local Build_InvertedRamp_Concrete_8x2_C

---@class FIN.classes.Satis.Build_InvertedRamp_Concrete_8x2_C : Satis.Build_InvertedRamp_Concrete_8x2_C
classes.Build_InvertedRamp_Concrete_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_InvertedRamp_Concrete_8x4_C : Satis.FGBuildableRampLightweight
local Build_InvertedRamp_Concrete_8x4_C

---@class FIN.classes.Satis.Build_InvertedRamp_Concrete_8x4_C : Satis.Build_InvertedRamp_Concrete_8x4_C
classes.Build_InvertedRamp_Concrete_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_Concrete_8x1_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Concrete_8x1_C

---@class FIN.classes.Satis.Build_Ramp_Concrete_8x1_C : Satis.Build_Ramp_Concrete_8x1_C
classes.Build_Ramp_Concrete_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_Concrete_8x2_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Concrete_8x2_C

---@class FIN.classes.Satis.Build_Ramp_Concrete_8x2_C : Satis.Build_Ramp_Concrete_8x2_C
classes.Build_Ramp_Concrete_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_Concrete_8x4_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Concrete_8x4_C

---@class FIN.classes.Satis.Build_Ramp_Concrete_8x4_C : Satis.Build_Ramp_Concrete_8x4_C
classes.Build_Ramp_Concrete_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_RampDouble_Concrete_8x1_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_Concrete_8x1_C

---@class FIN.classes.Satis.Build_RampDouble_Concrete_8x1_C : Satis.Build_RampDouble_Concrete_8x1_C
classes.Build_RampDouble_Concrete_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_RampDouble_Concrete_8x2_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_Concrete_8x2_C

---@class FIN.classes.Satis.Build_RampDouble_Concrete_8x2_C : Satis.Build_RampDouble_Concrete_8x2_C
classes.Build_RampDouble_Concrete_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_RampDouble_Concrete_8x4_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_Concrete_8x4_C

---@class FIN.classes.Satis.Build_RampDouble_Concrete_8x4_C : Satis.Build_RampDouble_Concrete_8x4_C
classes.Build_RampDouble_Concrete_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Stair_Concrete_8x1_C : Satis.FGBuildableRampLightweight
local Build_Stair_Concrete_8x1_C

---@class FIN.classes.Satis.Build_Stair_Concrete_8x1_C : Satis.Build_Stair_Concrete_8x1_C
classes.Build_Stair_Concrete_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Stair_Concrete_8x2_C : Satis.FGBuildableRampLightweight
local Build_Stair_Concrete_8x2_C

---@class FIN.classes.Satis.Build_Stair_Concrete_8x2_C : Satis.Build_Stair_Concrete_8x2_C
classes.Build_Stair_Concrete_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Stair_Concrete_8x4_C : Satis.FGBuildableRampLightweight
local Build_Stair_Concrete_8x4_C

---@class FIN.classes.Satis.Build_Stair_Concrete_8x4_C : Satis.Build_Stair_Concrete_8x4_C
classes.Build_Stair_Concrete_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Stair_FicsitSet_8x1_01_C : Satis.FGBuildableRampLightweight
local Build_Stair_FicsitSet_8x1_01_C

---@class FIN.classes.Satis.Build_Stair_FicsitSet_8x1_01_C : Satis.Build_Stair_FicsitSet_8x1_01_C
classes.Build_Stair_FicsitSet_8x1_01_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Stair_FicsitSet_8x2_01_C : Satis.FGBuildableRampLightweight
local Build_Stair_FicsitSet_8x2_01_C

---@class FIN.classes.Satis.Build_Stair_FicsitSet_8x2_01_C : Satis.Build_Stair_FicsitSet_8x2_01_C
classes.Build_Stair_FicsitSet_8x2_01_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Stair_FicsitSet_8x4_01_C : Satis.FGBuildableRampLightweight
local Build_Stair_FicsitSet_8x4_01_C

---@class FIN.classes.Satis.Build_Stair_FicsitSet_8x4_01_C : Satis.Build_Stair_FicsitSet_8x4_01_C
classes.Build_Stair_FicsitSet_8x4_01_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_InvertedRamp_Metal_8x1_C : Satis.FGBuildableRampLightweight
local Build_InvertedRamp_Metal_8x1_C

---@class FIN.classes.Satis.Build_InvertedRamp_Metal_8x1_C : Satis.Build_InvertedRamp_Metal_8x1_C
classes.Build_InvertedRamp_Metal_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_InvertedRamp_Metal_8x2_C : Satis.FGBuildableRampLightweight
local Build_InvertedRamp_Metal_8x2_C

---@class FIN.classes.Satis.Build_InvertedRamp_Metal_8x2_C : Satis.Build_InvertedRamp_Metal_8x2_C
classes.Build_InvertedRamp_Metal_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_InvertedRamp_Metal_8x4_C : Satis.FGBuildableRampLightweight
local Build_InvertedRamp_Metal_8x4_C

---@class FIN.classes.Satis.Build_InvertedRamp_Metal_8x4_C : Satis.Build_InvertedRamp_Metal_8x4_C
classes.Build_InvertedRamp_Metal_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_Metal_8x1_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Metal_8x1_C

---@class FIN.classes.Satis.Build_Ramp_Metal_8x1_C : Satis.Build_Ramp_Metal_8x1_C
classes.Build_Ramp_Metal_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_Metal_8x2_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Metal_8x2_C

---@class FIN.classes.Satis.Build_Ramp_Metal_8x2_C : Satis.Build_Ramp_Metal_8x2_C
classes.Build_Ramp_Metal_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_Metal_8x4_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Metal_8x4_C

---@class FIN.classes.Satis.Build_Ramp_Metal_8x4_C : Satis.Build_Ramp_Metal_8x4_C
classes.Build_Ramp_Metal_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_RampDouble_Metal_8x1_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_Metal_8x1_C

---@class FIN.classes.Satis.Build_RampDouble_Metal_8x1_C : Satis.Build_RampDouble_Metal_8x1_C
classes.Build_RampDouble_Metal_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_RampDouble_Metal_8x2_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_Metal_8x2_C

---@class FIN.classes.Satis.Build_RampDouble_Metal_8x2_C : Satis.Build_RampDouble_Metal_8x2_C
classes.Build_RampDouble_Metal_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_RampDouble_Metal_8x4_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_Metal_8x4_C

---@class FIN.classes.Satis.Build_RampDouble_Metal_8x4_C : Satis.Build_RampDouble_Metal_8x4_C
classes.Build_RampDouble_Metal_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Stair_GripMetal_8x1_C : Satis.FGBuildableRampLightweight
local Build_Stair_GripMetal_8x1_C

---@class FIN.classes.Satis.Build_Stair_GripMetal_8x1_C : Satis.Build_Stair_GripMetal_8x1_C
classes.Build_Stair_GripMetal_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Stair_GripMetal_8x2_C : Satis.FGBuildableRampLightweight
local Build_Stair_GripMetal_8x2_C

---@class FIN.classes.Satis.Build_Stair_GripMetal_8x2_C : Satis.Build_Stair_GripMetal_8x2_C
classes.Build_Stair_GripMetal_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Stair_GripMetal_8x4_C : Satis.FGBuildableRampLightweight
local Build_Stair_GripMetal_8x4_C

---@class FIN.classes.Satis.Build_Stair_GripMetal_8x4_C : Satis.Build_Stair_GripMetal_8x4_C
classes.Build_Stair_GripMetal_8x4_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_InvertedRamp_Polished_8x1_C : Satis.FGBuildableRampLightweight
local Build_InvertedRamp_Polished_8x1_C

---@class FIN.classes.Satis.Build_InvertedRamp_Polished_8x1_C : Satis.Build_InvertedRamp_Polished_8x1_C
classes.Build_InvertedRamp_Polished_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_InvertedRamp_Polished_8x2_C : Satis.FGBuildableRampLightweight
local Build_InvertedRamp_Polished_8x2_C

---@class FIN.classes.Satis.Build_InvertedRamp_Polished_8x2_C : Satis.Build_InvertedRamp_Polished_8x2_C
classes.Build_InvertedRamp_Polished_8x2_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_InvertedRamp_Polished_8x4_C : Satis.FGBuildableRampLightweight
local Build_InvertedRamp_Polished_8x4_C

---@class FIN.classes.Satis.Build_InvertedRamp_Polished_8x4_C : Satis.Build_InvertedRamp_Polished_8x4_C
classes.Build_InvertedRamp_Polished_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_Polished_8x1_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Polished_8x1_C

---@class FIN.classes.Satis.Build_Ramp_Polished_8x1_C : Satis.Build_Ramp_Polished_8x1_C
classes.Build_Ramp_Polished_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_Polished_8x2_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Polished_8x2_C

---@class FIN.classes.Satis.Build_Ramp_Polished_8x2_C : Satis.Build_Ramp_Polished_8x2_C
classes.Build_Ramp_Polished_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_Polished_8x4_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Polished_8x4_C

---@class FIN.classes.Satis.Build_Ramp_Polished_8x4_C : Satis.Build_Ramp_Polished_8x4_C
classes.Build_Ramp_Polished_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_RampDouble_Polished_8x1_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_Polished_8x1_C

---@class FIN.classes.Satis.Build_RampDouble_Polished_8x1_C : Satis.Build_RampDouble_Polished_8x1_C
classes.Build_RampDouble_Polished_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_RampDouble_Polished_8x2_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_Polished_8x2_C

---@class FIN.classes.Satis.Build_RampDouble_Polished_8x2_C : Satis.Build_RampDouble_Polished_8x2_C
classes.Build_RampDouble_Polished_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_RampDouble_Polished_8x4_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_Polished_8x4_C

---@class FIN.classes.Satis.Build_RampDouble_Polished_8x4_C : Satis.Build_RampDouble_Polished_8x4_C
classes.Build_RampDouble_Polished_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Stair_PolishedConcrete_8x1_C : Satis.FGBuildableRampLightweight
local Build_Stair_PolishedConcrete_8x1_C

---@class FIN.classes.Satis.Build_Stair_PolishedConcrete_8x1_C : Satis.Build_Stair_PolishedConcrete_8x1_C
classes.Build_Stair_PolishedConcrete_8x1_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Stair_PolishedConcrete_8x2_C : Satis.FGBuildableRampLightweight
local Build_Stair_PolishedConcrete_8x2_C

---@class FIN.classes.Satis.Build_Stair_PolishedConcrete_8x2_C : Satis.Build_Stair_PolishedConcrete_8x2_C
classes.Build_Stair_PolishedConcrete_8x2_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Foundation Stairs are just Ramps with extra steps.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Stair_PolishedConcrete_8x4_C : Satis.FGBuildableRampLightweight
local Build_Stair_PolishedConcrete_8x4_C

---@class FIN.classes.Satis.Build_Stair_PolishedConcrete_8x4_C : Satis.Build_Stair_PolishedConcrete_8x4_C
classes.Build_Stair_PolishedConcrete_8x4_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Ramp_8x1_01_C : Satis.FGBuildableRampLightweight
local Build_Ramp_8x1_01_C

---@class FIN.classes.Satis.Build_Ramp_8x1_01_C : Satis.Build_Ramp_8x1_01_C
classes.Build_Ramp_8x1_01_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Ramp_8x2_01_C : Satis.FGBuildableRampLightweight
local Build_Ramp_8x2_01_C

---@class FIN.classes.Satis.Build_Ramp_8x2_01_C : Satis.Build_Ramp_8x2_01_C
classes.Build_Ramp_8x2_01_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_8x4_01_C : Satis.FGBuildableRampLightweight
local Build_Ramp_8x4_01_C

---@class FIN.classes.Satis.Build_Ramp_8x4_01_C : Satis.Build_Ramp_8x4_01_C
classes.Build_Ramp_8x4_01_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_8x4_Inverted_01_C : Satis.FGBuildableRampLightweight
local Build_Ramp_8x4_Inverted_01_C

---@class FIN.classes.Satis.Build_Ramp_8x4_Inverted_01_C : Satis.Build_Ramp_8x4_Inverted_01_C
classes.Build_Ramp_8x4_Inverted_01_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 8 m
---@class Satis.Build_Ramp_8x8x8_C : Satis.FGBuildableRampLightweight
local Build_Ramp_8x8x8_C

---@class FIN.classes.Satis.Build_Ramp_8x8x8_C : Satis.Build_Ramp_8x8x8_C
classes.Build_Ramp_8x8x8_C = nil

--- Snaps to other structural buildings.<br>
--- Frames provide a more open factory aesthetic.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_Frame_01_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Frame_01_C

---@class FIN.classes.Satis.Build_Ramp_Frame_01_C : Satis.Build_Ramp_Frame_01_C
classes.Build_Ramp_Frame_01_C = nil

--- Snaps to other structural buildings.<br>
--- Frames provide a more open factory aesthetic.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Ramp_Frame_Inverted_01_C : Satis.FGBuildableRampLightweight
local Build_Ramp_Frame_Inverted_01_C

---@class FIN.classes.Satis.Build_Ramp_Frame_Inverted_01_C : Satis.Build_Ramp_Frame_Inverted_01_C
classes.Build_Ramp_Frame_Inverted_01_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_RampDouble_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_C

---@class FIN.classes.Satis.Build_RampDouble_C : Satis.Build_RampDouble_C
classes.Build_RampDouble_C = nil

--- Snaps to Foundations and makes it easier to get onto them.<br>
--- <br>
--- Buildings on top of the Ramp snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_RampDouble_8x1_C : Satis.FGBuildableRampLightweight
local Build_RampDouble_8x1_C

---@class FIN.classes.Satis.Build_RampDouble_8x1_C : Satis.Build_RampDouble_8x1_C
classes.Build_RampDouble_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_RampInverted_8x1_C : Satis.FGBuildableRampLightweight
local Build_RampInverted_8x1_C

---@class FIN.classes.Satis.Build_RampInverted_8x1_C : Satis.Build_RampInverted_8x1_C
classes.Build_RampInverted_8x1_C = nil

--- Provides a flat floor to build your factory on.<br>
--- <br>
--- Buildings on top of the Foundation snap to a grid, making it easier to line them up with each other.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_RampInverted_8x2_01_C : Satis.FGBuildableRampLightweight
local Build_RampInverted_8x2_01_C

---@class FIN.classes.Satis.Build_RampInverted_8x2_01_C : Satis.Build_RampInverted_8x2_01_C
classes.Build_RampInverted_8x2_01_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 0.5 m
---@class Satis.Build_Roof_A_01_C : Satis.FGBuildableRampLightweight
local Build_Roof_A_01_C

---@class FIN.classes.Satis.Build_Roof_A_01_C : Satis.Build_Roof_A_01_C
classes.Build_Roof_A_01_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Roof_A_02_C : Satis.FGBuildableRampLightweight
local Build_Roof_A_02_C

---@class FIN.classes.Satis.Build_Roof_A_02_C : Satis.Build_Roof_A_02_C
classes.Build_Roof_A_02_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Roof_A_03_C : Satis.FGBuildableRampLightweight
local Build_Roof_A_03_C

---@class FIN.classes.Satis.Build_Roof_A_03_C : Satis.Build_Roof_A_03_C
classes.Build_Roof_A_03_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Roof_A_04_C : Satis.FGBuildableRampLightweight
local Build_Roof_A_04_C

---@class FIN.classes.Satis.Build_Roof_A_04_C : Satis.Build_Roof_A_04_C
classes.Build_Roof_A_04_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x flat
---@class Satis.Build_Roof_Orange_01_C : Satis.FGBuildableRampLightweight
local Build_Roof_Orange_01_C

---@class FIN.classes.Satis.Build_Roof_Orange_01_C : Satis.Build_Roof_Orange_01_C
classes.Build_Roof_Orange_01_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Roof_Orange_02_C : Satis.FGBuildableRampLightweight
local Build_Roof_Orange_02_C

---@class FIN.classes.Satis.Build_Roof_Orange_02_C : Satis.Build_Roof_Orange_02_C
classes.Build_Roof_Orange_02_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Roof_Orange_03_C : Satis.FGBuildableRampLightweight
local Build_Roof_Orange_03_C

---@class FIN.classes.Satis.Build_Roof_Orange_03_C : Satis.Build_Roof_Orange_03_C
classes.Build_Roof_Orange_03_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Roof_Orange_04_C : Satis.FGBuildableRampLightweight
local Build_Roof_Orange_04_C

---@class FIN.classes.Satis.Build_Roof_Orange_04_C : Satis.Build_Roof_Orange_04_C
classes.Build_Roof_Orange_04_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x flat
---@class Satis.Build_Roof_Tar_01_C : Satis.FGBuildableRampLightweight
local Build_Roof_Tar_01_C

---@class FIN.classes.Satis.Build_Roof_Tar_01_C : Satis.Build_Roof_Tar_01_C
classes.Build_Roof_Tar_01_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Roof_Tar_02_C : Satis.FGBuildableRampLightweight
local Build_Roof_Tar_02_C

---@class FIN.classes.Satis.Build_Roof_Tar_02_C : Satis.Build_Roof_Tar_02_C
classes.Build_Roof_Tar_02_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Roof_Tar_03_C : Satis.FGBuildableRampLightweight
local Build_Roof_Tar_03_C

---@class FIN.classes.Satis.Build_Roof_Tar_03_C : Satis.Build_Roof_Tar_03_C
classes.Build_Roof_Tar_03_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Roof_Tar_04_C : Satis.FGBuildableRampLightweight
local Build_Roof_Tar_04_C

---@class FIN.classes.Satis.Build_Roof_Tar_04_C : Satis.Build_Roof_Tar_04_C
classes.Build_Roof_Tar_04_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x flat
---@class Satis.Build_Roof_Window_01_C : Satis.FGBuildableRampLightweight
local Build_Roof_Window_01_C

---@class FIN.classes.Satis.Build_Roof_Window_01_C : Satis.Build_Roof_Window_01_C
classes.Build_Roof_Window_01_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 1 m
---@class Satis.Build_Roof_Window_02_C : Satis.FGBuildableRampLightweight
local Build_Roof_Window_02_C

---@class FIN.classes.Satis.Build_Roof_Window_02_C : Satis.Build_Roof_Window_02_C
classes.Build_Roof_Window_02_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 2 m
---@class Satis.Build_Roof_Window_03_C : Satis.FGBuildableRampLightweight
local Build_Roof_Window_03_C

---@class FIN.classes.Satis.Build_Roof_Window_03_C : Satis.Build_Roof_Window_03_C
classes.Build_Roof_Window_03_C = nil

--- Snaps to Foundations, Walls, and other Roofs.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_Roof_Window_04_C : Satis.FGBuildableRampLightweight
local Build_Roof_Window_04_C

---@class FIN.classes.Satis.Build_Roof_Window_04_C : Satis.Build_Roof_Window_04_C
classes.Build_Roof_Window_04_C = nil

--- Provides a flat floor to build your factory on. <br>
--- Buildings on top of the foundation are adjusted to a grid, to make it easier to line them up to each other.
---@class Satis.Build_Foundation_Curved_Right_C : Satis.FGBuildableFoundation
local Build_Foundation_Curved_Right_C

---@class FIN.classes.Satis.Build_Foundation_Curved_Right_C : Satis.Build_Foundation_Curved_Right_C
classes.Build_Foundation_Curved_Right_C = nil

--- 
---@class Satis.FGBuildablePillar : Satis.FGBuildableFactoryBuilding
local FGBuildablePillar

---@class FIN.classes.Satis.FGBuildablePillar : Satis.FGBuildablePillar
classes.FGBuildablePillar = nil

--- 
---@class Satis.FGBuildablePillarLightweight : Satis.FGBuildablePillar
local FGBuildablePillarLightweight

---@class FIN.classes.Satis.FGBuildablePillarLightweight : Satis.FGBuildablePillarLightweight
classes.FGBuildablePillarLightweight = nil

--- Snaps to Pillars. Can be placed on surfaces like Foundations and Walls.
---@class Satis.Build_PillarBase_C : Satis.FGBuildablePillarLightweight
local Build_PillarBase_C

---@class FIN.classes.Satis.Build_PillarBase_C : Satis.Build_PillarBase_C
classes.Build_PillarBase_C = nil

--- Snaps to other Pillars. Can be placed on surfaces like Foundations and Walls.<br>
--- <br>
--- Size: 4 m x 4 m
---@class Satis.Build_PillarMiddle_C : Satis.FGBuildablePillarLightweight
local Build_PillarMiddle_C

---@class FIN.classes.Satis.Build_PillarMiddle_C : Satis.Build_PillarMiddle_C
classes.Build_PillarMiddle_C = nil

--- Snaps to other Pillars. Can be placed on surfaces like Foundations and Walls.<br>
--- <br>
--- Size: 4 m x 4 m
---@class Satis.Build_PillarMiddle_Concrete_C : Satis.FGBuildablePillarLightweight
local Build_PillarMiddle_Concrete_C

---@class FIN.classes.Satis.Build_PillarMiddle_Concrete_C : Satis.Build_PillarMiddle_Concrete_C
classes.Build_PillarMiddle_Concrete_C = nil

--- Snaps to other Pillars. Can be placed on surfaces like Foundations and Walls.<br>
--- <br>
--- Size: 4 m x 4 m
---@class Satis.Build_PillarMiddle_Frame_C : Satis.FGBuildablePillarLightweight
local Build_PillarMiddle_Frame_C

---@class FIN.classes.Satis.Build_PillarMiddle_Frame_C : Satis.Build_PillarMiddle_Frame_C
classes.Build_PillarMiddle_Frame_C = nil

--- Pillar Top
---@class Satis.Build_PillarTop_C : Satis.FGBuildablePillarLightweight
local Build_PillarTop_C

---@class FIN.classes.Satis.Build_PillarTop_C : Satis.Build_PillarTop_C
classes.Build_PillarTop_C = nil

--- Snaps to other Pillars. Can be placed on surfaces like Foundations and Walls.<br>
--- <br>
--- Size: 2 m x 4 m
---@class Satis.Build_Pillar_Small_Concrete_C : Satis.FGBuildablePillarLightweight
local Build_Pillar_Small_Concrete_C

---@class FIN.classes.Satis.Build_Pillar_Small_Concrete_C : Satis.Build_Pillar_Small_Concrete_C
classes.Build_Pillar_Small_Concrete_C = nil

--- Snaps to other Pillars. Can be placed on surfaces like Foundations and Walls.<br>
--- <br>
--- Size: 2 m x 4 m
---@class Satis.Build_Pillar_Small_Frame_C : Satis.FGBuildablePillarLightweight
local Build_Pillar_Small_Frame_C

---@class FIN.classes.Satis.Build_Pillar_Small_Frame_C : Satis.Build_Pillar_Small_Frame_C
classes.Build_Pillar_Small_Frame_C = nil

--- Snaps to other Pillars. Can be placed on surfaces like Foundations and Walls.<br>
--- <br>
--- Size: 2 m x 4 m
---@class Satis.Build_Pillar_Small_Metal_C : Satis.FGBuildablePillarLightweight
local Build_Pillar_Small_Metal_C

---@class FIN.classes.Satis.Build_Pillar_Small_Metal_C : Satis.Build_Pillar_Small_Metal_C
classes.Build_Pillar_Small_Metal_C = nil

--- Snaps to Pillars. Can be placed on surfaces like Foundations and Walls.
---@class Satis.Build_PillarBase_Small_C : Satis.FGBuildablePillarLightweight
local Build_PillarBase_Small_C

---@class FIN.classes.Satis.Build_PillarBase_Small_C : Satis.Build_PillarBase_Small_C
classes.Build_PillarBase_Small_C = nil

--- 
---@class Satis.FGBuildableStair : Satis.FGBuildableFactoryBuilding
local FGBuildableStair

---@class FIN.classes.Satis.FGBuildableStair : Satis.FGBuildableStair
classes.FGBuildableStair = nil

--- Snaps to Foundations.<br>
--- Simplifies access between floors of your structures.
---@class Satis.Build_Stairs_Left_01_C : Satis.FGBuildableStair
local Build_Stairs_Left_01_C

---@class FIN.classes.Satis.Build_Stairs_Left_01_C : Satis.Build_Stairs_Left_01_C
classes.Build_Stairs_Left_01_C = nil

--- Snaps to Foundations.<br>
--- Simplifies access between floors of your structures.
---@class Satis.Build_Stairs_Right_01_C : Satis.FGBuildableStair
local Build_Stairs_Right_01_C

---@class FIN.classes.Satis.Build_Stairs_Right_01_C : Satis.Build_Stairs_Right_01_C
classes.Build_Stairs_Right_01_C = nil

--- 
---@class Satis.FGBuildableWalkway : Satis.FGBuildableFactoryBuilding
local FGBuildableWalkway

---@class FIN.classes.Satis.FGBuildableWalkway : Satis.FGBuildableWalkway
classes.FGBuildableWalkway = nil

--- 
---@class Satis.FGBuildableWalkwayLightweight : Satis.FGBuildableWalkway
local FGBuildableWalkwayLightweight

---@class FIN.classes.Satis.FGBuildableWalkwayLightweight : Satis.FGBuildableWalkwayLightweight
classes.FGBuildableWalkwayLightweight = nil

end
do

--- Snaps to Foundations and other Walkways.<br>
--- Specifically designed for humans to walk on.
---@class Satis.Build_CatwalkCorner_C : Satis.FGBuildableWalkwayLightweight
local Build_CatwalkCorner_C

---@class FIN.classes.Satis.Build_CatwalkCorner_C : Satis.Build_CatwalkCorner_C
classes.Build_CatwalkCorner_C = nil

--- Snaps to Foundations and other Walkways.<br>
--- Specifically designed for humans to walk on.
---@class Satis.Build_CatwalkCross_C : Satis.FGBuildableWalkwayLightweight
local Build_CatwalkCross_C

---@class FIN.classes.Satis.Build_CatwalkCross_C : Satis.Build_CatwalkCross_C
classes.Build_CatwalkCross_C = nil

--- Snaps to Foundations and other Walkways.<br>
--- Specifically designed for humans to walk on.
---@class Satis.Build_CatwalkRamp_C : Satis.FGBuildableWalkwayLightweight
local Build_CatwalkRamp_C

---@class FIN.classes.Satis.Build_CatwalkRamp_C : Satis.Build_CatwalkRamp_C
classes.Build_CatwalkRamp_C = nil

--- Snaps to Foundations and other Walkways.<br>
--- Specifically designed for humans to walk on.
---@class Satis.Build_CatwalkStairs_C : Satis.FGBuildableWalkwayLightweight
local Build_CatwalkStairs_C

---@class FIN.classes.Satis.Build_CatwalkStairs_C : Satis.Build_CatwalkStairs_C
classes.Build_CatwalkStairs_C = nil

--- Snaps to Foundations and other Walkways.<br>
--- Specifically designed for humans to walk on.
---@class Satis.Build_CatwalkStraight_C : Satis.FGBuildableWalkwayLightweight
local Build_CatwalkStraight_C

---@class FIN.classes.Satis.Build_CatwalkStraight_C : Satis.Build_CatwalkStraight_C
classes.Build_CatwalkStraight_C = nil

--- Snaps to Foundations and other Walkways.<br>
--- Specifically designed for humans to walk on.
---@class Satis.Build_CatwalkT_C : Satis.FGBuildableWalkwayLightweight
local Build_CatwalkT_C

---@class FIN.classes.Satis.Build_CatwalkT_C : Satis.Build_CatwalkT_C
classes.Build_CatwalkT_C = nil

--- Snaps to Foundations and other Walkways.<br>
--- Specifically designed for humans to walk on.
---@class Satis.Build_WalkwayCross_C : Satis.FGBuildableWalkwayLightweight
local Build_WalkwayCross_C

---@class FIN.classes.Satis.Build_WalkwayCross_C : Satis.Build_WalkwayCross_C
classes.Build_WalkwayCross_C = nil

--- Snaps to Foundations and other Walkways.<br>
--- Specifically designed for humans to walk on.
---@class Satis.Build_WalkwayRamp_C : Satis.FGBuildableWalkwayLightweight
local Build_WalkwayRamp_C

---@class FIN.classes.Satis.Build_WalkwayRamp_C : Satis.Build_WalkwayRamp_C
classes.Build_WalkwayRamp_C = nil

--- Snaps to Foundations and other Walkways.<br>
--- Specifically designed for humans to walk on.
---@class Satis.Build_WalkwayT_C : Satis.FGBuildableWalkwayLightweight
local Build_WalkwayT_C

---@class FIN.classes.Satis.Build_WalkwayT_C : Satis.Build_WalkwayT_C
classes.Build_WalkwayT_C = nil

--- Snaps to Foundations and other Walkways.<br>
--- Specifically designed for humans to walk on.
---@class Satis.Build_WalkwayTrun_C : Satis.FGBuildableWalkwayLightweight
local Build_WalkwayTrun_C

---@class FIN.classes.Satis.Build_WalkwayTrun_C : Satis.Build_WalkwayTrun_C
classes.Build_WalkwayTrun_C = nil

--- Snaps to Foundations and other Walkways.<br>
--- Specifically designed for humans to walk on.
---@class Satis.Build_WalkwayStraight_C : Satis.FGBuildableWalkway
local Build_WalkwayStraight_C

---@class FIN.classes.Satis.Build_WalkwayStraight_C : Satis.Build_WalkwayStraight_C
classes.Build_WalkwayStraight_C = nil

--- Hides seams and makes Beam connections more visually pleasing.
---@class Satis.Build_Beam_Connector_C : Satis.FGBuildableFactoryBuilding
local Build_Beam_Connector_C

---@class FIN.classes.Satis.Build_Beam_Connector_C : Satis.Build_Beam_Connector_C
classes.Build_Beam_Connector_C = nil

--- Hides seams and makes Beam connections more visually pleasing.
---@class Satis.Build_Beam_Connector_Double_C : Satis.FGBuildableFactoryBuilding
local Build_Beam_Connector_Double_C

---@class FIN.classes.Satis.Build_Beam_Connector_Double_C : Satis.Build_Beam_Connector_Double_C
classes.Build_Beam_Connector_Double_C = nil

--- Snaps to Beams and various other structural buildings.<br>
--- Used to aesthetically connect beams to surfaces.
---@class Satis.Build_Beam_Support_C : Satis.FGBuildableFactoryBuilding
local Build_Beam_Support_C

---@class FIN.classes.Satis.Build_Beam_Support_C : Satis.Build_Beam_Support_C
classes.Build_Beam_Support_C = nil

--- 
---@class Satis.FGBuildableBlueprintDesigner : Satis.Buildable
local FGBuildableBlueprintDesigner

---@class FIN.classes.Satis.FGBuildableBlueprintDesigner : Satis.FGBuildableBlueprintDesigner
classes.FGBuildableBlueprintDesigner = nil

--- The Blueprint Designer is used to create custom factory designs and save them as Blueprints.<br>
--- Blueprints can be accessed from the Blueprint tab of the Build Menu.<br>
--- <br>
--- Note that buildings can only be placed in the Blueprint Designer if they are fully within the boundary frame.<br>
--- <br>
--- Dimensions: 32 m x 32 m x 32 m
---@class Satis.Build_BlueprintDesigner_C : Satis.FGBuildableBlueprintDesigner
local Build_BlueprintDesigner_C

---@class FIN.classes.Satis.Build_BlueprintDesigner_C : Satis.Build_BlueprintDesigner_C
classes.Build_BlueprintDesigner_C = nil

--- The Blueprint Designer is used to create custom factory designs and save them as Blueprints.<br>
--- Blueprints can be accessed from the Blueprint tab of the Build Menu.<br>
--- <br>
--- Note that buildings can only be placed in the Blueprint Designer if they are fully within the boundary frame.<br>
--- <br>
--- Dimensions: 40 m x 40 m x 40 m
---@class Satis.Build_BlueprintDesigner_MK2_C : Satis.FGBuildableBlueprintDesigner
local Build_BlueprintDesigner_MK2_C

---@class FIN.classes.Satis.Build_BlueprintDesigner_MK2_C : Satis.Build_BlueprintDesigner_MK2_C
classes.Build_BlueprintDesigner_MK2_C = nil

--- The Blueprint Designer is used to create custom factory designs and save them as Blueprints.<br>
--- Blueprints can be accessed from the Blueprint tab of the Build Menu.<br>
--- <br>
--- Note that buildings can only be placed in the Blueprint Designer if they are fully within the boundary frame.<br>
--- <br>
--- Dimensions: 48 m x 48 m x 48 m
---@class Satis.Build_BlueprintDesigner_Mk3_C : Satis.FGBuildableBlueprintDesigner
local Build_BlueprintDesigner_Mk3_C

---@class FIN.classes.Satis.Build_BlueprintDesigner_Mk3_C : Satis.Build_BlueprintDesigner_Mk3_C
classes.Build_BlueprintDesigner_Mk3_C = nil

--- 
---@class Satis.FGBuildableCalendar : Satis.Buildable
local FGBuildableCalendar

---@class FIN.classes.Satis.FGBuildableCalendar : Satis.FGBuildableCalendar
classes.FGBuildableCalendar = nil

--- 
---@class Satis.BP_ChristmasCalendar_C : Satis.FGBuildableCalendar
local BP_ChristmasCalendar_C

---@class FIN.classes.Satis.BP_ChristmasCalendar_C : Satis.BP_ChristmasCalendar_C
classes.BP_ChristmasCalendar_C = nil

--- A building that can connect two circuit networks together.
---@class Satis.CircuitBridge : Satis.Buildable
local CircuitBridge

---@class FIN.classes.Satis.CircuitBridge : Satis.CircuitBridge
classes.CircuitBridge = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
CircuitBridge.isBridgeConnected = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
CircuitBridge.isBridgeActive = nil

--- A circuit bridge that can be activated and deactivate by the player.
---@class Satis.CircuitSwitch : Satis.CircuitBridge
local CircuitSwitch

---@class FIN.classes.Satis.CircuitSwitch : Satis.CircuitSwitch
classes.CircuitSwitch = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
CircuitSwitch.isSwitchOn = nil

--- Changes the circuit switch state.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param state boolean The new switch state.
function CircuitSwitch:setIsSwitchOn(state) end

--- A circuit power switch that can be activated and deactivated based on a priority to prevent a full factory power shutdown.
---@class Satis.CircuitSwitchPriority : Satis.CircuitSwitch
local CircuitSwitchPriority

---@class FIN.classes.Satis.CircuitSwitchPriority : Satis.CircuitSwitchPriority
classes.CircuitSwitchPriority = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
CircuitSwitchPriority.priority = nil

--- Priority Power Switches can be ranked by priority. When power production is too low, Switches will start turning off automatically until the power stabilizes, starting with Priority Group 8.
---@class Satis.Build_PriorityPowerSwitch_C : Satis.CircuitSwitchPriority
local Build_PriorityPowerSwitch_C

---@class FIN.classes.Satis.Build_PriorityPowerSwitch_C : Satis.Build_PriorityPowerSwitch_C
classes.Build_PriorityPowerSwitch_C = nil

--- Enables/disables the connection between 2 power grids when switched ON/OFF.<br>
--- <br>
--- Note the A and B connector labels.
---@class Satis.Build_PowerSwitch_C : Satis.CircuitSwitch
local Build_PowerSwitch_C

---@class FIN.classes.Satis.Build_PowerSwitch_C : Satis.Build_PowerSwitch_C
classes.Build_PowerSwitch_C = nil

--- 
---@class Satis.FGBuildableControlPanelHost : Satis.CircuitBridge
local FGBuildableControlPanelHost

---@class FIN.classes.Satis.FGBuildableControlPanelHost : Satis.FGBuildableControlPanelHost
classes.FGBuildableControlPanelHost = nil

--- A control panel to configure multiple lights at once.
---@class Satis.LightsControlPanel : Satis.FGBuildableControlPanelHost
local LightsControlPanel

---@class FIN.classes.Satis.LightsControlPanel : Satis.LightsControlPanel
classes.LightsControlPanel = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
LightsControlPanel.isLightEnabled = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
LightsControlPanel.isTimeOfDayAware = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
LightsControlPanel.intensity = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
LightsControlPanel.colorSlot = nil

--- Allows to update the light color that is referenced by the given slot.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param slot number The slot you want to update the referencing color for.
---@param color Engine.Color The color this slot should now reference.
function LightsControlPanel:setColorFromSlot(slot, color) end

--- Sections off a series of lights, allowing them to be adjusted as a group.<br>
--- <br>
--- Controls all lights connected to the power grid via the Light Connector (yellow label).<br>
--- Note: Other Control Panels and Power Switches interrupt the connection.
---@class Satis.Build_LightsControlPanel_C : Satis.LightsControlPanel
local Build_LightsControlPanel_C

---@class FIN.classes.Satis.Build_LightsControlPanel_C : Satis.Build_LightsControlPanel_C
classes.Build_LightsControlPanel_C = nil

--- 
---@class Satis.FGBuildableConveyorBelt : Satis.FGBuildableConveyorBase
local FGBuildableConveyorBelt

---@class FIN.classes.Satis.FGBuildableConveyorBelt : Satis.FGBuildableConveyorBelt
classes.FGBuildableConveyorBelt = nil

--- 
---@class Satis.FGBuildableConveyorBase : Satis.Buildable
local FGBuildableConveyorBase

---@class FIN.classes.Satis.FGBuildableConveyorBase : Satis.FGBuildableConveyorBase
classes.FGBuildableConveyorBase = nil

--- Transports up to 60 resources per minute. Used to move resources between buildings.
---@class Satis.Build_ConveyorBeltMk1_C : Satis.FGBuildableConveyorBelt
local Build_ConveyorBeltMk1_C

---@class FIN.classes.Satis.Build_ConveyorBeltMk1_C : Satis.Build_ConveyorBeltMk1_C
classes.Build_ConveyorBeltMk1_C = nil

--- Transports up to 120 resources per minute. Used to move resources between buildings.
---@class Satis.Build_ConveyorBeltMk2_C : Satis.Build_ConveyorBeltMk1_C
local Build_ConveyorBeltMk2_C

---@class FIN.classes.Satis.Build_ConveyorBeltMk2_C : Satis.Build_ConveyorBeltMk2_C
classes.Build_ConveyorBeltMk2_C = nil

--- Transports up to 270 resources per minute. Used to move resources between buildings.
---@class Satis.Build_ConveyorBeltMk3_C : Satis.Build_ConveyorBeltMk1_C
local Build_ConveyorBeltMk3_C

---@class FIN.classes.Satis.Build_ConveyorBeltMk3_C : Satis.Build_ConveyorBeltMk3_C
classes.Build_ConveyorBeltMk3_C = nil

--- Transports up to 480 resources per minute. Used to move resources between buildings.
---@class Satis.Build_ConveyorBeltMk4_C : Satis.Build_ConveyorBeltMk1_C
local Build_ConveyorBeltMk4_C

---@class FIN.classes.Satis.Build_ConveyorBeltMk4_C : Satis.Build_ConveyorBeltMk4_C
classes.Build_ConveyorBeltMk4_C = nil

--- Transports up to 780 resources per minute. Used to move resources between buildings.
---@class Satis.Build_ConveyorBeltMk5_C : Satis.Build_ConveyorBeltMk1_C
local Build_ConveyorBeltMk5_C

---@class FIN.classes.Satis.Build_ConveyorBeltMk5_C : Satis.Build_ConveyorBeltMk5_C
classes.Build_ConveyorBeltMk5_C = nil

--- Transports up to 1200 resources per minute. Used to move resources between buildings.
---@class Satis.Build_ConveyorBeltMk6_C : Satis.Build_ConveyorBeltMk1_C
local Build_ConveyorBeltMk6_C

---@class FIN.classes.Satis.Build_ConveyorBeltMk6_C : Satis.Build_ConveyorBeltMk6_C
classes.Build_ConveyorBeltMk6_C = nil

--- 
---@class Satis.FGBuildableConveyorLift : Satis.FGBuildableConveyorBase
local FGBuildableConveyorLift

---@class FIN.classes.Satis.FGBuildableConveyorLift : Satis.FGBuildableConveyorLift
classes.FGBuildableConveyorLift = nil

--- Transports up to 60 resources per minute. Used to move resources between floors.
---@class Satis.Build_ConveyorLiftMk1_C : Satis.FGBuildableConveyorLift
local Build_ConveyorLiftMk1_C

---@class FIN.classes.Satis.Build_ConveyorLiftMk1_C : Satis.Build_ConveyorLiftMk1_C
classes.Build_ConveyorLiftMk1_C = nil

--- Transports up to 120 resources per minute. Used to move resources between floors.
---@class Satis.Build_ConveyorLiftMk2_C : Satis.Build_ConveyorLiftMk1_C
local Build_ConveyorLiftMk2_C

---@class FIN.classes.Satis.Build_ConveyorLiftMk2_C : Satis.Build_ConveyorLiftMk2_C
classes.Build_ConveyorLiftMk2_C = nil

--- Transports up to 270 resources per minute. Used to move resources between floors.
---@class Satis.Build_ConveyorLiftMk3_C : Satis.Build_ConveyorLiftMk1_C
local Build_ConveyorLiftMk3_C

---@class FIN.classes.Satis.Build_ConveyorLiftMk3_C : Satis.Build_ConveyorLiftMk3_C
classes.Build_ConveyorLiftMk3_C = nil

--- Transports up to 480 resources per minute. Used to move resources between floors.
---@class Satis.Build_ConveyorLiftMk4_C : Satis.Build_ConveyorLiftMk1_C
local Build_ConveyorLiftMk4_C

---@class FIN.classes.Satis.Build_ConveyorLiftMk4_C : Satis.Build_ConveyorLiftMk4_C
classes.Build_ConveyorLiftMk4_C = nil

--- Transports up to 780 resources per minute. Used to move resources between floors.
---@class Satis.Build_ConveyorLiftMk5_C : Satis.Build_ConveyorLiftMk1_C
local Build_ConveyorLiftMk5_C

---@class FIN.classes.Satis.Build_ConveyorLiftMk5_C : Satis.Build_ConveyorLiftMk5_C
classes.Build_ConveyorLiftMk5_C = nil

--- Transports up to 1200 resources per minute. Used to move resources between floors.
---@class Satis.Build_ConveyorLiftMk6_C : Satis.Build_ConveyorLiftMk1_C
local Build_ConveyorLiftMk6_C

---@class FIN.classes.Satis.Build_ConveyorLiftMk6_C : Satis.Build_ConveyorLiftMk6_C
classes.Build_ConveyorLiftMk6_C = nil

--- The base class for all light you can build.
---@class Satis.LightSource : Satis.Buildable
local LightSource

---@class FIN.classes.Satis.LightSource : Satis.LightSource
classes.LightSource = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
LightSource.isLightEnabled = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
LightSource.isTimeOfDayAware = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
LightSource.intensity = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
LightSource.colorSlot = nil

--- Returns the light color that is referenced by the given slot.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param slot number The slot you want to get the referencing color from.
---@return Engine.Color color The color this slot references.
function LightSource:getColorFromSlot(slot) end

--- Allows to update the light color that is referenced by the given slot.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param slot number The slot you want to update the referencing color for.
---@param color Engine.Color The color this slot should now reference.
function LightSource:setColorFromSlot(slot, color) end

--- 
---@class Satis.FGBuildableFloodlight : Satis.LightSource
local FGBuildableFloodlight

---@class FIN.classes.Satis.FGBuildableFloodlight : Satis.FGBuildableFloodlight
classes.FGBuildableFloodlight = nil

--- Illuminates large or outdoor spaces.<br>
--- <br>
--- Light color and intensity can be adjusted.<br>
--- Allows for up to 2 Power Line connections.
---@class Satis.Build_FloodlightPole_C : Satis.FGBuildableFloodlight
local Build_FloodlightPole_C

---@class FIN.classes.Satis.Build_FloodlightPole_C : Satis.Build_FloodlightPole_C
classes.Build_FloodlightPole_C = nil

--- Attaches to Walls and Foundations to illuminate large spaces.<br>
--- <br>
--- Light color and intensity can be modified via a Light Control Panel.<br>
--- Allows for up to 2 Power Line connections.
---@class Satis.Build_FloodlightWall_C : Satis.FGBuildableFloodlight
local Build_FloodlightWall_C

---@class FIN.classes.Satis.Build_FloodlightWall_C : Satis.Build_FloodlightWall_C
classes.Build_FloodlightWall_C = nil

--- Lights up indoor factory spaces when placed on ceilings.<br>
--- <br>
--- Light color and intensity can be adjusted via a Light Control Panel.<br>
--- Allows for up to 2 Power Line connections.
---@class Satis.Build_CeilingLight_C : Satis.LightSource
local Build_CeilingLight_C

---@class FIN.classes.Satis.Build_CeilingLight_C : Satis.Build_CeilingLight_C
classes.Build_CeilingLight_C = nil

--- Lights up factory areas and roads.<br>
--- <br>
--- Light color and intensity can be adjusted.<br>
--- Allows for up to 2 Power Line connections.
---@class Satis.Build_StreetLight_C : Satis.LightSource
local Build_StreetLight_C

---@class FIN.classes.Satis.Build_StreetLight_C : Satis.Build_StreetLight_C
classes.Build_StreetLight_C = nil

--- 
---@class Satis.FGBuildableHubTerminal : Satis.Buildable
local FGBuildableHubTerminal

---@class FIN.classes.Satis.FGBuildableHubTerminal : Satis.FGBuildableHubTerminal
classes.FGBuildableHubTerminal = nil

--- 
---@class Satis.Build_HubTerminal_C : Satis.FGBuildableHubTerminal
local Build_HubTerminal_C

---@class FIN.classes.Satis.Build_HubTerminal_C : Satis.Build_HubTerminal_C
classes.Build_HubTerminal_C = nil

--- Snaps to Walls and Foundations. Default height is 2 m, but it can be extended while building.
---@class Satis.Build_Ladder_C : Satis.FGBuildableLadder
local Build_Ladder_C

---@class FIN.classes.Satis.Build_Ladder_C : Satis.Build_Ladder_C
classes.Build_Ladder_C = nil

--- 
---@class Satis.FGBuildableLadder : Satis.Buildable
local FGBuildableLadder

---@class FIN.classes.Satis.FGBuildableLadder : Satis.FGBuildableLadder
classes.FGBuildableLadder = nil

--- 
---@class Satis.FGBuildableMAM : Satis.Buildable
local FGBuildableMAM

---@class FIN.classes.Satis.FGBuildableMAM : Satis.FGBuildableMAM
classes.FGBuildableMAM = nil

--- The Molecular Analysis Machine is used to analyze new and exotic materials found on alien planets.<br>
--- Through the MAM, R&D will assist pioneers in turning any valuable data into usable research options and new technologies.
---@class Satis.Build_Mam_C : Satis.FGBuildableMAM
local Build_Mam_C

---@class FIN.classes.Satis.Build_Mam_C : Satis.Build_Mam_C
classes.Build_Mam_C = nil

--- 
---@class Satis.FGBuildablePassthroughBase : Satis.Buildable
local FGBuildablePassthroughBase

---@class FIN.classes.Satis.FGBuildablePassthroughBase : Satis.FGBuildablePassthroughBase
classes.FGBuildablePassthroughBase = nil

--- 
---@class Satis.FGBuildablePassthrough : Satis.FGBuildablePassthroughBase
local FGBuildablePassthrough

---@class FIN.classes.Satis.FGBuildablePassthrough : Satis.FGBuildablePassthrough
classes.FGBuildablePassthrough = nil

--- Attaches to Foundations, allowing Conveyor Lifts to pass through.
---@class Satis.Build_FoundationPassthrough_Lift_C : Satis.FGBuildablePassthrough
local Build_FoundationPassthrough_Lift_C

---@class FIN.classes.Satis.Build_FoundationPassthrough_Lift_C : Satis.Build_FoundationPassthrough_Lift_C
classes.Build_FoundationPassthrough_Lift_C = nil

--- Attaches to Foundations, allowing Pipelines to pass through.
---@class Satis.Build_FoundationPassthrough_Pipe_C : Satis.FGBuildablePassthrough
local Build_FoundationPassthrough_Pipe_C

---@class FIN.classes.Satis.Build_FoundationPassthrough_Pipe_C : Satis.Build_FoundationPassthrough_Pipe_C
classes.Build_FoundationPassthrough_Pipe_C = nil

--- 
---@class Satis.FGBuildablePassthroughPipeHyper : Satis.FGBuildablePassthroughBase
local FGBuildablePassthroughPipeHyper

---@class FIN.classes.Satis.FGBuildablePassthroughPipeHyper : Satis.FGBuildablePassthroughPipeHyper
classes.FGBuildablePassthroughPipeHyper = nil

--- Attaches to Foundations, allowing Hypertubes to pass through.
---@class Satis.Build_FoundationPassthrough_Hypertube_C : Satis.FGBuildablePassthroughPipeHyper
local Build_FoundationPassthrough_Hypertube_C

---@class FIN.classes.Satis.Build_FoundationPassthrough_Hypertube_C : Satis.Build_FoundationPassthrough_Hypertube_C
classes.Build_FoundationPassthrough_Hypertube_C = nil

--- 
---@class Satis.FGBuildablePipeBase : Satis.Buildable
local FGBuildablePipeBase

---@class FIN.classes.Satis.FGBuildablePipeBase : Satis.FGBuildablePipeBase
classes.FGBuildablePipeBase = nil

--- A hypertube pipe
---@class Satis.BuildablePipeHyper : Satis.FGBuildablePipeBase
local BuildablePipeHyper

---@class FIN.classes.Satis.BuildablePipeHyper : Satis.BuildablePipeHyper
classes.BuildablePipeHyper = nil

--- Transports FICSIT employees.<br>
--- A Hypertube system cannot be powered up or used until a Hypertube Entrance is attached.
---@class Satis.Build_PipeHyper_C : Satis.BuildablePipeHyper
local Build_PipeHyper_C

---@class FIN.classes.Satis.Build_PipeHyper_C : Satis.Build_PipeHyper_C
classes.Build_PipeHyper_C = nil

--- 
---@class Satis.FGBuildablePipeline : Satis.FGBuildablePipeBase
local FGBuildablePipeline

---@class FIN.classes.Satis.FGBuildablePipeline : Satis.FGBuildablePipeline
classes.FGBuildablePipeline = nil

--- Transports fluids.<br>
--- External indicators show flow rate, direction, and volume.<br>
--- Capacity: 300 m³ of fluid per minute.
---@class Satis.Build_Pipeline_C : Satis.FGBuildablePipeline
local Build_Pipeline_C

---@class FIN.classes.Satis.Build_Pipeline_C : Satis.Build_Pipeline_C
classes.Build_Pipeline_C = nil

--- Transports fluids.<br>
--- Capacity: 300 m³ of fluid per minute.<br>
--- <br>
--- Caution: This version of the Pipeline does not feature an external indicator.
---@class Satis.Build_Pipeline_NoIndicator_C : Satis.Build_Pipeline_C
local Build_Pipeline_NoIndicator_C

---@class FIN.classes.Satis.Build_Pipeline_NoIndicator_C : Satis.Build_Pipeline_NoIndicator_C
classes.Build_Pipeline_NoIndicator_C = nil

--- Transports fluids.<br>
--- External indicators show flow rate, direction, and volume.<br>
--- Capacity: 600 m³ of fluid per minute.
---@class Satis.Build_PipelineMK2_C : Satis.FGBuildablePipeline
local Build_PipelineMK2_C

---@class FIN.classes.Satis.Build_PipelineMK2_C : Satis.Build_PipelineMK2_C
classes.Build_PipelineMK2_C = nil

--- Transports fluids.<br>
--- Capacity: 600 m³ of fluid per minute.<br>
--- <br>
--- Caution: This version of the Pipeline does not feature an external indicator.
---@class Satis.Build_PipelineMK2_NoIndicator_C : Satis.Build_PipelineMK2_C
local Build_PipelineMK2_NoIndicator_C

---@class FIN.classes.Satis.Build_PipelineMK2_NoIndicator_C : Satis.Build_PipelineMK2_NoIndicator_C
classes.Build_PipelineMK2_NoIndicator_C = nil

--- 
---@class Satis.FGBuildablePipelineFlowIndicator : Satis.Buildable
local FGBuildablePipelineFlowIndicator

---@class FIN.classes.Satis.FGBuildablePipelineFlowIndicator : Satis.FGBuildablePipelineFlowIndicator
classes.FGBuildablePipelineFlowIndicator = nil

--- 
---@class Satis.Build_PipelineFlowIndicator_C : Satis.FGBuildablePipelineFlowIndicator
local Build_PipelineFlowIndicator_C

---@class FIN.classes.Satis.Build_PipelineFlowIndicator_C : Satis.Build_PipelineFlowIndicator_C
classes.Build_PipelineFlowIndicator_C = nil

--- 
---@class Satis.FGBuildablePipelineSupport : Satis.FGBuildablePoleBase
local FGBuildablePipelineSupport

---@class FIN.classes.Satis.FGBuildablePipelineSupport : Satis.FGBuildablePipelineSupport
classes.FGBuildablePipelineSupport = nil

--- 
---@class Satis.FGBuildablePoleBase : Satis.Buildable
local FGBuildablePoleBase

---@class FIN.classes.Satis.FGBuildablePoleBase : Satis.FGBuildablePoleBase
classes.FGBuildablePoleBase = nil

--- Supports Hypertubes, allowing them to stretch over longer distances.
---@class Satis.Build_PipeHyperSupport_C : Satis.FGBuildablePipelineSupport
local Build_PipeHyperSupport_C

---@class FIN.classes.Satis.Build_PipeHyperSupport_C : Satis.Build_PipeHyperSupport_C
classes.Build_PipeHyperSupport_C = nil

--- Supports Hypertubes. Can be stacked on other stackable supports.
---@class Satis.Build_HyperPoleStackable_C : Satis.FGBuildablePipelineSupport
local Build_HyperPoleStackable_C

---@class FIN.classes.Satis.Build_HyperPoleStackable_C : Satis.Build_HyperPoleStackable_C
classes.Build_HyperPoleStackable_C = nil

--- Connects Pipeline segments. Support height can be adjusted.<br>
--- Useful for routing Pipelines more precisely and across long distances.
---@class Satis.Build_PipelineSupport_C : Satis.FGBuildablePipelineSupport
local Build_PipelineSupport_C

---@class FIN.classes.Satis.Build_PipelineSupport_C : Satis.Build_PipelineSupport_C
classes.Build_PipelineSupport_C = nil

--- Supports Pipelines. Can be stacked on other stackable supports.
---@class Satis.Build_PipeSupportStackable_C : Satis.FGBuildablePipelineSupport
local Build_PipeSupportStackable_C

---@class FIN.classes.Satis.Build_PipeSupportStackable_C : Satis.Build_PipeSupportStackable_C
classes.Build_PipeSupportStackable_C = nil

--- Connects Conveyor Belt segments. Pole height can be adjusted.<br>
--- Useful for routing Conveyor Belts more precisely and across long distances.
---@class Satis.Build_ConveyorPole_C : Satis.FGBuildablePoleLightweight
local Build_ConveyorPole_C

---@class FIN.classes.Satis.Build_ConveyorPole_C : Satis.Build_ConveyorPole_C
classes.Build_ConveyorPole_C = nil

--- 
---@class Satis.FGBuildablePoleLightweight : Satis.FGBuildablePole
local FGBuildablePoleLightweight

---@class FIN.classes.Satis.FGBuildablePoleLightweight : Satis.FGBuildablePoleLightweight
classes.FGBuildablePoleLightweight = nil

--- 
---@class Satis.FGBuildablePole : Satis.FGBuildablePoleBase
local FGBuildablePole

---@class FIN.classes.Satis.FGBuildablePole : Satis.FGBuildablePole
classes.FGBuildablePole = nil

--- 
---@class Satis.FGConveyorPoleStackable : Satis.FGBuildablePole
local FGConveyorPoleStackable

---@class FIN.classes.Satis.FGConveyorPoleStackable : Satis.FGConveyorPoleStackable
classes.FGConveyorPoleStackable = nil

--- Supports Conveyor Belts. Can be stacked on other stackable supports.
---@class Satis.Build_ConveyorPoleStackable_C : Satis.FGConveyorPoleStackable
local Build_ConveyorPoleStackable_C

---@class FIN.classes.Satis.Build_ConveyorPoleStackable_C : Satis.Build_ConveyorPoleStackable_C
classes.Build_ConveyorPoleStackable_C = nil

--- 
---@class Satis.FGBuildableSignSupport : Satis.FGBuildablePoleBase
local FGBuildableSignSupport

---@class FIN.classes.Satis.FGBuildableSignSupport : Satis.FGBuildableSignSupport
classes.FGBuildableSignSupport = nil

--- 
---@class Satis.Build_SignPole_C : Satis.FGBuildableSignSupport
local Build_SignPole_C

---@class FIN.classes.Satis.Build_SignPole_C : Satis.Build_SignPole_C
classes.Build_SignPole_C = nil

--- Attaches to ceilings and other ceiling mounts.<br>
--- Useful for routing Conveyor Belts more precisely and over long distances.
---@class Satis.Build_ConveyorCeilingAttachment_C : Satis.FGBuildablePoleBase
local Build_ConveyorCeilingAttachment_C

---@class FIN.classes.Satis.Build_ConveyorCeilingAttachment_C : Satis.Build_ConveyorCeilingAttachment_C
classes.Build_ConveyorCeilingAttachment_C = nil

--- 
---@class Satis.FGBuildablePixelSign : Satis.SignBase
local FGBuildablePixelSign

---@class FIN.classes.Satis.FGBuildablePixelSign : Satis.FGBuildablePixelSign
classes.FGBuildablePixelSign = nil

--- The base class for all signs in the game.
---@class Satis.SignBase : Satis.Buildable
local SignBase

---@class FIN.classes.Satis.SignBase : Satis.SignBase
classes.SignBase = nil

--- Returns the sign type descriptor
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.SignType descriptor The sign type descriptor
function SignBase:getSignType() end

--- Improves factory organization. The colors, icons, background, and text are customizable.<br>
--- <br>
--- Can be freestanding, placed on Walls, or attached to most buildings, including Storage Containers.<br>
--- <br>
--- Size: 16 m x 8 m
---@class Satis.Build_StandaloneWidgetSign_Huge_C : Satis.WidgetSign
local Build_StandaloneWidgetSign_Huge_C

---@class FIN.classes.Satis.Build_StandaloneWidgetSign_Huge_C : Satis.Build_StandaloneWidgetSign_Huge_C
classes.Build_StandaloneWidgetSign_Huge_C = nil

--- The type of sign that allows you to define layouts, images, texts and colors manually.
---@class Satis.WidgetSign : Satis.SignBase
local WidgetSign

---@class FIN.classes.Satis.WidgetSign : Satis.WidgetSign
classes.WidgetSign = nil

--- Sets the prefabg sign data e.g. the user settings like colo and more to define the signs content.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param prefabSignData Satis.PrefabSignData The new prefab sign data for this sign.
function WidgetSign:setPrefabSignData(prefabSignData) end

--- Returns the prefabg sign data e.g. the user settings like colo and more to define the signs content.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.PrefabSignData prefabSignData The new prefab sign data for this sign.
function WidgetSign:getPrefabSignData() end

--- Improves factory organization. The colors, icons, background, and text are customizable.<br>
--- <br>
--- Can be freestanding, placed on Walls, or attached to most buildings, including Storage Containers.<br>
--- <br>
--- Size: 8 m x 4 m
---@class Satis.Build_StandaloneWidgetSign_Large_C : Satis.WidgetSign
local Build_StandaloneWidgetSign_Large_C

---@class FIN.classes.Satis.Build_StandaloneWidgetSign_Large_C : Satis.Build_StandaloneWidgetSign_Large_C
classes.Build_StandaloneWidgetSign_Large_C = nil

--- Improves factory organization. The colors, icons, background, and text are customizable.<br>
--- <br>
--- Can be freestanding, placed on Walls, or attached to most buildings, including Storage Containers.<br>
--- <br>
--- Size: 2 m x 1 m
---@class Satis.Build_StandaloneWidgetSign_Medium_C : Satis.WidgetSign
local Build_StandaloneWidgetSign_Medium_C

---@class FIN.classes.Satis.Build_StandaloneWidgetSign_Medium_C : Satis.Build_StandaloneWidgetSign_Medium_C
classes.Build_StandaloneWidgetSign_Medium_C = nil

--- Improves factory organization. The colors, icons, background, and text are customizable.<br>
--- <br>
--- Can be freestanding, placed on Walls, or attached to most buildings, including Storage Containers.<br>
--- <br>
--- Size: 2 m x 3 m
---@class Satis.Build_StandaloneWidgetSign_Portrait_C : Satis.WidgetSign
local Build_StandaloneWidgetSign_Portrait_C

---@class FIN.classes.Satis.Build_StandaloneWidgetSign_Portrait_C : Satis.Build_StandaloneWidgetSign_Portrait_C
classes.Build_StandaloneWidgetSign_Portrait_C = nil

--- Improves factory organization. The colors, icons, background, and text are customizable.<br>
--- <br>
--- Can be freestanding, placed on Walls, or attached to most buildings, including Storage Containers.<br>
--- <br>
--- Size: 2 m x 0.5 m
---@class Satis.Build_StandaloneWidgetSign_Small_C : Satis.WidgetSign
local Build_StandaloneWidgetSign_Small_C

---@class FIN.classes.Satis.Build_StandaloneWidgetSign_Small_C : Satis.Build_StandaloneWidgetSign_Small_C
classes.Build_StandaloneWidgetSign_Small_C = nil

--- Improves factory organization. The colors, icons, background, and text are customizable.<br>
--- <br>
--- Can be freestanding, placed on Walls, or attached to most buildings, including Storage Containers.<br>
--- <br>
--- Size: 4 m x 0.5 m
---@class Satis.Build_StandaloneWidgetSign_SmallVeryWide_C : Satis.WidgetSign
local Build_StandaloneWidgetSign_SmallVeryWide_C

---@class FIN.classes.Satis.Build_StandaloneWidgetSign_SmallVeryWide_C : Satis.Build_StandaloneWidgetSign_SmallVeryWide_C
classes.Build_StandaloneWidgetSign_SmallVeryWide_C = nil

--- Improves factory organization. The colors, icons, background, and text are customizable.<br>
--- <br>
--- Can be freestanding, placed on Walls, or attached to most buildings, including Storage Containers.<br>
--- <br>
--- Size: 3 m x 0.5 m
---@class Satis.Build_StandaloneWidgetSign_SmallWide_C : Satis.WidgetSign
local Build_StandaloneWidgetSign_SmallWide_C

---@class FIN.classes.Satis.Build_StandaloneWidgetSign_SmallWide_C : Satis.Build_StandaloneWidgetSign_SmallWide_C
classes.Build_StandaloneWidgetSign_SmallWide_C = nil

--- Improves factory organization. The colors, icons, background, and text are customizable.<br>
--- <br>
--- Can be freestanding, placed on Walls, or attached to most buildings, including Storage Containers.<br>
--- <br>
--- Size: 2 m x 2 m
---@class Satis.Build_StandaloneWidgetSign_Square_C : Satis.WidgetSign
local Build_StandaloneWidgetSign_Square_C

---@class FIN.classes.Satis.Build_StandaloneWidgetSign_Square_C : Satis.Build_StandaloneWidgetSign_Square_C
classes.Build_StandaloneWidgetSign_Square_C = nil

--- Improves factory organization. The colors, icons, background, and text are customizable.<br>
--- <br>
--- Can be freestanding, placed on Walls, or attached to most buildings, including Storage Containers.<br>
--- <br>
--- Size: 1 m x 1 m
---@class Satis.Build_StandaloneWidgetSign_Square_Small_C : Satis.WidgetSign
local Build_StandaloneWidgetSign_Square_Small_C

---@class FIN.classes.Satis.Build_StandaloneWidgetSign_Square_Small_C : Satis.Build_StandaloneWidgetSign_Square_Small_C
classes.Build_StandaloneWidgetSign_Square_Small_C = nil

--- Improves factory organization. The colors, icons, background, and text are customizable.<br>
--- <br>
--- Can be freestanding, placed on Walls, or attached to most buildings, including Storage Containers.<br>
--- <br>
--- Size: 0.5 m x 0.5 m
---@class Satis.Build_StandaloneWidgetSign_Square_Tiny_C : Satis.WidgetSign
local Build_StandaloneWidgetSign_Square_Tiny_C

---@class FIN.classes.Satis.Build_StandaloneWidgetSign_Square_Tiny_C : Satis.Build_StandaloneWidgetSign_Square_Tiny_C
classes.Build_StandaloneWidgetSign_Square_Tiny_C = nil

--- Functions like a Power Pole, but attaches to a wall.<br>
--- <br>
--- Allows for up to 4 Power Line connections.<br>
--- <br>
--- Connect Power Poles, Power Generators and factory buildings with Power Lines to create a power grid. The power grid supplies all connected buildings with power.
---@class Satis.Build_PowerPoleWall_C : Satis.FGBuildablePowerPole
local Build_PowerPoleWall_C

---@class FIN.classes.Satis.Build_PowerPoleWall_C : Satis.Build_PowerPoleWall_C
classes.Build_PowerPoleWall_C = nil

--- 
---@class Satis.FGBuildablePowerPole : Satis.Buildable
local FGBuildablePowerPole

---@class FIN.classes.Satis.FGBuildablePowerPole : Satis.FGBuildablePowerPole
classes.FGBuildablePowerPole = nil

--- Functions like a Power Pole, but attaches to a wall.<br>
--- <br>
--- Allows for up to 7 Power Line connections.<br>
--- <br>
--- Connect Power Poles, Power Generators and factory buildings with Power Lines to create a power grid. The power grid supplies all connected buildings with power.
---@class Satis.Build_PowerPoleWall_Mk2_C : Satis.Build_PowerPoleWall_C
local Build_PowerPoleWall_Mk2_C

---@class FIN.classes.Satis.Build_PowerPoleWall_Mk2_C : Satis.Build_PowerPoleWall_Mk2_C
classes.Build_PowerPoleWall_Mk2_C = nil

--- Functions like a Power Pole, but attaches to a wall.<br>
--- <br>
--- Allows for up to 10 Power Line connections.<br>
--- <br>
--- Connect Power Poles, Power Generators and factory buildings with Power Lines to create a power grid. The power grid supplies all connected buildings with power.
---@class Satis.Build_PowerPoleWall_Mk3_C : Satis.Build_PowerPoleWall_C
local Build_PowerPoleWall_Mk3_C

---@class FIN.classes.Satis.Build_PowerPoleWall_Mk3_C : Satis.Build_PowerPoleWall_Mk3_C
classes.Build_PowerPoleWall_Mk3_C = nil

--- Allows for up to 4 Power Line connections.<br>
--- <br>
--- Connect Power Poles, Power Generators, and factory buildings with Power Lines to create a power grid. The power grid supplies all connected buildings with power.
---@class Satis.Build_PowerPoleMk1_C : Satis.FGBuildablePowerPole
local Build_PowerPoleMk1_C

---@class FIN.classes.Satis.Build_PowerPoleMk1_C : Satis.Build_PowerPoleMk1_C
classes.Build_PowerPoleMk1_C = nil

--- Allows for up to 7 Power Line connections.<br>
--- <br>
--- Connect Power Poles, Power Generators, and factory buildings with Power Lines to create a power grid. The power grid supplies all connected buildings with power.
---@class Satis.Build_PowerPoleMk2_C : Satis.Build_PowerPoleMk1_C
local Build_PowerPoleMk2_C

---@class FIN.classes.Satis.Build_PowerPoleMk2_C : Satis.Build_PowerPoleMk2_C
classes.Build_PowerPoleMk2_C = nil

--- Allows for up to 10 Power Line connections.<br>
--- <br>
--- Connect Power Poles, Power Generators, and factory buildings with Power Lines to create a power grid. The power grid supplies all connected buildings with power.
---@class Satis.Build_PowerPoleMk3_C : Satis.Build_PowerPoleMk1_C
local Build_PowerPoleMk3_C

---@class FIN.classes.Satis.Build_PowerPoleMk3_C : Satis.Build_PowerPoleMk3_C
classes.Build_PowerPoleMk3_C = nil

--- Functions like a Power Pole, but attaches to a wall. Has one connector on each side of the wall.<br>
--- <br>
--- Allows for up to 4 Power Line connections per side.<br>
--- <br>
--- Connect Power Poles, Power Generators and factory buildings with Power Lines to create a power grid. The power grid supplies all connected buildings with power.
---@class Satis.Build_PowerPoleWallDouble_C : Satis.FGBuildablePowerPole
local Build_PowerPoleWallDouble_C

---@class FIN.classes.Satis.Build_PowerPoleWallDouble_C : Satis.Build_PowerPoleWallDouble_C
classes.Build_PowerPoleWallDouble_C = nil

--- Functions like a Power Pole, but attaches to a wall. Has one connector on each side of the wall.<br>
--- <br>
--- Allows for up to 7 Power Line connections per side.<br>
--- <br>
--- Connect Power Poles, Power Generators and factory buildings with Power Lines to create a power grid. The power grid supplies all connected buildings with power.
---@class Satis.Build_PowerPoleWallDouble_Mk2_C : Satis.Build_PowerPoleWallDouble_C
local Build_PowerPoleWallDouble_Mk2_C

---@class FIN.classes.Satis.Build_PowerPoleWallDouble_Mk2_C : Satis.Build_PowerPoleWallDouble_Mk2_C
classes.Build_PowerPoleWallDouble_Mk2_C = nil

--- Functions like a Power Pole, but attaches to a wall. Has one connector on each side of the wall.<br>
--- <br>
--- Allows for up to 10 Power Line connections per side.<br>
--- <br>
--- Connect Power Poles, Power Generators and factory buildings with Power Lines to create a power grid. The power grid supplies all connected buildings with power.
---@class Satis.Build_PowerPoleWallDouble_Mk3_C : Satis.Build_PowerPoleWallDouble_Mk2_C
local Build_PowerPoleWallDouble_Mk3_C

---@class FIN.classes.Satis.Build_PowerPoleWallDouble_Mk3_C : Satis.Build_PowerPoleWallDouble_Mk3_C
classes.Build_PowerPoleWallDouble_Mk3_C = nil

--- Helps span Power Lines across greater distances.<br>
--- There is an additional power connector at the bottom of the Power Tower to connect it to other buildings, such as Power Poles.
---@class Satis.Build_PowerTower_C : Satis.FGBuildablePowerPole
local Build_PowerTower_C

---@class FIN.classes.Satis.Build_PowerTower_C : Satis.Build_PowerTower_C
classes.Build_PowerTower_C = nil

--- Helps span Power Lines across greater distances.<br>
--- There is an additional power connector at the bottom of the Power Tower to connect it to other buildings, such as Power Poles.<br>
--- <br>
--- Note: This Power Tower variant includes a ladder and platform for improved utility.
---@class Satis.Build_PowerTowerPlatform_C : Satis.Build_PowerTower_C
local Build_PowerTowerPlatform_C

---@class FIN.classes.Satis.Build_PowerTowerPlatform_C : Satis.Build_PowerTowerPlatform_C
classes.Build_PowerTowerPlatform_C = nil

--- 
---@class Satis.FGBuildablePowerTower : Satis.Buildable
local FGBuildablePowerTower

---@class FIN.classes.Satis.FGBuildablePowerTower : Satis.FGBuildablePowerTower
classes.FGBuildablePowerTower = nil

--- 
---@class Satis.FGBuildableRailroadBridge : Satis.Buildable
local FGBuildableRailroadBridge

---@class FIN.classes.Satis.FGBuildableRailroadBridge : Satis.FGBuildableRailroadBridge
classes.FGBuildableRailroadBridge = nil

--- A train signal to control trains on a track.
---@class Satis.RailroadSignal : Satis.Buildable
local RailroadSignal

---@class FIN.classes.Satis.RailroadSignal : Satis.RailroadSignal
classes.RailroadSignal = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
RailroadSignal.isPathSignal = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
RailroadSignal.isBiDirectional = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
RailroadSignal.hasObservedBlock = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadSignal.blockValidation = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadSignal.aspect = nil

--- Returns the track block this signals observes.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.RailroadSignalBlock block The railroad signal block this signal is observing.
function RailroadSignal:getObservedBlock() end

--- Returns a list of the guarded connections. (incoming connections)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadTrackConnection[] guardedConnections The guarded connections.
function RailroadSignal:getGuardedConnnections() end

--- Returns a list of the observed connections. (outgoing connections)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadTrackConnection[] observedConnections The observed connections.
function RailroadSignal:getObservedConnections() end

--- Triggers when the aspect of this signal changes.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Aspect = event.pull()
--- ```
--- - `signalName: "AspectChanged"`
--- - `component: RailroadSignal`
--- - `Aspect: number` <br>
--- The new aspect of the signal (see 'Get Aspect' for more information)
---@deprecated
---@type FIN.Signal
RailroadSignal.SIGNAL_AspectChanged = nil

--- Triggers when the validation of this signal changes.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Validation = event.pull()
--- ```
--- - `signalName: "ValidationChanged"`
--- - `component: RailroadSignal`
--- - `Validation: number` <br>
--- The new validation of the signal (see 'Block Validation' for more information)
---@deprecated
---@type FIN.Signal
RailroadSignal.SIGNAL_ValidationChanged = nil

--- Directs the movement of trains to avoid collisions and bottlenecks.<br>
--- <br>
--- Block Signals can be placed on Railways to create 'Blocks' between them. When a train is occupying one of these Blocks, other trains will be unable to enter it.<br>
--- <br>
--- Caution: Signals are directional! Trains are unable to move against this direction, so be sure to set up Signals in both directions for bi-directional Railways.
---@class Satis.Build_RailroadBlockSignal_C : Satis.RailroadSignal
local Build_RailroadBlockSignal_C

---@class FIN.classes.Satis.Build_RailroadBlockSignal_C : Satis.Build_RailroadBlockSignal_C
classes.Build_RailroadBlockSignal_C = nil

--- Directs the movement of trains to avoid collisions and bottlenecks.<br>
--- <br>
--- Path Signals are advanced signals that are especially useful for bi-directional Railways and complex intersections. They function similarly to Block Signals, but rather than occupying the entire Block, trains can reserve a specific path through it and will only enter the Block if their path allows them to fully pass through.<br>
--- <br>
--- Caution: Signals are directional! Trains are unable to move against this direction, so be sure to set up Signals in both directions for bi-directional Railways.
---@class Satis.Build_RailroadPathSignal_C : Satis.RailroadSignal
local Build_RailroadPathSignal_C

---@class FIN.classes.Satis.Build_RailroadPathSignal_C : Satis.Build_RailroadPathSignal_C
classes.Build_RailroadPathSignal_C = nil

--- The controler object for a railroad switch.
---@class Satis.RailroadSwitchControl : Satis.Buildable
local RailroadSwitchControl

---@class FIN.classes.Satis.RailroadSwitchControl : Satis.RailroadSwitchControl
classes.RailroadSwitchControl = nil

--- Toggles the railroad switch like if you interact with it.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function RailroadSwitchControl:toggleSwitch() end

--- Returns the current switch position of this switch.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number position The current switch position of this switch.
function RailroadSwitchControl:switchPosition() end

--- Returns the Railroad Connection this switch is controlling.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadTrackConnection connection The controlled connectino.
function RailroadSwitchControl:getControlledConnection() end

--- 
---@class Satis.Build_RailroadSwitchControl_C : Satis.RailroadSwitchControl
local Build_RailroadSwitchControl_C

---@class FIN.classes.Satis.Build_RailroadSwitchControl_C : Satis.Build_RailroadSwitchControl_C
classes.Build_RailroadSwitchControl_C = nil

--- Carries trains reliably and quickly.<br>
--- Has a wide turn angle, so make sure to plan it out properly.
---@class Satis.Build_RailroadTrack_C : Satis.RailroadTrack
local Build_RailroadTrack_C

---@class FIN.classes.Satis.Build_RailroadTrack_C : Satis.Build_RailroadTrack_C
classes.Build_RailroadTrack_C = nil

--- A peice of railroad track over which trains can drive.
---@class Satis.RailroadTrack : Satis.Buildable
local RailroadTrack

---@class FIN.classes.Satis.RailroadTrack : Satis.RailroadTrack
classes.RailroadTrack = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadTrack.length = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
RailroadTrack.isOwnedByPlatform = nil

--- Returns the closes track position from the given world position
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param worldPos Engine.Vector The world position form which you want to get the closest track position.
---@return Satis.RailroadTrack track The track the track pos points to.
---@return number offset The offset of the track pos.
---@return number forward The forward direction of the track pos. 1 = with the track direction, -1 = against the track direction
function RailroadTrack:getClosestTrackPosition(worldPos) end

--- Returns the world location and world rotation of the track position from the given track position.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param track Satis.RailroadTrack The track the track pos points to.
---@param offset number The offset of the track pos.
---@param forward number The forward direction of the track pos. 1 = with the track direction, -1 = against the track direction
---@return Engine.Vector location The location at the given track position
---@return Engine.Vector rotation The rotation at the given track position (forward vector)
function RailroadTrack:getWorldLocAndRotAtPos(track, offset, forward) end

--- Returns the railroad track connection at the given direction.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param direction number The direction of which you want to get the connector from. 0 = front, 1 = back
---@return Satis.RailroadTrackConnection connection The connection component in the given direction.
function RailroadTrack:getConnection(direction) end

--- Returns the track graph of which this track is part of.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.TrackGraph track The track graph of which this track is part of.
function RailroadTrack:getTrackGraph() end

--- Returns a list of Railroad Vehicles on the Track
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadVehicle[] vehicles THe list of vehicles on the track.
function RailroadTrack:getVehicles() end

--- Triggered when a vehicle enters the track.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Vehicle = event.pull()
--- ```
--- - `signalName: "VehicleEnter"`
--- - `component: RailroadTrack`
--- - `Vehicle: Satis.RailroadVehicle` <br>
--- The vehicle that entered the track.
---@deprecated
---@type FIN.Signal
RailroadTrack.SIGNAL_VehicleEnter = nil

--- Triggered when a vehicle exists the track.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Vehicle = event.pull()
--- ```
--- - `signalName: "VehicleExit"`
--- - `component: RailroadTrack`
--- - `Vehicle: Satis.RailroadVehicle` <br>
--- The vehicle that exited the track.
---@deprecated
---@type FIN.Signal
RailroadTrack.SIGNAL_VehicleExit = nil

--- 
---@class Satis.Build_RailroadTrackIntegrated_C : Satis.RailroadTrack
local Build_RailroadTrackIntegrated_C

---@class FIN.classes.Satis.Build_RailroadTrackIntegrated_C : Satis.Build_RailroadTrackIntegrated_C
classes.Build_RailroadTrackIntegrated_C = nil

--- 
---@class Satis.FGBuildableRoad : Satis.Buildable
local FGBuildableRoad

---@class FIN.classes.Satis.FGBuildableRoad : Satis.FGBuildableRoad
classes.FGBuildableRoad = nil

--- 
---@class Satis.FGBuildableSnowCannon : Satis.Buildable
local FGBuildableSnowCannon

---@class FIN.classes.Satis.FGBuildableSnowCannon : Satis.FGBuildableSnowCannon
classes.FGBuildableSnowCannon = nil

--- For those who want to aggressively celebrate the holidays.
---@class Satis.Build_SnowCannon_C : Satis.FGBuildableSnowCannon
local Build_SnowCannon_C

---@class FIN.classes.Satis.Build_SnowCannon_C : Satis.Build_SnowCannon_C
classes.Build_SnowCannon_C = nil

--- 
---@class Satis.FGBuildableSnowDispenser : Satis.Buildable
local FGBuildableSnowDispenser

---@class FIN.classes.Satis.FGBuildableSnowDispenser : Satis.FGBuildableSnowDispenser
classes.FGBuildableSnowDispenser = nil

--- Dispenses a mixture of water, air, and liquid nitrogen, practically identical to actual snow. Can be attached to Walls and ceilings.
---@class Satis.Build_SnowDispenser_C : Satis.FGBuildableSnowDispenser
local Build_SnowDispenser_C

---@class FIN.classes.Satis.Build_SnowDispenser_C : Satis.Build_SnowDispenser_C
classes.Build_SnowDispenser_C = nil

--- Connects Power Poles, Power Generators, and factory buildings.
---@class Satis.Build_PowerLine_C : Satis.FGBuildableWire
local Build_PowerLine_C

---@class FIN.classes.Satis.Build_PowerLine_C : Satis.Build_PowerLine_C
classes.Build_PowerLine_C = nil

--- 
---@class Satis.FGBuildableWire : Satis.Buildable
local FGBuildableWire

---@class FIN.classes.Satis.FGBuildableWire : Satis.FGBuildableWire
classes.FGBuildableWire = nil

--- A more festive take on the Power Line.
---@class Satis.Build_XmassLightsLine_C : Satis.FGBuildableWire
local Build_XmassLightsLine_C

---@class FIN.classes.Satis.Build_XmassLightsLine_C : Satis.Build_XmassLightsLine_C
classes.Build_XmassLightsLine_C = nil

--- 
---@class Satis.FGCustomizationLocker : Satis.Buildable
local FGCustomizationLocker

---@class FIN.classes.Satis.FGCustomizationLocker : Satis.FGCustomizationLocker
classes.FGCustomizationLocker = nil

--- 
---@class Satis.Build_Locker_MK1_C : Satis.FGCustomizationLocker
local Build_Locker_MK1_C

---@class FIN.classes.Satis.Build_Locker_MK1_C : Satis.Build_Locker_MK1_C
classes.Build_Locker_MK1_C = nil

--- 
---@class Satis.FGPioneerPotty : Satis.Buildable
local FGPioneerPotty

---@class FIN.classes.Satis.FGPioneerPotty : Satis.FGPioneerPotty
classes.FGPioneerPotty = nil

--- 
---@class Satis.BUILD_Potty_mk1_C : Satis.FGPioneerPotty
local BUILD_Potty_mk1_C

---@class FIN.classes.Satis.BUILD_Potty_mk1_C : Satis.BUILD_Potty_mk1_C
classes.BUILD_Potty_mk1_C = nil

--- 
---@class FicsItNetworksCircuit.FINNetworkAdapter : Satis.Buildable
local FINNetworkAdapter

---@class FIN.classes.FicsItNetworksCircuit.FINNetworkAdapter : FicsItNetworksCircuit.FINNetworkAdapter
classes.FINNetworkAdapter = nil

--- 
---@class FIN.Build_NetworkAdapter_C : FicsItNetworksCircuit.FINNetworkAdapter
local Build_NetworkAdapter_C

---@class FIN.classes.FIN.Build_NetworkAdapter_C : FIN.Build_NetworkAdapter_C
classes.Build_NetworkAdapter_C = nil

--- 
---@class FicsItNetworksCircuit.FINNetworkCable : Satis.Buildable
local FINNetworkCable

---@class FIN.classes.FicsItNetworksCircuit.FINNetworkCable : FicsItNetworksCircuit.FINNetworkCable
classes.FINNetworkCable = nil

--- The FicsIt-Networks Network Cable allows you to connect your network components wich each other.<br>
--- <br>
--- This is the core process of building up your own computer network.<br>
--- <br>
--- You can cconnect this cable via two a two step placement procedure to two network connectors, or, if the component/machine/whatever doesn't have a network connector, it will try to create add a network adpater to the machine to still allow you to connect it to your network.
---@class FIN.Build_NetworkCable_C : FicsItNetworksCircuit.FINNetworkCable
local Build_NetworkCable_C

---@class FIN.classes.FIN.Build_NetworkCable_C : FIN.Build_NetworkCable_C
classes.Build_NetworkCable_C = nil

--- The FicsIt-Networks Thin Network Cable allows you to connect your network panels with each other more gracefully.<br>
--- <br>
--- This cable works just like the normal network cable except it can only connect between MCP panels and Small Network Plugs.<br>
--- <br>
--- You can then connect Normal/Large Network Cables to those Small Network Plugs to be able to connect your MCP Panels with a computer.
---@class FIN.Build_ThinNetworkCable_C : FicsItNetworksCircuit.FINNetworkCable
local Build_ThinNetworkCable_C

---@class FIN.classes.FIN.Build_ThinNetworkCable_C : FIN.Build_ThinNetworkCable_C
classes.Build_ThinNetworkCable_C = nil

--- 
---@class FicsItNetworksCircuit.NetworkRouter : Satis.Buildable
local NetworkRouter

---@class FIN.classes.FicsItNetworksCircuit.NetworkRouter : FicsItNetworksCircuit.NetworkRouter
classes.NetworkRouter = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
NetworkRouter.isWhitelist = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
NetworkRouter.isAddrWhitelist = nil

--- Overrides the port filter list with the given array.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number[] ports The port array you want to override the filter list with.
function NetworkRouter:setPortList() end

--- Overrides the address filter list with the given array.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return string[] addresses The address array you want to override the filter list with.
function NetworkRouter:setAddrList() end

--- Removes the given port from the port filter list.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param port number The port you want to remove from the list.
function NetworkRouter:removePortList(port) end

--- Removes the given address from the address filter list.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param addr string The address you want to remove from the list.
function NetworkRouter:removeAddrList(addr) end

--- Allows to get all the ports of the port filter list as array.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number[] ports The port array of the filter list.
function NetworkRouter:getPortList() end

--- Allows to get all the addresses of the address filter list as array.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return string[] addresses The address array of the filter list.
function NetworkRouter:getAddrList() end

--- Adds a given port to the port filter list.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param port number The port you want to add to the list.
function NetworkRouter:addPortList(port) end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param addr string 
function NetworkRouter:addAddrList(addr) end

--- The FicsIt-Networks Network Router allows you to sepparate two different component network from each other.<br>
--- But it still lets network messages sent by network cards through.<br>
--- This allows for better networking capabilities, faster networking (can reduce game lag) and makes working with larger networks and multiple computer more easy.<br>
--- <br>
--- The router also provides a couple of functions which allow you to create filters for ports and message senders.
---@class FIN.Build_NetworkRouter_C : FicsItNetworksCircuit.NetworkRouter
local Build_NetworkRouter_C

---@class FIN.classes.FIN.Build_NetworkRouter_C : FIN.Build_NetworkRouter_C
classes.Build_NetworkRouter_C = nil

--- 
---@class FicsItNetworksCircuit.FINWirelessAccessPoint : Satis.Buildable
local FINWirelessAccessPoint

---@class FIN.classes.FicsItNetworksCircuit.FINWirelessAccessPoint : FicsItNetworksCircuit.FINWirelessAccessPoint
classes.FINWirelessAccessPoint = nil

--- The Ficsit Networks Wireless Access Point allows you to connect a circuit to the Ficsit Wireless Area Network (FWAN), which uses Radio Towers frequencies to create a messaging network over the planet.<br>
---  <br>
--- It should be connected to a Radio Tower, then all network messages received will be broadcasted to all other Wireless Access Points across the map.
---@class FIN.Build_WirelessAccessPoint_C : FicsItNetworksCircuit.FINWirelessAccessPoint
local Build_WirelessAccessPoint_C

---@class FIN.classes.FIN.Build_WirelessAccessPoint_C : FIN.Build_WirelessAccessPoint_C
classes.Build_WirelessAccessPoint_C = nil

--- 
---@class FIN.ComputerCase : Satis.Buildable
local ComputerCase

---@class FIN.classes.FIN.ComputerCase : FIN.ComputerCase
classes.ComputerCase = nil

--- Stops the Computer (Processor).
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
function ComputerCase:stopComputer() end

--- Starts the Computer (Processor).
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
function ComputerCase:startComputer() end

--- Returns the internal kernel state of the computer.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number result The current internal kernel state.
function ComputerCase:getState() end

--- Returns the log of the computer. Output is paginated using the input parameters. A negative Page will indicate pagination from the bottom (latest log entry first).
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param pageSize number The size of the returned page.
---@param page number The index of the page you want to return. Negative to start indexing at the bottom (latest entries first).
---@return FicsItLogLibrary.LogEntry[] log The Log page you wanted to retrieve.
---@return number logSize The size of the full log (not just the returned page).
function ComputerCase:getLog(pageSize, page) end

--- Triggers when something in the filesystem changes.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Type, From, To = event.pull()
--- ```
--- - `signalName: "FileSystemUpdate"`
--- - `component: ComputerCase`
--- - `Type: number` <br>
--- The type of the change.
--- - `From: string` <br>
--- The file path to the FS node that has changed.
--- - `To: string` <br>
--- The new file path of the node if it has changed.
---@deprecated
---@type FIN.Signal
ComputerCase.SIGNAL_FileSystemUpdate = nil

--- Triggers when the computers state changes.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, PreviousState, NewState = event.pull()
--- ```
--- - `signalName: "ComputerStateChanged"`
--- - `component: ComputerCase`
--- - `PreviousState: number` <br>
--- The previous computer state.
--- - `NewState: number` <br>
--- The new computer state.
---@deprecated
---@type FIN.Signal
ComputerCase.SIGNAL_ComputerStateChanged = nil

--- The FicsIt-Network computer case is the most important thing you will know of. This case already holds the essentials of a computer for you. Like a network connector, keyboard, mouse and screen. But most important of all, it already has a motherboard were you can place and configure the computer just like you want.
---@class FIN.Build_ComputerCase_C : FIN.ComputerCase
local Build_ComputerCase_C

---@class FIN.classes.FIN.Build_ComputerCase_C : FIN.Build_ComputerCase_C
classes.Build_ComputerCase_C = nil

--- 
---@class FIN.FINComputerModule : Satis.Buildable
local FINComputerModule

---@class FIN.classes.FIN.FINComputerModule : FIN.FINComputerModule
classes.FINComputerModule = nil

--- 
---@class FIN.FINComputerDriveHolder : FIN.FINComputerModule
local FINComputerDriveHolder

---@class FIN.classes.FIN.FINComputerDriveHolder : FIN.FINComputerDriveHolder
classes.FINComputerDriveHolder = nil

--- The FicsIt-Networks Drive holder allows you to add any hard drive to the computer system.<br>
--- <br>
--- The drive will then be able to get mounted as root FS or to get added as device file to the FS, after that you will be able to manually mount the drive to your desired location.
---@class FIN.Build_DriveHolder_C : FIN.FINComputerDriveHolder
local Build_DriveHolder_C

---@class FIN.classes.FIN.Build_DriveHolder_C : FIN.Build_DriveHolder_C
classes.Build_DriveHolder_C = nil

--- 
---@class FIN.FINComputerGPU : FIN.FINComputerModule
local FINComputerGPU

---@class FIN.classes.FIN.FINComputerGPU : FIN.FINComputerGPU
classes.FINComputerGPU = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Engine.Vector2D ReturnValue 
function FINComputerGPU:getScreenSize() end

--- Binds this GPU to the given screen. Unbinds the already bound screen.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param newScreen Engine.Object The screen you want to bind this GPU to. Null if you want to unbind the screen.
function FINComputerGPU:bindScreen(newScreen) end

--- <br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, oldScreen = event.pull()
--- ```
--- - `signalName: "ScreenBound"`
--- - `component: FINComputerGPU`
--- - `oldScreen: Engine.Object` <br>
--- 
---@deprecated
---@type FIN.Signal
FINComputerGPU.SIGNAL_ScreenBound = nil

--- 
---@class FIN.GPUT1 : FIN.FINComputerGPU
local GPUT1

---@class FIN.classes.FIN.GPUT1 : FIN.GPUT1
classes.GPUT1 = nil

--- Draws the given text at the given position to the hidden screen buffer.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param x number The x coordinate at which the text should get drawn.
---@param y number The y coordinate at which the text should get drawn.
---@param str string The text you want to draw on-to the buffer.
function GPUT1:setText(x, y, str) end

--- Changes the size of the text-grid (and buffer).
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param w number The width of the text-gird.
---@param h number The height of the text-grid.
function GPUT1:setSize(w, h) end

--- Changes the foreground color that is used for the next draw calls.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param r number The red portion of the foreground color. (0.0 - 1.0)
---@param g number The green portion of the foreground color. (0.0 - 1.0)
---@param b number The blue portion of the foreground color. (0.0 - 1.0)
---@param a number The opacity of the foreground color. (0.0 - 1.0)
function GPUT1:setForeground(r, g, b, a) end

--- Allows to change the back buffer of the GPU to the given buffer.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param buffer FIN.GPUT1Buffer The Buffer you want to now use as back buffer.
function GPUT1:setBuffer(buffer) end

--- Changes the background color that is used for the next draw calls.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param r number The red portion of the background color. (0.0 - 1.0)
---@param g number The green portion of the background color. (0.0 - 1.0)
---@param b number The blue portion of the background color. (0.0 - 1.0)
---@param a number The opacity of the background color. (0.0 - 1.0)
function GPUT1:setBackground(r, g, b, a) end

--- Returns the size of the text-grid (and buffer).
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number w The width of the text-gird.
---@return number h The height of the text-grid.
function GPUT1:getSize() end

--- Returns the currently bound screen.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Engine.Object screen The currently bound screen.
function GPUT1:getScreen() end

--- Returns the back buffer as struct to be able to use advanced buffer handling functions. (struct is a copy)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@return FIN.GPUT1Buffer buffer The Buffer that is currently the back buffer.
function GPUT1:getBuffer() end

--- Flushes the hidden screen buffer to the visible screen buffer and so makes the draw calls visible.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function GPUT1:flush() end

--- Draws the given character at all given positions in the given rectangle on-to the hidden screen buffer.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param x number The x coordinate at which the rectangle should get drawn. (upper-left corner)
---@param y number The y coordinate at which the rectangle should get drawn. (upper-left corner)
---@param dx number The width of the rectangle.
---@param dy number The height of the rectangle.
---@param str string The character you want to use for the rectangle. (first char in the given string)
function GPUT1:fill(x, y, dx, dy, str) end

--- Triggers when the size of the text grid changed.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, oldWidth, oldHeight = event.pull()
--- ```
--- - `signalName: "ScreenSizeChanged"`
--- - `component: GPUT1`
--- - `oldWidth: number` <br>
--- The old width of the screen.
--- - `oldHeight: number` <br>
--- The old height of the screen.
---@deprecated
---@type FIN.Signal
GPUT1.SIGNAL_ScreenSizeChanged = nil

--- Triggers when a mouse button got released.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, X, Y, Button = event.pull()
--- ```
--- - `signalName: "OnMouseUp"`
--- - `component: GPUT1`
--- - `X: number` <br>
--- The x position of the cursor.
--- - `Y: number` <br>
--- The y position of the cursor.
--- - `Button: number` <br>
--- The Button-Bit-Field providing information about the released button event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
GPUT1.SIGNAL_OnMouseUp = nil

--- Triggers when the mouse cursor moves on the screen.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, X, Y, Button = event.pull()
--- ```
--- - `signalName: "OnMouseMove"`
--- - `component: GPUT1`
--- - `X: number` <br>
--- The x position of the cursor.
--- - `Y: number` <br>
--- The y position of the cursor.
--- - `Button: number` <br>
--- The Button-Bit-Field providing information about the move event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
GPUT1.SIGNAL_OnMouseMove = nil

--- Triggers when a mouse button got pressed.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, X, Y, Button = event.pull()
--- ```
--- - `signalName: "OnMouseDown"`
--- - `component: GPUT1`
--- - `X: number` <br>
--- The x position of the cursor.
--- - `Y: number` <br>
--- The y position of the cursor.
--- - `Button: number` <br>
--- The Button-Bit-Field providing information about the pressed button event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
GPUT1.SIGNAL_OnMouseDown = nil

--- Triggers when a key got released.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, C, Code, Button = event.pull()
--- ```
--- - `signalName: "OnKeyUp"`
--- - `component: GPUT1`
--- - `C: number` <br>
--- The ASCII number of the character typed in.
--- - `Code: number` <br>
--- The number code of the pressed key.
--- - `Button: number` <br>
--- The Button-Bit-Field providing information about the key release event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
GPUT1.SIGNAL_OnKeyUp = nil

--- Triggers when a key got pressed.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, C, Code, Button = event.pull()
--- ```
--- - `signalName: "OnKeyDown"`
--- - `component: GPUT1`
--- - `C: number` <br>
--- The ASCII number of the character typed in.
--- - `Code: number` <br>
--- The number code of the pressed key.
--- - `Button: number` <br>
--- The Button-Bit-Field providing information about the key press event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
GPUT1.SIGNAL_OnKeyDown = nil

--- Triggers when a character key got 'clicked' and essentially a character got typed in, usful for text input.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Character, Button = event.pull()
--- ```
--- - `signalName: "OnKeyChar"`
--- - `component: GPUT1`
--- - `Character: string` <br>
--- The character that got typed in as string.
--- - `Button: number` <br>
--- The Button-Bit-Field providing information about the key release event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
GPUT1.SIGNAL_OnKeyChar = nil

--- The FicsIt-Networks GPU T1 allows you to render a character grid onto any kind of screen.<br>
--- <br>
--- Each character of this grid can be colored as you want as well as the background of each character.<br>
--- <br>
--- You can also change the resolution to up to 150x50 characters.<br>
--- <br>
--- The GPU also implemnts some signals allowing you to interact with the graphics more easily via keyboard, mouse and even touch.
---@class FIN.Build_GPU_T1_C : FIN.GPUT1
local Build_GPU_T1_C

---@class FIN.classes.FIN.Build_GPU_T1_C : FIN.Build_GPU_T1_C
classes.Build_GPU_T1_C = nil

--- 
---@class FIN.FINComputerGPUT2 : FIN.FINComputerGPU
local FINComputerGPUT2

---@class FIN.classes.FIN.FINComputerGPUT2 : FIN.FINComputerGPUT2
classes.FINComputerGPUT2 = nil

--- Pushes a transformation to the geometry stack. All subsequent drawcalls will be transformed through all previously pushed geometries and this one. Be aware, only all draw calls till, this geometry gets pop'ed are transformed, previous draw calls (and draw calls after the pop) are unaffected by this.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param translation Engine.Vector2D The local translation that is supposed to happen to all further drawcalls. Translation can be also thought as 'repositioning'.
---@param rotation number The local rotation that gets applied to all subsequent draw calls. The origin of the rotation is the whole screens center point. The value is in degrees.
---@param scale Engine.Vector2D The scale that gets applied to the whole screen localy along the (rotated) axis. No change in scale is (1,1).
function FINComputerGPUT2:pushTransform(translation, rotation, scale) end

--- Pushes a layout to the geometry stack. All subsequent drawcalls will be transformed through all previously pushed geometries and this one. Be aware, only all draw calls, till this geometry gets pop'ed are transformed, previous draw calls (and draw calls after the pop) are unaffected by this.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param offset Engine.Vector2D The local translation (or offset) that is supposed to happen to all further drawcalls. Translation can be also thought as 'repositioning'.
---@param size Engine.Vector2D The scale that gets applied to the whole screen localy along both axis. No change in scale is 1.
---@param scale number 
function FINComputerGPUT2:pushLayout(offset, size, scale) end

--- Pushes a rectangle to the clipping stack. All subsequent drawcalls will be clipped to only be visible within this clipping zone and all previously pushed clipping zones. Be aware, only all draw calls, till this clipping zone gets pop'ed are getting clipped by it, previous draw calls (and draw calls after the pop) are unaffected by this.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param position Engine.Vector2D The local position of the upper left corner of the clipping rectangle.
---@param size Engine.Vector2D The size of the clipping rectangle.
function FINComputerGPUT2:pushClipRect(position, size) end

--- Pushes a 4 pointed polygon to the clipping stack. All subsequent drawcalls will be clipped to only be visible within this clipping zone and all previously pushed clipping zones. Be aware, only all draw calls, till this clipping zone gets pop'ed are getting clipped by it, previous draw calls (and draw calls after the pop) are unaffected by this.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param topLeft Engine.Vector2D The local position of the top left point.
---@param topRight Engine.Vector2D The local position of the top right point.
---@param bottomLeft Engine.Vector2D The local position of the top right point.
---@param bottomRight Engine.Vector2D The local position of the bottom right point.
function FINComputerGPUT2:pushClipPolygon(topLeft, topRight, bottomLeft, bottomRight) end

--- Pops the top most geometry from the geometry stack. The latest geometry on the stack gets removed first. (Last In, First Out)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
function FINComputerGPUT2:popGeometry() end

--- Pops the top most clipping zone from the clipping stack. The latest clipping zone on the stack gets removed first. (Last In, First Out)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
function FINComputerGPUT2:popClip() end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param Text string 
---@param Size number 
---@param bMonospace boolean 
---@return Engine.Vector2D ReturnValue 
function FINComputerGPUT2:measureText(Text, Size, bMonospace) end

--- Flushes all draw calls to the visible draw call buffer to show all changes at once. The draw buffer gets cleared afterwards.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function FINComputerGPUT2:flush() end

--- Draws some Text at the given position (top left corner of the text), text, size, color and rotation.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param position Engine.Vector2D The position of the top left corner of the text.
---@param text string The text to draw.
---@param size number The font size used.
---@param color Engine.Color The color of the text.
---@param monospace boolean True if a monospace font should be used.
function FINComputerGPUT2:drawText(position, text, size, color, monospace) end

--- Draws a Spline from one position to another with given directions, thickness and color.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param start Engine.Vector2D The local position of the start point of the spline.
---@param startDirections Engine.Vector2D The direction of the spline of how it exists the start point.
---@param _end Engine.Vector2D The local position of the end point of the spline.
---@param endDirection Engine.Vector2D The direction of how the spline enters the end position.
---@param thickness number The thickness of the line drawn.
---@param color Engine.Color The color of the line drawn.
function FINComputerGPUT2:drawSpline(start, startDirections, _end, endDirection, thickness, color) end

--- Draws a Rectangle with the upper left corner at the given local position, size, color and rotation around the upper left corner.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param position Engine.Vector2D The local position of the upper left corner of the rectangle.
---@param size Engine.Vector2D The size of the rectangle.
---@param color Engine.Color The color of the rectangle.
---@param image string If not empty string, should be image reference that should be placed inside the rectangle.
---@param rotation number The rotation of the rectangle around the upper left corner in degrees.
function FINComputerGPUT2:drawRect(position, size, color, image, rotation) end

--- Draws connected lines through all given points with the given thickness and color.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param points Engine.Vector2D[] The local points that get connected by lines one after the other.
---@param thickness number The thickness of the lines.
---@param color Engine.Color The color of the lines.
function FINComputerGPUT2:drawLines(points, thickness, color) end

--- Draws a box.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param boxSettings FIN.GPUT2DrawCallBox The settings of the box you want to draw.
function FINComputerGPUT2:drawBox(boxSettings) end

--- Draws a Cubic Bezier Spline from one position to another with given control points, thickness and color.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param p0 Engine.Vector2D The local position of the start point of the spline.
---@param p1 Engine.Vector2D The local position of the first control point.
---@param p2 Engine.Vector2D The local position of the second control point.
---@param p3 Engine.Vector2D The local position of the end point of the spline.
---@param thickness number The thickness of the line drawn.
---@param color Engine.Color The color of the line drawn.
function FINComputerGPUT2:drawBezier(p0, p1, p2, p3, thickness, color) end

--- Triggers when the mouse cursor moves on the screen.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Position, WheelDelta, Modifiers = event.pull()
--- ```
--- - `signalName: "OnMouseMove"`
--- - `component: FINComputerGPUT2`
--- - `Position: Engine.Vector2D` <br>
--- The position of the cursor.
--- - `WheelDelta: number` <br>
--- The delta value of how much the mouse wheel got moved.
--- - `Modifiers: number` <br>
--- The Modifiers-Bit-Field providing information about the move event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
FINComputerGPUT2.SIGNAL_OnMouseMove = nil

--- Triggers when a mouse button got released.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Position, Modifiers = event.pull()
--- ```
--- - `signalName: "OnMouseUp"`
--- - `component: FINComputerGPUT2`
--- - `Position: Engine.Vector2D` <br>
--- The position of the cursor.
--- - `Modifiers: number` <br>
--- The Modifiers-Bit-Field providing information about the released button event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
FINComputerGPUT2.SIGNAL_OnMouseUp = nil

--- Triggers when the mouse cursor moves on the screen.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Position, Modifiers = event.pull()
--- ```
--- - `signalName: "OnMouseMove"`
--- - `component: FINComputerGPUT2`
--- - `Position: Engine.Vector2D` <br>
--- The position of the cursor.
--- - `Modifiers: number` <br>
--- The Modifiers-Bit-Field providing information about the move event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
FINComputerGPUT2.SIGNAL_OnMouseMove = nil

--- Triggers when the mouse cursor leaves the screen area.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Position, Modifiers = event.pull()
--- ```
--- - `signalName: "OnMouseLeave"`
--- - `component: FINComputerGPUT2`
--- - `Position: Engine.Vector2D` <br>
--- The position of the cursor.
--- - `Modifiers: number` <br>
--- The Modifiers-Bit-Field providing information about the move event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
FINComputerGPUT2.SIGNAL_OnMouseLeave = nil

--- Triggers when the mouse cursor enters the screen area.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Position, Modifiers = event.pull()
--- ```
--- - `signalName: "OnMouseEnter"`
--- - `component: FINComputerGPUT2`
--- - `Position: Engine.Vector2D` <br>
--- The position of the cursor.
--- - `Modifiers: number` <br>
--- The Modifiers-Bit-Field providing information about the move event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
FINComputerGPUT2.SIGNAL_OnMouseEnter = nil

--- Triggers when a mouse button got pressed.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Position, Modifiers = event.pull()
--- ```
--- - `signalName: "OnMouseDown"`
--- - `component: FINComputerGPUT2`
--- - `Position: Engine.Vector2D` <br>
--- The position of the cursor.
--- - `Modifiers: number` <br>
--- The Modifier-Bit-Field providing information about the pressed button event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
FINComputerGPUT2.SIGNAL_OnMouseDown = nil

--- Triggers when a key got released.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, C, Code, Modifiers = event.pull()
--- ```
--- - `signalName: "OnKeyUp"`
--- - `component: FINComputerGPUT2`
--- - `C: number` <br>
--- The ASCII number of the character typed in.
--- - `Code: number` <br>
--- The number code of the pressed key.
--- - `Modifiers: number` <br>
--- The Modifiers-Bit-Field providing information about the key release event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
FINComputerGPUT2.SIGNAL_OnKeyUp = nil

--- Triggers when a key got pressed.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, C, Code, Modifiers = event.pull()
--- ```
--- - `signalName: "OnKeyDown"`
--- - `component: FINComputerGPUT2`
--- - `C: number` <br>
--- The ASCII number of the character typed in.
--- - `Code: number` <br>
--- The number code of the pressed key.
--- - `Modifiers: number` <br>
--- The Modifiers-Bit-Field providing information about the key press event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
FINComputerGPUT2.SIGNAL_OnKeyDown = nil

--- Triggers when a character key got 'clicked' and essentially a character got typed in, usful for text input.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Character, Modifiers = event.pull()
--- ```
--- - `signalName: "OnKeyChar"`
--- - `component: FINComputerGPUT2`
--- - `Character: string` <br>
--- The character that got typed in as string.
--- - `Modifiers: number` <br>
--- The Modifiers-Bit-Field providing information about the key release event.<br>
--- Bits:<br>
--- 1th left mouse pressed<br>
--- 2th right mouse button pressed<br>
--- 3th ctrl key pressed<br>
--- 4th shift key pressed<br>
--- 5th alt key pressed<br>
--- 6th cmd key pressed
---@deprecated
---@type FIN.Signal
FINComputerGPUT2.SIGNAL_OnKeyChar = nil

--- The Graphical Processing Unit T2 allows for 2D Drawing on a screen.<br>
--- <br>
--- You are able to draw with lines, boxes, text, images & more.<br>
--- <br>
--- And through the use of transformation stack and clipping stack, you can more easily create more complex drawings!<br>
--- <br>
--- The GPU also implemnts some signals allowing you to interact with the graphics more easily via keyboard, mouse and even touch.
---@class FIN.Build_GPU_T2_C : FIN.FINComputerGPUT2
local Build_GPU_T2_C

---@class FIN.classes.FIN.Build_GPU_T2_C : FIN.Build_GPU_T2_C
classes.Build_GPU_T2_C = nil

--- 
---@class FIN.FINComputerMemory : FIN.FINComputerModule
local FINComputerMemory

---@class FIN.classes.FIN.FINComputerMemory : FIN.FINComputerMemory
classes.FINComputerMemory = nil

--- This is 100kB of amazing FicsIt-Networks Memory.<br>
--- <br>
--- You can add multiple of the memory bars to your PC and so you can extend the memory of your PC.<br>
--- <br>
--- You always need to have enough memory because FicsIt doesn't allow out of memory exceptions and if you bring a computer to throw one, you will loose one month of payment.
---@class FIN.Build_RAM_T1_C : FIN.FINComputerMemory
local Build_RAM_T1_C

---@class FIN.classes.FIN.Build_RAM_T1_C : FIN.Build_RAM_T1_C
classes.Build_RAM_T1_C = nil

--- 
---@class FIN.NetworkCard : FIN.FINComputerModule
local NetworkCard

---@class FIN.classes.FIN.NetworkCard : FIN.NetworkCard
classes.NetworkCard = nil

--- Sends a network message to the receiver with the given address on the given port. The data you want to add can be passed as additional parameters. Max amount of such parameters is 7 and they can only be nil, booleans, numbers and strings.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param receiver string The component ID as string of the component you want to send the network message to.
---@param port number The port on which the network message should get sent. For outgoing network messages a port does not need to be opened.
---@param ... any @additional arguments as described
function NetworkCard:send(receiver, port, ...) end

--- Opens the given port so the network card is able to receive network messages on the given port.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param port number The port you want to open.
function NetworkCard:open(port) end

--- Closes all ports of the network card so no further messages are able to get received
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function NetworkCard:closeAll() end

--- Closes the given port so the network card wont receive network messages on the given port.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param port number The port you want to close.
function NetworkCard:close(port) end

--- Sends a network message to all components in the network message network (including networks sepperated by network routers) on the given port. The data you want to add can be passed as additional parameters. Max amount of such parameters is 7 and they can only be nil, booleans, numbers and strings.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param port number The port on which the network message should get sent. For outgoing network messages a port does not need to be opened.
---@param ... any @additional arguments as described
function NetworkCard:broadcast(port, ...) end

--- Triggers when the network card receives a network message on one of its opened ports. The additional arguments are the data that is contained within the network message.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Sender, Port, ... = event.pull()
--- ```
--- - `signalName: "NetworkMessage"`
--- - `component: NetworkCard`
--- - `Sender: string` <br>
--- The component id of the sender of the network message.
--- - `Port: number` <br>
--- The port on which the network message got sent.
--- - `...: any`
---@deprecated
---@type FIN.Signal
NetworkCard.SIGNAL_NetworkMessage = nil

--- The FicsIt-Networks Network Card allows you to send network messages to other network cards in the same computer network.<br>
--- <br>
--- You can use unicast and broadcast messages to share information between multiple different computers in the same network.<br>
--- <br>
--- This is the best and easiest way for you to communicate between multiple computers.<br>
--- <br>
--- If you want to recieve network messages, make sure you also open the according port, since every message is asscociated with a port allowing for better filtering.
---@class FIN.Build_NetworkCard_C : FIN.NetworkCard
local Build_NetworkCard_C

---@class FIN.classes.FIN.Build_NetworkCard_C : FIN.Build_NetworkCard_C
classes.Build_NetworkCard_C = nil

--- 
---@class FIN.FINComputerProcessor : FIN.FINComputerModule
local FINComputerProcessor

---@class FIN.classes.FIN.FINComputerProcessor : FIN.FINComputerProcessor
classes.FINComputerProcessor = nil

--- 
---@class FIN.FINComputerProcessorLua : FIN.FINComputerProcessor
local FINComputerProcessorLua

---@class FIN.classes.FIN.FINComputerProcessorLua : FIN.FINComputerProcessorLua
classes.FINComputerProcessorLua = nil

--- This CPU is from the FicsIt-Lua series and allows you to program the PC with Lua.<br>
--- <br>
--- You can only place one CPU per PC.<br>
--- <br>
--- You are required to have at least one CPU per PC to run it. FicsIt does not allow unused PC Cases to get build.
---@class FIN.Build_CPU_Lua_C : FIN.FINComputerProcessorLua
local Build_CPU_Lua_C

---@class FIN.classes.FIN.Build_CPU_Lua_C : FIN.Build_CPU_Lua_C
classes.Build_CPU_Lua_C = nil

--- 
---@class FIN.FINComputerScreen : FIN.FINComputerModule
local FINComputerScreen

---@class FIN.classes.FIN.FINComputerScreen : FIN.FINComputerScreen
classes.FINComputerScreen = nil

--- The FicsIt-Networks Screen Driver allows you to add a screen display to the UI of the computer case you build this module into.<br>
--- <br>
--- You can then use the computer API to get a reference to the screen and so you can bind the screen to a GPU.
---@class FIN.Build_ScreenDriver_C : FIN.FINComputerScreen
local Build_ScreenDriver_C

---@class FIN.classes.FIN.Build_ScreenDriver_C : FIN.Build_ScreenDriver_C
classes.Build_ScreenDriver_C = nil

--- 
---@class FIN.FINInternetCard : FIN.FINComputerModule
local FINInternetCard

---@class FIN.classes.FIN.FINInternetCard : FIN.FINInternetCard
classes.FINInternetCard = nil

--- Does an HTTP-Request. If a payload is given, the Content-Type header has to be set. All additional parameters have to be strings and in pairs of two for defining the http headers and values.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param url string The URL for which you want to make an HTTP Request.
---@param method string The http request method/verb you want to make the request. f.e. 'GET', 'POST'
---@param data string The http request payload you want to sent.
---@param ... any @additional arguments as described
---@return FIN.Future ReturnValue 
function FINInternetCard:request(url, method, data, ...) end

--- A Internet Card!
---@class FIN.Build_InternetCard_C : FIN.FINInternetCard
local Build_InternetCard_C

---@class FIN.classes.FIN.Build_InternetCard_C : FIN.Build_InternetCard_C
classes.Build_InternetCard_C = nil

--- 
---@class FIN.IndicatorPole : Satis.Buildable
local IndicatorPole

---@class FIN.classes.FIN.IndicatorPole : FIN.IndicatorPole
classes.IndicatorPole = nil

--- Allows to change the color and light intensity of the indicator lamp.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param r number The red part of the color in which the light glows. (0.0 - 1.0)
---@param g number The green part of the color in which the light glows. (0.0 - 1.0)
---@param b number The blue part of the color in which the light glows. (0.0 - 1.0)
---@param e number The light intensity of the pole. (0.0 - 5.0)
function IndicatorPole:setColor(r, g, b, e) end

--- Allows to get the pole placed on top of this pole.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.IndicatorPole topPole The pole placed on top of this pole.
function IndicatorPole:getTopPole() end

--- Allows to get the color and light intensity of the indicator lamp.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number r The red part of the color in which the light glows. (0.0 - 1.0)
---@return number g The green part of the color in which the light glows. (0.0 - 1.0)
---@return number b The blue part of the color in which the light glows. (0.0 - 1.0)
---@return number e The light intensity of the pole. (0.0 - 5.0)
function IndicatorPole:getColor() end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.IndicatorPole ReturnValue 
function IndicatorPole:getBottomPole() end

--- Triggers when the color of the indicator pole changes.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Red, Green, Blue, Emissive = event.pull()
--- ```
--- - `signalName: "ColorChanged"`
--- - `component: IndicatorPole`
--- - `Red: number` <br>
--- The red part of the color in which the light glows. (0.0 - 1.0)
--- - `Green: number` <br>
--- The green part of the color in which the light glows. (0.0 - 1.0)
--- - `Blue: number` <br>
--- The blue part of the color in which the light glows. (0.0 - 1.0)
--- - `Emissive: number` <br>
--- The light intensity of the pole. (0.0 - 5.0)
---@deprecated
---@type FIN.Signal
IndicatorPole.SIGNAL_ColorChanged = nil

--- The FicsIt-Networks indicator light allows yout to determine by the looks of from far away the state of a machine or program.<br>
--- <br>
--- It has dynamic height, is stack able and you can control the color of it via accessing it from the computer network.
---@class FIN.Build_IndicatorPole_C : FIN.IndicatorPole
local Build_IndicatorPole_C

---@class FIN.classes.FIN.Build_IndicatorPole_C : FIN.Build_IndicatorPole_C
classes.Build_IndicatorPole_C = nil

--- 
---@class FIN.ModularIndicatorPole : Satis.Buildable
local ModularIndicatorPole

---@class FIN.classes.FIN.ModularIndicatorPole : FIN.ModularIndicatorPole
classes.ModularIndicatorPole = nil

--- Returns the next pole module if any.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Engine.Actor next The next module in this chain.
function ModularIndicatorPole:getNext() end

--- Gets the module at the given position in the stack
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param module number The module at the given offset in the stack or nil if none
---@return Engine.Actor index The index in the stack, 0 being the first module
function ModularIndicatorPole:getModule(module) end

--- The Modular FicsIt Indicator Pole allows busy pioneers to check on the status of machines, factories and much more from a long distance far away. To express the status you can stack individual modules. FicsIt invested more money to make the indicator pole suitable for every situation by allowing it to be placed on walls, floors and beams with a dynamic orientation and even dynamic height.
---@class FIN.Build_ModularIndicatorPole_C : FIN.ModularIndicatorPole
local Build_ModularIndicatorPole_C

---@class FIN.classes.FIN.Build_ModularIndicatorPole_C : FIN.Build_ModularIndicatorPole_C
classes.Build_ModularIndicatorPole_C = nil

--- 
---@class FIN.FINModularIndicatorPoleModule : Satis.Buildable
local FINModularIndicatorPoleModule

---@class FIN.classes.FIN.FINModularIndicatorPoleModule : FIN.FINModularIndicatorPoleModule
classes.FINModularIndicatorPoleModule = nil

--- Gets the previous module or the base mount if this called from the last module.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Buildable previous The previous module or base mount.
function FINModularIndicatorPoleModule:getPrevious() end

--- Returns the next pole module if any.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.FINModularIndicatorPoleModule next The next module in this chain.
function FINModularIndicatorPoleModule:getNext() end

--- FicsIt Buzzer Module for FicsIt Modular Indicator Poles provides pioneers with the most fundamental sound generator. 
---@class FIN.ModularPoleModule_Buzzer : FIN.FINModularIndicatorPoleModule
local ModularPoleModule_Buzzer

---@class FIN.classes.FIN.ModularPoleModule_Buzzer : FIN.ModularPoleModule_Buzzer
classes.ModularPoleModule_Buzzer = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
ModularPoleModule_Buzzer.volume = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
ModularPoleModule_Buzzer.decayCurve = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
ModularPoleModule_Buzzer.decayTime = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
ModularPoleModule_Buzzer.attackCurve = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
ModularPoleModule_Buzzer.isPlaying = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
ModularPoleModule_Buzzer.attackTime = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
ModularPoleModule_Buzzer.frequency = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
function ModularPoleModule_Buzzer:stop() end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
function ModularPoleModule_Buzzer:beep() end

--- FicsIt Indicator Module for FicsIt Modular Indicator Poles provides pioneers with the most fundamental indicator. The new and improved incandecent RGB bulb provides versatility to the industrious. Each modules color and intensity can be set via the network by a computer.
---@class FIN.ModularPoleModule_Indicator : FIN.FINModularIndicatorPoleModule
local ModularPoleModule_Indicator

---@class FIN.classes.FIN.ModularPoleModule_Indicator : FIN.ModularPoleModule_Indicator
classes.ModularPoleModule_Indicator = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Engine.Color FLinearColor 
function ModularPoleModule_Indicator:getColor() end

--- Sets the color of this module
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param r number The red part of the color in which the light glows. (0.0 - 1.0)
---@param g number The green part of the color in which the light glows. (0.0 - 1.0)
---@param b number The blue part of the color in which the light glows. (0.0 - 1.0)
---@param e number The light intensity of the pole. (>=0.0)
function ModularPoleModule_Indicator:setColor(r, g, b, e) end

--- 
---@class FIN.FINModuleBase : Satis.Buildable
local FINModuleBase

---@class FIN.classes.FIN.FINModuleBase : FIN.FINModuleBase
classes.FINModuleBase = nil

--- 
---@class FIN.FINModuleScreen : FIN.FINModuleBase
local FINModuleScreen

---@class FIN.classes.FIN.FINModuleScreen : FIN.FINModuleScreen
classes.FINModuleScreen = nil

--- This Screen Module for modular I/O Panels allows you to show graphics a GPU renders and to interact with it.<br>
--- <br>
--- You can use the instance of the module to bind it to a GPU. The screen will then display the graphics the GPU renders. If you just look at the screen with the crosshair you will trigger the GPUs OnMouseMove events or if you event click with the right of left mouse button while doing so, you can also trigger the MouseDown and MouseUp events.
---@class FIN.Build_ModuleScreen_C : FIN.FINModuleScreen
local Build_ModuleScreen_C

---@class FIN.classes.FIN.Build_ModuleScreen_C : FIN.Build_ModuleScreen_C
classes.Build_ModuleScreen_C = nil

--- This Button Module for modular I/O Panels can have different knob color and brightnesses and you can use them to trigger specific programmed events.<br>
--- <br>
--- Use the Ficsit Label Marker to change the text and foreground color of the button.
---@class FIN.PushbuttonModule : FIN.FINModuleBase
local PushbuttonModule

---@class FIN.classes.FIN.PushbuttonModule : FIN.PushbuttonModule
classes.PushbuttonModule = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
PushbuttonModule.enabled = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function PushbuttonModule:setColor(Red, Green, Blue, Emit) end

--- Triggers a button press by code.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function PushbuttonModule:Trigger() end

--- Triggers when the button gets pressed.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component = event.pull()
--- ```
--- - `signalName: "Trigger"`
--- - `component: PushbuttonModule`
---@deprecated
---@type FIN.Signal
PushbuttonModule.SIGNAL_Trigger = nil

--- This Potentiometer Module allows for input of a fixed value range and fires a signal with the new value each time the internal counter changes. This version has a readout display on it.
---@class FIN.PotWDisplayModule : FIN.FINModuleBase
local PotWDisplayModule

---@class FIN.classes.FIN.PotWDisplayModule : FIN.PotWDisplayModule
classes.PotWDisplayModule = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
PotWDisplayModule.enabled = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
PotWDisplayModule.autovalue = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
PotWDisplayModule.value = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
PotWDisplayModule.max = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
PotWDisplayModule.min = nil

--- Sets the text to be displayed on this micro display
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param text string The new text to display
function PotWDisplayModule:setText(text) end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function PotWDisplayModule:setColor(Red, Green, Blue, Emit) end

--- Signal fired when this potentiometers value changes by user interaction.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Value = event.pull()
--- ```
--- - `signalName: "value"`
--- - `component: PotWDisplayModule`
--- - `Value: number` <br>
--- The new value of this potentiometer
---@deprecated
---@type FIN.Signal
PotWDisplayModule.SIGNAL_value = nil

--- This Switch Module for modular I/O Panels is used to toggle between a true and false value. It has an illuminable spot on the knob and you can use them to trigger specific programmed events.
---@class FIN.SwitchModule2Position : FIN.FINModuleBase
local SwitchModule2Position

---@class FIN.classes.FIN.SwitchModule2Position : FIN.SwitchModule2Position
classes.SwitchModule2Position = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
SwitchModule2Position.enabled = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
SwitchModule2Position.state = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function SwitchModule2Position:setColor(Red, Green, Blue, Emit) end

--- Fired when this switch changes its state<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, NewValue = event.pull()
--- ```
--- - `signalName: "ChangeState"`
--- - `component: SwitchModule2Position`
--- - `NewValue: boolean` <br>
--- The new value this switch has taken
---@deprecated
---@type FIN.Signal
SwitchModule2Position.SIGNAL_ChangeState = nil

--- This Switch Module for modular I/O Panels is used to toggle between three different settings. It has an illuminable spot on the knob and you can use them to trigger specific programmed events.
---@class FIN.SwitchModule3Position : FIN.FINModuleBase
local SwitchModule3Position

---@class FIN.classes.FIN.SwitchModule3Position : FIN.SwitchModule3Position
classes.SwitchModule3Position = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
SwitchModule3Position.enabled = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
SwitchModule3Position.state = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function SwitchModule3Position:setColor(Red, Green, Blue, Emit) end

--- Fired when this switch changes its state<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, NewValue = event.pull()
--- ```
--- - `signalName: "ChangeState"`
--- - `component: SwitchModule3Position`
--- - `NewValue: number` <br>
--- The new value this switch has taken
---@deprecated
---@type FIN.Signal
SwitchModule3Position.SIGNAL_ChangeState = nil

--- This Stop Button Module for the modular I/O Panel is used to trigger important programmable events.
---@class FIN.ModuleStopButton : FIN.FINModuleBase
local ModuleStopButton

---@class FIN.classes.FIN.ModuleStopButton : FIN.ModuleStopButton
classes.ModuleStopButton = nil

--- Triggers a button press by code.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function ModuleStopButton:trigger() end

--- Triggers when the button gets pressed.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component = event.pull()
--- ```
--- - `signalName: "Trigger"`
--- - `component: ModuleStopButton`
---@deprecated
---@type FIN.Signal
ModuleStopButton.SIGNAL_Trigger = nil

--- This Button Module for modular I/O Panels can have different knob color and brightnesses and you can use them to trigger specific programmed events.
---@class FIN.ModuleButton : FIN.FINModuleBase
local ModuleButton

---@class FIN.classes.FIN.ModuleButton : FIN.ModuleButton
classes.ModuleButton = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function ModuleButton:setColor(Red, Green, Blue, Emit) end

--- Triggers a button press by code.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function ModuleButton:trigger() end

--- Triggers when the button gets pressed.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component = event.pull()
--- ```
--- - `signalName: "Trigger"`
--- - `component: ModuleButton`
---@deprecated
---@type FIN.Signal
ModuleButton.SIGNAL_Trigger = nil

--- This Potentiometer Module allows for input of a value with infinite range, this because it only fires how much the value changed since last, not how much it is at.
---@class FIN.EncoderModule : FIN.FINModuleBase
local EncoderModule

---@class FIN.classes.FIN.EncoderModule : FIN.EncoderModule
classes.EncoderModule = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
EncoderModule.enabled = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function EncoderModule:setColor(Red, Green, Blue, Emit) end

--- Signal fired when this potentiometers value changes by user interaction. <br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Value = event.pull()
--- ```
--- - `signalName: "value"`
--- - `component: EncoderModule`
--- - `Value: number` <br>
--- The amount of which this potentiometer have changed since the last tick. 
---@deprecated
---@type FIN.Signal
EncoderModule.SIGNAL_value = nil

--- The Lever Module for the modular I/O Panel is used to switch a programm state between two different value (on or off).
---@class FIN.ModuleSwitch : FIN.FINModuleBase
local ModuleSwitch

---@class FIN.classes.FIN.ModuleSwitch : FIN.ModuleSwitch
classes.ModuleSwitch = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
ModuleSwitch.state = nil

--- <br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, State = event.pull()
--- ```
--- - `signalName: "ChangeState"`
--- - `component: ModuleSwitch`
--- - `State: boolean` <br>
--- 
---@deprecated
---@type FIN.Signal
ModuleSwitch.SIGNAL_ChangeState = nil

end
do

--- This Potentiometer Module allows for input of a fixed value range and fires a signal with the new value each time the internal counter changes.
---@class FIN.PotentiometerModule : FIN.FINModuleBase
local PotentiometerModule

---@class FIN.classes.FIN.PotentiometerModule : FIN.PotentiometerModule
classes.PotentiometerModule = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
PotentiometerModule.enabled = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
PotentiometerModule.value = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
PotentiometerModule.max = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
PotentiometerModule.min = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function PotentiometerModule:setColor(Red, Green, Blue, Emit) end

--- Signal fired when this potentiometers value changes by user interaction.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Value = event.pull()
--- ```
--- - `signalName: "valueChanged"`
--- - `component: PotentiometerModule`
--- - `Value: number` <br>
--- The new value of this potentiometer
---@deprecated
---@type FIN.Signal
PotentiometerModule.SIGNAL_valueChanged = nil

--- The Potentiometer Module for the Modular I/O Control Panel allows you to have rotation input value for you programs.<br>
--- <br>
--- You can rotate it indefinetly into any direction where every rotation triggers a computer network signal.
---@class FIN.ModulePotentiometer : FIN.FINModuleBase
local ModulePotentiometer

---@class FIN.classes.FIN.ModulePotentiometer : FIN.ModulePotentiometer
classes.ModulePotentiometer = nil

--- Rotates the potentiometer into the given direction.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param anticlockwise boolean True if the potentiometer should be rotated anticlockwise.
function ModulePotentiometer:rotate(anticlockwise) end

--- Triggers if the potentiometer gets rotated by a player or by code.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, anticlockwise = event.pull()
--- ```
--- - `signalName: "PotRotate"`
--- - `component: ModulePotentiometer`
--- - `anticlockwise: boolean` <br>
--- 
---@deprecated
---@type FIN.Signal
ModulePotentiometer.SIGNAL_PotRotate = nil

--- This Mushroom Button Module for modular I/O Panels can have different knob color and brightnesses and you can use them to trigger specific programmed events.<br>
--- <br>
--- Use the Ficsit Label Marker to change the text and foreground color of the button.
---@class FIN.MushroomPushbuttonModule : FIN.FINModuleBase
local MushroomPushbuttonModule

---@class FIN.classes.FIN.MushroomPushbuttonModule : FIN.MushroomPushbuttonModule
classes.MushroomPushbuttonModule = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
MushroomPushbuttonModule.enabled = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function MushroomPushbuttonModule:setColor(Red, Green, Blue, Emit) end

--- Triggers a button press by code.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function MushroomPushbuttonModule:Trigger() end

--- Triggers when the button gets pressed.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component = event.pull()
--- ```
--- - `signalName: "Trigger"`
--- - `component: MushroomPushbuttonModule`
---@deprecated
---@type FIN.Signal
MushroomPushbuttonModule.SIGNAL_Trigger = nil

--- This Mushroom Button Module for modular I/O Panels can have different knob color and brightnesses and you can use them to trigger specific programmed events.<br>
--- <br>
--- Use the Ficsit Label Marker to change the text and foreground color of the button.
---@class FIN.MushroomPushbuttonModuleBig : FIN.MushroomPushbuttonModule
local MushroomPushbuttonModuleBig

---@class FIN.classes.FIN.MushroomPushbuttonModuleBig : FIN.MushroomPushbuttonModuleBig
classes.MushroomPushbuttonModuleBig = nil

--- Provides a relatively small text only display for Control Panels. <br>
--- Text height is fixed, but text is squeezed to fit horizontally.
---@class FIN.LargeMicroDisplayModule : FIN.FINModuleBase
local LargeMicroDisplayModule

---@class FIN.classes.FIN.LargeMicroDisplayModule : FIN.LargeMicroDisplayModule
classes.LargeMicroDisplayModule = nil

--- Sets the text to be displayed on this micro display
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param text string The new text to display
function LargeMicroDisplayModule:setText(text) end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function LargeMicroDisplayModule:setColor(Red, Green, Blue, Emit) end

--- Label is just a module for placing a label onto the panel
---@class FIN.Label1x1Module : FIN.FINModuleBase
local Label1x1Module

---@class FIN.classes.FIN.Label1x1Module : FIN.Label1x1Module
classes.Label1x1Module = nil

--- Label is just a module for placing a label onto the panel
---@class FIN.Label3x1Module : FIN.Label1x1Module
local Label3x1Module

---@class FIN.classes.FIN.Label3x1Module : FIN.Label3x1Module
classes.Label3x1Module = nil

--- Label is just a module for placing a label onto the panel
---@class FIN.Label2x1Module : FIN.Label1x1Module
local Label2x1Module

---@class FIN.classes.FIN.Label2x1Module : FIN.Label2x1Module
classes.Label2x1Module = nil

--- Label is just a module for placing a label onto the panel
---@class FIN.Build_Module_RingedLabel_1x1_C : FIN.Label1x1Module
local Build_Module_RingedLabel_1x1_C

---@class FIN.classes.FIN.Build_Module_RingedLabel_1x1_C : FIN.Build_Module_RingedLabel_1x1_C
classes.Build_Module_RingedLabel_1x1_C = nil

--- A medium analogue Gauge for use on Large Panels. The red portion and needle position can be changed through FIN
---@class FIN.BigGaugeModule : FIN.FINModuleBase
local BigGaugeModule

---@class FIN.classes.FIN.BigGaugeModule : FIN.BigGaugeModule
classes.BigGaugeModule = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
BigGaugeModule.limit = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
BigGaugeModule.percent = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function BigGaugeModule:setBackgroundColor(Red, Green, Blue, Emit) end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function BigGaugeModule:setColor(Red, Green, Blue, Emit) end

--- This Button Module for modular I/O Panels can have different knob color and brightnesses and you can use them to trigger specific programmed events.
---@class FIN.Build_ModulePlug_C : FIN.FINModuleBase
local Build_ModulePlug_C

---@class FIN.classes.FIN.Build_ModulePlug_C : FIN.Build_ModulePlug_C
classes.Build_ModulePlug_C = nil

--- The FicsIt-Networks Text-Display Module for the Modular Control Panel is a simple GPU and Screen combined!<br>
--- <br>
--- It allows you to display any kind of text with differnt font sizes and you can even switch between two fonts!<br>
--- <br>
--- But you can't interact with it, nor change the background/foreground color as you can do with a GPU.
---@class FIN.ModuleTextDisplay : FIN.FINModuleBase
local ModuleTextDisplay

---@class FIN.classes.FIN.ModuleTextDisplay : FIN.ModuleTextDisplay
classes.ModuleTextDisplay = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@type boolean
ModuleTextDisplay.monospace = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@type number
ModuleTextDisplay.size = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@type string
ModuleTextDisplay.text = nil

--- A small analogue Gauge for use on Micro Enclosures. The red portion and needle position can be changed through FIN
---@class FIN.GaugeModule : FIN.FINModuleBase
local GaugeModule

---@class FIN.classes.FIN.GaugeModule : FIN.GaugeModule
classes.GaugeModule = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
GaugeModule.percent = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
GaugeModule.limit = nil

--- Sets the color of the limit region of the gauge
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param r number Red Color Value. Float between 0 and 1
---@param g number Green Color Value. Float between 0 and 1
---@param b number Blue Color Value. Float between 0 and 1
function GaugeModule:setBackgroundColor(r, g, b) end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function GaugeModule:setColor(Red, Green, Blue, Emit) end

--- A small buzzer for panel mounting capable of playing single frequency beeps
---@class FIN.BuzzerModule : FIN.FINModuleBase
local BuzzerModule

---@class FIN.classes.FIN.BuzzerModule : FIN.BuzzerModule
classes.BuzzerModule = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
BuzzerModule.volume = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
BuzzerModule.decayCurve = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
BuzzerModule.decayTime = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
BuzzerModule.attackCurve = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
BuzzerModule.isPlaying = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
BuzzerModule.attackTime = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
BuzzerModule.frequency = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
function BuzzerModule:stop() end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
function BuzzerModule:beep() end

--- Provides a small text only display for Control Panels. <br>
--- Can display up to 3 digits, One additional dot may be used.
---@class FIN.MicroDisplayModule : FIN.FINModuleBase
local MicroDisplayModule

---@class FIN.classes.FIN.MicroDisplayModule : FIN.MicroDisplayModule
classes.MicroDisplayModule = nil

--- Sets the text to be displayed on this micro display
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param text string The new text to display
function MicroDisplayModule:setText(text) end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function MicroDisplayModule:setColor(Red, Green, Blue, Emit) end

--- Provides a relatively small text only display for Control Panels. <br>
--- Text height is fixed, but text is squeezed to fit horizontally.
---@class FIN.SquareMicroDisplayModule : FIN.FINModuleBase
local SquareMicroDisplayModule

---@class FIN.classes.FIN.SquareMicroDisplayModule : FIN.SquareMicroDisplayModule
classes.SquareMicroDisplayModule = nil

--- Sets the text to be displayed on this micro display
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param text string The new text to display
function SquareMicroDisplayModule:setText(text) end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function SquareMicroDisplayModule:setColor(Red, Green, Blue, Emit) end

--- This subplate allows one to place a single module in the center of a 2x2 module grid.<br>
--- <br>
--- 
---@class FIN.BasicSubplate_2x2 : FIN.FINModuleBase
local BasicSubplate_2x2

---@class FIN.classes.FIN.BasicSubplate_2x2 : FIN.BasicSubplate_2x2
classes.BasicSubplate_2x2 = nil

--- Returns the module associated with this subplate.<br>
--- This is effectively the same as calling getModule(0,0)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Engine.Actor Module 
function BasicSubplate_2x2:getSubModule() end

--- Returns all the modules on this subplate
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Engine.Object[] modules 
function BasicSubplate_2x2:getModules() end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param X number 
---@param Y number 
---@return Engine.Actor Module 
function BasicSubplate_2x2:getModule(X, Y) end

--- This subplate allows one to place a single module in the center of a 2x2 module grid.<br>
--- <br>
--- 
---@class FIN.Build_BasicSubplate2x2Labeled_C : FIN.BasicSubplate_2x2
local Build_BasicSubplate2x2Labeled_C

---@class FIN.classes.FIN.Build_BasicSubplate2x2Labeled_C : FIN.Build_BasicSubplate2x2Labeled_C
classes.Build_BasicSubplate2x2Labeled_C = nil

--- Indicator Module for panels
---@class FIN.IndicatorModule : FIN.FINModuleBase
local IndicatorModule

---@class FIN.classes.FIN.IndicatorModule : FIN.IndicatorModule
classes.IndicatorModule = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Red number 
---@param Green number 
---@param Blue number 
---@param Emit number 
function IndicatorModule:setColor(Red, Green, Blue, Emit) end

--- 
---@class FIN.Screen : Satis.Buildable
local Screen

---@class FIN.classes.FIN.Screen : FIN.Screen
classes.Screen = nil

--- Returns the size of the screen in 'panels'.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@return number width The width of the screen.
---@return number height The height of the screen.
function Screen:getSize() end

--- The FicsIt-Networks large screen allows you to display anything a GPU can render onto a huge plane.<br>
--- <br>
--- You can also interact with the monitor by locking at it and also by clicking on it.
---@class FIN.Build_Screen_C : FIN.Screen
local Build_Screen_C

---@class FIN.classes.FIN.Build_Screen_C : FIN.Build_Screen_C
classes.Build_Screen_C = nil

--- 
---@class FIN.FINSizeablePanel : Satis.Buildable
local FINSizeablePanel

---@class FIN.classes.FIN.FINSizeablePanel : FIN.FINSizeablePanel
classes.FINSizeablePanel = nil

--- This panel allows for dynamic sizeing. For placing on walls.
---@class FIN.SizeableModulePanel : FIN.FINSizeablePanel
local SizeableModulePanel

---@class FIN.classes.FIN.SizeableModulePanel : FIN.SizeableModulePanel
classes.SizeableModulePanel = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
SizeableModulePanel.height = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
SizeableModulePanel.width = nil

--- Returns all modules placed on the panel.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Engine.Object[] modules All the modules placed on the panel.
function SizeableModulePanel:getModules() end

--- Returns the module placed at the given location on the panel.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param x number The x position of the command point, starting from the non-cable end. Indexing starts at 0.
---@param y number The y position  of the command point, starting from the non-cable end. Indexing starts at 0.
---@return Engine.Actor module The module you want to get. Null if no module was placed.
function SizeableModulePanel:getModule(x, y) end

--- This speaker pole allows to play custom sound files, In-Game
---@class FIN.SpeakerPole : Satis.Buildable
local SpeakerPole

---@class FIN.classes.FIN.SpeakerPole : FIN.SpeakerPole
classes.SpeakerPole = nil

--- Stops the currently playing sound file.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
function SpeakerPole:stopSound() end

--- Plays a custom sound file ingame
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param sound string The sound file (without the file ending) you want to play
---@param startPoint number The start point in seconds at which the system should start playing
function SpeakerPole:playSound(sound, startPoint) end

--- Triggers when the sound play state of the speaker pole changes.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Type, Sound = event.pull()
--- ```
--- - `signalName: "SpeakerSound"`
--- - `component: SpeakerPole`
--- - `Type: number` <br>
--- The type of the speaker pole event.
--- - `Sound: string` <br>
--- The sound file including in the event.
---@deprecated
---@type FIN.Signal
SpeakerPole.SIGNAL_SpeakerSound = nil

--- The FicsIt-Networks speaker pole is a network component which allows you to use one more sense of the pioneers to give commands to them or to just make ambient better.<br>
--- <br>
--- The speaker pole can play sound files located in the Computer Folder "/Sounds" in your Satisfactory Save-Games-Folder. The FicsIt-Networks speaker pole is only able to play .ogg files cause FicsIt Inc. has the opinion other file formates are useless.
---@class FIN.Build_Speakers_C : FIN.SpeakerPole
local Build_Speakers_C

---@class FIN.classes.FIN.Build_Speakers_C : FIN.Build_Speakers_C
classes.Build_Speakers_C = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Volume number 
function Build_Speakers_C:setVolume(Volume) end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Range number 
function Build_Speakers_C:setRange(Range) end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number Volume 
function Build_Speakers_C:getVolume() end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number Range 
function Build_Speakers_C:getRange() end

--- <br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, setting, New, Old = event.pull()
--- ```
--- - `signalName: "SpeakerSetting"`
--- - `component: Build_Speakers_C`
--- - `setting: number` <br>
--- 
--- - `New: number` <br>
--- 
--- - `Old: number` <br>
--- 
---@deprecated
---@type FIN.Signal
Build_Speakers_C.SIGNAL_SpeakerSetting = nil

--- 
---@class FIN.VehicleScanner : Satis.Buildable
local VehicleScanner

---@class FIN.classes.FIN.VehicleScanner : FIN.VehicleScanner
classes.VehicleScanner = nil

--- Allows to change the color and light intensity of the scanner.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param r number The red part of the color in which the scanner glows. (0.0 - 1.0)
---@param g number The green part of the color in which the scanner glows. (0.0 - 1.0)
---@param b number The blue part of the color in which the scanner glows. (0.0 - 1.0)
---@param e number The light intensity of the scanner. (0.0 - 5.0)
function VehicleScanner:setColor(r, g, b, e) end

--- Returns the last vehicle that entered the scanner.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Vehicle vehicle The vehicle that entered the scanner. null if it has already left the scanner.
function VehicleScanner:getLastVehicle() end

--- Allows to get the color and light intensity of the scanner.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number r The red part of the color in which the scanner glows. (0.0 - 1.0)
---@return number g The green part of the color in which the scanner glows. (0.0 - 1.0)
---@return number b The blue part of the color in which the scanner glows. (0.0 - 1.0)
---@return number e The light intensity of the scanner. (0.0 - 5.0)
function VehicleScanner:getColor() end

--- Triggers when a vehicle leaves the scanner.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Vehicle = event.pull()
--- ```
--- - `signalName: "OnVehicleExit"`
--- - `component: VehicleScanner`
--- - `Vehicle: Satis.Vehicle` <br>
--- The vehicle that left the scanner.
---@deprecated
---@type FIN.Signal
VehicleScanner.SIGNAL_OnVehicleExit = nil

--- Triggers when a vehicle enters the scanner.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Vehicle = event.pull()
--- ```
--- - `signalName: "OnVehicleEnter"`
--- - `component: VehicleScanner`
--- - `Vehicle: Satis.Vehicle` <br>
--- The vehicle that entered the scanner.
---@deprecated
---@type FIN.Signal
VehicleScanner.SIGNAL_OnVehicleEnter = nil

--- The FicsIt-Networks Vehicle Scanner allows you to communicate with vehicles driving over the scanner.<br>
--- <br>
--- You can also get notified when a vehicle enters or leaves the scanner.
---@class FIN.Build_VehicleScanner_C : FIN.VehicleScanner
local Build_VehicleScanner_C

---@class FIN.classes.FIN.Build_VehicleScanner_C : FIN.Build_VehicleScanner_C
classes.Build_VehicleScanner_C = nil

--- This Pole allows you to connect multiple network components to it via the network cables.<br>
--- <br>
--- This is a essential building for spreading your computer network into the whole landscape.<br>
--- <br>
--- It basically allows you to digitalize the world!
---@class FIN.Build_NetworkPole_C : Satis.Buildable
local Build_NetworkPole_C

---@class FIN.classes.FIN.Build_NetworkPole_C : FIN.Build_NetworkPole_C
classes.Build_NetworkPole_C = nil

--- This FicsIt-Networks Wall Plug allows you to distribute a network circuit more easily near buildings and indoors.
---@class FIN.Build_NetworkWallPlug_C : Satis.Buildable
local Build_NetworkWallPlug_C

---@class FIN.classes.FIN.Build_NetworkWallPlug_C : FIN.Build_NetworkWallPlug_C
classes.Build_NetworkWallPlug_C = nil

--- This FicsIt-Networks Small Wall Plug allows you to connect the thin network cable only usable with MCH panels and other small components.<br>
--- <br>
--- You can then connect Normal/Large Network Cables to those Small Network Plugs to be able to connect your MCP Panels and such to a computer.
---@class FIN.Build_SmallNetworkWallPlug_C : Satis.Buildable
local Build_SmallNetworkWallPlug_C

---@class FIN.classes.FIN.Build_SmallNetworkWallPlug_C : FIN.Build_SmallNetworkWallPlug_C
classes.Build_SmallNetworkWallPlug_C = nil

--- See Display Name
---@class Satis.Build_Blueprint_C : Satis.Buildable
local Build_Blueprint_C

---@class FIN.classes.Satis.Build_Blueprint_C : Satis.Build_Blueprint_C
classes.Build_Blueprint_C = nil

--- This FicsIt-Networks Wall Plug allows you to pass a network circuit through a wall, allowing for more ease of use of the network cables.
---@class FIN.Build_NetworkWallPlug_Double_C : Satis.Buildable
local Build_NetworkWallPlug_Double_C

---@class FIN.classes.FIN.Build_NetworkWallPlug_Double_C : FIN.Build_NetworkWallPlug_Double_C
classes.Build_NetworkWallPlug_Double_C = nil

--- This large modular I/O control panel allows you to attach multiple different modules on to it and use them as I/O to control you programms.<br>
--- <br>
--- You can connect it to the FicsIt-Network.<br>
--- <br>
--- Important to note is that every module is it's own component, that means if you want to listen to the signals, you will need to listen to each of them individually.
---@class FIN.LargeControlPanel : Satis.Buildable
local LargeControlPanel

---@class FIN.classes.FIN.LargeControlPanel : FIN.LargeControlPanel
classes.LargeControlPanel = nil

--- Returns all modules placed on the panel.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Engine.Object[] modules All the modules placed on the panel.
function LargeControlPanel:getModules() end

--- Returns the module placed at the given location on the panel.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param x number The x location of the module on the panel. (0 = left)
---@param y number The y location of the module on the panel. (0 = bottom)
---@return Engine.Actor module The module you want to get. Null if no module was placed.
function LargeControlPanel:getModule(x, y) end

--- Enclosure for 1 command points
---@class FIN.ModulePanel : Satis.Buildable
local ModulePanel

---@class FIN.classes.FIN.ModulePanel : FIN.ModulePanel
classes.ModulePanel = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param Y number 
---@return Engine.Actor Module 
function ModulePanel:getYModule(Y) end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param X number 
---@return Engine.Actor Module 
function ModulePanel:getXModule(X) end

--- Returns all modules placed on the panel.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Engine.Object[] modules All the modules placed on the panel.
function ModulePanel:getModules() end

--- Returns the module placed at the given location on the panel.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param x number The x position of the command point, starting from the non-cable end. Indexing starts at 0.
---@param y number The y position  of the command point, starting from the non-cable end. Indexing starts at 0.
---@return Engine.Actor module The module you want to get. Null if no module was placed.
function ModulePanel:getModule(x, y) end

--- Enclosure for 3 command points.<br>
--- <br>
--- These Micro Control Panels can be used through out your factory and allow you to have an easier look on the state of your factory and they allow you to control your factory more easily.<br>
--- <br>
--- You can fully customize the control panels with buttons lights etc.
---@class FIN.Build_MicroPanel3_C : FIN.ModulePanel
local Build_MicroPanel3_C

---@class FIN.classes.FIN.Build_MicroPanel3_C : FIN.Build_MicroPanel3_C
classes.Build_MicroPanel3_C = nil

--- Micro Control Panel for 1 command point, center placement.<br>
--- <br>
--- These Micro Control Panels can be used through out your factory and allow you to have an easier look on the state of your factory and they allow you to control your factory more easily.<br>
--- <br>
--- You can fully customize the control panels with buttons lights etc.
---@class FIN.Build_MicroPanel1_Center_C : FIN.ModulePanel
local Build_MicroPanel1_Center_C

---@class FIN.classes.FIN.Build_MicroPanel1_Center_C : FIN.Build_MicroPanel1_Center_C
classes.Build_MicroPanel1_Center_C = nil

--- Enclosure for 6 command points.<br>
--- <br>
--- These Micro Control Panels can be used through out your factory and allow you to have an easier look on the state of your factory and they allow you to control your factory more easily.<br>
--- <br>
--- You can fully customize the control panels with buttons lights etc.
---@class FIN.Build_MicroPanel6_C : FIN.ModulePanel
local Build_MicroPanel6_C

---@class FIN.classes.FIN.Build_MicroPanel6_C : FIN.Build_MicroPanel6_C
classes.Build_MicroPanel6_C = nil

--- Enclosure for 1 command points.<br>
--- <br>
--- These Micro Control Panels can be used through out your factory and allow you to have an easier look on the state of your factory and they allow you to control your factory more easily.<br>
--- <br>
--- You can fully customize the control panels with buttons lights etc.
---@class FIN.Build_MicroPanel1_C : FIN.ModulePanel
local Build_MicroPanel1_C

---@class FIN.classes.FIN.Build_MicroPanel1_C : FIN.Build_MicroPanel1_C
classes.Build_MicroPanel1_C = nil

--- Enclosure for 2 command points.<br>
--- <br>
--- These Micro Control Panels can be used through out your factory and allow you to have an easier look on the state of your factory and they allow you to control your factory more easily.<br>
--- <br>
--- You can fully customize the control panels with buttons lights etc.
---@class FIN.Build_MicroPanel2_C : FIN.ModulePanel
local Build_MicroPanel2_C

---@class FIN.classes.FIN.Build_MicroPanel2_C : FIN.Build_MicroPanel2_C
classes.Build_MicroPanel2_C = nil

--- This large vertical modular I/O control panel allows you to attach multiple different modules on to it and use them as I/O to control your programms.<br>
--- <br>
--- You can connect it to the FicsIt-Network.<br>
--- <br>
--- Important to note is that every module is it's own component, that means if you want to listen to the signals, you will need to listen to each of them individually.
---@class FIN.LargeVerticalControlPanel : Satis.Buildable
local LargeVerticalControlPanel

---@class FIN.classes.FIN.LargeVerticalControlPanel : FIN.LargeVerticalControlPanel
classes.LargeVerticalControlPanel = nil

--- Returns all modules placed on the panels.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Engine.Object[] modules All the modules placed on the panels.
function LargeVerticalControlPanel:getModules() end

--- Returns the module placed at the given location on the given panel.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param x number The x location of the module on the panel. (0 = left)
---@param y number The y location of the module on the panel. (0 = bottom)
---@param panel number The panel you want to get the module from.
---@return Engine.Actor module The module you want to get. Null if no module was placed.
function LargeVerticalControlPanel:getModule(x, y, panel) end

--- Attaches to Walls.<br>
--- Useful for routing Conveyor Belts more precisely and over long distances.
---@class Satis.Build_ConveyorPoleWall_C : Satis.Buildable
local Build_ConveyorPoleWall_C

---@class FIN.classes.Satis.Build_ConveyorPoleWall_C : Satis.Build_ConveyorPoleWall_C
classes.Build_ConveyorPoleWall_C = nil

--- Allows you to manually craft a wide range of different parts. <br>
--- These parts can then be used to construct various factory buildings, vehicles, and equipment.
---@class Satis.Build_WorkBenchIntegrated_C : Satis.Buildable
local Build_WorkBenchIntegrated_C

---@class FIN.classes.Satis.Build_WorkBenchIntegrated_C : Satis.Build_WorkBenchIntegrated_C
classes.Build_WorkBenchIntegrated_C = nil

--- Attaches to Walls, allowing Hypertubes to pass through.
---@class Satis.Build_HyperTubeWallHole_C : Satis.Buildable
local Build_HyperTubeWallHole_C

---@class FIN.classes.Satis.Build_HyperTubeWallHole_C : Satis.Build_HyperTubeWallHole_C
classes.Build_HyperTubeWallHole_C = nil

--- Attaches to Walls.<br>
--- Supports Hypertubes, allowing them to stretch over longer distances.
---@class Satis.Build_HyperTubeWallSupport_C : Satis.Buildable
local Build_HyperTubeWallSupport_C

---@class FIN.classes.Satis.Build_HyperTubeWallSupport_C : Satis.Build_HyperTubeWallSupport_C
classes.Build_HyperTubeWallSupport_C = nil

--- Provides a good vantage point to facilitate factory construction.
---@class Satis.Build_LookoutTower_C : Satis.Buildable
local Build_LookoutTower_C

---@class FIN.classes.Satis.Build_LookoutTower_C : Satis.Build_LookoutTower_C
classes.Build_LookoutTower_C = nil

--- Attaches to Walls.<br>
--- Used to connect Pipelines over longer distances.
---@class Satis.Build_PipelineSupportWall_C : Satis.Buildable
local Build_PipelineSupportWall_C

---@class FIN.classes.Satis.Build_PipelineSupportWall_C : Satis.Build_PipelineSupportWall_C
classes.Build_PipelineSupportWall_C = nil

--- Attaches to Walls, allowing Pipelines to pass through.
---@class Satis.Build_PipelineSupportWallHole_C : Satis.Buildable
local Build_PipelineSupportWallHole_C

---@class FIN.classes.Satis.Build_PipelineSupportWallHole_C : Satis.Build_PipelineSupportWallHole_C
classes.Build_PipelineSupportWallHole_C = nil

--- Allows you to manually craft a wide range of different parts. <br>
--- These parts can then be used to construct various factory buildings, vehicles, and equipment.
---@class Satis.Build_WorkBench_C : Satis.Buildable
local Build_WorkBench_C

---@class FIN.classes.Satis.Build_WorkBench_C : Satis.Build_WorkBench_C
classes.Build_WorkBench_C = nil

--- Used to manually craft equipment.
---@class Satis.Build_Workshop_C : Satis.Buildable
local Build_Workshop_C

---@class FIN.classes.Satis.Build_Workshop_C : Satis.Build_Workshop_C
classes.Build_Workshop_C = nil

--- A giant Candy Cane decoration.<br>
--- <br>
--- - Not for consumption.<br>
--- - Do not inhale close to it without appropriate protection.<br>
--- - Do not put in your eyes.<br>
--- - Keep away from overly curious wildlife.
---@class Satis.Build_CandyCaneDecor_C : Satis.Buildable
local Build_CandyCaneDecor_C

---@class FIN.classes.Satis.Build_CandyCaneDecor_C : Satis.Build_CandyCaneDecor_C
classes.Build_CandyCaneDecor_C = nil

--- The closest thing you'll get to having a friend.
---@class Satis.Build_Snowman_C : Satis.Buildable
local Build_Snowman_C

---@class FIN.classes.Satis.Build_Snowman_C : Satis.Build_Snowman_C
classes.Build_Snowman_C = nil

--- Decorate this unique one-of-a-kind tree by progressing through the FICSMAS Holiday Event in the MAM.
---@class Satis.Build_XmassTree_C : Satis.Buildable
local Build_XmassTree_C

---@class FIN.classes.Satis.Build_XmassTree_C : Satis.Build_XmassTree_C
classes.Build_XmassTree_C = nil

--- A wreath woven from dead plants to bring that holiday spirit to your Walls.
---@class Satis.Build_WreathDecor_C : Satis.Buildable
local Build_WreathDecor_C

---@class FIN.classes.Satis.Build_WreathDecor_C : Satis.Build_WreathDecor_C
classes.Build_WreathDecor_C = nil

--- 
---@class Satis.Build_TetrominoGame_Computer_C : Satis.Buildable
local Build_TetrominoGame_Computer_C

---@class FIN.classes.Satis.Build_TetrominoGame_Computer_C : Satis.Build_TetrominoGame_Computer_C
classes.Build_TetrominoGame_Computer_C = nil

--- This class holds information and references about a trains (a collection of multiple railroad vehicles) and its timetable f.e.
---@class Satis.Train : Engine.Actor
local Train

---@class FIN.classes.Satis.Train : Satis.Train
classes.Train = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
Train.isPlayerDriven = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
Train.isSelfDriving = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Train.selfDrivingError = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
Train.hasTimeTable = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Train.dockState = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
Train.isDocked = nil

--- Returns the name of this train.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return string name The name of this train.
function Train:getName() end

--- Allows to set the name of this train.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param name string The new name of this trian.
function Train:setName(name) end

--- Returns the track graph of which this train is part of.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.TrackGraph track The track graph of which this train is part of.
function Train:getTrackGraph() end

--- Allows to set if the train should be self driving or not.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param selfDriving boolean True if the train should be self driving.
function Train:setSelfDriving(selfDriving) end

--- Returns the master locomotive that is part of this train.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadVehicle master The master locomotive of this train.
function Train:getMaster() end

--- Returns the timetable of this train.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.TimeTable timeTable The timetable of this train.
function Train:getTimeTable() end

--- Creates and returns a new timetable for this train.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@return Satis.TimeTable timeTable The new timetable for this train.
function Train:newTimeTable() end

--- Returns the first railroad vehicle that is part of this train.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadVehicle first The first railroad vehicle that is part of this train.
function Train:getFirst() end

--- Returns the last railroad vehicle that is part of this train.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadVehicle last The last railroad vehicle that is part of this train.
function Train:getLast() end

--- Trys to dock the train to the station it is currently at.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function Train:dock() end

--- Returns a list of all the vehicles this train has.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadVehicle[] vehicles A list of all the vehicles this train has.
function Train:getVehicles() end

--- Triggers when the self driving mode of the train changes<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, Enabled = event.pull()
--- ```
--- - `signalName: "SelfDrvingUpdate"`
--- - `component: Train`
--- - `Enabled: boolean` <br>
--- True if the train is now self driving.
---@deprecated
---@type FIN.Signal
Train.SIGNAL_SelfDrvingUpdate = nil

--- A Object that represents a whole power circuit.
---@class Satis.PowerCircuit : Engine.Object
local PowerCircuit

---@class FIN.classes.Satis.PowerCircuit : Satis.PowerCircuit
classes.PowerCircuit = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerCircuit.production = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerCircuit.consumption = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerCircuit.capacity = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerCircuit.batteryInput = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerCircuit.maxPowerConsumption = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
PowerCircuit.isFuesed = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
PowerCircuit.hasBatteries = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerCircuit.batteryCapacity = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerCircuit.batteryStore = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerCircuit.batteryStorePercent = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerCircuit.batteryTimeUntilFull = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerCircuit.batteryTimeUntilEmpty = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerCircuit.batteryIn = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
PowerCircuit.batteryOut = nil

--- Get Triggered when the fuse state of the power circuit changes.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component = event.pull()
--- ```
--- - `signalName: "PowerFuseChanged"`
--- - `component: PowerCircuit`
---@deprecated
---@type FIN.Signal
PowerCircuit.SIGNAL_PowerFuseChanged = nil

--- Contains the time table information of train.
---@class Satis.TimeTable : Engine.Actor
local TimeTable

---@class FIN.classes.Satis.TimeTable : Satis.TimeTable
classes.TimeTable = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
TimeTable.numStops = nil

--- Adds a stop to the time table.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index number The zero-based index at which the stop should get added.
---@param station Satis.RailroadStation The railroad station at which the stop should happen.
---@param ruleSet Satis.TrainDockingRuleSet The docking rule set that descibes when the train will depart from the station.
---@return boolean added True if the stop got sucessfully added to the time table.
function TimeTable:addStop(index, station, ruleSet) end

--- Removes the stop with the given index from the time table.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index number The zero-based index at which the stop should get added.
function TimeTable:removeStop(index) end

--- Returns a list of all the stops this time table has
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.TimeTableStop[] stops A list of time table stops this time table has.
function TimeTable:getStops() end

--- Allows to empty and fill the stops of this time table with the given list of new stops.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param stops FIN.TimeTableStop[] The new time table stops.
---@return boolean gotSet True if the stops got sucessfully set.
function TimeTable:setStops(stops) end

--- Allows to check if the given stop index is valid.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index number The zero-based stop index you want to check its validity.
---@return boolean valid True if the stop index is valid.
function TimeTable:isValidStop(index) end

--- Returns the stop at the given index.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index number The zero-based index of the stop you want to get.
---@return FIN.TimeTableStop stop The time table stop at the given index.
function TimeTable:getStop(index) end

--- Allows to override a stop already in the time table.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index number The zero-based index of the stop you want to override.
---@param stop FIN.TimeTableStop The time table stop you want to override with.
---@return boolean success True if setting was successful, false if not, f.e. invalid index.
function TimeTable:setStop(index, stop) end

--- Sets the stop, to which the train trys to drive to right now.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index number The zero-based index of the stop the train should drive to right now.
function TimeTable:setCurrentStop(index) end

--- Sets the current stop to the next stop in the time table.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function TimeTable:incrementCurrentStop() end

--- Returns the index of the stop the train drives to right now.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return number index The zero-based index of the stop the train tries to drive to right now.
function TimeTable:getCurrentStop() end

--- The list of targets/path-waypoints a autonomous vehicle can drive
---@class Satis.TargetList : Engine.Actor
local TargetList

---@class FIN.classes.Satis.TargetList : Satis.TargetList
classes.TargetList = nil

--- Returns the target struct at with the given index in the target list.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.TargetPoint target The TargetPoint-Struct with the given index in the target list.
function TargetList:getTarget() end

--- Removes the target with the given index from the target list.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index number The index of the target point you want to remove from the target list.
function TargetList:removeTarget(index) end

--- Adds the given target point struct at the end of the target list.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param target FIN.TargetPoint The target point you want to add.
function TargetList:addTarget(target) end

--- Allows to set the target at the given index to the given target point struct.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param index number The index of the target point you want to update with the given target point struct.
---@param target FIN.TargetPoint The new target point struct for the given index.
function TargetList:setTarget(index, target) end

--- Returns a list of target point structs of all the targets in the target point list.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.TargetPoint[] targets A list of target point structs containing all the targets of the target point list.
function TargetList:getTargets() end

--- Removes all targets from the target point list and adds the given array of target point structs to the empty target point list.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@param targets FIN.TargetPoint[] A list of target point structs you want to place into the empty target point list.
function TargetList:setTargets(targets) end

--- The dimensional depot, remote storage or also known as central storage.
---@class Satis.DimensionalDepot : Engine.Actor
local DimensionalDepot

---@class FIN.classes.Satis.DimensionalDepot : Satis.DimensionalDepot
classes.DimensionalDepot = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
DimensionalDepot.centralStorageItemStackLimit = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
DimensionalDepot.centralStorageTimeToUpload = nil

--- Returns the number of items of a given type that is stored within the central storage.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param itemType Satis.ItemType The type of the item you want to get the number of items in the central storage from.
---@return number number The number of items in the central storage.
function DimensionalDepot:getItemCountFromCentralStorage(itemType) end

--- Return a list of all items the central storage currently contains.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.ItemAmount[] items The list of items that the central storage currently contains.
function DimensionalDepot:getAllItemsFromCentralStorage() end

--- Returns true if any items of the given type can be uploaded to the central storage.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param itemType Satis.ItemType The type of the item you want to check if it can be uploaded.
---@return boolean canUpload True if the given item type can be uploaded to the central storage.
function DimensionalDepot:canUploadItemsToCentralStorage(itemType) end

--- Returns the maxiumum number of items of a given type you can upload to the central storage.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param itemType Satis.ItemType The type of the item you want to check if it can be uploaded.
---@return number number The maximum number of items you can upload.
function DimensionalDepot:getCentralStorageItemLimit(itemType) end

--- Gets triggered when a new item gets uploaded to the central storage.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, ItemType = event.pull()
--- ```
--- - `signalName: "NewItemAdded"`
--- - `component: DimensionalDepot`
--- - `ItemType: Satis.ItemType` <br>
--- The type of the item that got uploaded.
---@deprecated
---@type FIN.Signal
DimensionalDepot.SIGNAL_NewItemAdded = nil

--- Gets triggered when the amount of item in the central storage changes.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, ItemType, ItemAmount = event.pull()
--- ```
--- - `signalName: "ItemAmountUpdated"`
--- - `component: DimensionalDepot`
--- - `ItemType: Satis.ItemType` <br>
--- The type of the item that got uploaded.
--- - `ItemAmount: number` <br>
--- The new amount of items of the given type.
---@deprecated
---@type FIN.Signal
DimensionalDepot.SIGNAL_ItemAmountUpdated = nil

--- Gets triggered when an item type reached maximum capacity, or when it now has again available space for new items.<br>
--- 
--- ### returns from event.pull:<br>
--- ```
--- local signalName, component, ItemType, Reached = event.pull()
--- ```
--- - `signalName: "ItemLimitReachedUpdated"`
--- - `component: DimensionalDepot`
--- - `ItemType: Satis.ItemType` <br>
--- The type of the item which changed if it has reached the limit or not.
--- - `Reached: boolean` <br>
--- True if the given item type has reached the limit or not.
---@deprecated
---@type FIN.Signal
DimensionalDepot.SIGNAL_ItemLimitReachedUpdated = nil

--- The type of an item (iron plate, iron rod, leaves)
---@class Satis.ItemType : Engine.Object
local ItemType

---@class FIN.classes.Satis.ItemType : Satis.ItemType
classes.ItemType = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
ItemType.form = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
ItemType.energy = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
ItemType.radioactiveDecay = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
ItemType.name = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
ItemType.description = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
ItemType.max = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
ItemType.canBeDiscarded = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Satis.ItemCategory
ItemType.category = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Engine.Color
ItemType.fluidColor = nil

--- 
---@class FIN.FINMediaSubsystem : Engine.Actor
local FINMediaSubsystem

---@class FIN.classes.FIN.FINMediaSubsystem : FIN.FINMediaSubsystem
classes.FINMediaSubsystem = nil

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param TextureReference string 
function FINMediaSubsystem:loadTexture(TextureReference) end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param TextureReference string 
---@return boolean ReturnValue 
function FINMediaSubsystem:isTextureLoading(TextureReference) end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param TextureReference string 
---@return boolean ReturnValue 
function FINMediaSubsystem:isTextureLoaded(TextureReference) end

--- 
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param PageSize number 
---@param Page number 
---@return Satis.IconData[] ReturnValue 
function FINMediaSubsystem:getGameIcons(PageSize, Page) end

--- Tries to find an game icon like the ones you use for signs.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param IconName string 
---@return Satis.IconData ReturnValue 
function FINMediaSubsystem:findGameIcon(IconName) end

--- The category of some items.
---@class Satis.ItemCategory : Engine.Object
local ItemCategory

---@class FIN.classes.Satis.ItemCategory : Satis.ItemCategory
classes.ItemCategory = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
ItemCategory.name = nil

--- A struct that holds information about a recipe in its class. Means don't use it as object, use it as class type!
---@class Satis.Recipe : Engine.Object
local Recipe

---@class FIN.classes.Satis.Recipe : Satis.Recipe
classes.Recipe = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
Recipe.name = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Recipe.duration = nil

--- Describes the type of a sign.
---@class Satis.SignType : Engine.Object
local SignType

---@class FIN.classes.Satis.SignType : Satis.SignType
classes.SignType = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type Engine.Vector2D
SignType.dimensions = nil

--- The base class for all things of the reflection system.
---@class FIN.ReflectionBase : Engine.Object
local ReflectionBase

---@class FIN.classes.FIN.ReflectionBase : FIN.ReflectionBase
classes.ReflectionBase = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
ReflectionBase.name = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
ReflectionBase.displayName = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
ReflectionBase.description = nil

--- A Reflection object that holds information about properties and parameters.
---@class FIN.Property : FIN.ReflectionBase
local Property

---@class FIN.classes.FIN.Property : FIN.Property
classes.Property = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Property.dataType = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Property.flags = nil

--- A reflection object representing a array property.
---@class FIN.ArrayProperty : FIN.Property
local ArrayProperty

---@class FIN.classes.FIN.ArrayProperty : FIN.ArrayProperty
classes.ArrayProperty = nil

--- Returns the inner type of this array.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Property inner The inner type of this array.
function ArrayProperty:getInner() end

--- A reflection object representing a class property.
---@class FIN.ClassProperty : FIN.Property
local ClassProperty

---@class FIN.classes.FIN.ClassProperty : FIN.ClassProperty
classes.ClassProperty = nil

--- Returns the subclass type of this class. Meaning, the stored classes need to be of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Class subclass The subclass of this class property.
function ClassProperty:getSubclass() end

--- A reflection object representing a object property.
---@class FIN.ObjectProperty : FIN.Property
local ObjectProperty

---@class FIN.classes.FIN.ObjectProperty : FIN.ObjectProperty
classes.ObjectProperty = nil

--- Returns the subclass type of this object. Meaning, the stored objects need to be of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Class subclass The subclass of this object.
function ObjectProperty:getSubclass() end

--- A reflection object representing a struct property.
---@class FIN.StructProperty : FIN.Property
local StructProperty

---@class FIN.classes.FIN.StructProperty : FIN.StructProperty
classes.StructProperty = nil

--- Returns the subclass type of this struct. Meaning, the stored structs need to be of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Struct subclass The subclass of this struct.
function StructProperty:getSubclass() end

--- A reflection object representing a trace property.
---@class FIN.TraceProperty : FIN.Property
local TraceProperty

---@class FIN.classes.FIN.TraceProperty : FIN.TraceProperty
classes.TraceProperty = nil

--- Returns the subclass type of this trace. Meaning, the stored traces need to be of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Class subclass The subclass of this trace.
function TraceProperty:getSubclass() end

--- Reflection Object that holds information about structures.
---@class FIN.Struct : FIN.ReflectionBase
local Struct

---@class FIN.classes.FIN.Struct : FIN.Struct
classes.Struct = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
Struct.isConstructable = nil

--- Returns the parent type of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
---@return FIN.Class parent The parent type of this type.
function Struct:getParent() end

--- Returns all the properties of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Property[] properties The properties this specific type implements (excluding properties from parent types).
function Struct:getProperties() end

--- Returns all the properties of this and parent types.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Property[] properties The properties this type implements including properties from parent types.
function Struct:getAllProperties() end

--- Returns all the functions of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Function[] functions The functions this specific type implements (excluding properties from parent types).
function Struct:getFunctions() end

--- Returns all the functions of this and parent types.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Property[] functions The functions this type implements including functions from parent types.
function Struct:getAllFunctions() end

--- Allows to check if this struct is a child struct of the given struct or the given struct it self.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param parent FIN.Struct The parent struct you want to check if this struct is a child of.
---@return boolean isChild True if this struct is a child of parent.
function Struct:isChildOf(parent) end

--- Object that contains all information about a type.
---@class FIN.Class : FIN.Struct
local Class

---@class FIN.classes.FIN.Class : FIN.Class
classes.Class = nil

--- Returns all the signals of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Signal[] signals The signals this specific type implements (excluding properties from parent types).
function Class:getSignals() end

--- Returns all the signals of this and its parent types.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Signal[] signals The signals this type and all it parents implement.
function Class:getAllSignals() end

--- A reflection object representing a function.
---@class FIN.Function : FIN.ReflectionBase
local Function

---@class FIN.classes.FIN.Function : FIN.Function
classes.Function = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
Function.flags = nil

--- Returns all the parameters of this function.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Property[] parameters The parameters this function.
function Function:getParameters() end

--- A reflection object representing a signal.
---@class FIN.Signal : FIN.ReflectionBase
local Signal

---@class FIN.classes.FIN.Signal : FIN.Signal
classes.Signal = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
Signal.isVarArgs = nil

--- Returns all the parameters of this signal.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.Property[] parameters The parameters this signal.
function Signal:getParameters() end

--- 
---@class Satis.FGBuildableDecor : Satis.Buildable
local FGBuildableDecor

---@class FIN.classes.Satis.FGBuildableDecor : Satis.FGBuildableDecor
classes.FGBuildableDecor = nil

--- 
---@class Satis.FGBuildableSpeedSign : Satis.Buildable
local FGBuildableSpeedSign

---@class FIN.classes.Satis.FGBuildableSpeedSign : Satis.FGBuildableSpeedSign
classes.FGBuildableSpeedSign = nil

--- 
---@class Satis.FGBuildableWindTurbine : Satis.Factory
local FGBuildableWindTurbine

---@class FIN.classes.Satis.FGBuildableWindTurbine : Satis.FGBuildableWindTurbine
classes.FGBuildableWindTurbine = nil

--- Contains three cordinates (X, Y, Z) to describe a position or movement vector in 3D Space
---@class Engine.Vector
---@operator add(Engine.Vector) : Engine.Vector
---@operator sub(Engine.Vector) : Engine.Vector
---@operator unm : Engine.Vector
---@operator mul(Engine.Vector) : Engine.Vector
---@operator mul(number) : Engine.Vector
local Vector

---@class FIN.structs.Engine.Vector : Engine.Vector
---@overload fun(data: { [1]: number, [2]: number, [3]: number } ) : Engine.Vector
structs.Vector = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Vector.x = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Vector.y = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Vector.z = nil

--- Contains two cordinates (X, Y) to describe a position or movement vector in 2D Space
---@class Engine.Vector2D
---@operator add(Engine.Vector2D) : Engine.Vector2D
---@operator sub(Engine.Vector2D) : Engine.Vector2D
---@operator unm : Engine.Vector2D
---@operator mul(Engine.Vector2D) : number
---@operator mul(number) : Engine.Vector2D
local Vector2D

---@class FIN.structs.Engine.Vector2D : Engine.Vector2D
---@overload fun(data: { [1]: number, [2]: number } ) : Engine.Vector2D
structs.Vector2D = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Vector2D.x = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Vector2D.y = nil

--- A structure that holds a rgba color value
---@class Engine.Color
---@operator add(Engine.Color) : Engine.Color
---@operator unm : Engine.Color
---@operator sub(Engine.Color) : Engine.Color
---@operator mul(number) : Engine.Vector
---@operator div(number) : Engine.Vector
local Color

---@class FIN.structs.Engine.Color : Engine.Color
---@overload fun(data: { [1]: number, [2]: number, [3]: number, [4]: number } ) : Engine.Color
structs.Color = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Color.r = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Color.g = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Color.b = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Color.a = nil

--- Contains rotation information about a object in 3D spaces using 3 rotation axis in a gimble.
---@class Engine.Rotator
---@operator add(Engine.Rotator) : Engine.Rotator
---@operator sub(Engine.Rotator) : Engine.Rotator
local Rotator

---@class FIN.structs.Engine.Rotator : Engine.Rotator
---@overload fun(data: { [1]: number, [2]: number, [3]: number } ) : Engine.Rotator
structs.Rotator = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Rotator.pitch = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Rotator.yaw = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Rotator.roll = nil

--- A Vector containing four values.
---@class Engine.Vector4
local Vector4

---@class FIN.structs.Engine.Vector4 : Engine.Vector4
---@overload fun(data: { [1]: number, [2]: number, [3]: number, [4]: number } ) : Engine.Vector4
structs.Vector4 = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Vector4.x = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Vector4.y = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Vector4.z = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Vector4.w = nil

--- A struct containing four floats that describe a margin around a box (like a 9-patch).
---@class SlateCore.Margin
local Margin

---@class FIN.structs.SlateCore.Margin : SlateCore.Margin
---@overload fun(data: { [1]: number, [2]: number, [3]: number, [4]: number } ) : SlateCore.Margin
structs.Margin = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Margin.left = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Margin.right = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Margin.top = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
Margin.bottom = nil

--- A structure that holds item information.
---@class Satis.Item
local Item

---@class FIN.structs.Satis.Item : Satis.Item
---@overload fun(data: { [1]: Satis.ItemType } ) : Satis.Item
structs.Item = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Satis.ItemType
Item.type = nil

--- A structure that holds item information and item amount to represent an item stack.
---@class Satis.ItemStack
local ItemStack

---@class FIN.structs.Satis.ItemStack : Satis.ItemStack
---@overload fun(data: { [1]: number, [2]: Satis.Item } ) : Satis.ItemStack
structs.ItemStack = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
ItemStack.count = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Satis.Item
ItemStack.item = nil

--- A struct that holds a pair of amount and item type.
---@class Satis.ItemAmount
local ItemAmount

---@class FIN.structs.Satis.ItemAmount : Satis.ItemAmount
---@overload fun(data: { [1]: number, [2]: Satis.ItemType } ) : Satis.ItemAmount
structs.ItemAmount = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
ItemAmount.amount = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Satis.ItemType
ItemAmount.type = nil

--- A struct containing information about a game icon (used in f.e. signs).
---@class Satis.IconData
local IconData

---@class FIN.structs.Satis.IconData : Satis.IconData
structs.IconData = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
IconData.isValid = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
IconData.id = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
IconData.ref = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
IconData.animated = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
IconData.iconName = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
IconData.iconType = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
IconData.hidden = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
IconData.searchOnly = nil

--- Contains infromation about the rules that descibe when a trian should depart from a station
---@class Satis.TrainDockingRuleSet
local TrainDockingRuleSet

---@class FIN.structs.Satis.TrainDockingRuleSet : Satis.TrainDockingRuleSet
---@overload fun(data: { [1]: number, [2]: number, [3]: boolean } ) : Satis.TrainDockingRuleSet
structs.TrainDockingRuleSet = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
TrainDockingRuleSet.definition = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
TrainDockingRuleSet.duration = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
TrainDockingRuleSet.isDurationAndRule = nil

--- Returns the types of items that will be loaded.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.ItemType[] filters The item filter array
function TrainDockingRuleSet:getLoadFilters() end

--- Sets the types of items that will be loaded.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param filters Satis.ItemType[] The item filter array
function TrainDockingRuleSet:setLoadFilters(filters) end

--- Returns the types of items that will be unloaded.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.ItemType[] filters The item filter array
function TrainDockingRuleSet:getUnloadFilters() end

--- Sets the types of items that will be loaded.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param filters Satis.ItemType[] The item filter array
function TrainDockingRuleSet:setUnloadFilters(filters) end

--- This structure stores all data that defines what a sign displays.
---@class Satis.PrefabSignData
local PrefabSignData

---@class FIN.structs.Satis.PrefabSignData : Satis.PrefabSignData
---@overload fun(data: { [1]: Engine.Object, [2]: Engine.Color, [3]: Engine.Color, [4]: number, [5]: Engine.Color, [6]: Satis.SignType } ) : Satis.PrefabSignData
structs.PrefabSignData = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Engine.Object
PrefabSignData.layout = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Engine.Color
PrefabSignData.foreground = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Engine.Color
PrefabSignData.background = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
PrefabSignData.emissive = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Engine.Color
PrefabSignData.auxiliary = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Satis.SignType
PrefabSignData.signType = nil

--- Returns all text elements and their values.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return string[] textElements The element names for all text elements.
---@return string[] textElementValues The values for all text elements.
function PrefabSignData:getTextElements() end

--- Returns all icon elements and their values.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return string[] iconElements The element names for all icon elements.
---@return number[] iconElementValues The values for all icon elements.
function PrefabSignData:getIconElements() end

--- Sets all text elements and their values.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param textElements string[] The element names for all text elements.
---@param textElementValues string[] The values for all text elements.
function PrefabSignData:setTextElements(textElements, textElementValues) end

--- Sets all icon elements and their values.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param iconElements string[] The element names for all icon elements.
---@param iconElementValues number[] The values for all icon elements.
function PrefabSignData:setIconElements(iconElements, iconElementValues) end

--- Sets a text element with the given element name.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param elementName string The name of the text element
---@param value string The value of the text element
function PrefabSignData:setTextElement(elementName, value) end

--- Sets a icon element with the given element name.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param elementName string The name of the icon element
---@param value number The value of the icon element
function PrefabSignData:setIconElement(elementName, value) end

--- Gets a text element with the given element name.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param elementName string The name of the text element
---@return number value The value of the text element
function PrefabSignData:getTextElement(elementName) end

--- Gets a icon element with the given element name.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param elementName string The name of the icon element
---@return number value The value of the icon element
function PrefabSignData:getIconElement(elementName) end

--- An entry in the Computer Log.
---@class FicsItLogLibrary.LogEntry
local LogEntry

---@class FIN.structs.FicsItLogLibrary.LogEntry : FicsItLogLibrary.LogEntry
structs.LogEntry = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
LogEntry.content = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type string
LogEntry.timestamp = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
LogEntry.verbosity = nil

--- Creates a formatted string representation of this log entry.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return string result The resulting formatted string
function LogEntry:format() end

--- A track section that combines the area between multiple signals.
---@class FIN.RailroadSignalBlock
local RailroadSignalBlock

---@class FIN.structs.FIN.RailroadSignalBlock : FIN.RailroadSignalBlock
structs.RailroadSignalBlock = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
RailroadSignalBlock.isValid = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type boolean
RailroadSignalBlock.isBlockOccupied = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
RailroadSignalBlock.isPathBlock = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Read Only - The value of this property can not be changed by code.
---@type number
RailroadSignalBlock.blockValidation = nil

--- Allows you to check if this block is occupied by a given train.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param train Satis.Train The train you want to check if it occupies this block
---@return boolean isOccupied True if the given train occupies this block.
function RailroadSignalBlock:isOccupiedBy(train) end

--- Returns a list of trains that currently occupate the block.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Train[] occupation A list of trains occupying the block.
function RailroadSignalBlock:getOccupation() end

--- Returns a list of trains that try to reserve this block and wait for approval.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Train[] reservations A list of trains that try to reserve this block and wait for approval.
function RailroadSignalBlock:getQueuedReservations() end

--- Returns a list of trains that are approved by this block.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Train[] reservations A list of trains that are approved by this block.
function RailroadSignalBlock:getApprovedReservations() end

--- Target Point in the waypoint list of a wheeled vehicle.
---@class FIN.TargetPoint
local TargetPoint

---@class FIN.structs.FIN.TargetPoint : FIN.TargetPoint
---@overload fun(data: { [1]: Engine.Vector, [2]: Engine.Rotator, [3]: number, [4]: number } ) : FIN.TargetPoint
structs.TargetPoint = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Engine.Vector
TargetPoint.pos = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Engine.Rotator
TargetPoint.rot = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
TargetPoint.speed = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
TargetPoint.wait = nil

--- Information about a train stop in a time table.
---@class FIN.TimeTableStop
local TimeTableStop

---@class FIN.structs.FIN.TimeTableStop : FIN.TimeTableStop
---@overload fun(data: { [1]: Satis.RailroadStation } ) : FIN.TimeTableStop
structs.TimeTableStop = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Satis.RailroadStation
TimeTableStop.station = nil

--- Returns The rule set wich describe when the train will depart from the train station.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.TrainDockingRuleSet ruleset The rule set of this time table stop.
function TimeTableStop:getRuleSet() end

--- Allows you to change the Rule Set of this time table stop.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param ruleset Satis.TrainDockingRuleSet The rule set you want to use instead.
function TimeTableStop:setRuleSet(ruleset) end

--- Struct that holds a cache of a whole train/rail network.
---@class FIN.TrackGraph
local TrackGraph

---@class FIN.structs.FIN.TrackGraph : FIN.TrackGraph
structs.TrackGraph = nil

--- Returns a list of all trains in the network.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.Train[] trains The list of trains in the network.
function TrackGraph:getTrains() end

--- Returns a list of all trainstations in the network.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satis.RailroadStation[] stations The list of trainstations in the network.
function TrackGraph:getStations() end

--- A Future struct MAY BE HANDLED BY CPU IMPLEMENTATION differently, generaly, this is used to make resources available on a later point in time. Like if data won't be avaialble right away and you have to wait for it to process first. Like when you do a HTTP Request, then it takes some time to get the data from the web server. And since we don't want to halt the game and wait for the data, you can use a future to check if the data is available, or let just the Lua Code wait, till the data becomes available.
---@class FIN.Future
local Future

---@class FIN.structs.FIN.Future : FIN.Future
structs.Future = nil

--- A structure that can hold a buffer of characters and colors that can be displayed with a gpu
---@class FIN.GPUT1Buffer
local GPUT1Buffer

---@class FIN.structs.FIN.GPUT1Buffer : FIN.GPUT1Buffer
---@overload fun(data: { } ) : FIN.GPUT1Buffer
structs.GPUT1Buffer = nil

--- Allows to get the dimensions of the buffer.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@return number width The width of this buffer
---@return number height The height of this buffer
function GPUT1Buffer:getSize() end

--- Allows to set the dimensions of the buffer.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param width number The width this buffer should now have
---@param height number The height this buffer now have
function GPUT1Buffer:setSize(width, height) end

--- Allows to get a single pixel from the buffer at the given position
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param x number The x position of the character you want to get
---@param y number The y position of the character you want to get
---@return string c The character at the given position
---@return Engine.Color foreground The foreground color of the pixel at the given position
---@return Engine.Color background The background color of the pixel at the given position
function GPUT1Buffer:get(x, y) end

--- Allows to set a single pixel of the buffer at the given position
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param x number The x position of the character you want to set
---@param y number The y position of the character you want to set
---@param c string The character the pixel should have
---@param foreground Engine.Color The foreground color the pixel at the given position should have
---@param background Engine.Color The background color the pixel at the given position should have
---@return boolean done True if the pixel got set successfully
function GPUT1Buffer:set(x, y, c, foreground, background) end

--- Copies the given buffer at the given offset of the upper left corner into this buffer.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param x number The x offset of the upper left corner of the buffer relative to this buffer
---@param y number The y offset of the upper left corener of the buffer relative to this buffer
---@param buffer FIN.GPUT1Buffer The buffer from wich you want to copy from
---@param textBlendMode number The blend mode that is used for the text. 0 = Overwrite this with the content of the given buffer 1 = Overwrite with only characters that are not ' ' 2 = Overwrite only were this characters are ' ' 3 = Keep this buffer
---@param foregroundBlendMode number The blend mode that is used for the foreground color. 0 = Overwrite with the given color 1 = Normal alpha composition 2 = Multiply 3 = Divide 4 = Addition 5 = Subtraction 6 = Difference 7 = Darken Only 8 = Lighten Only 9 = None
---@param backgroundBlendMode number The blend mode that is used for the background color. 0 = Overwrite with the given color 1 = Normal alpha composition 2 = Multiply 3 = Divide 4 = Addition 5 = Subtraction 6 = Difference 7 = Darken Only 8 = Lighten Only 9 = None
function GPUT1Buffer:copy(x, y, buffer, textBlendMode, foregroundBlendMode, backgroundBlendMode) end

--- Allows to write the given text onto the buffer and with the given offset.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param x number The X Position at which the text should begin to get written.
---@param y number The Y Position at which the text should begin to get written.
---@param text string The text that should get written.
---@param foreground Engine.Color The foreground color which will be used to write the text.
---@param background Engine.Color The background color which will be used to write the text.
function GPUT1Buffer:setText(x, y, text, foreground, background) end

--- Draws the given character at all given positions in the given rectangle on-to the hidden screen buffer.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param x number The x coordinate at which the rectangle should get drawn. (upper-left corner)
---@param y number The y coordinate at which the rectangle should get drawn. (upper-left corner)
---@param width number The width of the rectangle.
---@param height number The height of the rectangle.
---@param character string A string with a single character that will be used for each pixel in the range you want to fill.
---@param foreground Engine.Color The foreground color which will be used to fill the rectangle.
---@param background Engine.Color The background color which will be used to fill the rectangle.
function GPUT1Buffer:fill(x, y, width, height, character, foreground, background) end

--- Allows to set the internal data of the buffer more directly.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
--- * Runtime Asynchronous - Can be changed anytime.
---@param characters string The characters you want to draw with a length of exactly width*height.
---@param foreground number[] The values of the foreground color slots for each character were a group of four values give one color. so the length has to be exactly width*height*4.
---@param background number[] The values of the background color slots for each character were a group of four values give one color. so the length has to be exactly width*height*4.
---@return boolean success True if the raw data was successfully written
function GPUT1Buffer:setRaw(characters, foreground, background) end

--- Clones this buffer into a new struct
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FIN.GPUT1Buffer buffer The clone of this buffer
function GPUT1Buffer:clone() end

--- This struct contains the necessary information to draw a box onto the GPU T2.
---@class FIN.GPUT2DrawCallBox
local GPUT2DrawCallBox

---@class FIN.structs.FIN.GPUT2DrawCallBox : FIN.GPUT2DrawCallBox
---@overload fun(data: { [1]: Engine.Vector2D, [2]: Engine.Vector2D, [3]: number, [4]: Engine.Color, [5]: string, [6]: Engine.Vector2D, [7]: boolean, [8]: boolean, [9]: boolean, [10]: boolean, [11]: SlateCore.Margin, [12]: boolean, [13]: Engine.Vector4, [14]: boolean, [15]: number, [16]: Engine.Color } ) : FIN.GPUT2DrawCallBox
structs.GPUT2DrawCallBox = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Engine.Vector2D
GPUT2DrawCallBox.position = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Engine.Vector2D
GPUT2DrawCallBox.size = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
GPUT2DrawCallBox.rotation = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Engine.Color
GPUT2DrawCallBox.color = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type string
GPUT2DrawCallBox.image = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Engine.Vector2D
GPUT2DrawCallBox.imageSize = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
GPUT2DrawCallBox.hasCenteredOrigin = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
GPUT2DrawCallBox.horizontalTiling = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
GPUT2DrawCallBox.verticalTiling = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
GPUT2DrawCallBox.isBorder = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type SlateCore.Margin
GPUT2DrawCallBox.margin = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
GPUT2DrawCallBox.isRounded = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Engine.Vector4
GPUT2DrawCallBox.radii = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type boolean
GPUT2DrawCallBox.hasOutline = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type number
GPUT2DrawCallBox.outlineThickness = nil

--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@type Engine.Color
GPUT2DrawCallBox.outlineColor = nil

--- This struct contains filter settings so you can evaluate if a sent signal matches the filter or not.
---@class FIN.EventFilter
---@operator mul(FIN.EventFilter) : FIN.EventFilter
---@operator band(FIN.EventFilter) : FIN.EventFilter
---@operator add(FIN.EventFilter) : FIN.EventFilter
---@operator bor(FIN.EventFilter) : FIN.EventFilter
---@operator unm : FIN.EventFilter
---@operator bnot : FIN.EventFilter
local EventFilter

---@class FIN.structs.FIN.EventFilter : FIN.EventFilter
structs.EventFilter = nil

--- Returns true if the given signal data matches this event filter.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@param name string The (internal) name of the signal.
---@param sender Engine.Object The sender of the signal
---@param ... any @additional arguments as described
---@return boolean matches True if the given signal matches the filter
function EventFilter:matches(name, sender, ...) end

end
