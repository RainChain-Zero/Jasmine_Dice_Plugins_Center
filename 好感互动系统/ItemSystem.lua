package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"
package.path = getDiceDir() .. "/plugin/Handle/?.lua"
require "FavorHandle"
require "MoodHandle"
require "Utils"
msg_order = {}
-- item为全局变量，检测合法性时不用传入
-- 使用道具
function UseItem(msg)
    local Item = ReadItem()
    local reply = "唔姆姆，你这是要对着空气做什么呀？（部分物品需要赠送给茉莉才会触发：“赠送茉莉 数量 道具”数量不填默认为1）"
    local num, item, flag1, flag2 = "", "", false, false
    num, item = string.match(msg.fromMsg, "[u,U][%s]*(%d*)[%s]*(.*)")
    if (not item or item == "") then
        return "请输入道具名哦~（输入“道具图鉴”可查看目前支持的所有道具）"
    end
    -- 数量默认为1
    if (not num or num == "") then
        num = 1
    end
    -- 道具剩余数量判断
    flag1, flag2, item = UseCheck(msg, num, Item, item)
    if (not flag1) then
        return "咦，茉莉的数据库里似乎没有该道具呢..."
    end
    if (not flag2) then
        return "哒咩哟哒咩，超额透支是不行的！"
    end

    -- 八音盒
    if item:find("八音盒") then
        local musicBox = getUserConf(msg.fromQQ, "musicBox", {})
        local enable, cd = musicBox["enable"] or false, musicBox["cd"] or 0
        if enable then
            return "该道具已生效，无法重复使用哦~"
        end
        if os.time() < cd then
            return "该道具冷却中，无法使用哦~"
        end
        setUserConf(msg.fromQQ, "musicBox", {enable = true, cd = os.time() + 432000})
        if msg.fromQQ == "3358315232" then
            msg:echo(
                "按下暗格，流水般的乐声从八音盒中缓缓流淌出来，往日的景色渐渐浮现与你的眼前，那粉蝶花丛的香气也变得渐渐可闻。\n一曲终了，意犹未尽。\n再次按下暗格，熟悉的乐声再度入耳，而那往日的景象也愈发清晰。\n——可在这和谐的乐声之中，却忽的出现了一个不和谐的音符。\n——就像是被人刻意改了一笔的钢琴乐谱。\n再度按下暗格，可那熟悉的乐声却消逝不见，而那八音盒却转而演奏起了狂乱的乐章。\n如果是刚刚是被人刻意改了一笔的琴谱，这这次则是八音盒在自发的弹奏着那被人胡写一通，毫无规律与美感可言的谱子。\n往日的幻象逐渐破碎，而今昔的痛楚却伴随着新的乐章迅猛袭来。\n乐声愈发狂乱，可那停留于记忆之中的粉蝶花丛也渐破碎远去。\n终了，就连那狂乱的乐声也渐消逝不见，耳中只余几声嘈杂的噪音。"
            )
        else
            msg:echo(Item["八音盒"].reply)
        end
        -- 八音盒将发送bgm
        return build_voice("八音盒bgm.mp3")
    elseif item:find("投影灯") then
        local light = getUserConf(msg.fromQQ, "projectionLamp", {})
        local lasting, cd = light["lasting"] or 0, light["cd"] or 0
        local now = os.time()
        if lasting > now then
            return "该道具已生效，无法重复使用哦~"
        end
        if now < cd then
            return "该道具冷却中，无法使用哦~"
        end
        setUserConf(msg.fromQQ, "projectionLamp", {cd = now + 432000, lasting = now + 172800})
        return Item["星幕投影灯"].reply
    elseif item:find("风车发饰") then
        local isSpecial7Read, specialUnlockedNotice =
            GetUserConf(
            "storyConf",
            msg.fromQQ,
            {"isSpecial7Read", "specialUnlockedNotice"},
            {0, 0000000000000000000000000}
        )
        local flag = string.sub(specialUnlockedNotice, 9, 9)
        -- “我所希冀的”阅读完毕后才会出发提示
        -- 追忆篇也会占用一格specialUnlockedNotice
        if isSpecial7Read == 1 and flag == "0" then
            SetUserConf(
                "storyConf",
                msg.fromQQ,
                "specialUnlockedNotice",
                string.sub(specialUnlockedNotice, 1, 8) .. "1" .. string.sub(specialUnlockedNotice, 10)
            )
            msg:echo("『✔提示』「流希」支线「追忆·其一」已经开放,输入“进入剧情 追忆·其一”可浏览剧情")
        end
        return Item["风车发饰"].reply
    end

    -- ? 是否用于解锁剧情章节
    local succ = false
    local entryStoryCheck = GetUserConf("storyConf", msg.fromQQ, "entryCheckStory", -1)
    if (entryStoryCheck ~= -1) then
        reply, succ = UnlockStory(msg, entryStoryCheck, item)
        if (succ == true) then
            SetUserConf("storyConf", msg.fromQQ, "entryCheckStory", -1)
        end
    end
    return reply
end
msg_order["/u"] = "UseItem"
msg_order["/U"] = "UseItem"

-- 赠送茉莉礼物
gift_order = "赠送茉莉"
function GiveGift(msg)
    --! 防止校准时使用物品导致物品在无提示的情况下失效
    local calibration = getUserConf(getDiceQQ(), "calibration", 0)
    local calibration_limit = getUserConf(getDiceQQ(), "calibration_limit", 12)
    -- 好奇的回复
    local curiosity_reply = nil
    if (calibration > calibration_limit) then
        return "本轮时钟周期已结束，请进行『校准』\n(指令为“茉莉校准”)"
    end

    local Gift_list = ReadItem()
    local num, item, flag1, flag2 = "", "", false, false
    local favor_ori, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
    num, item = string.match(msg.fromMsg, "[%s]*(%d*)[%s]*(.+)", #gift_order + 1)
    if (not num or num == "") then
        num = 1
    end
    num = num * 1
    if (not item or item == "") then
        return "『✖参数不足』诶诶诶？{nick}这是要送给茉莉什么呀？是...？惊喜吗！"
    end
    -- 合理性判断
    flag1, flag2, item = UseCheck(msg, num, Gift_list, item)
    if (not flag1) then
        return "『✖Error』嗯嗯嗯？原来这世上还存在这种东西的吗×"
    end
    if (not flag2) then
        return "『✖余量不足』好像该物品的剩余数量不足哦"
    end
    -- 检验是否是礼物
    if (Gift_list[item].gift == false) then
        return "『✖Error』这可不能送给茉莉哦~（小声提示）"
    end

    -- 处理特殊道具
    local reply = SpecialGift(msg, item, num, Gift_list, favor_ori, affinity)
    if (reply ~= nil) then
        check_curiosity(msg, item)
        return reply
    end
    -- 固定属性
    local favor_now
    local affinity_now = affinity
    --! 先调整亲和度，不然可能破千不清空亲和
    if (Gift_list[item].affinity ~= nil) then
        affinity_now = affinity + num * Gift_list[item].affinity
        if (affinity_now > 100) then
            affinity_now = 100
        end
        SetUserConf("favorConf", msg.fromQQ, "affinity", affinity_now)
    end
    if (Gift_list[item].favor ~= nil) then
        local special_mood, coefficient = GetUserConf("moodConf", msg.fromQQ, {"special_mood", "coefficient"}, {0, 1})
        coefficient = get_coefficient(special_mood, coefficient, {"渴望", "失望"})
        local favor_change, calibration_message =
            ModifyFavorChangeGift(msg, favor_ori, Gift_list[item].favor * coefficient, affinity_now)
        if (calibration_message ~= nil) then
            return calibration_message
        end
        favor_now = favor_ori + num * favor_change
        favor_now = CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity_now)
    end
    -- 持续性道具处理
    LastingItem(msg, item)
    check_curiosity(msg, item)

    SetUserConf("itemConf", msg.fromQQ, item, GetUserConf("itemConf", msg.fromQQ, item, 0) - num)

    return Gift_list[item].reply
end
msg_order[gift_order] = "GiveGift"
msg_order["贈送茉莉"] = "GiveGift"

function check_curiosity(msg, item)
    -- 处理“好奇”的任务
    local curiosity_gift = GetUserConf("missionConf", msg.fromQQ, "curiosity_gift", nil)
    if curiosity_gift == item then
        SetUserConf("missionConf", msg.fromQQ, "curiosity_gift", nil)
        -- 有5%概率获得300好感
        if (ranint(1, 100) <= 5) then
            local favor_now = GetUserConf("favorConf", msg.fromQQ, "favor", 0)
            favor_now = favor_now + 300
            SetUserConf("favorConf", msg.fromQQ, "favor", favor_now)
            msg:echo("『✧任务达成』{nick}送给茉莉的礼物竟然是茉莉最想要的东西！\n茉莉对{nick}的好感度额外上升了300！")
        end
    end
end

-- reply定制
reply_order = "定制reply"
function CustomizeReply(msg)
    if (GetUserConf("itemConf", msg.fromQQ, "定制reply", 0) == 0) then
        return "『✖余量不足』你现在并没有定制reply的剩余条数哦"
    end
    local content = string.match(msg.fromMsg, "[%s]*(.*)", #reply_order + 1)
    if (content == nil or content == "") then
        return "『✖参数不足』诶？你的要求可不能为空哦~示例:“定制reply xxxx(这里填你的要求)”"
    end
    content =
        "【系统邮件】收到了一条reply定制请求\n申请人：" ..
        getUserConf(msg.fromQQ, "nick", "用户名获取失败") .. "(" .. msg.fromQQ .. ")\n内容：" .. content
    sendMsg(content, 432653151, 0)
    return "已经成功将请求发送至管理员~请耐心等待答复哦~\n为了能正常接收提示消息，请添加茉莉为好友w"
end
msg_order[reply_order] = "CustomizeReply"

-- 完成reply定制
finish_reply_order = "完成定制reply"
function FinishtCustomizedReply(msg)
    if (msg.fromQQ ~= "3032902237" and msg.fromQQ ~= "2677409596") then
        return "『✖权限不足』只有管理员才可确认定制reply完成"
    end
    local QQ, msg = string.match(msg.fromMsg, "[%s]*(%d+)%s*(%S*)", #finish_reply_order + 1)
    if (QQ == nil or QQ == "") then
        return "『✖参数不足』请输入确认完成reply的目标QQ"
    end
    local content = "【系统邮件】您的定制reply已经完成，如有问题请通过“.send [消息内容]”进行反馈哦~"
    if msg then
        content = content .. "\n附加消息：" .. msg
    end
    SetUserConf("itemConf", QQ, "定制reply", GetUserConf("itemConf", QQ, "定制reply", 0) - 1)
    sendMsg(content, 0, QQ)
    return "已确认完成该reply定制"
end
msg_order[finish_reply_order] = "FinishtCustomizedReply"

-- 道具使用合理性判断
function UseCheck(msg, num, table, item)
    local flag1 = false
    item = covert_traditional_simplified(item)
    -- 判断道具是否存在
    for k, _ in pairs(table) do
        if (k:find(item) ~= nil) then
            flag1 = true
            item = k
            break
        end
    end
    -- 不存在直接返回
    if (not flag1) then
        return false, false
    end
    -- 判断道具余量
    if (GetUserConf("itemConf", msg.fromQQ, item, 0) * 1 < num * 1) then
        return true, false
    end
    return true, true, item
end

-- 解锁剧情章节
function UnlockStory(msg, entryStoryCheck, item)
    if (entryStoryCheck == 1) then
        if (item:find("梦的开始") ~= nil) then
            if (GetUserConf("itemConf", msg.fromQQ, "梦的开始", 0) == 0) then
                return "『✖余量不足』您的『梦的开始』余量不足", false
            end
            SetUserConf("storyConf", msg.fromQQ, {"entryStoryCheck", "isStory1Unlocked"}, {-1, 1})
            return "这把钥匙似乎和眼前的光芒产生了某种共鸣，倏忽间，光芒如同被某种强大的引力吸引般瞬间汇聚于钥匙上后逐渐稳定了下来...\f" .. "系统：注意，剧情模式第一章已经解锁！", true
        else
            return "你小心翼翼地将它向那团光球接近，但就在你要触及之时，一股强大的斥力将你远远弹开了...", false
        end
    end
end

-- 特殊道具处理
function SpecialGift(msg, item, num, Item, favor_ori, affinity)
    local favor_now, idx, dice = 0, 0, 0
    if (item == "彩虹糖") then
        num = JudgeSpecialItemNum(msg, num)
        SetUserConf("itemConf", msg.fromQQ, item, GetUserConf("itemConf", msg.fromQQ, item, 0) - 1)
        idx = ranint(1, 3)
        local favor_change = Item[item].res[idx].favor
        if (favor_change > 0) then
            favor_now = favor_ori + ModifyFavorChangeGift(msg, favor_ori, favor_change, affinity)
        else
            favor_now = favor_ori + ModifyFavorChangeNormal(msg, favor_ori, favor_change, affinity)
        end
        CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
        return Item[item].res[idx].reply
    elseif (item == "冰激凌") then
        num = JudgeSpecialItemNum(msg, num)
        SetUserConf("itemConf", msg.fromQQ, item, GetUserConf("itemConf", msg.fromQQ, item, 0) - 1)
        local icecreamEaten = GetUserConf("adjustConf", msg.fromQQ, "icecreamEaten", 0)
        if (icecreamEaten == 0) then
            dice = ranint(1, 10)
            if (dice == 10) then
                favor_now = favor_ori + ModifyFavorChangeNormal(msg, favor_ori, Item[item].res[2].favor, affinity)
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                SetUserConf("adjustConf", msg.fromQQ, "icecreamEaten", 0)
                return Item[item].res[2].reply
            else
                favor_now = favor_ori + ModifyFavorChangeGift(msg, favor_ori, Item[item].res[1].favor, affinity)
                CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
                SetUserConf("adjustConf", msg.fromQQ, "icecreamEaten", 1)
                return Item[item].res[1].reply
            end
        elseif (icecreamEaten == 1) then
            dice = ranint(1, 3)
            if (dice == 3) then
                SetUserConf("adjustConf", msg.fromQQ, "icecreamEaten", 0)
                favor_now = favor_ori + ModifyFavorChangeNormal(msg, favor_ori, Item[item].res[2].favor, affinity)
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                return Item[item].res[2].reply
            else
                favor_now = favor_ori + ModifyFavorChangeGift(msg, favor_ori, Item[item].res[1].favor, affinity)
                CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
                SetUserConf("adjustConf", msg.fromQQ, "icecreamEaten", 2)
                return Item[item].res[1].reply
            end
        elseif (icecreamEaten == 2) then
            dice = ranint(1, 2)
            if (dice == 2) then
                SetUserConf("adjustConf", msg.fromQQ, "icecreamEaten", 0)
                favor_now = favor_ori + ModifyFavorChangeNormal(msg, favor_ori, Item[item].res[2].favor, affinity)
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor_now)
                return Item[item].res[2].reply
            else
                favor_now = favor_ori + ModifyFavorChangeGift(msg, favor_ori, Item[item].res[1].favor, affinity)
                CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
                return Item[item].res[1].reply
            end
        end
    end
    return nil
end

function JudgeSpecialItemNum(msg, num)
    if (num > 1) then
        msg:echo("注意，该道具具有随机效果，一次只能赠送一个哦")
        return 1
    end
    return num
end
-- 持续性道具
function LastingItem(msg, item)
    if (item == "推理小说") then
        -- !时间惩罚降低的好感减少百分之多少，同类不覆盖
        local rate = GetUserConf("adjustConf", msg.fromQQ, "favorTimePunishDownRate", 0)
        -- 更新时间，取最新时间
        -- ! 打上标记，用做发送提醒的标记
        SetUserConf(
            "adjustConf",
            msg.fromQQ,
            {"favorTimePunishDownDDL", "favorTimePunishDownDDLFlag"},
            {os.time() + 5 * 24 * 60 * 60, 0}
        )

        if (rate < 0.3) then
            SetUserConf("adjustConf", msg.fromQQ, "favorTimePunishDownRate", 0.3)
        end
    elseif (item == "袋装曲奇") then
        -- ! 效果不会叠加,用os.time()秒级存储到期时间，更新为最新时间
        -- ! 打上标记，用做发送提醒的标记
        SetUserConf(
            "adjustConf",
            msg.fromQQ,
            {"addFavorDDL_Cookie", "addFavorDDLFlag_Cookie"},
            {os.time() + 3 * 24 * 60 * 60, 0}
        )
    elseif (item == "寿司") then
        --! 同类效果不叠加，打标记用于发送提醒
        SetUserConf(
            "adjustConf",
            msg.fromQQ,
            {"addAffinityDDL_Sushi", "addAffinityDDLFlag_Sushi"},
            {os.time() + 3 * 24 * 60 * 60, 0}
        )
    elseif (item == "发簪") then
        --! 同类效果不叠加，超出当日交互上限不计
        SetUserConf(
            "adjustConf",
            msg.fromQQ,
            {"addFavorPerActionDDL_Hairpin", "addFavorPerActionDDLFlag_Hairpin"},
            {os.time() + 3 * 24 * 60 * 60, 0}
        )
    end
end

-- 查询
check_order = "查询"
function SearchItem(msg)
    local Item = ReadItem()
    local item = string.match(msg.fromMsg, "[%s]*(.*)", #check_order + 1)
    local flag = false
    if (item == nil or item == "") then
        return "系统：请输入要查询的条目哦~"
    end
    if (item == "好感") then
        item = "好感度"
    end
    if item == "FL" then
        item = "fl"
    end
    item = covert_traditional_simplified(item)
    -- 判断道具是否存在
    for k, _ in pairs(Item) do
        if (k:find(item) ~= nil) then
            flag = true
            item = k
            break
        end
    end
    if (not flag) then
        return "该道具暂未被图鉴收录哦~"
    end
    local res = 0
    if (item ~= "好感度") then
        res = GetUserConf("itemConf", msg.fromQQ, item, 0)
    else
        res = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    end

    local content = "您目前的『" .. item .. "』数量为" .. string.format("%0.f", res) .. "\n(" .. Item[item].des .. ")"
    --! 查询八音盒会进入隐藏剧情
    if item:find("八音盒") then
        local musicBoxNum = GetUserConf("itemConf", msg.fromQQ, "八音盒", 0)
        if musicBoxNum >= 1 then
            SetUserConf("storyConf", msg.fromQQ, "specialReadNow", 4)
            content = content .. "\n提示：你可以通过输入.f来阅读此道具的隐藏剧情"
        end
    end
    return content
end
msg_order[check_order] = "SearchItem"
msg_order["查詢"] = "SearchItem"

-- 道具图鉴
function HandBook(msg)
    local Item = ReadItem()
    local res = {}
    local item_num = GetUserConf("itemConf", msg.fromQQ, {}, {}, true)
    for k, _ in pairs(Item) do
        local num = item_num[k] or 0
        if (Item[k].cohesion == nil) then
            if (res[0] == nil) then
                res[0] = ""
            end
            res[0] = res[0] .. k .. "  " .. num .. "\n"
        else
            if (res[Item[k].cohesion] == nil) then
                res[Item[k].cohesion] = ""
            end
            res[Item[k].cohesion] = res[Item[k].cohesion] .. k .. Item[k].class .. "  " .. num .. "\n"
        end
    end
    local reply = ""
    --! 直接采用索引 记得之后更改
    for i = 0, 3, 1 do
        reply = reply .. res[i] .. "===============\n"
    end
    return reply
end
msg_order["道具图鉴"] = "HandBook"
msg_order["道具圖鑒"] = "HandBook"

-- 道具繁体转简体
function covert_traditional_simplified(item)
    local covert_table = {
        ["夢的開始"] = "梦的开始",
        ["星幕投影燈"] = "星幕投影灯",
        ["野餐籃"] = "野餐篮",
        ["袋裝曲奇"] = "袋装曲奇",
        ["快樂水"] = "快乐水",
        ["推理小說"] = "推理小说",
        ["冰激淩"] = "冰激凌",
        ["可頌"] = "可颂",
        ["發簪"] = "发簪",
        ["壽司"] = "寿司",
        ["風車發飾"] = "风车发饰"
    }
    return covert_table[item] or item
end
