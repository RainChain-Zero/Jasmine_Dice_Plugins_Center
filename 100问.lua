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

remove_question_order = ".del q"
msg_order[remove_question_order] = "remove_question"
function remove_question(msg)
    local admin_qq = {
        "3032902237",
        "839968342",
        "751766424",
        "2595928998",
        "2677409596"
    }
    local question = string.match(msg.fromMsg, "[%s]*(.*)", #remove_question_order + 1) or ""
    for _, v in pairs(admin_qq) do
        if msg.fromQQ == v then
            local f = assert(io.open(getDiceDir() .. "/plugin/data/100question/100question.json", "r"))
            local str = f:read("a")
            f:close()
            local j = Json.decode(str)
            for i, v1 in pairs(j) do
                if v1 == question then
                    table.remove(j, i)
                    f = assert(io.open(getDiceDir() .. "/plugin/data/100question/100question.json", "w"))
                    f:write(Json.encode(j))
                    f:close()
                    return "问题删除成功！"
                end
            end
            return "未找到该问题！"
        end
    end
    return "你没有此操作的权限！"
end

function read_item()
    local f = assert(io.open(getDiceDir() .. "/plugin/data/100question/100question.json", "r"))
    local str = f:read("a")
    f:close()
    local j = Json.decode(str)
    return j
end
