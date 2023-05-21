package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"

msg_order = {}

work_order = "/开始"
function Work(msg)
    --! 灵音、峎皬eh定制reply /开始xx 6/9视作打工
    if
        (msg.fromQQ ~= "2595928998" and msg.fromQQ ~= "2043789473" and msg.fromQQ ~= "2822611983") and
            msg.fromMsg:find("/开始打工") ~= 1
     then
        return ""
    end
    if (GetUserConf("storyConf", msg.fromQQ, "story2Choice", 0) == 0) then
        return "『✖条件未满足』您首先需要通过剧情第二章『难以言明的选择 』"
    end
    if (JudgeWorking(msg)) then
        return "『✖并发限制』你同一时间只能有一项正在进行的打工哦~"
    end
    -- 打工会使八音盒道具失效
    local musicBox = getUserConf(msg.fromQQ, "musicBox", {})
    if musicBox["enable"] then
        setUserConf(msg.fromQQ, "musicBox", {["enable"] = false, ["cd"] = musicBox["cd"]})
    end
    local time = string.match(msg.fromMsg, "[%s]*(%d+)", #work_order + 1)
    local work = {
        ["working"] = true
    }
    if (time == nil or time == "") then
        return "『✖参数不足』请输入打工时间,6或9（单位：小时）\n示例：“/开始打工 6”"
    end
    time = time * 1
    if (time ~= 6 and time ~= 9) then
        return "『✖参数错误』打工时间当前仅支持6或9小时哦~”"
    end
    if (time == 6) then
        work["profit"] = 50
    else
        work["profit"] = 100
    end
    time = os.time() + math.modf(time * 60 * 60 * WorkTime_Item(msg))
    work["ddl"] = time

    SetUserConf("favorConf", msg.fromQQ, "work", work)
    return "你和茉莉走进刚开门的咖啡馆，跟常青打了个招呼，就和茉莉换上工作服，开始上班。\n下班时间：" .. os.date("%Y.%m.%d %H:%M:%S", time)
end
msg_order[work_order] = "Work"

function WorkTime_Item(msg)
    local change = 0
    if (GetUserConf("itemConf", msg.fromQQ, "未言的期待", 0) == 1) then
        change = 0.15
    end
    return 1 - change
end

-- 打工状态判断
function JudgeWorking(msg)
    local work = GetUserConf("favorConf", msg.fromQQ, "work", {["working"] = false})
    if (work["working"] == true) then
        -- 未进入打工状态
        -- 已经结束了打工
        if (os.time() > work["ddl"]) then
            -- 处于工作状态
            SetUserConf("itemConf", msg.fromQQ, "fl", GetUserConf("itemConf", msg.fromQQ, "fl", 0) + work["profit"])
            work["working"] = false
            SetUserConf("favorConf", msg.fromQQ, "work", work)
            sendMsg(
                "[CQ:at,qq=" .. msg.fromQQ .. "]『✔提示』打工已经完成！\n夜渐渐深了，你伸了个懒腰，叫上茉莉准备下班\n收益：" .. work["profit"] .. "fl",
                msg.gid or 0,
                msg.fromQQ
            )
            return false
        else
            return true
        end
    else
        return false
    end
end
