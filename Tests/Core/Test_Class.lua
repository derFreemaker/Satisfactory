local luaunit = require('tools.Testing.Luaunit')
require('tools.Testing.Simulator'):Initialize(1)

function TestCreateClass()
	local test = Utils.Class.Create({}, 'CreateEmpty')

	luaunit.assertNotIsNil(test)
end

function TestCreateClassWithBaseClass()
	local testBaseClass = Utils.Class.Create({}, 'EmptyBaseClass')
	local test = Utils.Class.Create({}, 'CreateEmptyWithBaseClass', testBaseClass)

	luaunit.assertNotIsNil(test)
end

function TestConstructClass()
	local test = Utils.Class.Create({}, 'CreateEmpty')

	luaunit.assertNotIsNil(test())
end

function TestExtendClass()
	local test = Utils.Class.Create({}, 'CreateEmpty')
	local testClassInstance = test()

	local testBaseClass = Utils.Class.Create({}, "CreateEmptyWithBaseClass", test)
	local testBaseClassInstance = testBaseClass()

	local extended = Utils.Class.Extend(test, { Test = "hi" })

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
	local testClass = Utils.Class.Create({}, 'CreateEmpty')
	local test = testClass()
	local function throwErrorBecauseOfDeconstructedClass()
		_ = test.hi
	end

	Utils.Class.Deconstruct(test)

	luaunit.assertErrorMsgContains("cannot get values from deconstruct class: CreateEmpty",
		throwErrorBecauseOfDeconstructedClass)
end

function TestStaticAccess()
	local testClass = Utils.Class.Create({ Static__Test = "hi" }, "StaticTestClass")
	local testClassInstance = testClass()

	luaunit.assertEquals(testClassInstance.Static__Test, "hi")

	testClass.Static__Test = "hello"

	luaunit.assertEquals(testClass.Static__Test, "hello")
	luaunit.assertEquals(testClassInstance.Static__Test, "hello")

	Utils.Class.Deconstruct(testClassInstance)
	local function throwErrorBecauseOfDeconstructedClass()
		_ = testClassInstance.Static__Test
	end

	luaunit.assertErrorMsgContains("cannot get values from deconstruct class: StaticTestClass",
		throwErrorBecauseOfDeconstructedClass)
end

function TestRawAccess()
	local testClass = Utils.Class.Create({
		Raw__Test = "hi",
		__index = function()
			error("can not use index")
		end
	}, 'CreateEmpty')
	local testClassInstance1 = testClass()
	local testClassInstance2 = testClass()

	testClassInstance1.Raw__Test = "hello"

	luaunit.assertEquals(testClassInstance1.Raw__Test, "hello")
	luaunit.assertEquals(testClassInstance2.Raw__Test, "hi")

	local function throwErrorBecauseOfNotContstructedClass()
		_ = testClass.Raw__Test
	end

	local function throwErrorBecauseOfIndexError()
		_ = testClassInstance1.Test
	end

	luaunit.assertErrorMsgContains("can only use static members in template", throwErrorBecauseOfNotContstructedClass)
	luaunit.assertErrorMsgContains("can not use index", throwErrorBecauseOfIndexError)
end

function TestMetaMethod()
	local testClass = Utils.Class.Create({
		__index = function()
			return "some value"
		end
	}, "TestMetaMethod")
	local instance = testClass()

	local function throwErrorBecauseOfIndexReturningString()
		_ = instance:foo()
	end

	luaunit.assertErrorMsgContains("attempt to call a string value (method 'foo')",
		throwErrorBecauseOfIndexReturningString)
end

os.exit(luaunit.LuaUnit.run())
