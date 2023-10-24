require('Test.Simulator.Simulator')

local Uri = require("Net.Rest.Uri")
local JsonSerializer = require("Core.Json.JsonSerializer")

local test = Uri("/Address")

print(JsonSerializer.Static__Serializer:Serialize(test))
