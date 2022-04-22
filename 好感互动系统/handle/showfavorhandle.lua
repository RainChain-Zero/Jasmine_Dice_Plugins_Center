package.path = getDiceDir() .. "/plugin/handle/?.lua"
require "prehandle"
-- 好感查询计算
function ShowFavorHandle(msg, favor, affinity)
    local addFavorItem, addAffinityItem = AddFavor_Item(msg), AddAffinity_Item(msg)
    Notice(msg)
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
        div = 100
    elseif (favor < 8500) then
        div = 140
    elseif (favor < 15000) then
        div = 170
    else
        div = 200
    end
    local res = "边际抵抗：" .. math.modf(favor / div) .. "%\n状态："
    if (isFavorTimePunish == true) then
        state = state .. "\n遗忘：当前好感正随时间流逝。"
    end
    if (calibration_limit > 16) then
        state = state .. "\n逻辑并发过载：某些安全隐患正在提升。"
    end
    if (math.modf(-1 * ((calibration + 1) * favor / div / (affinity + 1)) + affinity / 10) < 0) then
        state = state .. "\n情感单元过载：当前好感获取量减少。"
    else
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
        state = state .. "\n软糯的？：一天第一次交互额外增加4点亲和度。"
    end
    if (addFavorItem["addFavorEveryAction"] == "Hairpin") then
        state = state .. "\n不只是发簪：每次未超出当日限制次数的交互额外增加10好感。"
    end
    state = state .. "\n\n"
    return res .. state
end
