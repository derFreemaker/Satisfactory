local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.Class.Type
local ObjectTypeInfo = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Class/Object'][1]

---@class Utils.Class.Type
---@field Name string
---@field Base Utils.Class.Type
---
---@field Static table
---
---@field MetaMethods Utils.Class.MetaMethods
---@field Members Dictionary<string, any>
---
---
---@field HasConstructor boolean
---@field HasDeconstructor boolean
---@field HasIndex boolean
---@field HasNewIndex boolean

---@class Utils.Class.TypeHandler
local TypeHandler = {}

---@param name string
---@param baseClass object?
---@return Utils.Class.Type
function TypeHandler.CreateType(name, baseClass)
	local typeInfo = { Name = name }
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

return TypeHandler
