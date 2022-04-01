--[[
    @author 慕北_Innocent(RainChain)
    @version 1.7
    @Created 2021/12/05 00:04
    @Last Modified 2022/03/31 23:36
    ]] msg_order = {}

package.path = getDiceDir() .. "/plugin/Story/?.lua"
require "Story"
require "Story0"
require "Special0"
require "Story1"
require "Story2"
package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"
-- 主调入口
function StoryMain(msg)
    local Reply = "系统：剧情出现未知错误，请报告系统管理员"
    local StoryNormal, StorySpecial =
        GetUserConf(
        "storyConf",
        msg.fromQQ,
        {
            "StoryReadNow",
            "SpecialReadNow"
        },
        {-1, -1}
    )

    -- 未进入剧情模式不触发
    if (StoryNormal + StorySpecial == -2) then
        return "您未进入任何剧情模式哦~"
    end

    -- 必须在小窗下进行
    if (msg.fromGroup ~= "0") then
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
        end
    else
        if (StorySpecial == 0) then
            Reply = SpecialZero(msg)
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
    Init(msg)
    local StoryTemp = string.match(msg.fromMsg, "[%s]*(.*)", #EntryStoryOrder + 1)
    local Story = ""
    if (Story == nil or StoryTemp == "") then
        return "请输入章节名哦~"
    end
    -- 提取具体章节
    if (string.find(StoryTemp, "序章") ~= nil or string.find(StoryTemp, "惊蛰") ~= nil) then
        if (favor < 1000) then
            return "『✖条件未满足』茉莉暂时还不想和{nick}分享这些呢..这是茉莉的小秘密哦~(好感度不足1000)"
        end
        Story = "序章 惊蛰"
        SetUserConf("storyConf", msg.fromQQ, {"StoryReadNow", "ChoiceSelected0"}, {0, 0})
    elseif (string.find(StoryTemp, "元旦特典") ~= nil or string.find(StoryTemp, "预想此时应更好") ~= nil) then
        if (favor < 1500) then
            return "『✖条件未满足』茉莉暂时还不想和{nick}分享这些呢..这是茉莉的小秘密哦~(好感度不足1500)"
        end
        Story = "元旦特典 预想此时应更好"
        SetUserConf("storyConf", msg.fromQQ, "SpecialReadNow", 0)
    elseif (string.find(StoryTemp, "第一章") ~= nil or string.find(StoryTemp, "夜未央") ~= nil) then
        if (GetUserConf("storyConf", msg.fromQQ, "isStory1Unlocked", 0) == 0) then
            SetUserConf("storyConf", msg.fromQQ, "entryCheckStory", 1)
            return "眼前的记忆碎片被一股神秘的光芒所环绕，将它从外界隔绝开来，也许只有某些特定的物品才能将其解除。\n（输入“.u 道具名”使用道具，可输入“道具图鉴”以查询）"
        end
        SetUserConf(
            "storyConf",
            msg.fromQQ,
            {
                "actionRoundLeft",
                "StoryReadNow",
                "isStory1Option1Choice3"
            },
            {4, 1, -1}
        )
        Story = "第一章 夜未央"
    elseif (string.find(StoryTemp, "第二章") ~= nil or string.find(StoryTemp, "难以言明的选择") ~= nil) then
        --! 暂未对外开放
        if (msg.fromQQ ~= "3032902237" and msg.fromQQ ~= "2677409596") then
            return "『✖权限不足』该章节暂未对外开放！"
        end
        if (GetUserConf("storyConf", msg.fromQQ, "isStory1Unlocked", 0) == 0) then
            return "『✖条件未满足』您需要在第一章中解锁『商店』功能"
        elseif (GetUserConf("favorConf", msg.fromQQ, "好感度", 0) < 3000) then
            return "『✖条件未满足』茉莉暂时还不想和{nick}分享这些呢..这是茉莉的小秘密哦~(好感度不足3000)"
        else
            SetUserConf("storyConf", msg.fromQQ, "StoryReadNow", 2)
            Story = "第二章 难以言明的选择"
        end
    end
    -- 是否存在章节
    if (Story == "") then
        return "请输入正确的章节名哦~"
    end
    SetUserConf("storyConf", msg.fromQQ, {"MainIndex", "Option"}, {1, 0})
    return "您已进入剧情模式『" .. Story .. "』,请在小窗模式下输入.f一步一步进行哦~"
end
msg_order[EntryStoryOrder] = "EnterStory"

-- 配置初始化
function Init(msg)
    SetUserConf(
        "storyConf",
        msg.fromQQ,
        {
            "MainIndex",
            "ChoiceIndex",
            "Option",
            "Choice",
            "StoryReadNow",
            "SpecialReadNow",
            "NextOption"
        },
        {1, 1, 0, 0, -1, -1, 1}
    )
end

-- 选项选择
function Choose(msg)
    local Option, StoryNormal, StorySpecial =
        GetUserConf("storyConf", msg.fromQQ, {"Option", "StoryReadNow", "SpecialReadNow"}, {0, -1, -1})
    local Reply = "系统：出现未知错误，请报告系统管理员"
    -- 未进入任何剧情模式
    if (StoryNormal + StorySpecial == -2) then
        return ""
    end
    -- 没有任何选项
    if (Option == 0) then
        return "您现在还不能选择任何选项哦~"
    end
    -- 匹配选项
    local res = string.match(msg.fromMsg, "[%s]*(%d)", 3)
    if (res == nil or res == "" or res * 1 < 1 or res * 1 > 3) then
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
        end
    else
        if (StorySpecial == 0) then
            Reply = SpecialZeroChoose(msg, res)
        end
    end
    return Reply
end
msg_order[".c"] = "Choose"
msg_order[".C"] = "Choose"

-- 一个选项结束后初始化有关记录
function OptionNormalInit(msg, index)
    SetUserConf("storyConf", msg.fromQQ, {"MainIndex", "ChoiceIndex", "Option", "Choice"}, {index, 1, 0, 0})
end

-- 跳转到下一选项
function Skip(msg)
    local StoryNormal, StorySpecial =
        GetUserConf(
        "storyConf",
        msg.fromQQ,
        {
            "StoryReadNow",
            "SpecialReadNow"
        },
        {-1, -1}
    )
    local Reply
    -- 未进入任何剧情模式 不响应
    if (StoryNormal + StorySpecial == -2) then
        return ""
    end
    -- 必须在小窗下进行
    if (msg.fromGroup ~= "0") then
        return "茉莉..茉莉可不想在人多的地方和你分享这些哦（脸红）"
    end
    if (StoryNormal ~= -1) then
        if (StoryNormal == 0) then
            Reply = SkipStory0(msg)
        elseif (StoryNormal == 1) then
            Reply = SkipStory1()
        elseif (StoryNormal == 2) then
            Reply = SkipStory2(msg)
        end
    else
        if (StorySpecial == 0) then
            Reply = SkipSpecial0(msg)
        end
    end
    if (Reply == nil) then
        Reply = "您选择了跳过本段剧情，输入.f以确认跳转"
    end
    return Reply
end
msg_order["跳过"] = "Skip"
