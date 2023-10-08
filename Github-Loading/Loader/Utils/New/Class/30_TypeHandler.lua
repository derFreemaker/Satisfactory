local LoadedLoaderFiles = ({...})[1]
---@type Utils.new.Class.Type
local ObjectTypeInfo = LoadedLoaderFiles['/Github-Loading/Loader/Utils/New/Class/Object'][1]

---@class Utils.new.Class.Type
---@field Name string
---@field Base Utils.new.Class.Type
---
---@field Static table
---
---@field MetaMethods Utils.new.Class.MetaMethods
---@field Members Dictionary<string, any>
---
---
---@field HasConstructor boolean
---@field HasDeconstructor boolean
---@field HasIndex boolean
---@field HasNewIndex boolean

---@class Utils.new.Class.TypeHandler
local TypeHandler = {}

---@param name string
---@param baseClass object?
---@return Utils.new.Class.Type
function TypeHandler.CreateType(name, baseClass)
	local typeInfo = {Name = name}
	---@cast typeInfo Utils.new.Class.Type

	if baseClass then
		---@type Utils.new.Class.Metatable
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
