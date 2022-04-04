---@diagnostic disable: lowercase-global
--[[
    @author RainChain-Zero
    @version 1.0
    @Created 2022/04/02 23:26
    @Last Modified 2022/04/03 16:44
    ]]
-- 各条交互前预处理
function preHandle(msg)
    -- 强制更新提示信息
    -- sendMsg("紧急维护，暂停服务！",msg.fromGroup,msg.fromQQ)
    -- os.exit()

    -- 道具附加的额外好感追加
    AddFavor_Item(msg)
    -- 版本通告处
    Notice(msg)
    -- ! 好感时间惩罚
    FavorPunish(msg)
    -- 信任度和亲和度关联
    TrustChange(msg)
    -- 剧情解锁提示
    StoryUnlocked(msg)
end

-- 调整信任度和亲和度
function TrustChange(msg)
    local favor, trust_flag = GetUserConf("favorConf", msg.fromQQ, {"好感度", "trust_flag"}, {0, 0})
    local isStory0Read, isShopUnlocked =
        GetUserConf("storyConf", msg.fromQQ, {"isStory0Read", "isShopUnlocked"}, {0, 0})
    local admin_judge = msg.fromQQ ~= "2677409596" and msg.fromQQ ~= "3032902237"
    -- 关联信任度
    if (admin_judge) then
        if (favor < 1000) then
            if (trust_flag == 0) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 0", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust_flag", 0)
        elseif (favor < 3000) then
            if (trust_flag == 1) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 1", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust_flag", 1)
        elseif (favor < 5000) then
            if (trust_flag == 2) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 2", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust_flag", 2)
        else
            if (trust_flag == 3) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 3", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust_flag", 3)
        end
    end
    -- 调整亲密度
    if (favor < 1000) then
        SetUserConf("favorConf", msg.fromQQ, "cohesion", 0)
    end
    if (favor > 1000) then
        if (isStory0Read == 1) then
            -- 通过第一章且好感度达到1000
            SetUserConf("favorConf", msg.fromQQ, "cohesion", 1)
        end
    end
    if (favor > 2000) then
        if (isShopUnlocked == 1) then
            SetUserConf("favorConf", msg.fromQQ, "cohesion", 2)
        end
    end
end

function Notice(msg)
    local favorVersion = GetGroupConf(msg.fromGroup, "favorVersion", 0)
    local favorUVersion = GetUserConf("favorConf", msg.fromQQ, "favorVersion", 0)
    -- 修改版本号只需要将下面的数字修改为目前的版本号即可
    if (favorUVersion ~= 46) then
        SetUserConf("favorConf", msg.fromQQ, {"noticeQQ", "favorVersion"}, {0, 46})
    end
    if (favorVersion ~= 46) then
        SetGroupConf(msg.fromGroup, {"favorVersion", "notice"}, {46, 0})
    end
    local notice = GetGroupConf(msg.fromGroup, "notice", 0)
    local noticeQQ = GetUserConf("favorConf", msg.fromQQ, "noticeQQ", 0)
    if (msg.fromGroup == "0" and noticeQQ == 0) then
        noticeQQ = noticeQQ + 1
        local content = "【好感互动模块V4.6更新通告】本次为4.12更新的预更新，大幅修改了好感机制，如有疑问请务必仔细阅读。\n文档:https://rainchain-zero.github.io/JasmineDoc/appendix/favormechanism.html"
        SetUserConf("favorConf", msg.fromQQ, "noticeQQ", noticeQQ)
        sendMsg(content, 0, msg.fromQQ)
    end
    noticeQQ = GetUserConf("favorConf", msg.fromQQ, "noticeQQ", 0)
    if (notice ~= nil) then
        if (notice <= 4 and noticeQQ == 0) then
            notice = notice + 1
            noticeQQ = noticeQQ + 1
            local content = "【好感互动模块V4.6更新通告】本次为4.12更新的预更新，大幅修改了好感机制，如有疑问请务必仔细阅读。\n文档:https://rainchain-zero.github.io/JasmineDoc/appendix/favormechanism.html"
            SetGroupConf(msg.fromGroup, "notice", notice)
            SetUserConf("favorConf", msg.fromQQ, "noticeQQ", noticeQQ)
            sendMsg(content, msg.fromGroup, msg.fromQQ)
        end
    end
end

-- 每次交互道具增加的附加好感度
function AddFavor_Item(msg)
    local favor_change = 0
    local favor_ori, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
    if (os.time() < GetUserConf("adjustConf", msg.fromQQ, "addFavorDDL_Cookie", 0)) then
        if (GetUserToday(msg.fromQQ, "addFavor_Cookie", 0) == 0) then
            favor_change = favor_change + 30
            SetUserToday(msg.fromQQ, "addFavor_Cookie", 1)
        end
    elseif (GetUserConf("adjustConf", msg.fromQQ, "addFavorDDLFlag_Cookie", 1) == 0) then
        sendMsg("注意，您的『袋装曲奇』道具效果已消失", msg.fromGroup, msg.fromQQ)
        -- 更新标记，下次不做提醒
        SetUserConf("adjustConf", msg.fromQQ, "addFavorDDLFlag_Cookie", 1)
    end
    SetUserConf("favorConf", msg.fromQQ, "好感度", GetUserConf("favorConf", msg.fromQQ, "好感度", 0) + favor_change)
    CheckFavor(msg.fromQQ, favor_ori, favor_change + favor_ori, affinity)
end

-- 好感时间惩罚减免百分比计算
function favorTimePunishDownRate(msg)
    if (os.time() < GetUserConf("adjustConf", msg.fromQQ, "favorTimePunishDownDDL", 0)) then
        return GetUserConf("adjustConf", msg.fromQQ, "favorTimePunishDownRate", 0)
    elseif (GetUserConf("adjustConf", msg.fromQQ, "favorTimePunishDownDDLFlag", 1) == 0) then
        sendMsg("注意，您的好感度时间惩罚减免道具效果已消失", msg.fromGroup, msg.fromQQ)
        -- 更新标记，下次不做提醒
        SetUserConf("adjustConf", msg.fromQQ, {"favorTimePunishDownDDLFlag", "favorTimePunishDownRate"}, {1, 0})
    end
    return 0
end

-- 一定时间不交互将会降低好感度
function FavorPunish(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local flag = false
    -- 初始时间记为编写该程序段的时间
    local _year, _month, _day, _hour =
        GetUserConf(
        "favorConf",
        msg.fromQQ,
        {
            "year_last",
            "month_last",
            "day_last",
            "hour_last"
        },
        {2021, 10, 11, 23}
    )
    local subyear, subhour = year - _year, hour - _hour
    local subday
    -- ! 注意时间的计算方式

    if (subyear == 1) then
        subday = (12 - _month + month) * 30 + day - _day -- 跨年情况
    elseif (subyear == 0) then
        subday = (month - _month) * 30 + day - _day -- 时间段为本年
    else
        subday = 1000 -- 超过两年的直接设为1000天
    end

    SetUserConf("favorConf", msg.fromQQ, {"month_last", "day_last", "hour_last", "year_last"}, {month, day, hour, year})

    -- flag用于标记是否是从>500的favor降到500以下的
    if (favor >= 500) then
        flag = true
    else
        return "" -- 本身<500的用户不会触发
    end
    if (subday == 0) then
        return ""
    end

    -- ! 好感度锁定列表
    if
        (msg.fromQQ == "2720577231" or msg.fromQQ == "1550506144" or msg.fromQQ == "2908078197" or
            msg.fromQQ == "751766424")
     then
        return ""
    end
    local Llimit, Rlimit = 0, 0
    -- 分段降低好感
    if (subday <= 3) then
        if (subday == 1 and subhour <= -15) then
            return ""
        end
        if (favor < 8500 and favor > 1250) then
            Llimit, Rlimit = 80 * math.log(2 * subday, 2), 90 * math.log(2 * subday, 2)
        elseif (favor >= 8500) then
            Llimit, Rlimit = 90 * math.log(2 * subday, 2), 100 * math.log(2 * subday, 2)
        else
            Llimit, Rlimit = 30 * math.log(2 * subday, 2), 35 * math.log(2 * subday, 2)
        end
    elseif (subday <= 8) then
        Llimit, Rlimit = 160 * subday, 180 * subday
    else
        Llimit, Rlimit =
            720 + 200 * (subday - 5) * math.log(2 * (subday - 5), 2),
            780 + 225 * (subday - 5) * math.log(2 * (subday - 5), 2)
    end
    --
    -- ! 道具减免
    Llimit, Rlimit = Llimit * (1 - favorTimePunishDownRate(msg)), Rlimit * (1 - favorTimePunishDownRate(msg))
    -- //todo 将左右端点取整才可带入ranint
    Llimit, Rlimit = math.modf(Llimit), math.modf(Rlimit)
    favor = favor - ranint(Llimit, Rlimit)
    if (favor < 500 and flag == true) then
        favor = 500
    end
    SetUserConf("favorConf", msg.fromQQ, "好感度", favor)
end

-- 剧情模式解锁提示
function StoryUnlocked(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local storyUnlockedNotice, specialUnlockedNotice =
        GetUserConf(
        "storyConf",
        msg.fromQQ,
        {"storyUnlockedNotice", "specialUnlockedNotice"},
        {"0000000000000000000000000", "0000000000000000000000000"}
    )
    local content, flag, res = "", "1", ""
    if (favor >= 1000 and GetUserConf("storyConf", msg.fromQQ, "isStory0Read", 0) == 0) then
        flag = string.sub(storyUnlockedNotice, 1, 1)
        if (flag == "1") then
            return ""
        end
        if (msg.fromGroup ~= "0") then
            content = content .. "[CQ:at,qq=" .. msg.fromQQ .. "]\n"
        end
        content = content .. "『✔提示』剧情模式 序章,已经解锁,输入“进入剧情 序章”可浏览剧情"
        res = "1" .. string.sub(storyUnlockedNotice, 2)
        SetUserConf("storyConf", msg.fromQQ, "storyUnlockedNotice", res)
    elseif (favor >= 1500 and GetUserConf("storyConf", msg.fromQQ, "isSpecial0Read", 0) == 0) then
        flag = string.sub(specialUnlockedNotice, 1, 1)
        if (flag == "1") then
            return ""
        end
        content = content .. "『✔提示』剧情模式 元旦特典,已经解锁,输入“进入剧情 元旦特典”可浏览剧情"
        res = "1" .. string.sub(specialUnlockedNotice, 2)
        SetUserConf("storyConf", msg.fromQQ, "specialUnlockedNotice", res)
    elseif
        (GetUserConf("storyConf", msg.fromQQ, "isStory0Read", 0) == 1 and
            GetUserConf("storyConf", msg.fromQQ, "isShopUnlocked", 0) == 0)
     then
        flag = string.sub(storyUnlockedNotice, 2, 2)
        if (flag == "1") then
            return ""
        end
        if (msg.fromGroup ~= "0") then
            content = content .. "[CQ:at,qq=" .. msg.fromQQ .. "]\n"
        end
        content = content .. "『✔提示』剧情模式 第一章,已经解锁,输入“进入剧情 第一章”可浏览剧情"
        res = string.sub(storyUnlockedNotice, 1, 1) .. "1" .. string.sub(storyUnlockedNotice, 3)
        SetUserConf("storyConf", msg.fromQQ, "storyUnlockedNotice", res)
    --todo 第二章提示
    end
    sendMsg(content, msg.fromGroup, msg.fromQQ)
end
