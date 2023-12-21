print(collectgarbage("count"))

local _, logger = require("Tests.Simulator.Simulator"):Initialize(1)

print(collectgarbage("count"))

local Event = require("Core.Event")

local EventTest = Event()

---@class EmptyClass
---@overload fun() : EmptyClass
local EmptyClass = {}

function EmptyClass:__init()
    self.index = EventTest:AddListener(print, self)
end

---@private
function EmptyClass:__gc()
    EventTest:Remove(self.index)
end

Utils.Class.CreateClass(EmptyClass, "EmptyClass")

local instance = EmptyClass()

EventTest:Trigger(logger, "Test")

Utils.Class.Deconstruct(instance)

print(collectgarbage("count"))
collectgarbage()
print(collectgarbage("count"))

print("### END ###")
