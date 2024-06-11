local Path = require("Core.FileSystem.Path")
local ProxyReference = require("Core.References.ProxyReference")

local DbTable = require("Database.DbTable")

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
---@param createRequest TDS.Request.Builder
function DistributionSystem:AddRequest(createRequest)
    createRequest
end

return class("TDS.DistributionSystem", DistributionSystem)
