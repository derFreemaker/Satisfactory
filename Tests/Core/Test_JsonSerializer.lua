local luaunit = require('Tools.Testing.Luaunit')
require('Tools.Testing.Simulator.init'):Initialize(1)

local UUID = require("Core.Common.UUID")
local JsonSerializer = require("Core.Json.JsonSerializer")

function TestOverall()
    local serializer = JsonSerializer()
    serializer:AddTypesFromStatic()

    local json = serializer:Serialize({ Id = UUID.Static__Empty })
    local testObj = serializer:Deserialize(json)

    luaunit.assertEquals(tostring(testObj.Id), "000000-0000-00000000")
end

os.exit(luaunit.LuaUnit.run())
