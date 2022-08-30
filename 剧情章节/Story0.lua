--[[
    @author 慕北_Innocent(RainChain)
    @version 1.1
    @Created 2021/12/13 12:07
    @Last Modified 2022/03/31 23:36
    ]] -- 序章
function StoryZero(msg)
    local mainIndex, option, choice, choiceIndex, ChoiceSelected =
        GetUserConf(
        "storyConf",
        msg.fromQQ,
        {"mainIndex", "option", "choice", "choiceIndex", "choiceSelected0"},
        {1, 0, 0, 1, 0}
    )
    local content
    -- 判断是否进入分支
    if (option == 0) then
        -- 选项1
        content = Story0[mainIndex]
        if (mainIndex == 3) then
            SetUserConf("storyConf", msg.fromQQ, "option", 1)
        elseif (mainIndex == 7) then
            SetUserConf("storyConf", msg.fromQQ, "option", 2)
        end
        if (mainIndex == 7) then
            content = Story0[7][1] -- 初发选项
        end
        mainIndex = mainIndex + 1
        SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex)
        return content
    elseif (option == 1) then
        -- 未选择
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        -- 记录下一个跳转选项
        SetUserConf("storyConf", msg.fromQQ, "nextOption", 2)

        if (choice == 1) then
            mainIndex = 4
            content = Story0[mainIndex]
            mainIndex = 7
            SetUserConf("storyConf", msg.fromQQ, {"mainIndex", "option", "choice"}, {mainIndex, 0, 0})
            return content
        elseif (choice == 2) then
            mainIndex = 5
            content = Story0[mainIndex][choiceIndex]
            choiceIndex = choiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
            if (choiceIndex > 2) then
                SetUserConf("storyConf", msg.fromQQ, {"mainIndex", "choiceIndex", "option", "choice"}, {7, 1, 0, 0})
            end
            return content
        elseif (choice == 3) then
            if (GetUserConf("storyConf", msg.fromQQ, "isStory0Read", 0) == 0) then
                local favor_ori = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
                local favor_now = favor_ori + 200
                CheckFavor(msg.fromQQ, favor_ori, favor_now, GetUserConf("favorConf", msg.fromQQ, "affinity", 0))
            end
            mainIndex = 6
            content = Story0[mainIndex][choiceIndex + 1]
            sendMsg(Story0[mainIndex][choiceIndex], 0, msg.fromQQ)
            choiceIndex = choiceIndex + 2
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
            if (choiceIndex > 4) then
                SetUserConf("storyConf", msg.fromQQ, {"mainIndex", "choiceIndex", "option", "choice"}, {7, 1, 0, 0})
            end
            sleepTime(2500)
            return content
        end
    elseif (option == 2) then
        -- 记录下一个跳转选项
        SetUserConf("storyConf", msg.fromQQ, "nextOption", -1)
        -- 未选择
        if (choice == 0) then
            if (mainIndex == 7) then
                local Choicen = GetUserConf("storyConf", msg.fromQQ, "choiceSelected0", 0)
                -- return choice
                if (Choicen == 1) then
                    return Story0[7][2]
                end
                if (Choicen == 3) then
                    return Story0[7][3]
                end
                if (Choicen == 4) then
                    return Story0[7][4]
                end
            end
            return "请选择其中一个选项以推进哦~"
        end

        if (choice == 1) then
            ChoiceSelected = ChoiceSelected + 1
            SetUserConf("storyConf", msg.fromQQ, "choiceSelected0", ChoiceSelected)
            content = Story0[8]
            SetUserConf("storyConf", msg.fromQQ, {"mainIndex", "choice"}, {7, 0})
            return content
        elseif (choice == 2) then
            content = Story0[9]
            Init(msg)
            if (GetUserConf("storyConf", msg.fromQQ, "isStory0Read", 0) == 0) then
                SetUserConf("storyConf", msg.fromQQ, "isStory0Read", 1)
                SetUserConf("itemConf", msg.fromQQ, "梦的开始", 1)
                sendMsg(content, 0, msg.fromQQ)
                sleepTime(2000)
                return "系统：您得到了道具『梦的开始』x1（一把象牙白的钥匙，晶莹剔透，不知道是用什么制作的，或许能开启什么）"
            end
            return content
        elseif (choice == 3) then
            ChoiceSelected = ChoiceSelected + 3
            SetUserConf("storyConf", msg.fromQQ, "choiceSelected0", ChoiceSelected)
            content = Story0[10]
            SetUserConf("storyConf", msg.fromQQ, {"mainIndex", "choice"}, {7, 0})
            return content
        end
    end
end

function StoryZeroChoose(msg, res)
    local option = GetUserConf("storyConf", msg.fromQQ, "option", 0)
    local ChoiceSelected = GetUserConf("storyConf", msg.fromQQ, "choiceSelected0", 0)
    if (option == 2) then
        if
            ((res * 1 == 1 and (ChoiceSelected == 1 or ChoiceSelected == 4)) or
                (res * 1 == 3 and (ChoiceSelected == 3 or ChoiceSelected == 4)))
         then
            return "这个选项目前处于不可选中状态哦~"
        end
    end
    SetUserConf("storyConf", msg.fromQQ, "choice", res * 1)
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipStory0(msg)
    local nextOption = GetUserConf("storyConf", msg.fromQQ, "nextOption", 1)
    local isStory0Read = GetUserConf("storyConf", msg.fromQQ, "isStory0Read", 0)
    if (isStory0Read == 0) then
        return "初次阅读可不支持跳过哦？"
    end
    if (nextOption == -1) then
        return "当前所处选项不允许跳转哦？~（选项限制/已经是最后一个选项）"
    end
    OptionNormalInit(msg, 1)
    local mainIndex = {[1] = 3, [2] = 7}
    SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex[nextOption])
end
