Utils = {}
Utils.__index = Utils

function Utils.Sleep(ms)
    if type(ms) ~= "number" then error("ms was not a number", 1) end
    local startTime = millis()
    local endTime = startTime + ms
    while startTime >= endTime do end
end