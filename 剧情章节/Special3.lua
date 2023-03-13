function SpecialThree(msg)
    local mainIndex, option, choice = GetUserConf("storyConf", msg.fromQQ, {"mainIndex", "option", "choice"}, {1, 0, 0})
    local content = "系统：白色情人节剧情出现未知错误，请报告系统管理员"
    if option == 0 then
        content = Special3[mainIndex]
        SetUserConf("storyConf", "mainIndex", mainIndex + 1)
        if mainIndex == 11 then
            SetUserConf("storyConf", msg.fromQQ, "option", 1)
        elseif mainIndex == 44 then
            -- 播放歌曲
            local req = {
                ["qq"] = msg.fromQQ,
                ["type"] = "163",
                ["id"] = 1850441824
            }
            http.post(http.post("http://localhost:8083/musicCard", Json.encode(req)))
            sleepTime(1500)
        elseif mainIndex == 52 then
            content = content .. "{FormFeed}白色情人节特辑『献给你的礼物』Fin." .. "\n\n提示：您获得了道具『八音盒』x1，好感度变化：+200"
            SetUserConf("itemConf", msg.fromQQ, "musicBox", 1)
            SetUserConf("favorConf", msg.fromQQ, "好感度", GetUserConf("favorConf", msg.fromQQ, "好感度", 0) + 200)
            Init(msg)
        end
    elseif option == 1 then
        if (choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        if choice == 1 then
            mainIndex = 12
            content = Story3[mainIndex]
            mainIndex = mainIndex + 1
            SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex)
            if mainIndex == 17 then
                OptionNormalInit(msg, 17)
            end
        elseif choice == 2 then
            content = Story3[17]
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
    local content = Special3_extra[mainIndex]
    SetUserConf("storyConf", msg.fromQQ, "mainIndex", mainIndex + 1)
    if mainIndex == 15 then
        content = content .. "\n\n......(end)"
        Init(msg)
    elseif mainIndex == 2 then
        -- 播放歌曲
        local req = {
            ["qq"] = msg.fromQQ,
            ["type"] = "163",
            ["id"] = 1947095105
        }
        http.post(http.post("http://localhost:8083/musicCard", Json.encode(req)))
        sleepTime(1500)
    end
    return content
end

-- 构造发送卡片
function build_music_card(songname, songpageurl, img, songurl, singername)
    local xml =
        '<?xml version=\'1.0\' encoding=\'UTF-8\' standalone=\'yes\' ?><msg serviceID="2" templateID="1" action="web" brief="&#91;♫&#93;' ..
        songname ..
            '" sourceMsgId="0" url="' ..
                songpageurl ..
                    '" flag="0" adverSign="0" multiMsgFlag="0" ><item layout="2"><audio cover="' ..
                        img ..
                            '" src="' ..
                                songurl ..
                                    '" /><title>' ..
                                        songname .. "</title><summary>" .. singername .. "</summary></item></msg>]"
end
