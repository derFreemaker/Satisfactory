local luaunit = require('Tests.Luaunit')
require('Tests.Simulator.Simulator'):Initialize(1)

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

	local testBaseClass = Utils.Class.CreateClass({}, "CreateEmptyWithBaseClass", test)
	local testBaseClassInstance = testBaseClass()

	local extended = Utils.Class.ExtendClass({ Test = "hi" }, test)

	local extendedTestClassInstance = test()
	local extendedTestBaseClass = testBaseClass()
	local extendedClassInstance = extended()

	luaunit.assertEquals(testClassInstance.Test, "hi")
	luaunit.assertEquals(testBaseClassInstance.Test, "hi")
	luaunit.assertEquals(extendedTestClassInstance.Test, "hi")
	luaunit.assertEquals(extendedTestBaseClass.Test, "hi")
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
