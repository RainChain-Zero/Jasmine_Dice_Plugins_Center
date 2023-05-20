package.path = getDiceDir() .. "/plugin/IO/?.lua"
Json = require "json"

-- UserToday.json的路径
UserTodayPath = getDiceDir() .. "/user/UserToday.json"
-- GroupConf.json的路径
GroupConfPath = getDiceDir() .. "/user/GroupConf.json"

-- 本地API接口
url = "http://localhost:45445/"

routers = {
    ["favorConf"] = "FavorConf",
    ["adjustConf"] = "AdjustConf",
    ["itemConf"] = "ItemConf",
    ["storyConf"] = "StoryConf",
    ["tradeConf"] = "TradeConf",
    ["moodConf"] = "MoodConf",
    ["missionConf"] = "MissionConf"
}

-- 文件名,qq,{key},{value} key和value相同索引处一一对应/qq,key,value
function SetUserConf(filename, qq, key, value)
    qq = tostring(qq)
    --! 参数不足判断
    if (value == nil) then
        error("SetUserConf arg#4 value==nil")
    end
    --! 拼写错误判断
    if (filename == "stroyConf") then
        error("spelling mistake in SetUserConf arg#1 filename")
    end
    local j = {["qq"] = qq}
    -- 对密集的写入支持列表以提高效率
    if (type(key) == "table" and type(value) == "table") then
        -- 按顺序遍历表，写入
        for k, v in ipairs(key) do
            if v == "好感度" then
                j["favor"] = value[k]
            else
                j[v] = value[k]
            end
        end
    else
        -- 好感度的字段名和后端统一
        if key == "好感度" then
            j["favor"] = value
        else
            j[key] = value
        end
    end
    local json_encode = Json.encode(j)
    local res
    res, Str = http.post(url .. "set" .. routers[filename], json_encode)
    if not res then
        error("网络异常")
    end
    res = Json.decode(Str)
    if not res.succ then
        error(qq .. "的post接口异常" .. res.err_msg)
    end
end

-- 文件名,qq,{key},{default} key和default相同索引处一一对应/qq,key,default
function GetUserConf(filename, qq, key, default)
    qq = tostring(qq)
    --! 参数不足判断
    if (default == nil) then
        error("GetUserConf arg#4 default==nil")
    end
    --! 拼写错误判断
    if (filename == "stroyConf") then
        error("spelling mistake in GetUserConf arg#1 filename")
    end
    local succ
    succ, Str = http.get(url .. "get" .. routers[filename] .. "/" .. qq)
    if not succ then
        error("网络异常")
    end
    --! 捕获异常'
    local j = Json.decode(Str)
    if not j.succ then
        error(qq .. "的get请求调用失败！" .. j.err_msg)
    end
    j = j.data or "{}"
    if not succ then
        error("『×警告！』用户" .. qq .. "数据文件" .. filename .. "出错!")
    end
    -- 多值传入
    if (type(key) == "table" and type(default) == "table") then
        -- 单值读取
        -- 存放返回值表
        local res = key
        for k, v in ipairs(key) do
            local v_now = v
            if v == "好感度" then
                v_now = "favor"
            end
            if (j[v_now] == nil) then
                res[k] = default[k]
            else
                res[k] = j[v_now]
            end
        end
        -- unpack res表,统一返回所有值
        return table.unpack(res)
    else
        if key == "好感度" then
            key = "favor"
        end
        if (j[key] == nil) then
            return default
        else
            return j[key]
        end
    end
end

-- group,{key},{default} key和default相同索引处一一对应/group,key,default
function GetGroupConf(group, key, default)
    -- 判断是否为群聊
    if (group == "0") then
        return nil
    end
    group = tostring(group)
    local f1 = assert(io.open(GroupConfPath, "r"))
    local str = f1:read("a")
    f1:close()
    if (#str == 0) then
        str = "{}"
    end
    local j = Json.decode(str)
    if (type(key) == "table" and type(default) == "table") then
        -- 单值读取
        -- 存放返回值表
        local res = key
        for k, v in ipairs(key) do
            -- 判断顺序不可交换
            if (j[group] == nil or j[group][v] == nil) then
                res[k] = default[k]
            else
                res[k] = j[group][v]
            end
        end
        -- unpack res表,统一返回所有值
        return table.unpack(res)
    else
        if (j[group] == nil or j[group][key] == nil) then
            return default
        else
            return j[group][key]
        end
    end
end

-- group,{key},{value} key和value相同索引处一一对应/group,key,value
function SetGroupConf(group, key, value)
    group = tostring(group)
    -- 判断是否为群聊
    if (group == "0") then
        return ""
    end
    local f1 = assert(io.open(GroupConfPath, "r"))
    local str = f1:read("a")
    f1:close()
    if (#str == 0) then
        str = "{}"
    end
    local j = Json.decode(str)
    if (j[group] == nil) then
        j[group] = {}
    end
    -- 对密集的写入支持列表以提高效率
    if (type(key) == "table" and type(value) == "table") then
        -- 按顺序遍历表，写入
        for k, v in ipairs(key) do
            j[group][v] = value[k]
        end
    else
        j[group][key] = value
    end
    local json_encode = Json.encode(j)
    local f2 = assert(io.open(GroupConfPath, "w"))
    f2:write(json_encode)
    f2:close()
end

-- qq,{key},{default} key和default相同索引处一一对应/qq,key,default
function GetUserToday(qq, key, default)
    qq = tostring(qq)
    local f1 = assert(io.open(UserTodayPath, "r"))
    local str = f1:read("a")
    f1:close()
    if (#str == 0) then
        str = "{}"
    end
    local j = Json.decode(str)
    -- 对密集读取支持列表以提高效率
    if (type(key) == "table" and type(default) == "table") then
        -- 单值读取
        -- 存放返回值表
        local res = key
        for k, v in ipairs(key) do
            -- 判断顺序不可交换
            if (j[qq] == nil or j[qq][v] == nil) then
                res[k] = default[k]
            else
                res[k] = j[qq][v]
            end
        end
        -- unpack res表,统一返回所有值
        return table.unpack(res)
    else
        if (j[qq] == nil or j[qq][key] == nil) then
            return default
        else
            return j[qq][key]
        end
    end
end

-- qq,{key},{value} key和value相同索引处一一对应/qq,key,value
function SetUserToday(qq, key, value)
    qq = tostring(qq)
    local f1 = assert(io.open(UserTodayPath, "r"))
    local str = f1:read("a")
    f1:close()
    if (#str == 0) then
        str = "{}"
    end
    local j = Json.decode(str)
    -- 若不存在当前qq配置项
    if (j[qq] == nil) then
        j[qq] = {}
    end
    -- 对密集的写入支持列表以提高效率
    if (type(key) == "table" and type(value) == "table") then
        -- 按顺序遍历表，写入
        for k, v in ipairs(key) do
            j[qq][v] = value[k]
        end
    else
        j[qq][key] = value
    end
    local json_encode = Json.encode(j)
    local f2 = assert(io.open(UserTodayPath, "w"))
    f2:write(json_encode)
    f2:close()
end

function ReadItem()
    local f = assert(io.open(getDiceDir() .. "/plugin/Reply/item.json", "r"))
    local str = f:read("a")
    f:close()
    local j = Json.decode(str)
    return j
end
