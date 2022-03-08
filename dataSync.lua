--[[
    @author RainChain-Zero
    @version 0.1
    @Created 2022/03/08 20:35
    @Last Modified 2022/03/09 03:21
    ]] 

package.path=getDiceDir().."/plugin/dataSync/?.lua"
local Json=require "json"

function SetUserConf(qq,key,value)
   --! 必须进行这一步转换
   qq=tostring(qq)
   --读取json文件
   local f1=assert(io.open(getDiceDir().."/user/UserConf.json","r"))
   local str=f1:read("a")
   local j=Json.decode(str)
   j[qq][key]=value
   f1:close()
   local f2=assert(io.open(getDiceDir().."/user/UserConf.json","w"))
   j[qq][key]=value
   local res=Json.encode(j)
   f2:write(res)
   f2:close()
end

function GetUserConf(qq,key,defult)
   qq=tostring(qq)
   local f1=assert(io.open(getDiceDir().."/user/UserConf.json","r"))
   local str=f1:read("a")
   local j=Json.decode(str)
   f1:close()
   if (j[qq][key]==nil) then
      return defult
   end
   return j[qq][key]
end

function GetGroupConf(group,key,defult)
   --判断是否为群聊
   if(group=="0")then
      return nil
   end
   qq=tostring(group)
   local g1=assert(io.open(getDiceDir().."/user/GroupConf.json","r"))
   local strg=g1:read("a")
   local jg=Json.decode(strg)
   g1:close()
   if (jg[group][key]==nil) then
      return defult
   end
   return jg[group][key]
end

function SetGroupConf(group,key,value)
   --判断是否为群聊
   if(group=="0")then
      return ""
   end
   qq=tostring(group)
   local g1=assert(io.open(getDiceDir().."/user/GroupConf.json","r"))
   local strg=g1:read("a")
   local jg=Json.decode(strg)
   g1:close()
   local g2=assert(io.open(getDiceDir().."/user/GroupConf.json","w"))
   jg[group][key]=value
   local res=Json.encode(jg)
   g2:write(res)
   g2:close()
end


function DataSync(msg)

   if(getUserConf(msg.fromQQ,"dataSync",0)==0)then
      local f1=assert(io.open(getDiceDir().."/user/UserConf.json","r"))
      local str=f1:read("a")
      local j=Json.decode(str)
      f1:close()
      j[msg.fromQQ]={}
      j[msg.fromQQ]["noticeQQ"]=getUserConf(msg.fromQQ,"noticeQQ",0)
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
      j[msg.fromQQ]["isQQBiggerThanNine"]=getUserConf(msg.fromQQ,"isQQBiggerThanNine","n")
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
      local f2=assert(io.open(getDiceDir().."/user/UserConf.json","w"))
      f2:write(res)
      --所有数据同步完成
      setUserConf(msg.fromQQ,"dataSync",1)
      f2:close()
   end
   --群配置同步
   if (msg.fromGroup~="0") then
      if (getGroupConf(msg.fromGroup,"dataSync",0)==0) then
         local g1=assert(io.open(getDiceDir().."/user/GroupConf.json","r"))
         local strg=g1:read("a")
         local jg=Json.decode(strg)
         g1:close()
         jg[msg.fromGroup]={}
         jg[msg.fromGroup]["favorVersion"]=getGroupConf(msg.fromGroup,"favorVersion",0)
         jg[msg.fromGroup]["notice"]=getGroupConf(msg.fromGroup,"notice",0)

         --转码保存
         local res=Json.encode(jg)
         local g2=assert(io.open(getDiceDir().."/user/GroupConf.json","w"))
         g2:write(res)
         --所有数据同步完成
         setGroupConf(msg.fromGroup,"dataSync",1)
         g2:close()
      end
   end
end

function ResetSyncFlag(msg)
   setUserConf(msg.fromQQ,"dataSync",0)
   setGroupConf(msg.fromGroup,"dataSync",0)
end