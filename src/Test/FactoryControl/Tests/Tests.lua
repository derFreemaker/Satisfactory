---@param client FactoryControl.Client
local function test(client)
    log("tests running")

    local controller = require("Test.FactoryControl.Tests.Connection")(client)

    require("Test.FactoryControl.Tests.Features.Button")(controller)
    require("Test.FactoryControl.Tests.Features.Switch")(controller)
end
return test
