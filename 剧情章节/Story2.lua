--[[
    @author RainChain-Zero
    @version 1.0
    @Created 2022/03/19 20:23
    @Last Modified 2022/03/19 21:12
    ]]
-- 第二章 难以言明的选择
function StoryTwo(msg)
    local MainIndex, Option, Choice, ChoiceIndex =
        GetUserConf(msg.fromQQ, {"MainIndex", "Option", "Choice", "ChoiceIndex"}, {1, 0, 0, 1})
    local content = "系统：出现未知错误，请报告系统管理员"
    if (Option == 0) then
        content = Story2[MainIndex]
        if (MainIndex == 7) then
            SetUserConf(msg.fromQQ, "Option", 1)
        end
        SetUserConf(msg.fromQQ, "MainIndex", MainIndex + 1)
    elseif (Option == 1) then
        if (Choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        SetUserConf(msg.fromQQ, "NextOption", -1)
        if (Choice == 1) then
            MainIndex = 8
            content = Story2[MainIndex][ChoiceIndex]
            SetUserConf(msg.fromQQ, "ChoiceIndex", ChoiceIndex + 1)
            if (ChoiceIndex == 6) then
                content = content .. "\f{FormFeed}{FormFeed}第二章『难以言明的选择 』END"
                Init(msg)
            end
        elseif (Choice == 2) then
            MainIndex = 9
            content = Story2[MainIndex][ChoiceIndex]
            SetUserConf(msg.fromQQ, "ChoiceIndex", ChoiceIndex + 1)
            if (ChoiceIndex == 8) then
                content = content .. "\f{FormFeed}{FormFeed}第二章『难以言明的选择 』END"
                Init(msg)
            end
        elseif (Choice == 3) then
            MainIndex = 10
            content = Story2[MainIndex][ChoiceIndex]
            SetUserConf(msg.fromQQ, "ChoiceIndex", ChoiceIndex + 1)
            if (ChoiceIndex == 8) then
                content = content .. "\f{FormFeed}{FormFeed}第二章『难以言明的选择 』END"
                Init(msg)
            end
        end
    end
    return content
end

function StoryTwoChoose(msg, res)
    SetUserConf(msg.fromQQ, {"Choice", "story2Choice", "NextOption"}, {res * 1, res * 1, -1})
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipStory2(msg)
    local NextOption, story2Choice = GetUserConf(msg.fromQQ, {"NextOption", "story2Choice"}, {1, 0})
    if (story2Choice == 0) then
        return "『✖Error!』初次阅读可不允许跳过哦？~"
    end
    if (NextOption == 1) then
        SetUserConf(msg.fromQQ, "Option", 1)
        return Story2[7]
    else
        Init(msg)
        return "第二章『难以言明的选择 』END"
    end
end
