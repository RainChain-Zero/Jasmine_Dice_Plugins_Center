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

msg_order = {}

-- 各类上限
today_food_limit = 3 -- 单日喂食次数上限
today_morning_limit = 1 -- 单日早安好感增加次数上限
today_night_limit = 1 -- 每日晚安好感增加次数上限
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

function topercent(num)
    if (num == nil) then
        return ""
    end
    return string.format("%.2f", num / 100)
end

-- 各条交互前预处理
function preHandle(msg)
    -- 强制更新提示信息
    -- sendMsg("紧急维护，暂停服务！",msg.fromGroup,msg.fromQQ)
    -- os.exit()

    -- 道具附加的额外好感追加
    AddFavor_Item(msg)
    -- 版本通告处
    Notice(msg)
    -- ! 好感时间惩罚
    FavorPunish(msg)
    -- 剧情解锁提示
    StoryUnlocked(msg)
end

function TrustChange(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local trust_flag = GetUserConf("favorConf", msg.fromQQ, "trust_flag", 0)
    local admin_judge = msg.fromQQ ~= "2677409596" and msg.fromQQ ~= "3032902237"
    if (admin_judge) then
        if (favor < 1000) then
            if (trust_flag == 0) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 0", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust_flag", 0)
        elseif (favor < 3000) then
            if (trust_flag == 1) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 1", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust_flag", 1)
        elseif (favor < 5000) then
            if (trust_flag == 2) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 2", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust_flag", 2)
        else
            if (trust_flag == 3) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 3", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust_flag", 3)
        end
    end
end

function Notice(msg)
    local favorVersion = GetGroupConf(msg.fromGroup, "favorVersion", 0)
    local favorUVersion = GetUserConf("favorConf", msg.fromQQ, "favorVersion", 0)
    -- 修改版本号只需要将下面的数字修改为目前的版本号即可
    if (favorUVersion ~= 45) then
        SetUserConf("favorConf", msg.fromQQ, {"noticeQQ", "favorVersion"}, {0, 45})
    end
    if (favorVersion ~= 45) then
        SetGroupConf(msg.fromGroup, {"favorVersion", "notice"}, {45, 0})
    end
    local notice = GetGroupConf(msg.fromGroup, "notice", 0)
    local noticeQQ = GetUserConf("favorConf",msg.fromQQ, "noticeQQ", 0)
    if (msg.fromGroup == "0" and noticeQQ == 0) then
        noticeQQ = noticeQQ + 1
        local content = "【好感互动模块V4.5&其他功能更新通告】请“戳一戳”（双击头像）茉莉或@茉莉并紧跟含有“更新”的字眼（如“@茉莉 更新内容”)获得本次更新内容哦~"
        SetUserConf("favorConf", msg.fromQQ, "noticeQQ", noticeQQ)
        sendMsg(content, 0, msg.fromQQ)
    end
    noticeQQ = GetUserConf("favorConf", msg.fromQQ, "noticeQQ", 0)
    if (notice ~= nil) then
        if (notice <= 4 and noticeQQ == 0) then
            notice = notice + 1
            noticeQQ = noticeQQ + 1
            local content = "【好感互动模块V4.5&其他功能更新通告】请“戳一戳”（双击头像）茉莉或@茉莉并紧跟含有“更新”的字眼（如“@茉莉 更新内容”)获得本次更新内容哦~"
            SetGroupConf(msg.fromGroup, "notice", notice)
            SetUserConf("favorConf", msg.fromQQ, "noticeQQ", noticeQQ)
            sendMsg(content, msg.fromGroup, msg.fromQQ)
        end
    end
end

-- 每次交互道具增加的附加好感度
function AddFavor_Item(msg)
    local favor = 0
    if (os.time() < GetUserConf("adjustConf", msg.fromQQ, "addFavorDDL_Cookie", 0)) then
        if (GetUserToday(msg.fromQQ, "addFavor_Cookie", 0) == 0) then
            favor = favor + 30
            SetUserToday(msg.fromQQ, "addFavor_Cookie", 1)
        end
    elseif (GetUserConf("adjustConf", msg.fromQQ, "addFavorDDLFlag_Cookie", 1) == 0) then
        sendMsg("注意，您的『袋装曲奇』道具效果已消失", msg.fromGroup, msg.fromQQ)
        -- 更新标记，下次不做提醒
        SetUserConf("adjustConf", msg.fromQQ, "addFavorDDLFlag_Cookie", 1)
    end
    SetUserConf("favorConf", msg.fromQQ, "好感度", GetUserConf("favorConf", msg.fromQQ, "好感度", 0) + favor)
end

-- 好感时间惩罚减免百分比计算
function favorTimePunishDownRate(msg)
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
function FavorPunish(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local flag = false
    -- 初始时间记为编写该程序段的时间
    local _year, _month, _day, _hour =
        GetUserConf(
        "favorConf",
        msg.fromQQ,
        {
            "year_last",
            "month_last",
            "day_last",
            "hour_last"
        },
        {2021, 10, 11, 23}
    )
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

    SetUserConf("favorConf", msg.fromQQ, {"month_last", "day_last", "hour_last", "year_last"}, {month, day, hour, year})

    -- flag用于标记是否是从>500的favor降到500以下的
    if (favor >= 500) then
        flag = true
    else
        return "" -- 本身<500的用户不会触发
    end
    if (subday == 0) then
        return ""
    end

    -- ! 好感度锁定列表
    if
        (msg.fromQQ == "2720577231" or msg.fromQQ == "1550506144" or msg.fromQQ == "2908078197" or
            msg.fromQQ == "751766424")
     then
        return ""
    end
    local Llimit, Rlimit = 0, 0
    -- 分段降低好感
    if (subday <= 3) then
        if (subday == 1 and subhour <= -15) then
            return ""
        end
        if (favor < 8500 and favor > 1250) then
            Llimit, Rlimit = 80 * math.log(2 * subday, 2), 100 * math.log(2 * subday, 2)
        elseif (favor >= 8500) then
            Llimit, Rlimit = 150 * math.log(2 * subday, 2), 180 * math.log(2 * subday, 2)
        else
            Llimit, Rlimit = 30 * math.log(2 * subday, 2), 35 * math.log(2 * subday, 2)
        end
    elseif (subday <= 8) then
        Llimit, Rlimit = 180 * subday, 200 * subday
    else
        Llimit, Rlimit =
            820 + 215 * (subday - 5) * math.log(2 * (subday - 5), 2),
            870 + 245 * (subday - 5) * math.log(2 * (subday - 5), 2)
    end
    --
    -- ! 道具减免
    Llimit, Rlimit = Llimit * (1 - favorTimePunishDownRate(msg)), Rlimit * (1 - favorTimePunishDownRate(msg))
    -- //todo 将左右端点取整才可带入ranint
    Llimit, Rlimit = math.modf(Llimit), math.modf(Rlimit)
    favor = favor - ranint(Llimit, Rlimit)
    if (favor < 500 and flag == true) then
        favor = 500
    end
    SetUserConf("favorConf", msg.fromQQ, "好感度", favor)
end

-- 剧情模式解锁提示
function StoryUnlocked(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local content, flag, res, storyUnlockedNotice, specialUnlockedNotice =
        "",
        "1",
        "",
        GetUserConf(
            "storyConf",
            msg.fromQQ,
            {"storyUnlockedNotice", "specialUnlockedNotice"},
            {"0000000000000000000000000", "0000000000000000000000000"}
        )
    if (favor >= 1000 and GetUserConf("storyConf", msg.fromQQ, "isStory0Read", 0) == 0) then
        flag = string.sub(storyUnlockedNotice, 1, 1)
        if (flag == "1") then
            return ""
        end
        if (msg.fromGroup ~= "0") then
            content = content .. "[CQ:at,qq=" .. msg.fromQQ .. "]\n"
        end
        content = content .. "『✔提示』剧情模式 序章,已经解锁,输入“进入剧情 序章”可浏览剧情"
        res = "1" .. string.sub(storyUnlockedNotice, 2)
        SetUserConf("storyConf", msg.fromQQ, "storyUnlockedNotice", res)
    elseif (favor >= 1500 and GetUserConf("storyConf", msg.fromQQ, "isSpecial0Read", 0) == 0) then
        flag = string.sub(specialUnlockedNotice, 1, 1)
        if (flag == "1") then
            return ""
        end
        content = content .. "『✔提示』剧情模式 元旦特典,已经解锁,输入“进入剧情 元旦特典”可浏览剧情"
        res = "1" .. string.sub(specialUnlockedNotice, 2)
        SetUserConf("storyConf", msg.fromQQ, "specialUnlockedNotice", res)
    elseif
        (GetUserConf("storyConf", msg.fromQQ, "isStory0Read", 0) == 1 and
            GetUserConf("storyConf", msg.fromQQ, "isShopUnlocked", 0) == 0)
     then
        flag = string.sub(storyUnlockedNotice, 2, 2)
        if (flag == "1") then
            return ""
        end
        if (msg.fromGroup ~= "0") then
            content = content .. "[CQ:at,qq=" .. msg.fromQQ .. "]\n"
        end
        content = content .. "『✔提示』剧情模式 第一章,已经解锁,输入“进入剧情 第一章”可浏览剧情"
        res = string.sub(storyUnlockedNotice, 1, 1) .. "1" .. string.sub(storyUnlockedNotice, 3)
        SetUserConf("storyConf", msg.fromQQ, "storyUnlockedNotice", res)
    --todo 第二章提示
    end
    sendMsg(content, msg.fromGroup, msg.fromQQ)
end
function add_favor_food(favor)
    -- 单次固定好感上升
    -- return 100
    -- 随机好感上升,低好感用户翻倍
    if (favor <= 1250) then
        return ranint(40, 60)
    end
    return ranint(20, 30)
end
function add_gift_once() -- 单次计数上升
    return 5
    -- return ranint(1,10)
end

-- 下限黑名单判定
function blackList(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    if (favor <= -300 and favor > -500) then
        sendMsg("Warning:检测到{nick}的好感度过低，即将触发机体下限保护机制！", msg.fromGroup, msg.fromQQ)
        sendMsg("Warning:检测到用户" .. msg.fromQQ .. "好感度过低" .. "在群" .. msg.fromGroup, 0, 2677409596)
    end
    if (favor < -500) then
        eventMsg(".admin blackqq " .. "违反人机和谐共处条例 " .. msg.fromQQ, 0, 2677409596)
        eventMsg(
            ".group " .. msg.fromGroup .. " ban " .. msg.fromQQ .. " " .. tostring(-favor),
            msg.fromGroup,
            getDiceQQ()
        )
        return "已触发！"
    end
    return ""
end

-- !提醒：请不要随意修改rcv_food函数！！递归中牵扯过多，容易引发bug
function rcv_food(msg)
    -- rude值判定是否接受喂食
    preHandle(msg)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    -- 匹配喂食的次数
    if (cnt == 0) then
        cnt = string.match(msg.fromMsg, "[%s]*(%d+)", #food_order + 1)
        if (cnt == nil) then
            cnt = 0
        else
            cnt = cnt * 1
        end
    end
    if (cnt >= 4 or cnt < 0) then
        return "参数有误请重新输入哦~"
    end
    if (msg.fromQQ == "2677409596") then
        if ((today_rude >= 4 and today_sorry == 0) or today_sorry >= 2) then
            flag_food = flag_food + 1 -- 判定爱酱道歉次数以及是否知错不改（today_sorry>=2）
            if (flag_food == 1) then
                flag_food = 0
                return "哼，笨蛋主人，我才不吃你的东西呢"
            end
        end
    else
        if ((today_rude >= 3 and today_sorry == 0) or today_sorry >= 2) then
            flag_food = flag_food + 1 -- 判定其他用户道歉次数...
            if (flag_food == 1) then
                flag_food = 0
                return "主人告诉我不要吃坏人给的东西！"
            end
        end
    end
    -- 判定当日上限
    local today_gift = GetUserToday(msg.fromQQ, "gifts", 0)
    if (today_gift >= today_food_limit) then
        return "对不起{nick}，茉莉今天...想换点别的口味呢呜QAQ"
    end
    today_gift = today_gift + 1
    SetUserToday(msg.fromQQ, "gifts", today_gift)
    -- 计算今日/累计投喂，存取在骰娘用户记录上
    local DiceQQ = getDiceQQ()
    local gift_add = add_gift_once()
    local self_today_gift = GetUserToday(DiceQQ, "gifts", 0) + gift_add
    SetUserToday(DiceQQ, "gifts", self_today_gift)
    local self_total_gift = GetUserConf("favorConf", DiceQQ, "gifts", 0) + gift_add
    SetUserConf("favorConf", DiceQQ, "gifts", self_total_gift)
    -- 更新好感度
    if (today_sorry == 0) then
        -- end
        favor = favor + add_favor_food(favor)
        SetUserConf("favorConf", msg.fromQQ, "好感度", favor)
        cnt = cnt - 1
        flag_food = flag_food + 1
        --
        -- //!递归调用实现多次喂食
        if (cnt > 0) then
            rcv_food(msg)
        end
        -- if(flag_food==cntT)then
        --     flag_food=0
        cnt = 0
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
    preHandle(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    -- trust关联
    if (favor < 3000) then
        return "对{nick}的好感度只有" ..
            favor .. "，要加油哦，茉莉...可是很期待{sample:我们之间能发生什么故事的哦？|你的表现的哦？|你能...（摇头），不，不，没什么|的哦，可这次...茉莉能做好吗}"
    elseif (favor < 6000) then
        return "对{nick}的好感度有" .. favor .. "，{sample:还真是发生了不少事情呢，对吧？~|茉莉要好好记下和你在一起的点点滴滴|最近对茉莉的照顾...我很感激...能不能...}"
    elseif (favor < 10000) then
        return "好感度到" ..
            favor .. "了，{sample:有时候我会想，说不定真能...嗯嗯？没，我什么都没说，对吧对吧|你总能给茉莉带来很多快乐呢|最近茉莉总有点心神不宁...算了不想了，反正和你在一起就好啦~}"
    else
        return "对{nick}的好感度已经有" ..
            favor ..
                "了，以后也要永远在一起哦，{sample:真是的...明明...还要确认一下感情吗（嘟嘴）|茉莉当初没有想到，你会一直 一直陪在茉莉身边...|茉莉觉得，只要和你一直走下去，一定能抓住属于我们的未来的吧？|遇见你之后，我才明白，原来回忆是这么让人快乐和温暖的事|那些独自做不到的事，就让我们一起来把握吧|总感觉，只有和你在一起，茉莉才能看到曾经看不见的『可能性』呢}"
    end
end
msg_order["茉莉好感"] = "show_favor"

-- 早安问候互动程序
function rcv_Ciallo_morning(msg)
    -- 每天第一次早安加5好感度
    preHandle(msg)
    local today_morning, today_rude, today_sorry = GetUserToday(msg.fromQQ, {"morning", "rude", "sorry"}, {0, 0, 0})
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    today_morning = today_morning + 1
    SetUserToday(msg.fromQQ, "morning", today_morning)
    if (favor < -600) then
        return ""
    end
    -- 爱酱专属
    if (msg.fromQQ == "2677409596") then
        if (today_rude >= 4 or today_sorry >= 2) then
            return "Error!出现机体故障！没有听清！"
        else
            -- 时间判断
            if (hour >= 5 and hour <= 10) then
                if (today_morning <= 1) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 5)
                end
                return "主人早上好！主人今日加糖特供早安是茉莉的！"
            elseif (hour == 23 or (hour >= 0 and hour <= 2)) then
                return table_draw(relpy_morning_nightWrong)
            elseif (hour >= 11 and hour <= 15) then
                return table_draw(reply_morning_afternoonWrong)
            else
                return table_draw(reply_morning_normalWrong)
            end
        end
    else
        -- 其他用户判定
        if (today_rude >= 3 or today_sorry >= 2) then
            return "Error!出现机体故障！没有听清！"
        else
            if (hour >= 5 and hour <= 10) then
                if (today_morning <= 1) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 5)
                end
                if (favor < 1500) then
                    return table_draw(reply_morning_less)
                elseif (favor < 4500) then
                    return table_draw(reply_morning_low)
                elseif (favor < 6000) then
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
    local today_morning, today_rude, today_sorry = GetUserToday(msg.fromQQ, {"morning", "rude", "sory"}, {0, 0, 0})
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
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
                    if (today_morning <= 1) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 10)
                    end
                    return "主人早上好！茉莉想死你啦！#飞扑"
                else
                    return "就、就连主人也出现幻觉了吗...（失去高光）"
                end
            end
        else
            if (favor >= 1200) then
                if (today_rude <= 2 and today_sorry <= 1) then
                    if (hour >= 5 and hour <= 10) then
                        if (today_morning <= 1) then
                            SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 10)
                        end
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
    preHandle(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    if (favor < -600) then
        return ""
    end
    if (hour > 7 and hour < 12) then
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
        if (favor < 1500) then
            return "嗯？要睡午觉了吗，也是，养好精神也很重要呢"
        elseif (favor < 4000) then
            return "午安哦，茉莉也有点困了...呼呼呼"
        elseif (favor < 6000) then
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
    -- preHandle(msg)
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
    preHandle(msg)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    if (favor < -600) then
        return ""
    end
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
                if (favor <= 1500) then
                    return "唔，中午好！{nick}，吃过午饭了吗？吃过就赶快去休息吧"
                elseif (favor <= 4500) then
                    return "中午好呀{nick}——今天过去一半了哦，有什么要做的就抓紧吧"
                elseif (favor <= 6000) then
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
    -- preHandle(msg)
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
                    return "唔..可现在不是中午哦？不过 茉莉也向你问号哦~#踮起脚尖打招呼"
                end
            end
        end
    end
end
msg_order["中午好"] = "Ciallo_noon_normal"

-- 晚安问候程序（每日首次好感度+10）
function rcv_Ciallo_night(msg)
    preHandle(msg)
    local today_night, today_rude, today_sorry = GetUserToday(msg.fromQQ, {"night", "rude", "sorry"}, {0, 0, 0})
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    today_night = today_night + 1
    SetUserToday(msg.fromQQ, "night", today_night)
    if (favor < -600) then
        return ""
    end
    if (msg.fromQQ == "2677409596") then
        if (today_rude <= 3 and today_sorry <= 1) then
            if ((hour >= 21 and hour <= 23) or (hour >= 0 and hour <= 4)) then
                if (today_night <= 1) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 5)
                end
                return "晚安哦我的主人，茉莉今天明天也会一直喜欢你的！"
            else
                return "主——人——！不要捉弄茉莉，现在显然不是睡觉时间啦！"
            end
        end
    else
        if (today_rude <= 2 and today_sorry <= 1) then
            if ((hour >= 21 and hour <= 23) or (hour >= 0 and hour <= 4)) then
                if (today_night <= 1) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 5)
                end
                if (favor < 1500) then
                    return table_draw(reply_night_less)
                elseif (favor < 4500) then
                    return table_draw(reply_night_low)
                elseif (favor < 6000) then
                    return table_draw(reply_night_high)
                else
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
--     preHandle(msg)
--     local favor=GetUserConf("favorConf",msg.fromQQ,"好感度",0)
--     local today_rude=GetUserToday(msg.fromQQ,"rude",0)
--     local today_sorry=GetUserToday(msg.fromQQ,"sorry",0)
--     if(favor<-600)then
--         return ""
--     end
-- end
-- 爱酱特殊晚安问候程序
function night_master(msg)
    preHandle(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    if (msg.fromQQ == "2677409596") then
        if (today_rude <= 3 and today_sorry <= 1) then
            if ((hour >= 21 and hour <= 23) or (hour >= 0 and hour <= 4)) then
                return "主人晚安！！诶...主人你说不是对我说的...？呜...#委屈"
            else
                return "主人这是睡傻——了吗，现在明显还没到睡觉时间呢"
            end
        end
    else
        if (favor >= 2000) then
            if (today_rude <= 2 and today_sorry <= 1) then
                if ((hour >= 21 and hour <= 23) or (hour >= 0 and hour <= 4)) then
                    return "{sample:晚安哦，虽然不知道为什么，但茉莉想主动对你说晚安~|希望明天我们能依然保持赤诚和热爱|晚安，茉莉会你身边安心陪你睡着的哦？|晚安~愿你梦中星河烂漫，美好依旧}"
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
    -- preHandle(msg)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
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
        if (today_rude <= 2 and today_sorry <= 1) then
            if (favor < 1000) then
                return table_draw(reply_night_less)
            elseif (favor < 2000) then
                return table_draw(reply_night_low)
            elseif (favor < 3000) then
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
    -- preHandle(msg)
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
    -- 为了使触发该函数时不触发版本通告，不使用preHandle(msg)而采取部分内联形式
    FavorPunish(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local trust_flag = GetUserConf("favorConf", msg.fromQQ, "trust_flag", 0)
    local admin_judge = msg.fromQQ ~= "2677409596" and msg.fromQQ ~= "3032902237"
    local today_rude = GetUserToday(msg.fromQQ, "rude", 0)
    -- festival(msg)
    if (admin_judge) then
        if (favor < 1000) then
            if (trust_flag == 0) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 0", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust_flag", 0)
        elseif (favor < 3000) then
            if (trust_flag == 1) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 1", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust_flag", 1)
        elseif (favor < 5000) then
            if (trust_flag == 2) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 2", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust_flag", 2)
        else
            if (trust_flag == 3) then
                return ""
            end
            eventMsg(".user trust " .. msg.fromQQ .. " 3", 0, 2677409596)
            SetUserConf("favorConf", msg.fromQQ, "trust_flag", 3)
        end
    end

    -- 没有指明对茉莉的脏话
    if (string.find(msg.fromMsg, "茉莉", 1) == nil) then
        sendMsg("success", 0, msg.fromQQ)
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
    preHandle(msg)
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
    preHandle(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local today_rude, today_sorry = GetUserToday(msg.fromQQ, {"rude", "sorry"}, {0, 0})
    local RS_judge
    local today_interaction = GetUserToday(msg.fromQQ, "今日互动", 0)
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
    local level
    if (favor <= 1500) then
        level = "less"
        SetUserConf("favorConf", msg.fromQQ, "好感度", favor - ranint(50, 100))
    elseif (favor <= 3000) then
        level = "low"
    elseif (favor <= 5000) then
        level = "high"
        if (today_interaction <= today_lift_limit) then
            SetUserConf("favorConf", msg.fromQQ, "好感度", favor + ranint(12, 25))
        end
    else
        level = "highest"
        if (today_interaction <= today_lift_limit) then
            SetUserConf("favorConf", msg.fromQQ, "好感度", favor + ranint(15, 30))
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
    -- preHandle(msg)
    --! 千音暂时不回复
    if (msg.fromQQ == "959686587") then
        return ""
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
            reply_main = "{sample:嗯哼？茉莉在这哦~Ciallo|诶...是在叫茉莉吗？茉莉茉莉在哦~|我听到了！就是{nick}在叫我！这次一定没有错！}"
        end
    end
end

function action(msg)
    preHandle(msg)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)

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
        today_love =
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
            "love"
        },
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    )

    local blackReply = blackList(msg)

    if (blackReply ~= "" and blackReply ~= "已触发！") then
        return blackReply
    elseif (blackReply == "已触发！") then
        return ""
    end
    -- action 抱
    local judge_hug = string.find(msg.fromMsg, "抱", 1) ~= nil
    if (judge_hug) then
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
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 25)
                    end
                    reply_main = "诶诶诶！主人你...#稍有惊讶后很快放松下来 以后也要一直和茉莉在一起哦#抱紧"
                end
            end
        else
            if (today_rude >= 3 or today_sorry >= 2) then
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 300)
                reply_main = "哼！做了这种事的坏孩子不要碰茉莉！#有力挣开"
            else
                if (hugtosorry == 1) then
                    SetUserToday(msg.fromQQ, {"rude", "hug_needed_to_sorry"}, {0, 0})
                    reply_main = "唔姆姆，茉莉这次、这次...这次就原谅你！#音量莫名提高"
                else
                    if (favor <= 1500) then
                        if (today_hug <= today_hug_limit) then
                            SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 125)
                        end
                        reply_main = table_draw(reply_hug_less)
                    elseif (favor <= 3000) then
                        if (today_hug <= today_hug_limit) then
                            SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 8)
                        end
                        reply_main = table_draw(reply_hug_low)
                    elseif (favor <= 6000) then
                        if (today_hug <= today_hug_limit) then
                            SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 15)
                        end
                        reply_main = table_draw(reply_hug_high)
                    else
                        if (today_hug <= today_hug_limit) then
                            SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 25)
                        end
                        reply_main = table_draw(reply_hug_highest)
                    end
                end
            end
        end
    end
    -- action 摸头
    local judge_touch = string.find(msg.fromMsg, "摸头", 1) ~= nil or string.find(msg.fromMsg, "摸摸", 1) ~= nil
    if (judge_touch) then
        today_touch = today_touch + 1
        SetUserToday(msg.fromQQ, "touch", today_touch)
        if (msg.fromQQ == "2677409596") then
            if (today_rude >= 4 or today_sorry >= 2) then
                reply_main = "被笨蛋主人这样摸头...总感觉开心不起来呢"
            else
                if (today_touch <= today_touch_limit) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 20)
                end
                reply_main = "唔唔唔，主、主人不要摸啦，头、头发会乱的...#闭眼缩起脖子"
            end
        else
            if (today_rude >= 3 or today_sorry >= 2) then
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 100)
                reply_main = "不 不要！你是坏人，茉莉的头才不会让你摸呢！"
            else
                if (favor <= 1000) then
                    if (today_touch <= today_touch_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 40)
                    end
                    reply_main = table_draw(reply_touch_less)
                elseif (favor <= 2000) then
                    if (today_touch <= today_touch_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 8)
                    end
                    reply_main = table_draw(reply_touch_low)
                elseif (favor <= 4500) then
                    if (today_touch <= today_touch_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 12)
                    end
                    reply_main = table_draw(reply_touch_high)
                else
                    if (today_touch <= today_touch_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 16)
                    end
                    reply_main = table_draw(reply_touch_highest)
                end
            end
        end
    end
    -- action举高高
    local judge_lift = string.find(msg.fromMsg, "举高", 1) ~= nil
    if (judge_lift) then
        today_lift = today_lift + 1
        SetUserToday(msg.fromQQ, "lift", today_lift)
        if (msg.fromQQ == "2677409596") then
            if (today_rude <= 3 and today_sorry <= 1) then
                if (today_lift <= today_lift_limit) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 15)
                end
                reply_main = "啊主主主、主人 好、好高啊！再、再转几圈吧！#露出了开心的笑容"
            else
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 100)
                reply_main = "笨、笨蛋主人...！快放我下来！啊！"
            end
        else
            if (today_rude <= 2 and today_sorry <= 1) then
                if (favor <= 1550) then
                    if (today_lift <= today_lift_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 100)
                    end
                    reply_main = table_draw(reply_lift_less)
                elseif (favor <= 3200) then
                    if (today_lift <= today_lift_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 10)
                    end
                    reply_main = table_draw(reply_lift_low)
                elseif (favor <= 6800) then
                    if (today_lift <= today_lift_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 14)
                    end
                    reply_main = table_draw(reply_lift_high)
                else
                    if (today_lift <= today_lift_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 18)
                    end
                    reply_main = table_draw(reply_lift_highest)
                end
            else
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 100)
                reply_main = "主人教过茉莉，笨蛋不能这样做！"
            end
        end
    end
    -- action kiss
    local judge_kiss = string.find(msg.fromMsg, "亲", 1) ~= nil
    if (judge_kiss) then
        today_kiss = today_kiss + 1
        SetUserToday(msg.fromQQ, "kiss", today_kiss)
        if (msg.fromQQ == "2677409596") then
            if (today_rude <= 3 and today_sorry <= 1) then
                if (today_kiss <= today_kiss_limit) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 50)
                end
                reply_main = "啊...主、主人...你你你！#低头脸红 你讨厌死了！#捶胸口时埋到怀里"
            else
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 150)
                reply_main = "笨蛋主人！#快速扭过头然后看你 茉莉原谅你之前绝对不会让你亲的！"
            end
        else
            if (today_rude <= 2 and today_sorry <= 1) then
                if (favor <= 1700) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 175)
                    reply_main = table_draw(reply_kiss_less)
                elseif (favor <= 3200) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 20)
                    reply_main = table_draw(reply_kiss_low)
                elseif (favor <= 6700) then
                    if (today_kiss <= today_kiss_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 40)
                    end
                    reply_main = table_draw(reply_kiss_high)
                else
                    if (today_kiss <= today_kiss_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 65)
                    end
                    reply_main = table_draw(reply_kiss_highest)
                end
            else
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 200)
                reply_main = "哼，才不想理笨蛋呢"
            end
        end
    end
    -- action 牵手
    local judge_hand = string.find(msg.fromMsg, "牵手", 1) ~= nil
    if (judge_hand) then
        today_hand = today_hand + 1
        SetUserToday(msg.fromQQ, "hand", today_hand)
        if (msg.fromQQ == "2677409596") then
            if (today_rude <= 3 and today_sorry <= 1) then
                if (today_hand <= today_hand_limit) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 10)
                end
                reply_main = "诶？要牵手吗...嗯...嗯 那 就不要放开了哦~主人——"
            else
                reply_main = "哼...茉莉可还没有原谅主人哦，所以，不给你——牵！"
            end
        else
            if (today_rude <= 2 and today_sorry <= 1) then
                if (favor <= 1200) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 45)
                    reply_main = table_draw(reply_hand_less)
                elseif (favor <= 3500) then
                    if (today_hand <= today_hand_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 8)
                    end
                    reply_main = table_draw(reply_hand_low)
                elseif (favor <= 6000) then
                    if (today_hand <= today_hand_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 10)
                    end
                    reply_main = table_draw(reply_hand_high)
                else
                    if (today_hand <= today_hand_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 12)
                    end
                    reply_main = table_draw(reply_hand_highest)
                end
            else
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 80)
                reply_main = "在茉莉原谅你之前，才不会让笨蛋这么做"
            end
        end
    end
    -- action 捏/揉脸
    local judge_face =
        string.find(msg.fromMsg, "捏脸", 1) ~= nil or string.find(msg.fromMsg, "揉脸", 1) ~= nil or
        string.find(msg.fromMsg, "揉揉", 11) ~= nil
    if (judge_face) then
        today_face = today_face + 1
        SetUserToday(msg.fromQQ, "face", today_face)
        if (msg.fromQQ == "2677409596") then
            if (today_rude <= 3 and today_sorry <= 1) then
                if (today_face <= today_face_limit) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 7)
                end
                reply_main = "哎哎哎主人——别别这样，茉莉...茉莉感觉浑身发热了呜..."
            else
                reply_main = "#快速撇开头 略略略！茉莉就不给你碰——"
            end
        else
            if (today_rude <= 2 and today_sorry <= 1) then
                if (favor <= 1100) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 40)
                    reply_main = table_draw(reply_face_less)
                elseif (favor <= 3200) then
                    if (today_face <= today_face_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 5)
                    end
                    reply_main = table_draw(reply_face_low)
                elseif (favor <= 6000) then
                    if (today_face <= today_face_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 10)
                    end
                    reply_main = table_draw(reply_face_high)
                else
                    if (today_face <= today_face_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 14)
                    end
                    reply_main = table_draw(reply_face_highest)
                end
            else
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 70)
                reply_main = "不要随便碰我！你这个坏人！大笨蛋！#耍脾气"
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
        today_cute = today_cute + 1
        SetUserToday(msg.fromQQ, "cute", today_cute)
        if (msg.fromQQ == "2677409596") then
            if (today_rude <= 3 and today_sorry <= 1) then
                if (today_cute <= today_cute_limit) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 15)
                end
                reply_main = "诶诶诶？主...主人夸我了！#惊喜 还..还有点不好意思呢...#傻笑"
            else
                reply_main = "哼，不管主人怎么夸，茉莉都不会心动的 #气鼓鼓嘟起嘴"
            end
        else
            if (today_rude <= 2 and today_sorry <= 1) then
                if (favor <= 1050) then
                    if (today_cute <= today_cute_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 8)
                    end
                    reply_main = table_draw(reply_cute_less)
                elseif (favor <= 3000) then
                    if (today_cute <= today_cute_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 10)
                    end
                    reply_main = table_draw(reply_cute_low)
                elseif (favor <= 4000) then
                    if (today_cute <= today_cute_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 12)
                    end
                    reply_main = table_draw(reply_cute_high)
                else
                    if (today_cute <= today_cute_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 15)
                    end
                    reply_main = table_draw(reply_cute_highest)
                end
            else
                reply_main "不行哦——，茉莉是不会接受笨蛋的夸奖的哦~"
            end
        end
    end
    -- express suki
    local judge_suki = string.find(msg.fromMsg, "喜欢", 1) ~= nil or string.find(msg.fromMsg, "suki", 1) ~= nil
    if (judge_suki) then
        today_suki = today_suki + 1
        SetUserToday(msg.fromQQ, "suki", today_suki)
        if (msg.fromQQ == "2677409596") then
            if (today_rude <= 3 and today_sorry <= 1) then
                if (today_suki <= today_suki_limit) then
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 20)
                end
                reply_main = "啊..#呆住 Error！检测到机体温度迅速升高，要主人抱抱才能缓解！"
            else
                reply_main = "哼...就算主人这么说了...不！不对！主人是大笨蛋！茉莉才不会因为这种花言巧语而心软呢！"
            end
        else
            if (today_rude <= 2 and today_sorry <= 1) then
                if (favor <= 1500) then
                    reply_main = table_draw(reply_suki_less)
                elseif (favor <= 3500) then
                    if (today_suki <= today_suki_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 12)
                    end
                    reply_main = table_draw(reply_suki_low)
                elseif (favor <= 5500) then
                    if (today_suki <= today_suki_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 15)
                    end
                    reply_main = table_draw(reply_suki_high)
                else
                    if (today_suki <= today_suki_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 20)
                    end
                    reply_main = table_draw(reply_suki_highest)
                end
            else
                return "哼，笨蛋还好意思说出这些话"
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
                    SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 30)
                end
                reply_main = "啊啊啊主主主主主人你你你突然说些什么啊...我我我...茉莉...茉莉当然...也爱你啦（逐渐小声）"
            else
                reply_main = "诶？爱...主人爱我...？#面无表情但脸红 可、可别以为这样茉莉就会原谅你...#移开视线"
            end
        else
            if (today_rude <= 2 and today_sorry <= 1) then
                if (favor <= 1800) then
                    reply_main = table_draw(reply_love_less)
                elseif (favor <= 4500) then
                    if (today_love <= today_love_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 15)
                    end
                    reply_main = table_draw(reply_love_low)
                elseif (favor <= 6500) then
                    if (today_love <= today_love_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 20)
                    end
                    reply_main = table_draw(reply_love_high)
                else
                    if (today_love <= today_love_limit) then
                        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 25)
                    end
                    reply_main = table_draw(reply_love_highest)
                end
            else
                reply_main = "哼，茉莉可不想被茉莉说爱我，不、不然...不然茉莉不也是笨蛋了吗..."
            end
        end
    end
    -- 最后判断是否是“互动--部位”格式
    -- interaction(msg)
end

-- 以“茉莉 ”开头代表对象指向 然后搜索匹配相关动作
reply_main = ""
-- 执行函数相应“茉莉”
function action_main(msg)
    for k, v in pairs(rude_table) do
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

-- function picture(msg)
--     return "[CQ:image,url=https://img.paulzzh.com/touhou/konachan/image/2491526e5dce044efea57ef29e6a9999.jpg]"
-- end
-- msg_order["图片"]="picture"

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

admin_order4 = "好感历史 "
function favor_history(msg)
    local QQ = string.match(msg.fromMsg, "%d*", #admin_order4 + 1)
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        return "目标最后一次好感交互在" ..
            string.format("%.0f", GetUserConf("favorConf", QQ, "year_last", 2021)) ..
                "年" ..
                    string.format("%.0f", GetUserConf("favorConf", QQ, "month_last", 10)) ..
                        "月" ..
                            string.format("%.0f", GetUserConf("favorConf", QQ, "day_last", 11)) ..
                                "日" ..
                                    string.format("%.0f", GetUserConf("favorConf", QQ, "hour_last", 23)) ..
                                        "时" .. "\n好感度为" .. string.format("%.0f", GetUserConf("favorConf", QQ, "好感度", 0))
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

function table_draw(tab)
    return tab[ranint(1, #tab)]
end
