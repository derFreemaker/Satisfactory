---@class Main
---@field Logger Logger
---@field SetupFilesTree table
local Main = {}
Main.__index = Main

---@return string | any
function Main:Configure()
    return "$%not found%$"
end

---@return string | any
function Main:Run()
    return "$%not found%$"
end

return Main