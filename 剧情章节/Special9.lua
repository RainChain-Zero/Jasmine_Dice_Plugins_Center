-- 分支选择点
BRANCH_POINT = {4, 11, 22, 29, 37, 55, 64, 66, 76, 80, 92, 98, 104, 111}
-- 对应各option中各个choice的起始mainIndex
BRANCH_MAININDEX = {
    {5, 6, 7},
    {12, 13},
    -- 选项3没有分支，返回下一段内容后直接初始化选项
    23,
    {30, 31},
    {38, 39},
    {56, 57, 58},
    -- 选项7没有分支
    65,
    {67, 68, 69},
    -- 选项9没有分支
    77,
    {81, 82},
    {93, 94},
    {99, 100, 101},
    {105, 106, 107},
    {112, 113}
}
-- 伪分支
FAKE_BRANCH = {3, 7, 9}
function SpecialNine(msg)
    -- 判断当前阅读人数是否过多
    if story_queue("Special9", msg.uid, 1) == false then
        return STORY_BUSY
    end
    local mainIndex, isSpecial9Read, option, choice, choiceIndex =
        GetUserConf(
        "storyConf",
        msg.uid,
        {"mainIndex", "isSpecial9Read", "option", "choice", "choiceIndex"},
        {1, 0, 0, 0, 1}
    )
    local content = nil
    if option == 0 then
        content = main_storyline(msg, mainIndex, isSpecial9Read)
    else
        content = branch_stroyline(msg, option, choice, choiceIndex)
    end
    return content
end

-- 主线
function main_storyline(msg, mainIndex, isSpecial9Read)
    local content = Special9[mainIndex]
    -- 判断是否是分支点
    local index = search_keywords(mainIndex, BRANCH_POINT)
    if mainIndex == #Special9 then
        content = content .. "{FormFeed}{FormFeed}「我想一直待在从树叶空隙照进的阳光里」To be continued."
        if isSpecial9Read == 0 then
            content = content .. "\n提示：FL：+500"
            SetUserConf("itemConf", msg.uid, "fl", GetUserConf("itemConf", msg.uid, "fl", 0) + 500)
            SetUserConf("storyConf", msg.uid, "isSpecial9Read", 1)
        end
        Init(msg)
    elseif index then
        SetUserConf("storyConf", msg.uid, "option", index)
    end
    SetUserConf("storyConf", msg.uid, "mainIndex", mainIndex + 1)
    return content
end

-- 分支
function branch_stroyline(msg, option, choice, choice_index)
    if choice == 0 then
        msg:echo(option)
    -- return UNSELECTED_OPTION
    end
    -- 判断伪分支
    if search_keywords(option, FAKE_BRANCH) then
        local main_index = BRANCH_MAININDEX[option]
        OptionNormalInit(msg, main_index + 1)
        return Special9[main_index]
    end
    -- 根据option和choice获取对应的分支起始mainIndex
    local main_index = BRANCH_MAININDEX[option][choice]
    -- 若choice非法
    if main_index == nil then
        return ILLEGAL_OPTION
    end
    local end_index = #Special9[main_index]
    local content = Special9[main_index][choice_index]
    choice_index = choice_index + 1
    -- 返回主线
    if choice_index > end_index then
        OptionNormalInit(msg, BRANCH_MAININDEX[option][#BRANCH_MAININDEX[option]] + 1)
        return content
    end
    SetUserConf("storyConf", msg.uid, "choiceIndex", choice_index)
    return content
end

function SpecialNineChoose(msg, res)
    local option = GetUserConf("storyConf", msg.uid, "option", 0)
    SetUserConf("storyConf", msg.uid, {"choice", "nextOption"}, {res, option + 1})
    return "您选中了选项" .. res .. " 输入.f以确认选择"
end

function SkipSpecial9(msg)
    local nextOption, isSpecial9Read = GetUserConf("storyConf", msg.uid, {"nextOption", "isSpecial9Read"}, {1, 0})
    if isSpecial9Read == 0 then
        return "初次阅读可不支持跳过哦？"
    end
    OptionNormalInit(msg, BRANCH_POINT[nextOption])
end
