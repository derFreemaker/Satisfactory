local Controller = {}
Controller.__index = Controller

function Controller.new(ipAddress, name, category, factoryControlApiClient)
    return setmetatable({
        IPAddress = ipAddress,
        Name = name,
        Category = category,
        FactoryControlApiClient = factoryControlApiClient
    }, Controller)
end

function Controller.newWithExtractedData(extractData, factoryControlApiClient)
    local instance = setmetatable(extractData, Controller)
    instance.FactoryControlApiClient = factoryControlApiClient
    return instance
end

function Controller:extractData()
    return {
        IPAddress = self.IPAddress,
        Name = self.Name,
        Category = self.Category
    }
end

return Controller