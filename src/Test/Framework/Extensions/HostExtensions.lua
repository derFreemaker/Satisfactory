---@class Hosting.Host
local HostExtensions = {}

---@return Test.Framework testFramework
function HostExtensions:AddTesting()
    local testFramework = require("Test.Framework.Framework")
    for _, module in pairs(PackageLoader.CurrentPackage.Modules) do
        module:Load()
    end
    return testFramework
end

Utils.Class.ExtendClass(HostExtensions, require("Hosting.Host"))
