function SpecialOne(msg)
    local mainIndex, option, choice, choiceIndex, isSpecial1Read =
        GetUserConf(
        "storyConf",
        msg.fromQQ,
        {"mainIndex", "option", "choice", "choiceIndex", "isSpecial1Read"},
        {1, 0, 0, 1, 0}
    )
    local content = "系统：七夕特典剧情出现未知错误，请报告系统管理员"
    if (option == 0) then
        content = Special1[mainIndex]
        if mainIndex == 11 then
            SetUserConf("storyConf", msg.fromQQ, "option", 1)
        elseif mainIndex == 15 then
            SetUserConf("storyConf", msg.fromQQ, "option", 2)
        elseif mainIndex == 21 then
            Init(msg)
            if isSpecial1Read == 0 then
                local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 100)
                content = content .. "{FormFeed}{FormFeed}当前好感变化:+100"
            end
            SetUserConf("storyConf", msg.fromQQ, "isSpecial1Read", 1)
            return content
        end
        mainIndex = mainIndex + 1
        SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex)
        return content
    elseif option == 1 then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        SetUserConf("storyConf", msg.fromQQ, "nextOption", 2)
        if (choice == 1) then
            mainIndex = 12
            content = Special1[mainIndex][choiceIndex]
            choiceIndex = choiceIndex + 1
            if (choiceIndex > 2) then
                OptionNormalInit(msg, 14)
                return content
            end
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
        elseif (choice == 2) then
            mainIndex = 13
            content = Special1[mainIndex][choiceIndex]
            OptionNormalInit(msg, 14)
        end
        return content
    elseif (option == 2) then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
        SetUserConf("storyConf", msg.fromQQ, "nextOption", 3)
        if (choice == 1) then
            mainIndex = 16
            content = Special1[mainIndex][choiceIndex]
            choiceIndex = choiceIndex + 1
            OptionNormalInit(msg, 18)
            -- 该选项好感-20
            if isSpecial1Read == 0 then
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 20)
                content = content .. "{FormFeed}{FormFeed}当前好感变化：-20"
            end
        elseif (choice == 2) then
            mainIndex = 17
            content = Special1[mainIndex][choiceIndex]
            choiceIndex = choiceIndex + 1
            OptionNormalInit(msg, 18)
            -- 该选项好感+30
            if isSpecial1Read == 0 then
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 30)
                content = content .. "{FormFeed}{FormFeed}当前好感变化：+30"
            end
        end
        return content
    end
end

function SpecialOneChoose(msg, res)
    if res > 2 then
        return "您必须输入一个有效的选项数字哦~"
    end
    SetUserConf("storyConf", msg.fromQQ, "choice", res)
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipSpecial1(msg)
    local isSpecial1Read, nextOption = GetUserConf("storyConf", msg.fromQQ, {"isSpecial1Read", "nextOption"}, {0, 1})
    if (isSpecial1Read == 0) then
        return "初次阅读可不支持跳过哦？"
    end
    OptionNormalInit(msg, 1)
    local mainIndex = {[1] = 11, [2] = 15, [3] = 21}
    SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex[nextOption])
end
