msg_order = {}

-- 614671889定制喵喵reply
function nya(msg)
    local p = ranint(1, 100)
    if msg.fromQQ ~= "614671889" or p >= 70 then
        return ""
    end
    local cnt, reply = 0, ""
    if p <= 10 then
        cnt = ranint(50, 100)
    else
        cnt = ranint(1, 25)
    end
    for i = 1, cnt do
        reply = reply .. "喵"
    end
    return reply
end
