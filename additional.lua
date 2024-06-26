package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"
msg_order = {}

function restart_qsign(msg)
    if msg.gid == 921454429 then
        http.post("http://lt51.mccn.pro:205/close_process")
        return "正在重启签名服务器...请等待十几秒后重试"
    end
end
msg_order["/重启签名"] = "restart_qsign"

Trade_order = "禁言"
function Mute(msg)
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596") then
        local QQ, time = string.match(msg.fromMsg, "[%s]*[%[CQ:at,qq=]*(%d*)[%]]*[%s]*(%d*)", #Trade_order + 1)
        if (QQ == nil or QQ == "") then
            return "{nick} 请告诉茉莉目标是哪位小朋友哦~"
        end
        eventMsg(".group ban " .. QQ .. " " .. time, msg.gid, "2677409596")
    end
end
msg_order[Trade_order] = "Mute"

function Kick(msg)
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596") then
        local QQ = string.match(msg.fromMsg, "[%s]*[%[CQ:at,qq=]*(%d*)[%]]*", #Trade_order + 1)
        if (QQ == nil or QQ == "") then
            return "{nick} 请告诉茉莉目标是哪位小朋友哦~"
        end
        eventMsg(".group kick " .. QQ, msg.gid, "2677409596")
    end
end
msg_order["#移除"] = "Kick"

function Nn(msg)
    if msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" then
        local qq = string.match(msg.fromMsg, "(%d+)")
        eventMsg(".nn", msg.gid, qq)
    end
end
msg_order["#nn"] = "Nn"

function picture(msg)
    if (GetUserConf("favorConf", msg.fromQQ, "好感度", 0) < 1000) then
        return "『✖条件未满足』此功能需要好感度≥1000"
    end
    local num = string.match(msg.fromMsg, "%d+")
    if (num == nil or num == "") then
        num = 1
    end
    num = num * 1
    if (num > 6) then
        return "『✖参数超限』一次不能超过6张哦~"
    end
    local reply = ""
    while (num > 0) do
        reply = reply .. "[CQ:image,url=" .. picture_api[ranint(1, #picture_api)] .. "]"
        if (num > 1) then
            reply = reply .. "\f"
        end
        num = num - 1
    end
    return reply
end
msg_order["来点二次元"] = "picture"

picture_api = {
    [1] = "http://random.firefliestudio.com",
    [2] = "https://www.dmoe.cc/random.php",
    [3] = "https://api.vvhan.com/api/acgimg",
    [4] = "https://img.xjh.me/random_img.php",
    [5] = "https://api.ghser.com/random/api.php",
    [6] = "https://api.yimian.xyz/img"
}

function http_cat(msg)
    local code = string.match(msg.fromMsg, "(%d+)")
    if not code then
        return "请输入正确的http状态码"
    end
    return "[CQ:image,url=https://http.cat/" .. code .. "]"
end
msg_order["/httpcat"] = "http_cat"

function start_trpg(msg)
end
