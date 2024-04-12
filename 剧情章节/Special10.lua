-- 分支选择点
BRANCH_POINT = { 6, 13, 18, 30, 35, 55, 72, 86 }
-- 对应各option中各个choice的起始mainIndex
BRANCH_MAININDEX = {
    { 7,  8,  9 },
    { 14, 15 },
    { 20, 21 },
    { 31, 31 },
    { 36, 37, 38 },
    { 56, 57, 58, 59 },
    { 73, 73 },
    { 87, 88 }
}
-- 伪分支
FAKE_BRANCH = { 4, 7 }

function SpecialTen(msg)
    -- 判断当前阅读人数是否过多
    if story_queue("Special10", msg.uid, 2) == false then
        return STORY_BUSY
    end
    local mainIndex, isSpecial10Read, option, choice, choiceIndex =
        GetUserConf(
            "storyConf",
            msg.uid,
            { "mainIndex", "isSpecial10Read", "option", "choice", "choiceIndex" },
            { 1, 0, 0, 0, 1 }
        )
    local content = nil
    if option == 0 or (mainIndex == 19 and option == 3) then
        content = main_storyline(msg, mainIndex, isSpecial10Read)
    else
        content = branch_storyline(msg, option, choice, choiceIndex)
    end
    return content
end

-- 主线
function main_storyline(msg, mainIndex, isSpecial10Read)
    local content = Special10[mainIndex]
    -- 判断是否是分支点
    local index = search_keywords(mainIndex, BRANCH_POINT)
    if mainIndex == #Special10 then
        content = content .. "{FormFeed}{FormFeed}「我想一直待在从树叶空隙照进的阳光里」END."
        if isSpecial10Read == 0 then
            content = content .. "\n提示：FL：+500"
            SetUserConf("itemConf", msg.uid, "fl", GetUserConf("itemConf", msg.uid, "fl", 0) + 500)
            SetUserConf("storyConf", msg.uid, "isSpecial10Read", 1)
        end
        Init(msg)
        quit_story_queue("Special10", msg.uid)
    elseif index then
        SetUserConf("storyConf", msg.uid, "option", index)
    end
    SetUserConf("storyConf", msg.uid, "mainIndex", mainIndex + 1)
    if mainIndex == 49 then
        build_music_card(msg.fromQQ, "163", 1351926437)
        sleepTime(1500)
    end
    return content
end

-- 分支
function branch_storyline(msg, option, choice, choice_index)
    if choice == 0 then
        return UNSELECTED_OPTION
    end
    -- 判断伪分支
    if search_keywords(option, FAKE_BRANCH) then
        local main_index = BRANCH_MAININDEX[option][1]
        OptionNormalInit(msg, main_index + 1)
        return Special10[main_index]
    end
    -- 根据option和choice获取对应的分支起始mainIndex
    local main_index = BRANCH_MAININDEX[option][choice]
    -- 若choice非法
    if main_index == nil then
        return ILLEGAL_OPTION
    end
    local end_index = #Special10[main_index]
    local content = Special10[main_index][choice_index]
    choice_index = choice_index + 1
    -- 返回主线
    if choice_index > end_index then
        OptionNormalInit(msg, BRANCH_MAININDEX[option][#BRANCH_MAININDEX[option]] + 1)
        return content
    end
    SetUserConf("storyConf", msg.uid, "choiceIndex", choice_index)
    return content
end

function SpecialTenChoose(msg, res)
    local option = GetUserConf("storyConf", msg.uid, "option", 0)
    if res > #BRANCH_MAININDEX[option] then
        return ILLEGAL_OPTION
    end
    SetUserConf("storyConf", msg.uid, { "choice", "nextOption" }, { res, option + 1 })
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipSpecial10(msg)
    local nextOption, isSpecial10Read = GetUserConf("storyConf", msg.uid, { "nextOption", "isSpecial10Read" }, { 1, 0 })
    if isSpecial10Read == 0 then
        return "初次阅读可不支持跳过哦？"
    end
    OptionNormalInit(msg, BRANCH_POINT[nextOption])
end
