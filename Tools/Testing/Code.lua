print("### START ###")

-- local sim = require('Tools.Testing.Simulator'):Initialize(1)
local sim, loader = require('Tools.Testing.Simulator'):InitializeWithLoader(1, nil, nil, true)

local option = loader:LoadOption("FactoryControl_Server")
sim:OverrideRequire()

local program, package = loader:LoadProgram(option, true)

loader:Configure(program, package, 1)
loader:Run(program)

print(computer.getMemory())
print("### END ###")
