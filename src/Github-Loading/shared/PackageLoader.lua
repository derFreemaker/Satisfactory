---@class Package
---@field Name string
---@field Namespace string
---@field RequiredPackages string[]
---@field Data table
local Package = {}
Package.__index = Package

---@param info table
---@param data table
---@return Package
function Package.new(info, data)
    return setmetatable({
        Name = info.Name,
        RequiredPackages = info.RequiredPackages,
        Data = data
    }, Package)
end



---@class PackageLoader
local PackageLoader = {}



return PackageLoader