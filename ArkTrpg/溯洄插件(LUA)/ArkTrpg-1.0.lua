--[[
    @Author 泰拉旅社
    @Version 1.0
    @Last Modified 2025/04/09
    @Description：适用于WIT-v1.0的人物作成与规则检定
]]
---@diagnostic disable: lowercase-global, assign-type-mismatch, cast-local-type

msg_order = {
    [".rk"] = "ark_main",
    [".sck"] = "ark_sck",
    [".ark"] = "roll_ark"
}

AT_CQ = "%[CQ:at,id=(%d+)%]"
BASIC_ATTR = {
    ["欺诈，乔装，潜行，调查，觉察，追踪"] = "精神意志",
    ["声乐，艺术，心理，游说，取悦，威吓"] = "个人魅力",
    ["妙手，急救，驾驶，舞蹈，短兵，暗器，射击，身法"] = "反应机动",
    ["长兵，刀剑，钝器，格斗，软兵，拳术，盾术"] = "物理强度",
    ["兵械操作，生物驯养，战术规划，支援技术，自然学，医药学，源石学，社会学，政法学，经管学，机械工程，电子工程，农林渔牧，手工工艺"] = "经验智慧",
    ["动能，光明，暗影，火焰，电能，气流，控水，土石，冰霜，躯体，植物，恢复，传心感知"] = "源石技艺适应性"
}

function ark_main(msg)
    -- 处理奖励骰和惩罚骰
    local correction
    msg, correction = parse_reward_punish(msg)

    -- 处理at_qq
    local at_qq = msg.fromMsg:match(AT_CQ)
    msg.fromMsg = msg.fromMsg:gsub(AT_CQ, "")

    -- 提取参数
    local res, errorMsg = parse_common_roll_command(msg)
    if not res then
        return errorMsg
    end

    res.at_qq = at_qq

    return ark_check(res, msg, correction)
end

function ark_check(input, msg, correction)
    -- 掷骰过程（技能值d骰面）（附带奖励骰和惩罚骰）
    local random_result = ndm(input.skill_value + correction, input.face)
    local random_sum = random_result.sum
    local random_display = table.concat(random_result.values, "+")

    local res, basic_attr_value = random_sum, 0
    -- 是否为基础属性，不是则加上基础属性值
    if not is_basic_attr(input.skill_name) then
        -- 寻找基础属性
        local basic_attr = find_basic_attr(input.skill_name)
        -- 找到基础属性则加上基础属性值，否则加0
        basic_attr_value = basic_attr and getPlayerCardAttr(msg.uid, msg.gid, basic_attr, 0) or 0
        -- +基础属性值
        res = res + basic_attr_value
    end

    -- 构建返回信息
    local reply
    -- correction为正数，加"+"号"，变为字符串，负数则直接字符串化
    correction = correction >= 0 and ("+" .. correction) or tostring(correction)
    if res >= input.dc_value then
        reply =
            "{pc}进行ark的" ..
            input.skill_name ..
                "检定:\n" ..
                    "(" ..
                        input.skill_value ..
                            correction ..
                                ")" ..
                                    "d" ..
                                        input.face ..
                                            "+" ..
                                                basic_attr_value ..
                                                    "=" ..
                                                        random_display ..
                                                            "+" ..
                                                                basic_attr_value ..
                                                                    "=" ..
                                                                        res ..
                                                                            "/" ..
                                                                                input.dc_value ..
                                                                                    "，{strRollRegularSuccess}"
        -- at_qq的hp减去 res - dc
        if input.at_qq then
            local hp = getPlayerCardAttr(input.at_qq, msg.gid, "hp", 0)
            local damage = res - input.dc_value
            hp = hp - damage
            if hp <= 0 then
                hp = 0
                reply = reply .. "\n提示：目标hp已经归零"
            else
                reply = reply .. "\n目标hp已减少" .. damage .. "点"
            end
            setPlayerCardAttr(input.at_qq, msg.gid, "hp", hp)
        end
    else
        reply =
            "{pc}进行ark的" ..
            input.skill_name ..
                "检定:\n" ..
                    "(" ..
                        input.skill_value ..
                            correction ..
                                ")" ..
                                    "d" ..
                                        input.face ..
                                            "+" ..
                                                basic_attr_value ..
                                                    "=" ..
                                                        random_display ..
                                                            "+" ..
                                                                basic_attr_value ..
                                                                    "=" ..
                                                                        res ..
                                                                            "/" .. input.dc_value .. "，{strRollFailure}"
    end

    -- 判断是否为大失败或大成功
    local critical_result = check_critical(random_result, input.face)
    if critical_result.critical_success then
        reply = reply .. "\n" .. "{strCriticalSuccess}（至少半数最大值）"
    elseif critical_result.critical_failure then
        reply = reply .. "\n" .. "{strRollFumble}（至少半数最小值）"
    end

    return reply
end

-- sck[数值]
function ark_sck(msg)
    -- 提取参数
    local count = msg.fromMsg:match("[%.。]sck%s*(%d*)")
    -- 默认为1
    count = (count and #count > 0) and tonumber(count) or 1

    -- count d10
    local random_result = ndm(count, 10)
    local random_sum = random_result.sum

    local will = getPlayerCardAttr(msg.uid, msg.gid, "精神意志", 0)

    if random_sum > will then
        return "{pc}进行ark的自控检定:\n" .. count .. "d10" .. "=" .. random_sum .. "/" .. will .. "，{strRollFailure}"
    else
        return "{pc}进行ark的自控检定:\n" .. count .. "d10" .. "=" .. random_sum .. "/" .. will .. "，{strRollRegularSuccess}"
    end
end

function parse_common_roll_command(msg)
    -- 定义正则表达式模式，匹配所有可能的输入情况
    local pattern = "[%.。]rk%s*(%d*)%s*([^%d%s/]*)%s*(%d*)%s*/(%d+)"

    -- 使用正则表达式匹配输入
    local face, skill_name, skill_value, dc_value = msg.fromMsg:match(pattern)

    -- 检查是否匹配到了/符号但DC为空
    if msg.fromMsg:find("/") and (not dc_value or dc_value == "") then
        return nil, "错误：指定了/符号但未提供难度等级DC×"
    end

    -- 如果第一个模式没有匹配成功，尝试匹配没有DC部分的格式
    if not face then
        local pattern2 = "[%.。]rk%s*(%d*)%s*([^%d%s/]*)%s*(%d*)"
        face, skill_name, skill_value = msg.fromMsg:match(pattern2)

        -- 如果仍然没有匹配成功，则返回错误
        if not face then
            return nil, "错误：命令格式不正确×"
        end

        -- 没有/符号时，默认DC为0
        dc_value = "0"
    end

    -- 如果技能名为空，返回错误
    if not skill_name or skill_name == "" then
        return nil, "错误：未提供技能名×"
    end

    -- 处理默认值
    face = (face and #face > 0) and tonumber(face) or 6
    skill_value =
        (skill_value and #skill_value > 0) and tonumber(skill_value) or
        getPlayerCardAttr(msg.uid, msg.gid, skill_name, 0)
    dc_value = tonumber(dc_value) or 0

    -- 返回成功结果
    return {
        success = true,
        face = face,
        skill_name = skill_name,
        skill_value = skill_value,
        dc_value = dc_value
    }
end

function parse_reward_punish(msg)
    if msg.fromMsg:match("^[%.。]rkb") then
        -- 提取奖励骰参数
        local face = msg.fromMsg:match("^[%.。]rkb(%d*)")
        -- 默认为1
        face = (face and #face > 0) and tonumber(face) or 1
        msg.fromMsg = msg.fromMsg:gsub("^[%.。]rkb(%d*)", ".rk")
        return msg, face
    end
    if msg.fromMsg:match("^[%.。]rkp") then
        -- 提取惩罚骰参数
        local face = msg.fromMsg:match("^[%.。]rkp(%d*)")
        -- 默认为1
        face = (face and #face > 0) and tonumber(face) or 1
        msg.fromMsg = msg.fromMsg:gsub("^[%.。]rkp(%d*)", ".rk")
        return msg, -face
    end
    return msg, 0
end

function ndm(n, m)
    local res_sum = 0
    local rolls = {}
    for _ = 1, n do
        local roll = ranint(1, m)
        table.insert(rolls, roll)
        res_sum = res_sum + roll
    end
    return {values = rolls, sum = res_sum}
end

-- 检查是否大成功或大失败
function check_critical(roll_result, face)
    local rolls = roll_result.values
    local dice_count = #rolls

    -- 计算最大值和最小值的出现次数
    local max_value_count = 0
    local min_value_count = 0

    for _, roll in ipairs(rolls) do
        if roll == face then -- 最大值
            max_value_count = max_value_count + 1
        elseif roll == 1 then -- 最小值
            min_value_count = min_value_count + 1
        end
    end

    -- 计算"一半"的阈值（向上取整）
    local half_threshold = math.ceil(dice_count / 2)

    -- 判断大成功和大失败
    local is_critical_success = (max_value_count >= half_threshold)
    local is_critical_failure = (min_value_count >= half_threshold)

    return {
        critical_success = is_critical_success,
        critical_failure = is_critical_failure
    }
end

function find_basic_attr(str)
    for k, v in pairs(BASIC_ATTR) do
        if k:find(str) then
            return v
        end
    end
    return nil
end

-- 判断是否是基础属性
function is_basic_attr(str)
    for _, v in pairs(BASIC_ATTR) do
        if v == str then
            return v
        end
    end
    return nil
end

--! 下面是有关.ark的内容
-- 生成角色属性函数
function generate_character_stats()
    -- 初始化属性
    local stats = {
        physical_endurance = 0,
        agility = 0,
        physical_strength = 0,
        mental_will = 0,
        experience_wisdom = 0,
        originium_arts_adaptability = 0,
        personal_charm = 0,
        economic_rating = 0
    }

    -- 投掷2d4获取基本属性
    for _ = 1, 2 do
        stats.physical_endurance = stats.physical_endurance + ranint(1, 4)
        stats.agility = stats.agility + ranint(1, 4)
        stats.physical_strength = stats.physical_strength + ranint(1, 4)
        stats.mental_will = stats.mental_will + ranint(1, 4)
        stats.experience_wisdom = stats.experience_wisdom + ranint(1, 4)
        stats.originium_arts_adaptability = stats.originium_arts_adaptability + ranint(1, 4)
        stats.personal_charm = stats.personal_charm + ranint(1, 4)
    end

    -- 计算经济评级4d6
    for _ = 1, 4 do
        stats.economic_rating = stats.economic_rating + ranint(1, 6)
    end

    -- 计算社交点数 (personal_charm)d6
    local social_points = 0
    for _ = 1, stats.personal_charm do
        social_points = social_points + ranint(1, 6)
    end

    -- 计算总值
    local base_stats_total =
        stats.physical_endurance + stats.agility + stats.physical_strength + stats.mental_will + stats.experience_wisdom +
        stats.originium_arts_adaptability +
        stats.personal_charm

    local grand_total = base_stats_total + stats.economic_rating + social_points

    -- 格式化输出
    local result =
        ("{nick}的泰拉人作成\n" ..
        "生理耐受: %d  反应机动: %d\n" ..
            "物理强度: %d  精神意志: %d\n" .. "经验智慧: %d  源石技艺适应性: %d\n" .. "个人魅力: %d  经济评级: %d\n" .. "社交点数: %d  共计: %d/%d"):format(
        stats.physical_endurance,
        stats.agility,
        stats.physical_strength,
        stats.mental_will,
        stats.experience_wisdom,
        stats.originium_arts_adaptability,
        stats.personal_charm,
        stats.economic_rating,
        social_points,
        base_stats_total,
        grand_total
    )

    return result
end

-- 处理ark指令的函数
function roll_ark(msg)
    -- 解析指令中的次数
    local count = msg.fromMsg:match("(%d+)")

    -- 设置默认值及范围检查
    count = count and tonumber(count) or 1

    if count < 1 then
        return "{strZeroDiceErr}"
    elseif count > 5 then
        return "{strDicetooBigErr}"
    else
        -- 生成指定次数的角色
        local results = {}
        for _ = 1, count do
            table.insert(results, generate_character_stats())
        end

        -- 拼接结果
        return table.concat(results, "\n\n")
    end
end
