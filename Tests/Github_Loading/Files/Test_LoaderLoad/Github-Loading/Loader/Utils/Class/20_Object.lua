local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.Class.Configs
local Config = LoadedLoaderFiles["/Github-Loading/Loader/Utils/Class/Config"][1]
---@type Utils.String
local String = LoadedLoaderFiles['/Github-Loading/Loader/Utils/String'][1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]

---@class object : Utils.Class.ObjectMetaMethods, function
local Object = {}

---@protected
---@return string typeName
function Object:__tostring()
	return typeof(self).Name
end

---@protected
---@return string
function Object.__concat(left, right)
	return tostring(left) .. tostring(right)
end

---@class object.Modify
---@field DisableCustomIndexing boolean?

---@protected
---@param modify object.Modify
function Object:Raw__ModifyBehavior(modify)
	local metatable = getmetatable(self)

	if modify.DisableCustomIndexing ~= nil then
		metatable.Type.IndexingDisabled = modify.DisableCustomIndexing
	end
end

----------------------------------------
-- Type Info
----------------------------------------

local typeInfo = {}
---@cast typeInfo Utils.Class.Type

typeInfo.Name = 'object'

typeInfo.Static = {}
typeInfo.MetaMethods = {}
typeInfo.Members = {}

for key, value in pairs(Object) do
	if Config.AllMetaMethods[key] then
		typeInfo.MetaMethods[key] = value
	else
		if type(key) == 'string' then
			local splittedKey = String.Split(key, '__')
			if Table.Contains(splittedKey, 'Static') then
				typeInfo.Static[key] = value
			else
				typeInfo.Members[key] = value
			end
		else
			typeInfo.Members[key] = value
		end
	end
end

typeInfo.HasConstructor = false
typeInfo.HasDeconstructor = false
typeInfo.HasIndex = false
typeInfo.HasNewIndex = false

typeInfo.Instances = setmetatable({}, { __mode = 'k' })

return typeInfo
