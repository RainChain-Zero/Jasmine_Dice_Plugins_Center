function SpecialTwo(msg)
    local mainIndex, option, choice = GetUserConf("storyConf", msg.fromQQ, {"mainIndex", "option", "choice"}, {1, 0, 0})
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local content = "系统：圣诞特典剧情出现未知错误，请报告系统管理员"
    if option == 0 then
        content = Special2[mainIndex]
        SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex + 1)
        if mainIndex == 33 then
            SetUserConf("storyConf", msg.fromQQ, "option", 2)
        elseif mainIndex == 10 then
            SetUserConf("storyConf", msg.fromQQ, "option", 1)
        elseif mainIndex == 51 then
            local isSpecial2Read = GetUserConf("storyConf", msg.fromQQ, "isSpecial2Read", 0)
            if isSpecial2Read == 0 then
                SetUserConf("favorConf", msg.fromQQ, "好感度", favor + 200)
                SetUserConf("storyConf", msg.fromQQ, "isSpecial2Read", 1)
                content = content .. "\n当前好感变化:+200"
            end
            Init(msg)
        end
    elseif option == 1 then
        if choice == 0 then
            return "请选择其中一个选项以推进哦~"
        end
        content = Special2[11]
        OptionNormalInit(msg, 12)
    elseif option == 2 then
        if choice == 0 then
            return "请选择其中一个选项以推进哦~"
        end
        if choice == 1 then
            content = Special2[34]
        elseif choice == 2 then
            content = Special2[35]
        end
        OptionNormalInit(msg, 36)
    end
    return getNickFirst(msg.fromQQ, content)
end

--! 获取字符串第一个UTF-8字符
function getNickFirst(qq, str)
    return str:gsub("{nickFirst}", getUserConf(qq, "nick", "笨蛋"):match("[%z\1-\127\194-\244][\128-\191]*"))
end

function SpecialTwoChoose(msg, res)
    local option = GetUserConf("storyConf", msg.fromQQ, "option", 0)
    if option == 1 then
        SetUserConf("storyConf", msg.fromQQ, {"nextOption", "choice"}, {2, res})
    elseif option == 2 then
        if res < 1 or res > 2 then
            return "您必须输入一个有效的选项数字哦~"
        end
        SetUserConf("storyConf", msg.fromQQ, {"nextOption", "choice"}, {3, res})
    end
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipSpecial2(msg)
    local nextOption, isSpecial2Read = GetUserConf("storyConf", msg.fromQQ, {"nextOption", "isSpecial2Read"}, {1, 0})
    if isSpecial2Read == 0 then
        return "初次阅读可不支持跳过哦？"
    end
    local mainIndex = {[1] = 10, [2] = 33, [3] = 51}
    OptionNormalInit(msg, 1)
    SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex[nextOption])
end
