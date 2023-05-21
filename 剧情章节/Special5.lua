function SpecialFive(msg)
    local mainIndex = GetUserConf("storyConf", msg.fromQQ, "mainIndex", 1)
    local content = "系统：剧情出现未知错误，请报告系统管理员"
    content = Special5[mainIndex]
    if mainIndex == 1 then
        build_music_card(msg.fromQQ, "163", 1365914380)
        sleepTime(1500)
    end
    if mainIndex <= 12 then
        content = "【你】\n" .. content
    elseif mainIndex <= 25 then
        content = "【茉莉】\n" .. content
    elseif mainIndex == 26 then
        content = content .. "{FormFeed}『夜』Fin."
        if GetUserConf("storyConf", msg.fromQQ, "isSpecial5Read", 0) == 0 then
            content = content .. "\n好感变化：+100\n新的reply已解锁：膝枕（茉莉膝枕）（注：此项交互好感要求较高）"
            SetUserConf("favorConf", msg.fromQQ, "好感度", GetUserConf("favorConf", msg.fromQQ, "好感度", 0) + 100)
            SetUserConf("storyConf", msg.fromQQ, "isSpecial5Read", 1)
        end
        Init(msg)
        return content
    end
    SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex + 1)
    return content
end
