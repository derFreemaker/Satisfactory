local JsonSerializer = require("Core.Json.JsonSerializer")

---@class Services.Callback.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddClasses({
        require("Services.Callback.Core.Entities.CallbackInfo")
    })

    require("Services.Callback.Core.Extensions.NetworkContextExtensions")
end

return Events
