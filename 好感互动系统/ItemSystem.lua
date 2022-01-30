--[[
    @author 慕北_Innocent(RainChain)
    @version 1.0
    @Create 2022/01/19 11:30
    @Last Update 2022/01/21 20:51
    ]]

msg_order={}
--使用道具
function UseItem(msg)
    local reply="唔姆姆，你这是要对着空气做什么呀？"
    local num,item=string.match(msg.fromMsg,"[u,U][%s]*(%d*)[%s]*(.*)")
    if(item==nil)then
        return "请输入道具名哦~（输入“道具图鉴”可查看目前支持的所有道具）"
    end
    --数量默认为1
    if(num=="" or num==nil)then
        num=1
    end
    --道具剩余数量判断
    local flag1,flag2=UseCheck(msg,num,item)
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

--todo 道具使用合理性判断
function UseCheck(msg,num,item)
    local flag1,flag2=false,false
    --判断道具是否存在
    for k,v in pairs(ItemName)
    do
        if(string.find(item,v)~=nil)then
            flag1=true
            item=v
            break
        end
    end
    --不存在直接返回
    if(not flag1)then
        return false,false
    end
    --判断道具余量
    if(getUserConf(msg.fromQQ,item,0)*1<num)then
        return true,false
    end
    return true,true
end

--todo 解锁剧情章节
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


--todo 查询
check_order="查询"
function Check(msg)
    local item=string.match(msg.fromMsg,"[%s]*(.*)",#check_order+1)
    local flag=false
    if(item==nil or item=="")then
        return "系统：请输入要查询的条目哦~"
    end
    if(item=="好感")then
        item="好感度"
    end

    --判断道具是否存在
    for k,v in pairs(ItemName)
    do
        if(string.find(item,v)~=nil)then
            flag=true
            item=v
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
msg_order[check_order]="Check"

--todo 道具图鉴
function HandBook()
    local res=""
    local cnt=1
    for k,v in pairs(ItemName)
    do
        res=res..string.format("%.0f",cnt).."."..v.."\n"
        cnt=cnt+1
    end
    res=res.."输入“查询 道具名”以查阅具体词条"
    return res
end
msg_order["道具图鉴"]="HandBook"

--物品描述
Item=
{
    ["好感度"]="用于指示和茉莉亲密关系的重要指标，具有很高的参考价值",
    ["梦的开始"]="一把象牙白的钥匙，晶莹剔透，不知道是用什么制作的，或许能开启什么",
    ["未言的期待"]="茉莉最喜欢牌子的棒棒糖，在你向她诉说些什么时给你的，听她说棒棒糖有魔力\n效果：附加永久增益：使「打工」时间缩减10%",
    ["永恒之戒"]="泛着耀眼光芒的钻戒，传说只有纯粹和心意相通的两人才能使其绽放出流光溢彩的永恒之光吧。\n“谁也没有见过风，更别说我和你了；谁都没有见过爱情，直到有花束抛向自己”\n效果：？？？"
}

ItemName=
{
    "好感度","梦的开始","未言的期待","永恒之戒"
}