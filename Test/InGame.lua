---@type FicsIt_Networks.Components.FINComputerMod.InternetCard_C
local internetCard = computer.getPCIDevices(findClass('FINInternetCard'))[1]
if not internetCard then
	computer.beep(0.2)
	error('No internet-card found!')
	return
end

print(internetCard:getHash())
