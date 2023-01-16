local ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

ModuleLoader.modules = {}

function ModuleLoader:Load(libName, libPath)
    for id, _ in pairs(self.modules) do
        if id == libName then return end
    end

    self.modules[libName] = require(libPath)
end

function ModuleLoader:GetModule(moduleNameToLoad)
    for moduleName, module in pairs(self.modules) do
        if moduleName == moduleNameToLoad then
            return module
        end
    end
end

return ModuleLoader