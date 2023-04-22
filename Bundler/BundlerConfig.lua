---@class BundlerConfig
---@field private args string[]
---@field Path string
local Config = {}
Config.__index = Config

local props = {
    ["-path"] = "Path",
    ["-name"] = "Name"
}

---@param str string
---@param sep string
---@return string[]
local function split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

---@return BundlerConfig
function Config.new(args)
    return setmetatable({
        args = args
    }, Config)
end

---@return BundlerConfig
function Config:Build()
    for _, value in pairs(self.args) do
        local valueData = split(value, ":")
        local prop = props[valueData[1]]
        if prop ~= nil then
            self[prop] = valueData[2]
        end
    end

    for _, prop in pairs(props) do
        if self[prop] == nil then
            error(prop .. " was  nil")
        end
    end

    self.args = {}
    return self
end

return Config