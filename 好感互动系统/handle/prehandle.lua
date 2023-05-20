---@diagnostic disable: lowercase-global
-- 各条交互前预处理
function preHandle(msg)
    --! 强制阅读协议注册，一天提醒一次
    local register = check_register(msg)
    if register then
        return register
    end
    -- 打工终止
    if (JudgeWorking(msg)) then
        return "『✖Error』“打工期间不准调情！”你就这样被常青抓了个正着（打工期间无法进行喂食以及交互）"
    end
    -- 交互冷却
    local isFrequency = JudgeFrequency(msg)
    if isFrequency ~= nil then
        return isFrequency
    end
    -- 道具附加好感
    AddFavor_Item(msg)
    -- 道具附加亲和度
    AddAffinity_Item(msg)
    -- Notice(msg)
    -- ! 好感时间惩罚
    FavorPunish(msg)
    -- 信任度和亲和度关联
    TrustChange(msg)
    CohesionChange(msg)
    -- 剧情解锁提示
    StoryUnlocked(msg)
    -- 检测当前的任务
    check_mission(msg)
end

function check_register(msg)
    if getUserConf(msg.uid, "isRegister", 0) == 0 then
        if getUserToday(msg.uid, "registerNotice", 0) == 0 then
            setUserToday(msg.uid, "registerNotice", 1)
            return "检测到您还未激活好感系统...\n请前往https://rainchain-zero.github.io/JasmineDoc/promise/阅读茉莉协议并查看激活指令"
        end
    end
end
function JudgeFrequency(msg)
    local frequency = getUserToday(msg.uid, "frequency", {["lastTime"] = 0, ["count"] = 0})
    local DiceQQ = getDiceQQ()
    local frequency_bot = getUserToday(DiceQQ, "frequency", {["lastTime"] = 0, ["count"] = 0})
    -- 个人冷却时间
    if os.time() - frequency["lastTime"] < 10 then
        frequency["count"] = frequency["count"] + 1
        setUserToday(msg.uid, "frequency", {["lastTime"] = os.time(), ["count"] = frequency["count"]})
        setUserToday(DiceQQ, "frequency", {["lastTime"] = os.time(), ["count"] = frequency_bot["count"]})
        if frequency["count"] >= 3 then
            local favor, affinity = GetUserConf("favorConf", msg.uid, {"好感度", "affinity"}, {0, 0})
            SetUserConf(msg.uid, {"好感度", "affinity"}, {favor - 100, affinity - 20})
            return "您无视提醒，作为惩罚，您损失了100点好感和20点亲和度"
        end
        return "当前交互频率过高，请等待10s后再试哦~"
    else
        setUserToday(msg.uid, "frequency", {["lastTime"] = os.time(), ["count"] = 0})
        setUserToday(DiceQQ, "frequency", {["lastTime"] = os.time(), ["count"] = frequency_bot["count"]})
    end
    -- 全局冷却时间
    if os.time() - frequency_bot["lastTime"] < 7 then
        frequency_bot["count"] = frequency_bot["count"] + 1
        setUserToday(DiceQQ, "frequency", {["lastTime"] = os.time(), ["count"] = frequency_bot["count"]})
        if frequency_bot["count"] >= 2 then
            return "当前全局交互频率过高，系统繁忙，茉莉并没有理睬你"
        end
    else
        setUserToday(DiceQQ, "frequency", {["lastTime"] = os.time(), ["count"] = 0})
    end
end

-- 打工状态判断
function JudgeWorking(msg)
    local work = GetUserConf("favorConf", msg.uid, "work", {["working"] = false})
    if (work["working"] == true) then
        -- 未进入打工状态
        -- 已经结束了打工
        if (os.time() > (work["ddl"] or 0)) then
            -- 处于工作状态
            SetUserConf("itemConf", msg.uid, "fl", GetUserConf("itemConf", msg.uid, "fl", 0) + work["profit"])
            work["working"] = false
            SetUserConf("favorConf", msg.uid, "work", work)
            sendMsg(
                "[CQ:at,qq=" .. msg.uid .. "]『✔提示』打工已经完成！\n夜渐渐深了，你伸了个懒腰，叫上茉莉准备下班\n收益：" .. work["profit"] .. "fl",
                msg.gid or 0,
                msg.uid
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
    local favor, trust = GetUserConf("favorConf", msg.uid, {"好感度", "trust"}, {0, 0})
    local admin_judge =
        msg.uid ~= "2677409596" and msg.uid ~= "3032902237" and msg.uid ~= "959686587" and msg.uid ~= "2595928998" and
        msg.uid ~= "751766424" and
        msg.uid ~= "839968342"
    -- 关联信任度
    if (admin_judge) then
        if (favor < 500) then
            --eventMsg(".user trust " .. msg.uid .. " 0", 0, 2677409596)
            setUserConf(msg.uid, "trust", 0)
            SetUserConf("favorConf", msg.uid, "trust", 0)
        elseif (favor < 3000) then
            --eventMsg(".user trust " .. msg.uid .. " 1", 0, 2677409596)
            setUserConf(msg.uid, "trust", 1)
            SetUserConf("favorConf", msg.uid, "trust", 1)
        elseif (favor < 5000) then
            --eventMsg(".user trust " .. msg.uid .. " 2", 0, 2677409596)
            setUserConf(msg.uid, "trust", 2)
            SetUserConf("favorConf", msg.uid, "trust", 2)
        else
            --eventMsg(".user trust " .. msg.uid .. " 3", 0, 2677409596)
            setUserConf(msg.uid, "trust", 3)
            SetUserConf("favorConf", msg.uid, "trust", 3)
        end
    end
end

-- 调整亲密度
function CohesionChange(msg)
    local favor = GetUserConf("favorConf", msg.uid, "好感度", 0)
    local isStory0Read, isShopUnlocked, story2Choice, isStory3Read, isStory4Read =
        GetUserConf(
        "storyConf",
        msg.uid,
        {"isStory0Read", "isShopUnlocked", "story2Choice", "isStory3Read", "isStory4Read"},
        {0, 0, 0, 0, 0}
    )
    if (favor < 1000) then
        SetUserConf("favorConf", msg.uid, "cohesion", 0)
    end
    if (favor >= 1000 and isShopUnlocked ~= 1) then
        if (isStory0Read == 1) then
            -- 通过序章且好感度达到1000
            SetUserConf("favorConf", msg.uid, "cohesion", 1)
        end
    end
    if (favor >= 2000 and story2Choice == 0) then
        -- 通过第一章
        if (isShopUnlocked == 1) then
            SetUserConf("favorConf", msg.uid, "cohesion", 2)
        end
    end
    if (favor >= 3000 and isStory3Read == 0) then
        -- 通过第二章
        if (story2Choice ~= 0) then
            SetUserConf("favorConf", msg.uid, "cohesion", 3)
        end
    end
    if favor >= 4000 then
        if isStory4Read == 1 then
            SetUserConf("favorConf", msg.uid, "cohesion", 5)
        elseif isStory3Read == 1 then
            SetUserConf("favorConf", msg.uid, "cohesion", 4)
        end
    end
end

function Notice(msg)
    local favorUVersion = GetUserConf("favorConf", msg.uid, "favorVersion", 0)
    -- 修改版本号只需要将下面的数字修改为目前的版本号即可
    if (favorUVersion ~= 47) then
        SetUserConf("favorConf", msg.uid, {"noticeQQ", "favorVersion"}, {0, 47})
    end
    local noticeQQ = GetUserConf("favorConf", msg.uid, "noticeQQ", 0)
    if (not msg.gid and noticeQQ == 0) then
        noticeQQ = noticeQQ + 1
        local content =
            "【好感互动模块V4.7更新通告】本次为茉莉412生日的更新。更新内容可以在空间找到，\n文档:https://rainchain-zero.github.io/JasmineDoc/diary"
        SetUserConf("favorConf", msg.uid, "noticeQQ", noticeQQ)
        sendMsg(content, 0, msg.uid)
    end
    noticeQQ = GetUserConf("favorConf", msg.uid, "noticeQQ", 0)
    if (msg.gid) then
        if (noticeQQ == 0) then
            noticeQQ = noticeQQ + 1
            local content =
                "【好感互动模块V4.7更新通告】本次为茉莉412生日的更新。更新内容可以在空间找到，\n文档:https://rainchain-zero.github.io/JasmineDoc/diary"
            SetUserConf("favorConf", msg.uid, "noticeQQ", noticeQQ)
            sendMsg(content, msg.gid, msg.uid)
        end
    end
end

-- 每天道具增加的附加好感度
function AddFavor_Item(msg)
    local favor_change = 0
    local favor_ori, affinity = GetUserConf("favorConf", msg.uid, {"好感度", "affinity"}, {0, 0})
    local addFavorItem, addFavorEveryDay, addFavorEveryAction = {}, "", ""
    -- 袋装曲奇
    if (os.time() < GetUserConf("adjustConf", msg.uid, "addFavorDDL_Cookie", 0)) then
        addFavor = "Cookie"
        if (GetUserToday(msg.uid, "addFavor_Cookie", 0) == 0) then
            favor_change = favor_change + ModifyFavorChangeGift(msg, favor_ori, 20, affinity)
            SetUserToday(msg.uid, "addFavor_Cookie", 1)
        end
    elseif (GetUserConf("adjustConf", msg.uid, "addFavorDDLFlag_Cookie", 1) == 0) then
        sendMsg("注意，您的『袋装曲奇』道具效果已消失", msg.gid or 0, msg.uid)
        -- 更新标记，下次不做提醒
        SetUserConf("adjustConf", msg.uid, "addFavorDDLFlag_Cookie", 1)
    end
    if favor_change > 0 then
        CheckFavor(msg.uid, favor_ori, favor_change + favor_ori, affinity)
    end
    -- 返回正在起效的道具表用户好感状态栏
    addFavorItem["addFavorEveryDay"] = addFavorEveryDay

    -- 检查每次交互增加好感的道具
    local hairpinDDL = GetUserConf("adjustConf", msg.uid, "addFavorPerActionDDL_Hairpin", 0)
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
        GetUserConf("adjustConf", msg.uid, {"addAffinityDDL_Sushi", "addAffinityDDLFlag_Sushi"}, {0, 0})
    if (os.time() < sushiDDL) then
        addAffinityEveryDay = "Sushi"
        if (GetUserToday(msg.uid, "addAffinity_Sushi", 0) == 0) then
            affinity_change = 2
            SetUserToday(msg.uid, "addAffinity_Sushi", 1)
        end
    elseif (sushiDDLFlag == 0) then
        if (sushiDDL ~= 0) then
            sendMsg("注意，您的『寿司』道具效果已消失", msg.gid or 0, msg.uid)
        end
        -- 更新标记，下次不做提醒
        SetUserConf("adjustConf", msg.uid, "addAffinityDDLFlag_Sushi", 1)
    end
    local affinity_now = GetUserConf("favorConf", msg.uid, "affinity", 0) + affinity_change
    if (affinity_now > 100) then
        affinity_now = 100
    end
    SetUserConf("favorConf", msg.uid, "affinity", affinity_now)
    addAffinityItem["addAffinityEveryDay"] = addAffinityEveryDay
    addAffinityItem["addAffinityEveryAction"] = addAffinityEveryAction
    return addAffinityItem
end

-- 好感时间惩罚减免百分比计算
function FavorTimePunishDownRate(msg)
    if (os.time() < GetUserConf("adjustConf", msg.uid, "favorTimePunishDownDDL", 0)) then
        return GetUserConf("adjustConf", msg.uid, "favorTimePunishDownRate", 0)
    elseif (GetUserConf("adjustConf", msg.uid, "favorTimePunishDownDDLFlag", 1) == 0) then
        sendMsg("注意，您的好感度时间惩罚减免道具效果已消失", msg.gid or 0, msg.uid)
        -- 更新标记，下次不做提醒
        SetUserConf("adjustConf", msg.uid, {"favorTimePunishDownDDLFlag", "favorTimePunishDownRate"}, {1, 0})
    end
    return 0
end

-- 一定时间不交互将会降低好感度
function FavorPunish(msg, show_favor)
    local favor, lastTime = GetUserConf("favorConf", msg.uid, {"好感度", "lastTime"}, {0, os.time()})
    -- 测试群通告
    if favor >= 3000 and getUserConf(msg.uid, "testGroupNotice", 0) == 0 then
        local at = "[CQ:at,qq=" .. msg.uid .. "]"
        msg:echo(at .. "【重要通知】您的好感已达3000，为了保证您的正常使用，我们诚挚邀请您加入茉莉测试群（517343442）\n若有特殊情况&被冻结，将只在此群启用备用机。")
        setUserConf(msg.uid, "testGroupNotice", 1)
    end

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
        SetUserConf("favorConf", msg.uid, "lastTime", os.time())
    end

    -- 好感不流逝
    if isFavorSilent(msg, favor, show_favor) then
        return ""
    end

    local Llimit, Rlimit = 0, 0
    -- 分段降低好感
    -- 一天之内
    if (subday == 0) then
        -- 一天内 间隔小于15h
        if (subhour < 15) then
            Llimit, RLimit = 0, 0
        else
            --一天内  间隔大于15h
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
            720 + 100 * (subday - 5) * math.log(2 * (subday - 5), 2),
            780 + 120 * (subday - 5) * math.log(2 * (subday - 5), 2)
    end
    -- ! 道具减免
    local itemDownRate = 1 - FavorTimePunishDownRate(msg)
    if (itemDownRate < 1) then
        isFavorTimePunishDown = true
    end
    -- 将左右端点取整才可带入ranint
    Llimit, Rlimit = math.modf(Llimit), math.modf(Rlimit)
    local favor_down = ranint(Llimit, Rlimit) * itemDownRate
    if (favor_down > 0) then
        isFavorTimePunish = true
        local special_mood, coefficient = GetUserConf("favorConf", msg.uid, {"special_mood", "coefficient"}, {0, 0})
        coefficient = get_coefficient(special_mood, coefficient, {"开心", "焦虑"})
        favor_down = math.modf(favor_down * coefficient)
    end
    if favor_down > 1000 then
        favor_down = 1000
    end
    if (favor - favor_down < 500) then
        favor_down = favor - 500
        favor = 500
    else
        favor = favor - favor_down
    end
    if (show_favor == false and isFavorTimePunish) then
        -- 一次降低好感超过200，获得回归标记
        if (favor_down < 200) then
            SetUserConf("favorConf", msg.uid, "好感度", favor)
        else
            SetUserConf(
                "favorConf",
                msg.uid,
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

-- 因为各种情况，好感度不流逝的情况
function isFavorSilent(msg, favor, show_favor)
    -- ! 好感度锁定列表
    if
        (favor < 5000 or msg.uid == "318242040" or msg.uid == "3272364628" or msg.uid == "2908078197" or
            msg.uid == "614671889" or
            msg.uid == "2043789473" or
            msg.uid == "2677402349" or
            msg.uid == "1530045447" or
            msg.uid == "4786515" or
            msg.uid == "3578788465" or
            msg.uid == "1530045447" or
            msg.uid == "1549554054" or
            msg.uid == "996518321")
     then
        return true
    end
    -- 判断八音盒效果
    local musicBox = getUserConf(msg.uid, "musicBox", {})
    if musicBox["enable"] and not show_favor then
        -- 触发八音盒效果，本次交互不降低好感（刷新交互时间），同时八音盒失效
        setUserConf(msg.uid, "musicBox", {["enable"] = false, ["cd"] = musicBox["cd"]})
        return true
    end
    --! 是否在回归保护期
    if (GetUserConf("favorConf", msg.uid, "regression", {["protection"] = 0})["protection"] > os.time()) then
        return true
    end
    if (favor <= 500) then
        return true
    end
end

-- 剧情模式解锁提示
function StoryUnlocked(msg)
    local favor = GetUserConf("favorConf", msg.uid, "好感度", 0)
    local storyUnlockedNotice,
        specialUnlockedNotice,
        isStory0Read,
        isSpecial0Read,
        isShopUnlocked,
        story2Choice,
        isSpecial1Read,
        isSpecial2Read,
        isSpecial3Read,
        isStory3Read,
        isSpecial4Read,
        isSpecial5Read =
        GetUserConf(
        "storyConf",
        msg.uid,
        {
            "storyUnlockedNotice",
            "specialUnlockedNotice",
            "isStory0Read",
            "isSpecial0Read",
            "isShopUnlocked",
            "story2Choice",
            "isSpecial1Read",
            "isSpecial2Read",
            "isSpecial3Read",
            "isStory3Read",
            "isSpecial4Read",
            "isSpecial5Read"
        },
        {"0000000000000000000000000", "0000000000000000000000000", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    )
    local content, flag, res = "", "1", ""
    if (favor >= 1000 and GetUserConf("storyConf", msg.uid, "isStory0Read", 0) == 0) then
        flag = string.sub(storyUnlockedNotice, 1, 1)
        if (flag == "0") then
            content = content .. "『✔提示』剧情模式 序章『惊蛰』,已经解锁,输入“进入剧情 序章”可浏览剧情\n"
            storyUnlockedNotice = "1" .. string.sub(storyUnlockedNotice, 2)
            SetUserConf("storyConf", msg.uid, "storyUnlockedNotice", storyUnlockedNotice)
        end
    end
    if (isSpecial0Read == 0 and favor >= 1500) then
        flag = string.sub(specialUnlockedNotice, 1, 1)
        if (flag == "0") then
            content = content .. "『✔提示』剧情模式 元旦特典『预想此时应更好』,已经解锁,输入“进入剧情 元旦特典”可浏览剧情\n"
            specialUnlockedNotice = "1" .. string.sub(specialUnlockedNotice, 2)
            SetUserConf("storyConf", msg.uid, "specialUnlockedNotice", specialUnlockedNotice)
        end
    end
    if (isStory0Read == 1 and favor >= 2000 and isShopUnlocked == 0) then
        flag = string.sub(storyUnlockedNotice, 2, 2)
        if (flag == "0") then
            content = content .. "『✔提示』剧情模式 第一章『夜未央』,已经解锁,输入“进入剧情 第一章”可浏览剧情\n"
            storyUnlockedNotice = string.sub(storyUnlockedNotice, 1, 1) .. "1" .. string.sub(storyUnlockedNotice, 3)
            SetUserConf("storyConf", msg.uid, "storyUnlockedNotice", storyUnlockedNotice)
        end
    end
    if (isShopUnlocked == 1 and favor >= 3000 and story2Choice == 0) then
        flag = string.sub(storyUnlockedNotice, 3, 3)
        if (flag == "0") then
            content = content .. "『✔提示』剧情模式 第二章『难以言明的选择』,已经解锁,输入“进入剧情 第二章”可浏览剧情\n"
            storyUnlockedNotice = string.sub(storyUnlockedNotice, 1, 2) .. "1" .. string.sub(storyUnlockedNotice, 4)
            SetUserConf("storyConf", msg.uid, "storyUnlockedNotice", storyUnlockedNotice)
        end
    end
    if story2Choice ~= 0 and favor >= 4000 then
        flag = string.sub(storyUnlockedNotice, 4, 4)
        if (flag == "0") then
            content = content .. "『✔提示』剧情模式 第三章『此般景致』,已经解锁,输入“进入剧情 第三章”可浏览剧情\n"
            storyUnlockedNotice = string.sub(storyUnlockedNotice, 1, 3) .. "1" .. string.sub(storyUnlockedNotice, 5)
            SetUserConf("storyConf", msg.uid, "storyUnlockedNotice", storyUnlockedNotice)
        end
    end
    if isSpecial1Read == 0 and favor >= 3500 then
        flag = string.sub(specialUnlockedNotice, 2, 2)
        if (flag == "0") then
            content = content .. "『✔提示』剧情模式 七夕特典『近在咫尺的距离』已经解锁,输入“进入剧情 七夕特典”可浏览剧情\n"
            specialUnlockedNotice =
                string.sub(specialUnlockedNotice, 1, 1) .. "1" .. string.sub(specialUnlockedNotice, 3)
            SetUserConf("storyConf", msg.uid, "specialUnlockedNotice", specialUnlockedNotice)
        end
    end
    if isSpecial2Read == 0 and favor >= 2000 then
        flag = string.sub(specialUnlockedNotice, 3, 3)
        if (flag == "0") then
            content = content .. "『✔提示』剧情模式 圣诞特典『予你的光点』已经解锁,输入“进入剧情 圣诞特典”可浏览剧情\n"
            specialUnlockedNotice =
                string.sub(specialUnlockedNotice, 1, 2) .. "1" .. string.sub(specialUnlockedNotice, 4)
            SetUserConf("storyConf", msg.uid, "specialUnlockedNotice", specialUnlockedNotice)
        end
    end
    if isSpecial3Read == 0 and favor >= 2000 then
        flag = string.sub(specialUnlockedNotice, 4, 4)
        if (flag == "0") then
            content = content .. "『✔提示』剧情模式 白色情人节特典『献给你的礼物』已经开放,输入“进入剧情 献给你的礼物”可浏览剧情\n注意：本次解锁剧情需要扣除750FL"
            specialUnlockedNotice =
                string.sub(specialUnlockedNotice, 1, 3) .. "1" .. string.sub(specialUnlockedNotice, 5)
            SetUserConf("storyConf", msg.uid, "specialUnlockedNotice", specialUnlockedNotice)
        end
    end
    -- 第四章
    if isStory3Read == 1 and favor >= 4000 then
        flag = string.sub(storyUnlockedNotice, 5, 5)
        if (flag == "0") then
            content = content .. "『✔提示』剧情模式 第四章『众生相』,已经解锁,输入“进入剧情 第四章”可浏览剧情\n"
            storyUnlockedNotice = string.sub(storyUnlockedNotice, 1, 4) .. "1" .. string.sub(storyUnlockedNotice, 6)
            SetUserConf("storyConf", msg.uid, "storyUnlockedNotice", storyUnlockedNotice)
        end
    end
    -- 星星点灯
    if favor >= 2000 and isSpecial4Read == 0 then
        flag = string.sub(specialUnlockedNotice, 5, 5)
        if (flag == "0") then
            content = content .. "『✔提示』剧情模式『星星点灯』已经开放,输入“进入剧情 星星点灯”可浏览剧情\n注意：本次解锁剧情需要扣除900FL"
            specialUnlockedNotice =
                string.sub(specialUnlockedNotice, 1, 4) .. "1" .. string.sub(specialUnlockedNotice, 6)
            SetUserConf("storyConf", msg.uid, "specialUnlockedNotice", specialUnlockedNotice)
        end
    end
    if favor >= 4000 and isSpecial5Read == 0 then
        flag = string.sub(specialUnlockedNotice, 6, 6)
        if (flag == "0") then
            content = content .. "『✔提示』剧情模式『夜』已经开放,输入“进入剧情 夜”可浏览剧情\n注意：本次解锁剧情需要扣除1000FL"
            specialUnlockedNotice =
                string.sub(specialUnlockedNotice, 1, 5) .. "1" .. string.sub(specialUnlockedNotice, 7)
            SetUserConf("storyConf", msg.uid, "specialUnlockedNotice", specialUnlockedNotice)
        end
    end
    if content ~= "" then
        msg:echo("[CQ:at,qq=" .. msg.uid .. "]\n" .. content)
    end
end

-- 动作类交互预处理
function Actionprehandle(str)
    local list = {
        "抱",
        "摸",
        "举高",
        "亲",
        "牵手",
        "捏",
        "揉",
        "可爱",
        "萌",
        "kawa",
        "喜欢",
        "suki",
        "爱",
        "love",
        "贴贴",
        "蹭蹭",
        "膝枕",
        "肩膀"
    }
    for _, v in pairs(list) do
        if (string.find(str, v) ~= nil) then
            return true
        end
    end
    return false
end

function check_mission(msg)
    --检验“好奇”心情的任务
    local curiosity_gift = GetUserConf("missionConf", msg.uid, "curiosity_gift", nil)
    if curiosity_gift then
        msg:echo(at_user(msg.uid) .. "提示：茉莉当前处于「好奇」心情，赠送茉莉" .. curiosity_gift .. "可完成任务")
    end
end
