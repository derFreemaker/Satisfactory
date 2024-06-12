local luaunit = require("Tools.Testing.Luaunit")
require("Tools.Testing.Simulator.init"):Initialize(1)

local UUID = require("Core.Common.UUID")

function TestNewUUID()
	local test = UUID.Static__New()

	luaunit.assertNotIsNil(test)
end

function TestEmptyUUID()
	local test = UUID.Static__Empty

	luaunit.assertEquals(tostring(test), "0000-0000-00000000")
end

function TestParseUUID()
	local uuidStr = "000000-0000-00000000"

	local test = UUID.Static__Parse(uuidStr)
	local testStr = tostring(test)

	luaunit.assertEquals(testStr, uuidStr)
end

function TestRadomnessUUID()
	local uuids = {}
	for i = 1, 50000, 1 do
		local uuid = UUID.Static__New()
		local uuidStr = uuid:ToString()
		if uuids[uuidStr] then
			luaunit.fail("already generated uuid: " .. uuid:ToString())
		end
		uuids[uuidStr] = true
	end
end

os.exit(luaunit.LuaUnit.run())
