local luaunit = require('Tools.Testing.Luaunit')
require('Tools.Testing.Simulator'):Initialize(1)

local UUID = require('Core.Common.UUID')

function TestNewUUID()
	local test = UUID.Static__New()

	luaunit.assertNotIsNil(test)
end

function TestEmptyUUID()
	local test = UUID.Static__Empty

	luaunit.assertEquals(tostring(test), "000000-0000-00000000")
end

function TestParseUUID()
	local uuidStr = "000000-0000-00000000"

	local test = UUID.Static__Parse(uuidStr)
	local testStr = tostring(test)

	luaunit.assertEquals(testStr, uuidStr)
end

os.exit(luaunit.LuaUnit.run())
