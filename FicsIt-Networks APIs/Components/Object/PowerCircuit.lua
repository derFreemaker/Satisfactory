---@diagnostic disable


--- A Object that represents a whole power circuit.
---@class FicsIt_Networks.Components.PowerCircuit : FicsIt_Networks.Components.Object
---@field production float The amount of power produced by the whole circuit in the last tick.
---@field consumption float The power consumption of the whole circuit in the last tick.
---@field capacity float The power capacity of the whole network in the last tick. (The max amount of power available in the last tick)
---@field batteryInput float The power that gone into batteries in the last tick.
---@field maxPowerConsumption float The maximum consumption of power in the last tick.
---@field isFuesed boolen True if the fuse in the network triggered.
---@field hasBatteries boolean True if the power circuit has batteries connected to it.
---@field batteryCapacity float The energy capacity all batteries of the network combined provide.
---@field batteryStore float The amount of energy currently stored in all batteries of the network combined.
---@field batteryStorePercent float The fill status in percent of all batteries of the network combined.
---@field batteryTimeUntilFull float The time in seconds until every battery in the network is filled.
---@field batteryTimeUntilEmpty float The time in seconds until every battery im the network is empty.
---@field batteryIn float The amount of energy that currently gets stored in every battery of the whole network.
---@field batteryOut float The amount of energy that currently discharges from every battery in the whole network.
local PowerCircuit = {}


--- Gets Triggerd when the fuse state of the power circuit changes.
---@type FicsIt_Networks.Components.Signal
PowerCircuit.PowerFuseChanged = {}
