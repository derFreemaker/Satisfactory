local LoadedLoaderFiles = ({ ... })[1]
---@type Utils
local Utils = LoadedLoaderFiles["/Github-Loading/Loader/Utils"][1]

----------------------------------------------
-- Event
----------------------------------------------

local eventListenFunc = event.listen
---@param component Engine.Object | Core.Ref
---@diagnostic disable-next-line
function event.listen(component)
    if Utils.Class.HasInterface(component, "Core.IReference") then
        ---@cast component Core.Ref
        return eventListenFunc(component:Get())
    end

    ---@cast component Engine.Object
    return eventListenFunc(component)
end
