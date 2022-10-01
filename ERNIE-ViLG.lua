--[[
Author: RainChain-Zero rainchain@foxmail.com
Date: 2022-09-06 13:46:15
LastEditors: RainChain-Zero rainchain@foxmail.com
LastEditTime: 2022-09-06 19:32:18
FilePath: \可可爱爱茉莉酱\ERNIE-ViLG.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
--[[
Author: RainChain-Zero rainchain@foxmail.com
Date: 2022-09-06 13:46:15
LastEditors: RainChain-Zero rainchain@foxmail.com
LastEditTime: 2022-09-06 18:47:01
FilePath: \可可爱爱茉莉酱\ERNIE-ViLG.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
--[[
    Author: RainChain-Zero rainchain@foxmail.com
    Date: 2022-09-06 13:46:15
    LastEditors: RainChain-Zero rainchain@foxmail.com
    LastEditTime: 2022-09-06 13:46:46
    Description: 基于文心大模型的AI作图
--]]
---@diagnostic disable: lowercase-global

msg_order = {
    ["/作图"] = "draw_image"
}

--! 配置文件
config = {
    --todo Api的ak和sk，登录后在https://wenxin.baidu.com/moduleApi/key申请
    api_key = "",
    secret_key = "",
    -- 是否在有任务进行时阻塞新的任务被创建
    block = true,
    -- 设定多长时间没有结果后超时退出，单位毫秒
    timeout = 5 * 60 * 1000,
    -- 一天之内调用上限（免费额度每天50次）
    limit = 50
}

DiceQQ = getDiceQQ()

Json = require "json"

function draw_image(msg)
    -- if config.block and getUserConf(DiceQQ, "wenxin_txt2img_block", 0) == 1 then
    --     return "当前有任务正在进行中，请稍后再试"
    -- end
    local txt2img_today = getUserToday(DiceQQ, "wenxin_txt2img_count", 0)
    if txt2img_today >= config.limit then
        return "今日调用次数已达上限"
    end
    local style, text = string.match(msg.fromMsg, "[%s]*(%S+)[%s]+(.+)", #"/作图" + 1)
    if not text then
        return "请检查参数是否正确，格式为：/作图 风格 描述文本"
    end
    setUserToday(DiceQQ, "wenxin_txt2img_count", txt2img_today + 1)
    setUserConf(DiceQQ, "wenxin_txt2img_block", 1)
    -- 请求access_token
    local res, access_resp =
        http.post(
        "https://wenxin.baidu.com/moduleApi/portal/api/oauth/token?grant_type=client_credentials&client_id=" ..
            config.api_key .. "&client_secret=" .. config.secret_key,
        "application/x-www-form-urlencoded"
    )
    if not res then
        return "网络异常，请检查你的网络连接"
    end
    access_resp = Json.decode(access_resp)
    if access_resp.code ~= 0 then
        return access_resp.msg
    end
    local access_token = access_resp.data
    -- 提交任务
    local task_id, submit_resp = nil, nil
    local data = {}
    data["text"] = http.urlEncode(text)
    data["style"] = http.urlEncode(style)
    --! Some problems
    res, submit_resp =
        http.post(
        "https://wenxin.baidu.com/moduleApi/portal/api/rest/1.0/ernievilg/v1/txt2img?access_token=" .. access_token,
        Json.encode(data)
    )
    if not res then
        return "网络异常，请检查你的网络连接"
    end
    log(submit_resp)
    return submit_resp
    -- submit_resp = Json.decode(submit_resp)
    -- if submit_resp.code ~= 0 then
    --     return submit_resp.msg
    -- end
end
