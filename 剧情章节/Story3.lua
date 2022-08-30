function StoryThree(msg)
    local mainIndex, option, choice, choiceIndex =
        GetUserConf("storyConf", msg.fromQQ, {"mainIndex", "option", "choice", "choiceIndex"}, {1, 0, 0, 1})
    local content = "系统：出现未知错误，请报告系统管理员"
    if (option == 0) then
        content = Story3[mainIndex]
        if (mainIndex == 12) then
            SetUserConf("storyConf", msg.fromQQ, "option", 1)
            return content
        elseif mainIndex == 23 then
            Init(msg)
            SetUserConf("storyConf", msg.fromQQ, "isStory3Read", 1)
            return content
        end
        SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex + 1)
        return content
    elseif option == 1 then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        elseif choice == 1 then
            OptionNormalInit(msg, 16)
            return Story3[13]
        elseif choice == 2 then
            OptionNormalInit(msg, 16)
            return Story3[14]
        elseif choice == 3 then
            OptionNormalInit(msg, 16)
            return Story3[15]
        end
    end
end

function StoryThreeChoose(msg, res)
    SetUserConf("storyConf", msg.fromQQ, {"choice", "story2Choice", "nextOption"}, {res * 1, res * 1, -1})
    local isStory3Read = GetUserConf("storyConf", msg.fromQQ, "isStory3Read", 0)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    -- 选择2 初次阅读增加100好感
    if res == 2 and isStory3Read == 0 then
        SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 100)
    end
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipStory3(msg)
    local nextOption, isStory3Read = GetUserConf("storyConf", msg.fromQQ, {"nextOption", "isStory3Read"}, {1, 0})
    if isStory3Read == 0 then
        return "初次阅读可不允许跳过哦？"
    end
    if nextOption == 1 then
        SetUserConf("storyConf", msg.fromQQ, "option", 1)
        return Story3[12]
    elseif nextOption == -1 then
        Init(msg)
        return Story3[23]
    end
end
