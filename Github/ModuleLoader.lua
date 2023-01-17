ModuleLoader = {}
ModuleLoader.__index = {}

ModuleLoader.libs = {}

function ModuleLoader:GetModule(moduleNameToLoad, path)
    for moduleName, module in pairs(self.libs) do
        if moduleName == moduleNameToLoad then
            return module
        end
    end
    local module = filesystem.doFile(path)
    self.libs[moduleNameToLoad] = module
    return module
end