---@meta
local PackageData = {}

PackageData["FactoryControlCore__events"] = {
    Location = "FactoryControl.Core.__events",
    Namespace = "FactoryControl.Core.__events",
    IsRunnable = true,
    Data = [[
local JsonSerializer = require("Core.Json.JsonSerializer")

---@class FactoryControl.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddTypeInfos({
        -- ControllerDto's
        require("FactoryControl.Core.Entities.Controller.ControllerDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.CreateDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.ModifyDto"):Static__GetType(),

        -- FeatureDto's
        require("FactoryControl.Core.Entities.Controller.Feature.SwitchDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.Feature.ButtonDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.Feature.RadialDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.Feature.ChartDto"):Static__GetType(),
    })
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

PackageData["FactoryControlCoreEntitiesControllerConnectDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.ConnectDto",
    Namespace = "FactoryControl.Core.Entities.Controller.ConnectDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.Controller.ConnectDto : Core.Json.Serializable
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@overload fun(name: string, ipAddress: Net.Core.IPAddress) : FactoryControl.Core.Entities.Controller.ConnectDto
local ConnectDto = {}

---@private
---@param name string
---@param ipAddress Net.Core.IPAddress
function ConnectDto:__init(name, ipAddress)
    self.Name = name
    self.IPAddress = ipAddress
end

---@return string name, Net.Core.IPAddress ipAddress
function ConnectDto:Serialize()
    return self.Name, self.IPAddress
end

return Utils.Class.CreateClass(ConnectDto, "FactoryControl.Core.Entities.Controller.ConnectDto",
    require("Core.Json.Serializable"))
]]
}

PackageData["FactoryControlCoreEntitiesControllerControllerDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.ControllerDto",
    Namespace = "FactoryControl.Core.Entities.Controller.ControllerDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.ControllerDto : Core.Json.Serializable
---@field Id Core.UUID
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@field Features Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>
---@overload fun(id: Core.UUID, name: string, ipAddress: Net.Core.IPAddress, features: Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>?) : FactoryControl.Core.Entities.ControllerDto
local ControllerDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>?
function ControllerDto:__init(id, name, ipAddress, features)
    self.Id = id
    self.Name = name
    self.IPAddress = ipAddress
    self.Features = features or {}
end

---@return string name, Core.UUID id, Net.Core.IPAddress ipAddress, Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto> features
function ControllerDto:Serialize()
    return self.Name, self.Id, self.IPAddress, self.Features
end

return Utils.Class.CreateClass(ControllerDto, "FactoryControl.Core.Entities.ControllerDto",
    require("Core.Json.Serializable"))
]]
}

PackageData["FactoryControlCoreEntitiesControllerCreateDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.CreateDto",
    Namespace = "FactoryControl.Core.Entities.Controller.CreateDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.Controller.CreateDto : Core.Json.Serializable
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@field Features Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>
---@overload fun(name: string, ipAddress: Net.Core.IPAddress, features: Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>?) : FactoryControl.Core.Entities.Controller.CreateDto
local ControllerDto = {}

---@private
---@param name string
---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>?
function ControllerDto:__init(name, ipAddress, features)
    self.Name = name
    self.IPAddress = ipAddress
    self.Features = features or {}
end

---@return string name, Net.Core.IPAddress ipAddress, Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto> features
function ControllerDto:Serialize()
    return self.Name, self.IPAddress, self.Features
end

return Utils.Class.CreateClass(ControllerDto, "FactoryControl.Core.Entities.Controller.CreateDto",
    require("Core.Json.Serializable"))
]]
}

PackageData["FactoryControlCoreEntitiesControllerModifyDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.ModifyDto",
    Namespace = "FactoryControl.Core.Entities.Controller.ModifyDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.Controller.ModifyDto : Core.Json.Serializable
---@field Id Core.UUID
---@field Features Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>
---@overload fun(features: Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>) : FactoryControl.Core.Entities.Controller.ModifyDto
local ModifyDto = {}

---@private
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>
function ModifyDto:__init(features)
    self.Features = features
end

---@return Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>
function ModifyDto:Serialize()
    return self.Features
end

return Utils.Class.CreateClass(ModifyDto, "FactoryControl.Core.Entities.Controller.ModifyDto",
    require("Core.Json.Serializable"))
]]
}

PackageData["FactoryControlCoreEntitiesControllerFeatureButtonDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.Feature.ButtonDto",
    Namespace = "FactoryControl.Core.Entities.Controller.Feature.ButtonDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.Controller.Feature.ButtonDto : FactoryControl.Core.Entities.Controller.FeatureDto
---@overload fun(id: Core.UUID, name: string) : FactoryControl.Core.Entities.Controller.Feature.ButtonDto
local ButtonFeatureDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function ButtonFeatureDto:__init(baseFunc, id, name)
    baseFunc(id, name, "Button")
end

---@return Core.UUID id, string name
function ButtonFeatureDto:Serialize()
    return self.Id, self.Name
end

return Utils.Class.CreateClass(ButtonFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.ButtonDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --{{{@as FactoryControl.Core.Entities.Controller.FeatureDto}}})
]]
}

PackageData["FactoryControlCoreEntitiesControllerFeatureChartDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.Feature.ChartDto",
    Namespace = "FactoryControl.Core.Entities.Controller.Feature.ChartDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.Controller.Feature.ChartDto : FactoryControl.Core.Entities.Controller.FeatureDto
---@field XAxisName string
---@field YAxisName string
---@field Data Dictionary<number, any>
---@overload fun(id: Core.UUID, name: string, xAxisName: string, yAxisName: string, data: Dictionary<number, any>?) : FactoryControl.Core.Entities.Controller.Feature.ChartDto
local ChartFeatureDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param xAxisName string
---@param yAxisName string
---@param data Dictionary<number, any>?
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function ChartFeatureDto:__init(baseFunc, id, name, xAxisName, yAxisName, data)
    baseFunc(id, name, "Chart")

    self.XAxisName = xAxisName
    self.YAxisName = yAxisName
    self.Data = data or {}
end

---@return Core.UUID id, string name, string xAxisName, string yAxisName, Dictionary<number, any> data
function ChartFeatureDto:Serialize()
    return self.Id, self.Name, self.XAxisName, self.YAxisName, self.Data
end

return Utils.Class.CreateClass(ChartFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.ChartDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --{{{@as FactoryControl.Core.Entities.Controller.FeatureDto}}})
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

---@class FactoryControl.Core.Entities.Controller.FeatureDto : Core.Json.Serializable
---@field Id Core.UUID
---@field Name string
---@field Type FactoryControl.Core.Entities.Controller.Feature.Type
---@overload fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type) : FactoryControl.Core.Entities.Controller.FeatureDto
local FeatureDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param type FactoryControl.Core.Entities.Controller.Feature.Type
function FeatureDto:__init(id, name, type)
    self.Id = id
    self.Name = name
    self.Type = type
end

-- No Seriliaze function because this class should only be used as base not for instances

return Utils.Class.CreateClass(FeatureDto, "FactoryControl.Core.Entities.Controller.FeatureDto",
    require("Core.Json.Serializable"))
]]
}

PackageData["FactoryControlCoreEntitiesControllerFeatureRadialDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.Feature.RadialDto",
    Namespace = "FactoryControl.Core.Entities.Controller.Feature.RadialDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.Controller.Feature.RadialDto : FactoryControl.Core.Entities.Controller.FeatureDto
---@field Min number
---@field Max number
---@field Setting number
---@overload fun(id: Core.UUID, name: string, min: number?, max: number?, setting: number?) : FactoryControl.Core.Entities.Controller.Feature.RadialDto
local RadialFeatureDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param min number
---@param max number
---@param setting number
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function RadialFeatureDto:__init(baseFunc, id, name, min, max, setting)
    baseFunc(id, name, "Radial")

    self.Min = min or 0
    self.Max = max or 1

    if self.Min > self.Max then
        error("min: " .. self.Min .. " cannot be bigger then max: " .. self.Max)
        return
    end

    if setting == nil then
        setting = self.Min
    else
        if self.Min > setting or self.Max < setting then
            error("setting: " .. setting .. " is out of range: " .. self.Min .. " - " .. self.Max)
            return
        end
    end

    self.Setting = setting
end

---@return Core.UUID id, string name, number min, number max, number setting
function RadialFeatureDto:Serialize()
    return self.Id, self.Name, self.Min, self.Max, self.Setting
end

return Utils.Class.CreateClass(RadialFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.RadialDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --{{{@as FactoryControl.Core.Entities.Controller.FeatureDto}}})
]]
}

PackageData["FactoryControlCoreEntitiesControllerFeatureSwitchDto"] = {
    Location = "FactoryControl.Core.Entities.Controller.Feature.SwitchDto",
    Namespace = "FactoryControl.Core.Entities.Controller.Feature.SwitchDto",
    IsRunnable = true,
    Data = [[
---@class FactoryControl.Core.Entities.Controller.Feature.SwitchDto : FactoryControl.Core.Entities.Controller.FeatureDto
---@field IsEnabled boolean
---@overload fun(id: Core.UUID, name: string, isEnabled: boolean) : FactoryControl.Core.Entities.Controller.Feature.SwitchDto
local SwitchFeatureDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param isEnabled boolean?
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function SwitchFeatureDto:__init(baseFunc, id, name, isEnabled)
    baseFunc(id, name, "Switch")

    if isEnabled == nil then
        self.IsEnabled = false
        return
    end
    self.IsEnabled = isEnabled
end

---@return Core.UUID id, string name, boolean isEnabled
function SwitchFeatureDto:Serialize()
    return self.Id, self.Name, self.IsEnabled
end

return Utils.Class.CreateClass(SwitchFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.SwitchDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --{{{@as FactoryControl.Core.Entities.Controller.FeatureDto}}})
]]
}

return PackageData
