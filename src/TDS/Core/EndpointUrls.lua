---@class TDS.EndpointUrlTemplates
local EndpointUrlTemplates = {}

---@class TDS.EndpointUrlConstructors
local EndpointUrlConstructors = {}

--------------------------------------------------------------
-- Train
--------------------------------------------------------------

---@class TDS.EndpointUrlTemplates.Train
local TrainTemplates = {}

---@class TDS.EndpointUrlConstructors.Train
local TrainConstructors = {}

TrainTemplates.Create = "/Train/Create"
function TrainConstructors.Create()
    return "/Train/Create"
end

TrainTemplates.Delete = "/Train/{id:Core.UUID}/Delete"
---@param id Core.UUID
function TrainConstructors.Delete(id)
    return "/Train/" .. id:ToString() .. "/Delete"
end

TrainTemplates.Modify = "/Train/{id:Core.UUID}/Modify"
---@param id Core.UUID
function TrainConstructors.Modify(id)
    return "/Train/" .. id:ToString() .. "/Modify"
end

TrainTemplates.GetById = "/Train/{id:Core.UUID}"
---@param id Core.UUID
function TrainConstructors.GetById(id)
    return "/Train/" .. id:ToString()
end

EndpointUrlTemplates.Train = TrainTemplates
EndpointUrlConstructors.Train = TrainConstructors

return { EndpointUrlTemplates, EndpointUrlConstructors }