local Utils = require("Utils")
local BundlePart = require("BundlePart")

---@class Bundler
---@field Config BundlerConfig
---@field RootBundlePart BundlePart
local Bundler = {}
Bundler.__index = Bundler

---@param config BundlerConfig
---@return Bundler
function Bundler.new(config)
    return setmetatable({
        Config = config
    }, Bundler)
end

function Bundler:Build()
    local folder = bundlerFilesystem.getFolder(self.Config.Path)
    local uuid = Utils.GenerateNewUUID()
    self.RootBundlePart = BundlePart.newFromFolder(uuid, folder)
    self.RootBundlePart:Build()
end

return Bundler