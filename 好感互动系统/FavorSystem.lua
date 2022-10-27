---@diagnostic disable: lowercase-global
--[[
    @author 慕北_Innocent(RainChain)
    @version 4.5
    @Created 2021/08/19 13:16
    @Last Modified 2022/03/31 23:36
    ]] -- 载入回复模块
package.path = getDiceDir() .. "/plugin/ReplyAndDescription/?.lua"
require "favorReply"
require "itemDescription"
package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"
package.path = getDiceDir() .. "/plugin/handle/?.lua"
require "prehandle"
require "favorhandle"
require "showfavorhandle"
require "CustomizedReply"
msg_order = {}

-- 各类上限
today_food_limit = 3 -- 单日喂食次数上限
today_morning_limit = 1 -- 单日早安好感增加次数上限
today_night_limit = 1 -- 每日晚安好感增加次数上限
today_noon_limit = 1 -- 每日午安上限
today_hug_limit = 1 -- 每日拥抱加好感次数上限
today_touch_limit = 1 -- 每日摸头加好感次数上限
today_lift_limit = 1 -- 每日举高高加好感次数上限
today_kiss_limit = 1 -- 每日kiss加好感次数上限
today_hand_limit = 1 -- 每日牵手加好感次数上限
today_face_limit = 1 -- 每日捏/揉脸加好感次数上限
today_suki_limit = 1 -- 每日喜欢加好感次数上限
today_love_limit = 1 -- 每日爱加好感次数上限
today_interaction_limit = 3 -- 每日"互动-部位"增加好感次数上限
today_cute_limit = 1
today_tietie_limit = 1
today_cengceng_limit = 1
flag_food = 0 -- 用于标记多次喂食只回复一次
cnt = 0 -- 用户输入的喂食次数
-- 时间系统
hour = os.date("*t").hour * 1
minute = os.date("%M") * 1
month = os.date("%m") * 1
day = os.date("%d") * 1
year = os.date("%Y") * 1
-- do
--     if(hour>=16 and hour<=23)then
--         hour=0+8-(24-hour)         --GMT时间转北京时间
--     end
-- end

--! 校准
function Calibrated()
    local reply = "『✖Error』当前时钟周期仍未结束哦"
    if (calibration >= calibration_limit) then
        if (getUserConf(getDiceQQ(), "blockCalibration", 0) == 1) then
            return "『✖Error』当前已有『校准』在进行中！"
        end
        -- 1/5概率成功,1/5概率失败,3/5概率普通成功
        local res, calibration_list = ranint(1, 5), getUserConf(getDiceQQ(), "calibration_list", {})
        --! 阻塞后续校准
        setUserConf(getDiceQQ(), "blockCalibration", 1)
        --成功
        if (res == 1) then
            for k, v in pairs(calibration_list) do
                if (v > 0) then
                    local favor, affinity = GetUserConf("favorConf", k, {"好感度", "affinity"}, {0, 0})
                    local favor_now = favor + v
                    -- SetUserConf("favorConf", k, "好感度", favor_now)
                    CheckFavor(k, favor, favor_now, affinity)
                end
            end
            reply = "叮——一次完美的校准！茉莉看起来很开心，新的周期已经开始"
        elseif (res == 5) then
            for k, v in pairs(calibration_list) do
                local favor = GetUserConf("favorConf", k, "好感度", 0)
                if (v > 0) then
                    SetUserConf("favorConf", k, "好感度", favor - (v + (calibration_limit - 12)))
                else
                    SetUserConf("favorConf", k, "好感度", favor + v - (calibration_limit - 12))
                end
            end
            reply = "校准...失败了！茉莉似乎忘记了一些事情，但愿不要发生糟糕的事...新的周期已经开始"
        else
            reply = "一次成功的校准！你成功将这些记忆保存了下来，新的周期已经开始"
        end
        setUserConf(getDiceQQ(), "calibration_list", {})
        setUserConf(getDiceQQ(), "calibration", 0)
        setUserConf(getDiceQQ(), "calibration_limit", 12)
        setUserConf(getDiceQQ(), "blockCalibration", 0)
    end
    return reply
end
msg_order["茉莉校准"] = "Calibrated"

function ClearCalibratedBlock(msg)
    setUserConf(getDiceQQ(), "blockCalibration", 0)
    return "成功清除校准阻塞"
end
msg_order["清除校准阻塞"] = "ClearCalibratedBlock"

function topercent(num)
    if (num == nil) then
        return ""
    end
    return string.format("%.2f", num / 100)
end

function add_favor_food(msg, favor, affinity)
    -- 随机好感上升,低好感用户翻倍
    if (favor <= 1500) then
        return ModifyFavorChangeGift(msg, favor, ranint(30, 50), affinity, false)
    elseif (favor <= 4000) then
        return ModifyFavorChangeGift(msg, favor, ranint(20, 30), affinity, false)
    elseif (favor <= 10000) then
        return ModifyFavorChangeGift(msg, favor, ranint(15, 20), affinity, false)
    else
        return ModifyFavorChangeGift(msg, favor, ranint(20, 30), affinity, false)
    end
end
function add_gift_once() -- 单次计数上升
    return 5
    -- return ranint(1,10)
end

-- 下限黑名单判定
function blackList(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    if (favor <= -200 and favor > -500) then
        sendMsg("Warning:检测到你的好感度过低，即将触发机体下限保护机制！", msg.fromGroup or 0, msg.fromQQ)
    end
    if (favor < -500) then
        sendMsg("Warning:检测到用户" .. msg.fromQQ .. "触发好感下限" .. "在群" .. msg.fromGroup, 0, 2677409596)
        sendMsg("Warning:检测到用户" .. msg.fromQQ .. "触发好感下限" .. "在群" .. msg.fromGroup, 0, 3032902237)
        eventMsg(
            ".group " .. msg.fromGroup .. " ban " .. msg.fromQQ .. " " .. tostring(-favor),
            msg.fromGroup,
            getDiceQQ()
        )
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
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    local favor, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
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
    if (msg.fromQQ == "2677409596") then
        if ((today_rude >= 4 and today_sorry == 0) or today_sorry >= 2) then
            return "哼，笨蛋主人，我才不吃你的东西呢"
        end
    else
        if ((today_rude >= 3 and today_sorry == 0) or today_sorry >= 2) then
            return "主人告诉我不要吃坏人给的东西！"
        end
    end
    -- 判定当日上限
    local today_gift = GetUserToday(msg.fromQQ, "gifts", 0)
    if (today_gift >= today_food_limit) then
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
    if (today_sorry == 0) then
        -- 循环调用
        while (cnt > 0) do
            local favor_ori, favor_add, calibration_message = favor, 0, nil
            favor_add, calibration_message = add_favor_food(msg, favor_ori, affinity)
            if (calibration_message ~= nil) then
                return calibration_message
            end
            today_gift = today_gift + 1
            SetUserToday(msg.fromQQ, "gifts", today_gift)
            if (today_gift > today_food_limit) then
                break
            end
            favor = favor_ori + favor_add
            -- SetUserConf("favorConf", msg.fromQQ, "好感度", favor)
            favor, affinity = CheckFavor(msg.fromQQ, favor_ori, favor, affinity)
            cnt = cnt - 1
        end
        return "你眼前一黑，手中的食物瞬间消失，再看的时候，眼前的烧酒口中还在咀嚼着什么，扭头躲开了你的目光\n今日已收到投喂" ..
            topercent(self_today_gift) .. "kg\n累计投喂" .. topercent(self_total_gift) .. "kg"
    else
        if (msg.fromQQ == "2677409596") then
            SetUserToday(msg.fromQQ, "hug_needed_to_sorry", 1) -- 设定需要抱茉莉以道歉的次数
            return "#咀嚼声 哼...唔，主人可别认为这样我就会原谅你！#扭捏着 抱、抱我！"
        else
            if (favor >= 1500) then
                SetUserToday(msg.fromQQ, "hug_needed_to_sorry", 1) -- 设定需要抱茉莉以道歉的次数
                return "好、好吃！...不！不对！你如果不抱我的话我绝不原谅你！#撇过头"
            else
                SetUserToday(msg.fromQQ, "rude", 0)
                return "哼，行吧，茉莉这次就原谅你，下次记得别这样了啊，茉莉我可是很宽容的~#笑"
            end
        end
    end
end
food_order = "喂食茉莉"
msg_order[food_order] = "rcv_food"

function show_favor(msg)
    local favor, cohesion, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "cohesion", "affinity"}, {0, 0, 0})
    local state = ShowFavorHandle(msg, favor, affinity)
    local header =
        "[CQ:image,url=http://q1.qlogo.cn/g?b=qq&nk=" ..
        msg.fromQQ .. "&s=640]\n\n亲密度：" .. cohesion .. " | 亲和度：" .. affinity .. " | " .. state
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
    local today_morning, today_rude, today_sorry = GetUserToday(msg.fromQQ, {"morning", "rude", "sorry"}, {0, 0, 0})
    local favor, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
    local favor_ori = favor
    today_morning = today_morning + 1
    SetUserToday(msg.fromQQ, "morning", today_morning)
    -- 用于判定成功/失败，增加校准
    local t1, t2, t3, calibration_message = ModifyLimit(msg, favor, affinity)
    if (calibration_message ~= nil) then
        return calibration_message
    end
    -- 其他用户判定
    if (today_rude >= 3 or today_sorry >= 2) then
        return "Error!出现机体故障！没有听清！"
    else
        if (hour >= 5 and hour <= 10) then
            SetUserToday(msg.fromQQ, "morning", today_morning + 1)
            local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
            if (calibration_message1 ~= nil) then
                return calibration_message1
            end
            if (succ == false) then
                return "诶？早上好...那我先去准备早饭，有点心不在焉？不不，没有的事"
            end
            local favor_now = favor + ModifyFavorChangeNormal(msg, favor, 5, affinity, true)
            if (today_morning <= 1) then
                -- SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
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

-- 爱酱特殊问候关键词触发程序
function rcv_Ciallo_morning_master(msg)
    local today_morning, today_rude, today_sorry = GetUserToday(msg.fromQQ, {"morning", "rude", "sorry"}, {0, 0, 0})
    local favor, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
    -- 关键词匹配
    local judge =
        msg.fromMsg == "早" or string.find(msg.fromMsg, "早上好", 1) ~= nil or string.find(msg.fromMsg, "早啊", 1) ~= nil or
        string.find(msg.fromMsg, "早呀", 1) ~= nil or
        string.find(msg.fromMsg, "早安", 1) ~= nil or
        string.find(msg.fromMsg, "早哟", 1) ~= nil
    local special_judge = string.find(msg.fromMsg, "茉莉", 1) == nil
    today_morning = today_morning + 1
    SetUserToday(msg.fromQQ, "morning", today_morning)
    if (judge and special_judge) then
        if (msg.fromQQ == "2677409596") then
            if (today_rude <= 3 and today_sorry <= 1) then
                if (hour >= 5 and hour <= 10) then
                    return "主人早上好！茉莉想死你啦！#飞扑"
                else
                    return "就、就连主人也出现幻觉了吗...（失去高光）"
                end
            end
        else
            if (favor >= 1200) then
                if (today_rude <= 2 and today_sorry <= 1) then
                    if (hour >= 5 and hour <= 10) then
                        return "诶诶诶{nick}早上好！今天是来找茉莉玩的吗？"
                    else
                        return "唔...{nick}难道是在和另一个自己对话吗...因为现在怎么看都不是早上的样子..."
                    end
                end
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
    local favor, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
    local today_rude, today_sorry, today_noon = GetUserToday(msg.fromQQ, {"rude", "sorry", "noon"}, {0, 0, 0})
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
    -- 爱酱特殊问候模式
    if (msg.fromQQ == "2677409596") then
        if (today_rude <= 3 and today_sorry <= 1) then
            return "午安我的主人~你不在的时间里茉莉会照顾好自己的哟"
        end
    end
    if (today_rude <= 2 and today_sorry <= 1) then
        SetUserToday(msg.fromQQ, "noon", today_noon + 1)
        local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
        if (calibration_message1 ~= nil) then
            return calibration_message1
        end
        if (succ == false) then
            return "啊...？嗯...{nick}午安，很抱歉，能让茉莉一个人待一会吗"
        end
        if (today_noon < today_noon_limit) then
            local favor_now = favor + ModifyFavorChangeNormal(msg, favor, 5, affinity, succ)
            -- SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
            CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
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
end
msg_order["午安茉莉"] = "rcv_Ciallo_afternoon"
msg_order["茉莉午安"] = "rcv_Ciallo_afternoon"
msg_order["茉莉酱午安"] = "rcv_Ciallo_afternoon"

-- 非指向性午安判断程序
function afternoon_special(msg)
    -- local preReply=preHandle(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    if (msg.fromQQ == "2677409596") then
        if (today_rude <= 3 and today_sorry <= 1) then
            if (hour >= 11 and hour <= 16) then
                return msg.fromMsg .. "..诶？主人你是对我说的吧...大概（小声）"
            else
                return "主人啊...你..不会出现幻觉了吧..."
            end
        end
    else
        if (favor >= 1200) then
            if (today_rude <= 2 and today_sorry <= 1) then
                return "嗯嗯" .. " 午安" .. "，这是茉莉凭个 人 意 愿想对你说的哦~"
            end
        end
    end
end
msg_order["午安"] = "afternoon_special"

-- 指代性中午好
function rcv_Ciallo_noon(msg)
    local preReply = preHandle(msg)
    if (preReply ~= nil) then
        return preReply
    end
    local today_rude, today_sorry, today_noon = GetUserToday(msg.fromQQ, {"rude", "sorry", "noon"}, {0, 0, 0})
    local favor, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
    local favor_ori = favor
    if (msg.fromQQ == "2677409596") then
        if (today_rude >= 4 or today_sorry >= 2) then
            return "怎么了——笨↗蛋↘主人，茉莉现在，不！想！理！你！"
        else
            if (hour >= 11 and hour <= 14) then
                return "主人中午好呀！茉、茉莉吃得...有点饱了...呼呼呼#倒床上"
            else
                return "唔姆，#抬头看窗外 主人你没事吧 睡傻了吗（上来捏脸）"
            end
        end
    else
        if (today_rude >= 3 or today_sorry >= 2) then
            return "Error!机体故障！目标信息丢失，无法识别该对象！你是谁啊茉莉不认识你"
        else
            if (hour >= 11 and hour <= 14) then
                SetUserToday(msg.fromQQ, "today_noon", today_noon + 1)
                local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
                if (calibration_message1 ~= nil) then
                    return calibration_message1
                end
                if (succ == false) then
                    return "中午好。嗯...?你说就没有其他的话了...?"
                end
                if (today_noon < today_noon_limit) then
                    local favor_now = favor + ModifyFavorChangeNormal(msg, favor, 5, affinity, succ)
                    -- SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                    CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
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
            else
                return "咦，现在，是中午？好吧，既然{nick}这么说，那么，中午好！"
            end
        end
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
    -- local preReply=preHandle(msg)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    if (msg.fromQQ == "2677409596") then
        if (today_rude <= 3 and today_sorry <= 1) then
            if (hour >= 11 and hour <= 14) then
                return "主、主人 中午好呀，午睡前要一起玩吗.."
            else
                return "诶？中午好...？唔 好吧 原来这时间叫做中午...茉莉记下了，毕竟我最相信主人了嘛"
            end
        end
    else
        if (today_rude <= 2 and today_sorry <= 1) then
            if (favor >= 1200) then
                if (hour >= 11 and hour <= 14) then
                    return "诶，中午好？是…在和茉莉说吗，应该……是吧"
                else
                    return "唔..可现在不是中午哦？不过 茉莉也向你问好哦~#踮起脚尖打招呼"
                end
            end
        end
    end
end
msg_order["中午好"] = "Ciallo_noon_normal"

-- 晚上好
function rcv_Ciallo_evening(msg)
    local preReply = preHandle(msg)
    if (preReply ~= nil) then
        return preReply
    end
    local today_evening, today_rude, today_sorry = GetUserToday(msg.fromQQ, {"evening", "rude", "sorry"}, {0, 0, 0})
    local favor, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
    local favor_ori = favor
    today_evening = today_evening + 1
    SetUserToday(msg.fromQQ, "evening", today_evening)

    if (today_rude <= 2 and today_sorry <= 1) then
        if ((hour >= 18 and hour <= 24) or (hour >= 0 and hour <= 4)) then
            local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
            if (calibration_message1 ~= nil) then
                return calibration_message1
            end
            if (succ == false) then
                return "女孩似乎没有理睬你的意思，只是怔怔望着窗外，若有所思×"
            end
            if (today_evening <= 1) then
                local favor_now = favor + ModifyFavorChangeNormal(msg, favor, 5, affinity, succ)
                CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
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
end
msg_order["茉莉晚上好"] = "rcv_Ciallo_evening"
msg_order["晚上好茉莉"] = "rcv_Ciallo_evening"

-- 晚安问候程序
function rcv_Ciallo_night(msg)
    local preReply = preHandle(msg)
    if (preReply ~= nil) then
        return preReply
    end
    local today_night, today_rude, today_sorry = GetUserToday(msg.fromQQ, {"night", "rude", "sorry"}, {0, 0, 0})
    local favor, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
    local favor_ori = favor
    today_night = today_night + 1
    SetUserToday(msg.fromQQ, "night", today_night)
    if (msg.fromQQ == "2677409596") then
        if (today_rude <= 3 and today_sorry <= 1) then
            if ((hour >= 21 and hour <= 23) or (hour >= 0 and hour <= 4)) then
                if (today_night <= 1) then
                    --SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 5)
                    CheckFavor(msg.fromQQ, favor_ori, favor_ori + 5, affinity)
                end
                return "晚安哦我的主人，茉莉今天明天也会一直喜欢你的！"
            else
                return "主——人——！不要捉弄茉莉，现在显然不是睡觉时间啦！"
            end
        end
    else
        if (today_rude <= 2 and today_sorry <= 1) then
            if ((hour >= 21 and hour <= 23) or (hour >= 0 and hour <= 4)) then
                local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
                if (calibration_message1 ~= nil) then
                    return calibration_message1
                end
                if (succ == false) then
                    return "那茉莉就回自己房间了，晚安，明早见"
                end
                if (today_night <= 1) then
                    local favor_now = favor + ModifyFavorChangeNormal(msg, favor, 5, affinity, succ)
                    -- SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                    CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
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
                    if msg.fromQQ == "1298754454" then
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
    end
end
-- 可能的晚安问候池(前缀匹配)
msg_order["晚安茉莉"] = "rcv_Ciallo_night"
msg_order["茉莉酱晚安"] = "rcv_Ciallo_night"
msg_order["茉莉晚安"] = "rcv_Ciallo_night"
msg_order["晚安啊茉莉"] = "rcv_Ciallo_night"
msg_order["茉莉哦呀斯密纳塞"] = "rcv_Ciallo_night"
msg_order["茉莉哦呀斯密"] = "rcv_Ciallo_night"

-- function Ciallo_xiawuhao(msg)
--     local preReply=preHandle(msg)
--     local favor=GetUserConf("favorConf",msg.fromQQ,"好感度",0)
--     local today_rude=GetUserToday(msg.fromQQ,"rude",0)
--     local today_sorry=GetUserToday(msg.fromQQ,"sorry",0)
--     if(favor<-600)then
--         return ""
--     end
-- end
-- 爱酱特殊晚安问候程序
function night_master(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    if (tostring(msg.fromQQ) == "2677409596") then
        preHandle(msg)
        if (today_rude <= 3 and today_sorry <= 1) then
            if ((hour >= 21 and hour <= 23) or (hour >= 0 and hour <= 4)) then
                return "主人晚安！！诶...主人你说不是对我说的...？呜...#委屈"
            else
                return "主人这是睡傻——了吗，现在明显还没到睡觉时间呢"
            end
        end
    else
        if (favor >= 2000) then
            preHandle(msg)
            if (today_rude <= 2 and today_sorry <= 1) then
                if ((hour >= 21 and hour <= 23) or (hour >= 0 and hour <= 4)) then
                    return "{sample:晚安哦，虽然不知道为什么，但茉莉想主动对你说晚安~|希望明天我们能依然保持赤诚和热爱|晚安，茉莉会在你身边安心陪你睡着的哦？|晚安~愿你梦中星河烂漫，美好依旧}"
                else
                    return "嗯...{nick}现在好像还没到晚安的时间呢..."
                end
            end
        end
    end
end
msg_order["晚安"] = "night_master"

-- 关于晚安、午安的其他表达
function Ciallo_night_2(msg)
    -- local preReply=preHandle(msg)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    local favor, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
    -- 爱酱特殊判断
    if (msg.fromQQ == "2677409596") then
        if (today_rude <= 3 and today_sorry <= 1) then
            if ((hour >= 21 and hour <= 23) or (hour >= 0 and hour <= 4)) then
                return "诶？主人真的会睡吗...茉莉很怀疑哦，但还是晚安啦"
            elseif (hour >= 12 and hour <= 15) then
                return "唔 看来到睡午觉的时间了呢 主人请好好休息吧"
            else
                return "（叹气）果然...主人脑子里只有睡觉吗...现在可不是该睡觉的时间"
            end
        end
    else -- 其他用户根据好感判断回复
        local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
        if (calibration_message1 ~= nil) then
            return calibration_message1
        end
        if (succ == false) then
            return ""
        end
        if (today_rude <= 2 and today_sorry <= 1) then
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
    end
end
msg_order["睡了"] = "Ciallo_night_2"
msg_order["我睡了"] = "Ciallo_night_2"

-- “睡了”的特殊判断
function Ciallo_night_2_add(msg)
    -- local preReply=preHandle(msg)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})

    if (msg.fromQQ == "2677409596") then
        if (today_rude <= 3 and today_sorry <= 1) then
            return "诶，这次是真的睡了？...唔姆，茉莉相信你主人，晚安啦"
        else
            return "切，笨蛋主人真睡假睡茉莉才不关心呢！"
        end
    else
        if (today_rude <= 2 and today_sorry <= 1) then
            return "诶？那可要遵守约定哦~乖乖去睡觉啦"
        else
            return "谁要管你睡不睡啊！（闹脾气）"
        end
    end
end
msg_order["真睡了"] = "Ciallo_night_2_add"
msg_order["我真睡了"] = "Ciallo_night_2_add"

-- 爱酱“呜呜呜”特殊判定
function cry_master(msg)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    if (msg.fromQQ == "2677409596") then
        if (today_rude <= 3 and today_sorry <= 1) then
            return "主人不哭，茉莉永远陪在你身边哦~#摸摸头"
        else
            return "...真是的...主、主人你没事吧？茉、茉莉其实也没有真在生气啦..."
        end
    end
end
msg_order["呜呜"] = "cry_master"
msg_order["乌乌"] = "cry_master"

-- 好感度降低惩罚（粗俗）
function punish_favor_rude(msg)
    -- 为了使触发该函数时不触发版本通告，不使用local preReply=preHandle(msg)而采取部分内联形式
    FavorPunish(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local trust = GetUserConf("favorConf", msg.fromQQ, "trust", 0)
    local admin_judge = msg.fromQQ ~= "2677409596" and msg.fromQQ ~= "3032902237"
    local today_rude = GetUserToday(msg.fromQQ, "rude", 0)
    -- festival(msg)
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

    -- 没有指明对茉莉的脏话
    if (string.find(msg.fromMsg, "茉莉", 1) == nil) then
        favor = favor - 20
        SetUserConf("favorConf", msg.fromQQ, "好感度", favor)
        today_rude = today_rude + 1
        SetUserToday(msg.fromQQ, "rude", today_rude)
        local blackReply = blackList(msg)
        if (blackReply ~= "" and blackReply ~= "已触发！") then
            return blackReply
        elseif (blackReply == "已触发！") then
            return ""
        end
        return ""
    end

    local today_sorry = GetUserToday(msg.fromQQ, "sorry", 0)
    today_rude = today_rude + 1
    SetUserToday(msg.fromQQ, "rude", today_rude)
    -- 如果道歉后再犯，将sorry值加1，作为知错不改的判定条件
    if (today_sorry == 1) then
        today_sorry = today_sorry + 1
        SetUserToday(msg.fromQQ, "sorry", today_sorry)
        SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 65)
        return "你！你不是才向茉莉道完歉吗！你、你...茉莉今天绝对不会理你了！"
    end
    -- 每rude一次减65好感度
    SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 65)
    local blackReply = blackList(msg)
    if (blackReply ~= "" and blackReply ~= "已触发！") then
        return blackReply
    elseif (blackReply == "已触发！") then
        return ""
    end
    if (msg.fromQQ == "2677409596") then
        if (today_rude == 1 and today_sorry == 0) then
            return "主人不可以骂人哦...你是这么教茉莉的..."
        elseif (today_rude == 2 and today_sorry == 0) then
            return "主人！不准骂人！不然茉莉今天、今天不理你了哦..."
        elseif (today_rude == 3 and today_sorry == 0) then
            return "...主人大笨蛋！我我我...呜呜呜求求你了不要骂人好不好..."
        elseif (today_rude == 4 and today_sorry == 0) then
            return "就算是主人...茉莉都这么求你了！我今天不理你了！"
        end
    end
    if (today_rude == 1 and today_sorry == 0) then
        return "不可以骂人哦~"
    elseif (today_rude == 2 and today_sorry == 0) then
        return "不要骂人！不然茉莉酱要生气了！#气鼓鼓"
    elseif (today_rude == 3 and today_sorry == 0) then
        return "哼！茉莉今天不会再理你了！#撇过头"
    end
end
-- rude词汇判定池
msg_order["爬"] = "punish_favor_rude"
msg_order["(爬"] = "punish_favor_rude"
msg_order["爪巴"] = "punish_favor_rude"
msg_order["cnm"] = "punish_favor_rude"
msg_order["nm"] = "punish_favor_rude"
msg_order["rnm"] = "punish_favor_rude"
msg_order["tmd"] = "punish_favor_rude"
msg_order["滚"] = "punish_favor_rude"
msg_order["傻逼"] = "punish_favor_rude"
msg_order["傻比"] = "punish_favor_rude"
msg_order["煞笔"] = "punish_favor_rude"
msg_order["煞比"] = "punish_favor_rude"
msg_order["sb"] = "punish_favor_rude"
msg_order["wdnmd"] = "punish_favor_rude"
msg_order["操"] = "punish_favor_rude"
msg_order["我操"] = "punish_favor_rude"

rude_table = {
    "爬",
    "(爬",
    "爪 巴",
    "cnm",
    "nm",
    "rnm",
    "tmd",
    "滚",
    "（爪",
    "傻逼",
    "傻比",
    "煞笔",
    "煞比",
    "sb",
    "wdnmd",
    "操",
    "我操"
}

-- function teach_special(msg)
--     local today_rude=GetUserToday(2677409596,"rude",0)
--     local today_sorry=GetUserToday(2677409596,"sorry",0)
--     if(today_rude>=1 or today_sorry>=2)then
--         return "嗯嗯...茉莉不会和主人学坏的！茉莉是好——孩——子！"
--     else
--         return "诶？可...可主人什么也没做错呀"
--     end
-- end
-- msg_order["不要和爱酱学坏哦"]="teach_special"

-- 道歉相关判断程序
function say_sorry(msg)
    local preReply = preHandle(msg)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    if (favor < -600) then
        return ""
    end
    if (today_sorry >= 2) then
        return "哼！知错不改的坏孩子！茉莉今天绝对不会理你的！"
    end
    -- 对爱酱的判定
    if (msg.fromQQ == "2677409596") then
        if (today_rude <= 0) then
            return "诶诶诶？！主人为什么要道歉啊 不不、不会是茉莉做了什么坏事吧！"
        elseif (today_rude <= 3) then
            -- 增加今日道歉次数
            today_sorry = today_sorry + 1
            SetUserToday(msg.fromQQ, {"sorry", "hug_needed_to_sorry"}, {today_sorry, 1})
            return "唔姆姆...既然主人都这么说了...茉莉其实也没有那么生气啦#撇过头，抱抱我就原谅你了！"
        else
            today_sorry = today_sorry + 1
            -- 减少已投喂次数以腾出次数给道歉投喂
            SetUserToday(
                msg.fromQQ,
                {"sorry", "gifts"},
                {
                    today_sorry,
                    GetUserToday(msg.fromQQ, "gifts", 0) - 1
                }
            )
            return "哼，笨蛋主人，现在才想起来和我道歉吗！不行不行！...茉莉、茉莉要吃的！"
        end
    else
        if (today_rude <= 0) then
            return "诶？！怎、怎么了 为什么要无端向茉莉道歉啊#慌乱"
        elseif (today_rude <= 2) then
            today_sorry = today_sorry + 1
            SetUserToday(msg.fromQQ, "sorry", today_sorry)
            return "...好、好吧，只要你答应茉莉不会再犯就好！茉莉可是很宽容的#叉腰"
        else
            today_sorry = today_sorry + 1
            -- 减少已投喂次数以腾出次数给道歉投喂
            SetUserToday(
                msg.fromQQ,
                {"sorry", "gifts"},
                {
                    today_sorry,
                    GetUserToday(msg.fromQQ, "gifts", 0) - 1
                }
            )
            return "哼...就算你这么说了...但茉莉可不会这么轻易原谅你（沉默）我、我肚子饿了..."
        end
    end
end
msg_order["对不起茉莉"] = "say_sorry"
msg_order["茉莉对不起"] = "say_sorry"
msg_order["茉莉我错了"] = "say_sorry"
msg_order["我错了茉莉"] = "say_sorry"

-- 动作交互系统
interaction_order = "茉莉 互动 "
normal_order_old = "茉莉 "
function interaction(msg)
    local preReply = preHandle(msg)
    if (preReply ~= nil) then
        return preReply
    end
    local favor, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    local RS_judge
    local today_interaction = GetUserToday(msg.fromQQ, "今日互动", 0)
    local favor_ori = favor
    today_interaction = today_interaction + 1
    SetUserToday(msg.fromQQ, "今日互动", today_interaction)
    local blackReply = blackList(msg)
    if (blackReply ~= "" and blackReply ~= "已触发！") then
        return blackReply
    elseif (blackReply == "已触发！") then
        return ""
    end
    if (msg.fromQQ == "2677409596") then
        RS_judge = today_rude <= 3 and today_sorry <= 1
    else
        RS_judge = today_rude <= 2 and today_sorry <= 1
    end
    if (not RS_judge) then
        return ""
    end
    local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
    if (calibration_message1) then
        return calibration_message1
    end
    if (succ == false) then
        return "茉莉向后退了一步，并对你比了个“×”的手势×"
    end
    local level
    if (favor <= ranint(1500 - left_limit, 1500 + right_limit)) then
        level = "less"
        SetUserConf(
            "favorConf",
            msg.fromQQ,
            "好感度",
            favor - ModifyFavorChangeNormal(msg, favor, ranint(50, 100), affinity)
        )
    elseif (favor <= ranint(3000 - left_limit, 3000 + right_limit)) then
        level = "low"
        if (today_interaction <= today_interaction_limit) then
            local favor_now = favor + ModifyFavorChangeNormal(msg, favor, ranint(5, 8), affinity)
            -- SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
            CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
        end
    elseif (favor <= ranint(5000 - left_limit, 5000 + right_limit)) then
        level = "high"
        if (today_interaction <= today_interaction_limit) then
            local favor_now = favor + ModifyFavorChangeNormal(msg, favor, ranint(12, 25), affinity)
            -- SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
            CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
        end
    else
        level = "highest"
        if (today_interaction <= today_interaction_limit) then
            local favor_now = favor + ModifyFavorChangeNormal(msg, favor, ranint(15, 30), affinity)
            -- SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
            CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
        end
    end
    local first, second = "", string.match(msg.fromMsg, "^[%s]*[%S]*[%s]*[%S]*$", #normal_order_old + 1)
    first, second = string.match(second, "^[%S]*"), string.match(second, "^[%S]*", string.find(second, " ") + 1)
    if (first ~= "互动") then
        return ""
    end
    if (second == "") then
        return "茉莉无法解析您的指令哦"
    end
    if (second == "头") then
        second = "head"
    elseif (second == "脸") then
        second = "face"
    elseif (second == "身体") then
        second = "body"
    elseif (second == "脖子") then
        second = "neck"
    elseif (second == "背") then
        second = "back"
    elseif (second == "腰") then
        second = "waist"
    elseif (second == "腿") then
        second = "leg"
    elseif (second == "手") then
        second = "hand"
    end
    local flag = second .. "_" .. level
    for k, v in pairs(reply) do
        if (k == flag) then
            return v[ranint(1, #v)]
        end
    end
end
msg_order[interaction_order] = "interaction"

normal_order = "茉莉"
-- 普通问候程序
function _Ciallo_normal(msg)
    -- return "Warning！好感组件强制更新中 相关功能已停用"
    -- local preReply=preHandle(msg)
    local ignore_qq = {959686587}
    --! 千音暂时不回复，以及定制reply
    for _, v in pairs(ignore_qq) do
        if msg.fromQQ * 1 == v then
            return ""
        end
    end
    if (msg.fromQQ == "839968342") then
        if (string.find(msg.fromMsg, "茉莉？") ~= nil or string.find(msg.fromMsg, "茉莉?") ~= nil) then
            return ""
        end
    end
    local str = string.match(msg.fromMsg, "(.*)", #normal_order + 1)
    local deepjudge = {
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
    local flag = false
    for k, v in pairs(deepjudge) do
        if (string.find(str, v) ~= nil) then
            flag = true
            break
        end
    end
    if (msg.fromMsg == "茉莉") then
        flag = true
    end
    if (flag == false) then
        return ""
    end
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    if (favor < -600) then
        return ""
    end
    if (msg.fromQQ == "2677409596") then
        if (today_rude >= 4 or today_sorry >= 2) then
            reply_main = "Error！不存在的机体名！#装作迷茫"
        else
            reply_main = "嗯？...啊！主人！茉莉可没有偷懒哦..."
        end
    else
        if (today_rude >= 3 or today_sorry >= 2) then
            reply_main = "Error!不存在的机体名！"
        else
            -- 定制reply
            if msg.fromQQ == "2595928998" then
                reply_main = table_draw(normal_2595928998)
            elseif msg.fromQQ == "751766424" then
                reply_main = table_draw(normal_751766424)
            else
                reply_main = "{sample:嗯哼？茉莉在这哦~Ciallo|诶...是在叫茉莉吗？茉莉茉莉在哦~|我听到了！就是{nick}在叫我！这次一定没有错！}"
            end
        end
    end
end

function action(msg)
    if (Actionprehandle(msg.fromMsg) == false) then
        return ""
    end
    local preReply = preHandle(msg)
    if (preReply ~= nil) then
        reply_main = preReply
        return preReply
    end
    local favor, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
    local favor_ori, favor_now = favor, favor
    local today_rude,
        today_sorry,
        today_hug,
        today_touch,
        hugtosorry,
        today_lift,
        today_kiss,
        today_hand,
        today_face,
        today_suki,
        today_love,
        today_tietie,
        today_cengceng =
        GetUserToday(
        msg.fromQQ,
        {
            "rude",
            "sorry",
            "hug",
            "touch",
            "hug_needed_to_sorry",
            "lift",
            "kiss",
            "hand",
            "face",
            "suki",
            "love",
            "tietie",
            "cengceng"
        },
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    )

    local blackReply = blackList(msg)

    if (blackReply ~= "" and blackReply ~= "已触发！") then
        return blackReply
    elseif (blackReply == "已触发！") then
        return ""
    end
    local succ, left_limit, right_limit, calibration_message1 = ModifyLimit(msg, favor, affinity)
    if (calibration_message1 ~= nil) then
        reply_main = calibration_message1
        return ""
    end
    --! 灵音定制 蹭蹭
    if (msg.fromQQ == "2595928998" and string.find(msg.fromMsg, "蹭蹭") ~= nil) then
        today_cengceng = today_cengceng + 1
        reply_main = table_draw(cengceng_2595928998)
        SetUserToday(msg.fromQQ, "cengceng", today_cengceng)
        if today_cengceng <= today_cengceng_limit then
            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 20, affinity, succ)
        end
    end
    -- action 抱
    local judge_hug = string.find(msg.fromMsg, "抱", 1) ~= nil
    if (judge_hug) then
        if (succ == false) then
            reply_main = "茉莉突然加快了脚步，你和空气紧紧相拥×"
            SetUserConf("favorConf", msg.fromQQ, "好感度", favor - ModifyFavorChangeNormal(msg, favor, 10, affinity, succ))
            return ""
        else
            today_hug = today_hug + 1
            SetUserToday(msg.fromQQ, "hug", today_hug)
            if (msg.fromQQ == "2677409596") then
                if (today_rude >= 4 or today_sorry >= 2) then
                    reply_main = "#挣脱 不要，主人是笨蛋，被笨蛋抱会变傻的！"
                else
                    if (hugtosorry == 1) then
                        SetUserToday(msg.fromQQ, {"hug_needed_to_sorry", "rude"}, {0, 0})
                        reply_main = "啊...好像主人偶尔犯犯错还不错啊..#闭眼低语"
                    else
                        if (today_hug <= today_hug_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 25, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = "诶诶诶！主人你...#稍有惊讶后很快放松下来 以后也要一直和茉莉在一起哦#抱紧"
                    end
                end
            else
                if (today_rude >= 3 or today_sorry >= 2) then
                    SetUserConf(
                        "favorConf",
                        msg.fromQQ,
                        "好感度",
                        favor + ModifyFavorChangeNormal(msg, favor, -100, affinity, succ)
                    )
                    reply_main = "哼！做了这种事的坏孩子不要碰茉莉！#有力挣开"
                    return ""
                else
                    if (hugtosorry == 1) then
                        SetUserToday(msg.fromQQ, {"rude", "hug_needed_to_sorry"}, {0, 0})
                        reply_main = "唔姆姆，茉莉这次、这次...这次就原谅你！#音量莫名提高"
                    else
                        if (favor <= ranint(1500 - left_limit, 1500 + right_limit)) then
                            if (today_hug <= today_hug_limit) then
                                SetUserConf(
                                    "favorConf",
                                    msg.fromQQ,
                                    "好感度",
                                    favor + ModifyFavorChangeNormal(msg, favor, -90, affinity, succ)
                                )
                            end
                            if favor < 0 then
                                reply_main = table_draw(reply_action_lowest)
                            else
                                reply_main = table_draw(reply_hug_less)
                            end
                            return
                        elseif (favor <= ranint(3000 - left_limit, 3000 + right_limit)) then
                            if (today_hug <= today_hug_limit) then
                                favor_now = favor + ModifyFavorChangeNormal(msg, favor, 8, affinity, succ)
                            --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                            end
                            reply_main = table_draw(reply_hug_low)
                        elseif (favor <= ranint(6000 - left_limit, 6000 + right_limit)) then
                            if (today_hug <= today_hug_limit) then
                                favor_now = favor + ModifyFavorChangeNormal(msg, favor, 15, affinity, succ)
                            -- SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                            end
                            reply_main = table_draw(reply_hug_high)
                        else
                            if (today_hug <= today_hug_limit) then
                                favor_now = favor + ModifyFavorChangeNormal(msg, favor, 25, affinity, succ)
                            --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                            end
                            reply_main = table_draw(reply_hug_highest)
                        end
                    end
                end
            end
        end
    end
    -- action 摸头
    local judge_touch = string.find(msg.fromMsg, "摸头", 1) ~= nil or string.find(msg.fromMsg, "摸摸", 1) ~= nil
    if (judge_touch) then
        if (succ == false) then
            reply_main = "你伸出手去，什么也没碰到，只见她缩了下脖子接一大步走到了你前面×"
            SetUserConf("favorConf", msg.fromQQ, "好感度", favor - ModifyFavorChangeNormal(msg, favor, 10, affinity, succ))
            return ""
        else
            today_touch = today_touch + 1
            SetUserToday(msg.fromQQ, "touch", today_touch)
            if (msg.fromQQ == "2677409596") then
                if (today_rude >= 4 or today_sorry >= 2) then
                    reply_main = "被笨蛋主人这样摸头...总感觉开心不起来呢"
                else
                    if (today_touch <= today_touch_limit) then
                        favor_now = favor + ModifyFavorChangeNormal(msg, favor, 20, affinity, succ)
                    --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                    end
                    reply_main = "唔唔唔，主、主人不要摸啦，头、头发会乱的...#闭眼缩起脖子"
                end
            else
                if (today_rude >= 3 or today_sorry >= 2) then
                    SetUserConf(
                        "favorConf",
                        msg.fromQQ,
                        "好感度",
                        favor + ModifyFavorChangeNormal(msg, favor, -90, affinity, succ)
                    )
                    reply_main = "不 不要！你是坏人，茉莉的头才不会让你摸呢！"
                    return ""
                else
                    if (favor <= ranint(1000 - left_limit, 1000 + right_limit)) then
                        if (today_touch <= today_touch_limit) then
                            SetUserConf(
                                "favorConf",
                                msg.fromQQ,
                                "好感度",
                                favor + ModifyFavorChangeNormal(msg, favor, -30, affinity, succ)
                            )
                        end
                        if favor < 0 then
                            reply_main = table_draw(reply_action_lowest)
                        else
                            reply_main = table_draw(reply_touch_less)
                        end
                        return
                    elseif (favor <= ranint(2000 - left_limit, 2000 + right_limit)) then
                        if (today_touch <= today_touch_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 8, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_touch_low)
                    elseif (favor <= ranint(4500 - left_limit, 4500 + right_limit)) then
                        if (today_touch <= today_touch_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 12, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_touch_high)
                    else
                        if (today_touch <= today_touch_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 16, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_touch_highest)
                    end
                end
            end
        end
    end
    -- action举高高
    local judge_lift = string.find(msg.fromMsg, "举高", 1) ~= nil
    if (judge_lift) then
        if (succ == false) then
            reply_main = "你就这样顺势把茉莉举了起来...是假的，她好像发现了什么正弯下腰端详着，只有你高举双臂不知道在干什么×"
            SetUserConf("favorConf", msg.fromQQ, "好感度", favor - ModifyFavorChangeNormal(msg, favor, 10, affinity, succ))
            return ""
        else
            today_lift = today_lift + 1
            SetUserToday(msg.fromQQ, "lift", today_lift)
            if (msg.fromQQ == "2677409596") then
                if (today_rude <= 3 and today_sorry <= 1) then
                    if (today_lift <= today_lift_limit) then
                        favor_now = favor + ModifyFavorChangeNormal(msg, favor, 15, affinity, succ)
                    --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                    end
                    reply_main = "啊主主主、主人 好、好高啊！再、再转几圈吧！#露出了开心的笑容"
                else
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 80)
                    reply_main = "笨、笨蛋主人...！快放我下来！啊！"
                    return ""
                end
            else
                if (today_rude <= 2 and today_sorry <= 1) then
                    if (favor <= ranint(1550 - left_limit, 1550 + right_limit)) then
                        if (today_lift <= today_lift_limit) then
                            SetUserConf(
                                "favorConf",
                                msg.fromQQ,
                                "好感度",
                                favor + ModifyFavorChangeNormal(msg, favor, -80, affinity, succ)
                            )
                        end
                        if favor < 0 then
                            reply_main = table_draw(reply_action_lowest)
                        else
                            reply_main = table_draw(reply_lift_less)
                        end
                        return
                    elseif (favor <= ranint(3200 - left_limit, 3200 + right_limit)) then
                        if (today_lift <= today_lift_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 10, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_lift_low)
                    elseif (favor <= ranint(6800 - left_limit, 6800 + right_limit)) then
                        if (today_lift <= today_lift_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 14, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_lift_high)
                    else
                        if (today_lift <= today_lift_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 18, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_lift_highest)
                    end
                else
                    SetUserConf(
                        "favorConf",
                        msg.fromQQ,
                        "好感度",
                        favor + ModifyFavorChangeNormal(msg, favor, -90, affinity, succ)
                    )
                    reply_main = "主人教过茉莉，笨蛋不能这样做！"
                    return ""
                end
            end
        end
    end
    -- action kiss
    local judge_kiss = string.find(msg.fromMsg, "亲", 1) ~= nil
    if (judge_kiss) then
        if (succ == false) then
            reply_main = "正当你鼓起勇气凑近她的脸庞，却被她有力的手给推开了×"
            SetUserConf("favorConf", msg.fromQQ, "好感度", favor - ModifyFavorChangeNormal(msg, favor, 10, affinity, succ))
            return ""
        else
            today_kiss = today_kiss + 1
            SetUserToday(msg.fromQQ, "kiss", today_kiss)
            if (msg.fromQQ == "2677409596") then
                if (today_rude <= 3 and today_sorry <= 1) then
                    if (today_kiss <= today_kiss_limit) then
                        favor_now = favor + ModifyFavorChangeNormal(msg, favor, 50, affinity, succ)
                    --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                    end
                    reply_main = "啊...主、主人...你你你！#低头脸红 你讨厌死了！#捶胸口时埋到怀里"
                else
                    SetUserConf(
                        "favorConf",
                        msg.fromQQ,
                        "好感度",
                        favor + ModifyFavorChangeNormal(msg, favor, -150, affinity, succ)
                    )
                    reply_main = "笨蛋主人！#快速扭过头然后看你 茉莉原谅你之前绝对不会让你亲的！"
                    return ""
                end
            else
                if (today_rude <= 2 and today_sorry <= 1) then
                    if (favor <= ranint(2000 - left_limit, 2000 + right_limit)) then
                        SetUserConf(
                            "favorConf",
                            msg.fromQQ,
                            "好感度",
                            favor + ModifyFavorChangeNormal(msg, favor, -100, affinity, succ)
                        )
                        if favor < 0 then
                            reply_main = table_draw(reply_action_lowest)
                        else
                            reply_main = table_draw(reply_kiss_less)
                        end
                        return
                    elseif (favor <= ranint(3200 - left_limit, 3200 + right_limit)) then
                        SetUserConf(
                            "favorConf",
                            msg.fromQQ,
                            "好感度",
                            favor + ModifyFavorChangeNormal(msg, favor, -20, affinity, succ)
                        )
                        reply_main = table_draw(reply_kiss_low)
                        return
                    elseif (favor <= ranint(6700 - left_limit, 6700 + right_limit)) then
                        if (today_kiss <= today_kiss_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 15, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_kiss_high)
                    else
                        if (today_kiss <= today_kiss_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 20, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_kiss_highest)
                    end
                else
                    SetUserConf(
                        "favorConf",
                        msg.fromQQ,
                        "好感度",
                        favor + ModifyFavorChangeNormal(msg, favor, -130, affinity, succ)
                    )
                    reply_main = "哼，才不想理笨蛋呢"
                    return ""
                end
            end
        end
    end
    -- action 牵手
    local judge_hand = string.find(msg.fromMsg, "牵手", 1) ~= nil
    if (judge_hand) then
        if (succ == false) then
            reply_main = "你试探性地触碰了一下她的手，可她却把手缩到胸前，嘴唇微张却没有说话×"
            SetUserConf("favorConf", msg.fromQQ, "好感度", favor - ModifyFavorChangeNormal(msg, favor, 10, affinity, succ))
            return ""
        else
            today_hand = today_hand + 1
            SetUserToday(msg.fromQQ, "hand", today_hand)
            if (msg.fromQQ == "2677409596") then
                if (today_rude <= 3 and today_sorry <= 1) then
                    if (today_hand <= today_hand_limit) then
                        favor_now = favor + ModifyFavorChangeNormal(msg, favor, 10, affinity, succ)
                    --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                    end
                    reply_main = "诶？要牵手吗...嗯...嗯 那 就不要放开了哦~主人——"
                else
                    reply_main = "哼...茉莉可还没有原谅主人哦，所以，不给你——牵！"
                end
            else
                if (today_rude <= 2 and today_sorry <= 1) then
                    if (favor <= ranint(1200 - left_limit, 1200 + right_limit)) then
                        SetUserConf(
                            "favorConf",
                            msg.fromQQ,
                            "好感度",
                            favor + ModifyFavorChangeNormal(msg, favor, -40, affinity, succ)
                        )
                        if favor < 0 then
                            reply_main = table_draw(reply_action_lowest)
                        else
                            reply_main = table_draw(reply_hand_less)
                        end
                        return
                    elseif (favor <= ranint(2800 - left_limit, 2800 + right_limit)) then
                        if (today_hand <= today_hand_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 8, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_hand_low)
                    elseif (favor <= ranint(5800 - left_limit, 5800 + right_limit)) then
                        if (today_hand <= today_hand_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 10, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_hand_high)
                    else
                        if (today_hand <= today_hand_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 12, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_hand_highest)
                    end
                else
                    SetUserConf(
                        "favorConf",
                        msg.fromQQ,
                        "好感度",
                        favor + ModifyFavorChangeNormal(msg, favor, -80, affinity, succ)
                    )
                    reply_main = "在茉莉原谅你之前，才不会让笨蛋这么做"
                    return ""
                end
            end
        end
    end
    -- action 捏/揉脸
    local judge_face =
        string.find(msg.fromMsg, "捏脸", 1) ~= nil or string.find(msg.fromMsg, "揉脸", 1) ~= nil or
        string.find(msg.fromMsg, "揉揉", 11) ~= nil
    if (judge_face) then
        if (succ == false) then
            reply_main = "你的手还在空中之际，对上了她眨巴眨巴的眼睛，你尴尬地缩回了手×"
            SetUserConf("favorConf", msg.fromQQ, "好感度", favor - ModifyFavorChangeNormal(msg, favor, 10, affinity, succ))
            return ""
        else
            today_face = today_face + 1
            SetUserToday(msg.fromQQ, "face", today_face)
            if (msg.fromQQ == "2677409596") then
                if (today_rude <= 3 and today_sorry <= 1) then
                    if (today_face <= today_face_limit) then
                        favor_now = favor + ModifyFavorChangeNormal(msg, favor, 7, affinity, succ)
                    --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                    end
                    reply_main = "哎哎哎主人——别别这样，茉莉...茉莉感觉浑身发热了呜..."
                else
                    reply_main = "#快速撇开头 略略略！茉莉就不给你碰——"
                end
            else
                if (today_rude <= 2 and today_sorry <= 1) then
                    if (favor <= ranint(1100 - left_limit, 1100 + right_limit)) then
                        SetUserConf(
                            "favorConf",
                            msg.fromQQ,
                            "好感度",
                            favor + ModifyFavorChangeNormal(msg, favor, -40, affinity, succ)
                        )
                        if favor < 0 then
                            reply_main = table_draw(reply_action_lowest)
                        else
                            reply_main = table_draw(reply_face_less)
                        end
                        return
                    elseif (favor <= ranint(3200 - left_limit, 3200 + right_limit)) then
                        if (today_face <= today_face_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 5, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_face_low)
                    elseif (favor <= ranint(6000 - left_limit, 6000 + right_limit)) then
                        if (today_face <= today_face_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 10, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_face_high)
                    else
                        if (today_face <= today_face_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 14, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_face_highest)
                    end
                else
                    SetUserConf(
                        "favorConf",
                        msg.fromQQ,
                        "好感度",
                        favor + ModifyFavorChangeNormal(msg, favor, -70, affinity, succ)
                    )
                    reply_main = "不要随便碰我！你这个坏人！大笨蛋！#耍脾气"
                    return ""
                end
            end
        end
    end
    -- 赞美和情感表达系统
    -- 可爱
    local judge_cute =
        string.find(msg.fromMsg, "可爱", 1) ~= nil or string.find(msg.fromMsg, "卡哇伊", 1) ~= nil or
        string.find(msg.fromMsg, "萌", 1) ~= nil or
        string.find(msg.fromMsg, "kawai", 1) ~= nil or
        string.find(msg.fromMsg, "kawayi", 1) ~= nil
    if (judge_cute) then
        local today_cute = GetUserToday(msg.fromQQ, "cute", 0)
        if (succ == false) then
            reply_main = "可爱吗...虽然茉莉不是很明白为什么...×"
        else
            today_cute = today_cute + 1
            SetUserToday(msg.fromQQ, "cute", today_cute)
            if (msg.fromQQ == "2677409596") then
                if (today_rude <= 3 and today_sorry <= 1) then
                    if (today_cute <= today_cute_limit) then
                        favor_now = favor + ModifyFavorChangeNormal(msg, favor, 15, affinity, succ)
                    --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                    end
                    reply_main = "诶诶诶？主...主人夸我了！#惊喜 还..还有点不好意思呢...#傻笑"
                else
                    reply_main = "哼，不管主人怎么夸，茉莉都不会心动的 #气鼓鼓嘟起嘴"
                end
            else
                if (today_rude <= 2 and today_sorry <= 1) then
                    if (favor <= ranint(1050 - left_limit, 1050 + right_limit)) then
                        if (today_cute <= today_cute_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 8, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_cute_less)
                    elseif (favor <= ranint(3000 - left_limit, 3000 + right_limit)) then
                        if (today_cute <= today_cute_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 10, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_cute_low)
                    elseif (favor <= ranint(4000 - left_limit, 4000 + right_limit)) then
                        if (today_cute <= today_cute_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 12, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_cute_high)
                    else
                        if (today_cute <= today_cute_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 15, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_cute_highest)
                    end
                else
                    reply_main "不行哦——，茉莉是不会接受笨蛋的夸奖的哦~"
                end
            end
        end
    end
    -- express suki
    local judge_suki = string.find(msg.fromMsg, "喜欢", 1) ~= nil or string.find(msg.fromMsg, "suki", 1) ~= nil
    if (judge_suki) then
        if (succ == false) then
            reply_main = "非常感谢{nick}的喜欢×"
        else
            today_suki = today_suki + 1
            SetUserToday(msg.fromQQ, "suki", today_suki)
            if (msg.fromQQ == "2677409596") then
                if (today_rude <= 3 and today_sorry <= 1) then
                    if (today_suki <= today_suki_limit) then
                        favor_now = favor + ModifyFavorChangeNormal(msg, favor, 10, affinity, succ)
                    end
                    reply_main = "啊..#呆住 Error！检测到机体温度迅速升高，要主人抱抱才能缓解！"
                else
                    reply_main = "哼...就算主人这么说了...不！不对！主人是大笨蛋！茉莉才不会因为这种花言巧语而心软呢！"
                end
            else
                if (today_rude <= 2 and today_sorry <= 1) then
                    if (favor <= ranint(1500 - left_limit, 1500 + right_limit)) then
                        reply_main = table_draw(reply_suki_less)
                    elseif (favor <= ranint(3500 - left_limit, 3500 + right_limit)) then
                        if (today_suki <= today_suki_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 12, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_suki_low)
                    elseif (favor <= ranint(5500 - left_limit, 5500 + right_limit)) then
                        if (today_suki <= today_suki_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 15, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_suki_high)
                    else
                        if (today_suki <= today_suki_limit) then
                            favor_now = favor + ModifyFavorChangeNormal(msg, favor, 20, affinity, succ)
                        --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                        end
                        reply_main = table_draw(reply_suki_highest)
                    end
                else
                    return "哼，笨蛋还好意思说出这些话"
                end
            end
        end
    end
    -- express love
    local judge_love = string.find(msg.fromMsg, "爱", 1) ~= nil or string.find(msg.fromMsg, "love", 1) ~= nil
    if (judge_love and not judge_cute) then
        today_love = today_love + 1
        SetUserToday(msg.fromQQ, "love", today_love)
        if (msg.fromQQ == "2677409596") then
            if (today_rude <= 3 and today_sorry <= 1) then
                if (today_love <= today_love_limit) then
                    favor_now = favor + ModifyFavorChangeNormal(msg, favor, 30, affinity, succ)
                --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                end
                reply_main = "啊啊啊主主主主主人你你你突然说些什么啊...我我我...茉莉...茉莉当然...也爱你啦（逐渐小声）"
            else
                reply_main = "诶？爱...主人爱我...？#面无表情但脸红 可、可别以为这样茉莉就会原谅你...#移开视线"
            end
        else
            if (today_rude <= 2 and today_sorry <= 1) then
                if (favor <= ranint(1800 - left_limit, 1800 + right_limit)) then
                    reply_main = table_draw(reply_love_less)
                elseif (favor <= ranint(4500 - left_limit, 4500 + right_limit)) then
                    if (today_love <= today_love_limit) then
                        favor_now = favor + ModifyFavorChangeNormal(msg, favor, 15, affinity, succ)
                    --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                    end
                    reply_main = table_draw(reply_love_low)
                elseif (favor <= ranint(6500 - left_limit, 6500 + right_limit)) then
                    if (today_love <= today_love_limit) then
                        favor_now = favor + ModifyFavorChangeNormal(msg, favor, 20, affinity, succ)
                    --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                    end
                    reply_main = table_draw(reply_love_high)
                else
                    if (today_love <= today_love_limit) then
                        favor_now = favor + ModifyFavorChangeNormal(msg, favor, 25, affinity, succ)
                    --SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                    end
                    reply_main = table_draw(reply_love_highest)
                end
            else
                reply_main = "哼，茉莉可不想被笨蛋说爱我，不、不然...不然茉莉不也是笨蛋了吗..."
            end
        end
    end
    local judge_tietie = string.find(msg.fromMsg, "贴贴", 1) ~= nil
    if judge_tietie then
        today_tietie = today_tietie + 1
        SetUserToday(msg.fromQQ, "tietie", today_tietie)
        if today_rude <= 2 and today_sorry <= 1 then
            if favor <= ranint(1500 - left_limit, 1500 + right_limit) then
                favor_now = favor + ModifyFavorChangeNormal(msg, favor, -40, affinity, succ)
                reply_main = table_draw(reply_tietie_less)
            elseif favor <= ranint(3500 - left_limit, 3500 + right_limit) then
                if today_tietie <= today_tietie_limit then
                    favor_now = favor + ModifyFavorChangeNormal(msg, favor, 10, affinity, succ)
                end
                reply_main = table_draw(reply_tietie_low)
            elseif favor <= ranint(5500 - left_limit, 5500 + left_limit) then
                if today_tietie <= today_tietie_limit then
                    favor_now = favor + ModifyFavorChangeNormal(msg, favor, 13, affinity, succ)
                end
                reply_main = table_draw(reply_tietie_high)
            else
                if today_tietie <= today_tietie_limit then
                    favor_now = favor + ModifyFavorChangeNormal(msg, favor, 15, affinity, succ)
                end
                if ranint(1, 2) == 1 then
                    reply_main = table_draw(reply_tietie_high)
                else
                    reply_main = table_draw(reply_tietie_highest)
                end
            end
        end
    end
    CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
    -- 最后判断是否是“互动--部位”格式
    -- interaction(msg)
end

-- 以“茉莉 ”开头代表对象指向 然后搜索匹配相关动作
reply_main = ""
-- 执行函数相应“茉莉”
function action_main(msg)
    for _, v in pairs(rude_table) do
        if (string.find(msg.fromMsg, v) ~= nil) then
            reply_main = punish_favor_rude(msg)
            break
        end
    end
    if (reply_main ~= "") then
        return reply_main
    end
    action(msg)
    if (reply_main ~= "") then
        return reply_main
    end
    _Ciallo_normal(msg)
    return reply_main
end
msg_order[normal_order] = "action_main"

--! 注册指令
function register(msg)
    setUserConf(msg.fromQQ, "isRegister", 1)
    return "信息已录入...欢迎您，{nick}，希望能和你一起创造美好的回忆~"
end
msg_order["我已阅读并理解茉莉协议，同意接受以上服务条款"] = "register"

-- 管理员测试权限
function setfavor(msg)
    local first, second = "", ""
    first, second = string.match(msg.fromMsg, "^[%s]*(%d*)[%s]*(%d*)$", #admin_order1 + 1)
    if (first == "" or second == "") then
        return "请输入正确的参数×"
    end
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        SetUserConf("favorConf", first, "好感度", second * 1)
        return "权限确认：已将目标好感度设置为" .. second
    end
end
admin_order1 = "设置好感"
msg_order[admin_order1] = "setfavor"

function reset_rude_sorry(msg)
    local QQ = string.match(msg.fromMsg, "%d*", #admin_order2 + 1)
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        SetUserToday(QQ, {"rude", "sorry"}, {0, 0})
        return "权限确认：已重置该对象今日rude_sorry值"
    end
end
admin_order2 = "重置RS "
msg_order[admin_order2] = "reset_rude_sorry"

function time(msg)
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        return month .. "月" .. day .. "日" .. hour .. "时" .. minute .. "分"
    end
end
msg_order["当前时间"] = "time"

function reset_food(msg)
    local QQ = string.match(msg.fromMsg, "%d*", #admin_order3 + 1)
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        SetUserToday(QQ, "gifts", 0)
        return "权限确认:已重置目标今日喂食数"
    end
end
admin_order3 = "重置喂食 "
msg_order[admin_order3] = "reset_food"

admin_order4 = "查看好感 "
function favor_history(msg)
    local QQ = string.match(msg.fromMsg, "%d*", #admin_order4 + 1)
    local favor, cohesion, affinity = GetUserConf("favorConf", QQ, {"好感度", "cohesion", "affinity"}, {0, 0, 0})
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        return "目标最后一次好感交互在" ..
            string.format("%.0f", GetUserConf("favorConf", QQ, "year_last", 2021)) ..
                "年" ..
                    string.format("%.0f", GetUserConf("favorConf", QQ, "month_last", 10)) ..
                        "月" ..
                            string.format("%.0f", GetUserConf("favorConf", QQ, "day_last", 11)) ..
                                "日" ..
                                    string.format("%.0f", GetUserConf("favorConf", QQ, "hour_last", 23)) ..
                                        "时" ..
                                            "\n好感度为" ..
                                                string.format("%.0f", favor) ..
                                                    "\n亲密度为" ..
                                                        string.format("%.0f", cohesion) ..
                                                            "\n亲和力为" .. string.format("%.0f", affinity)
    end
end
msg_order[admin_order4] = "favor_history"

admin_order5 = "发送 "
function sendmsg(msg)
    local strtemp = string.match(msg.fromMsg, "^(.*)$", #admin_order5 + 1)
    local group = string.match(strtemp, "%d*")
    local message = string.match(strtemp, " (.*)")
    sendMsg(message, group, 3032902237)
end
msg_order[admin_order5] = "sendmsg"

admin_order6 = "群通告次数 "
function setNoticeGroup(msg)
    local strtemp = string.match(msg.fromMsg, "^(.*)$", #admin_order6 + 1)
    local group = string.match(strtemp, "%d*")
    local num = string.match(strtemp, " %d*")
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        SetGroupConf(group, "notice", num)
        return "权限确认：已设置该群聊本版本通告次数为" .. string.format("%.0f", num)
    end
end
msg_order[admin_order6] = "setNoticeGroup"

admin_order7 = "个人通告次数 "
function setNoticePerson(msg)
    local strtemp = string.match(msg.fromMsg, "^(.*)$", #admin_order7 + 1)
    local QQ = string.match(strtemp, "%d*")
    local num = string.match(strtemp, " %d*")
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        SetUserConf("favorConf", QQ, "noticeQQ", num * 1)
        return "权限确认：已设置目标本版本通告次数为" .. num
    end
end
msg_order[admin_order7] = "setNoticePerson"

admin_order8 = "设置亲和 "
function setAffinity(msg)
    local first, second = "", ""
    first, second = string.match(msg.fromMsg, "^[%s]*(%d*)[%s]*(%d*)$", #admin_order8 + 1)
    if (first == "" or second == "") then
        return "请输入正确的参数×"
    end
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        SetUserConf("favorConf", first, "affinity", second * 1)
        return "权限确认：已将目标亲和度设置为" .. second
    end
end
msg_order[admin_order8] = "setAffinity"

admin_order9 = "设置校准 "
function setCaribration(msg)
    local num = string.match(msg.fromMsg, "^[%s]*(%d*)", #admin_order9 + 1)
    if (num == "") then
        return "请输入正确的参数×"
    end
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        setUserConf(getDiceQQ(), "calibration", num * 1)
        return "权限确认：已将当前校准值设置为" .. num
    end
end
msg_order[admin_order9] = "setCaribration"

admin_order10 = "设置校准上限 "
function setCaribrationLimit(msg)
    local num = string.match(msg.fromMsg, "^[%s]*(%d*)", #admin_order10 + 1)
    if (num == "") then
        return "请输入正确的参数×"
    end
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        setUserConf(getDiceQQ(), "calibration_limit", num * 1)
        return "权限确认：已将当前校准上限设置为" .. num
    end
end
msg_order[admin_order10] = "setCaribrationLimit"

function calibration_show(msg)
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596") then
        return "当前校准值为——" .. calibration .. ";校准上限为——" .. calibration_limit
    end
end
msg_order["当前校准"] = "calibration_show"

admin_order11 = "重置交互 "
function resetInteraction(msg)
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596") then
        local QQ = string.match(msg.fromMsg, "%d*", #admin_order11 + 1)
        SetUserToday(
            QQ,
            {
                "rude",
                "sorry",
                "hug",
                "touch",
                "hug_needed_to_sorry",
                "lift",
                "kiss",
                "hand",
                "face",
                "suki",
                "love"
            },
            {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
        )
        return "权限确认：已重置目标当日交互次数"
    end
end
msg_order[admin_order11] = "resetInteraction"

function table_draw(tab)
    return tab[ranint(1, #tab)]
end
