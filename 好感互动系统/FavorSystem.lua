---@diagnostic disable: lowercase-global
package.path = getDiceDir() .. "/plugin/ReplyAndDescription/?.lua"
require "Reply"
require "itemDescription"
package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"
package.path = getDiceDir() .. "/plugin/handle/?.lua"
require "prehandle"
require "favorhandle"
require "showfavorhandle"
require "moodhandle"
require "CustomizedReply"
require "CalibrationSystem"
msg_order = {}

-- 一天互动上限
__LIMIT_PER_DAY__ = {
    food = 3,
    morning = 1,
    noon = 1,
    night = 1,
    hug = 1,
    head = 1,
    lift = 1,
    kiss = 1,
    hand = 1,
    face = 1,
    suki = 1,
    love = 1,
    interaction = 3,
    cute = 1,
    tietie = 1,
    cengceng = 1,
    lapPillow = 1
}
flag_food = 0 -- 用于标记多次喂食只回复一次
cnt = 0 -- 用户输入的喂食次数
-- 时间
hour = os.date("*t").hour * 1
minute = os.date("%M") * 1
month = os.date("%m") * 1
day = os.date("%d") * 1
year = os.date("%Y") * 1

function topercent(num)
    if (num == nil) then
        return ""
    end
    return string.format("%.2f", num / 100)
end

function add_favor_food(msg, favor, affinity, coefficient)
    local favor_add = 0
    -- 随机好感上升,低好感用户翻倍
    if (favor <= 1500) then
        favor_add = ranint(30, 50)
    elseif (favor <= 4000) then
        favor_add = ranint(20, 30)
    elseif (favor <= 10000) then
        favor_add = ranint(15, 20)
    else
        favor_add = ranint(20, 30)
    end
    return ModifyFavorChangeGift(msg, favor, favor_add * coefficient, affinity, false)
end

function add_gift_once() -- 单次计数上升
    return 5
end

-- 下限黑名单判定
function blackList(msg)
    local favor = GetUserConf("favorConf", msg.uid, "好感度", 0)
    if (favor <= -200 and favor > -500) then
        msg:echo("Warning:检测到你的好感度过低，即将触发机体下限保护机制！")
    end
    if (favor < -500) then
        sendMsg("Warning:检测到用户" .. msg.uid .. "触发好感下限" .. "在群" .. msg.gid, 801655697, 0)
        eventMsg(".group " .. msg.gid .. " ban " .. msg.uid .. " " .. tostring(-favor), msg.gid, getDiceQQ())
        return "已触发！"
    end
    return ""
end

function rcv_food(msg)
    -- rude值判定是否接受喂食
    local preReply = preHandle(msg)
    if (preReply ~= nil) then
        return preReply
    end
    local favor, affinity = GetUserConf("favorConf", msg.uid, {"好感度", "affinity"}, {0, 0})
    local mood, special_mood, coefficient =
        GetUserConf("favorConf", msg.uid, {"mood", "special_mood", "coefficient"}, {0, 0, 0})
    coefficient = get_coefficient(special_mood, coefficient, {"渴望", "失望"})

    -- 匹配喂食的次数
    if (cnt == 0) then
        cnt = string.match(msg.fromMsg, "[%s]*(%d+)", #food_order + 1)
        if (cnt == nil or cnt == "") then
            cnt = 1
        else
            cnt = cnt * 1
        end
    end
    if (cnt >= 4 or cnt < 0) then
        return "参数有误请重新输入哦~"
    end
    -- 判定当日上限
    local today_gift = GetUserToday(msg.uid, "gifts", 0)
    if (today_gift >= __LIMIT_PER_DAY__.food) then
        return "对不起{nick}，茉莉今天...想换点别的口味呢呜QAQ"
    end
    -- 计算今日/累计投喂，存取在骰娘用户记录上
    local DiceQQ = 3349795206
    local gift_add = add_gift_once()
    local self_today_gift = getUserToday(DiceQQ, "gifts", 0) + gift_add * cnt
    setUserToday(DiceQQ, "gifts", self_today_gift)
    --! 骰娘总次数采用Dice!函数
    local self_total_gift = getUserConf(DiceQQ, "gifts", 0) + gift_add * cnt
    setUserConf(DiceQQ, "gifts", self_total_gift)
    -- 循环调用
    while (cnt > 0) do
        local favor_ori, favor_add, calibration_message = favor, 0, nil
        favor_add, calibration_message = add_favor_food(msg, favor_ori, affinity, coefficient)
        if (calibration_message ~= nil) then
            return calibration_message
        end
        today_gift = today_gift + 1
        SetUserToday(msg.uid, "gifts", today_gift)
        if (today_gift > __LIMIT_PER_DAY__.food) then
            break
        end
        favor = favor_ori + favor_add
        -- SetUserConf("favorConf", msg.uid, "好感度", favor)
        favor, affinity = CheckFavor(msg.uid, favor_ori, favor, affinity)
        cnt = cnt - 1
    end
    return "你眼前一黑，手中的食物瞬间消失，再看的时候，眼前的烧酒口中还在咀嚼着什么，扭头躲开了你的目光\n今日已收到投喂" ..
        topercent(self_today_gift) .. "kg\n累计投喂" .. topercent(self_total_gift) .. "kg"
end
food_order = "喂食茉莉"
msg_order[food_order] = "rcv_food"

function show_favor(msg)
    local favor, cohesion, affinity = GetUserConf("favorConf", msg.uid, {"好感度", "cohesion", "affinity"}, {0, 0, 0})
    local state = ShowFavorHandle(msg, favor, affinity)
    local header =
        "[CQ:image,url=http://q1.qlogo.cn/g?b=qq&nk=" ..
        msg.uid .. "&s=640]\n\n亲密度：" .. cohesion .. " | 亲和度：" .. affinity .. " | " .. state
    if (favor < 3000) then
        return header ..
            "对{nick}的好感度只有" ..
                favor .. "，要加油哦~\n茉莉...可是很期待{sample:我们之间能发生什么故事的哦？|你的表现的哦？|你能...（摇头），不，不，没什么|的哦，可这次...茉莉能做好吗}"
    elseif (favor < 6000) then
        return header ..
            "对{nick}的好感度有" .. favor .. "\n{sample:还真是发生了不少事情呢，对吧？~|茉莉要好好记下和你在一起的点点滴滴|最近对茉莉的照顾...我很感激...能不能...}"
    elseif (favor < 10000) then
        return header ..
            "好感度到" ..
                favor .. "了~\n{sample:有时候我会想，说不定真能...嗯嗯？没，我什么都没说，对吧对吧|你总能给茉莉带来很多快乐呢|最近茉莉总有点心神不宁...算了不想了，反正和你在一起就好啦~}"
    else
        return header ..
            "对{nick}的好感度已经有" ..
                favor ..
                    "了,以后也要永远在一起哦~\n{sample:真是的...明明...还要确认一下感情吗（嘟嘴）|茉莉当初没有想到，你会一直 一直陪在茉莉身边...|茉莉觉得，只要和你一直走下去，一定能抓住属于我们的未来的吧？|遇见你之后，我才明白，原来回忆是这么让人快乐和温暖的事|那些独自做不到的事，就让我们一起来把握吧|总感觉，只有和你在一起，茉莉才能看到曾经看不见的『可能性』呢}"
    end
end
msg_order["茉莉好感"] = "show_favor"

-- 早安问候互动程序
function rcv_Ciallo_morning(msg)
    -- 每天第一次早安加5好感度
    local preReply = preHandle(msg)
    if (preReply ~= nil) then
        return preReply
    end
    local today_morning = GetUserToday(msg.uid, "morning", 0)
    local favor, affinity = GetUserConf("favorConf", msg.uid, {"好感度", "affinity"}, {0, 0})
    local mood, special_mood, coefficient =
        GetUserConf("favorConf", msg.uid, {"mood", "special_mood", "coefficient"}, {0, 0, 0})
    coefficient = get_coefficient(special_mood, coefficient, {"振奋", "枯燥"})

    local favor_ori = favor
    today_morning = today_morning + 1
    SetUserToday(msg.uid, "morning", today_morning)
    -- 用于判定成功/失败，增加校准
    local t1, t2, t3, calibration_message = ModifyLimit(msg, favor, affinity)
    if (calibration_message ~= nil) then
        return calibration_message
    end
    -- 其他用户判定
    if (hour >= 5 and hour <= 10) then
        SetUserToday(msg.uid, "morning", today_morning + 1)
        local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
        if (calibration_message1 ~= nil) then
            if (calibration_message1 ~= nil) then
                return calibration_message1
            end
            if (succ == false) then
                return "诶？早上好...那我先去准备早饭，有点心不在焉？不不，没有的事"
            end
            local favor_now = favor + ModifyFavorChangeNormal(msg, favor, 5 * coefficient, affinity, true)
            if (today_morning <= 1) then
                -- SetUserConf("favorConf", msg.uid, "好感度", favor_now)
                CheckFavor(msg.uid, favor_ori, favor_now, affinity)
            end
            if (favor < 0) then
                return table_draw(reply_ciallo_lowest)
            elseif (favor < ranint(1500 - left_limit, 1500 + right_limit)) then
                return table_draw(reply_morning_less)
            elseif (favor < ranint(4500 - left_limit, 4500 + right_limit)) then
                return table_draw(reply_morning_low)
            elseif (favor < ranint(6000 - left_limit, 6000 + right_limit)) then
                return table_draw(reply_morning_high)
            else
                return table_draw(reply_morning_highest)
            end
        elseif (hour == 23 or (hour >= 0 and hour <= 2)) then
            return table_draw(relpy_morning_nightWrong)
        elseif (hour >= 11 and hour <= 15) then
            return table_draw(reply_morning_afternoonWrong)
        else
            return table_draw(reply_morning_normalWrong)
        end
    end
end
-- 可能的早安问候池(前缀匹配)
msg_order["早上好茉莉"] = "rcv_Ciallo_morning"
msg_order["茉莉酱早"] = "rcv_Ciallo_morning"
msg_order["早啊茉莉"] = "rcv_Ciallo_morning"
msg_order["茉莉早"] = "rcv_Ciallo_morning"
msg_order["早上好啊茉莉"] = "rcv_Ciallo_morning"
msg_order["早上好哟茉莉"] = "rcv_Ciallo_morning"
msg_order["早安茉莉"] = "rcv_Ciallo_morning"

function rcv_Ciallo_morning_master(msg)
    local today_morning = GetUserToday(msg.uid, "morning", 0)
    local favor, affinity = GetUserConf("favorConf", msg.uid, {"好感度", "affinity"}, {0, 0})
    today_morning = today_morning + 1
    SetUserToday(msg.uid, "morning", today_morning)
    if (search_keywords(msg.fromMsg, {"早", "早上好", "早啊", "早呀", "早安", "早哟"}) and msg.fromMsg:find("茉莉") == nil) then
        if (favor >= 1200) then
            if (hour >= 5 and hour <= 10) then
                return "诶诶诶{nick}早上好！今天是来找茉莉玩的吗？"
            else
                return "唔...{nick}难道是在和另一个自己对话吗...因为现在怎么看都不是早上的样子..."
            end
        end
    end
end
msg_order["早"] = "rcv_Ciallo_morning_master"

-- 午安问候程序（不触发好感事件）
function rcv_Ciallo_afternoon(msg)
    local preReply = preHandle(msg)
    if (preReply ~= nil) then
        return preReply
    end
    local favor, affinity = GetUserConf("favorConf", msg.uid, {"好感度", "affinity"}, {0, 0})
    local mood, special_mood, coefficient =
        GetUserConf("favorConf", msg.uid, {"mood", "special_mood", "coefficient"}, {0, 0, 0})
    coefficient = get_coefficient(special_mood, coefficient, {"振奋", "枯燥"})

    local today_noon = GetUserToday(msg.uid, "noon", 0)
    local favor_ori = favor
    if (favor < -600) then
        return ""
    end
    if (hour > 7 and hour < 11) then
        return "诶..可现在还没到中午诶，是茉莉出故障了吗..."
    end
    if (hour >= 18 or hour <= 6) then
        return "茉莉这次才不会搞错呢！才不会被{nick}这种小花招骗到！外面明明那么黑（指着窗外）"
    end

    SetUserToday(msg.uid, "noon", today_noon + 1)
    local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
    if (calibration_message1 ~= nil) then
        return calibration_message1
    end
    if (succ == false) then
        return "啊...？嗯...{nick}午安，很抱歉，能让茉莉一个人待一会吗"
    end
    if (today_noon < __LIMIT_PER_DAY__.noon) then
        local favor_now = favor + ModifyFavorChangeNormal(msg, favor, 5 * coefficient, affinity, succ)
        -- SetUserConf("favorConf", msg.uid, "好感度", favor_now)
        CheckFavor(msg.uid, favor_ori, favor_now, affinity)
    end
    if (favor < 0) then
        return table_draw(reply_ciallo_lowest)
    elseif (favor < ranint(1500 - left_limit, 1500 + right_limit)) then
        return "嗯？要睡午觉了吗，也是，养好精神也很重要呢"
    elseif (favor < ranint(4000 - left_limit, 4000 + right_limit)) then
        return "午安哦，茉莉也有点困了...呼呼呼"
    elseif (favor < ranint(6000 - left_limit, 6000 + right_limit)) then
        return "诶要睡了吗，好、好吧...之后记得找茉莉玩哦"
    else
        return "嗯呐，在你午睡的时候，请让茉莉在一旁陪着你吧#依"
    end
end
msg_order["午安茉莉"] = "rcv_Ciallo_afternoon"
msg_order["茉莉午安"] = "rcv_Ciallo_afternoon"
msg_order["茉莉酱午安"] = "rcv_Ciallo_afternoon"

-- 非指向性午安判断程序
function afternoon_special(msg)
    local favor = GetUserConf("favorConf", msg.uid, "好感度", 0)

    if (favor >= 1200) then
        return "嗯嗯" .. " 午安" .. "，这是茉莉凭个 人 意 愿想对你说的哦~"
    end
end
msg_order["午安"] = "afternoon_special"

-- 指代性中午好
function rcv_Ciallo_noon(msg)
    local preReply = preHandle(msg)
    if (preReply ~= nil) then
        return preReply
    end
    local today_noon = GetUserToday(msg.uid, "noon", 0)
    local favor, affinity = GetUserConf("favorConf", msg.uid, {"好感度", "affinity"}, {0, 0})
    local mood, special_mood, coefficient =
        GetUserConf("favorConf", msg.uid, {"mood", "special_mood", "coefficient"}, {0, 0, 0})
    coefficient = get_coefficient(special_mood, coefficient, {"振奋", "枯燥"})

    local favor_ori = favor
    if hour < 11 or hour > 14 then
        return "咦，现在，是中午？好吧，既然{nick}这么说，那么，中午好！"
    end

    SetUserToday(msg.uid, "today_noon", today_noon + 1)
    local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
    if (calibration_message1 ~= nil) then
        return calibration_message1
    end
    if (succ == false) then
        return "中午好。嗯...?你说就没有其他的话了...?"
    end
    if (today_noon < __LIMIT_PER_DAY__.noon) then
        local favor_now = favor + ModifyFavorChangeNormal(msg, favor, 5 * coefficient, affinity, succ)
        -- SetUserConf("favorConf", msg.uid, "好感度", favor_now)
        CheckFavor(msg.uid, favor_ori, favor_now, affinity)
    end
    if (favor < 0) then
        return table_draw(reply_ciallo_lowest)
    elseif (favor <= ranint(1500 - left_limit, 1500 + right_limit)) then
        return "唔，中午好！{nick}，吃过午饭了吗？吃过就赶快去休息吧"
    elseif (favor <= ranint(4500 - left_limit, 4500 + right_limit)) then
        return "中午好呀{nick}——今天过去一半了哦，有什么要做的就抓紧吧"
    elseif (favor <= ranint(6000 - left_limit, 6000 + right_limit)) then
        return "中，中午好{nick}，是有什么要和茉莉说吗！"
    else
        return "中↘午↗好——呀！想睡觉了呢...在那之前#拉衣角 再陪茉莉玩一会吧"
    end
end
msg_order["中午好茉莉"] = "rcv_Ciallo_noon"
msg_order["茉莉中午好"] = "rcv_Ciallo_noon"
msg_order["茉莉酱中午好"] = "rcv_Ciallo_noon"
msg_order["中午好呀茉莉"] = "rcv_Ciallo_noon"
msg_order["中午好啊茉莉"] = "rcv_Ciallo_noon"
msg_order["中午好哟茉莉"] = "rcv_Ciallo_noon"

-- 非指向性中午好
function Ciallo_noon_normal(msg)
    local favor = GetUserConf("favorConf", msg.uid, "好感度", 0)

    if (favor >= 1200) then
        if (hour >= 11 and hour <= 14) then
            return "诶，中午好？是…在和茉莉说吗，应该……是吧"
        end
        return "唔..可现在不是中午哦？不过 茉莉也向你问好哦~#踮起脚尖打招呼"
    end
end
msg_order["中午好"] = "Ciallo_noon_normal"

-- 晚上好
function rcv_Ciallo_evening(msg)
    local preReply = preHandle(msg)
    if (preReply ~= nil) then
        return preReply
    end
    local today_evening = GetUserToday(msg.uid, "evening", 0)
    local favor, affinity = GetUserConf("favorConf", msg.uid, {"好感度", "affinity"}, {0, 0})
    local mood, special_mood, coefficient =
        GetUserConf("favorConf", msg.uid, {"mood", "special_mood", "coefficient"}, {0, 0, 0})
    coefficient = get_coefficient(special_mood, coefficient, {"振奋", "枯燥"})

    local favor_ori = favor
    today_evening = today_evening + 1
    SetUserToday(msg.uid, "evening", today_evening)

    if ((hour >= 18 and hour <= 24) or (hour >= 0 and hour <= 4)) then
        local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
        if (calibration_message1 ~= nil) then
            return calibration_message1
        end
        if (succ == false) then
            return "女孩似乎没有理睬你的意思，只是怔怔望着窗外，若有所思×"
        end
        if (today_evening <= 1) then
            local favor_now = favor + ModifyFavorChangeNormal(msg, favor, 5 * coefficient, affinity, succ)
            CheckFavor(msg.uid, favor_ori, favor_now, affinity)
        end
        if favor < 0 then
            return table_draw(reply_ciallo_lowest)
        elseif (favor < ranint(1500 - left_limit, 1500 + right_limit)) then
            return table_draw(reply_evening_less)
        elseif (favor < ranint(4500 - left_limit, 4500 + right_limit)) then
            return table_draw(reply_evening_low)
        elseif (favor < ranint(6000 - left_limit, 6000 + right_limit)) then
            return table_draw(reply_evening_high)
        else
            return table_draw(reply_evening_highest)
        end
    elseif (hour >= 5 and hour <= 12) then
        return table_draw(reply_evening_morningWrong)
    else
        return table_draw(reply_evening_normalWrong)
    end
end
msg_order["茉莉晚上好"] = "rcv_Ciallo_evening"
msg_order["晚上好茉莉"] = "rcv_Ciallo_evening"

-- 晚安问候程序
function rcv_Ciallo_night(msg)
    local preReply = preHandle(msg)
    if (preReply ~= nil) then
        return preReply
    end
    local today_night = GetUserToday(msg.uid, "night", 0)
    local favor, affinity = GetUserConf("favorConf", msg.uid, {"好感度", "affinity"}, {0, 0})
    local mood, special_mood, coefficient =
        GetUserConf("favorConf", msg.uid, {"mood", "special_mood", "coefficient"}, {0, 0, 0})
    coefficient = get_coefficient(special_mood, coefficient, {"振奋", "枯燥"})

    local favor_ori = favor
    today_night = today_night + 1
    SetUserToday(msg.uid, "night", today_night)

    if ((hour >= 21 and hour <= 23) or (hour >= 0 and hour <= 4)) then
        local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
        if (calibration_message1 ~= nil) then
            return calibration_message1
        end
        if (succ == false) then
            return "那茉莉就回自己房间了，晚安，明早见"
        end
        if (today_night <= 1) then
            local favor_now = favor + ModifyFavorChangeNormal(msg, favor, 5 * coefficient, affinity, succ)
            -- SetUserConf("favorConf", msg.uid, "好感度", favor_now)
            CheckFavor(msg.uid, favor_ori, favor_now, affinity)
        end
        if favor < 0 then
            return table_draw(reply_ciallo_lowest)
        elseif (favor < ranint(1500 - left_limit, 1500 + right_limit)) then
            return table_draw(reply_night_less)
        elseif (favor < ranint(4500 - left_limit, 4500 + right_limit)) then
            return table_draw(reply_night_low)
        elseif (favor < ranint(6000 - left_limit, 6000 + right_limit)) then
            return table_draw(reply_night_high)
        else
            --! 1298754454 晚安定制
            if msg.uid == "1298754454" then
                return table_draw(merge_reply(reply_night_highest, evening_1298754454))
            end
            return table_draw(reply_night_highest)
        end
    elseif (hour >= 5 and hour <= 11) then
        return table_draw(reply_night_morningWrong)
    elseif (hour >= 12 and hour <= 15) then
        return table_draw(reply_night_afternoonWrong)
    else
        return table_draw(reply_night_normalWrong)
    end
end
-- 可能的晚安问候池(前缀匹配)
msg_order["晚安茉莉"] = "rcv_Ciallo_night"
msg_order["茉莉酱晚安"] = "rcv_Ciallo_night"
msg_order["茉莉晚安"] = "rcv_Ciallo_night"
msg_order["晚安啊茉莉"] = "rcv_Ciallo_night"
msg_order["茉莉哦呀斯密纳塞"] = "rcv_Ciallo_night"
msg_order["茉莉哦呀斯密"] = "rcv_Ciallo_night"

function night_master(msg)
    local favor = GetUserConf("favorConf", msg.uid, "好感度", 0)
    if (favor >= 2000) then
        preHandle(msg)
        if ((hour >= 21 and hour <= 23) or (hour >= 0 and hour <= 4)) then
            return "{sample:晚安哦，虽然不知道为什么，但茉莉想主动对你说晚安~|希望明天我们能依然保持赤诚和热爱|晚安，茉莉会在你身边安心陪你睡着的哦？|晚安~愿你梦中星河烂漫，美好依旧}"
        end
        return "嗯...{nick}现在好像还没到晚安的时间呢..."
    end
end

msg_order["晚安"] = "night_master"

-- 关于晚安、午安的其他表达
function Ciallo_night_2(msg)
    local favor, affinity = GetUserConf("favorConf", msg.uid, {"好感度", "affinity"}, {0, 0})
    local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
    if (calibration_message1 ~= nil) then
        return calibration_message1
    end
    if (succ == false) then
        return ""
    end

    if (favor < ranint(1000 - left_limit, 1000 + right_limit)) then
        return table_draw(reply_night_less)
    elseif (favor < ranint(2000 - left_limit, 2000 + right_limit)) then
        return table_draw(reply_night_low)
    elseif (favor < ranint(3000 - left_limit, 3000 + right_limit)) then
        return table_draw(reply_night_high)
    else
        return table_draw(reply_night_highest)
    end
end
msg_order["睡了"] = "Ciallo_night_2"
msg_order["我睡了"] = "Ciallo_night_2"

-- 动作交互系统
interaction_order = "茉莉 互动 "
function interaction(msg)
    local preReply = preHandle(msg)
    if (preReply ~= nil) then
        return preReply
    end
    local favor, affinity = GetUserConf("favorConf", msg.uid, {"好感度", "affinity"}, {0, 0})
    local mood, special_mood, coefficient =
        GetUserConf("favorConf", msg.uid, {"mood", "special_mood", "coefficient"}, {0, 0, 0})
    coefficient = get_coefficient(special_mood, coefficient, {"振奋", "枯燥"})

    local today_interaction = GetUserToday(msg.uid, "今日互动", 0)
    local favor_ori = favor
    today_interaction = today_interaction + 1
    SetUserToday(msg.uid, "今日互动", today_interaction)
    local blackReply = blackList(msg)
    if (blackReply ~= "" and blackReply ~= "已触发！") then
        return blackReply
    elseif (blackReply == "已触发！") then
        return ""
    end
    local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
    if (calibration_message1) then
        return calibration_message1
    end
    if (succ == false) then
        return "茉莉向后退了一步，并对你比了个“×”的手势×"
    end
    local level, favor_now, favor_add
    if (favor <= ranint(1500 - left_limit, 1500 + right_limit)) then
        level = 1
        SetUserConf("favorConf", msg.uid, "好感度", favor - ModifyFavorChangeNormal(msg, favor, ranint(50, 100), affinity))
    else
        if (favor <= ranint(3000 - left_limit, 3000 + right_limit)) then
            level = 2
            favor_add = ranint(5, 8)
        elseif (favor <= ranint(5000 - left_limit, 5000 + right_limit)) then
            level = 3
            favor_add = ranint(12, 25)
        else
            level = 4
            favor_add = ranint(15, 30)
        end
        if (today_interaction <= __LIMIT_PER_DAY__.interaction) then
            favor_now = favor + ModifyFavorChangeNormal(msg, favor, favor_add * coefficient, affinity)
            CheckFavor(msg.uid, favor_ori, favor_now, affinity)
        end
    end
    local part = msg.fromMsg:match("[%s]*(%S*)", #interaction_order + 1)
    if (part == "") then
        return "茉莉无法解析您的指令哦"
    end
    local convert_part = {
        ["头"] = "head",
        ["脸"] = "face",
        ["身体"] = "body",
        ["脖子"] = "neck",
        ["背"] = "back",
        ["腰"] = "waist",
        ["腿"] = "leg",
        ["手"] = "hand",
        ["肩"] = "shoulder",
        ["肩膀"] = "shoulder"
    }
    part = convert_part[part]
    return table_draw(__REPLY__[part][level][mood])
end
msg_order[interaction_order] = "interaction"

normal_order = "茉莉"
-- 普通问候程序
function _Ciallo_normal(msg)
    local ignore_qq = {959686587}
    --! 千音暂时不回复，以及定制reply
    for _, v in pairs(ignore_qq) do
        if msg.uid * 1 == v then
            return ""
        end
    end
    if (msg.uid == "839968342") then
        if (search_keywords(msg.fromMsg, {"茉莉?", "茉莉？"})) then
            return ""
        end
    end
    local str = string.match(msg.fromMsg, "(.*)", #normal_order + 1)
    local flag =
        search_keywords(
        str,
        {
            "在",
            "——",
            "？",
            "~",
            "！",
            "!",
            "?",
            "吗",
            "呢",
            "茉莉",
            "酱"
        }
    )
    if (msg.fromMsg == "茉莉") then
        flag = true
    end
    if (flag == false) then
        return ""
    end
    local favor = GetUserConf("favorConf", msg.uid, "好感度", 0)
    if (favor < -600) then
        return ""
    end

    --! 定制reply
    if msg.uid == "2595928998" then
        reply_main = table_draw(normal_2595928998)
    elseif msg.uid == "751766424" then
        reply_main = table_draw(normal_751766424)
    else
        reply_main = "{sample:嗯哼？茉莉在这哦~Ciallo|诶...是在叫茉莉吗？茉莉茉莉在哦~|我听到了！就是{nick}在叫我！这次一定没有错！}"
    end
end

function action(msg)
    if (Actionprehandle(msg.fromMsg) == false) then
        return ""
    end
    local preReply = preHandle(msg)
    if (preReply ~= nil) then
        return preReply
    end
    local favor, affinity = GetUserConf("favorConf", msg.uid, {"好感度", "affinity"}, {0, 0})
    local favor_ori, favor_now = favor, favor
    local mood, special_mood, coefficient =
        GetUserConf("favorConf", msg.uid, {"mood", "special_mood", "coefficient"}, {0, 0, 0})
    coefficient = get_coefficient(special_mood, coefficient, {"振奋", "枯燥"})

    local blackReply = blackList(msg)
    if (blackReply ~= "" and blackReply ~= "已触发！") then
        return blackReply
    elseif (blackReply == "已触发！") then
        return ""
    end

    if msg.fromMsg:find("抱") then
        return action_function(msg, {1500, 3000, 6000}, {-90, 8, 15, 20}, "hug", favor_ori, affinity, mood, coefficient)
    elseif msg.fromMsg:find("摸") then
        return action_function(
            msg,
            {1000, 2000, 4500},
            {-30, 8, 12, 16},
            "head",
            favor_ori,
            affinity,
            mood,
            coefficient
        )
    elseif msg.fromMsg:find("亲") then
        return action_function(
            msg,
            {2000, 3200, 7000},
            {-100, -20, 15, 25},
            "kiss",
            favor_ori,
            affinity,
            mood,
            coefficient
        )
    elseif msg.fromMsg:find("举高高") then
        return action_function(
            msg,
            {1550, 3200, 6800},
            {-80, 10, 14, 18},
            "lift",
            favor_ori,
            affinity,
            mood,
            coefficient
        )
    elseif msg.fromMsg:find("牵手") then
        return action_function(
            msg,
            {1200, 3000, 5500},
            {-40, 8, 10, 12},
            "hand",
            favor_ori,
            affinity,
            mood,
            coefficient
        )
    elseif msg.fromMsg:find("脸") then
        return action_function(
            msg,
            {1100, 3000, 5000},
            {-40, 5, 10, 15},
            "face",
            favor_ori,
            affinity,
            mood,
            coefficient
        )
    elseif search_keywords(msg.fromMsg, {"可爱", "萌", "卡哇伊", "kawai", "kawayi"}) then
        return action_function(msg, {1050, 3000, 4000}, {8, 10, 12, 14}, "cute", favor_ori, affinity, mood, coefficient)
    elseif search_keywords(msg.fromMsg, {"喜欢", "suki"}) then
        return action_function(msg, {1500, 3500, 5500}, {9, 12, 15, 20}, "suki", favor_ori, affinity, mood, coefficient)
    elseif search_keywords(msg.fromMsg, {"爱", "love"}) then
        return action_function(
            msg,
            {2000, 4500, 6500},
            {12, 15, 20, 23},
            "love",
            favor_ori,
            affinity,
            mood,
            coefficient
        )
    elseif msg.fromMsg:find("贴贴") then
        return action_function(
            msg,
            {1500, 3500, 5500},
            {-40, 10, 13, 15},
            "tietie",
            favor_ori,
            affinity,
            mood,
            coefficient
        )
    elseif (msg.uid == "2595928998" and msg.fromMsg:find("蹭蹭")) then
        --! 灵音定制 蹭蹭
        today_cengceng = today_cengceng + 1
        SetUserToday(msg.uid, "cengceng", today_cengceng)
        if today_cengceng <= __LIMIT_PER_DAY__.cengceng then
            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 20, affinity, true)
        end
        return table_draw(cengceng_2595928998)
    elseif msg.fromMsg:find("膝枕") then
        local reply_main = ""
        if favor <= ranint(8000, 8000) then
            favor_now = favor + ModifyFavorChangeNormal(msg, favor, -20, affinity, true)
            reply_main = "嗯...？{nick}是生病了吧？怎么会说出这样的要求呢？茉莉无法答应哦。"
        elseif GetUserConf("storyConf", msg.uid, "isSpecial5Read", 0) == 0 then
            reply_main = "{nick}想要膝枕吗？现在茉莉有些忙，可以等下次再说吗？\n（解锁条件：阅读剧情『夜』）"
        elseif today_lapPillow >= __LIMIT_PER_DAY__.lapPillow then
            reply_main = "茉莉刚才不是已经安慰过{nick}了吗？真是的...怎么和小孩子一样啊....好吧，只能再休息一下下哦？"
        else
            today_lapPillow = today_lapPillow + 1
            SetUserToday(msg.uid, "lapPillow", today_lapPillow)
            reply_main = table_draw(reply_lapPillow)
            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 20, affinity, true)
        end
        CheckFavor(msg.uid, favor_ori, favor_now, affinity)
        return reply_main
    end
end

-- 执行函数相应“茉莉”
function action_main(msg)
    local reply_main = action(msg)

    if (reply_main) then
        return reply_main
    end
    return _Ciallo_normal(msg)
end
msg_order[normal_order] = "action_main"

--[[
    用于执行函数相应“茉莉”.
    msg: 消息体
    boundary: 好感度变化的边界，数组
    favor_change: 好感度变化，数组
    action_name: 动作名称
    favor_ori: 原始好感度
    affinity: 亲密度
    mood: 心情
    coefficient: 心情系数
]]
function action_function(msg, boundary, favor_change, action_name, favor_ori, affinity, mood, coefficient)
    local succ, left_limit, right_limit, calibration_message = ModifyLimit(msg, favor_ori, affinity)
    local favor_now = favor_ori
    if (calibration_message) then
        return calibration_message
    end
    if not succ then
        favor_now = favor_ori + ModifyFavorChangeNormal(msg, favor_ori, -10, affinity, succ)
        CheckFavor(msg.uid, favor_ori, favor_now, affinity)
        return table_draw(__REPLY_FAILED__[action_name])
    end
    -- 依次检查各个好感等级
    for i = 1, #boundary + 1 do
        if i == #boundary + 1 or favor_ori <= ranint(boundary[i] - left_limit, boundary[i] + right_limit) then
            local today_times = GetUserToday(msg.uid, action_name, 0)
            if today_times < __LIMIT_PER_DAY__[action_name] or favor_change[i] < 0 then
                -- 如果是获取好感，则需要受到心情系数的修正
                if favor_change[i] > 0 then
                    favor_change[i] = favor_change[i] * coefficient
                end
                favor_now = favor_ori + ModifyFavorChangeNormal(msg, favor_ori, favor_change[i], affinity, succ)
                CheckFavor(msg.uid, favor_ori, favor_now, affinity)
                SetUserToday(msg.uid, action_name, today_times + 1)
            end
            return table_draw(__REPLY__[action_name][i][mood])
        end
    end
end

function search_keywords(str, keywords)
    for _, v in pairs(keywords) do
        if str:find(v) then
            return true
        end
    end
    return false
end

--! 注册指令
function register(msg)
    setUserConf(msg.uid, "isRegister", 1)
    return "信息已录入...欢迎您，{nick}，希望能和你一起创造美好的回忆~"
end
msg_order["我已阅读并理解茉莉协议，同意接受以上服务条款"] = "register"

function table_draw(tab)
    return tab[ranint(1, #tab)]
end
