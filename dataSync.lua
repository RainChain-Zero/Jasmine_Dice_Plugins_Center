--[[
    @author RainChain-Zero
    @version 0.1
    @Created 2022/03/08 20:35
    @Last Modified 2022/02/03 19:57
    ]] 

local Json=require "json"

--读取json文件
local f=assert(getDiceDir().."/user/UserConf.json","r+")
local g=assert(getDiceDir().."/user/GroupConf.json","r+")
local str=f:read("a")
local strg=g:read("a")
--转lua表
local j=Json.decode(str)
local jg=Json.decode(strg)

function SetUserConf(qq,key,value)
   j[qq][key]=value
   local res=Json.encode(j)
   f:write(res)
   f:close()
   g:close()
end

function GetUserConf(qq,key,defult)
   if (j[qq][key]==nil) then
      f:close()
      g:close()
      return defult
   end
   f:close()
   g:close()
   return j[qq][key]
end

function GetGroupConf(group,key,defult)
   if (jg[group][key]==nil) then
      f:close()
      g:close()
      return defult
   end
   f:close()
   g:close()
   return jg[group][key]
end

function SetGroupConf(group,key,value)
   jg[group][key]=value
   local res=Json.encode(jg)
   g:write(res)
   f:close()
   g:close()
end
function DataSync(msg)

   if(getUserConf(msg.frommsg.fromQQ,"dataSync",0)==0)then
      j[msg.fromQQ]["noticemsg.fromQQ"]=getUserConf(msg.fromQQ,"noticemsg.fromQQ",0)
      j[msg.fromQQ]["favorVersion"]=getUserConf(msg.fromQQ,"favorVersion",0)
      j[msg.fromQQ]["trust_flag"]=getUserConf(msg.fromQQ,"trust_flag",0)
      j[msg.fromQQ]["month_last"]=getUserConf(msg.fromQQ,"month_last",10)
      j[msg.fromQQ]["day_last"]=getUserConf(msg.fromQQ,"day_last",1)
      j[msg.fromQQ]["hour_last"]=getUserConf(msg.fromQQ,"hour_last",23)
      j[msg.fromQQ]["year_last"]=getUserConf(msg.fromQQ,"year_last",2021)
      j[msg.fromQQ]["好感度"]=getUserConf(msg.fromQQ,"好感度",0)
      j[msg.fromQQ]["gifts"]=getUserConf(msg.fromQQ,"gifts",0)
      j[msg.fromQQ]["addFavorDDL_Cookie"]=getUserConf(msg.fromQQ,"addFavorDDL_Cookie",0)
      j[msg.fromQQ]["addFavorDDLFlag_Cookie"]=getUserConf(msg.fromQQ,"addFavorDDLFlag_Cookie",1)
      j[msg.fromQQ]["favorTimePunishDownDDL"]=getUserConf(msg.fromQQ,"favorTimePunishDownDDL",0)
      j[msg.fromQQ]["favorTimePunishDownRate"]=getUserConf(msg.fromQQ,"favorTimePunishDownRate",0)
      j[msg.fromQQ]["favorTimePunishDownDDLFlag"]=getUserConf(msg.fromQQ,"favorTimePunishDownDDLFlag",1)
      j[msg.fromQQ]["entryCheckStory"]=getUserConf(msg.fromQQ,"entryCheckStory",-1)
      j[msg.fromQQ]["isStory1Unlocked"]=getUserConf(msg.fromQQ,"isStory1Unlocked",0)
      j[msg.fromQQ]["isShopUnlocked"]=getUserConf(msg.fromQQ,"isShopUnlocked",0)
      j[msg.fromQQ]["itemRequest"]=getUserConf(msg.fromQQ,"itemRequest","nil")
      j[msg.fromQQ]["isInGroup"]=getUserConf(msg.fromQQ,"isInGroup",0)
      j[msg.fromQQ]["tradeReceive1"]=getUserConf(msg.fromQQ,"tradeReceive1",0)
      j[msg.fromQQ]["tradeReceive2"]=getUserConf(msg.fromQQ,"tradeReceive2",0)
      j[msg.fromQQ]["tradeRequest1"]=getUserConf(msg.fromQQ,"tradeRequest1",0)
      j[msg.fromQQ]["tradeRequest2"]=getUserConf(msg.fromQQ,"tradeRequest2",0)
      j[msg.fromQQ]["ismsg.fromQQBiggerThanNine"]=getUserConf(msg.fromQQ,"ismsg.fromQQBiggerThanNine","n")
      j[msg.fromQQ]["itemRequestNum"]=getUserConf(msg.fromQQ,"itemRequestNum",0)
      j[msg.fromQQ]["itemReceiveNum"]=getUserConf(msg.fromQQ,"itemReceiveNum",0)
      j[msg.fromQQ]["itemReceive"]=getUserConf(msg.fromQQ,"itemReceive","nil")
      j[msg.fromQQ]["FL"]=getUserConf(msg.fromQQ,"FL",0)
      j[msg.fromQQ]["雪花糖"]=getUserConf(msg.fromQQ,"雪花糖",0)
      j[msg.fromQQ]["袋装曲奇"]=getUserConf(msg.fromQQ,"袋装曲奇",0)
      j[msg.fromQQ]["快乐水"]=getUserConf(msg.fromQQ,"快乐水",0)
      j[msg.fromQQ]["pocky"]=getUserConf(msg.fromQQ,"pocky",0)
      j[msg.fromQQ]["彩虹糖"]=getUserConf(msg.fromQQ,"彩虹糖",0)
      j[msg.fromQQ]["推理小说"]=getUserConf(msg.fromQQ,"推理小说",0)
      j[msg.fromQQ]["梦的开始"]=getUserConf(msg.fromQQ,"梦的开始",0)
      j[msg.fromQQ]["未言的期待"]=getUserConf(msg.fromQQ,"未言的期待",0)
      j[msg.fromQQ]["永恒之戒"]=getUserConf(msg.fromQQ,"永恒之戒",0)
      j[msg.fromQQ]["MainIndex"]=getUserConf(msg.fromQQ,"MainIndex",1)
      j[msg.fromQQ]["Option"]=getUserConf(msg.fromQQ,"Option",0)
      j[msg.fromQQ]["Choice"]=getUserConf(msg.fromQQ,"Choice",0)
      j[msg.fromQQ]["ChoiceIndex"]=getUserConf(msg.fromQQ,"ChoiceIndex",1)
      j[msg.fromQQ]["StroyReadNow"]=getUserConf(msg.fromQQ,"StroyReadNow",-1)
      j[msg.fromQQ]["SpecialReadNow"]=getUserConf(msg.fromQQ,"SpecialReadNow",-1)
      j[msg.fromQQ]["NextOption"]=getUserConf(msg.fromQQ,"NextOption",1) 
      j[msg.fromQQ]["ChoiceSelected0"]=getUserConf(msg.fromQQ,"ChoiceSelected0",0)
      j[msg.fromQQ]["isStory0Read"]=getUserConf(msg.fromQQ,"isStory0Read",0)
      j[msg.fromQQ]["isSpecial0Read"]=getUserConf(msg.fromQQ,"isSpecial0Read",0)
      j[msg.fromQQ]["Special0Option3"]=getUserConf(msg.fromQQ,"Special0Option3",1)
      j[msg.fromQQ]["Special0Flag"]=getUserConf(msg.fromQQ,"Special0Flag",0)
      j[msg.fromQQ]["isMessageSent"]=getUserConf(msg.fromQQ,"isMessageSent",0)
      j[msg.fromQQ]["isStory1Unlocked"]=getUserConf(msg.fromQQ,"isStory1Unlocked",0)
      j[msg.fromQQ]["actionRoundLeft"]=getUserConf(msg.fromQQ,"actionRoundLeft",4)
      j[msg.fromQQ]["isShopUnlocked"]=getUserConf(msg.fromQQ,"isShopUnlocked",0)
      j[msg.fromQQ]["isStory1Option1Choice3"]=getUserConf(msg.fromQQ,"isStory1Option1Choice3",-1)

      --转码保存
      local res=Json.encode(j)
      f:write(res)
      --所有数据同步完成
      setUserConf(msg.fromQQ,"dataSync",1)
   end
   --群配置同步
   if (msg.fromGroup~="0") then
      if (getGroupConf(msg.fromGroup,"dataSync",0)==0) then
         jg[msg.fromGroup]["favorVersion"]=getGroupConf(msg.fromGroup,"favorVersion",0)
         jg[msg.fromGroup]["notice"]=getGroupConf(msg.fromGroup,"notice",0)

         --转码保存
         local res=Json.encode(jg)
         g:write(res)
         --所有数据同步完成
         setGroupConf(msg.fromGroup,"dataSync",1)
      end
   end
   --关闭文件
   f:close()
   g:close()
end
