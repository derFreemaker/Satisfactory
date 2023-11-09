local LoadedLoaderFiles = ({ ... })[1]
---@type Utils
local Utils = LoadedLoaderFiles["/Github-Loading/Loader/Utils"][1]

----------------------------------------------
-- Event
----------------------------------------------

local eventListenFunc = event.listen
---@param component FIN.Component | Core.IReference
---@diagnostic disable-next-line
function event.listen(component)
    if Utils.Class.HasBaseClass(component, "Core.IReference") then
        ---@cast component Core.IReference
        return eventListenFunc(component:Get())
    end

    ---@cast component FIN.Component
    return eventListenFunc(component)
end
