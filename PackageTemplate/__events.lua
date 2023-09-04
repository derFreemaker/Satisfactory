---@class Template.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    print("called on loaded")
end

return Events