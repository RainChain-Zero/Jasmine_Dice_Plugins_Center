--[[
    @author 慕北_Innocent(RainChain)
    @version 1.1
    @Created 2021/12/13 12:07
    @Last Modified 2021/12/30 14:15
    ]] -- 序章
function StoryZero(msg)
    local MainIndex, Option, Choice = getUserConf(msg.fromQQ, "MainIndex", 1),
                                      getUserConf(msg.fromQQ, "Option", 0),
                                      getUserConf(msg.fromQQ, "Choice", 0)
    local ChoiceIndex = getUserConf(msg.fromQQ, "ChoiceIndex", 1)
    local ChoiceSelected = getUserConf(msg.fromQQ, "ChoiceSelected0", 0)
    local content
    -- 判断是否进入分支
    if (Option == 0) then
        content = Story0[MainIndex];
        if (MainIndex == 3) then
            setUserConf(msg.fromQQ, "Option", 1)
        elseif (MainIndex == 7) then
            setUserConf(msg.fromQQ, "Option", 2)
        end
        if (MainIndex == 7) then
            content = Story0[7][1] -- 初发选项
        end
        MainIndex = MainIndex + 1
        setUserConf(msg.fromQQ, "MainIndex", MainIndex)
        return content

        -- 选项1
    elseif (Option == 1) then
        -- 未选择
        if (Choice == 0) then
            return "请选择其中一个选项以推进哦~"
        end
        -- 记录下一个跳转选项
        setUserConf(msg.fromQQ, "NextOption", 2)

        if (Choice == 1) then
            MainIndex = 4
            content = Story0[MainIndex]
            MainIndex = 7
            setUserConf(msg.fromQQ, "MainIndex", MainIndex)
            setUserConf(msg.fromQQ, "Option", 0)
            setUserConf(msg.fromQQ, "Choice", 0)
            return content
        elseif (Choice == 2) then
            MainIndex = 5
            content = Story0[MainIndex][ChoiceIndex]
            ChoiceIndex = ChoiceIndex + 1
            setUserConf(msg.fromQQ, "ChoiceIndex", ChoiceIndex)
            if (ChoiceIndex > 2) then
                setUserConf(msg.fromQQ, "MainIndex", 7)
                setUserConf(msg.fromQQ, "ChoiceIndex", 1)
                setUserConf(msg.fromQQ, "Option", 0)
                setUserConf(msg.fromQQ, "Choice", 0)
            end
            return content
        elseif (Choice == 3) then
            if (getUserConf(msg.fromQQ, "isStory0Read", 0) == 0) then
                setUserConf(msg.fromQQ, "好感度",
                            getUserConf(msg.fromQQ, "好感度", 0) + 200)
            end
            MainIndex = 6
            content = Story0[MainIndex][ChoiceIndex + 1]
            sendMsg(Story0[MainIndex][ChoiceIndex], 0, msg.fromQQ)
            ChoiceIndex = ChoiceIndex + 2
            setUserConf(msg.fromQQ, "ChoiceIndex", ChoiceIndex)
            if (ChoiceIndex > 4) then
                setUserConf(msg.fromQQ, "MainIndex", 7)
                setUserConf(msg.fromQQ, "ChoiceIndex", 1)
                setUserConf(msg.fromQQ, "Option", 0)
                setUserConf(msg.fromQQ, "Choice", 0)
            end
            sleepTime(2500)
            return content
        end
    elseif (Option == 2) then
        -- 记录下一个跳转选项
        setUserConf(msg.fromQQ, "NextOption", -1)
        -- 未选择
        if (Choice == 0) then
            if (MainIndex == 7) then
                local Choicen = getUserConf(msg.fromQQ, "ChoiceSelected0", 0)
                -- return Choice
                if (Choicen == 1) then return Story0[7][2] end
                if (Choicen == 3) then return Story0[7][3] end
                if (Choicen == 4) then return Story0[7][4] end
            end
            return "请选择其中一个选项以推进哦~"
        end

        if (Choice == 1) then
            ChoiceSelected = ChoiceSelected + 1
            setUserConf(msg.fromQQ, "ChoiceSelected0", ChoiceSelected)
            content = Story0[8]
            setUserConf(msg.fromQQ, "MainIndex", 7)
            setUserConf(msg.fromQQ, "Choice", 0)
            return content
        elseif (Choice == 2) then
            content = Story0[9]
            Init(msg)
            if (getUserConf(msg.fromQQ, "isStory0Read", 0) == 0) then
                setUserConf(msg.fromQQ, "梦的开始", 1)
                setUserConf(msg.fromQQ, "isStory0Read", 1)
                sendMsg(content, 0, msg.fromQQ)
                sleepTime(2000)
                return
                    "系统：您得到了道具『梦的开始』x1（一把象牙白的钥匙，晶莹剔透，不知道是用什么制作的，或许能开启什么）"
            end
            return content
        elseif (Choice == 3) then
            ChoiceSelected = ChoiceSelected + 3
            setUserConf(msg.fromQQ, "ChoiceSelected0", ChoiceSelected)
            content = Story0[10]
            setUserConf(msg.fromQQ, "MainIndex", 7)
            setUserConf(msg.fromQQ, "Choice", 0)
            return content
        end
    end
end

function StoryZeroChoose(msg, res)
    local Option = getUserConf(msg.fromQQ, "Option", 0)
    local ChoiceSelected = getUserConf(msg.fromQQ, "ChoiceSelected0", 0)
    if (Option == 2) then
        if ((res * 1 == 1 and (ChoiceSelected == 1 or ChoiceSelected == 4)) or
            (res * 1 == 3 and (ChoiceSelected == 3 or ChoiceSelected == 4))) then
            return "这个选项目前处于不可选中状态哦~"
        end
    end
    setUserConf(msg.fromQQ, "Choice", res * 1)
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipStory0(msg)
    local NextOption = getUserConf(msg.fromQQ, "NextOption", 1)
    local isStory0Read = getUserConf(msg.fromQQ, "isStory0Read", 0)
    if (isStory0Read == 0) then return "初次阅读可不支持跳过哦？" end
    if (NextOption == -1) then
        return
            "当前所处选项不允许跳转哦？~（选项限制/已经是最后一个选项）"
    end
    OptionNormalInit(msg, 1)
    local MAININDEX = {[1] = 3, [2] = 7}
    setUserConf(msg.fromQQ, "MainIndex", MAININDEX[NextOption])
end
