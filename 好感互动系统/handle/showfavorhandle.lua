package.path = getDiceDir() .. "/plugin/Handle/?.lua"
require "PreHandle"
-- 好感查询计算
function ShowFavorHandle(msg, favor, affinity)
    local addFavorItem, addAffinityItem = AddFavor_Item(msg), AddAffinity_Item(msg)
    --Notice(msg)
    local isFavorTimePunish, isFavorTimePunishDown = FavorPunish(msg, true)
    TrustChange(msg)
    CohesionChange(msg)
    StoryUnlocked(msg)
    local state = ""
    local div = 1
    -- 判断打工
    if (JudgeWorking(msg)) then
        state = state .. "\n打工人：打工期间无法进行喂食以及交互。"
    end
    if (favor < 3000) then
        div = 90
    elseif (favor < 8500) then
        div = 95
    elseif (favor < 12000) then
        div = 110
    elseif (favor < 15000) then
        div = 130
    else
        div = 200
    end
    local res = "边际抵抗：" .. math.modf(favor / div) .. "%\n-----------------------------------------\n状态："
    if (isFavorTimePunish == true) then
        state = state .. "\n遗忘：当前好感正随时间流逝。"
    end
    if (calibration_limit > 16) then
        state = state .. "\n逻辑并发过载：某些安全隐患正在提升。"
    end
    local cal = math.modf(-1 * ((calibration + 1) * favor / div / (affinity + 1)) + affinity / 10)
    if cal < 0 then
        state = state .. "\n情感单元过载：当前好感获取量减少。"
    end
    if cal > 0 or (getUserConf(msg.fromQQ, "projectionLamp", {}).lasting or 0) > os.time() then
        state = state .. "\n情感单元谐振：当前好感获取量增加。"
    end
    -- 判断回归
    local regression = GetUserConf("favorConf", msg.fromQQ, "regression", {["flag"] = false, ["protection"] = 0})
    if (regression["flag"] == true) then
        state = state .. "\n汹涌的思念：每次操作都将获得额外的亲和与好感度。"
    end
    if (regression["protection"] > os.time()) then
        state = state .. "\n跨越时间的：一定时间内好感度将不会随时间流逝。"
    end
    if (isFavorTimePunishDown) then
        state = state .. "\n心流：好感随时间流逝量减少。"
    end
    if (addFavorItem["addFavorEveryDay"] == "Cookie") then
        state = state .. "\n曲奇的余香：一天第一次交互额外增加20好感。"
    end
    if (addAffinityItem["addAffinityEveryDay"] == "Sushi") then
        state = state .. "\n软糯的？：一天第一次交互额外增加2点亲和度。"
    end
    if (addFavorItem["addFavorEveryAction"] == "Hairpin") then
        state = state .. "\n不只是发簪：每次未超出当日限制次数的交互额外增加10好感。"
    end
    if (getUserConf(msg.fromQQ, "musicBox", {})["enable"]) then
        state = state .. "\n残缺的旋律：你们之间的记忆暂停了（好感流逝锁定）。"
    end
    state = state .. "\n-----------------------------------------\n"
    -- 当前心情判断
    local special_mood, float_value, coefficient =
        GetUserConf("moodConf", msg.fromQQ, {"special_mood", "float_value", "coefficient"}, {"平常", 0, 0})
    if special_mood == "好奇" then
        local curiosity_gift = GetUserConf("missionConf", msg.fromQQ, "curiosity_gift", nil)
        if curiosity_gift == nil then
            state = state .. "好奇：茉莉的好奇心已被满足"
        else
            state = state .. "好奇：茉莉想要一个「" .. curiosity_gift .. "」，完成后有5%概率获得300好感，未完成则有5%概率失去100好感"
        end
    else
        state = state .. special_mood .. "：" .. __MOOD_DES__[special_mood]
    end
    state =
        state ..
        "\n心情浮动：" .. float_value .. " | 心情系数：" .. coefficient .. "\n-----------------------------------------\n"
    return res .. state
end

__MOOD_DES__ = {
    ["平常"] = "平淡的日常，最珍贵的时光",
    ["开心"] = "随时间流逝的好感度减少",
    ["渴望"] = "喂食、赠礼的好感获取量增加",
    ["振奋"] = "交互的好感获取量增加（除喂食、赠礼）",
    ["焦虑"] = "随时间流逝的好感度增加",
    ["失望"] = "喂食、赠礼的好感获取量减少",
    ["枯燥"] = "交互的好感获取量减少（除喂食、赠礼）"
}
