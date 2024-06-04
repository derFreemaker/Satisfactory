local EventPullAdapter = require("Core.Event.EventPullAdapter")
local FactoryControlClient = require("FactoryControl.Client.Client")

local Task = require("Core.Common.Task")

---@class PowerPlant.Watcher.Main : Github_Loading.Entities.Main
local Main = {}

function Main:Configure()
    if not Config.Name then
        error("'Config.Name' needs to be set")
    end
end

---@param update FactoryControl.Core.Entities.Controller.Feature.Chart.Update
local function processUpdate(update)
    log("update data:\n", update.Data)
end

function Main:Run()
    local factoryClient = FactoryControlClient(self.Logger:subLogger("FactoryControlClient"))

    local controller = factoryClient:GetControllerByName(Config.Name)

    if not controller then
        error("unable to get controller: " .. Config.Name)
    end

    for _, feature in pairs(controller:GetFeatures()) do
        print(feature.Name, feature.Type)

        if feature.Type == "Chart" then
            feature.OnChanged:AddTask(Task(processUpdate))
        end
    end

    EventPullAdapter:Run()
end

return Main
