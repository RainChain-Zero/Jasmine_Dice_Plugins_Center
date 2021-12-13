--[[
    @author 慕北_Innocent(RainChain)
    @version 1.0(Beta)
    @Created 2021/12/05 00:04
    @Last Modified 2021/12/13 08:53
    ]]

msg_order={}

package.path="/home/container/Dice3349795206/plugin/FavorReply/?.lua"
require "Story"

--todo 主调入口
function StoryMain(msg)
    local Reply="系统：出现未知错误，请报告系统管理员"
    local StoryNormal=getUserConf(msg.fromQQ,"StoryReadNow",-1)
    local StorySpecial=getUserConf(msg.fromQQ,"SpecialReadNow",-1)

    --未进入剧情模式不触发
    if(StoryNormal+StorySpecial==-2)then
        return "您未进入任何剧情模式哦~"
    end

    --必须在小窗下进行
    if(msg.fromGroup~="0")then
        return "茉莉..茉莉可不想在人多的地方和你分享这些哦（脸红）"
    end

    --? 判断具体剧情
    if(StoryNormal~=-1)then
        if(StoryNormal==0)then
            Reply=StoryZero(msg)
        end
    else
        if(StorySpecial==0)then
            
        end
    end
    return Reply
end
msg_order[".f"]="StoryMain"

--todo 剧情入口点
EntryStoryOrder="进入剧情"
function EnterStory(msg)
    --清空之前所有操作
    Init(msg)
    local Story=string.match(msg.fromMsg,"[%s]*(.*)",#EntryStoryOrder+1)
    if(Story==nil or Story=="")then
        return "请输入章节名哦~"
    end
    if(Story=="序章")then
        local favor=getUserConf(msg.fromQQ,"好感度",0)
        if(favor<1000)then
            return "茉莉暂时还不想和{nick}分享这些呢..这是茉莉的小秘密哦~"
        end
        setUserConf(msg.fromQQ,"StoryReadNow",0)
        setUserConf(msg.fromQQ,"SpecialReadNow",-1)
    elseif(Story=="元旦特典")then

        --! Alpha Ver
        if(msg.fromQQ=="3032902231" or msg.fromQQ=="2677409596")then
            setUserConf(msg.fromQQ,"SpecialReadNow",0)
            setUserConf(msg.fromQQ,"StoryReadNow",-1)
        end

    end
    setUserConf(msg.fromQQ,"MainIndex",1)
    setUserConf(msg.fromQQ,"Option",0)
    return "您已进入剧情模式『"..Story.."』,请在小窗模式下输入.f一步一步进行哦~"
end
msg_order[EntryStoryOrder]="EnterStory"

--todo 配置初始化
function Init(msg)
    setUserConf(msg.fromQQ,"MainIndex",1)
    setUserConf(msg.fromQQ,"Option",0)
    setUserConf(msg.fromQQ,"Choice",0)
    setUserConf(msg.fromQQ,"StoryReadNow",-1)
    setUserConf(msg.fromQQ,"SpecialReadNow",-1)
    setUserConf(msg.fromQQ,"ChoiceSelected0",0)
end


--todo 选项选择
function Choose(msg)
    local Option =getUserConf(msg.fromQQ,"Option",0)
    local StoryNormal=getUserConf(msg.fromQQ,"StoryReadNow",-1)
    local StorySpecial=getUserConf(msg.fromQQ,"SpecialReadNow",-1)
    local ChoiceSelected=getUserConf(msg.fromQQ,"ChoiceSelected0",0)
   --未进入任何剧情模式
    if(StoryNormal+StorySpecial==-2)then
       return ""
    end
   --没有任何选项
    if(Option==0)then
        return "您现在还不能选择任何选项哦~"
    end
    
    --匹配选项
    local res=string.match(msg.fromMsg,"[%s]*(%d)",string.find(msg.fromMsg,"选择")+1)
    if(res==nil or res=="" or res*1<1 or res*1>3)then
        return "您必须输入一个有效的选项数字哦~"
    end


    --todo 不同章节一一处理
    if(StoryNormal~=-1)then
        if(StoryNormal==0)then
            if(Option==0)then
                return "您现在还不能选择任何选项哦~"
            end
            local res=string.match(msg.fromMsg,"[%s]*(%d)",string.find(msg.fromMsg,"选择")+1)
            if(res==nil or res=="" or res*1<1 or res*1>3)then
                return "您必须输入一个有效的选项数字哦~"
            end
            if(Option==2)then
                if((res*1==1 and (ChoiceSelected==1 or ChoiceSelected==4)) or (res*1==3 and (ChoiceSelected==3 or ChoiceSelected==4)))then
                    return "这个选项目前处于不可选中状态哦~"
                end
            end
            setUserConf(msg.fromQQ,"Choice",res*1)
            return "您已选择选项"..res.." 输入.f以推进"
        end
    else
        if(StorySpecial==0)then
            
        end
    end
    return ""
end
msg_order["选择"]="Choose"



--todo 具体的剧情
function StoryZero(msg)
    local MainIndex,Option,Choice=getUserConf(msg.fromQQ,"MainIndex",1),getUserConf(msg.fromQQ,"Option",0),getUserConf(msg.fromQQ,"Choice",0)
    local ChoiceIndex=getUserConf(msg.fromQQ,"ChoiceIndex",1)
    local ChoiceSelected=getUserConf(msg.fromQQ,"ChoiceSelected0",0)
    local content;
    --判断是否进入分支
    if(Option==0)then
        content=Story0[MainIndex];
        if(MainIndex==3)then
            setUserConf(msg.fromQQ,"Option",1)
        elseif(MainIndex==7)then
            setUserConf(msg.fromQQ,"Option",2)
        end
        if(MainIndex==7)then
            content=Story0[7][1]    --初发选项
        end
        MainIndex=MainIndex+1
        setUserConf(msg.fromQQ,"MainIndex",MainIndex)
        return content

        --选项1
    elseif(Option==1)then
        --未选择
        if(Choice==0)then
            return "请选择其中一个选项以推进哦~"
        end
        if(Choice==1)then
            MainIndex=4
            content=Story0[MainIndex]
            MainIndex=7
            setUserConf(msg.fromQQ,"MainIndex",MainIndex)
            setUserConf(msg.fromQQ,"Option",0)
            setUserConf(msg.fromQQ,"Choice",0)
            return content
        elseif(Choice==2)then
            MainIndex=5
            content=Story0[MainIndex][ChoiceIndex]
            ChoiceIndex=ChoiceIndex+1
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
            if(ChoiceIndex>2)then
                setUserConf(msg.fromQQ,"MainIndex",7)
                setUserConf(msg.fromQQ,"ChoiceIndex",1)
                setUserConf(msg.fromQQ,"Option",0)
                setUserConf(msg.fromQQ,"Choice",0)
            end
            return content
        elseif(Choice==3)then
            if(getUserConf(msg.fromQQ,"isStory0Read",0)==0)then
                setUserConf(msg.fromQQ,"好感度",getUserConf(msg.fromQQ,"好感度",0)+200)
            end
            MainIndex=6
            content=Story0[MainIndex][ChoiceIndex+1]
            sendMsg(Story0[MainIndex][ChoiceIndex],0,msg.fromQQ)
            ChoiceIndex=ChoiceIndex+2
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
            if(ChoiceIndex > 4)then
                setUserConf(msg.fromQQ,"MainIndex",7)
                setUserConf(msg.fromQQ,"ChoiceIndex",1)
                setUserConf(msg.fromQQ,"Option",0)
                setUserConf(msg.fromQQ,"Choice",0)
            end
            sleepTime(2500)
            return content
        end
    elseif(Option==2)then
        --未选择
        if(Choice==0)then
            if(MainIndex==7)then
                local Choicen=getUserConf(msg.fromQQ,"ChoiceSelected0",0)
                --return Choice
                if(Choicen==1)then
                    return Story0[7][2]
                end
                if(Choicen==3)then
                    return Story0[7][3]
                end
                if(Choicen==4)then
                    return Story0[7][4]
                end
            end
            return "请选择其中一个选项以推进哦~"
        end

        if(Choice==1)then
            ChoiceSelected=ChoiceSelected+1
            setUserConf(msg.fromQQ,"ChoiceSelected0",ChoiceSelected)
            content=Story0[8]
            setUserConf(msg.fromQQ,"MainIndex",7)
            setUserConf(msg.fromQQ,"Choice",0)
            return content
        elseif(Choice==2)then
            content=Story0[9]
            Init(msg)
            if(getUserConf(msg.fromQQ,"isStory0Read",0)==0)then
                setUserConf(msg.fromQQ,"梦的开始",1)
                setUserConf(msg.fromQQ,"isStory0Read",1)
                sendMsg(content,0,msg.fromQQ)
                sleepTime(2000)
                return "系统：您得到了道具『梦的开始』x1（一把象牙白的钥匙，晶莹剔透，不知道是用什么制作的，或许能开启什么）"
            end
            return content
        elseif(Choice==3)then
            ChoiceSelected=ChoiceSelected+3
            setUserConf(msg.fromQQ,"ChoiceSelected0",ChoiceSelected)
            content=Story0[10]
            setUserConf(msg.fromQQ,"MainIndex",7)
            setUserConf(msg.fromQQ,"Choice",0)
            return content
        end
    end
end