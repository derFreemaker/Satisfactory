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

function TestExtendClass()
	local test = Utils.Class.CreateClass({}, 'CreateEmpty')
	local testClassInstance = test()

	local extended = Utils.Class.ExtendClass({ Test = "hi" }, test)
	local extendedtestClassInstance = test()
	local extendedClassInstance = extended()

	luaunit.assertEquals(testClassInstance.Test, "hi")
	luaunit.assertEquals(extendedtestClassInstance.Test, "hi")
	luaunit.assertEquals(extendedClassInstance.Test, "hi")
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
