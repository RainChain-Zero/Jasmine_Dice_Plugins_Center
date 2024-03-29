package.path = getDiceDir() .. "/plugin/Handle/?.lua"
require "Utils"
-- 好坏情绪原始分界值
__BOUNDARY__ = 0.75
-- 单位浮动值变动的区间长度
__FLOAT_WEIGHT_CHANGE__ = 0.1
__GOOD_MOOD__ = {"好奇", "开心", "渴望", "振奋"}
__BAD_MOOD__ = {"焦虑", "失望", "枯燥"}
__MOOD_FUNCTION__ = {
    ["开心"] = function(y)
        return 1 / y
    end,
    ["渴望"] = function(y)
        return y
    end,
    ["好奇"] = function(y)
        return 1
    end,
    ["振奋"] = function(y)
        return y
    end,
    ["焦虑"] = function(y)
        return y
    end,
    ["失望"] = function(y)
        return 1 / y
    end,
    ["枯燥"] = function(y)
        return 1 / y
    end
}

-- 获取标准正态分布数
function get_normal()
    local x = math.random()
    local y = math.random()
    -- Box-Muller变换
    return math.sqrt(-2 * math.log(x)) * math.cos(2 * math.pi * y)
end

--[[
    从情绪概率池中抽取情绪
    标准正态分布数在负无穷到-0.75间为坏情绪
    在-0.75到0.75间为平常情绪 P=52.05%
    在0.75到正无穷间为好情绪
]]
function get_mood(float_value)
    local random = get_normal()
    -- 获取左右边界
    local left, right = get_limit(float_value)
    if random < left then
        return -1, random
    elseif random > right then
        return 1, random
    else
        return 0, random
    end
end

--[[
    变动浮动值
    抽取的情绪为坏情绪，浮动值减1
    抽取的情绪为好情绪，浮动值加1
    抽取的情绪为平常情绪，浮动值不变
]]
function update_float_value(mood_now, float_value)
    -- 两次获得的情绪相反，则浮动值归零
    if float_value * mood_now < 0 then
        return 0
    end
    if mood_now == -1 then
        return float_value - 1
    elseif mood_now == 1 then
        return float_value + 1
    else
        return float_value
    end
end

--[[
    计算浮动加权
    浮动值<0时，每减少1，浮动加权减少-0.1
    浮动值>0时，每增加1，浮动加权增加0.1
]]
function get_float_weight(float_value)
    if float_value <= -1 or float_value >= 1 then
        return __FLOAT_WEIGHT_CHANGE__ * float_value
    else
        return 0
    end
end

--[[
    通过浮动加权获取好坏情绪分界值
    返回左右边界值
]]
function get_limit(float_vlaue)
    local float_weight = get_float_weight(float_vlaue)
    -- 如果浮动加权的值超过了0.3，那么必定为另一种情绪
    if math.abs(float_weight) >= 0.3 then
        -- 若为坏情绪，必定为好情绪
        if float_weight < 0 then
            return -math.huge, -math.huge
        else
            return math.huge, math.huge
        end
    end
    -- 平常情绪区间长度-float_weight，按照正负左右移动区间
    if float_weight < 0 then
        -- 缩小坏情绪和平常情绪的区间，加倍加长好情绪区间
        return -__BOUNDARY__ + float_weight, __BOUNDARY__ + float_weight * 2
    else
        -- 缩小好情绪和平常情绪的区间，加倍加长坏情绪区间
        return -__BOUNDARY__ + float_weight * 2, __BOUNDARY__ + float_weight
    end
end

--[[
    更新心情信息
    返回新的心情值，浮动值
]]
function update_mood_info(qq, float_value)
    -- 抽取新情绪
    local mood_now, random = get_mood(float_value)
    -- 更新浮动值
    float_value = update_float_value(mood_now, float_value)
    -- 抽取具体心情
    local special_mood, coefficient = get_special_mood(qq, mood_now, random)
    return mood_now, float_value, special_mood, coefficient
end

-- 校准时更新用户列表心情
function update_mood_list(mood_list)
    for k, _ in pairs(mood_list) do
        local float_value, mood_now, special_mood, coefficient
        float_value = GetUserConf("moodConf", k, "float_value", 0)
        mood_now, float_value, special_mood, coefficient = update_mood_info(k, float_value)
        SetUserConf(
            "moodConf",
            k,
            {"mood", "float_value", "special_mood", "coefficient"},
            {mood_now, float_value, special_mood, coefficient}
        )
        address_special_mood(k, special_mood)
    end
end

-- 获取具体心情
function get_special_mood(qq, mood, random)
    local random_key = nil
    if random < -1 then
        random = -1
    elseif random > 1 then
        random = 1
    end
    local y = math.abs(random) + 1
    if mood == 0 then
        return "平常", 1
    elseif mood == 1 then
        local good_mood = __GOOD_MOOD__
        -- 好感不足2000时，不会出现好奇心情
        if GetUserConf("favorConf", qq, "好感度", 0) < 2000 then
            table.remove(good_mood, 1)
        end
        random_key = good_mood[ranint(1, #good_mood)]
        return random_key, __MOOD_FUNCTION__[random_key](y)
    else
        random_key = __BAD_MOOD__[ranint(1, #__BAD_MOOD__)]
        return random_key, __MOOD_FUNCTION__[random_key](y)
    end
end

function get_coefficient(special_mood, coefficient, candidates)
    for _, v in pairs(candidates) do
        if v == special_mood then
            return coefficient
        end
    end
    return 1
end

-- 处理特殊心情
function address_special_mood(qq, special_mood)
    if special_mood == "好奇" then
        local gift = get_random_gift()
        SetUserConf("missionConf", qq, "curiosity_gift", gift)
        SetUserToday(qq, "curiosity_gift_notice", 0)
    end
end
