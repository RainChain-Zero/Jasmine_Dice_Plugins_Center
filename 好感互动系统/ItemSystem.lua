--[[
    @author 慕北_Innocent(RainChain)
    @version 1.1
    @Create 2022/01/19 11:30
    @Last Update 2022/01/31 20:35
    ]]

package.path=getDiceDir().."/plugin/ReplyAndDescription/?.lua"
require "itemDescription"

msg_order={}
--item为全局变量，检测合法性时不用传入
item=""
--使用道具
function UseItem(msg)
    local reply="唔姆姆，你这是要对着空气做什么呀？（部分物品需要赠送给茉莉才会触发：“赠送茉莉 数量 道具”数量不填默认为1）"
    local num=""
    num,item=string.match(msg.fromMsg,"[u,U][%s]*(%d*)[%s]*(.*)")
    if(item==nil or item=="")then
        return "请输入道具名哦~（输入“道具图鉴”可查看目前支持的所有道具）"
    end
    --数量默认为1
    if(num=="" or num==nil)then
        num=1
    end
    --道具剩余数量判断
    local flag1,flag2=UseCheck(msg,num,Item)
    if(not flag1)then
        return "咦，茉莉的数据库里似乎没有该道具呢..."
    end
    if(not flag2)then
        return "哒咩哟哒咩，超额透支是不行的！"
    end

    --? 是否用于解锁剧情章节
    local entryStoryCheck=getUserConf(msg.fromQQ,"entryCheckStory")
    if(entryStoryCheck~=-1)then
        reply=UnlockStory(msg,entryStoryCheck,item)
        setUserConf(msg.fromQQ,"entryCheckStory",-1)
    end
    
    return reply
end
msg_order[".u"]="UseItem"
msg_order[".U"]="UseItem"

--赠送茉莉礼物
gift_order="赠送茉莉"
function GiveGift(msg)
    local num=""
    num,item=string.match(msg.fromMsg,"[%s]*(%d*)[%s]*(.+)",#gift_order+1)
    if(num==""or num==nil)then
        num=1
    end
    if(item=="" or item==nil)then
        return "诶诶诶？{nick}这是要送给茉莉什么呀？是...？惊喜吗！"
    end
    --合理性判断
    local flag1,flag2=UseCheck(msg,num*1,Gift_list)
    if(not flag1)then
        return "嗯嗯嗯？这种东西还不在可选列表里哦？"
    end
    if(not flag2)then
        return "好像该礼物的剩余数量不足哦"
    end
    if(num*1>1 and item=="彩虹糖")then
        num=1
        sendMsg("注意，该道具具有随机效果，一次只能赠送一个哦",msg.fromGroup,msg.fromQQ)
    end
    --排除例外情况
    --todo 完善排除特例的情况（采用遍历排除）

    if(item~="推理小说" and item~="袋装曲奇")then
        setUserConf(msg.fromQQ,"好感度",getUserConf(msg.fromQQ,"好感度",0)+num*1*Gift_list[item].favor)
    elseif (item=="推理小说") then

        --!时间惩罚降低的好感减少百分之多少，同类不覆盖
        local rate=getUserConf(msg.fromQQ,"favorTimePunishDownRate",0)
        --更新时间，取最新时间
        setUserConf(msg.fromQQ,"favorTimePunishDownDDL",os.time()+5*24*60*60*1000)
        --! 打上标记，用做发送提醒的标记
        setUserConf(msg.fromQQ,"favorTimePunishDownDDLFlag",0)
        if (rate<0.3) then
            setUserConf(msg.fromQQ,"favorTimePunishDownRate",0.3)
        end
    elseif (item=="袋装曲奇") then

        --! 效果不会叠加,用os.time()秒级存储到期时间，更新为最新时间
        setUserConf(msg.fromQQ,"addFavorDDL_Cookie",os.time()+3*24*60*60*1000)
        --! 打上标记，用做发送提醒的标记
        setUserConf(msg.fromQQ,"addFavorDDLFlag_Cookie",0)
    end
    setUserConf(msg.fromQQ,item,getUserConf(msg.fromQQ,item,0)-num*1)
    return Gift_list[item].reply
end
msg_order[gift_order]="GiveGift"

-- 道具使用合理性判断
function UseCheck(msg,num,table)
    local flag1,flag2=false,false
    --判断道具是否存在
    for k,_ in pairs(table)
    do
        if(string.find(k,item)~=nil)then
            flag1=true
            item=k
            break
        end
    end
    --不存在直接返回
    if(not flag1)then
        return false,false
    end
    --判断道具余量
    if(getUserConf(msg.fromQQ,item,0)*1<num*1)then
        return true,false
    end
    return true,true
end

-- 解锁剧情章节
function UnlockStory(msg,entryStoryCheck,item)
    if(entryStoryCheck==1)then
        if(string.find(item,"梦的开始")~=nil)then
            setUserConf(msg.fromQQ,"entryStoryCheck",-1)
            setUserConf(msg.fromQQ,"isStory1Unlocked",1)
            return "这把钥匙似乎和眼前的光芒产生了某种共鸣，倏忽间，光芒如同被某种强大的引力吸引般瞬间汇聚于钥匙上后逐渐稳定了下来...\f"
            .."系统：注意，剧情模式第一章已经解锁！"
        else
            return "你小心翼翼地将它向那团光球接近，但就要在你触及之时，一股强大的斥力将你远远弹开了..."
        end
    end
end


-- 查询
check_order="查询"
function SearchItem(msg)
    local item=string.match(msg.fromMsg,"[%s]*(.*)",#check_order+1)
    local flag=false
    if(item==nil or item=="")then
        return "系统：请输入要查询的条目哦~"
    end
    if(item=="好感")then
        item="好感度"
    end

    --判断道具是否存在
    for k,_ in pairs(Item)
    do
        if(string.find(k,item)~=nil)then
            flag=true
            item=k
            break
        end
    end
    if(not flag)then
        return "该道具暂未被图鉴收录哦~"
    end

    local res=getUserConf(msg.fromQQ,item,0)
    sendMsg( "系统：正在检索..."..ranint(20,50).."%..."..ranint(51,80).."%...",msg.fromGroup,msg.fromQQ)
    sleepTime(1000)
    return "您目前的『"..item.."』数量为"..string.format("%0.f",res).."\n("..Item[item]..")"
end
msg_order[check_order]="SearchItem"

-- 道具图鉴
function HandBook()
    local res=""
    local cnt=1
    for k,_ in pairs(Item)
    do
        res=res..string.format("%.0f",cnt).."."..k.."\n"
        cnt=cnt+1
    end
    res=res.."输入“查询 道具名”以查阅具体词条"
    return res
end
msg_order["道具图鉴"]="HandBook"