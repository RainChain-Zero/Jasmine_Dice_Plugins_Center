function merge_table(ori, new)
    for _, v in pairs(new) do
        table.insert(ori, v)
    end
    return ori
end

function search_keywords(str, keywords)
    str = tostring(str)
    for _, v in pairs(keywords) do
        if str:find(v) then
            return true
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
