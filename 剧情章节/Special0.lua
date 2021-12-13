--[[
    @author 慕北_Innocent(RainChain)
    @version 0.1(Alpha)
    @Created 2021/12/13 09:19
    @Last Modified 2021/12/13 15:06
    ]]
    
--元旦特典 2021.12.13
function SpecialZero(msg)
    local MainIndex,Option,Choice=getUserConf(msg.fromQQ,"MainIndex",1),getUserConf(msg.fromQQ,"Option",0),getUserConf(msg.fromQQ,"Choice",0)
    local ChoiceIndex=getUserConf(msg.fromQQ,"ChoiceIndex",1)
    local content="系统：出现未知错误，请报告系统管理员"
    if(Option==0)then
        content=Special0[MainIndex];
        if(MainIndex==7)then
            setUserConf(msg.fromQQ,"Option",1)
        elseif(MainIndex==15)then
            setUserConf(msg.fromQQ,"Option",2)
        end
        MainIndex=MainIndex+1
        setUserConf(msg.fromQQ,"MainIndex",MainIndex)
        return content
    elseif(Option==1)then
        if(Choice==0)then
            return "请选择其中一个选项以推进哦~"
        elseif(Choice==1)then
            MainIndex=8
            content=Special0[MainIndex][ChoiceIndex]
            ChoiceIndex=ChoiceIndex+1
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
            if(ChoiceIndex>6)then
                OptionNormalInit(msg,11)
            end
        elseif(Choice==2)then
            MainIndex=9
            content=Special0[MainIndex][ChoiceIndex]
            ChoiceIndex=ChoiceIndex+1
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
            if(ChoiceIndex>12)then
                OptionNormalInit(msg,11)
            end
        elseif(Choice==3)then
            MainIndex=10
            content=Special0[MainIndex][ChoiceIndex]
            ChoiceIndex=ChoiceIndex+1
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
            if(ChoiceIndex>8)then
                OptionNormalInit(msg,11)
            end
        end
    elseif(Option==2)then
        if(Choice==0)then
            return "请选择其中一个选项以推进哦~"
        elseif(Choice==1)then
            MainIndex=16
            content=Special0[MainIndex][ChoiceIndex]
            ChoiceIndex=ChoiceIndex+1
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
            if(ChoiceIndex>6)then
                Init(msg)  --! 后续删除
                content= "TO BE CONTINUED"
            end
        
            --todo TO BE CONTINUED
        elseif(Choice==2)then
            Init(msg)  --! 后续删除
            content="TO BE CONTINUED"
        elseif(Choice==3)then
            Init(msg)  --! 后续删除
            content="TO BE CONTINUED"
        end
    end
    return content
end


function SpecialZeroChoose(msg,res)
    setUserConf(msg.fromQQ,"Choice",res*1)
    return "您已选择选项"..res.." 输入.f以推进"
end

-- 一个选项结束后初始化有关记录
function OptionNormalInit(msg,index)
    setUserConf(msg.fromQQ,"MainIndex",index)
    setUserConf(msg.fromQQ,"ChoiceIndex",1)
    setUserConf(msg.fromQQ,"Option",0)
    setUserConf(msg.fromQQ,"Choice",0)
end