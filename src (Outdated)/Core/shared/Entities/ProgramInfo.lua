---@class ProgramInfo
---@field Name string
---@field Version string
local ProgramInfo = {}
ProgramInfo.__index = ProgramInfo

---@param name string
---@param version string
---@return ProgramInfo
function ProgramInfo.new(name, version)
    return setmetatable({
        Name = name,
        Version = version
    }, ProgramInfo)
end

---@param programInfo ProgramInfo
function ProgramInfo:Compare(programInfo)
    if self.Name ~= programInfo.Name
        or self.Version ~= programInfo.Version then
        return false
    end
    return true
end

return ProgramInfo