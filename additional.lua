msg_order = {}
Trade_order = "禁言"
function test(msg)
    if (msg.fromQQ == "3032902237") then
        local QQ, time = string.match(msg.fromMsg,
                                      "[%s]*[%[CQ:at,qq=]*(%d*)[%]]*[%s]*(%d*)",
                                      #Trade_order + 1)
        if (QQ == nil or QQ == "") then
            return "{nick} 请告诉茉莉目标是哪位小朋友哦~"
        end
        eventMsg(".group ban " .. QQ .. " " .. time, msg.fromGroup, "2677409596") -- 21雾见漫研社
    end
end
msg_order[Trade_order] = "test"

function picture(msg)
    return "[CQ:image,url=" .. picture_api[ranint(1, #picture_api)] .. "]"
end
msg_order["来点二次元"] = "picture"

picture_api = {
    [1] = "https://iw233.cn/api/Random.php",
    [2] = "http://random.firefliestudio.com",
    [3] = "https://acg.toubiec.cn/random.php",
    [4] = "https://www.dmoe.cc/random.php",
    [5] = "https://api.ixiaowai.cn/api/api.php"
}

function Override_rh()
    return
        "Warning:暗骰已被认定为危险指令，已被管理员临时锁定！"
end
msg_order[".rh"] = "Override_rh"
msg_order[". rh"] = "Override_rh"
msg_order[".h"] = "Override_rh"
msg_order[". h"] = "Override_rh"
msg_order["! h"] = "Override_rh"
msg_order["! rh"] = "Override_rh"
msg_order[".  rh"] = "Override_rh"
msg_order[".  h"] = "Override_rh"
msg_order["!  h"] = "Override_rh"
msg_order["!  rh"] = "Override_rh"
msg_order["!h"] = "Override_rh"

function setfavor(msg)
    local first, second = "", string.match(msg.fromMsg,
                                           "^[%s]*[%d]*[%s]*[%d]*$",
                                           #admin_order1 + 1)
    if (second == "") then return "茉莉无法解析您的指令哦" end
    first, second = string.match(second, "^[%d]*"), string.match(second,
                                                                 "^[%d]*",
                                                                 string.find(
                                                                     second, " ") +
                                                                     1)
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ ==
        "2225336268") then
        setUserConf(first, "好感度", second * 1)
        return "权限确认：已将目标好感度设置为" .. second
    end
end
admin_order1 = "设置好感 "
msg_order[admin_order1] = "setfavor"
function show_favor(msg)
    local favor = getUserConf(msg.fromQQ, "好感度", 0)
    -- trust关联
    if (favor < 3000) then
        return "对{nick}的好感度只有" .. favor ..
                   "，要加油哦，茉莉...可是很期待{sample:我们之间能发生什么故事的哦？|你的表现的哦？|你能...（摇头），不，不，没什么|的哦，可这次...茉莉能做好吗}"
    elseif (favor < 6000) then
        return "对{nick}的好感度有" .. favor ..
                   "，{sample:还真是发生了不少事情呢，对吧？~|茉莉要好好记下和你在一起的点点滴滴|最近对茉莉的照顾...我很感激...能不能...}"
    elseif (favor < 10000) then
        return "好感度到" .. favor ..
                   "了，{sample:有时候我会想，说不定真能...嗯嗯？没，我什么都没说，对吧对吧|你总能给茉莉带来很多快乐呢|最近茉莉总有点心神不宁...算了不想了，反正和你在一起就好啦~}"
    else
        return "对{nick}的好感度已经有" .. favor ..
                   "了，以后也要永远在一起哦，{sample:真是的...明明...还要确认一下感情吗（嘟嘴）|茉莉当初没有想到，你会一直 一直陪在茉莉身边...|茉莉觉得，只要和你一直走下去，一定能抓住属于我们的未来的吧？|遇见你之后，我才明白，原来回忆是这么让人快乐和温暖的事|那些独自做不到的事，就让我们一起来把握吧|总感觉，只有和你在一起，茉莉才能看到曾经看不见的『可能性』呢}"
    end
end
msg_order["茉莉好感"] = "show_favor"
