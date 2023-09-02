---@class DNS.Endpoints : object
---@overload fun() : DNS.Endpoints
local Endpoints = {}

function Endpoints:__call()
    
end

return Utils.Class.CreateClass(Endpoints, "DNS.Endpoints")