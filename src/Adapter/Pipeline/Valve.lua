---@class Adapter.Pipeline.Valve : object
---@field valve FicsIt_Networks.Components.Factory.Build_Valve_C
local Valve = {}

---@private
---@param id FicsIt_Networks.UUID | FicsIt_Networks.Components.Factory.Build_Valve_C
function Valve:__init(id)
	if type(id) == 'string' then
		self.valve = component.proxy(id) --[[@as FicsIt_Networks.Components.Factory.Build_Valve_C]]
		return
	end
	---@cast id FicsIt_Networks.Components.Factory.Build_Valve_C
	self.valve = id
end

function Valve:Block()
	self.valve.userFlowLimit = 0
end

function Valve:Free()
	self.valve.userFlowLimit = 600
end

-- //TODO: check fields and add all flags to all components

return Utils.Class.CreateClass(Valve, 'Adapter.Pipeline.Valve')
