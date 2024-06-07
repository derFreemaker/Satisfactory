local DbTable = require("Database.DbTable")
local Path = require("Core.FileSystem.Path")
local UUID = require("Core.Common.UUID")

local TrainDto = require("TDS.Core.Entities.Train.Dto")

---@class TDS.Server.DatabaseAccessLayer : object
---@field m_Trains Database.DbTable
---@overload fun(logger: Core.Logger) : TDS.Server.DatabaseAccessLayer
local DatabaseAccessLayer = {}

---@private
---@param logger Core.Logger
function DatabaseAccessLayer:__init(logger)
    self.m_Trains = DbTable("Trains", Path("/Database/Trains"), logger:subLogger("TrainsTable"))

    self.m_Trains:Load()
end

function DatabaseAccessLayer:Save()
    self.m_Trains:Save()
end

--------------------------------------------------------------
-- Trains
--------------------------------------------------------------

---@param createTrain TDS.Entities.Train.Create
---@return TDS.Entities.Train.Dto | nil trainDto
function DatabaseAccessLayer:CreateTrain(createTrain)
    local trainDto = TrainDto(UUID.Static__New(), createTrain.NumCargoWagons, createTrain.NumFluidWagons)

    self.m_Trains:Set(trainDto.Id:ToString(), trainDto)
    return trainDto
end

---@param id Core.UUID
---@return boolean found
function DatabaseAccessLayer:DeleteTrain(id)
    return self.m_Trains:Delete(id:ToString())
end

---@param id Core.UUID
---@return TDS.Entities.Train.Dto
function DatabaseAccessLayer:GetTrainById(id)
    return self.m_Trains:Get(id:ToString())
end

return class("TDS.DatabaseAccessLayer", DatabaseAccessLayer)
