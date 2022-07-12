function StoryThree(msg)
    local MainIndex, Option, Choice, ChoiceIndex =
        GetUserConf("storyConf", msg.fromQQ, {"MainIndex", "Option", "Choice", "ChoiceIndex"}, {1, 0, 0, 1})
    local content = "系统：出现未知错误，请报告系统管理员"
    if (Option == 0) then
        content = Story3[MainIndex]
        if (MainIndex == 12) then
            SetUserConf("storyConf", msg.fromQQ, "Option", 1)
            return content
        elseif MainIndex == 23 then
            Init(msg)
            SetUserConf("storyConf", msg.fromQQ, "isStory3Read", 1)
            return content
        end
        SetUserConf("storyConf", msg.fromQQ, "MainIndex", MainIndex + 1)
        return content
    elseif Option == 1 then
        if (Choice == 0) then
            return "请选择其中一个选项以推进哦~"
        elseif Choice == 1 then
            OptionNormalInit(msg, 16)
            return Story3[13]
        elseif Choice == 2 then
            OptionNormalInit(msg, 16)
            return Story3[14]
        elseif Choice == 3 then
            OptionNormalInit(msg, 16)
            return Story3[15]
        end
    end
end

function StoryThreeChoose(msg, res)
    SetUserConf("storyConf", msg.fromQQ, {"Choice", "story2Choice", "NextOption"}, {res * 1, res * 1, -1})
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipStory3(msg)
    local NextOption, isStory3Read = GetUserConf("storyConf", msg.fromQQ, {"NextOption", "isStory3Read"}, {1, 0})
    if isStory3Read == 0 then
        return "初次阅读可不允许跳过哦？"
    end
    if NextOption == 1 then
        SetUserConf("storyConf", msg.fromQQ, "Option", 1)
        return Story3[12]
    elseif NextOption == -1 then
        Init(msg)
        return Story3[23]
    end
end
