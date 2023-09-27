---@meta

--- The base class of most machines you can build.
---@class FicsIt_Networks.Components.Factory : FicsIt_Networks.Components.FGBuildable
---@field progress float The current production progress of the current production cycle.
---@field powerConsumProducing float The power consumption when producing.
---@field productivity float The productivity of this factory.
---@field cycleTime float The time that passes till one production cycle is finished.
---@field maxPotential float The maximum potential this factory can be set to.
---@field minPotential float The minimum potential this factory needs to be set to.
---@field standby boolean True if the factory is in standby.
---@field potential float The potential this factory is currently set to. (the overclock value) 0 = 0%, 1 = 100%
local Factory = {}
