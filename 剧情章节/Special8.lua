function SpecialEight(msg)
    local mainIndex, isSpecial8Read = GetUserConf("storyConf", msg.fromQQ, {"mainIndex", "isSpecial8Read"}, {1, 0})
    local content = "系统：剧情出现未知错误，请报告系统管理员"
    content = Special8[mainIndex]
    if mainIndex == #Special8 then
        content = content .. "{FormFeed}{FormFeed}「海边旅行」Fin."
        if isSpecial8Read == 0 then
            content = content .. "\n提示：好感变化：+200"
            SetUserConf("favorConf", msg.fromQQ, "好感度", GetUserConf("favorConf", msg.fromQQ, "好感度", 0) + 200)
            SetUserConf("storyConf", msg.fromQQ, "isSpecial8Read", 1)
        end
        Init(msg)
    end
    SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex + 1)
    return content
end
