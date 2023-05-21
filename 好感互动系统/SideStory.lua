msg_order = {}

package.path = getDiceDir() .. "/plugin/Story/?.lua"
require "Story"
require "Special"
require "Story0"
require "Special0"
require "Story1"
require "Story2"
require "Story3"
require "Story4"
require "Special1"
require "Special2"
require "Special3"
require "Special4"
require "Special5"
require "Special6"
package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"
package.path = getDiceDir() .. "/plugin/Handle/?.lua"
require "FavorHandle"
require "Utils"

-- 主调入口
function StoryMain(msg)
    local Reply = "系统：剧情出现未知错误，请报告系统管理员"
    local StoryNormal, StorySpecial =
        GetUserConf(
        "storyConf",
        msg.fromQQ,
        {
            "storyReadNow",
            "specialReadNow"
        },
        {-1, -1}
    )

    -- 未进入剧情模式不触发
    if (StoryNormal + StorySpecial == -2) then
        return "您未进入任何剧情模式哦~"
    end

    -- 必须在小窗下进行
    if (msg.gid ~= nil) then
        return "茉莉..茉莉可不想在人多的地方和你分享这些哦（脸红）"
    end

    -- ? 判断具体剧情
    if (StoryNormal ~= -1) then
        if (StoryNormal == 0) then
            Reply = StoryZero(msg)
        elseif (StoryNormal == 1) then
            Reply = StoryOne(msg)
        elseif (StoryNormal == 2) then
            Reply = StoryTwo(msg)
        elseif StoryNormal == 3 then
            Reply = StoryThree(msg)
        elseif StoryNormal == 4 then
            Reply = StoryFour(msg)
        end
    else
        if (StorySpecial == 0) then
            Reply = SpecialZero(msg)
        elseif StorySpecial == 1 then
            Reply = SpecialOne(msg)
        elseif StorySpecial == 2 then
            Reply = getNickFirst(msg.fromQQ, SpecialTwo(msg))
        elseif StorySpecial == 3 then
            Reply = getNickFirst(msg.fromQQ, SpecialThree(msg))
        elseif StorySpecial == 4 then
            Reply = SpecialThreeExtra(msg)
        elseif StorySpecial == 5 then
            Reply = SpecialFour(msg)
        elseif StorySpecial == 6 then
            Reply = SpecialFive(msg)
        elseif StorySpecial == 7 then
            Reply = SpecialSix(msg)
        end
    end
    return Reply
end
msg_order[".f"] = "StoryMain"

-- 剧情入口点
EntryStoryOrder = "进入剧情"
function EnterStory(msg)
    -- 初始化配置
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    local StoryTemp = string.match(msg.fromMsg, "[%s]*(.*)", #EntryStoryOrder + 1)
    local Story = ""
    if (Story == nil or StoryTemp == "") then
        return "请输入章节名哦~"
    end
    Init(msg)
    -- 提取具体章节
    if (string.find(StoryTemp, "序章") ~= nil or string.find(StoryTemp, "惊蛰") ~= nil) then
        if (favor < 1000) then
            return "『✖条件未满足』茉莉暂时还不想和{nick}分享这些呢..这是茉莉的小秘密哦~(好感度不足1000)"
        end
        Story = "序章 惊蛰"
        SetUserConf("storyConf", msg.fromQQ, {"storyReadNow", "choiceSelected0"}, {0, 0})
    elseif (string.find(StoryTemp, "元旦特典") ~= nil or string.find(StoryTemp, "预想此时应更好") ~= nil) then
        if (favor < 1500) then
            return "『✖条件未满足』茉莉暂时还不想和{nick}分享这些呢..这是茉莉的小秘密哦~(好感度不足1500)"
        end
        Story = "元旦特典 预想此时应更好"
        SetUserConf("storyConf", msg.fromQQ, "specialReadNow", 0)
    elseif (string.find(StoryTemp, "第一章") ~= nil or string.find(StoryTemp, "夜未央") ~= nil) then
        if (favor < 2000) then
            return "『✖条件未满足』茉莉暂时还不想和{nick}分享这些呢..这是茉莉的小秘密哦~(好感度不足2000)"
        end
        if (GetUserConf("storyConf", msg.fromQQ, "isStory1Unlocked", 0) == 0) then
            SetUserConf("storyConf", msg.fromQQ, "entryCheckStory", 1)
            return "眼前的记忆碎片被一股神秘的光芒所环绕，将它从外界隔绝开来，也许只有某些特定的物品才能将其解除。\n（输入“/u 道具名”使用道具，可输入“道具图鉴”以查询）"
        end
        SetUserConf(
            "storyConf",
            msg.fromQQ,
            {
                "actionRoundLeft",
                "storyReadNow",
                "isStory1Option1Choice3"
            },
            {4, 1, -1}
        )
        Story = "第一章 夜未央"
    elseif (string.find(StoryTemp, "第二章") ~= nil or string.find(StoryTemp, "难以言明的选择") ~= nil) then
        if (GetUserConf("storyConf", msg.fromQQ, "isShopUnlocked", 0) == 0) then
            return "『✖条件未满足』您需要在第一章中解锁『商店』功能"
        elseif (favor < 3000) then
            return "『✖条件未满足』茉莉暂时还不想和{nick}分享这些呢..这是茉莉的小秘密哦~(好感度不足3000)"
        else
            SetUserConf("storyConf", msg.fromQQ, "storyReadNow", 2)
            Story = "第二章 难以言明的选择"
        end
    elseif (string.find(StoryTemp, "第三章") or string.find(StoryTemp, "此般景致")) then
        if (GetUserConf("storyConf", msg.fromQQ, "story2Choice", 0) == 0) then
            return "『✖条件未满足』您需要通过第二章 难以言明的选择"
        elseif (favor < 4000) then
            return "『✖条件未满足』茉莉暂时还不想和{nick}分享这些呢..这是茉莉的小秘密哦~(好感度不足4000)"
        else
            SetUserConf("storyConf", msg.fromQQ, "storyReadNow", 3)
            Story = "第三章 此般景致"
        end
    elseif string.find(StoryTemp, "七夕特典") or string.find(StoryTemp, "近在咫尺的距离") then
        if favor < 3500 then
            return "『✖条件未满足』茉莉暂时还不想和{nick}分享这些呢..这是茉莉的小秘密哦~(好感度不足3500)"
        end
        SetUserConf("storyConf", msg.fromQQ, "specialReadNow", 1)
        Story = "七夕特典 近在咫尺的距离"
    elseif StoryTemp:find("圣诞特典") or StoryTemp:find("予你的光点") then
        if favor < 2000 then
            return "『✖条件未满足』茉莉暂时还不想和{nick}分享这些呢..这是茉莉的小秘密哦~(好感度不足2000)"
        end
        SetUserConf("storyConf", msg.fromQQ, "specialReadNow", 2)
        Story = "圣诞特典 予你的光点"
    elseif StoryTemp:find("白色情人节特典") or StoryTemp:find("献给你的礼物") then
        local isSpecial3Read = GetUserConf("storyConf", msg.fromQQ, "isSpecial3Read", 0)
        if isSpecial3Read == 0 then
            local fl = GetUserConf("itemConf", msg.fromQQ, "fl", 0)
            if fl >= 750 then
                SetUserConf("itemConf", msg.fromQQ, "fl", fl - 750)
                SetUserConf("storyConf", msg.fromQQ, "specialReadNow", 3)
                Story = "白色情人节特典 献给你的礼物"
            else
                msg:echo("您需要拥有750fl来解锁此剧情哦~")
            end
        else
            SetUserConf("storyConf", msg.fromQQ, "specialReadNow", 3)
            Story = "白色情人节特典 献给你的礼物"
        end
    elseif StoryTemp:find("第四章") or StoryTemp:find("众生相") then
        if GetUserConf("storyConf", msg.fromQQ, "isStory3Read", 0) == 0 then
            return "『✖条件未满足』您需要通过第三章 此般景致"
        elseif favor < 4000 then
            return "『✖条件未满足』茉莉暂时还不想和{nick}分享这些呢..这是茉莉的小秘密哦~(好感度不足4000)"
        else
            SetUserConf("storyConf", msg.fromQQ, "storyReadNow", 4)
            Story = "第四章 众生相"
        end
    elseif StoryTemp:find("星星点灯") or StoryTemp:find("生日特典") then
        local isSepcial4Read = GetUserConf("storyConf", msg.fromQQ, "isSepcial4Read", 0)
        if isSepcial4Read == 0 then
            local fl = GetUserConf("itemConf", msg.fromQQ, "fl", 0)
            if fl >= 900 then
                SetUserConf("itemConf", msg.fromQQ, "fl", fl - 900)
                SetUserConf("storyConf", msg.fromQQ, "specialReadNow", 5)
                Story = "生日特典 星星点灯"
            else
                msg:echo("您需要拥有900fl来解锁此剧情哦~")
            end
        else
            SetUserConf("storyConf", msg.fromQQ, "specialReadNow", 5)
            Story = "生日特典 星星点灯"
        end
    elseif StoryTemp:find("夜") then
        local isSpecial5Read = GetUserConf("storyConf", msg.fromQQ, "isSpecial5Read", 0)
        if isSpecial5Read == 0 then
            local fl = GetUserConf("itemConf", msg.fromQQ, "fl", 0)
            if fl >= 1000 then
                SetUserConf("itemConf", msg.fromQQ, "fl", fl - 1000)
                SetUserConf("storyConf", msg.fromQQ, "specialReadNow", 6)
                Story = "夜"
            else
                return "您需要拥有1000fl来解锁此剧情哦~"
            end
        end
    elseif StoryTemp:find("因为是家人") then
        if favor >= 5000 then
            SetUserConf("storyConf", msg.fromQQ, "specialReadNow", 7)
            Story = "因为是家人"
        else
            return "『✖条件未满足』茉莉暂时还不想和{nick}分享这些呢..这是茉莉的小秘密哦~(好感度不足5000)"
        end
    end
    -- 是否存在章节
    if (Story == "") then
        return "请输入正确的章节名哦~"
    end
    return "您已进入剧情模式「" .. Story .. "」,请在小窗模式下输入.f一步一步进行哦~"
end
msg_order[EntryStoryOrder] = "EnterStory"

-- 配置初始化
function Init(msg)
    SetUserConf(
        "storyConf",
        msg.fromQQ,
        {
            "mainIndex",
            "choiceIndex",
            "option",
            "choice",
            "storyReadNow",
            "specialReadNow",
            "nextOption"
        },
        {1, 1, 0, 0, -1, -1, 1}
    )
end

-- 选项选择
function Choose(msg)
    local option, StoryNormal, StorySpecial =
        GetUserConf("storyConf", msg.fromQQ, {"option", "storyReadNow", "specialReadNow"}, {0, -1, -1})
    local Reply = "系统：出现未知错误，请报告系统管理员"
    -- 未进入任何剧情模式
    if (StoryNormal + StorySpecial == -2) then
        return ""
    end
    -- 没有任何选项
    if (option == 0) then
        return "您现在还不能选择任何选项哦~"
    end
    -- 匹配选项
    local res = string.match(msg.fromMsg, "[%s]*(%d)", 3)
    res = tonumber(res or 0)
    if (res < 1 or res > 3) then
        return "您必须输入一个有效的选项数字哦~"
    end

    -- 不同章节一一处理
    if (StoryNormal ~= -1) then
        if (StoryNormal == 0) then
            Reply = StoryZeroChoose(msg, res)
        elseif (StoryNormal == 1) then
            Reply = StoryOneChoose(msg, res)
        elseif (StoryNormal == 2) then
            Reply = StoryTwoChoose(msg, res)
        elseif StoryNormal == 3 then
            Reply = StoryThreeChoose(msg, res)
        elseif StoryNormal == 4 then
            Reply = StoryFourChoose(msg, res)
        end
    else
        if (StorySpecial == 0) then
            Reply = SpecialZeroChoose(msg, res)
        elseif StorySpecial == 1 then
            Reply = SpecialOneChoose(msg, res)
        elseif StorySpecial == 2 then
            Reply = SpecialTwoChoose(msg, res)
        elseif StorySpecial == 3 then
            Reply = SpecialThreeChoose(msg, res)
        elseif StorySpecial == 7 then
            Reply = SpecialSixChoose(msg, res)
        end
    end
    return Reply
end
msg_order[".c"] = "Choose"
msg_order[".C"] = "Choose"

-- 一个选项结束后初始化有关记录
function OptionNormalInit(msg, index)
    SetUserConf("storyConf", msg.fromQQ, {"mainIndex", "choiceIndex", "option", "choice"}, {index, 1, 0, 0})
end

-- 跳转到下一选项
function Skip(msg)
    local StoryNormal, StorySpecial =
        GetUserConf(
        "storyConf",
        msg.fromQQ,
        {
            "storyReadNow",
            "specialReadNow"
        },
        {-1, -1}
    )
    local Reply
    -- 未进入任何剧情模式 不响应
    if (StoryNormal + StorySpecial == -2) then
        return ""
    end
    -- 必须在小窗下进行
    if (msg.gid ~= nil) then
        return "茉莉..茉莉可不想在人多的地方和你分享这些哦（脸红）（必须在好友小窗下进行）"
    end
    if (StoryNormal ~= -1) then
        if (StoryNormal == 0) then
            Reply = SkipStory0(msg)
        elseif (StoryNormal == 1) then
            Reply = SkipStory1()
        elseif (StoryNormal == 2) then
            Reply = SkipStory2(msg)
        elseif StoryNormal == 3 then
            Reply = SkipStory3(msg)
        elseif StoryNormal == 4 then
            Reply = SkipStory4(msg)
        end
    else
        if (StorySpecial == 0) then
            Reply = SkipSpecial0(msg)
        elseif StorySpecial == 1 then
            Reply = SkipSpecial1(msg)
        elseif StorySpecial == 2 then
            Reply = SkipSpecial2(msg)
        elseif StorySpecial == 3 then
            Reply = SkipSpecial3(msg)
        elseif StorySpecial == 4 or StorySpecial == 5 or StorySpecial == 6 or StorySpecial == 7 then
            Reply = "本剧情没有选项哦~无法跳转"
        end
    end
    if (Reply == nil) then
        Reply = "您选择了跳过本段剧情，输入.f以确认跳转"
    end
    return Reply
end
msg_order[".skip"] = "Skip"

function query_story(msg)
    local story_finish =
        GetUserConf(
        "storyConf",
        msg.fromQQ,
        {
            "isStory0Read",
            "isSpecial0Read",
            "isShopUnlocked",
            "story2Choice",
            "isSpecial1Read",
            "isSpecial2Read",
            "isSpecial3Read",
            "isStory3Read",
            "isSpecial4Read",
            "isSpecial5Read",
            "isStory4Read",
            "isShopUnlocked",
            "isSpecial6Read"
        },
        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
        true
    )
    local reply = "收到数据库访问请求，为您检索：\n"
    for _, variable in ipairs(__STORY_VARIABLE__) do
        if story_finish[variable] == 0 then
            reply = reply .. __STORY_NAME__[variable] .. " ✘未通过\n"
        else
            reply = reply .. __STORY_NAME__[variable] .. " ✔已通过\n"
        end
    end
    return reply .. "茉莉，高性能ですから!"
end
msg_order["/剧情进度"] = "query_story"

__STORY_NAME__ = {
    isStory0Read = "序章「惊蛰」",
    isShopUnlocked = "第一章「夜未央」",
    story2Choice = "第二章「难以言明的选择」",
    isStory3Read = "第三章「此般景致」",
    isStory4Read = "第四章「众生相」",
    isSpecial0Read = "元旦特典「预想此时应更好」",
    isSpecial1Read = "七夕特典「近在咫尺的距离」",
    isSpecial2Read = "圣诞特典 「予你的光点」",
    isSpecial3Read = "白色情人节特典 「献给你的礼物」",
    isSpecial4Read = "「星星点灯」",
    isSpecial5Read = "「夜」",
    isSpecial6Read = "521短篇「因为是家人」"
}

__STORY_VARIABLE__ = {
    "isStory0Read",
    "isShopUnlocked",
    "story2Choice",
    "isStory3Read",
    "isStory4Read",
    "isSpecial0Read",
    "isSpecial1Read",
    "isSpecial2Read",
    "isSpecial3Read",
    "isSpecial4Read",
    "isSpecial5Read",
    "isSpecial6Read"
}
