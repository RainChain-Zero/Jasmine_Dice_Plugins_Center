function SpecialSix(msg)
    local mainIndex, isSpecial6Read, option, choice =
        GetUserConf("storyConf", msg.fromQQ, {"mainIndex", "isSpecial6Read", "option", "choice"}, {1, 0, 0, 0})
    if option == 1 and choice == 0 then
        return "请选择其中一个选项以推进哦~"
    end
    local content = "系统：剧情出现未知错误，请报告系统管理员"
    content = Special6[mainIndex]
    if mainIndex == #Special6 then
        content = content .. "{FormFeed}521短篇「因为是家人」Fin."
        if isSpecial6Read == 0 then
            content = content .. "\n提示：您得到了道具『野餐篮』x1；好感变化：+100"
            SetUserConf("itemConf", msg.fromQQ, "野餐篮", 1)
            SetUserConf("favorConf", msg.fromQQ, "好感度", GetUserConf("favorConf", msg.fromQQ, "好感度", 0) + 100)
            SetUserConf("storyConf", msg.fromQQ, "isSpecial6Read", 1)
        end
        Init(msg)
    elseif mainIndex == 1 then
        SetUserConf("storyConf", msg.fromQQ, "option", 1)
    end
    SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex + 1)
    if mainIndex ~= 1 then
        return convert_gender(msg, content)
    end
    return content
end

function SpecialSixChoose(msg, res)
    if res == 1 then
        setUserConf(msg.fromQQ, "gender", "female")
    elseif res == 2 then
        setUserConf(msg.fromQQ, "gender", "male")
    else
        return "您必须输入一个有效的选项数字哦~"
    end
    SetUserConf("storyConf", msg.fromQQ, "choice", res)
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function convert_gender(msg, content)
    local gender = getUserConf(msg.fromQQ, "gender", "female")
    if gender == "male" then
        return content:gsub("哥", "姐")
    end
    return content
end
