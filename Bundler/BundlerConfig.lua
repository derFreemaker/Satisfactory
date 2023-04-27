local Utils = require("Utils")

---@class BundlerConfig
---@field private argumente string[]
---@field Path string
local Config = {}
Config.__index = Config

local props = {
    ["p"] = "Path"
}

---@param argumente string
---@return BundlerConfig
function Config.new(argumente)
    return setmetatable({
        argumente = argumente
    }, Config)
end

---@return BundlerConfig
function Config:Build()
    for _, value in pairs(self.argumente) do
        local valueData = Utils.Split(value, "--")
        local prop = props[valueData[1]]
        if prop ~= nil then
            self[prop] = valueData[2]
        end
    end

    self.args = {}
    self:Check()
    return self
end

function Config:Check()
    for _, prop in pairs(props) do
        if self[prop] == nil or self[prop] == "" then
            error(prop .. " was  nil")
        end
    end
end

return Config