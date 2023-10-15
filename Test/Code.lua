require('Test.Simulator.Simulator')

local UUID = require("Core.UUID")
local JsonSerializer = require("Core.Json.JsonSerializer")

local serializer = JsonSerializer()
serializer:AddDefaultTypeInfos()

local test = UUID.Static__Empty()
print(test)

local json = serializer:Serialize({ Id = test })
print(json)

local testObj = serializer:Deserialize(json)
print(testObj.Id)
