filesystem.initFileSystem('/dev')
local drive = filesystem.childs('/dev')[1]
if not drive or drive:len() < 1 then
    computer.beep(0.2)
    error('Unable to find filesystem to load on! Insert a drive or floppy.')
    return
end
filesystem.mount('/dev/' .. drive, '/')

local file = filesystem.open("test.txt", "r")
file:seek("set", 3)
print(file:read(1))
file:close()
