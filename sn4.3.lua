-- 于赵骰基础上改动的.sn指令 made by 32w
-- 发布更新于Dice！论坛，bot为群管理方可使用
msg_order = {}
json = require("json")

local port = 15700 -- http通信端口，用于api更新骰娘权限
local allowAuto = true -- 随跑团数据更新群名片功能的总开关，需要骰主按照教程进行相关配置之后再设置为true。教程我懒得写……很麻烦，可以来问我倒是
local version = 4.3

msg_order[".sn help"] = "sn"
msg_order[".sn"] = "sn"
function sn(msg)
    if not msg.gid then return "私聊窗口可改不了名字x" end -- 排除私聊
    local name = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", 4) -- 匹配文本
    local is_sn = getGroupConf(msg.gid, "is_sn", false)
    local info = ""

    if is_sn then -- 如果为此群第一次使用sn指令发送帮助
    else
        if name == "help" then
        else
            setGroupConf(msg.gid, "is_sn", true)
            eventMsg(".sn help", msg.gid, msg.uid)
        end
    end

    if (name and #name > 0) then -- sn后面附带有内容
        if (name == "help") then -- 显示帮助
            if (allowAuto) then
                return "于赵骰基础上改动的.sn指令 ver" .. version ..
                           " made by 32w\n发布更新于Dice！论坛，bot为群管理方可使用\n.sn   \\\\改名片，san后面的值为lastsan，第一次使用lastsan=san\n.sn init \\\\手动调用api获取最新权限信息.st lastsan 70     \\\\手动设置lastsan\n.newday             \\\\新的一天，改名片，lastsan=当前san\f{self}已支持随跑团数据实时更新群名片。\n.sn auto on  \\\\开启\n.sn auto off  \\\\关闭，默认关闭\n使用不省略空格的指令调用实时更新，如【.sc 1/1d4】【.st hp-1】可以更新，【.sc1/1d4】【.sthp-1】则不能\n（此消息会在使用【.sn help】或第一次在本群使用【.sn】时发送）"
            else
                return "于赵骰基础上改动的.sn指令 ver" .. version ..
                           " made by 32w\n发布更新于Dice！论坛，bot为群管理方可使用\n.sn   \\\\改名片，san后面的值为lastsan，第一次使用lastsan=san\n.sn init \\\\手动调用api获取最新权限信息\n.st lastsan 70     \\\\手动设置lastsan\n.newday             \\\\新的一天，改名片，lastsan=当前san\f{self}不支持随跑团数据实时更新群名片（此消息会在使用【.sn help】或第一次在本群使用【.sn】时发送）"
            end
            -- return "xxx仿照赵骰且有微小改动的.sn功能ver0.1 made by 32w\n发布于Dice！论坛，访问以获取最新版xxx\n1.使用.sn auto on开启本群随跑团数据更新群名片功能，使用.sn auto off关闭，默认关闭\n  1.1如果骰娘要开启随跑团数据自动更新功能，建议骰主①发送【.strGroupCardSet  {Formfeed}】将默认的群名片修改回执关闭\n  1.2②骰主将代码最前面修改为【local allowAuto=true】\n2.由于Dice！内部缓存机制问题，在设置骰娘群管理权限之后，需要重启骰娘才能读取权限。建议使用该插件的骰主发送【】设定每天五点重启mirai来应对。"
        elseif (name == "auto on") then
            setGroupConf(msg.fromGroup, "cardAutoUpdate", true)
            return "实时更新群名片开"
        elseif (name == "auto off") then
            setGroupConf(msg.fromGroup, "cardAutoUpdate", false)
            return "实时更新群名片关"
        elseif name == "init" then
            local get, admin = get_admin(true)
            if admin == 0 then
                return
                    "API调用失败，请检查HTTP通信是否设置成功并重启gocq。\n如果您是用户，请联系骰主。\n如果您是骰主，请仔细阅读原帖：https://forum.kokona.tech/d/1031-zhi-ling-jiao-ben-fang-zhao-de-sngong-neng-gen-ju-pao-tuan-shu-ju-shi-shi-geng-xin-qun-ming-pian/14"
            elseif admin == 1 then
                return "权限更新成功，当前权限为群员"
            elseif admin == 2 then
                return "权限更新成功，当前权限为管理员"
            elseif admin == 3 then
                return "权限更新成功，当前权限为群主"
            end
        else
            info = name
            local order = ".group card " .. msg.fromQQ .. " " .. name
            local get, admin = get_admin(false)
            eventMsg(order, msg.fromGroup, getDiceQQ())
            if get and admin == 0 then
                return "API调用失败，请尝试使用.sn init指令"
            end
        end
    else
        info = update_card(msg)
        if info == "API调用失败，请尝试使用.sn init指令。" then
            return info .. "\f{strSelfPermissionErr}"
        end
    end
    return "{self}已尝试将群名片修改为『" .. info ..
               "』，若不成功请发送『.sn help』"
end

msg_order[".newday"] = "newday"
function newday(msg)
    local lastsan = getPlayerCardAttr(msg.fromQQ, msg.fromGroup, "san", 0)
    setPlayerCardAttr(msg.fromQQ, msg.fromGroup, "lastsan", lastsan)

    update_card(msg)

    return "沙漏翻转，{pc}的lastsan值置为" .. lastsan ..
               "，新的一天到来了"
end

function check_update(msg)
    if (allowAuto) then
        if (getGroupConf(msg.fromGroup, "cardAutoUpdate", false)) then
            update_card(msg)
        end
    end
end

function update_card(msg)
    local order = ".group card " .. msg.fromQQ .. " "
    -- 获取角色卡名称
    local pcname = getPlayerCardAttr(msg.fromQQ, msg.fromGroup, "__Name",
                                     "无名朋友")
    if (pcname == "角色卡") then
        pcname = getUserConf(msg.fromQQ, "nick#" .. msg.fromGroup, "")
    end

    -- 获取当前属性
    local hp = getPlayerCardAttr(msg.fromQQ, msg.fromGroup, "hp", 0)
    local san = getPlayerCardAttr(msg.fromQQ, msg.fromGroup, "san", 0)
    local dex = getPlayerCardAttr(msg.fromQQ, msg.fromGroup, "dex", 0)

    -- 获取上限
    local maxhp = math.floor((getPlayerCardAttr(msg.fromQQ, msg.fromGroup,
                                                "体型", 0) +
                                 getPlayerCardAttr(msg.fromQQ, msg.fromGroup,
                                                   "体质", 0)) / 10)
    -- local maxsan=99-getPlayerCardAttr(msg.fromQQ, msg.fromGroup, "cm",0)

    -- 加载用户在上一次记录的san值，用以查看pc是否进入不定性疯狂，或许这会比san的上限更常用。
    -- 第一次使用sn的时候将会记录当前的san值，如果想要更改，请使用【.newday coc】或者【.st lastsan xx】指令
    -- 如果仍然希望显示san的上限，将这一块代码用--[[]]注释掉，并且将上面一行定义的maxsan前面的注释去除
    local maxsan = getPlayerCardAttr(msg.fromQQ, msg.fromGroup, "lastsan",
                                     getPlayerCardAttr(msg.fromQQ,
                                                       msg.fromGroup, "san", 99))
    setPlayerCardAttr(msg.fromQQ, msg.fromGroup, "lastsan", maxsan)
    -- 到这里为一块

    info = pcname .. " hp" .. hp .. "/" .. maxhp .. " san" .. san .. "/" ..
               maxsan .. " dex" .. dex
    local get, admin = get_admin(false)
    if get and admin == 0 then
        return "API调用失败，请尝试使用.sn init指令。"
    end
    eventMsg(order .. info, msg.fromGroup, getDiceQQ())
    print("changCardOk")
    return info
end

-- 以下部分监听.sc\.st hp\.st san指令，如果不使用实时更新角色卡功能可全部删去
msg_order[".sc "] = "sctest" -- 请注意这里.sc后面跟着的空格很重要，如果删去则会陷入无限循环
function sctest(msg)
    local rest = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", 5) -- 匹配文本
    eventMsg(".sc" .. rest, msg.fromGroup, msg.fromQQ)
    -- 执行sc，这里之所以不会陷入无限循环是因为函数只匹配有空格的sc，不匹配无空格的。算是绕了个小圈子
    sleepTime(5000) -- 确保属性修改在前，延迟更新群名片
    check_update(msg)
end

msg_order[".st hp"] = "sthp" -- 请注意这里的空格很重要，如果删去则会陷入无限循环
function sthp(msg)
    local rest = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", 7) -- 匹配文本
    eventMsg(".sthp" .. rest, msg.fromGroup, msg.fromQQ)
    sleepTime(5000)
    check_update(msg)
end

msg_order[".st san"] = "stsan" -- 请注意这里的空格很重要，如果删去则会陷入无限循环
function stsan(msg)
    local rest = string.match(msg.fromMsg, "^[%s]*(.-)[%s]*$", 8) -- 匹配文本
    eventMsg(".stsan" .. rest, msg.fromGroup, msg.fromQQ)
    sleepTime(5000)
    check_update(msg)
end

function get_admin(noCache) -- 如果接受指令时dice缓存中记录骰娘不是管理，或者输入了参数true，则会调用api来更新权限,返回两个参数，api调用是否成功与获取到的权限等级
    local admin = getGroupConf(msg.gid, "auth#" .. getDiceQQ(), 0)
    local get
    if (admin < 2) or noCache then
        get = true
        local para = {}
        para["group_id"] = msg.gid
        para["user_id"] = getDiceQQ()
        para["no_cache"] = false
        local stat, data = http.post("http://127.0.0.1:" .. port ..
                                         "/get_group_member_info",
                                     json.encode(para)) -- 访问api
        if stat then
            authority = json.decode(data)["data"]["role"]
            if authority == "owner" then
                admin = 3
            elseif authority == "admin" then
                admin = 2
            else
                admin = 1
            end
        else
            admin = 0
        end
    else
        get = false
    end
    return get, admin
end
