local luaunit = require('tools.Testing.Luaunit')
require('tools.Testing.Simulator'):Initialize(1)

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
    local isFile = test:IsFile()

    luaunit.assertIsTrue(isFile)
end

function TestIsDir()
    local path = "\\Test\\../Test/Path/./"

    local test = Path(path)

    luaunit.assertIsTrue(test:IsDir())
end

function TestGetParentFolderPath()
    local path = "/Test/Path/"

    local test = Path(path)
    local parentFolderPath = test:GetParentFolderPath():GetPath()

    luaunit.assertEquals(parentFolderPath, "/Test/")
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

    local testNodes = tostring(test.m_nodes) ---@diagnostic disable-line
    local copyNodes = tostring(testCopy.m_nodes) ---@diagnostic disable-line

    local testPath = test:GetPath()
    local copyPath = testCopy:GetPath()

    ---@diagnostic disable-next-line
    luaunit.assertNotEquals(testNodes, copyNodes)
    luaunit.assertEquals(copyPath, testPath)
end

os.exit(luaunit.LuaUnit.run())
