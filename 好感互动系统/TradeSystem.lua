---@diagnostic disable: lowercase-global
--[[
    @author 慕北_Innocent(RainChain)
    @version 1.3(Beta)
    @Create 2021/11/21 0:21
    @Last Modified 2022/03/31 23:36
    ]] msg_order = {}

package.path = getDiceDir() .. "/plugin/ReplyAndDescription/?.lua"
require "itemDescription"
package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"
require "itemIO"
itemRequest = ""
itemReceive = ""
QQReceive = ""
itemReceiveNum = ""
itemRequestNum = ""
-- 交易系统
-- //! 注意！同一用户只能有一次进行的交易，如果多次进行，只保留最后一次请求，之前的请求视作无效
trade_order = "交易"
function Trade(msg)
    local content = ""
    -- //? 首先判断是不是被交易方的回复指令
    if
        (string.find(msg.fromMsg, "同意") == nil and string.find(msg.fromMsg, "接受") == nil and
            string.find(msg.fromMsg, "拒绝") == nil)
     then
        -- //? 判断被请求方是否在同一个群中
        local isInGroup = (string.find(msg.fromMsg, "%[CQ:at,qq=") ~= nil)
        if (isInGroup == true) then
            isInGroup = 1
        else
            isInGroup = 0
            -- ! 禁止跨群交易（防止主动发起临时对话）
            return ""
        end
        -- 正则检测并选出参数
        -- //todo 注意输入合法性的判断条件
        QQReceive, itemRequestNum, itemRequest, itemReceiveNum, itemReceive =
            string.match(
            msg.fromMsg,
            "^[%s]*[%[CQ:at,qq=]*(%d*)[%]]*[%s]*[T,t]*[%s]*(%d*)[%s]*(%S*)[%s]*[F,f]*[%s]*(%d*)[%s]*(%S*)$",
            #trade_order + 1
        )
        if
            ((QQReceive == nil or QQReceive == "") or (itemRequestNum == nil or itemRequestNum == "") or
                (itemRequest == nil or itemRequest == "") or
                (itemReceiveNum == nil or itemReceiveNum == "") or
                string.find(msg.fromMsg, "@") ~= nil)
         then
            return "系统：检测到您的参数输入有误哦~"
        end
        if (msg.fromQQ == QQReceive) then
            return "系统：您无法和自己交易哦~"
        end
        -- ? 输入的道具是否存在
        local flag1, flag2 = Check()
        if (not flag1 or not flag2) then
            return "系统：检测到您输入了数据库中不存在的道具呢"
        end
        -- ! 禁止好感交易
        if (string.find(itemRequest, "好感") ~= nil or string.find(itemReceive, "好感") ~= nil) then
            return "重要数据不能进行交易哦？~"
        end
        local itemRequestNow = GetUserConf("itemConf", msg.fromQQ, itemRequest, 0)
        if (itemRequestNow - itemRequestNum * 1 < 0) then
            return "系统：您的" .. itemRequest .. "余量不足，无法发起交易"
        end
        -- 如果itemReceiveNum为0 为赠送的情况
        if (itemReceiveNum * 1 == 0) then
            if (isInGroup == 1) then
                content =
                    "[CQ:at,qq=" ..
                    QQReceive ..
                        "]\n" ..
                            "系统：您收到来自用户" ..
                                getUserConf(msg.fromQQ, "nick", "用户名获取失败") ..
                                    "的赠送——您得到了" .. itemRequestNum .. itemRequest
            else
                content =
                    "系统：您收到来自" ..
                    "用户编号为" ..
                        getUserConf(msg.fromQQ, "nick", "用户名获取失败") .. "的赠送——您得到了" .. itemRequestNum .. itemRequest
            end
            SetUserConf(
                "itemConf",
                msg.fromQQ,
                itemRequest,
                GetUserConf("itemConf", msg.fromQQ, itemRequest, 0) - itemRequestNum
            )
            SetUserConf(
                "itemConf",
                QQReceive,
                itemRequest,
                GetUserConf("itemConf", QQReceive, itemRequest, 0) + itemRequestNum
            )
            sendMsg(content, msg.fromGroup, QQReceive)
            return ""
        else
            if (itemReceive == nil) then
                return "系统：检测到您的参数输入有误哦~"
            end
        end
        -- //? 记录下被交易方是否在同一个群内，用于被交易方回复时判断不同的处理方式
        SetUserConf("tradeConf", QQReceive, "isInGroup", isInGroup)
        QQRequest = msg.fromQQ
        -- 交易双方在对方处留下记录作为交易进行的凭证
        SetUserConf("tradeConf", msg.fromQQ, "tradeReceive", QQReceive)
        SetUserConf("tradeConf", QQReceive, "tradeRequest", QQRequest)
        -- 双方各自记录交易物品
        SetUserConf("tradeConf", msg.fromQQ, {"itemRequestNum", "itemRequest"}, {itemRequestNum * 1, itemRequest})
        SetUserConf("tradeConf", QQReceive, {"itemReceiveNum", "itemReceive"}, {itemReceiveNum * 1, itemReceive})
        -- 茉莉发送请求给被交易方
        if (isInGroup == 1) then
            content =
                "[CQ:at,qq=" ..
                QQReceive ..
                    "]\n" ..
                        "系统：您收到来自用户编号为" ..
                            msg.fromQQ ..
                                "的交易请求——您将得到" ..
                                    itemRequestNum ..
                                        itemRequest ..
                                            "；同时失去" .. itemReceiveNum .. itemReceive .. "\n是否接受？（输入 “交易同意/拒绝”）"
            sendMsg(content, msg.fromGroup, QQReceive)
        else
            content =
                "系统：您收到来自用户编号为" ..
                msg.fromQQ ..
                    "的交易请求——您将得到" ..
                        itemRequestNum ..
                            itemRequest .. "；同时失去" .. itemReceiveNum .. itemReceive .. "\n是否接受？（输入 “交易 同意/拒绝”）"
            sendMsg(content, 0, QQReceive)
            sendMsg("系统：您的交易请求已发送，请等待对方回复，结果将通过私聊通知。若长时间未回复，可能是对方未加本机好友并且所在群禁止了临时会话", msg.fromGroup, msg.fromQQ)
        end
        return ""
    elseif
        (string.find(msg.fromMsg, "同意") ~= nil or string.find(msg.fromMsg, "接受") ~= nil or
            string.find(msg.fromMsg, "拒绝") ~= nil)
     then
        -- 记录获取交易发起方
        local reply = string.match(msg.fromMsg, "[%s]*(.*)", #trade_order + 1)
        local tradeRequest
        tradeRequest = GetUserConf("tradeConf", msg.fromQQ, "tradeRequest", "0")
        -- //! 先判断交易是否成立
        -- //? 第一种 被请求方是否存在未处理的请求
        if (tradeRequest == "0") then
            return "系统：您还未收到过交易请求哦~"
        end
        -- //? 第二种 交易发起方是否取消交易
        local tradeReceiveNow
        tradeReceiveNow = GetUserConf("tradeConf", tradeRequest, "tradeReceive", "0")
        if (tradeReceiveNow * 1 ~= msg.fromQQ * 1) then
            -- debug
            -- return tradeReceiveNow
            SetUserConf("tradeConf", msg.fromQQ, "tradeRequest", "0")
            return "系统：对方已取消交易，本次交易已关闭"
        end
        if (reply == "同意" or reply == "接受") then
            local itemReceive = GetUserConf("tradeConf", msg.fromQQ, "itemReceive", "nil")
            local itemReceiveNow, itemReceiveNum =
                GetUserConf("itemConf", msg.fromQQ, itemReceive, 0),
                GetUserConf("tradeConf", msg.fromQQ, "itemReceiveNum", 0)
            -- 余额不足，交易自动关闭
            if (itemReceiveNow - itemReceiveNum < 0) then
                if (GetUserConf("tradeConf", msg.fromQQ, "isInGroup", 0) == 1) then -- 判断是否在同一群内
                    -- 交易结束，交易凭证清除
                    TradeEnd(tradeRequest, msg.fromQQ)
                else
                    content = "系统：用户" .. "{nick}" .. "(" .. msg.fromQQ .. ")拒绝了您的交易请求"
                    sendMsg(content, 0, tradeRequest)
                    TradeEnd(tradeRequest, msg.fromQQ)
                end
                return "系统：您的" .. itemReceive .. "余量不足,交易已关闭"
            end

            -- 物品数量变更
            SetUserConf("itemConf", msg.fromQQ, itemReceive, itemReceiveNow - itemReceiveNum)
            SetUserConf(
                "itemConf",
                tradeRequest,
                itemReceive,
                GetUserConf("itemConf", tradeRequest, itemReceive, 0) + itemReceiveNum
            )
            local itemRequest = GetUserConf("tradeConf", tradeRequest, "itemRequest", "nil")
            local itemRequestNum, itemRequestNow =
                GetUserConf("tradeConf", tradeRequest, "itemRequestNum", 0),
                GetUserConf("itemConf", tradeRequest, itemRequest, 0)
            SetUserConf(
                "itemConf",
                msg.fromQQ,
                itemRequest,
                GetUserConf("itemConf", msg.fromQQ, itemRequest, 0) + itemRequestNum
            )
            SetUserConf("itemConf", tradeRequest, itemRequest, itemRequestNow - itemRequestNum)

            -- 茉莉发送交易结束通知
            if (GetUserConf("tradeConf", msg.fromQQ, "isInGroup", 0) == 1) then -- 判断是否在同一群内
                -- 交易结束，交易凭证清除
                TradeEnd(tradeRequest, msg.fromQQ)
            else
                content = "系统：用户" .. "{nick}" .. "(" .. msg.fromQQ .. ")已同意您的交易请求"
                sendMsg(content, 0, tradeRequest)
                -- 交易结束，交易凭证清除
                TradeEnd(tradeRequest, msg.fromQQ)
            end
            return "系统：您同意了该交易，交易已成立"
        else
            if (GetUserConf("tradeConf", msg.fromQQ, "isInGroup", 0) == 1) then -- 判断是否在同一群内
                -- 交易结束，交易凭证清除
                TradeEnd(tradeRequest, msg.fromQQ)
            else
                content = "系统：用户" .. "{nick}" .. "(" .. msg.fromQQ .. ")拒绝了您的交易请求"
                sendMsg(content, 0, tradeRequest)
                -- 交易结束，交易凭证清除
                TradeEnd(tradeRequest, msg.fromQQ)
            end
            return "系统：您拒绝了该交易，交易已关闭"
        end
    end
end
msg_order[trade_order] = "Trade"

function TradeEnd(q1, q2)
    SetUserConf("tradeConf", q1, "tradeReceive", "0")
    SetUserConf("tradeConf", q2, "tradeRequest", "0")
end

-- 管理员发送奖励
admin_order_gift = "奖励"
function adminGift(msg)
    if (msg.fromQQ ~= "3032902237" and msg.fromQQ ~= "2677409596") then
        return ""
    end
    -- 目标 赠送道具数量 赠送道具 附加信息
    local QQ, num, item, message =
        string.match(msg.fromMsg, "[%s]*(%d*)[%s]*(%d*)[%s]*(%S*)[%s]*(.*)", #admin_order_gift + 1)
    if (QQ == nil or QQ == "" or num == nil or item == nil or message == nil) then
        return "参数输入有误！"
    end
    SetUserConf("itemConf", QQ, item, GetUserConf("itemConf", QQ * 1, item, 0) + num)
    -- 发送消息提醒对方
    -- ! 注意 一定要在对方是好友的前提下使用！
    local content = "系统邮件：" .. message .. "\n已接收附件：" .. item .. "x" .. string.format("%.0f", num) .. ",通过指令“查询 道具名”确认"
    sendMsg(content, 0, QQ)
    return "权限确认：已成功将奖励送至目标"
end
msg_order[admin_order_gift] = "adminGift"

-- 判断输入的道具是否合法
function Check()
    local flag1, flag2 = false, false
    local Item = ReadItem()
    for k, _ in pairs(Item) do
        if (string.find(k, itemRequest) ~= nil) then
            flag1 = true
            itemRequest = k
        end
        if (string.find(k, itemReceive) ~= nil) then
            flag2 = true
            itemReceive = k
        end
        if (flag1 and flag2) then
            return true, true
        end
    end
    return flag1, flag2
end
