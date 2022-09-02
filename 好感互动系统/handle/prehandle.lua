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
    --! 强制阅读协议注册，一天提醒一次
    if getUserConf(msg.fromQQ, "isRegister", 0) == 0 then
        if getUserToday(msg.fromQQ, "registerNotice", 0) == 0 then
            setUserToday(msg.fromQQ, "registerNotice", 1)
            return "检测到您还未激活好感系统...\n请前往https://rainchain-zero.github.io/JasmineDoc/promise/阅读茉莉协议并查看激活指令"
        else
            return ""
        end
    end
    -- 打工终止
    if (JudgeWorking(msg)) then
        return "『✖Error』“打工期间不准调情！”你就这样被常青抓了个正着（打工期间无法进行喂食以及交互）"
    end
    -- 道具附加好感
    AddFavor_Item(msg)
    -- 道具附加亲和度
    AddAffinity_Item(msg)
    -- 版本通告处
    --Notice(msg)
    -- ! 好感时间惩罚
    FavorPunish(msg)
    -- 信任度和亲和度关联
    TrustChange(msg)
    CohesionChange(msg)
    -- 剧情解锁提示
    StoryUnlocked(msg)
end

-- 打工状态判断
function JudgeWorking(msg)
    local work = GetUserConf("favorConf", msg.fromQQ, "work", {["working"] = false})
    if (work["working"] == true) then
        -- 未进入打工状态
        -- 已经结束了打工
        if (os.time() > work["ddl"] or 0) then
            -- 处于工作状态
            SetUserConf("itemConf", msg.fromQQ, "fl", GetUserConf("itemConf", msg.fromQQ, "fl", 0) + work["profit"])
            work["working"] = false
            SetUserConf("favorConf", msg.fromQQ, "work", work)
            sendMsg(
                "[CQ:at,qq=" .. msg.fromQQ .. "]『✔提示』打工已经完成！\n夜渐渐深了，你伸了个懒腰，叫上茉莉准备下班\n收益：" .. work["profit"] .. "fl",
                msg.fromGroup,
                msg.fromQQ
            )
            return false
        else
            return true
        end
    else
        return false
    end
end
-- 调整信任度和亲和度
function TrustChange(msg)
    local favor, trust = GetUserConf("favorConf", msg.fromQQ, {"好感度", "trust"}, {0, 0})
    local admin_judge = msg.fromQQ ~= "2677409596" and msg.fromQQ ~= "3032902237" and msg.fromQQ ~= "959686587"
    -- 关联信任度
    if (admin_judge) then
        if (favor < 1000) then
            if (trust == 0) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 0", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust", 0)
        elseif (favor < 3000) then
            if (trust == 1) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 1", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust", 1)
        elseif (favor < 5000) then
            if (trust == 2) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 2", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust", 2)
        else
            if (trust == 3) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 3", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust", 3)
        end
    end
end

-- 调整亲密度
function CohesionChange(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local isStory0Read, isShopUnlocked, story2Choice, isStory3Read =
        GetUserConf(
        "storyConf",
        msg.fromQQ,
        {"isStory0Read", "isShopUnlocked", "story2Choice", "isStory3Read"},
        {0, 0, 0, 0}
    )
    if (favor < 1000) then
        SetUserConf("favorConf", msg.fromQQ, "cohesion", 0)
    elseif (favor < 2000) then
        if (isStory0Read == 1) then
            -- 通过第一章且好感度达到1000
            SetUserConf("favorConf", msg.fromQQ, "cohesion", 1)
        end
    elseif (favor < 3000) then
        if (isShopUnlocked == 1) then
            SetUserConf("favorConf", msg.fromQQ, "cohesion", 2)
        end
    elseif (favor < 4000) then
        if (story2Choice ~= 0) then
            SetUserConf("favorConf", msg.fromQQ, "cohesion", 3)
        end
    else
        if isStory3Read == 1 then
            SetUserConf("favorConf", msg.fromQQ, "cohesion", 4)
        end
    end
end

function Notice(msg)
    local favorUVersion = GetUserConf("favorConf", msg.fromQQ, "favorVersion", 0)
    -- 修改版本号只需要将下面的数字修改为目前的版本号即可
    if (favorUVersion ~= 47) then
        SetUserConf("favorConf", msg.fromQQ, {"noticeQQ", "favorVersion"}, {0, 47})
    end
    local noticeQQ = GetUserConf("favorConf", msg.fromQQ, "noticeQQ", 0)
    if (msg.fromGroup == "0" and noticeQQ == 0) then
        noticeQQ = noticeQQ + 1
        local content =
            "【好感互动模块V4.7更新通告】本次为茉莉412生日的更新。更新内容可以在空间找到，\n文档:https://rainchain-zero.github.io/JasmineDoc/diary"
        SetUserConf("favorConf", msg.fromQQ, "noticeQQ", noticeQQ)
        sendMsg(content, 0, msg.fromQQ)
    end
    noticeQQ = GetUserConf("favorConf", msg.fromQQ, "noticeQQ", 0)
    if (msg.fromGroup ~= "0") then
        if (noticeQQ == 0) then
            noticeQQ = noticeQQ + 1
            local content =
                "【好感互动模块V4.7更新通告】本次为茉莉412生日的更新。更新内容可以在空间找到，\n文档:https://rainchain-zero.github.io/JasmineDoc/diary"
            SetUserConf("favorConf", msg.fromQQ, "noticeQQ", noticeQQ)
            sendMsg(content, msg.fromGroup, msg.fromQQ)
        end
    end
end

-- 每天道具增加的附加好感度
function AddFavor_Item(msg)
    local favor_change = 0
    local favor_ori, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
    local addFavorItem, addFavorEveryDay, addFavorEveryAction = {}, "", ""
    -- 袋装曲奇
    if (os.time() < GetUserConf("adjustConf", msg.fromQQ, "addFavorDDL_Cookie", 0)) then
        addFavor = "Cookie"
        if (GetUserToday(msg.fromQQ, "addFavor_Cookie", 0) == 0) then
            favor_change = favor_change + ModifyFavorChangeGift(msg, favor_ori, 20, affinity)
            SetUserToday(msg.fromQQ, "addFavor_Cookie", 1)
        end
    elseif (GetUserConf("adjustConf", msg.fromQQ, "addFavorDDLFlag_Cookie", 1) == 0) then
        sendMsg("注意，您的『袋装曲奇』道具效果已消失", msg.fromGroup, msg.fromQQ)
        -- 更新标记，下次不做提醒
        SetUserConf("adjustConf", msg.fromQQ, "addFavorDDLFlag_Cookie", 1)
    end
    -- SetUserConf("favorConf", msg.fromQQ, "好感度", GetUserConf("favorConf", msg.fromQQ, "好感度", 0) + favor_change)
    CheckFavor(msg.fromQQ, favor_ori, favor_change + favor_ori, affinity)
    -- 返回正在起效的道具表用户好感状态栏
    addFavorItem["addFavorEveryDay"] = addFavorEveryDay

    -- 检查每次交互增加好感的道具
    local hairpinDDL = GetUserConf("adjustConf", msg.fromQQ, "addFavorPerActionDDL_Hairpin", 0)
    if (os.time() < hairpinDDL) then
        addFavorEveryAction = "Hairpin"
    end
    addFavorItem["addFavorEveryAction"] = addFavorEveryAction
    return addFavorItem
end

-- 每天道具附带的亲和度
function AddAffinity_Item(msg)
    local addAffinityEveryDay, addAffinityEveryAction, affinity_change, addAffinityItem = "", "", 0, {}
    -- 寿司
    local sushiDDL, sushiDDLFlag =
        GetUserConf("adjustConf", msg.fromQQ, {"addAffinityDDL_Sushi", "addAffinityDDLFlag_Sushi"}, {0, 0})
    if (os.time() < sushiDDL) then
        addAffinityEveryDay = "Sushi"
        if (GetUserToday(msg.fromQQ, "addAffinity_Sushi", 0) == 0) then
            affinity_change = 2
            SetUserToday(msg.fromQQ, "addAffinity_Sushi", 1)
        end
    elseif (sushiDDLFlag == 0) then
        if (sushiDDL ~= 0) then
            sendMsg("注意，您的『寿司』道具效果已消失", msg.fromGroup, msg.fromQQ)
        end
        -- 更新标记，下次不做提醒
        SetUserConf("adjustConf", msg.fromQQ, "addAffinityDDLFlag_Sushi", 1)
    end
    local affinity_now = GetUserConf("favorConf", msg.fromQQ, "affinity", 0) + affinity_change
    if (affinity_now > 100) then
        affinity_now = 100
    end
    SetUserConf("favorConf", msg.fromQQ, "affinity", affinity_now)
    addAffinityItem["addAffinityEveryDay"] = addAffinityEveryDay
    addAffinityItem["addAffinityEveryAction"] = addAffinityEveryAction
    return addAffinityItem
end

-- 好感时间惩罚减免百分比计算
function FavorTimePunishDownRate(msg)
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
function FavorPunish(msg, show_favor)
    local favor, lastTime = GetUserConf("favorConf", msg.fromQQ, {"好感度", "lastTime"}, {0, os.time()})
    local time_table = os.date("*t", lastTime)
    local _year, _month, _day, _hour = time_table["year"], time_table["month"], time_table["day"], time_table["hour"]
    local isFavorTimePunishDown, isFavorTimePunish = false, false
    -- 初始时间记为编写该程序段的时间

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

    if (show_favor ~= true) then
        SetUserConf("favorConf", msg.fromQQ, "lastTime", os.time())
    end
    -- ! 好感度锁定列表
    if
        (msg.fromQQ == "318242040" or msg.fromQQ == "3272364628" or msg.fromQQ == "2908078197" or
            msg.fromQQ == "614671889")
     then
        return ""
    end
    --! 是否在回归保护期
    if (GetUserConf("favorConf", msg.fromQQ, "regression", {["protection"] = 0})["protection"] > os.time()) then
        return ""
    end
    if (favor <= 500) then
        return ""
    end
    local Llimit, Rlimit = 0, 0
    -- 分段降低好感
    -- 一天之内
    if (subday == 0) then
        -- 一天内 间隔小于15h
        if (subhour < 15) then
            --一天内  间隔大于15h
            Llimit, RLimit = 0, 0
        else
            if (favor < 8500 and favor > 2000) then
                Llimit, Rlimit = 30, 40
            elseif (favor >= 8500) then
                Llimit, Rlimit = 50, 60
            else
                Llimit, Rlimit = 20, 30
            end
        end
    elseif (subday <= 3) then
        if (subday == 1 and subhour <= -15) then
            Llimit, Rlimit = 0, 0
        else
            if (favor < 8500 and favor > 2000) then
                Llimit, Rlimit = 50 * math.log(2 * subday, 2), 60 * math.log(2 * subday, 2)
            elseif (favor >= 8500) then
                Llimit, Rlimit = 80 * math.log(2 * subday, 2), 90 * math.log(2 * subday, 2)
            else
                Llimit, Rlimit = 30 * math.log(2 * subday, 2), 35 * math.log(2 * subday, 2)
            end
        end
    elseif (subday <= 8) then
        Llimit, Rlimit = 160 * subday, 180 * subday
    else
        Llimit, Rlimit =
            720 + 200 * (subday - 5) * math.log(2 * (subday - 5), 2),
            780 + 225 * (subday - 5) * math.log(2 * (subday - 5), 2)
    end
    -- ! 道具减免
    local itemDownRate = 1 - FavorTimePunishDownRate(msg)
    if (itemDownRate < 1) then
        isFavorTimePunishDown = true
    end
    -- 将左右端点取整才可带入ranint
    Llimit, Rlimit = math.modf(Llimit), math.modf(Rlimit)
    if (Rlimit > 0) then
        isFavorTimePunish = true
    end
    local favor_down = math.modf(ranint(Llimit, Rlimit) * itemDownRate)
    if (favor - favor_down < 500) then
        favor_down = favor - 500
        favor = 500
    else
        favor = favor - favor_down
    end
    if (show_favor ~= true) then
        -- 一次降低好感超过200，获得回归标记
        if (favor_down < 200) then
            SetUserConf("favorConf", msg.fromQQ, "好感度", favor)
        else
            SetUserConf(
                "favorConf",
                msg.fromQQ,
                {"好感度", "regression"},
                {
                    favor,
                    {
                        ["favor_ori"] = favor + favor_down,
                        ["flag"] = true,
                        ["protection"] = os.time() + 2 * 24 * 60 * 60 --保护期两天
                    }
                }
            )
        end
    end
    -- 返回是否处于好感流逝状态，是否存在道具修正状态
    return isFavorTimePunish, isFavorTimePunishDown
end

-- 剧情模式解锁提示
function StoryUnlocked(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local storyUnlockedNotice,
        specialUnlockedNotice,
        isStory0Read,
        isSpecial0Read,
        isShopUnlocked,
        story2Choice,
        isSpecial1Read =
        GetUserConf(
        "storyConf",
        msg.fromQQ,
        {
            "storyUnlockedNotice",
            "specialUnlockedNotice",
            "isStory0Read",
            "isSpecial0Read",
            "isShopUnlocked",
            "story2Choice",
            "isSpecial1Read"
        },
        {"0000000000000000000000000", "0000000000000000000000000", 0, 0, 0, 0, 0}
    )
    local content, flag, res = "", "1", ""
    if (favor >= 1000 and GetUserConf("storyConf", msg.fromQQ, "isStory0Read", 0) == 0) then
        flag = string.sub(storyUnlockedNotice, 1, 1)
        if (flag == "1") then
            return ""
        end
        content = content .. "[CQ:at,qq=" .. msg.fromQQ .. "]\n" .. "『✔提示』剧情模式 序章『惊蛰』,已经解锁,输入“进入剧情 序章”可浏览剧情"
        res = "1" .. string.sub(storyUnlockedNotice, 2)
        SetUserConf("storyConf", msg.fromQQ, "storyUnlockedNotice", res)
    elseif (isSpecial0Read == 0 and favor >= 1500) then
        flag = string.sub(specialUnlockedNotice, 1, 1)
        if (flag == "1") then
            return ""
        end
        content = content .. "[CQ:at,qq=" .. msg.fromQQ .. "]\n" .. "『✔提示』剧情模式 元旦特典『预想此时应更好』,已经解锁,输入“进入剧情 元旦特典”可浏览剧情"
        res = "1" .. string.sub(specialUnlockedNotice, 2)
        SetUserConf("storyConf", msg.fromQQ, "specialUnlockedNotice", res)
    elseif (isStory0Read == 1 and favor >= 2000 and isShopUnlocked == 0) then
        flag = string.sub(storyUnlockedNotice, 2, 2)
        if (flag == "1") then
            return ""
        end
        content = content .. "[CQ:at,qq=" .. msg.fromQQ .. "]\n" .. "『✔提示』剧情模式 第一章『夜未央』,已经解锁,输入“进入剧情 第一章”可浏览剧情"
        res = string.sub(storyUnlockedNotice, 1, 1) .. "1" .. string.sub(storyUnlockedNotice, 3)
        SetUserConf("storyConf", msg.fromQQ, "storyUnlockedNotice", res)
    elseif (isShopUnlocked == 1 and favor >= 3000 and story2Choice == 0) then
        flag = string.sub(storyUnlockedNotice, 3, 3)
        if (flag == "1") then
            return ""
        end
        content = content .. "[CQ:at,qq=" .. msg.fromQQ .. "]\n" .. "『✔提示』剧情模式 第二章『难以言明的选择』,已经解锁,输入“进入剧情 第二章”可浏览剧情"
        res = string.sub(storyUnlockedNotice, 1, 2) .. "1" .. string.sub(storyUnlockedNotice, 4)
        SetUserConf("storyConf", msg.fromQQ, "storyUnlockedNotice", res)
    elseif story2Choice ~= 0 and favor >= 4000 then
        flag = string.sub(storyUnlockedNotice, 4, 4)
        if (flag == "1") then
            return ""
        end
        content = content .. "[CQ:at,qq=" .. msg.fromQQ .. "]\n" .. "『✔提示』剧情模式 第三章『此般景致』,已经解锁,输入“进入剧情 第三章”可浏览剧情"
        res = string.sub(storyUnlockedNotice, 1, 3) .. "1" .. string.sub(storyUnlockedNotice, 5)
        SetUserConf("storyConf", msg.fromQQ, "storyUnlockedNotice", res)
    elseif isSpecial1Read == 0 and favor >= 3500 then
        flag = string.sub(specialUnlockedNotice, 2, 2)
        if (flag == "1") then
            return ""
        end
        content = content .. "[CQ:at,qq=" .. msg.fromQQ .. "]\n" .. "『✔提示』剧情模式 七夕特典『近在咫尺的距离』限时开放,输入“进入剧情 七夕特典”可浏览剧情"
        res = string.sub(storyUnlockedNotice, 1, 1) .. "1" .. string.sub(storyUnlockedNotice, 3)
        SetUserConf("storyConf", msg.fromQQ, "specialUnlockedNotice", res)
    end
    sendMsg(content, msg.fromGroup, msg.fromQQ)
end

-- 动作类交互预处理
function Actionprehandle(str)
    local list = {"抱", "摸", "举高", "亲", "牵手", "捏", "揉", "可爱", "萌", "kawa", "喜欢", "suki", "爱", "love", "贴贴"}
    for _, v in pairs(list) do
        if (string.find(str, v) ~= nil) then
            return true
        end
    end
    return false
end
