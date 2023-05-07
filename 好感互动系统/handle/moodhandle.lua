-- 好坏情绪原始分界值
__BOUNDARY__ = 0.75
-- 单位浮动值变动的区间长度
__FLOAT_WEIGHT_CHANGE__ = 0.1
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
    在-0.75到0.75间为平常情绪 P=55.42%
    在0.75到正无穷间为好情绪
]]
function get_mood(float_value)
    local random = get_normal()
    -- 获取左右边界
    local left, right = get_limit(float_value)
    log("左右边界：", left, right)
    if random < left then
        return -1
    elseif random > right then
        return 1
    else
        return 0
    end
end

--[[
    变动浮动值
    抽取的情绪为坏情绪，浮动值减1
    抽取的情绪为好情绪，浮动值加1
    抽取的情绪为平常情绪，浮动值不变
]]
function change_float_value(mood_pre, mood_now, float_value)
    -- 两次获得的情绪相反，则浮动值归零
    if mood_pre + mood_now == 0 then
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
    if float_value <= -1 then
        return -__FLOAT_WEIGHT_CHANGE__ * float_value
    elseif float_value >= 1 then
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
    log("浮动加权：", float_weight)
    -- 如果浮动加权的值超过了平常情绪的区间值，那么必定为另一种情绪
    if __BOUNDARY__ * 2 - math.abs(float_weight) <= 0 then
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
function update_mood_info(mood_pre, float_value)
    -- 抽取新情绪
    local mood_now = get_mood(float_value)
    -- 更新浮动值
    float_value = change_float_value(mood_pre, mood_now, float_value)
    log("新情绪：", mood_now, "新浮动值：", float_value)
    return mood_now, float_value
end
