msg_order = {
    ["/排行榜"] = "ranking"
}

Json = require "json"

function ranking(msg)
    local name = string.match(msg.fromMsg, "/排行榜[%s]*(.+)")
    if not name then
        return '请输入"/排行榜 [排行榜名称]" 如"/排行榜 fl"、"/排行榜 好感度"'
    end
    local res, resp
    if name == "FL" or name == "fl" then
        res, resp = http.get("http://localhost:45445/getFlRank")
    elseif string.find(name, "好感") ~= nil then
        res, resp = http.get("http://localhost:45445/getFavorRank")
    end
    if not res then
        return "网络异常！"
    end
    resp = Json.decode(resp)
    if not resp.succ then
        return "服务器内部错误"
    end
    local rank, reply, num = resp.data, nil, 1
    if name == "FL" or name == "fl" then
        reply = "========FL排行榜========\n"
        for _, v in ipairs(rank) do
            reply =
                reply ..
                "NO." ..
                    tostring(num) .. " " .. getUserConf(v.qq, "name", "用户") .. "（" .. v.qq .. "）：" .. v.fl .. "FL\n"
            num = num + 1
        end
    elseif string.find(name, "好感") ~= nil then
        reply = "========好感度排行榜========\n"
        for _, v in ipairs(rank) do
            reply =
                reply ..
                "NO." ..
                    tostring(num) .. " " .. getUserConf(v.qq, "name", "用户") .. "（" .. v.qq .. "）：" .. v.favor .. "好感度\n"
            num = num + 1
        end
    end
    return reply
end
