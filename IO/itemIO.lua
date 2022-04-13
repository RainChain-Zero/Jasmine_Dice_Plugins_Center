package.path = getDiceDir() .. "/plugin/IO/?.lua"
Json = require "json"

function ReadItem()
    local f=assert(io.open(getDiceDir().."/plugin/ReplyAndDescription/item.json","r"))
    local str=f:read("a")
    f:close()
    local j=Json.decode(str)
    return j
end