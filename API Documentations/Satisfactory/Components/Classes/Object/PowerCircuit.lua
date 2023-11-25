---@meta

--- A Object that represents a whole power circuit.
---@class Satisfactory.Components.PowerCircuit : Satisfactory.Components.Object
local PowerCircuit = {}

--- The amount of power produced by the whole circuit in the last tick.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerCircuit.production = nil

--- The power consumption of the whole circuit in the last tick.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerCircuit.consumption = nil

--- The power capacity of the whole network in the last tick. (The max amount of power available in the last tick)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerCircuit.capacity = nil

--- The power that gone into batteries in the last tick.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerCircuit.batteryInput = nil

--- The maximum consumption of power in the last tick.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerCircuit.maxPowerConsumption = nil

--- True if the fuse in the network triggered.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type boolean
PowerCircuit.isFuesed = nil

--- True if the power circuit has batteries connected to it.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type boolean
PowerCircuit.hasBatteries = nil

--- The energy capacity all batteries of the network combined provide.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerCircuit.batteryCapacity = nil

--- The amount of energy currently stored in all batteries of the network combined.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerCircuit.batteryStore = nil

--- The fill status in percent of all batteries of the network combined.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerCircuit.batteryStorePercent = nil

--- The time in seconds until every battery in the network is filled.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerCircuit.batteryTimeUntilFull = nil

--- The time in seconds until every battery im the network is empty.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerCircuit.batteryTimeUntilEmpty = nil

--- The amount of energy that currently gets stored in every battery of the whole network.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerCircuit.batteryIn = nil

--- The amount of energy that currently discharges from every battery in the whole network.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerCircuit.batteryOut = nil

--- Gets Triggerd when the fuse state of the power circuit changes.
---
--- ### returns from event.pull:
--- ```
--- local signalName, component = event.pull()
--- ```
--- - `signalName: string` <br> -> "PowerFuseChanged"
--- - `component: FIN.Components.PowerCircuit` <br> -> The component wich send the signal.
---@deprecated
---@type FIN.Components.Signal
PowerCircuit.PowerFuseChanged = { isVarArgs = true }
