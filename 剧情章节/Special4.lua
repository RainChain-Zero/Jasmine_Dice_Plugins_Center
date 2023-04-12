function SpecialFour(msg)
    local mainIndex, isSpecial4Read = GetUserConf("storyConf", msg.fromQQ, {"mainIndex", "isSpecial4Read"}, {1, 0})
    local content = "系统：剧情出现未知错误，请报告系统管理员"
    content = Special4[mainIndex]
    if mainIndex == 42 then
        content = content .. "{FormFeed}『星星点灯』Fin."
        if isSpecial4Read == 0 then
            content = content .. "\n提示：您得到了道具『星幕投影灯』x1；好感变化：+100"
            SetUserConf("itemConf", msg.fromQQ, "星幕投影灯", 1)
            SetUserConf("favorConf", msg.fromQQ, "好感度", GetUserConf("favorConf", msg.fromQQ, "好感度", 0) + 100)
            SetUserConf("storyConf", msg.fromQQ, "isSpecial4Read", 1)
        end
        Init(msg)
    end
    SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex + 1)
    return content
end
