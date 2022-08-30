--[[
    @author 慕北_Innocent(RainChain)
    @version 1.6
    @Created 2021/12/13 09:19
    @Last Modified 2022/03/31 23:36
    ]] -- 元旦特典 2021.12.13
function SpecialZero(msg)
    local mainIndex, option, choice, choiceIndex =
        GetUserConf("storyConf", msg.fromQQ, {"mainIndex", "option", "choice", "choiceIndex"}, {1, 0, 0, 1})
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local content = "系统：元旦特典剧情出现未知错误，请报告系统管理员"
    if (option == 0) then
        content = Special0[mainIndex]
        if (mainIndex == 3) then
            SetUserConf("storyConf", msg.fromQQ, "option", 1)
        elseif (mainIndex == 14) then
            SetUserConf("storyConf", msg.fromQQ, "option", 2)
        elseif (mainIndex == 21) then
            SetUserConf("storyConf", msg.fromQQ, "option", 3)
        elseif (mainIndex == 24) then
            SetUserConf("storyConf", msg.fromQQ, "option", 4)
        end
        mainIndex = mainIndex + 1
        SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex)
        return content
    elseif (option == 1) then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        -- 记录下一个跳转选项
        SetUserConf("storyConf", msg.fromQQ, "nextOption", 2)

        if (choice == 1) then
            mainIndex = 4
            content = Special0[mainIndex][choiceIndex]
            choiceIndex = choiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
            if (choiceIndex > 4) then
                OptionNormalInit(msg, 7)
            end
        elseif (choice == 2) then
            mainIndex = 5
            content = Special0[mainIndex][choiceIndex]
            choiceIndex = choiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
            if (choiceIndex > 4) then
                OptionNormalInit(msg, 7)
            end
        elseif (choice == 3) then
            mainIndex = 6
            content = Special0[mainIndex][choiceIndex]
            choiceIndex = choiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
            if (choiceIndex > 3) then
                OptionNormalInit(msg, 7)
            end
        end
    elseif (option == 2) then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        -- 记录下一个跳转选项
        SetUserConf("storyConf", msg.fromQQ, "nextOption", 3)

        if (choice == 1) then
            if (favor < 3000) then
                return "您的好感度不足哦~为" .. favor
            end
            mainIndex = 15
            content = Special0[mainIndex][choiceIndex]
            choiceIndex = choiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
            if (choiceIndex > 5) then
                OptionNormalInit(msg, 18)
            end
        elseif (choice == 2) then
            if (favor < 2000) then
                return "您的好感度不足哦~为" .. favor
            end
            mainIndex = 16
            content = Special0[mainIndex][choiceIndex]
            choiceIndex = choiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
            if (choiceIndex > 4) then
                OptionNormalInit(msg, 18)
            end
        elseif (choice == 3) then
            -- 进入本选择则不可跳转
            SetUserConf("storyConf", msg.fromQQ, "nextOption", -1)

            mainIndex = 17
            content = Special0[mainIndex][choiceIndex]
            choiceIndex = choiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
            -- ! 直接结束
            if (choiceIndex > 3) then
                SetUserConf("storyConf", msg.fromQQ, "isSpecial0Read", 1)
                Init(msg)
            end
        end
    elseif (option == 3) then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        else
            -- 记录下一个跳转选项
            SetUserConf("storyConf", msg.fromQQ, {"nextOption", "special0Option3"}, {4, choice})
            OptionNormalInit(msg, 23)
            return Special0[22]
        end
    elseif (option == 4) then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        -- 进入本选择则不可跳转
        SetUserConf("storyConf", msg.fromQQ, "nextOption", -1)

        if (choice == 1) then
            mainIndex = 25
            if (choiceIndex == 2) then
                content = Special0[mainIndex][choiceIndex][GetUserConf("storyConf", msg.fromQQ, "special0Option3", 1)]
            else
                content = Special0[mainIndex][choiceIndex]
            end
            choiceIndex = choiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
            if (choiceIndex > 6) then
                -- todo 记录用户在给出卡片的前提下结束剧情
                SetUserConf("storyConf", msg.fromQQ, {"special0Flag", "isSpecial0Read"}, {1, 1})
                Init(msg)
            end
        elseif (choice == 2) then
            mainIndex = 26
            content = Special0[mainIndex][choiceIndex]
            choiceIndex = choiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
            if (choiceIndex > 4) then
                SetUserConf("storyConf", msg.fromQQ, "isSpecial0Read", 1)
                Init(msg)
            end
        end
    end
    return content
end

function SpecialZeroChoose(msg, res)
    local option = GetUserConf("storyConf", msg.fromQQ, "option", 0)
    if (option == 4 and res * 1 == 3) then
        return "您必须输入一个有效的选项数字哦~"
    end
    SetUserConf("storyConf", msg.fromQQ, "choice", res * 1)
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipSpecial0(msg)
    local nextOption = GetUserConf("storyConf", msg.fromQQ, "nextOption", 1)
    if (nextOption == -1) then
        return "当前所处选项不允许跳转哦？~（选项限制/已经是最后一个选项）"
    end
    local isSpecial0Read = GetUserConf("storyConf", msg.fromQQ, "isSpecial0Read", 0)
    if (isSpecial0Read == 0) then
        return "初次阅读可不支持跳过哦？"
    end
    OptionNormalInit(msg, 1)
    local mainIndex = {[1] = 3, [2] = 14, [3] = 21, [4] = 24}
    SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex[nextOption])
end
