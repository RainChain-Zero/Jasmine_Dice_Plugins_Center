--[[
    @author 慕北_Innocent(RainChain)
    @version 1.6
    @Created 2021/12/13 09:19
    @Last Modified 2022/03/31 23:36
    ]] -- 元旦特典 2021.12.13
function SpecialZero(msg)
    local MainIndex, Option, Choice, ChoiceIndex =
        GetUserConf("storyConf", msg.fromQQ, {"MainIndex", "Option", "Choice", "ChoiceIndex"}, {1, 0, 0, 1})
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local content = "系统：元旦特典剧情出现未知错误，请报告系统管理员"
    if (Option == 0) then
        content = Special0[MainIndex]
        if (MainIndex == 3) then
            SetUserConf("storyConf", msg.fromQQ, "Option", 1)
        elseif (MainIndex == 14) then
            SetUserConf("storyConf", msg.fromQQ, "Option", 2)
        elseif (MainIndex == 21) then
            SetUserConf("storyConf", msg.fromQQ, "Option", 3)
        elseif (MainIndex == 24) then
            SetUserConf("storyConf", msg.fromQQ, "Option", 4)
        end
        MainIndex = MainIndex + 1
        SetUserConf("storyConf", msg.fromQQ, "MainIndex", MainIndex)
        return content
    elseif (Option == 1) then
        if (Choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        -- 记录下一个跳转选项
        SetUserConf("storyConf", msg.fromQQ, "NextOption", 2)

        if (Choice == 1) then
            MainIndex = 4
            content = Special0[MainIndex][ChoiceIndex]
            ChoiceIndex = ChoiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "ChoiceIndex", ChoiceIndex)
            if (ChoiceIndex > 4) then
                OptionNormalInit(msg, 7)
            end
        elseif (Choice == 2) then
            MainIndex = 5
            content = Special0[MainIndex][ChoiceIndex]
            ChoiceIndex = ChoiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "ChoiceIndex", ChoiceIndex)
            if (ChoiceIndex > 4) then
                OptionNormalInit(msg, 7)
            end
        elseif (Choice == 3) then
            MainIndex = 6
            content = Special0[MainIndex][ChoiceIndex]
            ChoiceIndex = ChoiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "ChoiceIndex", ChoiceIndex)
            if (ChoiceIndex > 3) then
                OptionNormalInit(msg, 7)
            end
        end
    elseif (Option == 2) then
        if (Choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        -- 记录下一个跳转选项
        SetUserConf("storyConf", msg.fromQQ, "NextOption", 3)

        if (Choice == 1) then
            if (favor < 3000) then
                return "您的好感度不足哦~为" .. favor
            end
            MainIndex = 15
            content = Special0[MainIndex][ChoiceIndex]
            ChoiceIndex = ChoiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "ChoiceIndex", ChoiceIndex)
            if (ChoiceIndex > 5) then
                OptionNormalInit(msg, 18)
            end
        elseif (Choice == 2) then
            if (favor < 2000) then
                return "您的好感度不足哦~为" .. favor
            end
            MainIndex = 16
            content = Special0[MainIndex][ChoiceIndex]
            ChoiceIndex = ChoiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "ChoiceIndex", ChoiceIndex)
            if (ChoiceIndex > 4) then
                OptionNormalInit(msg, 18)
            end
        elseif (Choice == 3) then
            -- 进入本选择则不可跳转
            SetUserConf("storyConf", msg.fromQQ, "NextOption", -1)

            MainIndex = 17
            content = Special0[MainIndex][ChoiceIndex]
            ChoiceIndex = ChoiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "ChoiceIndex", ChoiceIndex)
            -- ! 直接结束
            if (ChoiceIndex > 3) then
                SetUserConf("storyConf", msg.fromQQ, "isSpecial0Read", 1)
                Init(msg)
            end
        end
    elseif (Option == 3) then
        if (Choice == 0) then
            return "请选择其中一个选项以推进哦~"
        else
            -- 记录下一个跳转选项
            SetUserConf("storyConf", msg.fromQQ, {"NextOption", "Special0Option3"}, {4, Choice})
            OptionNormalInit(msg, 23)
            return Special0[22]
        end
    elseif (Option == 4) then
        if (Choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        -- 进入本选择则不可跳转
        SetUserConf("storyConf", msg.fromQQ, "NextOption", -1)

        if (Choice == 1) then
            MainIndex = 25
            if (ChoiceIndex == 2) then
                content = Special0[MainIndex][ChoiceIndex][GetUserConf("storyConf", msg.fromQQ, "Special0Option3", 1)]
            else
                content = Special0[MainIndex][ChoiceIndex]
            end
            ChoiceIndex = ChoiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "ChoiceIndex", ChoiceIndex)
            if (ChoiceIndex > 6) then
                -- todo 记录用户在给出卡片的前提下结束剧情
                SetUserConf("storyConf", msg.fromQQ, {"Special0Flag", "isSpecial0Read"}, {1, 1})
                Init(msg)
            end
        elseif (Choice == 2) then
            MainIndex = 26
            content = Special0[MainIndex][ChoiceIndex]
            ChoiceIndex = ChoiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "ChoiceIndex", ChoiceIndex)
            if (ChoiceIndex > 4) then
                SetUserConf("storyConf", msg.fromQQ, "isSpecial0Read", 1)
                Init(msg)
            end
        end
    end
    return content
end

function SpecialZeroChoose(msg, res)
    local Option = GetUserConf("storyConf", msg.fromQQ, "Option", 0)
    if (Option == 4 and res * 1 == 3) then
        return "您必须输入一个有效的选项数字哦~"
    end
    SetUserConf("storyConf", msg.fromQQ, "Choice", res * 1)
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipSpecial0(msg)
    local NextOption = GetUserConf("storyConf", msg.fromQQ, "NextOption", 1)
    if (NextOption == -1) then
        return "当前所处选项不允许跳转哦？~（选项限制/已经是最后一个选项）"
    end
    local isSpecial0Read = GetUserConf("storyConf", msg.fromQQ, "isSpecial0Read", 0)
    if (isSpecial0Read == 0) then
        return "初次阅读可不支持跳过哦？"
    end
    OptionNormalInit(msg, 1)
    local MAININDEX = {[1] = 3, [2] = 14, [3] = 21, [4] = 24}
    SetUserConf("storyConf", msg.fromQQ, "MainIndex", MAININDEX[NextOption])
end
