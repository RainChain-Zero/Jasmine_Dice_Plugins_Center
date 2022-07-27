msg_order = {}

package.path = getDiceDir() .. "/plugin/IO/?.lua"
Json = require "json"

function draw(msg)
    if (msg.fromGroup ~= "921454429" and msg.fromGroup ~= "1007561501" and msg.fromGroup ~= "384144009") then
        return ""
    end
    if msg.fromMsg == "end" then
        setGroupConf(msg.fromGroup, "100questionsAnswerNow", 0)
        return "嗯嗯，感谢" ..
            getUserConf(msg.fromQQ, "nick", getGroupConf(msg.fromGroup, "100questionsQQ", "0")) .. "的精彩回答!!"
    end
    if (msg.fromMsg == "终止问答" and getGroupConf(msg.fromGroup, "100questionsQQ", "0") ~= "0") then
        setGroupConf(msg.fromGroup, "100questionsQQ", "0")
        setGroupConf(msg.fromGroup, "100questionsAnswerNow", 0)
        return "本次问答已结束"
    end
    -- 上一位未回答结束
    if (getGroupConf(msg.fromGroup, "100questionsAnswerNow", 0) == 1) then
        return "请耐心等待上一位回答结束哦~"
    end
    local reply = read_item()
    setGroupConf(msg.fromGroup, "100questionsQQ", msg.fromQQ)
    -- 标记现在正在回答
    setGroupConf(msg.fromGroup, "100questionsAnswerNow", 1)
    return reply[ranint(1, #reply)]
end
msg_order[".q"] = "draw"
msg_order[".Q"] = "draw"
msg_order["end"] = "draw"
msg_order["终止问答"] = "draw"

function add_question(msg)
    local item = string.match(msg.fromMsg, "[%s]*(.+)", #(".add q") + 1)
    if not item then
        return "请输入要添加的问题哦~"
    end
    local f = assert(io.open(getDiceDir() .. "/plugin/data/100question/100question.json", "r"))
    local str = f:read("a")
    f:close()
    local j = Json.decode(str)
    table.insert(j, item)
    f = assert(io.open(getDiceDir() .. "/plugin/data/100question/100question.json", "w"))
    f:write(Json.encode(j))
    f:close()
    return "问题添加成功！"
end
msg_order[".add q"] = "add_question"

function read_item()
    local f = assert(io.open(getDiceDir() .. "/plugin/data/100question/100question.json", "r"))
    local str = f:read("a")
    f:close()
    local j = Json.decode(str)
    return j
end
