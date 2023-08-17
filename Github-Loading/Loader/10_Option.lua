---@class Github_Loading.Option
---@field Name string
---@field Url string
local Option = {}

---@param name string
---@param url string
---@return Github_Loading.Option
function Option.new(name, url)
    local metatable = Option
    metatable.__index = Option
    return setmetatable({
        Name = name,
        Url = url
    }, Option)
end

---@param extended boolean
function Option:Print(extended)
    ---@type string
    local output = self.Name
    if extended == true then
        output = output .. " -> " .. self.Url
    end
    print(output)
end

return Option