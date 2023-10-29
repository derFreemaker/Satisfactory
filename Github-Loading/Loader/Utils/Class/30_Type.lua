local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.Class.Type
local ObjectTypeInfo = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Class/Object'][1]

---@class Utils.Class.Type
---@field Name string
---@field Base Utils.Class.Type
---
---@field Static table<string, any>
---
---@field MetaMethods Utils.Class.MetaMethods
---@field Members table<string, any>
---
---
---@field HasConstructor boolean
---@field HasDeconstructor boolean
---
---@field IndexingDisabled boolean
---@field HasIndex boolean
---@field HasNewIndex boolean
---
---@field Template table
---@field Instances table

---@class Utils.Class.TypeHandler
local TypeHandler = {}

---@param name string
---@param baseClass object?
---@return Utils.Class.Type
function TypeHandler.CreateType(name, baseClass)
	local typeInfo = { Name = name, IndexingDisabled = false }
	---@cast typeInfo Utils.Class.Type

	if baseClass then
		---@type Utils.Class.Metatable
		local baseClassMetatable = getmetatable(baseClass)
		typeInfo.Base = baseClassMetatable.Type
	else
		typeInfo.Base = ObjectTypeInfo
	end

	setmetatable(
		typeInfo,
		{
			__tostring = function(self)
				return self.Name
			end
		}
	)

	return typeInfo
end

---@param typeInfo Utils.Class.Type
---@param key string
---@param value any
---@return boolean wasFound
local function assignStatic(typeInfo, key, value)
	if rawget(typeInfo.Static, key) ~= nil then
		rawset(typeInfo.Static, key, value)
		return true
	end

	if typeInfo.Name == "object" then
		return false
	end

	return assignStatic(typeInfo.Base, key, value)
end

---@param typeInfo Utils.Class.Type
---@param key string
---@param value any
function TypeHandler.SetStatic(typeInfo, key, value)
	if not assignStatic(typeInfo, key, value) then
		rawset(typeInfo.Static, key, value)
	end
end

---@param typeInfo Utils.Class.Type
---@param key string
function TypeHandler.GetStatic(typeInfo, key)
	local value = rawget(typeInfo.Static, key)

	if value ~= nil then
		return value
	end

	if typeInfo.Name == "object" then
		return nil
	end

	return TypeHandler.GetStatic(typeInfo.Base, key)
end

return TypeHandler
