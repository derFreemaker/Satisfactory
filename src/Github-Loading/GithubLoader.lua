---@class Option
---@field Name string
---@field Url string
local Option = {}
Option.__index = Option

---@param name string
---@param url string
---@return Option
function Option.new(name, url)
    return setmetatable({
        Name = name,
        Url = url
    }, Option)
end

---@param extended boolean
function Option:Print(extended)
    ---@type string
    local output
    if extended == true and type(self.Url) == "string" then
        output = self.Name .. " -> " .. self.Url
    end
    print(output)
end

-- ########## Option ########## --

---@class GithubLoader
local GithubLoader = {}
GithubLoader.__index = GithubLoader



return GithubLoader