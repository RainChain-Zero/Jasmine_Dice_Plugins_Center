package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"
msg_order = {
    ["喵"] = "nya"
}

-- 614671889定制喵喵reply
function nya(msg)
    local p = ranint(1, 100)
    local favor = GetUserConf("favorConf", msg.fromQQ, "好感度", 0)
    if favor < 500 or p >= 60 then
        return ""
    end
    local cnt, reply = 0, ""
    if p <= 8 then
        cnt = ranint(50, 100)
    else
        cnt = ranint(1, 25)
    end
    for i = 1, cnt do
        reply = reply .. "喵"
    end
    if ranint(1, 100) <= 50 then
        local end_pot = {
            "~",
            "!",
            "？",
            "♬",
            "♫",
            "♪",
            "☆",
            "……",
            "₍˄·͈༝·͈˄*₎◞ ̑̑",
            "(˃ ⌑ ˂ഃ )",
            "(✧∇✧)",
            "( •́ω•̀ )",
            "(≧▽≦)"
        }
        reply = reply .. end_pot[ranint(1, #end_pot)]
    end
    return reply
end
