local UUID = require("Core.Common.UUID")
local Path = require("Core.FileSystem.Path")
local ProxyReference = require("Core.References.ProxyReference")
local DbTable = require("Database.DbTable")

local Request = require("TDS.Entities.Request")

NEW_NAME = "NEW_TRAIN"

---@class TDS.DistributionSystem : object
---@field m_queue TDS.Request[]
---@field m_trains Database.DbTable
---@field m_requests Database.DbTable
---@field m_logger Core.Logger
---@overload fun(logger: Core.Logger) : TDS.DistributionSystem
local DistributionSystem = {}

---@private
---@param logger Core.Logger
function DistributionSystem:__init(logger)
    self.m_trains = DbTable(Path("/Trains"), logger:subLogger("Trains_DbTable"))
    self.m_requests = DbTable(Path("/Requests"), logger:subLogger("Requests_DbTable"))

    self.m_logger = logger
end

function DistributionSystem:Save()
    self.m_trains:Save()
end

---@private
---@param requestData TDS.Request.Data
---@return TDS.Request
function DistributionSystem:AddRequest(requestData)
    local request = Request(UUID.Static__New(), 1, nil, requestData)
    self.m_requests:Set(request.Id:ToString(), request)
    return request
end

return class("TDS.DistributionSystem", DistributionSystem)
