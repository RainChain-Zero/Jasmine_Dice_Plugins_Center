function StoryFour(msg)
    local mainIndex, option, choice, choiceIndex =
        GetUserConf("storyConf", msg.fromQQ, {"mainIndex", "option", "choice", "choiceIndex"}, {1, 0, 0, 1})
    local content = "系统：出现未知错误，请报告系统管理员"
    if option == 0 then
        content = Story4[mainIndex]
        if mainIndex == 24 then
            SetUserConf("storyConf", msg.fromQQ, "option", 1)
        elseif mainIndex == 36 then
            Init(msg)
            content = content .. "{FormFeed}第四章『众生相』END."
            -- 第一次阅读才加好感
            if GetUserConf("storyConf", msg.fromQQ, "isStory4Read", 0) == 0 then
                content = content .. "好感变化：+100"
                SetUserConf("favorConf", msg.fromQQ, "好感度", GetUserConf("favorConf", msg.fromQQ, "好感度", 0) + 100)
            end
            SetUserConf("storyConf", msg.fromQQ, "isStory4Read", 1)
        end
        SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex + 1)
    elseif option == 1 then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        SetUserConf("storyConf", msg.fromQQ, "nextOption", 2)
        if choice == 1 then
            content = Story4[25][choiceIndex]
            choiceIndex = choiceIndex + 1
            if choiceIndex > 8 then
                OptionNormalInit(msg, 27)
            else
                SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
            end
        elseif choice == 2 then
            content = Story4[26][choiceIndex]
            choiceIndex = choiceIndex + 1
            if choiceIndex > 9 then
                OptionNormalInit(msg, 27)
            else
                SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
            end
        end
    end
    return content
end

function StoryFourChoose(msg, res)
    if res > 2 then
        return "您必须输入一个有效的选项数字哦~"
    end
    SetUserConf("storyConf", msg.fromQQ, "choice", res)
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipStory4(msg)
    local nextOption, isStory4Read = GetUserConf("storyConf", msg.fromQQ, {"nextOption", "isStory4Read"}, {1, 0})
    if isStory4Read == 0 then
        return "初次阅读可不支持跳过哦？"
    end
    local mainIndex = {[1] = 24, [2] = 36}
    SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex[nextOption])
end
