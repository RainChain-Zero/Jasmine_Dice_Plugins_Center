--[[
    @author RainChain-Zero
    @version 0.1
    @Created 2022/03/09 13:11
    @Last Modified 2022/03/09 15:21
    ]] 


--定时清除今日数据
task_call = {
    clearTodayConf="clearTodayConf"
}

function clearTodayConf()
    local f=assert(io.open(getDiceDir().."/user/UserToday.json","w"))
    f:write("{}")
    f:close()
    log("用户每日数据清除成功！")
end