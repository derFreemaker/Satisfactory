local Controller = {}
Controller.__index = Controller

function Controller.new(ipAddress, name, category)
    local instance = setmetatable({
        IPAddress = ipAddress,
        Name = name,
        Category = category
    }, Controller)
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