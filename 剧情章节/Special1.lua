function SpecialOne(msg)
    local MainIndex, Option, Choice, ChoiceIndex, isSpecial1Read =
        GetUserConf(
        "storyConf",
        msg.fromQQ,
        {"MainIndex", "Option", "Choice", "ChoiceIndex", "isSpecial1Read"},
        {1, 0, 0, 1, 0}
    )
    local content = "系统：七夕特典剧情出现未知错误，请报告系统管理员"
    if (Option == 0) then
        content = Special1[MainIndex]
        if MainIndex == 11 then
            SetUserConf("storyConf", msg.fromQQ, "Option", 1)
        elseif MainIndex == 15 then
            SetUserConf("storyConf", msg.fromQQ, "Option", 2)
        elseif MainIndex == 21 then
            Init(msg)
            if isSpecial1Read == 0 then
                local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
                GetUserConf("favorConf", msg.fromQQ, "好感度", favor + 100)
                content = content .. "{FormFeed}{FormFeed}当前好感变化:+100"
            end
            SetUserConf("storyConf", msg.fromQQ, "isSpecial1Read", 1)
            return content
        end
        MainIndex = MainIndex + 1
        SetUserConf("storyConf", msg.fromQQ, "MainIndex", MainIndex)
        return content
    elseif Option == 1 then
        if (Choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        SetUserConf("storyConf", msg.fromQQ, "NextOption", 2)
        if (Choice == 1) then
            MainIndex = 12
            content = Special1[MainIndex][ChoiceIndex]
            ChoiceIndex = ChoiceIndex + 1
            if (ChoiceIndex > 2) then
                OptionNormalInit(msg, 14)
                return content
            end
            SetUserConf("storyConf", msg.fromQQ, "ChoiceIndex", ChoiceIndex)
        elseif (Choice == 2) then
            MainIndex = 13
            content = Special1[MainIndex][ChoiceIndex]
            OptionNormalInit(msg, 14)
        end
        return content
    elseif (Option == 2) then
        if (Choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
        SetUserConf("storyConf", msg.fromQQ, "NextOption", 3)
        if (Choice == 1) then
            MainIndex = 16
            content = Special1[MainIndex][ChoiceIndex]
            ChoiceIndex = ChoiceIndex + 1
            OptionNormalInit(msg, 18)
            -- 该选项好感-20
            if isSpecial1Read == 0 then
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor - 20)
                content = content .. "{FormFeed}{FormFeed}当前好感变化：-20"
            end
        elseif (Choice == 2) then
            MainIndex = 17
            content = Special1[MainIndex][ChoiceIndex]
            ChoiceIndex = ChoiceIndex + 1
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
    SetUserConf("storyConf", msg.fromQQ, "Choice", res)
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipSpecial1(msg)
    local isSpecial1Read, NextOption = GetUserConf("storyConf", msg.fromQQ, {"isSpecial1Read", "NextOption"}, {0, 1})
    if (isSpecial1Read == 0) then
        return "初次阅读可不支持跳过哦？"
    end
    OptionNormalInit(msg, 1)
    local MAININDEX = {[1] = 11, [2] = 15, [3] = 21}
    SetUserConf("storyConf", msg.fromQQ, "MainIndex", MAININDEX[NextOption])
end
