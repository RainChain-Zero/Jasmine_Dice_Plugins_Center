msg_order = {}
msg_order["/抽奖"] = "draw_lottery"

package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "itemIO"
require "IO"

function draw_lottery(msg)
    local num, name, message = string.match(msg.fromMsg, "/抽奖[%s]*(%d+)[%s]*(%S*)[%s]*(.*)")
    if not num then
        return "请输入正确的抽奖命令哦~"
    end
    num = tonumber(num)
    if num < 1 then
        return "放入物品数量不能小于1哦~"
    end
    if not name or name == "" or name == "FL" then
        name = "fl"
    end
    local item = ReadItem()
    if not item[name] or (item[name].gift == false and name ~= "fl") then
        return "不可以把这个东西放入奖池中哦~"
    end
    local fl, item_request_num = GetUserConf("itemConf", msg.fromQQ, {"fl", name}, {0, 0})
    if fl < 6 or item_request_num < num then
        return "你的" .. name .. "数量不足哦~"
    elseif name == "fl" and fl < 6 + num then
        return "你的fl数量不足哦~"
    end
    local item_request_price = tonumber(string.match(item[name].price or "1", "%d+")) * num
    if item_request_price < 30 then
        return "不可以放入总价值少于30FL的物品哦~"
    end
    local request_body = {qq = tostring(msg.fromQQ), num = num, name = name, price = item_request_price, msg = message}
    -- 调用api抽奖
    local res, resp = http.post(url .. "drawLottery", Json.encode(request_body), "application/json;charset=utf-8")
    if not res then
        return "网络异常"
    end
    resp = Json.decode(resp)
    if not resp.succ then
        return resp.err_msg
    end
    -- 扣除物品
    if name == "fl" then
        fl = fl - 6 - num
    else
        fl, item_request_num = fl - 6, item_request_num - num
    end
    -- 抽取到的物品
    local qq_get, item_get_num, item_get, price_get, avg, message_get =
        resp.data.qq,
        resp.data.num,
        resp.data.name,
        resp.data.price,
        resp.data.avg,
        resp.data.msg
    -- 计算x和y
    local x = math.floor(item_request_price / avg * 100 + 0.5) / 100
    local y = 0
    if x < 0.8 or x > 1.2 then
        y = math.abs(x - 1)
    end
    -- 额外变动的fl数
    local m = y * price_get
    if x < 0.8 then
        -- 不足以支付惩罚将没收抽到的物品
        if fl - m < 0 then
            item_get_num = 0
        else
            fl = fl - m
            m = m * -1
        end
    elseif x > 1.2 then
        fl = fl + m
    end
    local reply = "你满怀激动地拆开了礼盒，里面有【" .. item_get_num .. "】个" .. item_get
    if item_get_num > 0 then
        reply = reply .. "\n总价值【" .. price_get .. "】fl"
    else
        reply = reply .. "\n总价值【0】fl"
    end
    -- 分类写入用户物品变化
    local item_num_now
    if name == "fl" and item_get == "fl" then
        fl = fl + item_get_num
        SetUserConf("itemConf", msg.fromQQ, "fl", fl)
    elseif name == "fl" and item_get ~= "fl" then
        item_num_now = GetUserConf("itemConf", msg.fromQQ, item_get, 0) + item_get_num
        SetUserConf("itemConf", msg.fromQQ, {"fl", item_get}, {fl, item_num_now})
    elseif name ~= "fl" and item_get == "fl" then
        fl = fl + item_get_num
        SetUserConf("itemConf", msg.fromQQ, {"fl", name}, {fl, item_request_num})
    else
        if name == item_get then
            item_request_num = item_request_num + item_get_num
            SetUserConf("itemConf", msg.fromQQ, {"fl", name}, {fl, item_request_num})
        else
            item_num_now = GetUserConf("itemConf", msg.fromQQ, item_get, 0) + item_get_num
            SetUserConf("itemConf", msg.fromQQ, {"fl", name, item_get}, {fl, item_request_num, item_num_now})
        end
    end
    reply = reply .. "，额外变动了【" .. m .. "】FL"
    if message_get ~= nil and message_get ~= "" then
        reply =
            reply ..
            "\n里面还发现了来自【" .. getUserConf(qq_get, "name", "用户") .. "(" .. qq_get .. ")" .. "】的留言：" .. message_get
    end
    return reply
end
