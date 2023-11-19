local luaunit = require('Tests.Luaunit')
require('Tests.Simulator.Simulator'):Initialize(1)

local UUID = require("Core.Common.UUID")
local JsonSerializer = require("Core.Json.JsonSerializer")

function TestOverall()
    local serializer = JsonSerializer()
    serializer:AddTypesFromStatic()
    local test = UUID.Static__Empty()

    local json = serializer:Serialize({ Id = test })
    local testObj = serializer:Deserialize(json)

    luaunit.assertEquals(tostring(testObj.Id), "000000-0000-000000")
end

os.exit(luaunit.LuaUnit.run())
