local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]
local MetatableHandler,
metaMethods = table.unpack(LoadedLoaderFiles
	['/Github-Loading/Loader/Utils/Class/MetatableHandler'])
---@cast MetatableHandler Utils.Class.MetatableHandler
---@cast metaMethods table

---@class Utils.Class.ConstructionHandler
local ConstructionHandler = {}

---@param obj object
local function construct(obj, ...)
	---@type Utils.Class.Metatable
	local metatable = getmetatable(obj)
	local typeInfo = metatable.Type

	local class,
	classMetatable = {}, {}
	---@cast class table
	---@cast classMetatable Utils.Class.Metatable

	MetatableHandler.CreateMetatable(typeInfo, classMetatable)
	ConstructionHandler.ConstructClass(typeInfo, class, classMetatable, ...)

	table.insert(typeInfo.Instances, class)

	return class
end

---@param typeInfo Utils.Class.Type
---@param class table
---@param classMetatable Utils.Class.Metatable
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

---@param typeInfo Utils.Class.Type
---@param data table
function ConstructionHandler.ConstructTemplate(typeInfo, data)
	Table.Clear(data)

	typeInfo.Instances = setmetatable({}, { __mode = 'v' })

	local metatable = MetatableHandler.CreateTemplateMetatable(typeInfo)
	metatable.__call = construct

	data = setmetatable(data, metatable)
	typeInfo.Template = data
end

return ConstructionHandler
