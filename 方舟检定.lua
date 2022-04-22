---@diagnostic disable: lowercase-global
msg_order = {}
order_kng = ".rk"
msg_order[order_kng] = "ark_check"

objTemp, obj, num, sign, add = "", "", "", "", ""
function ark_check(msg)
   --将前缀符号均统一为"."
   local str = string.gsub(msg.fromMsg, "。", ".")
   --提取参数
   objTemp, num, sign, add =
      string.match(str, "[%s]*([^%s^%d^%+^%-]*)[%s]*(%d*)[%s]*([%+|%-]?)[%s]*(%d*)", #order_kng + 1)
   --判断合法性
   if (objTemp == "" or objTemp == nil) then
      return "请输入正确的检定条目哦"
   end
   --判断是否存在难度条目，如果存在，返回true和难度条目
   local flag, hardness = false, ""
   flag, hardness = HardnessCheck()
   --如果不存在难度条目，检定条目就为objTemp去掉可能的修订条目
   if (not flag) then
      obj = string.match(objTemp, "([^%s^%d^%+^%-]*)[%+|%-]?")
   else
      --如果存在难度条目，此时hardness即为难度条目，提取检定条目
      obj = string.match(objTemp, hardness .. "([^%s^%d^%+^%-]*)[%+|%-]?")
   end
   --侦查和侦察统一
   if (obj == "侦查") then
      obj = "侦察"
   end
   --不存在即时检定也无修订值
   if ((type(num) == "string" and (num == "" or num == nil)) and (type(add) == "string" and (add == "" or add == nil))) then
      --存在即时检定但无修订值
      --! 已知问题：如果检定条目为“力量”，将会取出nil
      num = getPlayerCardAttr(msg.fromQQ, msg.fromGroup, obj, 0)

      if (num == nil) then
         return ""
      end
      --特殊条目判定
      num = num + SpecialItem()
      if (num * 1 == 0) then
         return "未设定" .. obj .. "技能值×"
      end
   elseif
      (type(num) == "string" and (num ~= "" and num ~= nil) and (type(add) == "string" and (add == "" or add == nil)))
    then
      --不存在即时检定但有修订值
      num = num * 1 + SpecialItem()
   elseif
      (type(num) == "string" and (num == "" or num == nil) and (type(add) == "string" and (add ~= "" and add ~= nil)))
    then
      --既有即时检定又有修订值
      if (sign == "+") then
         num = getPlayerCardAttr(msg.fromQQ, msg.fromGroup, obj, 0) + SpecialItem() + add * 1
         if (num <= 0) then
            return "成功率<=0，这样可成功不了哦？"
         end
      elseif (sign == "-") then
         num = getPlayerCardAttr(msg.fromQQ, msg.fromGroup, obj, 0) + SpecialItem() - add * 1
         if (num <= 0) then
            return "成功率<=0，这样可成功不了哦？"
         end
      else
         return "Error，错误的修订符"
      end
   elseif
      (type(num) == "string" and (num ~= "" or num ~= nil) and (type(add) == "string" and (add ~= "" and add ~= nil)))
    then
      if (sign == "+") then
         num = num * 1 + SpecialItem() + add * 1
         if (num <= 0) then
            return "成功率<=0，这样可成功不了哦？"
         end
      elseif (sign == "-") then
         num = num * 1 + SpecialItem() - add * 1
         if (num <= 0) then
            return "成功率<=0，这样可成功不了哦？"
         end
      else
         return "Error 错误的修订符"
      end
   else
      return "Error，检定输入有误"
   end

   --开始检定
   res = ranint(1, 100)
   --如果没有添加难度条目
   if (hardness == "") then
      return NormalJudge()
   else
      --设定了难度条目的情况
      return Hardness[hardness]()
   end
end

--检测难度条目
function HardnessCheck()
   for k, _ in pairs(Hardness) do
      if (string.find(objTemp, k) ~= nil) then
         return true, k
      end
   end
   return false, ""
end

--特殊条目+2D10判定
function SpecialItem()
   for _, v in pairs(ItemsNeed2D10) do
      if (obj == v) then
         return ranint(1, 10) + ranint(1, 10)
      end
   end
   return 0
end

--没有增加难度条目的情况
function NormalJudge()
   if (res <= 5) then
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" ..
               "\nD100" ..
                  "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "{strCriticalSuccess}"
   elseif (res <= num - 40) then
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" ..
               "\nD100" ..
                  "=" ..
                     string.format("%.0f", res) .. "/" .. string.format("%.0f", num - 40) .. "{strRollExtremeSuccess}"
   elseif (res <= num - 25) then
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" ..
               "\nD100" ..
                  "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num - 25) .. "{strRollHardSuccess} "
   elseif (res <= num - 10) then
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" ..
               "\nD100" .. "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num - 10) .. "是较难成功，还可以吧"
   elseif (res <= num) then
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" ..
               "\nD100" ..
                  "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "{strRollRegularSuccess}"
   elseif (res <= 95) then
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" ..
               "\nD100" .. "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "{strRollFailure}"
   else
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" ..
               "\nD100" .. "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "{strRollFumble}"
   end
   return reply
end

--需要2d10加值的检定项
ItemsNeed2D10 = {
   "搏斗",
   "拳术",
   "暗器",
   "刀剑",
   "杖术",
   "枪术",
   "软兵",
   "盾术",
   "重钝器",
   "弓弩",
   "投掷",
   "射击",
   "炮术",
   "爆破",
   "兵械操作",
   "无人机操作"
}

--增加了难度条目的检定
Hardness = {
   ["较难"] = function()
      if (res <= 5) then
         reply =
            "{pc}进行ark的较难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "{strCriticalSuccess}"
      elseif (res <= num - 40) then
         reply =
            "{pc}进行ark的较难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" ..
                        string.format("%.0f", res) ..
                           "/" .. string.format("%.0f", num - 40) .. "{strRollExtremeSuccess}"
      elseif (res <= num - 25) then
         reply =
            "{pc}进行ark的较难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" ..
                        string.format("%.0f", res) .. "/" .. string.format("%.0f", num - 25) .. "{strRollHardSuccess} "
      elseif (res <= num - 10) then
         reply =
            "{pc}进行ark的较难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num - 10) .. "是较难成功，还可以吧"
      elseif (res <= 95) then
         reply =
            "{pc}进行ark的较难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num - 10) .. "{strRollFailure}"
      else
         reply =
            "{pc}进行ark的较难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num - 10) .. "{strRollFumble}"
      end
      return reply
   end,
   ["困难"] = function()
      if (res <= 5) then
         reply =
            "{pc}进行ark的困难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "{strCriticalSuccess}"
      elseif (res <= num - 40) then
         reply =
            "{pc}进行ark的困难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" ..
                        string.format("%.0f", res) ..
                           "/" .. string.format("%.0f", num - 40) .. "{strRollExtremeSuccess}"
      elseif (res <= num - 25) then
         reply =
            "{pc}进行ark的困难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" ..
                        string.format("%.0f", res) .. "/" .. string.format("%.0f", num - 25) .. "{strRollHardSuccess}"
      elseif (res <= 95) then
         reply =
            "{pc}进行ark的困难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num - 25) .. "{strRollFailure}"
      else
         reply =
            "{pc}进行ark的困难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num - 25) .. "{strRollFumble}"
      end
      return reply
   end,
   ["极难"] = function()
      if (res <= 5) then
         reply =
            "{pc}进行ark的极难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "{strCriticalSuccess}"
      elseif (res <= num - 40) then
         reply =
            "{pc}进行ark的极难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" ..
                        string.format("%.0f", res) ..
                           "/" .. string.format("%.0f", num - 40) .. "{strRollExtremeSuccess}"
      elseif (res <= 95) then
         reply =
            "{pc}进行ark的极难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num - 40) .. "{strRollFailure}"
      else
         reply =
            "{pc}进行ark的极难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num - 40) .. "{strRollFumble}"
      end
      return reply
   end,
   ["普通"] = NormalJudge,
   ["一般"] = NormalJudge
}
