local Data={
["TDS.Server.__main"] = [==========[
local EventPullAdapter = require("Core.Event.EventPullAdapter")

local DistributionSystem = require("TDS.Server.DistributionSystem")

---@class TDS.Server.Main : Github_Loading.Entities.Main
---@field m_distibutionSystem TDS.Server.DistributionSystem
local Main = {}

function Main:Configure()
    -- add host to host endpoints

    self.m_distibutionSystem = DistributionSystem(self.Logger:subLogger("TrainDistributionSystem"))
end

function Main:Run()
	while true do
        EventPullAdapter:Wait(2)

        self.m_distibutionSystem:Run()
	end
end

return Main

]==========],
["TDS.Server.DistributionSystem"] = [==========[
local UUID = require("Core.Common.UUID")
local Path = require("Core.FileSystem.Path")
local ProxyReference = require("Core.References.ProxyReference")
local DbTable = require("Database.DbTable")

local Train = require("TDS.Core.Entities.Train")
local Request = require("TDS.Core.Entities.Request")

NEW_NAME = "NEW_TRAIN"

---@class TDS.Server.DistributionSystem : object
---@field m_queue TDS.Request[]
---@field m_trains Database.DbTable
---@field m_requests Database.DbTable
---@field m_logger Core.Logger
---@overload fun(logger: Core.Logger) : TDS.Server.DistributionSystem
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

---@private
---@param trainRef Core.Reference<Satis.Train>
function DistributionSystem:AddTrain(trainRef)
    --//TODO: maybe works to find out if it has fluid containers but should test out
    local lastPart = trainRef:Get():getLast()
    local isFluid = #lastPart:getInventories() == 0

    local train = Train(UUID.Static__New(), 1, isFluid)
    trainRef:Get():setName(train.Id:ToString())

    self.m_trains:Set(train.Id:ToString(), train)
end

function DistributionSystem:Check()
    log("TODO: check for missing stations or trians")
    log("TODO: add any stations or trains")
end

function DistributionSystem:Distribute()
    log("TODO: implement DistributionSystem:Distribute()")
end

function DistributionSystem:Run()
    self:Check()

    self:Distribute()
end

return class("TDS.DistributionSystem", DistributionSystem)

]==========],
["TDS.Server.TrainHandler"] = [==========[
local UUID = require("Core.Common.UUID")

---@class TDS.TrainHandler : object
---@overload fun() : TDS.TrainHandler
local TrainHandler = {}

---@private
function TrainHandler:__init()
    
end

function TrainHandler:Handle()

end

return class("TDS.TrainHandler", TrainHandler)

]==========],
}

return Data
