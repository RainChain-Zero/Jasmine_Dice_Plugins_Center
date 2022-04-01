--[[
    @author RainChain-Zero
    @version 1.0
    @Created 2022/03/31 22:04
    @Last Modified 2022/04/01 00:45
    ]] -- json.lua的路径
package.path = getDiceDir() .. "/plugin/IO/?.lua"
Json = require "json"

-- UserConf.json的路径
UserConfPath = getDiceDir() .. "\\user\\UserConf\\"
-- UserToday.json的路径
UserTodayPath = getDiceDir() .. "/user/UserToday.json"
-- GroupConf.json的路径
GroupConfPath = getDiceDir() .. "/user/GroupConf.json"

-- 文件名,qq,{key},{value} key和value相同索引处一一对应/qq,key,value
function SetUserConf(filename,qq, key, value)
    -- 读取json文件
    local f1 = io.open(UserConfPath..qq.."\\"..filename..".json", "r")
    if (not f1) then
        --! 用户数据文件初始化
        UserInit(qq)
        -- 打开创建的文件
        f1=assert(io.open(UserConfPath..qq.."\\"..filename..".json","r"))
    end
    local str = f1:read("a")
    if (#str == 0) then str = "{}" end
    local j = Json.decode(str)
    f1:close()

    local f2 = assert(io.open(UserConfPath..qq.."\\"..filename..".json", "w"))
    -- 对密集的写入支持列表以提高效率
    if (type(key) == "table" and type(value) == "table") then
        -- 按顺序遍历表，写入
        for k, v in ipairs(key) do j[v] = value[k] end
    else
        j[key] = value
    end
    f2:write(Json.encode(j))
    f2:close()
end

-- 文件名,qq,{key},{default} key和default相同索引处一一对应/qq,key,default
function GetUserConf(filename,qq, key, default)
    local f1 = io.open(UserConfPath..qq.."\\"..filename..".json", "r")
    if (not f1) then
        --! 用户数据文件初始化
        UserInit(qq)
        -- 打开创建的文件
        sendMsg("filename:"..filename.." 路径:"..UserConfPath..qq.."\\"..filename..".json",0,3032902237)
        f1=assert(io.open(UserConfPath..qq.."\\"..filename..".json","r"))
    end
    local str = f1:read("a")
    if (#str == 0) then str = "{}" end
    local j = Json.decode(str)
    f1:close()
    -- 多值传入
    if (type(key) == "table" and type(default) == "table") then
        -- 存放返回值表
        local res = key
        for k, v in ipairs(key) do
            if (j[v] == nil) then
                res[k] = default[k]
            else
                res[k] = j[v]
            end
        end
        -- unpack res表,统一返回所有值
        return table.unpack(res)
        -- 单值读取
    else
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
    if (group == "0") then return nil end
    group = tostring(group)
    local f1 = assert(io.open(GroupConfPath, "r"))
    local str = f1:read("a")
    if (#str == 0) then str = "{}" end
    local j = Json.decode(str)
    f1:close()

    if (type(key) == "table" and type(default) == "table") then
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
        -- 单值读取
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
    if (group == "0") then return "" end
    local f1 = assert(io.open(GroupConfPath, "r"))
    local str = f1:read("a")
    if (#str == 0) then str = "{}" end
    local j = Json.decode(str)
    f1:close()

    local f2 = assert(io.open(GroupConfPath, "w"))
    if (j[group] == nil) then j[group] = {} end
    -- 对密集的写入支持列表以提高效率
    if (type(key) == "table" and type(value) == "table") then
        -- 按顺序遍历表，写入
        for k, v in ipairs(key) do j[group][v] = value[k] end
    else
        j[group][key] = value
    end
    f2:write(Json.encode(j))
    f2:close()
end

-- qq,{key},{default} key和default相同索引处一一对应/qq,key,default
function GetUserToday(qq, key, default)
    qq = tostring(qq)
    local f1 = assert(io.open(UserTodayPath, "r"))
    local str = f1:read("a")
    if (#str == 0) then str = "{}" end
    local j = Json.decode(str)
    f1:close()
    -- 对密集读取支持列表以提高效率
    if (type(key) == "table" and type(default) == "table") then
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
        -- 单值读取
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
    if (#str == 0) then str = "{}" end
    local j = Json.decode(str)
    f1:close()

    local f2 = assert(io.open(UserTodayPath, "w"))
    -- 若不存在当前qq配置项
    if (j[qq] == nil) then j[qq] = {} end
    -- 对密集的写入支持列表以提高效率
    if (type(key) == "table" and type(value) == "table") then
        -- 按顺序遍历表，写入
        for k, v in ipairs(key) do j[qq][v] = value[k] end
    else
        j[qq][key] = value
    end
    f2:write(Json.encode(j))
    f2:close()
end

-- 用户数据文件初始化
function UserInit(qq)
    os.execute("mkdir "..UserConfPath..qq.."\\")
    os.execute("cd.> "..UserConfPath..qq.."\\favorConf.json")
    os.execute("cd.> "..UserConfPath..qq.."\\storyConf.json")
    os.execute("cd.> "..UserConfPath..qq.."\\itemConf.json")
    os.execute("cd.> "..UserConfPath..qq.."\\tradeConf.json")
    os.execute("cd.> "..UserConfPath..qq.."\\adjustConf.json")
end