function SpecialThree(msg)
    local mainIndex, option, choice, isSpecial3Read =
        GetUserConf("storyConf", msg.fromQQ, {"mainIndex", "option", "choice", "isSpecial3Read"}, {1, 0, 0, 0})
    local content = "系统：白色情人节剧情出现未知错误，请报告系统管理员"
    if option == 0 then
        content = Special3[mainIndex]
        SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex + 1)
        if mainIndex == 11 then
            SetUserConf("storyConf", msg.fromQQ, "option", 1)
        elseif mainIndex == 44 then
            -- 播放歌曲
            build_music_card(msg.fromQQ, "163", 1850441824)
            sleepTime(1500)
        elseif mainIndex == 52 then
            content = content .. "{FormFeed}白色情人节特典『献给你的礼物』Fin."
            if isSpecial3Read == 0 then
                content = content .. "\n\n提示：您得到了道具『八音盒』x1；好感变化：+200"
                SetUserConf("itemConf", msg.fromQQ, "八音盒", 1)
                SetUserConf("favorConf", msg.fromQQ, "好感度", GetUserConf("favorConf", msg.fromQQ, "好感度", 0) + 200)
                SetUserConf("storyConf", msg.fromQQ, "isSpecial3Read", 1)
            end
            Init(msg)
        end
    elseif option == 1 then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        if choice == 1 then
            content = Special3[mainIndex]
            mainIndex = mainIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex)
            if mainIndex == 17 then
                OptionNormalInit(msg, 17)
            end
        elseif choice == 2 then
            content = Special3[17]
            OptionNormalInit(msg, 18)
        end
    end
    return content
end

function SpecialThreeChoose(msg, res)
    local option = GetUserConf("storyConf", msg.fromQQ, "option", 0)
    if res == 3 then
        return "您必须输入一个有效的选项数字哦~"
    end
    if option == 1 then
        SetUserConf("storyConf", msg.fromQQ, {"choice", "nextOption"}, {res, 2})
    end
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipSpecial3(msg)
    local nextOption, isSpecial3Read = GetUserConf("storyConf", msg.fromQQ, {"nextOption", "isSpecial3Read"}, {1, 0})
    if isSpecial3Read == 0 then
        return "初次阅读可不支持跳过哦？"
    end
    local MainIndex = {[1] = 11, [2] = 52}
    OptionNormalInit(msg, MainIndex[nextOption])
end

-- 八音盒额外剧情
function SpecialThreeExtra(msg)
    local mainIndex = GetUserConf("storyConf", msg.fromQQ, "mainIndex", 1)
    local content = Special3Extra[mainIndex]
    SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex + 1)
    if mainIndex == 15 then
        content = content .. "\n\n......(end)"
        Init(msg)
    elseif mainIndex == 2 then
        -- 播放歌曲
        build_music_card(msg.fromQQ, "163", 1947095105)
        sleepTime(1500)
    end
    return content
end
