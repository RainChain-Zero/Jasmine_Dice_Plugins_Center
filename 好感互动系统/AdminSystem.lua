package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"

msg_order = {}

function setfavor(msg)
    local first, second = "", ""
    first, second = string.match(msg.fromMsg, "^[%s]*(%d*)[%s]*(%d*)$", #admin_order1 + 1)
    if (first == "" or second == "") then
        return "请输入正确的参数×"
    end
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        SetUserConf("favorConf", first, "好感度", second * 1)
        return "权限确认：已将目标好感度设置为" .. second
    end
end
admin_order1 = "设置好感"
msg_order[admin_order1] = "setfavor"

function reset_food(msg)
    local QQ = string.match(msg.fromMsg, "%d*", #admin_order3 + 1)
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        SetUserToday(QQ, "gifts", 0)
        return "权限确认:已重置目标今日喂食数"
    end
end
admin_order3 = "重置喂食 "
msg_order[admin_order3] = "reset_food"

admin_order4 = "查看好感 "
function favor_history(msg)
    local QQ = string.match(msg.fromMsg, "%d*", #admin_order4 + 1)
    local favor, cohesion, affinity = GetUserConf("favorConf", QQ, {"好感度", "cohesion", "affinity"}, {0, 0, 0})
    if
        (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268" or
            msg.fromQQ == "2595928998" or
            msg.fromQQ == "839968342" or
            msg.fromQQ == "751766424")
     then
        return "目标好感度为" ..
            string.format("%.0f", favor) ..
                "\n亲密度为" .. string.format("%.0f", cohesion) .. "\n亲和力为" .. string.format("%.0f", affinity)
    end
end
msg_order[admin_order4] = "favor_history"

admin_order5 = "发送 "
function sendmsg(msg)
    local strtemp = string.match(msg.fromMsg, "^(.*)$", #admin_order5 + 1)
    local group = string.match(strtemp, "%d*")
    local message = string.match(strtemp, " (.*)")
    sendMsg(message, group, 3032902237)
end
msg_order[admin_order5] = "sendmsg"

admin_order6 = "群通告次数 "
function setNoticeGroup(msg)
    local strtemp = string.match(msg.fromMsg, "^(.*)$", #admin_order6 + 1)
    local group = string.match(strtemp, "%d*")
    local num = string.match(strtemp, " %d*")
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        SetGroupConf(group, "notice", num)
        return "权限确认：已设置该群聊本版本通告次数为" .. string.format("%.0f", num)
    end
end
msg_order[admin_order6] = "setNoticeGroup"

admin_order7 = "个人通告次数 "
function setNoticePerson(msg)
    local strtemp = string.match(msg.fromMsg, "^(.*)$", #admin_order7 + 1)
    local QQ = string.match(strtemp, "%d*")
    local num = string.match(strtemp, " %d*")
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        SetUserConf("favorConf", QQ, "noticeQQ", num * 1)
        return "权限确认：已设置目标本版本通告次数为" .. num
    end
end
msg_order[admin_order7] = "setNoticePerson"

admin_order8 = "设置亲和 "
function setAffinity(msg)
    local first, second = "", ""
    first, second = string.match(msg.fromMsg, "^[%s]*(%d*)[%s]*(%d*)$", #admin_order8 + 1)
    if (first == "" or second == "") then
        return "请输入正确的参数×"
    end
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        SetUserConf("favorConf", first, "affinity", second * 1)
        return "权限确认：已将目标亲和度设置为" .. second
    end
end
msg_order[admin_order8] = "setAffinity"

function calibration_show(msg)
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596") then
        return "当前校准值为——" .. calibration .. ";校准上限为——" .. calibration_limit
    end
end
msg_order["当前校准"] = "calibration_show"

admin_order11 = "重置交互 "
function resetInteraction(msg)
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596") then
        local QQ = string.match(msg.fromMsg, "%d*", #admin_order11 + 1)
        SetUserToday(
            QQ,
            {
                "rude",
                "sorry",
                "hug",
                "touch",
                "hug_needed_to_sorry",
                "lift",
                "kiss",
                "hand",
                "face",
                "suki",
                "love"
            },
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
        )
        return "权限确认：已重置目标当日交互次数"
    end
end
msg_order[admin_order11] = "resetInteraction"
