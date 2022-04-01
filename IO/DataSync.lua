--[[
    @author RainChain-Zero
    @version 0.1
    @Created 2022/03/08 20:35
    @Last Modified 2022/03/31 23:36
    ]] -- json.lua的路径
msg_order = {}
package.path = getDiceDir() .. "/plugin/IO/?.lua"
Json = require "json"

-- UserConf.json的路径
UserConfPath = getDiceDir() .. "/user/UserConf/"

function DataSync(msg)
    if (msg.fromQQ ~= "3032902237") then
        return ""
    end
    sendMsg("启动数据重构...", msg.fromGroup, msg.fromQQ)
    local f1 = io.open(getDiceDir() .. "/user/UserConf.json", "r")
    local str = f1:read("a")
    local j = Json.decode(str) --用户配置表
    -- 用户数据字段分类
    local favorConf = {
        "noticeQQ",
        "favorVersion",
        "trust_flag",
        "month_last",
        "day_last",
        "hour_last",
        "year_last",
        "好感度",
        "gifts"
    }
    local storyConf = {
        "entryCheckStory",
        "isStory1Unlocked",
        "isShopUnlocked",
        "MainIndex",
        "Option",
        "Choice",
        "ChoiceIndex",
        "StroyReadNow",
        "SpecialReadNow",
        "NextOption",
        "ChoiceSelected0",
        "isStory0Read",
        "isSpecial0Read",
        "Special0Option3",
        "Special0Flag",
        "isMessageSent",
        "isStory1Unlocked",
        "actionRoundLeft",
        "isStory1Option1Choice3",
        "storyUnlockedNotice",
        "specialUnlockedNotice"
    }
    local itemConf = {
        "FL",
        "雪花糖",
        "袋装曲奇",
        "快乐水",
        "pocky",
        "彩虹糖",
        "推理小说",
        "梦的开始",
        "未言的期待",
        "永恒之戒"
    }
    local tradeConf = {
        "itemRequest",
        "isInGroup",
        "tradeReceive1",
        "tradeReceive2",
        "tradeRequest1",
        "tradeRequest2",
        "isQQBiggerThanNine",
        "itemRequestNum",
        "itemReceiveNum",
        "itemReceive"
    }
    local adjustConf = {
        "addFavorDDL_Cookie",
        "addFavorDDLFlag_Cookie",
        "favorTimePunishDownDDL",
        "favorTimePunishDownRate",
        "favorTimePunishDownDDLFlag"
    }
    --遍历所有用户，进行数据拆分
    for qq in pairs(j) do
        -- 创建用户专属文件夹
        UserInit(qq)
        --遍历某一用户所有字段
        for k, v in pairs(j[qq]) do
            for _, value in pairs(favorConf) do
                if (k == value) then
                    IOFile("favorConf", qq, k, v)
                    break
                end
            end
            for _,value in pairs(storyConf) do
                if (k == value) then
                    IOFile("storyConf", qq, k, v)
                    break
                end
            end
            for _,value in pairs(itemConf) do
                if (k == value) then
                    IOFile("itemConf", qq, k, v)
                    break
                end
            end
            for _,value in pairs(tradeConf) do
                if (k == value) then
                    IOFile("tradeConf", qq, k, v)
                    break
                end
            end
            for _,value in pairs(adjustConf) do
                if (k == value) then
                    IOFile("adjustConf", qq, k, v)
                    break
                end
            end
        end
    end
    return "数据重构完成！"
end
msg_order["重构数据"] = "DataSync"
-- 用户数据文件初始化
function UserInit(qq)
    --! Linux写法
    os.execute("mkdir "..UserConfPath..qq.."/")
    os.execute("cd> "..UserConfPath..qq.."/favorConf.json")
    os.execute("cd> "..UserConfPath..qq.."/storyConf.json")
    os.execute("cd> "..UserConfPath..qq.."/itemConf.json")
    os.execute("cd> "..UserConfPath..qq.."/tradeConf.json")
    os.execute("cd> "..UserConfPath..qq.."/adjustConf.json")
end

function IOFile(filename, qq, key, value)
    local f1 = assert(io.open(UserConfPath .. qq .. "/" .. filename .. ".json", "r"))
    local str = f1:read("a")
    if (#str == 0) then
        str = "{}"
    end
    local j = Json.decode(str)
    f1:close()
    j[key] = value
    str = Json.encode(j)
    f1 = assert(io.open(UserConfPath .. qq .. "/" .. filename .. ".json", "w"))
    f1:write(str)
    f1:close()
end
