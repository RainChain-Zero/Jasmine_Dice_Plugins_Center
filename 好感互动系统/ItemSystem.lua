--[[
    @author 慕北_Innocent(RainChain)
    @version 1.1
    @Create 2022/01/19 11:30
    @Last Modified 2022/03/31 23:36
    ]] package.path =
    getDiceDir() .. "/plugin/ReplyAndDescription/?.lua"
require "itemDescription"
package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"
require "itemIO"
package.path = getDiceDir() .. "/plugin/handle/?.lua"
require "favorhandle"
msg_order = {}
-- item为全局变量，检测合法性时不用传入
-- 使用道具
function UseItem(msg)
    local Item = ReadItem()
    local reply = "唔姆姆，你这是要对着空气做什么呀？（部分物品需要赠送给茉莉才会触发：“赠送茉莉 数量 道具”数量不填默认为1）"
    local num, item, flag1, flag2 = "", "", false, false
    num, item = string.match(msg.fromMsg, "[u,U][%s]*(%d*)[%s]*(.*)")
    if (item == nil or item == "") then
        return "请输入道具名哦~（输入“道具图鉴”可查看目前支持的所有道具）"
    end
    -- 数量默认为1
    if (num == "" or num == nil) then
        num = 1
    end
    --! 梦的开始bug判断
    if
        (GetUserConf("storyConf", msg.fromQQ, "isStory0Read", 0) == 1 and
            GetUserConf("itemConf", msg.fromQQ, "梦的开始", 0) == 0)
     then
        SetUserConf("itemConf", msg.fromQQ, "梦的开始", 1)
    end
    -- 道具剩余数量判断
    flag1, flag2, item = UseCheck(msg, num, Item, item)
    if (not flag1) then
        return "咦，茉莉的数据库里似乎没有该道具呢..."
    end
    if (not flag2) then
        return "哒咩哟哒咩，超额透支是不行的！"
    end

    -- ? 是否用于解锁剧情章节
    local entryStoryCheck = GetUserConf("storyConf", msg.fromQQ, "entryCheckStory", -1)
    if (entryStoryCheck ~= -1) then
        reply = UnlockStory(msg, entryStoryCheck, item)
        SetUserConf("storyConf", msg.fromQQ, "entryCheckStory", -1)
    end

    return reply
end
msg_order["/u"] = "UseItem"
msg_order["/U"] = "UseItem"

-- 赠送茉莉礼物
gift_order = "赠送茉莉"
function GiveGift(msg)
    local Gift_list = ReadItem()
    local num, item, flag1, flag2 = "", "", false, false
    local favor_ori, affinity = GetUserConf("favorConf", msg.fromQQ, {"好感度", "affinity"}, {0, 0})
    num, item = string.match(msg.fromMsg, "[%s]*(%d*)[%s]*(.+)", #gift_order + 1)
    if (num == "" or num == nil) then
        num = 1
    end
    num = num * 1
    if (item == "" or item == nil) then
        return "『✖参数不足』诶诶诶？{nick}这是要送给茉莉什么呀？是...？惊喜吗！"
    end
    -- 合理性判断
    flag1, flag2, item = UseCheck(msg, num * 1, Gift_list, item)
    if (not flag1) then
        return "『✖Error』嗯嗯嗯？原来这世上还存在这种东西的吗×"
    end
    if (not flag2) then
        return "『✖余量不足』好像该物品的剩余数量不足哦"
    end
    -- 检验是否是礼物
    if (Gift_list[item] == false) then
        return "『✖Error』这可不能送给茉莉哦~（小声提示）"
    end

    -- 处理特殊道具
    local reply = SpecialGift(msg, item, num, Gift_list, favor_ori, affinity)
    if (reply ~= nil) then
        return reply
    end
    -- 固定属性
    local favor_now
    if (Gift_list[item].favor ~= nil) then
        favor_now = favor_ori + num * ModifyFavorChangeGift(msg, favor_ori, Gift_list[item].favor, affinity)
        CheckFavor(msg.fromQQ, favor_ori, favor_now, affinity)
    end
    if (Gift_list[item].affinity ~= nil) then
        SetUserConf("favorConf", msg.fromQQ, "affinity", num * affinity + Gift_list[item].affinity)
    end

    -- 持续性道具处理
    LastingItem(msg, item)

    SetUserConf("itemConf", msg.fromQQ, item, GetUserConf("itemConf", msg.fromQQ, item, 0) - num)
    return Gift_list[item].reply
end
msg_order[gift_order] = "GiveGift"

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
    sendMsg(content, 0, 3032902237)
    sendMsg(content, 0, 2677409596)
    return "已经成功将请求发送至管理员~请耐心等待答复哦~\n为了能正常接收提示消息，请添加茉莉为好友w"
end
msg_order[reply_order] = "CustomizeReply"

-- 完成reply定制
finish_reply_order = "完成定制reply"
function FinishtCustomizedReply(msg)
    if (msg.fromQQ~="3032902237" and msg.fromQQ~="2677409596") then
        return "『✖权限不足』只有管理员才可确认定制reply完成"
    end
    local QQ =string.match(msg.fromMsg,"[%s]*(%d+)",#finish_reply_order+1)
    if (QQ==nil or QQ =="") then
        return "『✖参数不足』请输入确认完成reply的目标QQ"
    end
    local content = "【系统邮件】您的定制reply已经完成，如有问题请通过“.send [消息内容]”进行反馈哦~"
    SetUserConf("itemConf",QQ,"定制reply",GetUserConf("itemConf",QQ,"定制reply",0)-1)
    sendMsg(content,0,QQ)
    return "已确认完成该reply定制"
end
msg_order[finish_reply_order]="FinishtCustomizedReply"

-- 道具使用合理性判断
function UseCheck(msg, num, table, item)
    local flag1 = false
    -- 判断道具是否存在
    for k, _ in pairs(table) do
        if (string.find(k, item) ~= nil) then
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
        if (string.find(item, "梦的开始") ~= nil) then
            SetUserConf("storyConf", msg.fromQQ, {"entryStoryCheck", "isStory1Unlocked"}, {-1, 1})
            return "这把钥匙似乎和眼前的光芒产生了某种共鸣，倏忽间，光芒如同被某种强大的引力吸引般瞬间汇聚于钥匙上后逐渐稳定了下来...\f" .. "系统：注意，剧情模式第一章已经解锁！"
        else
            return "你小心翼翼地将它向那团光球接近，但就要在你触及之时，一股强大的斥力将你远远弹开了..."
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
                SetUserConf("adjustConf", msg.fromQQ, "好感度", favor_now)
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
                SetUserConf("adjustConf", msg.fromQQ, "好感度", favor_now)
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
                SetUserConf("adjustConf", msg.fromQQ, "好感度", favor_now)
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
        sendMsg("注意，该道具具有随机效果，一次只能赠送一个哦", msg.fromGroup, msg.fromQQ)
        return 1
    end
    return num
end
-- 持续性道具
function LastingItem(msg, item)
    -- 降低好感流逝类
    if (item == "推理小说") then
        -- 每天第一次交互增加好感类
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
        -- 每天第一几次交互增加亲和类
        -- ! 效果不会叠加,用os.time()秒级存储到期时间，更新为最新时间
        -- ! 打上标记，用做发送提醒的标记
        SetUserConf(
            "adjustConf",
            msg.fromQQ,
            {"addFavorDDL_Cookie", "addFavorDDLFlag_Cookie"},
            {os.time() + 3 * 24 * 60 * 60, 0}
        )
    elseif (item == "寿司") then
        -- 每天交互均增加好感类
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

    -- 判断道具是否存在
    for k, _ in pairs(Item) do
        if (string.find(k, item) ~= nil) then
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

    sendMsg("系统：正在检索..." .. ranint(20, 50) .. "%..." .. ranint(51, 80) .. "%...", msg.fromGroup, msg.fromQQ)
    sleepTime(1000)
    return "您目前的『" .. item .. "』数量为" .. string.format("%0.f", res) .. "\n(" .. Item[item].des .. ")"
end
msg_order[check_order] = "SearchItem"

-- 道具图鉴
function HandBook()
    local Item = ReadItem()
    local res = {}
    for k, _ in pairs(Item) do
        if (Item[k].cohesion == nil) then
            if (res[0] == nil) then
                res[0] = ""
            end
            res[0] = res[0] .. k .. "\n"
        else
            if (res[Item[k].cohesion] == nil) then
                res[Item[k].cohesion] = ""
            end
            res[Item[k].cohesion] = res[Item[k].cohesion] .. k .. Item[k].class .. "\n"
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
