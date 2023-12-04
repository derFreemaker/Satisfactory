local FileSystem = require("Tools.FileSystem")
local Parser = require("Tools.DocLuaParserBasic.Parser")

local inputFilePath = "C:\\Coding\\Games\\Satisfactory\\Tests\\ToMarkdownExample.lua"
local outputFilePath = "C:\\Coding\\Games\\Satisfactory\\Tests\\MarkdownExample.md"

local inputFile = FileSystem.OpenFile(inputFilePath, "r")

local content = inputFile:read("a")

local parser = Parser.new()

local context = parser:ParseStr(content)

print(context)
