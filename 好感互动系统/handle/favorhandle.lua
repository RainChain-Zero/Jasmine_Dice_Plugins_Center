---@diagnostic disable: lowercase-global
--[[
    @author RainChain-Zero
    @version 1.0
    @Created 2022/04/03 16:23
    @Last Modified 2022/04/03 16:44
    ]]
--! 校准值 使用Dice!函数
calibration = getUserConf(getDiceQQ(), "calibration", 0)
-- 校准值初始上限
calibration_limit = getUserConf(getDiceQQ(), "calibration_limit", 12)
-- 好感阈值修正，返回是否成功、下限修正和上限修正值(修正非赠礼交互)
-- msg,当前好感，亲和力
function ModifyLimit(msg, favor, affinity)
    if (calibration > calibration_limit) then
        return false, 0, 0, "本轮时钟周期已结束，请进行『校准』\n(指令为“茉莉校准”)"
    end
    -- 下限修订600*亲和力/100，上限修订100+好感/100*（校准值+1）
    local left_limit, right_limit = math.modf(600 * affinity / 100), math.modf(150 + favor / 100 * (calibration + 1))
    -- 每次互动都增加一次校准值
    calibration = calibration + 1
    setUserConf(getDiceQQ(), "calibration", calibration)
    -- 1/10的失败概率
    if (ranint(1, 10) == 10) then
        -- 校准上限+2，亲和力减少
        calibration_limit = calibration_limit + 2
        local affinity_down = ranint(4, 6)
        if (affinity - affinity_down < 0) then
            affinity = 0
        else
            affinity = affinity - affinity_down
        end
        setUserConf(getDiceQQ(), "calibration_limit", calibration_limit)
        SetUserConf("favorConf", msg.fromQQ, "affinity", affinity)
        return false, left_limit, right_limit
    else
        return true, left_limit, right_limit
    end
end

-- 修正好感变化值(适用于非赠礼交互)
-- msg,原好感,当前好感变化值，亲和力,是否成功
function ModifyFavorChangeNormal(msg, favor_ori, favor_change, affinity, succ)
    local res = 0
    if (favor_change < 0) then
        -- 校准上限+2，亲和力减少
        calibration_limit = calibration_limit + 2
        local affinity_down = ranint(6, 8)
        if (affinity - affinity_down < 0) then
            affinity = 0
        else
            affinity = affinity - affinity_down
        end
        setUserConf(getDiceQQ(), "calibration_limit", calibration_limit)
        SetUserConf("favorConf", msg.fromQQ, "affinity", affinity)
        if (calibration > 20) then
            res = 2 * favor_change
        elseif (calibration < 8) then
            res = math.modf(0.8 * favor_change)
        else
            res = math.modf(calibration / 10 * favor_change)
        end
    else
        -- 判定成功，则亲和度增加
        if (succ) then
            local affinity_up = ranint(2, 3)
            if (favor_ori < 1500) then
                affinity_up = ranint(4, 5)
            end
            if (affinity + affinity_up > 100) then
                affinity = 100
            else
                affinity = affinity + affinity_up
            end
            SetUserConf("favorConf", msg.fromQQ, "affinity", affinity)
        end
        local favor_modify, div = 0, 1
        if (favor_ori < 3000) then
            div = 90
        elseif (favor_ori < 8500) then
            div = 95
        elseif (favor_ori < 12000) then
            div = 110
        elseif (favor_ori < 15000) then
            div = 130
        else
            div = 200
        end
        favor_modify = math.modf(-1 * ((calibration + 1) * favor_ori / div / (affinity + 1)) + affinity / 10)
        -- 保底5
        if (favor_change + favor_modify < 5) then
            res = 5
        else
            res = favor_change + favor_modify
        end
    end

    -- 检测道具带来的额外好感
    res = res + AddFavorPerAction(msg, favor_ori, affinity)

    --! 校准列表，使用Dice!函数
    local calibration_list = getUserConf(getDiceQQ(), "calibration_list", {})
    -- 记录变化值
    calibration_list[msg.fromQQ] = res
    setUserConf(getDiceQQ(), "calibration_list", calibration_list)
    return res
end

-- 每次交互带来的额外好感
function AddFavorPerAction(msg, favor_ori, affinity)
    local res = 0
    -- 发簪
    local hairpinDDL, hairpinDDLFlag =
        GetUserConf(
        "adjustConf",
        msg.fromQQ,
        {"addFavorPerActionDDL_Hairpin", "addFavorPerActionDDLFlag_Hairpin"},
        {0, 0}
    )
    if (os.time() < hairpinDDL) then
        res = res + ModifyFavorChangeSpecial(favor_ori, 10, affinity)
    elseif (hairpinDDLFlag == 0) then
        if (hairpinDDL ~= 0) then
            sendMsg("注意，您的『发簪』道具效果已消失", msg.fromGroup, msg.fromQQ)
        end
        -- 更新标记，下次不做提醒
        SetUserConf("adjustConf", msg.fromQQ, "addFavorPerActionDDLFlag_Hairpin", 1)
    end
    return res
end

-- 不带校准和亲和度变化的好感修正
function ModifyFavorChangeSpecial(favor_ori, favor_change, affinity)
    local favor_modify, div, res = 0, 1, 0
    if (favor_ori < 3000) then
        div = 90
    elseif (favor_ori < 8500) then
        div = 95
    elseif (favor_ori < 12000) then
        div = 110
    elseif (favor_ori < 15000) then
        div = 130
    else
        div = 200
    end
    favor_modify = math.modf(-1 * ((calibration + 1) * favor_ori / div / (affinity + 1)) + affinity / 10)
    -- 保底5
    if (favor_change + favor_modify < 5) then
        res = 5
    else
        res = favor_change + favor_modify
    end
    return res
end

-- 修正好感变化值(适用于赠礼交互)
-- msg,原好感,当前好感变化值，亲和力，成功是否不加亲和
function ModifyFavorChangeGift(msg, favor_ori, favor_change, affinity, lock)
    local res = 0
    if (calibration > calibration_limit) then
        return 0, "本轮时钟周期已结束，请进行『校准』\n(指令为“茉莉校准”)"
    end
    calibration = calibration + 1
    setUserConf(getDiceQQ(), "calibration", calibration)
    if (ranint(1, 10) == 10) then
        -- 校准上限+2，亲和力减少
        calibration_limit = calibration_limit + 2
        local affinity_down = ranint(4, 6)
        if (affinity - affinity_down < 0) then
            affinity = 0
        else
            affinity = affinity - affinity_down
        end
        setUserConf(getDiceQQ(), "calibration_limit", calibration_limit)
        SetUserConf("favorConf", msg.fromQQ, "affinity", affinity)
    else
        if (lock == false) then
            local affinity_up = 0
            if (favor_ori < 1500) then
                affinity_up = ranint(2, 3)
            else
                affinity_up = ranint(1, 2)
            end
            if (affinity + affinity_up > 100) then
                affinity = 100
            else
                affinity = affinity + affinity_up
            end
            SetUserConf("favorConf", msg.fromQQ, "affinity", affinity)
        end
    end
    local favor_modify, div = 0, 1
    if (favor_ori < 3000) then
        div = 90
    elseif (favor_ori < 8500) then
        div = 95
    elseif (favor_ori < 12000) then
        div = 110
    elseif (favor_ori < 15000) then
        div = 130
    else
        div = 200
    end
    favor_modify = math.modf(-1 * ((calibration + 1) * favor_ori / div / (affinity + 1)) + affinity / 10)
    -- 保底5
    if (favor_change + favor_modify < 5) then
        res = 5
    else
        res = favor_change + favor_modify
    end
    --! 校准列表，使用Dice!函数
    local calibration_list = getUserConf(getDiceQQ(), "calibration_list", {})
    -- 记录变化值
    calibration_list[msg.fromQQ] = res
    setUserConf(getDiceQQ(), "calibration_list", calibration_list)
    return res
end

-- 好感度逢千判断亲和力是否达到100
-- qq,原好感度,现好感度,亲和力
function CheckFavor(qq, favor_ori, favor_now, affinity)
    local pre, now = 0, 0
    -- 回归修正
    favor_now = CheckRegression(qq, favor_now, affinity)
    if (favor_ori < 1000) then
        pre = 0
    else
        pre = favor_ori % 10000
        pre = math.modf(pre / 1000)
    end
    if (favor_now < 1000) then
        now = 0
    else
        now = favor_now % 10000
        now = math.modf(now / 1000)
    end
    if (now == (pre + 1) % 10) then
        if (affinity == 100) then
            SetUserConf("favorConf", qq, {"好感度", "affinity"}, {favor_now, 0})
        else
            favor_now = math.modf(favor_ori / 10000) * 10000 + pre * 1000 + 999
            SetUserConf("favorConf", qq, "好感度", favor_now)
        end
    else
        SetUserConf("favorConf", qq, "好感度", favor_now)
    end
    return favor_now
end

-- 检验回归加成
function CheckRegression(qq, favor_now, affinity)
    local regression = GetUserConf("favorConf", qq, "regression", {["flag"] = false})
    if (regression["flag"] == true) then
        local affinity_now = affinity + ranint(1, 2)
        if (affinity_now > 100) then
            affinity_now = 100
        end
        SetUserConf("favorConf", qq, "affinity", affinity_now)
        local favor_add, favor_diff = 0, regression["favor_ori"] - favor_now
        if (favor_diff > 500) then
            favor_add = ranint(10, 13)
        elseif (favor_diff > 200) then
            favor_add = ranint(5, 8)
        elseif (favor_diff > 0) then
            favor_add = ranint(3, 4)
        end
        favor_now = favor_now + favor_add
        -- 达到原先好感，效果结束
        if (favor_now > regression["favor_ori"]) then
            SetUserConf("favorConf", qq, "regression", {["flag"] = false, ["protection"] = 0})
        end
    end
    return favor_now
end
