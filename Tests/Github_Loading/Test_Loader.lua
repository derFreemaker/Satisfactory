local luaunit = require('tools.Testing.Luaunit')

local FileSystem = require("tools.Freemaker.bin.filesystem")
local FileSystemPath = FileSystem:GetCurrentDirectory() .. "/Sim-Files/Test_LoaderLoad"
local Sim, Loader = require('tools.Testing.Simulator'):InitializeWithLoader(1, FileSystemPath, nil, true)

function TestCheckVersion()
    _ = Loader:CheckVersion()
end

function TestShowOptions()
    Loader:ShowOptions(true)
end

function TestLoadOption()
    local option = Loader:LoadOption("Test_Core")
end

function TestLoadProgram()
    local option = Loader:LoadOption("Test_Core")
    Sim:OverrideRequire()

    local program, package = Loader:LoadProgram(option, true)
end

function TestConfigureProgram()
    local option = Loader:LoadOption("Test_Core")
    Sim:OverrideRequire()

    local program, package = Loader:LoadProgram(option, true)

    Loader:Configure(program, package, 1)
end

function TestRunProgram()
    local option = Loader:LoadOption("Test_Core")
    Sim:OverrideRequire()

    local program, package = Loader:LoadProgram(option, true)

    Loader:Configure(program, package, 1)
    Loader:Run(program)
end

os.exit(luaunit.LuaUnit.run())
