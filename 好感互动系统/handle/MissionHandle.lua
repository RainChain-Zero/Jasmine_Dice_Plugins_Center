package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"
function check_mission(user_list)
    for k, _ in pairs(user_list) do
        local curiosity_gift = GetUserConf("missionConf", k, "curiosity_gift", nil)
        -- 任务未完成
        if curiosity_gift ~= nil then
            SetUserConf("missionConf", k, "curiosity_gift", nil)
            -- 5%概率失去100好感
            if ranint(1, 100) <= 5 then
                SetUserConf("favorConf", k, "好感度", GetUserConf("favorConf", k, "好感度", 0) - 100)
            end
        end
    end
end
