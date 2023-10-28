filesystem.initFileSystem('/dev')
local drive = ''
for _, child in pairs(filesystem.childs('/dev')) do
    if not (child == 'serial') then
        drive = child
        break
    end
end
if drive:len() < 1 then
    computer.beep(0.2)
    error('Unable to find filesystem to load on! Insert a drive or floppy.')
    return
end
filesystem.mount('/dev/' .. drive, '/')

local dirPath = "/Long/Long/Long/Long/Long/Long/Long/Long/Long/Long"
    .. "/Long/Long/Long/Long/Long/Long/Long/Long/Long/Long"
    .. "/Long/Long/Long/Long/Long/Long/Long/Long/Long/Long/File/"

filesystem.createDir(dirPath, true)
local file = filesystem.open(dirPath .. "Path.txt", "w")
file:write("foo")
file:close()
