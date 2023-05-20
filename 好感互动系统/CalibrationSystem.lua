package.path = getDiceDir() .. "/plugin/Handle/?.lua"
require "Moodhandle"

msg_order = {}
function Calibrated()
    local reply = "『✖Error』当前时钟周期仍未结束哦"
    if (calibration >= calibration_limit) then
        if (getUserConf(getDiceQQ(), "blockCalibration", 0) == 1) then
            return "『✖Error』当前已有『校准』在进行中！"
        end
        -- 1/5概率成功,1/5概率失败,3/5概率普通成功
        local res, calibration_list = ranint(1, 5), getUserConf(getDiceQQ(), "calibration_list", {})
        --! 阻塞后续校准
        setUserConf(getDiceQQ(), "blockCalibration", 1)
        --成功
        if (res == 1) then
            for k, v in pairs(calibration_list) do
                if (v > 0) then
                    local favor, affinity = GetUserConf("favorConf", k, {"好感度", "affinity"}, {0, 0})
                    CheckFavor(k, favor, favor + v, affinity)
                end
            end
            reply = "叮——一次完美的校准！茉莉看起来很开心，新的周期已经开始"
        elseif (res == 5) then
            for k, v in pairs(calibration_list) do
                local favor = GetUserConf("favorConf", k, "好感度", 0)
                if (v > 0) then
                    SetUserConf("favorConf", k, "好感度", favor - (v + (calibration_limit - 12)))
                else
                    SetUserConf("favorConf", k, "好感度", favor + v - (calibration_limit - 12))
                end
            end
            reply = "校准...失败了！茉莉似乎忘记了一些事情，但愿不要发生糟糕的事...新的周期已经开始"
        else
            reply = "一次成功的校准！你成功将这些记忆保存了下来，新的周期已经开始"
        end
        -- 更新用户心情
        update_mood_list(calibration_list)

        setUserConf(getDiceQQ(), "calibration_list", {})
        setUserConf(getDiceQQ(), "calibration", 0)
        setUserConf(getDiceQQ(), "calibration_limit", 12)
        setUserConf(getDiceQQ(), "blockCalibration", 0)
    end
    return reply
end
msg_order["茉莉校准"] = "Calibrated"

function ClearCalibratedBlock(msg)
    setUserConf(getDiceQQ(), "blockCalibration", 0)
    return "成功清除校准阻塞"
end
msg_order["清除校准阻塞"] = "ClearCalibratedBlock"

admin_order9 = "设置校准 "
function setCaribration(msg)
    local num = string.match(msg.fromMsg, "^[%s]*(%d*)", #admin_order9 + 1)
    if (num == "") then
        return "请输入正确的参数×"
    end
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        setUserConf(getDiceQQ(), "calibration", num * 1)
        return "权限确认：已将当前校准值设置为" .. num
    end
end
msg_order[admin_order9] = "setCaribration"

admin_order10 = "设置校准上限 "
function setCaribrationLimit(msg)
    local num = string.match(msg.fromMsg, "^[%s]*(%d*)", #admin_order10 + 1)
    if (num == "") then
        return "请输入正确的参数×"
    end
    if (msg.fromQQ == "3032902237" or msg.fromQQ == "2677409596" or msg.fromQQ == "2225336268") then
        setUserConf(getDiceQQ(), "calibration_limit", num * 1)
        return "权限确认：已将当前校准上限设置为" .. num
    end
end
msg_order[admin_order10] = "setCaribrationLimit"
