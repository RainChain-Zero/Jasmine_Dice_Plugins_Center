--[[
    @author RainChain-Zero
    @version 1.0
    @Created 2022/03/19 20:23
    @Last Modified 2022/03/31 23:36
    ]]
-- 第二章 难以言明的选择
function StoryTwo(msg)
    local mainIndex, option, choice, choiceIndex =
        GetUserConf("storyConf", msg.fromQQ, {"mainIndex", "option", "choice", "choiceIndex"}, {1, 0, 0, 1})
    local content = "系统：出现未知错误，请报告系统管理员"
    if (option == 0) then
        content = Story2[mainIndex]
        if (mainIndex == 7) then
            SetUserConf("storyConf", msg.fromQQ, "option", 1)
        end
        SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex + 1)
    elseif (option == 1) then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        SetUserConf("storyConf", msg.fromQQ, "nextOption", -1)
        if (choice == 1) then
            mainIndex = 8
            content = Story2[mainIndex][choiceIndex]
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 1)
            if (choiceIndex == 6) then
                content = content .. "\f{FormFeed}{FormFeed}第二章『难以言明的选择 』END"
                Init(msg)
            end
        elseif (choice == 2) then
            mainIndex = 9
            content = Story2[mainIndex][choiceIndex]
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 1)
            if (choiceIndex == 8) then
                content = content .. "\f{FormFeed}{FormFeed}第二章『难以言明的选择 』END"
                Init(msg)
            end
        elseif (choice == 3) then
            mainIndex = 10
            content = Story2[mainIndex][choiceIndex]
            SetUserConf("storyConf", msg.fromQQ, "choiceIndex", choiceIndex + 1)
            if (choiceIndex == 8) then
                content = content .. "\f{FormFeed}{FormFeed}第二章『难以言明的选择 』END"
                Init(msg)
            end
        end
    end
    return content
end

function StoryTwoChoose(msg, res)
    if (GetUserConf("storyConf", msg.fromQQ, "story2Choice", 0) == 0) then
        sendMsg(
            "『✔提示』『打工模式』已解锁！\n开启打工状态指令:“/开始打工 6”或“/开始打工 9”（打工6或9小时）\n一旦开始将无法进行喂食及交互且无法中途停止\n结束后可以得到50或100FL",
            msg.fromGroup or 0,
            msg.fromQQ
        )
    end
    sleepTime(1000)
    SetUserConf("storyConf", msg.fromQQ, {"choice", "story2Choice", "nextOption"}, {res * 1, res * 1, -1})
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipStory2(msg)
    local nextOption, story2Choice = GetUserConf("storyConf", msg.fromQQ, {"nextOption", "story2Choice"}, {1, 0})
    if (story2Choice == 0) then
        return "『✖Error!』初次阅读可不允许跳过哦？~"
    end
    if (nextOption == 1) then
        SetUserConf("storyConf", msg.fromQQ, "option", 1)
        return Story2[7]
    else
        Init(msg)
        return "第二章『难以言明的选择 』END"
    end
end
