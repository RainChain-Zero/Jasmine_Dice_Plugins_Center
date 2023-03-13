msg_order = {}

package.path = getDiceDir() .. "/plugin/Story/?.lua"
require "Story"
require "Special"
require "Story0"
require "Special0"
require "Story1"
require "Story2"
require "Story3"
require "Special1"
require "Special2"
require "Special3"
package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"
package.path = getDiceDir() .. "/plugin/handle/?.lua"
require "favorhandle"

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
    if (msg.fromGroup ~= nil) then
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
        end
    end
    return Reply
end
msg_order[".f"] = "StoryMain"

--! 获取字符串第一个UTF-8字符
function getNickFirst(qq, str)
    return str:gsub("{nickFirst}", getUserConf(qq, "nick", "笨蛋"):match("[%z\1-\127\194-\244][\128-\191]*"))
end

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
        if (GetUserConf("storyConf", msg.fromQQ, "isStory1Unlocked", 0) == 0) then
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
        SetUserConf("storyConf", msg.fromQQ, "specialReadNow", 3)
        Story = "白色情人节特典 献给你的礼物"
    end
    -- 是否存在章节
    if (Story == "") then
        return "请输入正确的章节名哦~"
    end
    SetUserConf("storyConf", msg.fromQQ, {"mainIndex", "option"}, {1, 0})
    return "您已进入剧情模式『" .. Story .. "』,请在小窗模式下输入.f一步一步进行哦~"
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
    if (msg.fromGroup ~= nil) then
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
        end
    end
    if (Reply == nil) then
        Reply = "您选择了跳过本段剧情，输入.f以确认跳转"
    end
    return Reply
end
msg_order[".skip"] = "Skip"
