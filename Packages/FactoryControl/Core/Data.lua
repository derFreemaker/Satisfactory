---@meta
local PackageData = {}

PackageData["FactoryControlCore__events"] = {
    Location = "FactoryControl.Core.__events",
    Namespace = "FactoryControl.Core.__events",
    IsRunnable = true,
    Data = [[
local JsonSerializer = require("Core.Json.JsonSerializer")

local EntityTypes = {
    require("FactoryControl.Core.Entities.Controller.ControllerDto"):Static__GetType(),
    require("FactoryControl.Core.Entities.Controller.Feature.SwitchDto"):Static__GetType(),
    require("FactoryControl.Core.Entities.Controller.Feature.ButtonDto"):Static__GetType(),
    require("FactoryControl.Core.Entities.Controller.Feature.RadialDto"):Static__GetType(),
    require("FactoryControl.Core.Entities.Controller.Feature.ChartDto"):Static__GetType(),
}

---@class FactoryControl.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddTypeInfos(EntityTypes)
end

return Events
]]
}

PackageData["FactoryControlCoreConfig"] = {
    Location = "FactoryControl.Core.Config",
    Namespace = "FactoryControl.Core.Config",
    IsRunnable = true,
    Data = [[
return {
	DOMAIN = 'FactoryControl'
}
]]
}

PackageData["FactoryControlCoreEntitiesControllerControllerDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.ControllerDto",
    Namespace = "FactoryControl.Core.Entities.Controller.ControllerDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.Controller.ControllerDto : Core.Json.Serializable
---@field Id Core.UUID
---@field IPAddress Net.Core.IPAddress
---@field Features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>
---@overload fun(id: Core.UUID, ipAddress: Net.Core.IPAddress, features: Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>?) : FactoryControl.Core.Entities.Controller.ControllerDto
local ControllerDto = {}

---@private
---@param id Core.UUID
---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>?
function ControllerDto:__init(id, ipAddress, features)
    self.Id = id
    self.IPAddress = ipAddress
    self.Features = features or {}
end

---@return Core.UUID id, Net.Core.IPAddress ipAddress, Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto> features
function ControllerDto:Serialize()
    return self.Id, self.IPAddress, self.Features
end

---@param id Core.UUID
---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>
---@return FactoryControl.Core.Entities.Controller.ControllerDto
function ControllerDto.Static__Deserialize(id, ipAddress, features)
    return ControllerDto(id, ipAddress, features)
end

return Utils.Class.CreateClass(ControllerDto, "FactoryControl.Core.Entities.Controller.ControllerDto",
    require("Core.Json.Serializable"))
]]
}

PackageData["FactoryControlCoreEntitiesControllerCreateControllerDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.CreateControllerDto",
    Namespace = "FactoryControl.Core.Entities.Controller.CreateControllerDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.Controller.CreateDto : Core.Json.Serializable
---@field IPAddress Net.Core.IPAddress
---@field Features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>
---@overload fun(ipAddress: Net.Core.IPAddress, features: Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>?) : FactoryControl.Core.Entities.Controller.CreateDto
local ControllerDto = {}

---@private
---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>?
function ControllerDto:__init(ipAddress, features)
    self.IPAddress = ipAddress
    self.Features = features or {}
end

---@return Net.Core.IPAddress ipAddress, Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto> features
function ControllerDto:Serialize()
    return self.IPAddress, self.Features
end

---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>
---@return FactoryControl.Core.Entities.Controller.CreateDto
function ControllerDto.Static__Deserialize(ipAddress, features)
    return ControllerDto(ipAddress, features)
end

return Utils.Class.CreateClass(ControllerDto, "FactoryControl.Core.Entities.Controller.CreateDto",
    require("Core.Json.Serializable"))
]]
}

PackageData["FactoryControlCoreEntitiesControllerFeatureButtonDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.Feature.ButtonDto",
    Namespace = "FactoryControl.Core.Entities.Controller.Feature.ButtonDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.Controller.Feature.ButtonDto : FactoryControl.Core.Entities.Controller.Feature.FeatureDto
---@overload fun(id: Core.UUID) : FactoryControl.Core.Entities.Controller.Feature.ButtonDto
local ButtonFeatureDto = {}

---@private
---@param id Core.UUID
---@param baseFunc fun(id: Core.UUID, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function ButtonFeatureDto:__init(baseFunc, id)
    baseFunc(id, "Button")
end

---@return Core.UUID
function ButtonFeatureDto:Serialize()
    return self.Id
end

---@param id Core.UUID
---@return FactoryControl.Core.Entities.Controller.Feature.ButtonDto
function ButtonFeatureDto.Static__Deserialize(id)
    return ButtonFeatureDto(id)
end

return Utils.Class.CreateClass(ButtonFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.ButtonDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --{{{@as FactoryControl.Core.Entities.Controller.Feature.FeatureDto}}})
]]
}

PackageData["FactoryControlCoreEntitiesControllerFeatureChartDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.Feature.ChartDto",
    Namespace = "FactoryControl.Core.Entities.Controller.Feature.ChartDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.Controller.Feature.ChartDto : FactoryControl.Core.Entities.Controller.Feature.FeatureDto
---@field Data Dictionary<number, any>
---@overload fun(id: Core.UUID, data: Dictionary<number, any>?) : FactoryControl.Core.Entities.Controller.Feature.ChartDto
local ChartFeatureDto = {}

---@private
---@param id Core.UUID
---@param data Dictionary<number, any>?
---@param baseFunc fun(id: Core.UUID, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function ChartFeatureDto:__init(baseFunc, id, data)
    baseFunc(id, "Chart")

    self.Data = data or {}
end

---@return Core.UUID id, Dictionary<number, any> data
function ChartFeatureDto:Serialize()
    return self.Id, self.Data
end

---@param id Core.UUID
---@param data Dictionary<number, any>
---@return FactoryControl.Core.Entities.Controller.Feature.ChartDto
function ChartFeatureDto.Static__Deserialize(id, data)
    return ChartFeatureDto(id, data)
end

return Utils.Class.CreateClass(ChartFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.ChartDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --{{{@as FactoryControl.Core.Entities.Controller.Feature.FeatureDto}}})
]]
}

PackageData["FactoryControlCoreEntitiesControllerFeatureFeatureDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.Feature.FeatureDto",
    Namespace = "FactoryControl.Core.Entities.Controller.Feature.FeatureDto",
    IsRunnable = true,
    Data = [[
---@alias FactoryControl.Core.Entities.Controller.Feature.Type
---|"Switch"
---|"Button"
---|"Radial"
---|"Chart"

---@class FactoryControl.Core.Entities.Controller.Feature.FeatureDto : Core.Json.Serializable
---@field Id Core.UUID
---@field Type FactoryControl.Core.Entities.Controller.Feature.Type
---@overload fun(id: Core.UUID, type: FactoryControl.Core.Entities.Controller.Feature.Type) : FactoryControl.Core.Entities.Controller.Feature.FeatureDto
local FeatureDto = {}

---@private
---@param id Core.UUID
---@param type FactoryControl.Core.Entities.Controller.Feature.Type
function FeatureDto:__init(id, type)
    self.Id = id
    self.Type = type
end

return Utils.Class.CreateClass(FeatureDto, "FactoryControl.Core.Entities.Controller.FeatureDto",
    require("Core.Json.Serializable"))
]]
}

PackageData["FactoryControlCoreEntitiesControllerFeatureRadialDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.Feature.RadialDto",
    Namespace = "FactoryControl.Core.Entities.Controller.Feature.RadialDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.Controller.Feature.RadialDto : FactoryControl.Core.Entities.Controller.Feature.FeatureDto
---@field Min number
---@field Max number
---@field Setting number
---@overload fun(id: Core.UUID, min: number?, max: number?, setting: number?) : FactoryControl.Core.Entities.Controller.Feature.RadialDto
local RadialFeatureDto = {}

---@private
---@param id Core.UUID
---@param min number
---@param max number
---@param setting number
---@param baseFunc fun(id: Core.UUID, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function RadialFeatureDto:__init(baseFunc, id, min, max, setting)
    baseFunc(id, "Radial")

    self.Min = min or 0
    self.Max = max or 1

    if setting == nil then
        setting = self.Min
    else
        if self.Min > setting or self.Max < setting then
            error("setting: " .. setting .. " is out of range: " .. self.Min .. " - " .. self.Max)
        end
    end

    self.Setting = setting
end

---@return Core.UUID id, number min, number max, number setting
function RadialFeatureDto:Serialize()
    return self.Id, self.Min, self.Max, self.Setting
end

---@param id Core.UUID
---@param min number
---@param max number
---@param setting number
---@return FactoryControl.Core.Entities.Controller.Feature.RadialDto
function RadialFeatureDto.Static__Deserialize(id, min, max, setting)
    return RadialFeatureDto(id, min, max, setting)
end

return Utils.Class.CreateClass(RadialFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.RadialDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --{{{@as FactoryControl.Core.Entities.Controller.Feature.FeatureDto}}})
]]
}

PackageData["FactoryControlCoreEntitiesControllerFeatureSwitchDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.Feature.SwitchDto",
    Namespace = "FactoryControl.Core.Entities.Controller.Feature.SwitchDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.Controller.Feature.SwitchDto : FactoryControl.Core.Entities.Controller.Feature.FeatureDto
---@field IsEnabled boolean
---@overload fun(id: Core.UUID, isEnabled: boolean) : FactoryControl.Core.Entities.Controller.Feature.SwitchDto
local SwitchFeatureDto = {}

---@private
---@param id Core.UUID
---@param isEnabled boolean?
---@param baseFunc fun(id: Core.UUID, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function SwitchFeatureDto:__init(baseFunc, id, isEnabled)
    baseFunc(id, "Switch")

    if isEnabled == nil then
        self.IsEnabled = false
        return
    end
    self.IsEnabled = isEnabled
end

function SwitchFeatureDto:Serialize()
    return self.Id, self.IsEnabled
end

---@param id Core.UUID
---@param isEnabled boolean
---@return FactoryControl.Core.Entities.Controller.Feature.SwitchDto
function SwitchFeatureDto.Static__Deserialize(id, isEnabled)
    return SwitchFeatureDto(id, isEnabled)
end

return Utils.Class.CreateClass(SwitchFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.SwitchDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --{{{@as FactoryControl.Core.Entities.Controller.Feature.FeatureDto}}})
]]
}

return PackageData
