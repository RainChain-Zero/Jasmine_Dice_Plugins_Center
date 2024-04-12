--[[
    @Author RainChain-Zero
    @Version 2.1
    @Last Modified 2024/02/24
    @Description：适用于方舟泰拉trpg的规则检定
]]
---@diagnostic disable: lowercase-global, assign-type-mismatch, cast-local-type
msg_order = {}
order_kng = ".rk"
msg_order[order_kng] = "ark_main"

at_cq = "%[CQ:at,id=(%d+)%]"
BASIC_ATTR = {
   ["欺诈，乔装，潜行，调查，觉察，追踪"] = "精神意志",
   ["声乐，艺术，心理，游说，取悦，威吓"] = "个人魅力",
   ["妙手，急救，驾驶，杂耍，短兵，暗器，弓弩，身法"] = "反应机动",
   ["长兵，刀剑，钝器，格斗，软兵，拳术，盾术"] = "物理强度",
   ["兵械操作，生物驯养，军事理论，领导力，自然学，工程学，医药学，源石学，社会学，政法学，经管学，神秘学，机械工程，电子工程，农林牧渔，加工工艺"] = "经验智慧"
}

objTemp, obj, num, sign, add = "", "", "", "", ""

function ark_main(msg)
   --将前缀符号均统一为"."
   local str = msg.fromMsg:gsub("^。", ".")
   -- 判断是.rk还是.rka
   local isrka, at_qq = false, nil
   -- 判断是否.rkc和可能的dc
   local isrkc, dc = false, nil
   -- 判断是否是rkd和骰面
   local isrkd, dice = false, nil
   if msg.fromMsg:match("^.rka") then
      isrka = true
      -- 获取rka的at_qq
      at_qq = str:match(at_cq)
      --去掉"a"
      str = str:gsub("^.rka", ".rk")
   end
   if msg.fromMsg:match("^.rkc") then
      isrkc = true
      -- 获取rkc的dc
      dc = str:match("/%s*(%d+)")
      --去掉"c"
      str = str:gsub("^.rkc", ".rk")
   end
   if msg.fromMsg:match("^.rkd") then
      isrkd = true
      -- 获取rkd的骰面和dc(dice/dc)
      dice, dc = str:match("(%d+)%s*/%s*(%d+)")
      -- 获取可能的at_qq
      at_qq = str:match(at_cq)
      --去掉"d"
      str = str:gsub("^.rkd", ".rk")
   end
   -- 去掉可能的at_qq
   str = str:gsub(at_cq, "")
   -- 去掉可能的dice和dc
   str = str:gsub("%d*%s*/%s*%d+", "")

   local res, round = "", 1
   str, round = ark_multi(str)
   if round > 10 then
      return "诶诶诶？{self}这可要丢到什么时候呀..."
   end
   -- 联合检定判定(用&分割)
   local ark_union = split(str, "&")
   local isunion = #ark_union > 1
   for i = 1, round do
      if isunion then
         if i ~= 1 then
            res = res .. "\n\n"
         end
         res = res .. "{pc}进行ark的联合检定——\n"
      end
      local res_final = true
      for j = 1, #ark_union do
         local union_item = ark_union[j]
         if j ~= 1 then
            union_item = ".rk " .. union_item
         end
         local res_now = ark_check(msg, union_item, isrka, at_qq, isrkc, dc, isrkd, dice)
         -- 修改多次检定的剩余结果抬头
         if not isunion and i ~= 1 then
            res_now = res_now:gsub("{pc}进行ark的(.*)检定:", "")
         elseif isunion then
            res_now = "\n" .. res_now
         end
         -- 有一项检定失败则最终结果为失败
         if res_now:find("Failure") ~= nil or res_now:find("Fumble") ~= nil then
            res_final = false
         end
         res = res .. res_now
         -- 判断联合检定最终结果
         if isunion and j == #ark_union then
            res = res .. "\n\n"
            if not res_final then
               res = res .. "最终结果为——失败了...没有关系的哦~相信你一定能找到解决办法的！"
            else
               res = res .. "最终结果...成功啦!{self}就相信{nick}一定没问题的！"
            end
         end
      end
   end
   return res
end

-- 处理多轮检定,返回处理后的指令内容和多轮检定轮数
function ark_multi(str)
   local round = str:match("(%d+)%s*#")
   if not round then
      return str, 1
   end
   return str:gsub("%d+%s*#", ""), round * 1
end

-- 处理修正值,格式为xdy+z
function ark_mod(str)
   -- 通过+、-号分割字符串
   local num, op = split(str, "[%+%-]")
   local res = cal_mod(num[1])
   for i = 1, #num - 1 do
      if op[i] == "+" then
         res = res + cal_mod(num[i + 1])
      else
         res = res - cal_mod(num[i + 1])
      end
   end
   return res
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

-- 计算各个修正项的值
function cal_mod(mod)
   local mod_now = 0
   if not mod:find("[dD]") then
      mod_now = tonumber(mod)
      --log(type(mod_now))
      if type(mod_now) == "number" then
         return mod_now
      else
         return 0
      end
   end
   local x, y = mod:match("(%d+)[dD]+(%d+)")
   if not x or not y then
      return 0
   end
   for i = 1, x do
      mod_now = mod_now + ranint(1, y)
   end
   return mod_now
end

function ark_check(msg, str, isrka, at_qq, isrkc, dc, isrkd, dice)
   -- rka ac
   local ac, res_rka = 0, ""
   if isrka and at_qq then
      ac = getPlayerCardAttr(at_qq, msg.gid, "反应", 0)
      res_rka = "\n（反应=" .. string.format("%.0f）", ac)
   end
   --提取参数
   objTemp, num, sign = str:match("[%s]*([^%s^%d^%+^%-]*)[%s]*(%d*)[%s]*([%+|%-]?)", #order_kng + 1)
   --判断合法性
   if (objTemp == "" or objTemp == nil) then
      return "请输入正确的检定条目哦"
   end
   --判断是否存在难度条目，如果存在，返回true和难度条目
   local flag, hardness = false, ""
   flag, hardness = HardnessCheck()
   --如果不存在难度条目，检定条目就为objTemp去掉可能的修订条目
   if (not flag) then
      obj = objTemp:match("([^%s^%d^%+^%-]*)[%+|%-]?")
   else
      --如果存在难度条目，此时hardness即为难度条目，提取检定条目
      obj = objTemp:match(hardness .. "([^%s^%d^%+^%-]*)[%+|%-]?")
   end
   --侦查和侦察统一
   if (obj == "侦查") then
      obj = "侦察"
   end
   local sign_judge = type(sign) == "string" and (sign ~= "" and sign ~= nil)
   -- 处理修正值
   if sign_judge then
      add = ark_mod(str:match(sign .. "(.*)"))
   end

   --不存在即时检定也无修订值
   if ((type(num) == "string" and (num == "" or num == nil)) and not sign_judge) then
      --存在即时检定但无修订值
      --! 已知问题：如果检定条目为“力量”，将会取出nil
      num = getPlayerCardAttr(msg.uid, msg.gid, obj, 0)

      if (num == nil) then
         return ""
      end
      num = num - ac
      if (num * 1 == 0) then
         return "未设定" .. obj .. "技能值×"
      end
   elseif (type(num) == "string" and (num ~= "" and num ~= nil) and not sign_judge) then
      --不存在即时检定但有修订值
      num = num * 1 - ac
   elseif (type(num) == "string" and (num == "" or num == nil) and sign_judge) then
      --既有即时检定又有修订值
      if (sign == "+") then
         num = getPlayerCardAttr(msg.uid, msg.gid, obj, 0) - ac + add * 1
         if (num <= 0) then
            return "成功率<=0，这样可成功不了哦？"
         end
      elseif (sign == "-") then
         num = getPlayerCardAttr(msg.uid, msg.gid, obj, 0) - ac - add * 1
         if (num <= 0) then
            return "成功率<=0，这样可成功不了哦？"
         end
      else
         return "Error，错误的修订符"
      end
   elseif (type(num) == "string" and (num ~= "" or num ~= nil) and sign_judge) then
      if (sign == "+") then
         num = num * 1 - ac + add * 1
         if (num <= 0) then
            return "成功率<=0，这样可成功不了哦？"
         end
      elseif (sign == "-") then
         num = num * 1 - ac - add * 1
         if (num <= 0) then
            return "成功率<=0，这样可成功不了哦？"
         end
      else
         return "Error 错误的修订符"
      end
   else
      return "Error，检定输入有误"
   end
   -- 如果是rkc检定
   if isrkc then
      return rkc(msg, dc)
   end
   -- 如果是rkd检定
   if isrkd then
      return rkd(msg, dice, dc, at_qq)
   end
   --开始检定
   res = ranint(1, 100)
   --如果没有添加难度条目
   if (hardness == "") then
      return NormalJudge() .. res_rka
   else
      --设定了难度条目的情况
      return Hardness[hardness]() .. res_rka
   end
end

--检测难度条目
function HardnessCheck()
   for k, _ in pairs(Hardness) do
      if (objTemp:find(k) ~= nil) then
         return true, k
      end
   end
   return false, ""
end

--没有增加难度条目的情况
function NormalJudge()
   if (res <= 5) then
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" ..
               "\nD100" ..
                  "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strCriticalSuccess}"
   elseif (res <= num - 40) then
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" ..
               "\nD100" ..
                  "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollExtremeSuccess}"
   elseif (res <= num - 25) then
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" ..
               "\nD100" ..
                  "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollHardSuccess} "
   elseif (res <= num - 10) then
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" .. "\nD100" .. "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，是较难成功，还可以吧"
   elseif (res <= num) then
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" ..
               "\nD100" ..
                  "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollRegularSuccess}"
   elseif (res <= 95) then
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" ..
               "\nD100" .. "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollFailure}"
   else
      reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:" ..
               "\nD100" .. "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollFumble}"
   end
   return reply
end

--增加了难度条目的检定
Hardness = {
   ["较难"] = function()
      if (res <= 5) then
         reply =
            "{pc}进行ark的较难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strCriticalSuccess}"
      elseif (res <= num - 40) then
         reply =
            "{pc}进行ark的较难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" ..
                        string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollExtremeSuccess}"
      elseif (res <= num - 25) then
         reply =
            "{pc}进行ark的较难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollHardSuccess} "
      elseif (res <= num - 10) then
         reply =
            "{pc}进行ark的较难" ..
            obj ..
               "检定:" ..
                  "\nD100" .. "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，是较难成功，还可以吧"
      elseif (res <= 95) then
         reply =
            "{pc}进行ark的较难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollFailure}"
      else
         reply =
            "{pc}进行ark的较难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollFumble}"
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
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strCriticalSuccess}"
      elseif (res <= num - 40) then
         reply =
            "{pc}进行ark的困难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" ..
                        string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollExtremeSuccess}"
      elseif (res <= num - 25) then
         reply =
            "{pc}进行ark的困难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollHardSuccess}"
      elseif (res <= 95) then
         reply =
            "{pc}进行ark的困难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollFailure}"
      else
         reply =
            "{pc}进行ark的困难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollFumble}"
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
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strCriticalSuccess}"
      elseif (res <= num - 40) then
         reply =
            "{pc}进行ark的极难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" ..
                        string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollExtremeSuccess}"
      elseif (res <= 95) then
         reply =
            "{pc}进行ark的极难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollFailure}"
      else
         reply =
            "{pc}进行ark的极难" ..
            obj ..
               "检定:" ..
                  "\nD100" ..
                     "=" .. string.format("%.0f", res) .. "/" .. string.format("%.0f", num) .. "，{strRollFumble}"
      end
      return reply
   end,
   ["普通"] = NormalJudge,
   ["一般"] = NormalJudge
}

-- rkc检定，技能值d6+基础属性值和dc比较
function rkc(msg, dc)
   local res, random, basic_attr_value, res
   -- 判断是否是基础属性
   local basic_attr_input = is_basic_attr(obj)
   if basic_attr_input then
      basic_attr_value = getPlayerCardAttr(msg.uid, msg.gid, basic_attr_input, 0)
      res = ndm(basic_attr_value, 6)
   else
      --获取技能对应的基础属性
      local basic_attr = find_basic_attr(obj)
      if not basic_attr then
         return "未找到对应的基础属性，请检查技能名是否正确"
      end
      random = ndm(num, 6)
      basic_attr_value = getPlayerCardAttr(msg.uid, msg.gid, basic_attr, 0)
      -- 技能值d6+基础属性值
      res = random + basic_attr_value
   end
   -- 没有dc
   if not dc then
      if basic_attr_input then
         return "{pc}进行ark的" .. obj .. "检定:\n" .. basic_attr_value .. "d6=" .. res .. "，希望你成功吧"
      end
      return "{pc}进行ark的" .. obj .. "检定:\n" .. num .. "d6+" .. basic_attr_value .. "=" .. res .. "，希望你成功吧"
   end
   dc = tonumber(dc)
   if res >= dc then
      if basic_attr_input then
         return "{pc}进行ark的" ..
            obj .. "检定:\n" .. basic_attr_value .. "d6=" .. res .. "/" .. dc .. "，{strRollRegularSuccess}"
      end
      return "{pc}进行ark的" ..
         obj .. "检定:\n" .. num .. "d6+" .. basic_attr_value .. "=" .. res .. "/" .. dc .. "，{strRollRegularSuccess}"
   else
      if basic_attr_input then
         return "{pc}进行ark的" .. obj .. "检定:\n" .. basic_attr_value .. "d6=" .. res .. "/" .. dc .. "，{strRollFailure}"
      end
      return "{pc}进行ark的" ..
         obj .. "检定:\n" .. num .. "d6+" .. basic_attr_value .. "=" .. res .. "/" .. dc .. "，{strRollFailure}"
   end
end

-- rkd检定，技能值d骰面+基础属性和dc比较，并将at_qq的hp减去res
function rkd(msg, dice, dc, at_qq)
   --dice和dc不为空
   if not dice or not dc then
      return "请指定骰面和dc值"
   end
   --获取技能对应的基础属性
   local basic_attr = find_basic_attr(obj)
   if not basic_attr then
      return "未找到对应的基础属性，请检查技能名是否正确"
   end
   local random = ndm(num, dice)
   local basic_attr_value = getPlayerCardAttr(msg.uid, msg.gid, basic_attr, 0)
   -- 技能值d骰面+基础属性值
   local res = random + basic_attr_value
   dc = tonumber(dc)
   if res >= dc then
      local reply =
         "{pc}进行ark的" ..
         obj ..
            "检定:\n" ..
               num ..
                  "d" .. dice .. "+" .. basic_attr_value .. "-" .. dc .. "=" .. (res - dc) .. "，{strRollRegularSuccess}"
      -- at_qq的hp减去res
      if not at_qq then
         return reply
      end
      local hp = getPlayerCardAttr(at_qq, msg.gid, "hp", 0)
      hp = hp - (res - dc)
      if hp <= 0 then
         hp = 0
         reply = reply .. "\n警告：目标hp已经归零"
      else
         reply = reply .. "\n目标hp已减少" .. (res - dc) .. "点"
      end
      setPlayerCardAttr(at_qq, msg.gid, "hp", hp)
      return reply
   else
      return "{pc}进行ark的" ..
         obj ..
            "检定:\n" .. num .. "d" .. dice .. "+" .. basic_attr_value .. "=" .. res .. "/" .. dc .. "，{strRollFailure}"
   end
end

function ndm(n, m)
   local res = 0
   for _ = 1, n do
      res = res + ranint(1, m)
   end
   return math.floor(res)
end

function find_basic_attr(str)
   for k, v in pairs(BASIC_ATTR) do
      if k:find(str) then
         return v
      end
   end
   return nil
end

-- 判断是否是基础属性
function is_basic_attr(str)
   for _, v in pairs(BASIC_ATTR) do
      if v == str then
         return v
      end
   end
   return nil
end
