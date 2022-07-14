local args = {...}
--[[
local files = {
    Class = "t8Dr3Ne0",
    BasicTaskModule = "a3b0XDAs",
    TurtleStripMining = "PjsfaaBL",
    TurtleTreeCutting = "a5XfhuLV"
}
]]--
 
for fileName, pastebinId in pairs(args) do 
    if fs.exists(fileName) then 
        fs.delete(fileName)
    end
    shell.execute("pastebin","get", pastebinId, fileName)
end