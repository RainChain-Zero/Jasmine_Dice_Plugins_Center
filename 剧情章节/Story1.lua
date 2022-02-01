--[[
    @author 慕北_Innocent(RainChain)
    @version 1.0
    @Created 2022/01/19 11:11
    @Last Modified 2022/01/25 13:47
    ]]

--第一章 夜未央
function StoryOne(msg)
    local MainIndex,Option,Choice=getUserConf(msg.fromQQ,"MainIndex",1),getUserConf(msg.fromQQ,"Option",0),getUserConf(msg.fromQQ,"Choice",0)
    local ChoiceIndex=getUserConf(msg.fromQQ,"ChoiceIndex",1)
    --记录给茉莉发送消息后返回的选项编号
    --! -1%10==9
    local OptionReturn=getUserConf(msg.fromQQ,"isStory1Option1Choice3",-1)%10
    --剩余行动轮 初始为4
    local actionRoundLeft=getUserConf(msg.fromQQ,"actionRoundLeft",4)
    local content="系统：出现未知错误，请报告系统管理员"

    if(Option==0)then
        content=Story1[MainIndex]
        if(MainIndex==4)then
            setUserConf(msg.fromQQ,"Option",1)
        elseif (MainIndex==13) then
            setUserConf(msg.fromQQ,"Option",2)
            content=content.."\f注意：当前剩余行动次数"..string.format("%.0f",actionRoundLeft).."/4"
        elseif (MainIndex==30) then
            --! 剧情结束
            Init(msg)
            --! 商店功能未解锁警告
            if (getUserConf(msg.fromQQ,"isShopUnlocked",0)==0) then
                content=content.."\f系统消息：Warning：您在本章节仍有一项功能未解锁！"
            end
        end
        MainIndex=MainIndex+1
        setUserConf(msg.fromQQ,"MainIndex",MainIndex)
        return content
    elseif (Option==1) then
        if(Choice==0)then
            return "请选择其中一个选项以推进哦~"
        end
        if (Choice==1) then
            MainIndex=5
            content=Story1[MainIndex][ChoiceIndex]
            --! 准备跳转到选项1.1
            if(ChoiceIndex==2)then
                --Option记录为11
                setUserConf(msg.fromQQ,"Option",11)
                setUserConf(msg.fromQQ,"ChoiceIndex",1)
                setUserConf(msg.fromQQ,"Choice",0)
                if (getUserConf(msg.fromQQ,"isStory1Option1Choice3",-1)~=-1) then
                    content=content.."(不可选)"
                end
                return content
            end
            ChoiceIndex=ChoiceIndex+1
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
            return content
        elseif (Choice==2) then
            return MessageSent(msg,OptionReturn)
        elseif(Choice==3)then
            return GoToMessage(msg,10,ChoiceIndex)
        end
    elseif (Option==11) then
        if(Choice==0)then
            return "请选择其中一个选项以推进哦~"
        end
        if(Choice==1)then
            MainIndex=6
            content=Story1[MainIndex][ChoiceIndex]
            --! 准备跳转到选项1.2
            if (ChoiceIndex==4) then
                --Option记录为12
                setUserConf(msg.fromQQ,"Option",12)
                setUserConf(msg.fromQQ,"ChoiceIndex",1)
                setUserConf(msg.fromQQ,"Choice",0)
                if (getUserConf(msg.fromQQ,"isStory1Option1Choice3",-1)~=-1) then
                    content=content.."(不可选)"
                end
                return content
            end
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex+1)
            return content
        elseif (Choice==2) then
            return MessageSent(msg,OptionReturn)
        elseif (Choice==3) then
            return GoToMessage(msg,11,ChoiceIndex)
        end
    elseif (Option==12) then
        if(Choice==0)then
            return "请选择其中一个选项以推进哦~"
        end
        if(Choice==1)then
            return MessageSent(msg,OptionReturn)
        elseif (Choice==2) then
            return GoToShop(msg)
        elseif (Choice==3) then
            return GoToMessage(msg,12,ChoiceIndex)
        end
    elseif (Option==13) then
        if(Choice==0)then
            return "请选择其中一个选项以推进哦~"
        end
        if (Choice==1) then
            return ReturnLastOption(msg,8,ChoiceIndex,17,OptionReturn)
        elseif (Choice==2) then
            return ReturnLastOption(msg,9,ChoiceIndex,19,OptionReturn)
        elseif (Choice==3) then
            return ReturnLastOption(msg,10,ChoiceIndex,19,OptionReturn)
        end
    elseif (Option==2) then
        if(Choice==0)then
            return "请选择其中一个选项以推进哦~"
        end
        if (Choice==1) then
            return ActionRound_Room(msg,14,ChoiceIndex,3)
        elseif (Choice==2) then
            return ActionRound_Room(msg,17,ChoiceIndex,3)
        elseif (Choice==3) then
            return ActionRound_Room(msg,20,ChoiceIndex,4)
        end
    elseif (Option==21) then
        if(Choice==0)then
            return "请选择其中一个选项以推进哦~"
        end
        if (Choice==1) then
            return ActionRound_InnerRoom(msg,15,ChoiceIndex,3,Option)
        elseif (Choice==2) then
            return ActionRound_InnerRoom(msg,16,ChoiceIndex,3,Option)
        elseif (Choice==3) then
            --返回客厅，不消耗行动轮次数
            setUserConf(msg.fromQQ,"Option",2)
            setUserConf(msg.fromQQ,"ChoiceIndex",1)
            setUserConf(msg.fromQQ,"Choice",0)
            return "你又踱回了客厅，接下来要去哪看看呢？\f"..Story1[13]
        end
    elseif (Option==22) then
        if(Choice==0)then
            return "请选择其中一个选项以推进哦~"
        end
        if (Choice==1) then
            return ActionRound_InnerRoom(msg,18,ChoiceIndex,3,Option)
        elseif (Choice==2) then
            return ActionRound_InnerRoom(msg,19,ChoiceIndex,4,Option)
        elseif (Choice==3) then
            --返回客厅，不消耗行动轮次数
            setUserConf(msg.fromQQ,"Option",2)
            setUserConf(msg.fromQQ,"ChoiceIndex",1)
            setUserConf(msg.fromQQ,"Choice",0)
            return "你又踱回了客厅，接下来要去哪看看呢？\f"..Story1[13]
        end
    elseif (Option==23) then
        if(Choice==0)then
            return "请选择其中一个选项以推进哦~"
        end
        if (Choice==1) then
            return ActionRound_InnerRoom(msg,21,ChoiceIndex,5,Option)
        elseif (Choice==2) then
            --返回客厅，不消耗行动轮次数
            setUserConf(msg.fromQQ,"Option",2)
            setUserConf(msg.fromQQ,"ChoiceIndex",1)
            setUserConf(msg.fromQQ,"Choice",0)
            return "你又踱回了客厅，接下来要去哪看看呢？\f"..Story1[13]
        end
        --进入商店的剧情
    elseif (Option==3) then
        MainIndex=31
        --! 准备跳转回家
        if(ChoiceIndex==8)then
            return MessageSent(msg,OptionReturn)
        end
        content=Story1[MainIndex][ChoiceIndex]
        if(ChoiceIndex==6)then
            --第一次解锁商店
            if(getUserConf(msg.fromQQ,"isShopUnlocked",0)==0)then
                content=content.."\f{FormFeed}{FormFeed}".."重要消息：『商店』已经解锁！输入指令“进入商店”来进入商品界面\f系统消息：您得到了500FL"
                setUserConf(msg.fromQQ,"isShopUnlocked",10)
                setUserConf(msg.fromQQ,"FL",500)
            end
        end
        if (ChoiceIndex==7) then
            if(getUserConf(msg.fromQQ,"isShopUnlocked",0)==10)then
                return "提示：初次阅读，您必须先购买一件商品才能继续进行哦~"
            end
        end
        ChoiceIndex=ChoiceIndex+1
        setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
        return content
    end
end

--判断回家时是否发送信息
function MessageSent(msg,OptionReturn)
    local content="出现未知错误，请报告系统管理员！"
    --为9代表没有发送消息
    if(OptionReturn~=9)then
        --添加过渡句
        content="你带着还不错的心情回到家中，茉莉此时似乎还没回来，不过稍等片刻，"..Story1[22]
        OptionNormalInit(msg,23)
        return content
    else
        content=Story1[11]
        OptionNormalInit(msg,12)
        return content
    end
end

--发送信息的部分
function GoToMessage(msg,index,ChoiceIndex)
    local content=""
    --记录发送信息
    setUserConf(msg.fromQQ,"isMessageSent",1)
    setUserConf(msg.fromQQ,"isStory1Option1Choice3",index)
    MainIndex=7
    content=Story1[MainIndex][ChoiceIndex]
    --实现消息延时发送
    if(ChoiceIndex==2 or ChoiceIndex==4)then
        content=content.."{FormFeed}{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+1]
        setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex+1)
        ChoiceIndex=ChoiceIndex+1
    end
    --! 准备跳转到选项1.3
    if (ChoiceIndex==6) then
        setUserConf(msg.fromQQ,"Option",13) 
        setUserConf(msg.fromQQ,"ChoiceIndex",1)
        setUserConf(msg.fromQQ,"Choice",0)
        return content
    end
    setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex+1)
    return content
end

--发送完消息后返回上一个选项
function ReturnLastOption(msg,MainIndex,ChoiceIndex,Border,OptionReturn)
    local content=""
    if (ChoiceIndex==Border) then
        if (OptionReturn==0) then
            --添加第三选项不可选中标记
            content=Story1[4].."(不可选)"
            setUserConf(msg.fromQQ,"Option",1)
            setUserConf(msg.fromQQ,"ChoiceIndex",1)
            setUserConf(msg.fromQQ,"Choice",0)
            return content
        elseif (OptionReturn==1) then
            --添加第三选项不可选中标记
            content=Story1[5][3].."(不可选)"
            setUserConf(msg.fromQQ,"Option",11)
            setUserConf(msg.fromQQ,"ChoiceIndex",1)
            setUserConf(msg.fromQQ,"Choice",0)
            return content
        elseif (OptionReturn==2) then
            --添加第三选项不可选中标记
            content=Story1[6][4].."(不可选)"
            setUserConf(msg.fromQQ,"Option",12)
            setUserConf(msg.fromQQ,"ChoiceIndex",1)
            setUserConf(msg.fromQQ,"Choice",0)
            return content
        end
    end
    content=Story1[MainIndex][ChoiceIndex]
    --实现延迟发送
    if(MainIndex==8)then
        if(ChoiceIndex==1)then
            content=content.."{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+1].."{FormFeed}{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+2]
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex+2)
            ChoiceIndex=ChoiceIndex+2
        elseif (ChoiceIndex==4) then
            content=content.."{FormFeed}{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+1].."{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+2]..
            "{FormFeed}{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+3]
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex+3)
            ChoiceIndex=ChoiceIndex+3
        elseif (ChoiceIndex==8) then
            content=content.."{FormFeed}{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+1].."{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+2]
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex+2)
            ChoiceIndex=ChoiceIndex+2
        elseif (ChoiceIndex==12) then
            content=content.."{FormFeed}{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+1].."{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+2]..
            "{FormFeed}{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+3]
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex+3)
            ChoiceIndex=ChoiceIndex+3
        end
    elseif (MainIndex==9) then
        if (ChoiceIndex==1) then
            content=content.."{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+1].."{FormFeed}{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+2]
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex+2)
            ChoiceIndex=ChoiceIndex+2
        elseif (ChoiceIndex==5 or ChoiceIndex==7 or ChoiceIndex==9 or ChoiceIndex==11 or ChoiceIndex==13 or ChoiceIndex==15 or ChoiceIndex==17) then
            content=content.."{FormFeed}{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+1]
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex+1)
            ChoiceIndex=ChoiceIndex+1
        end
    elseif (MainIndex==10) then
        if (ChoiceIndex==1 or ChoiceIndex==6 or ChoiceIndex==8 or ChoiceIndex==10 or ChoiceIndex==13) then
            content=content.."{FormFeed}{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+1]
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex+1)
            ChoiceIndex=ChoiceIndex+1
        elseif (ChoiceIndex==3 or ChoiceIndex==15) then
            content=content.."{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+1].."{FormFeed}{FormFeed}{FormFeed}"..Story1[MainIndex][ChoiceIndex+2]
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex+2)
            ChoiceIndex=ChoiceIndex+2
        end
    end
    ChoiceIndex=ChoiceIndex+1
    setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
    return content
end

--行动轮剩余次数判断
function JudgeActionRound(msg)
    local actionRoundLeft=getUserConf(msg.fromQQ,"actionRoundLeft",4)-1
    setUserConf(msg.fromQQ,"actionRoundLeft",actionRoundLeft)
    if (actionRoundLeft>=1) then
        return true
    end
    return false
end

--行动轮-房间选择
function ActionRound_Room(msg,MainIndex,ChoiceIndex,Border)
    local content=Story1[MainIndex][ChoiceIndex]
    local Option
    if (ChoiceIndex==Border) then
        --判定当前行动轮次数是否消耗完
        if (JudgeActionRound(msg)) then
            --! 准备跳转到选项2.x
            if (MainIndex==14) then
                Option=21
            elseif (MainIndex==17) then
                Option=22
            elseif (MainIndex==20) then
                Option=23
            end
            setUserConf(msg.fromQQ,"Option",Option)
            setUserConf(msg.fromQQ,"ChoiceIndex",1)
            setUserConf(msg.fromQQ,"Choice",0)
            return content.."\f注意：当前剩余行动次数"..string.format("%.0f",getUserConf(msg.fromQQ,"actionRoundLeft",4)).."/4"
        else
            --已经消耗完行动次数，不给出下一个选项
            OptionNormalInit(msg,23)
            return Story1[22]
        end
    end
    setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex+1)
    return content
end

--行动轮-房间内行动
function ActionRound_InnerRoom(msg,MainIndex,ChoiceIndex,Border,OptionNow)
    local content=Story1[MainIndex][ChoiceIndex]
    if (ChoiceIndex==Border) then
        --判定当前行动轮次数是否被消耗完
        if (JudgeActionRound(msg)) then
            --! 准备返回选项2.x
            setUserConf(msg.fromQQ,"Option",OptionNow)
            setUserConf(msg.fromQQ,"ChoiceIndex",1)
            setUserConf(msg.fromQQ,"Choice",0)
            return content.."\f注意：当前剩余行动次数"..string.format("%.0f",getUserConf(msg.fromQQ,"actionRoundLeft",4)).."/4"
        else
            --已经消耗完行动次数，不给出下一个选项
            OptionNormalInit(msg,23)
            return Story1[22]
        end
    end
    setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex+1)
    return content
end

--商店界面
function GoToShop(msg)
    setUserConf(msg.fromQQ,"Option",3)
    setUserConf(msg.fromQQ,"ChoiceIndex",2)
    return Story1[31][1]
end
--选择
function StoryOneChoose(msg,res)
    local Option=getUserConf(msg.fromQQ,"Option",0)
    if (Option==23 and res*1==3) then
        return "请输入一个有效的选项数字哦~"
    end
    if (Option==1 or Option==11 or Option==12) then
        if ( res*1==3 and getUserConf(msg.fromQQ,"isStory1Option1Choice3",-1)~=-1) then
            return "该选项处于不可选中状态哦~"
        end
    end
    setUserConf(msg.fromQQ,"Choice",res*1)
    return "您选中了选项"..res.." 输入.f以确认选择"
end

--跳过
function SkipStory1()
    return "Warning：当前章节选项重要程度为高，跳转功能已被锁定"
end