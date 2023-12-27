---@class Hosting.Host
local HostExtensions = {}

---@return Test.Framework testFramework
function HostExtensions:AddTesting()
    local testFramework = require("Test.Framework.init")
    for _, module in pairs(PackageLoader.CurrentPackage.Modules) do
        require(module.Namespace)
    end
    return testFramework
end

Utils.Class.Extend(require("Hosting.Host"), HostExtensions)
