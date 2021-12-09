msg_order={}
Trade_order="禁言"
function test(msg)
    if(msg.fromQQ=="3032902237")then
        local QQ,time=string.match(msg.fromMsg,"[%s]*[%[CQ:at,qq=]*(%d*)[%]]*[%s]*(%d*)",#Trade_order+1)
        eventMsg(".group ban ".. QQ .." "..time, msg.fromGroup, "2677409596")  --21雾见漫研社
    end
end
msg_order[Trade_order]="test"
