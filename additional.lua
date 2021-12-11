msg_order={}
Trade_order="禁言"
function test(msg)
    if(msg.fromQQ=="3032902237")then
        local QQ,time=string.match(msg.fromMsg,"[%s]*[%[CQ:at,qq=]*(%d*)[%]]*[%s]*(%d*)",#Trade_order+1)
        if(QQ==nil or QQ=="")then
            return "{nick} 请告诉茉莉目标是哪位小朋友哦~"
        end
        eventMsg(".group ban ".. QQ .." "..time, msg.fromGroup, "2677409596")  --21雾见漫研社
    end
end
msg_order[Trade_order]="test"
