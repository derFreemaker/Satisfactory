local LoadedLoaderFiles = ({ ... })[1]
---@type Utils.Table
local Table = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Table'][1]
---@type Utils.Class.MetatableHandler
local MetatableHandler = LoadedLoaderFiles['/Github-Loading/Loader/Utils/Class/MetatableHandler'][1]

---@class Utils.Class.Template

---@class Utils.Class.ConstructionHandler
local ConstructionHandler = {}

ConstructionHandler.SearchInBase = MetatableHandler.SearchInBase
ConstructionHandler.SetNormal = MetatableHandler.SetNormal

local function AddInstance(typeInfo, instance)
	if not typeInfo then
		return
	end

	table.insert(typeInfo.Instances, instance)

	AddInstance(typeInfo.Base, instance)
end

---@param obj object
---@return Utils.Class.Template template
local function construct(obj, ...)
	---@type Utils.Class.Metatable
	local metatable = getmetatable(obj)
	local typeInfo = metatable.Type

	local classInstance,
	classMetatable = {}, {}
	---@cast classInstance Utils.Class.Template
	---@cast classMetatable Utils.Class.Metatable

	MetatableHandler.CreateMetatable(typeInfo, classMetatable)
	ConstructionHandler.ConstructClass(typeInfo, classInstance, classMetatable, ...)

	AddInstance(typeInfo, classInstance)

	return classInstance
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
			if Table.ContainsKey(MetatableHandler.MetaMethods, key) then
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
