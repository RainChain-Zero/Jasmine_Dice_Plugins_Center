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

function picture(msg)
    return "[CQ:image,url="..picture_api[ranint(1,#picture_api)].."]"
end
msg_order["来点二次元"]="picture"

picture_api=
{
    [1]="https://iw233.cn/api/Random.php",
    [2]="http://random.firefliestudio.com",
    [3]="https://acg.toubiec.cn/random.php",
    [4]="https://www.dmoe.cc/random.php",
    [5]="https://api.ixiaowai.cn/api/api.php",
}

