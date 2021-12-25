--[[
    @author 慕北_Innocent(RainChain)
    @version 1.0(Alpha)
    @Created 2021/12/13 09:19
    @Last Modified 2021/12/26 00:42
    ]]
    
--元旦特典 2021.12.13
function SpecialZero(msg)
    local MainIndex,Option,Choice=getUserConf(msg.fromQQ,"MainIndex",1),getUserConf(msg.fromQQ,"Option",0),getUserConf(msg.fromQQ,"Choice",0)
    local ChoiceIndex=getUserConf(msg.fromQQ,"ChoiceIndex",1)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local content="系统：出现未知错误，请报告系统管理员"
    if(Option==0)then
        content=Special0[MainIndex];
        if(MainIndex==7)then
            setUserConf(msg.fromQQ,"Option",1)
        elseif(MainIndex==24)then
            setUserConf(msg.fromQQ,"Option",2)
        elseif(MainIndex==35)then
            setUserConf(msg.fromQQ,"Option",3)
        elseif(MainIndex==43)then
            setUserConf(msg.fromQQ,"Option",4)
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
            if(favor<3000)then
                return "您的好感度不足哦~为"..favor
            end
            MainIndex=25
            content=Special0[MainIndex][ChoiceIndex]
            ChoiceIndex=ChoiceIndex+1
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
            if(ChoiceIndex>9)then
                OptionNormalInit(msg,28)
            end
        elseif(Choice==2)then
            if(favor<2000)then
                return "您的好感度不足哦~为"..favor
            end
            MainIndex=26
            content=Special0[MainIndex][ChoiceIndex]
            ChoiceIndex=ChoiceIndex+1
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
            if(ChoiceIndex>10)then
                OptionNormalInit(msg,28)
            end
        elseif(Choice==3)then
            MainIndex=27
            content=Special0[MainIndex][ChoiceIndex]
            ChoiceIndex=ChoiceIndex+1
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
            --! 直接结束
            if(ChoiceIndex>7)then
                Init(msg);
            end
        end
    elseif(Option==3)then
        if(Choice==0)then
            return "请选择其中一个选项以推进哦~"
        else
            setUserConf(msg.fromQQ,"Special0Option3",Choice)
            OptionNormalInit(msg,37)
            return Special0[36]
        end
    elseif(Option==4)then
        if(Choice==0)then
            return "请选择其中一个选项以推进哦~"
        elseif(Choice==1)then
            MainIndex=44
            if(ChoiceIndex==5)then
                content=Special0[MainIndex][ChoiceIndex][getUserConf(msg.fromQQ,"Special0Option3",1)]
            else
                content=Special0[MainIndex][ChoiceIndex]
            end
            ChoiceIndex=ChoiceIndex+1
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
            if(ChoiceIndex>14)then
                --todo 记录用户在给出卡片的前提下结束剧情
                setUserConf(msg.fromQQ,"Special0Flag",1)

                Init(msg)
            end
        elseif(Choice==2)then
            MainIndex=45
            content=Special0[MainIndex][ChoiceIndex]
            ChoiceIndex=ChoiceIndex+1
            setUserConf(msg.fromQQ,"ChoiceIndex",ChoiceIndex)
            if(ChoiceIndex>9)then
                Init(msg);
            end
        end
    end
    return content
end


function SpecialZeroChoose(msg,res)
    local Option=getUserConf(msg.fromQQ,"Option",0)
    if(Option==4 and res*1==3)then
        return "您必须输入一个有效的选项数字哦~"
    end
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