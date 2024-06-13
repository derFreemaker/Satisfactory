local Path = require("Core.FileSystem.Path")
local DbTable = require("Database.DbTable")

---@class TDS.Server.DatabaseAccessLayer : object
---@overload fun(logger: Core.Logger) : TDS.Server.DatabaseAccessLayer
local DatabaseAccessLayer = {}

---@private
---@param logger Core.Logger
function DatabaseAccessLayer:__init(logger)
    self.m_trains = DbTable(Path("/Database/Trains"), logger:subLogger("Trains_DbTable"))
    self.m_stations = DbTable(Path("/Database/Stations"), logger:subLogger("Stations_DbTable"))
    self.m_requests = DbTable(Path("/Database/Requests"), logger:subLogger("Requests_DbTable"))
end

--//TODO: add functions

return class("TDS.Server.DatabaseAccessLayer", DatabaseAccessLayer)
