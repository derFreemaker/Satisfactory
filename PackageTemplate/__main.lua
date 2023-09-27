---@class Template.Main : Github_Loading.Entities.Main
local Main = {}

function Main:Configure()
	print('called configure')
end

function Main:Run()
	print('called run')
end

return Main
