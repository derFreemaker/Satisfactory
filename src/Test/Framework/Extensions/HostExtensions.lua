---@class Hosting.Host
local HostExtensions = {}

---@return Test.Framework testFramework
function HostExtensions:AddTesting()
    local testFramework = require("Test.Framework.init")
    for _, module in pairs(PackageLoader.CurrentPackage.Modules) do
        module:Load()
    end
    return testFramework
end

Utils.Class.ExtendClass(require("Hosting.Host"), HostExtensions)
