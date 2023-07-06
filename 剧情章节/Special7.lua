-- 我所希冀的
function Special7(msg)
    local mainIndex, isSpecial7Read, option, choice =
        GetUserConf("storyConf", msg.fromQQ, {"mainIndex", "isSpecial7Read", "option", "choice"}, {1, 0, 0, 0})
    local content = "剧情出现未知错误，请联系管理员"
    if option == 0 then
        content = Special7[mainIndex]
        SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex + 1)
        if mainIndex == 12 then
            content = content .. "{wait:500}「我所希冀的」Fin."
            if isSpecial7Read == 0 then
                content = content .. "\n提示：您得到了道具「风车发饰」x1；好感变化：+100\n" .. build_image("我所希冀的二维码.png")
                SetUserConf("itemConf", msg.fromQQ, "风车发饰", 1)
                SetUserConf("favorConf", msg.fromQQ, "好感度", GetUserConf("favorConf", msg.fromQQ, "好感度", 0) + 100)
                SetUserConf("storyConf", msg.fromQQ, "isSpecial7Read", 1)
            end
            Init(msg)
        elseif mainIndex == 2 then
            SetUserConf("storyConf", msg.fromQQ, "option", 1)
        end
    elseif option == 1 then
        if choice == 0 then
            return "请选择其中一个选项以推进哦~"
        end
        if choice == 1 then
            content = Special7[3]
        elseif choice == 2 then
            content = Special7[4]
        elseif choice == 3 then
            content = Special7[5]
        end
        OptionNormalInit(msg, 6)
    end
    return content
end

function StorySevenChoose(msg, res)
    SetUserConf("storyConf", msg.fromQQ, {"choice", "nextOption"}, {res, 2})
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipSpecial7(msg)
    local nextOption, isSpecial7Read = GetUserConf("storyConf", msg.fromQQ, {"nextOption", "isSpecial7Read"}, {1, 0})
    if isSpecial7Read == 0 then
        return "初次阅读可不支持跳过哦？"
    end
    local MainIndex = {[1] = 2, [2] = 12}
    OptionNormalInit(msg, MainIndex[nextOption])
end

-- 流希 追忆·其一
function SpecialSevenExtra(msg)
    local mainIndex = GetUserConf("storyConf", msg.fromQQ, "mainIndex", 1)
    local content = Special7Extra[mainIndex]
    SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex + 1)
    if mainIndex == 7 then
        content = content .. "{wait:500}追忆·其一 End"
        Init(msg)
    elseif mainIndex == 1 then
        -- 播放歌曲
        build_music_card(msg.fromQQ, "163", 1869161372)
        sleepTime(1500)
    end
    return content
end
