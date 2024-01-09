local luaunit = require('Tools.Testing.Luaunit')

local FileSystem = require("Tools.Freemaker.bin.filesystem")
local currentPath = FileSystem:GetCurrentDirectory()

local eepromFilePath = currentPath .. "/../../Github-Loading/GithubLoaderInGame.lua"
local eepromFile = io.open(eepromFilePath, "r")
if not eepromFile then
    error("unable to open install.eeprom")
end
local eeprom = eepromFile:read("a")
eepromFile:close()

local FileSystemPath = currentPath .. "/Sim-Files/Test_LoaderLoad"
local Sim = require('Tools.Testing.Simulator'):Initialize(1, FileSystemPath, eeprom)

---@diagnostic disable-next-line
function computer.stop()
    luaunit.success()
end

function Test()
    dofile(eepromFilePath)
end

os.exit(luaunit.LuaUnit.run())
