local luaunit = require('Test.Luaunit')
require('Test.Simulator.Simulator')

function TestCreateClass()
	local test = Utils.Class.CreateClass({}, 'CreateEmpty')

	luaunit.assertNotIsNil(test)
end

function TestCreateClassWithBaseClass()
	local testBaseClass = Utils.Class.CreateClass({}, 'EmptyBaseClass')
	local test = Utils.Class.CreateClass({}, 'CreateEmptyWithBaseClass', testBaseClass)

	luaunit.assertNotIsNil(test)
end

function TestConstructClass()
	local test = Utils.Class.CreateClass({}, 'CreateEmpty')

	luaunit.assertNotIsNil(test())
end

function TestDeconstructClass()
	local testClass = Utils.Class.CreateClass({}, 'CreateEmpty')
	local test = testClass()
	local function throwErrorBecauseOfDeconstructedClass()
		_ = test.hi
	end

	Utils.Class.Deconstruct(test)

	luaunit.assertErrorMsgContains("cannot get values from deconstruct class: CreateEmpty",
		throwErrorBecauseOfDeconstructedClass)
end

os.exit(luaunit.LuaUnit.run())
