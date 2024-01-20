function merge_table(ori, new)
    for _, v in pairs(new) do
        table.insert(ori, v)
    end
    return ori
end

function search_keywords(str, keywords)
    for k, v in ipairs(keywords) do
        if type(str) == "string" and str:find(v) then
            return k
        elseif type(str) == "number" and str == v then
            return k
        end
    end
    return false
end

--! 获取字符串第一个UTF-8字符
function getNickFirst(qq, str)
    return str:gsub("{nickFirst}", getUserConf(qq, "nick", "笨蛋"):match("[%z\1-\127\194-\244][\128-\191]*"))
end

-- 构造发送卡片
function build_music_card(qq, type, id)
    local req = {
        ["qq"] = qq,
        ["type"] = type,
        ["id"] = id
    }
    http.post("http://localhost:8083/musicCard", Json.encode(req))
end

-- 获取qq头像
function get_avatar(qq)
    return "[CQ:image,url=http://q1.qlogo.cn/g?b=qq&nk=" .. qq .. "&s=640]"
end

-- 字符串分割函数
function split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray, nSeparatorArray = {}, {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        --nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nFindStartIndex = nFindLastIndex + 1
        nSeparatorArray[nSplitIndex] = string.sub(szFullString, nFindLastIndex, nFindLastIndex)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray, nSeparatorArray
end

function get_random_gift()
    package.path = getDiceDir() .. "/plugin/IO/?.lua"
    require "IO"
    local item = ReadItem()
    local gift = {}
    for k, v in pairs(item) do
        if v.gift == nil then
            gift[#gift + 1] = k
        end
    end
    return gift[ranint(1, #gift)]
end

function at_user(qq)
    return "[CQ:at,qq=" .. qq .. "]"
end

function build_voice(file)
    return "[CQ:record,file=/record/" .. file .. "]"
end

function build_image(file)
    return "[CQ:image,file=/image/" .. file .. "]"
end

-- 较长的剧情只能同时固定人数观看，返回true表示可以观看，false表示不可以观看
function story_queue(story_name, qq, max_num, timeout)
    qq = tostring(qq)
    -- 如果观看人较长时间（10分钟）未操作，则清除
    timeout = timeout or 600
    -- setUserConf(getDiceQQ(), "storyQueue", {})
    -- return false
    --[[
        {
            ["story_name"]={
                ["qq"] = time
            }
        }
]]
    local queue_all = read_queue()
    local queue = queue_all[story_name] or {}
    -- 标记本人是否在观看队列中
    local is_in_queue = false
    -- 计算表长
    local count = 0
    for k, v in pairs(queue) do
        if k == qq then
            is_in_queue = true
        elseif os.time() - v > timeout then
            table.remove(queue, k)
            count = count - 1
        end
        count = count + 1
    end
    if not is_in_queue and count >= max_num then
        return false
    end
    queue[qq] = os.time()
    queue_all[story_name] = queue
    write_queue(queue_all)
    return true
end

function read_queue()
    QUEUE_PATH = getDiceDir() .. "/user/Queue.json"
    local f = assert(io.open(QUEUE_PATH, "r"))
    local str = f:read("a")
    f:close()
    if (#str == 0) then
        str = "{}"
    end
    local j = Json.decode(str)
    return j
end

function write_queue(queue)
    QUEUE_PATH = getDiceDir() .. "/user/Queue.json"
    local json_encode = Json.encode(queue)
    local f = assert(io.open(QUEUE_PATH, "w"))
    f:write(json_encode)
    f:close()
end
