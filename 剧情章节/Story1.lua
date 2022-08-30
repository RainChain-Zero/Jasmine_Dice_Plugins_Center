--[[
    @author 慕北_Innocent(RainChain)
    @version 1.0
    @Created 2022/01/19 11:11
    @Last Modified 2022/03/31 23:36
    ]] -- 第一章 夜未央
function StoryOne(msg)
    local mainIndex, option, choice, choiceIndex, actionRoundLeft =
        GetUserConf(
        "storyConf",
        msg.fromQQ,
        {"mainIndex", "option", "choice", "choiceIndex", "actionRoundLeft"},
        {1, 0, 0, 1, 4}
    )
    -- 记录给茉莉发送消息后返回的选项编号
    -- ! -1%10==9
    local OptionReturn = GetUserConf("storyConf", msg.fromQQ, "isStory1Option1Choice3", -1) % 10
    -- 剩余行动轮 初始为4
    local content = "系统：出现未知错误，请报告系统管理员"

    if (option == 0) then
        content = Story1[mainIndex]
        if (mainIndex == 4) then
            SetUserConf("storyConf", msg.fromQQ, "option", 1)
        elseif (mainIndex == 13) then
            SetUserConf("storyConf", msg.fromQQ, "option", 2)
            content = content .. "\f注意：当前剩余行动次数" .. string.format("%.0f", actionRoundLeft) .. "/4"
        elseif (mainIndex == 30) then
            -- ! 剧情结束
            Init(msg)
            -- ! 商店功能未解锁警告
            if (GetUserConf("storyConf", msg.fromQQ, "isShopUnlocked", 0) == 0) then
                content = content .. "\f系统消息：Warning：您在本章节仍有一项功能未解锁！"
            end
        end
        mainIndex = mainIndex + 1
        SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex)
        return content
    elseif (option == 1) then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        if (choice == 1) then
            mainIndex = 5
            content = Story1[mainIndex][choiceIndex]
            -- ! 准备跳转到选项1.1
            if (choiceIndex == 2) then
                -- Option记录为11
                SetUserConf("storyConf", msg.fromQQ, {"option", "choiceIndex", "choice"}, {11, 1, 0})
                if (GetUserConf("storyConf", msg.fromQQ, "isStory1Option1Choice3", -1) ~= -1) then
                    content = content .. "(不可选)"
                end
                return content
            end
            choiceIndex = choiceIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
            return content
        elseif (choice == 2) then
            return MessageSent(msg, OptionReturn)
        elseif (choice == 3) then
            return GoToMessage(msg, 10, choiceIndex)
        end
    elseif (option == 11) then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        if (choice == 1) then
            mainIndex = 6
            content = Story1[mainIndex][choiceIndex]
            -- ! 准备跳转到选项1.2
            if (choiceIndex == 4) then
                -- Option记录为12
                SetUserConf("storyConf", msg.fromQQ, {"option", "choiceIndex", "choice"}, {12, 1, 0})
                if (GetUserConf("storyConf", msg.fromQQ, "isStory1Option1Choice3", -1) ~= -1) then
                    content = content .. "(不可选)"
                end
                return content
            end
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 1)
            return content
        elseif (choice == 2) then
            return MessageSent(msg, OptionReturn)
        elseif (choice == 3) then
            return GoToMessage(msg, 11, choiceIndex)
        end
    elseif (option == 12) then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        if (choice == 1) then
            return MessageSent(msg, OptionReturn)
        elseif (choice == 2) then
            return GoToShop(msg)
        elseif (choice == 3) then
            return GoToMessage(msg, 12, choiceIndex)
        end
    elseif (option == 13) then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        if (choice == 1) then
            return ReturnLastOption(msg, 8, choiceIndex, 17, OptionReturn)
        elseif (choice == 2) then
            return ReturnLastOption(msg, 9, choiceIndex, 19, OptionReturn)
        elseif (choice == 3) then
            return ReturnLastOption(msg, 10, choiceIndex, 19, OptionReturn)
        end
    elseif (option == 2) then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        if (choice == 1) then
            return ActionRound_Room(msg, 14, choiceIndex, 3)
        elseif (choice == 2) then
            return ActionRound_Room(msg, 17, choiceIndex, 3)
        elseif (choice == 3) then
            return ActionRound_Room(msg, 20, choiceIndex, 4)
        end
    elseif (option == 21) then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        if (choice == 1) then
            return ActionRound_InnerRoom(msg, 15, choiceIndex, 3, option)
        elseif (choice == 2) then
            return ActionRound_InnerRoom(msg, 16, choiceIndex, 3, option)
        elseif (choice == 3) then
            -- 返回客厅，不消耗行动轮次数
            SetUserConf("storyConf", msg.fromQQ, {"option", "choiceIndex", "choice"}, {2, 1, 0})
            return "你又踱回了客厅，接下来要去哪看看呢？\f" .. Story1[13]
        end
    elseif (option == 22) then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        if (choice == 1) then
            return ActionRound_InnerRoom(msg, 18, choiceIndex, 3, option)
        elseif (choice == 2) then
            return ActionRound_InnerRoom(msg, 19, choiceIndex, 4, option)
        elseif (choice == 3) then
            -- 返回客厅，不消耗行动轮次数
            SetUserConf("storyConf", msg.fromQQ, {"option", "choiceIndex", "choice"}, {2, 1, 0})
            return "你又踱回了客厅，接下来要去哪看看呢？\f" .. Story1[13]
        end
    elseif (option == 23) then
        -- 进入商店的剧情
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        if (choice == 1) then
            return ActionRound_InnerRoom(msg, 21, choiceIndex, 5, option)
        elseif (choice == 2) then
            -- 返回客厅，不消耗行动轮次数
            SetUserConf("storyConf", msg.fromQQ, {"option", "choiceIndex", "choice"}, {2, 1, 0})
            return "你又踱回了客厅，接下来要去哪看看呢？\f" .. Story1[13]
        end
    elseif (option == 3) then
        mainIndex = 31
        -- ! 准备跳转回家
        if (choiceIndex == 8) then
            return MessageSent(msg, OptionReturn)
        end
        content = Story1[mainIndex][choiceIndex]
        if (choiceIndex == 6) then
            -- 第一次解锁商店
            if (GetUserConf("storyConf", msg.fromQQ, "isShopUnlocked", 0) == 0) then
                content = content .. "\f{FormFeed}{FormFeed}" .. "重要消息：『商店』已经解锁！输入指令“进入商店”来进入商品界面\f系统消息：您得到了500FL"
                SetUserConf("storyConf", msg.fromQQ, "isShopUnlocked", 10)
                SetUserConf("itemConf", msg.fromQQ, "fl", 500)
            end
        end
        if (choiceIndex == 7) then
            if (GetUserConf("storyConf", msg.fromQQ, "isShopUnlocked", 0) == 10) then
                return "提示：初次阅读，您必须先购买一件商品才能继续进行哦~"
            end
        end
        choiceIndex = choiceIndex + 1
        SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
        return content
    end
end

-- 判断回家时是否发送信息
function MessageSent(msg, OptionReturn)
    local content = "出现未知错误，请报告系统管理员！"
    -- 为9代表没有发送消息
    if (OptionReturn ~= 9) then
        -- 添加过渡句
        content = "你带着还不错的心情回到家中，茉莉此时似乎还没回来，不过稍等片刻，" .. Story1[22]
        OptionNormalInit(msg, 23)
        return content
    else
        content = Story1[11]
        OptionNormalInit(msg, 12)
        return content
    end
end

-- 发送信息的部分
function GoToMessage(msg, index, choiceIndex)
    local content = ""
    -- 记录发送信息
    SetUserConf("storyConf", msg.fromQQ, {"isMessageSent", "isStory1Option1Choice3"}, {1, index})
    mainIndex = 7
    content = Story1[mainIndex][choiceIndex]
    -- 实现消息延时发送
    if (choiceIndex == 2 or choiceIndex == 4) then
        content = content .. "{FormFeed}{FormFeed}{FormFeed}" .. Story1[mainIndex][choiceIndex + 1]
        SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 1)
        choiceIndex = choiceIndex + 1
    end
    -- ! 准备跳转到选项1.3
    if (choiceIndex == 6) then
        SetUserConf("storyConf", msg.fromQQ, {"option", "choiceIndex", "choice"}, {13, 1, 0})
        return content
    end
    SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 1)
    return content
end

-- 发送完消息后返回上一个选项
function ReturnLastOption(msg, mainIndex, choiceIndex, Border, OptionReturn)
    local content = ""
    if (choiceIndex == Border) then
        if (OptionReturn == 0) then
            -- 添加第三选项不可选中标记
            content = Story1[4] .. "(不可选)"
            SetUserConf("storyConf", msg.fromQQ, {"option", "choiceIndex", "choice"}, {1, 1, 0})
            return content
        elseif (OptionReturn == 1) then
            -- 添加第三选项不可选中标记
            content = Story1[5][2] .. "(不可选)"
            SetUserConf("storyConf", msg.fromQQ, {"option", "choiceIndex", "choice"}, {11, 1, 0})
            return content
        elseif (OptionReturn == 2) then
            -- 添加第三选项不可选中标记
            content = Story1[6][4] .. "(不可选)"
            SetUserConf("storyConf", msg.fromQQ, {"option", "choiceIndex", "choice"}, {12, 1, 0})
            return content
        end
    end
    content = Story1[mainIndex][choiceIndex]
    -- 实现延迟发送
    if (mainIndex == 8) then
        if (choiceIndex == 1) then
            content =
                content ..
                "{FormFeed}{FormFeed}" ..
                    Story1[mainIndex][choiceIndex + 1] ..
                        "{FormFeed}{FormFeed}{FormFeed}" .. Story1[mainIndex][choiceIndex + 2]
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 2)
            choiceIndex = choiceIndex + 2
        elseif (choiceIndex == 4) then
            content =
                content ..
                "{FormFeed}{FormFeed}{FormFeed}" ..
                    Story1[mainIndex][choiceIndex + 1] ..
                        "{FormFeed}{FormFeed}" ..
                            Story1[mainIndex][choiceIndex + 2] ..
                                "{FormFeed}{FormFeed}{FormFeed}" .. Story1[mainIndex][choiceIndex + 3]
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 3)
            choiceIndex = choiceIndex + 3
        elseif (choiceIndex == 8) then
            content =
                content ..
                "{FormFeed}{FormFeed}{FormFeed}" ..
                    Story1[mainIndex][choiceIndex + 1] .. "{FormFeed}{FormFeed}" .. Story1[mainIndex][choiceIndex + 2]
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 2)
            choiceIndex = choiceIndex + 2
        elseif (choiceIndex == 12) then
            content =
                content ..
                "{FormFeed}{FormFeed}{FormFeed}" ..
                    Story1[mainIndex][choiceIndex + 1] ..
                        "{FormFeed}{FormFeed}" ..
                            Story1[mainIndex][choiceIndex + 2] ..
                                "{FormFeed}{FormFeed}{FormFeed}" .. Story1[mainIndex][choiceIndex + 3]
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 3)
            choiceIndex = choiceIndex + 3
        end
    elseif (mainIndex == 9) then
        if (choiceIndex == 1) then
            content =
                content ..
                "{FormFeed}{FormFeed}" ..
                    Story1[mainIndex][choiceIndex + 1] ..
                        "{FormFeed}{FormFeed}{FormFeed}" .. Story1[mainIndex][choiceIndex + 2]
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 2)
            choiceIndex = choiceIndex + 2
        elseif
            (choiceIndex == 5 or choiceIndex == 7 or choiceIndex == 9 or choiceIndex == 11 or choiceIndex == 13 or
                choiceIndex == 15 or
                choiceIndex == 17)
         then
            content = content .. "{FormFeed}{FormFeed}{FormFeed}" .. Story1[mainIndex][choiceIndex + 1]
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 1)
            choiceIndex = choiceIndex + 1
        end
    elseif (mainIndex == 10) then
        if (choiceIndex == 1 or choiceIndex == 6 or choiceIndex == 8 or choiceIndex == 10 or choiceIndex == 13) then
            content = content .. "{FormFeed}{FormFeed}{FormFeed}" .. Story1[mainIndex][choiceIndex + 1]
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 1)
            choiceIndex = choiceIndex + 1
        elseif (choiceIndex == 3 or choiceIndex == 15) then
            content =
                content ..
                "{FormFeed}{FormFeed}" ..
                    Story1[mainIndex][choiceIndex + 1] ..
                        "{FormFeed}{FormFeed}{FormFeed}" .. Story1[mainIndex][choiceIndex + 2]
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 2)
            choiceIndex = choiceIndex + 2
        end
    end
    choiceIndex = choiceIndex + 1
    SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex)
    return content
end

-- 行动轮剩余次数判断
function JudgeActionRound(msg)
    local actionRoundLeft = GetUserConf("storyConf", msg.fromQQ, "actionRoundLeft", 4) - 1
    SetUserConf("storyConf", msg.fromQQ, "actionRoundLeft", actionRoundLeft)
    if (actionRoundLeft >= 1) then
        return true
    end
    return false
end

-- 行动轮-房间选择
function ActionRound_Room(msg, mainIndex, choiceIndex, Border)
    local content = Story1[mainIndex][choiceIndex]
    local option
    if (choiceIndex == Border) then
        -- 判定当前行动轮次数是否消耗完
        if (JudgeActionRound(msg)) then
            -- ! 准备跳转到选项2.x
            if (mainIndex == 14) then
                option = 21
            elseif (mainIndex == 17) then
                option = 22
            elseif (mainIndex == 20) then
                option = 23
            end
            SetUserConf("storyConf", msg.fromQQ, {"option", "choiceIndex", "choice"}, {option, 1, 0})
            return content ..
                "\f注意：当前剩余行动次数" ..
                    string.format("%.0f", GetUserConf("storyConf", msg.fromQQ, "actionRoundLeft", 4)) .. "/4"
        else
            -- 已经消耗完行动次数，不给出下一个选项
            OptionNormalInit(msg, 23)
            return Story1[22]
        end
    end
    SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 1)
    return content
end

-- 行动轮-房间内行动
function ActionRound_InnerRoom(msg, mainIndex, choiceIndex, Border, OptionNow)
    local content = Story1[mainIndex][choiceIndex]
    if (choiceIndex == Border) then
        -- 判定当前行动轮次数是否被消耗完
        if (JudgeActionRound(msg)) then
            -- ! 准备返回选项2.x
            SetUserConf("storyConf", msg.fromQQ, {"option", "choiceIndex", "choice"}, {OptionNow, 1, 0})
            return content ..
                "\f注意：当前剩余行动次数" ..
                    string.format("%.0f", GetUserConf("storyConf", msg.fromQQ, "actionRoundLeft", 4)) .. "/4"
        else
            -- 已经消耗完行动次数，不给出下一个选项
            OptionNormalInit(msg, 23)
            return Story1[22]
        end
    end
    SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 1)
    return content
end

-- 商店界面
function GoToShop(msg)
    SetUserConf("storyConf", msg.fromQQ, {"option", "choiceIndex"}, {3, 2})
    return Story1[31][1]
end
-- 选择
function StoryOneChoose(msg, res)
    local option = GetUserConf("storyConf", msg.fromQQ, "option", 0)
    if (option == 23 and res * 1 == 3) then
        return "请输入一个有效的选项数字哦~"
    end
    if (option == 1 or option == 11 or option == 12) then
        if (res * 1 == 3 and GetUserConf("storyConf", msg.fromQQ, "isStory1Option1Choice3", -1) ~= -1) then
            return "该选项处于不可选中状态哦~"
        end
    end
    SetUserConf("storyConf", msg.fromQQ, "choice", res * 1)
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

-- 跳过
function SkipStory1()
    return "Warning：当前章节选项重要程度为高，跳转功能已被锁定"
end
