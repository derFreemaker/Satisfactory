local LoadedLoaderFiles = ({...})[1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]
---@type Utils.new.Class.MetatableHandler, table
local MetatableHandler,
	metaMethods = table.unpack(LoadedLoaderFiles['/Github-Loading/Loader/Utils/New/Class/MetatableHandler'])

---@class Utils.new.Class.ConstructionHandler
local ConstructionHandler = {}

---@param obj Utils.new.Class
local function construct(obj, ...)
	---@type Utils.new.Class.Metatable
	local metatable = getmetatable(obj)
	local typeInfo = metatable.Type

	local class,
		classMetatable = {}, {}
	---@cast class table
	---@cast classMetatable Utils.new.Class.Metatable

	MetatableHandler.CreateMetatable(typeInfo, classMetatable)
	ConstructionHandler.ConstructClass(typeInfo, class, classMetatable, ...)

	return class
end

---@param typeInfo Utils.new.Class.Type
---@param class table
---@param classMetatable Utils.new.Class.Metatable
---@param ... any
function ConstructionHandler.ConstructClass(typeInfo, class, classMetatable, ...)
	---@type function
	local baseFunc = nil

	local function constructMembers()
		for key, value in pairs(typeInfo.MetaMethods) do
			if metaMethods[key] then
				classMetatable[key] = value
			end
		end

		for key, value in pairs(typeInfo.Members) do
			class[key] = value
		end

		setmetatable(class, classMetatable)
	end

	if typeInfo.Base then
		if typeInfo.Base.HasConstructor then
			function baseFunc(...)
				ConstructionHandler.ConstructClass(typeInfo.Base, class, classMetatable, ...)
				constructMembers()
			end
		else
			ConstructionHandler.ConstructClass(typeInfo.Base, class, classMetatable)
			constructMembers()
		end
	else
		constructMembers()
	end

	if typeInfo.HasConstructor then
		if baseFunc then
			typeInfo.MetaMethods.__init(class, baseFunc, ...)
		else
			typeInfo.MetaMethods.__init(class, ...)
		end
	end
end

---@param typeInfo Utils.new.Class.Type
---@param data table
---@return Utils.new.Class template
function ConstructionHandler.ConstructTemplate(typeInfo, data)
	Table.Clear(data)

	local metatable = MetatableHandler.CreateTemplateMetatable(typeInfo)
	metatable.__call = construct

	return setmetatable(data, metatable)
end

return ConstructionHandler
