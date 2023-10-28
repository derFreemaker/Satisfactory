local luaunit = require('Tests.Luaunit')
require('Tests.Simulator.Simulator'):Initialize(1)

local Path = require("Core.FileSystem.Path")

function TestCreatePath()
    local test = Path("/Test/Path")

    luaunit.assertNotIsNil(test, "test path is nil")
end

function TestGetPathAndToString()
    local path = "/Test/Path/"

    local test = Path(path)

    luaunit.assertEquals(test:GetPath(), path)
    luaunit.assertEquals(tostring(test), path)
end

function TestIsEmpty()
    local test = Path()

    luaunit.assertIsTrue(test:IsEmpty())
end

function TestIsFile()
    local path = "\\Test\\../Test/Path/./log.txt"

    local test = Path(path)

    luaunit.assertIsTrue(test:IsFile())
end

function TestIsDir()
    local path = "\\Test\\../Test/Path/./"

    local test = Path(path)

    luaunit.assertIsTrue(test:IsDir())
end

function TestGetParentFolderPath()
    local path = "/Test/Path/"

    local test = Path(path)

    luaunit.assertEquals(test:GetParentFolderPath():GetPath(), "/Test/")
end

function TestGetFileName()
    local path = "\\Test\\../Test/Path/./log.txt"

    local test = Path(path)

    luaunit.assertEquals(test:GetFileName(), "log.txt")
end

function TestGetFileExtension()
    local path = "\\Test\\../Test/Path/./log.txt"

    local test = Path(path)

    luaunit.assertEquals(test:GetFileExtension(), ".txt")
end

function TestGetFileStem()
    local path = "\\Test\\../Test/Path/./log.txt"

    local test = Path(path)

    luaunit.assertEquals(test:GetFileStem(), "log")
end

function TestNormalizeDir()
    local path = "\\Test\\../Test/Path/."

    local test = Path(path)

    luaunit.assertEquals(test:Normalize():GetPath(), "/Test/Path/")
end

function TestNormalizeFile()
    local path = "\\Test\\../Test/Path/./log.txt"

    local test = Path(path)

    luaunit.assertEquals(test:Normalize():GetPath(), "/Test/Path/log.txt")
end

function TestAppend()
    local path = "\\Test\\../Test/Path/."
    local test = Path(path)

    test:Append("log.txt")

    luaunit.assertEquals(test:GetPath(), "/Test/Path/log.txt")
end

function TestExtend()
    local path = "/Test/Path/"
    local test = Path(path)

    local testExtened = test:Extend("log.txt")

    luaunit.assertEquals(test:GetPath(), "/Test/Path/")
    luaunit.assertEquals(testExtened:GetPath(), "/Test/Path/log.txt")
end

function TestCopy()
    local path = "\\Test\\../Test/Path/."

    local test = Path(path)
    local testCopy = test:Copy()

    ---@diagnostic disable-next-line
    luaunit.assertNotEquals(tostring(test.m_nodes), tostring(testCopy.m_nodes))
    luaunit.assertEquals(test:GetPath(), testCopy:GetPath())
end

os.exit(luaunit.LuaUnit.run())
