
--以下更新仅限个人使用
--updated by 慕北_Innocent 2021.8.19
--Ver2.0 增加更多的好感交互行为，追加好感降低惩罚，优化好感升降数值
--updated by 慕北_Innocent 2021.8.20
--Ver2.5 增加认错交互，追加更多的互动分支，为之前的好感交互增加rude_sorry判定
--updated by 慕北_Innocent 2021.8.21
--Ver2.6 修复道歉系统中出现的逻辑漏洞
--Ver3.0 updated by 慕北_Innocent 2021.8.23
--Ver3.0 修改（提高）互动等级阈值，追加动作初步交互系统，新增交互分支,优化交互匹配逻辑机制,追加初步时间系统
--Ver3.2 updated by 慕北——Innocent 2021.8.27
--Ver3.2 追加初步夸奖和感情表达系统，增加可交互的动作，新增可选分支
--updated by 慕北——Innocent 2021.9.20
--Ver3.3 增加好感下限黑名单保护机制
--Ver3.4 将好感度和用户信任等级关联
--Ver3.6 增加“互动”模式 可以选择身体部位进行交互（初步） 增加节日相关内容 分支追加
--Ver3.7 现在一定时间不进行好感互动将会降好感
--Ver3.8 所有好感增幅减半 脏话若不指定茉莉不会触发回复，但会隐式降低好感度 增加逼近好感下限提醒

--载入回复模块
package.path="/home/container/Dice3349795206/plugin/FavorReply/?.lua"
require "favorReply"

msg_order = {}

function topercent(num)
    if(num==nil)then
        return ""
    end
    return string.format("%.2f",num/100)
end
--各类上限
today_food_limit = 3   --单日喂食次数上限
today_morning_limit=1  --单日早安好感增加次数上限
today_night_limit=1  --每日晚安好感增加次数上限
today_hug_limit=1   --每日拥抱加好感次数上限
today_touch_limit=1  --每日摸头加好感次数上限
today_lift_limit=1  --每日举高高加好感次数上限
today_kiss_limit=1  --每日kiss加好感次数上限
today_hand_limit=1  --每日牵手加好感次数上限
today_face_limit=1   --每日捏/揉脸加好感次数上限
today_suki_limit=1   --每日喜欢加好感次数上限
today_love_limit=1    --每日爱加好感次数上限
today_interaction_limit=3  --每日"互动-部位"增加好感次数上限
today_cute_limit=1
flag_food=0   --用于标记多次喂食只回复一次
cnt=0       --用户输入的喂食次数

--时间系统
hour=os.date("*t").hour*1
minute=os.date("%M")*1
month=os.date("%m")*1
day=os.date("%d")*1
year=os.date("%Y")*1
-- do
--     if(hour>=16 and hour<=23)then
--         hour=0+8-(24-hour)         --GMT时间转北京时间
--     end
-- end

--关联骰娘trust
function trust(msg)
    --强制更新提示信息
    --sendMsg("Error！茉莉好感组件强制更新维护中！暂停服务！",msg.fromGroup,msg.fromQQ)
    --os.exit()

    --版本通告处
    
    local favorVersion=getGroupConf(msg.fromGroup,"favorVersion",0)
    local favorUVersion=getUserConf(msg.fromQQ,"favorVersion",0)
    --修改版本号只需要将下面的数字修改为目前的版本号即可
    if(favorUVersion~=40)then
        setUserConf(msg.fromQQ,"noticeQQ",0)
        setUserConf(msg.fromQQ,"favorVersion",40)
    end
    if(favorVersion~=40)then
        setGroupConf(msg.fromGroup,"favorVersion",40)
        setGroupConf(msg.fromGroup,"notice",0)
    end
    local notice=getGroupConf(msg.fromGroup,"notice",0)
    local noticeQQ=getUserConf(msg.fromQQ,"noticeQQ",0)
    if(msg.fromGroup=="0" and noticeQQ==0)then
            noticeQQ=noticeQQ+1
            local content="**[好感互动模块-版本通告Ver4.0]**\n新增了剧情系统（Beta），可以浏览和茉莉酱一起经历的故事，目前已完成（短篇）序章，好感达到1000者可通过指令“进入剧情 序章”进入剧情浏览，欢迎阅读哦~\n1.进度自动保存，重新输入“进入剧情”将会从零开始\n2.部分选项会增加/降低好感\n3.阅读完章节将会给予道具奖励\n"..
            "策划及文案：@Ashiterui（2677409596）\n脚本及实现：@慕北_Innocent（RainChain）(3032902237)\nBug及意见反馈：@Ashiterui（2677409596）\n——By 慕北_Innocent(RainChain)(3032902237)\n2021.12.05"
            setUserConf(msg.fromQQ,"noticeQQ",noticeQQ)
            sendMsg(content,0,msg.fromQQ)
    end
    noticeQQ=getUserConf(msg.fromQQ,"noticeQQ",0)
    if(notice~=nil)then
        if(notice<=2 and noticeQQ==0)then
            notice=notice+1
            noticeQQ=noticeQQ+1
            local content="**[好感互动模块-版本通告Ver4.0]**\n新增了剧情系统（Beta），可以浏览和茉莉酱一起经历的故事，目前已完成（短篇）序章，好感达到1000者可通过指令“进入剧情 序章”进入剧情浏览，欢迎阅读哦~\n1.进度自动保存，重新输入“进入剧情”将会从零开始\n2.部分选项会增加/降低好感\n3.阅读完章节将会给予道具奖励\n"..
            "策划及文案：@Ashiterui（2677409596）\n脚本及实现：@慕北_Innocent（RainChain）(3032902237)\nBug及意见反馈：@Ashiterui（2677409596）\n本通告各群将广播3次("..string.format("%.0f",notice).."/3)\n——By 慕北_Innocent(RainChain)(3032902237)\n2021.12.05"
            setGroupConf(msg.fromGroup,"notice",notice)
            setUserConf(msg.fromQQ,"noticeQQ",noticeQQ)
            sendMsg(content,msg.fromGroup,msg.fromQQ)
        end
    end
    --把时间-好感降低函数放在trust函数第一句
    favor_punish(msg)
    local favor = getUserConf(msg.fromQQ,"好感度",0)
    local trust_flag=getUserConf(msg.fromQQ,"trust_flag",0)
    local admin_judge=msg.fromQQ~="2677409596" and msg.fromQQ~="3032902237"
    --festival(msg)
    if(admin_judge)then
        if(favor<1000)then
            if(trust_flag==0)then
                return ""
            end
            eventMsg(".user trust "..msg.fromQQ.." 0",0,2677409596)
            setUserConf(msg.fromQQ,"trust_flag",0)
        elseif(favor<3000)then
            if(trust_flag==1)then
                return ""
            end
            eventMsg(".user trust "..msg.fromQQ.." 1",0,2677409596)
            setUserConf(msg.fromQQ,"trust_flag",1)
        elseif(favor<5000)then
            if(trust_flag==2)then
                return ""
            end
            eventMsg(".user trust "..msg.fromQQ.." 2",0,2677409596)
            setUserConf(msg.fromQQ,"trust_flag",2)
        else
            if(trust_flag==3)then
                return ""
            end
            eventMsg(".user trust "..msg.fromQQ.." 3",0,2677409596)
            setUserConf(msg.fromQQ,"trust_flag",3)
        end
    end
end
--一定时间不交互将会降低好感度
function favor_punish(msg)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local flag=false
    --初始时间记为编写该程序段的时间
    local _year,_month,_day,_hour=getUserConf(msg.fromQQ,"year_last",2021),getUserConf(msg.fromQQ,"month_last",10),getUserConf(msg.fromQQ,"day_last",11),getUserConf(msg.fromQQ,"hour_last",23)
    local subyear,submonth,subday,subhour=year-_year,month-_month,day-_day,hour-_hour
    subday=365*subyear+30*submonth+subday
    setUserConf(msg.fromQQ,"month_last",month)
    setUserConf(msg.fromQQ,"day_last",day)
    setUserConf(msg.fromQQ,"hour_last",hour)
    setUserConf(msg.fromQQ,"year_last",year)
    --flag用于标记是否是从>500的favor降到500以下的
    if(favor>=500)then
        flag=true
    else
        return ""   --本身<500的用户不会触发
    end
    if(subday==0)then
        return ""
    end
    local Llimit,Rlimit=0,0
    --分段降低好感
    if(subday<=3)then
        if(subday==1 and subhour<=-15)then
            return ""
        end
        if(favor<8500 and favor>1250)then
            Llimit,Rlimit=60*math.log(2*subday,2),70*math.log(2*subday,2)
        elseif(favor>=8500)then
            Llimit,Rlimit=120*math.log(2*subday,2),140*math.log(2*subday,2)
        else
            Llimit,Rlimit=30*math.log(2*subday,2),35*math.log(2*subday,2)
        end
    elseif(subday<=8)then
        Llimit,Rlimit=150*subday,185*subday
    else
        Llimit,Rlimit=820+195*(subday-5)*math.log(2*(subday-5),2),870+225*(subday-5)*math.log(2*(subday-5),2)
    end
    --
    --//todo 将左右端点取整才可带入ranint
    Llimit,Rlimit=math.modf(Llimit),math.modf(Rlimit)
    favor=favor-ranint(Llimit,Rlimit)
    if(favor<500 and flag==true)then
        favor=500
    end
    setUserConf(msg.fromQQ,"好感度",favor)
end

function add_favor_food()
    --单次固定好感上升
    --return 100
    --随机好感上升
    return ranint(20,30)
end
function add_gift_once()	--单次计数上升
    return 5
    --return ranint(1,10)
end

--下限黑名单判定
function blackList(msg)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    if(favor<=-300 and favor>-600)then
        sendMsg("Warning:检测到{nick}的好感度过低，即将触发机体下限保护机制！",msg.fromGroup,msg.fromQQ)
        sendMsg("Warning:检测到用户"..msg.fromQQ.."好感度过低".."在群"..msg.fromGroup,msg.fromGroup,2677409596)
    end
    if(favor<-600)then
        eventMsg(".admin blackqq ".."违反人机和谐共处条例 "..msg.fromQQ,0,2677409596)
        eventMsg(".group ".. msg.fromGroup .." ban ".. msg.fromQQ .." "..tostring(-favor),msg.fromGroup, getDiceQQ())
        return "已触发！"
    end
    return ""
end

--!提醒：请不要随意修改rcv_food函数！！递归中牵扯过多，容易引发bug
function rcv_food(msg)
    --rude值判定是否接受喂食
    --return "Warning!好感组件强制更新中 相关功能已停用"
    trust(msg)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    local favor = getUserConf(msg.fromQQ,"好感度",0)
    --匹配喂食的次数
    if(cnt==0)then
        cnt=string.match(msg.fromMsg,"[%s]*(%d+)",#food_order+1)
        if(cnt==nil)then
            cnt=0
        else
            cnt=cnt*1
        end
    end
    if(cnt>=4 or cnt<0)then
        return "参数有误请重新输入哦~"
    end
    if(msg.fromQQ=="2677409596")then
        if((today_rude>=4 and today_sorry==0) or today_sorry>=2)then
            flag_food=flag_food+1     --判定爱酱道歉次数以及是否知错不改（today_sorry>=2）
            if(flag_food==1)then
                flag_food=0
                return "哼，笨蛋主人，我才不吃你的东西呢"
            end
        end
    else
        if((today_rude>=3 and today_sorry==0) or today_sorry>=2)then
            flag_food=flag_food+1    --判定其他用户道歉次数...
            if(flag_food==1)then
                flag_food=0
                return "主人告诉我不要吃坏人给的东西！"
            end
        end
    end
    --判定当日上限
    local today_gift = getUserToday(msg.fromQQ,"gifts",0)
    if(today_gift>=today_food_limit)then
        return "对不起{nick}，茉莉今天...想换点别的口味呢呜QAQ"
    end
    today_gift = today_gift + 1
    setUserToday(msg.fromQQ, "gifts", today_gift)
    --计算今日/累计投喂，存取在骰娘用户记录上
    local DiceQQ = getDiceQQ()
    local gift_add = add_gift_once()
    local self_today_gift = getUserToday(DiceQQ,"gifts")+gift_add
    setUserToday(DiceQQ,"gifts",self_today_gift)
    local self_total_gift = getUserConf(DiceQQ,"gifts",0)+gift_add
    setUserConf(DiceQQ,"gifts",self_total_gift)
    --更新好感度
    if(today_sorry==0)then
        favor=favor+ add_favor_food()
        setUserConf(msg.fromQQ, "好感度", favor)
        cnt=cnt-1
        flag_food=flag_food+1
        --
        --//!递归调用实现多次喂食
        if(cnt>0)then
            rcv_food(msg)
        end
        -- if(flag_food==cntT)then
        --     flag_food=0
        cnt=0
            return "你眼前一黑，手中的食物瞬间消失，再看的时候，眼前的烧酒口中还在咀嚼着什么，扭头躲开了你的目光\n今日已收到投喂"..topercent(self_today_gift).."kg\n累计投喂"..topercent(self_total_gift).."kg"
        -- end
    else
        if(msg.fromQQ=="2677409596" )then
            setUserToday(msg.fromQQ,"hug_needed_to_sorry",1)   --设定需要抱茉莉以道歉的次数
            return "#咀嚼声 哼...唔，主人可别认为这样我就会原谅你！#扭捏着 抱、抱我！"
        else
            if (favor>=1500) then
                setUserToday(msg.fromQQ,"hug_needed_to_sorry",1)   --设定需要抱茉莉以道歉的次数
                return "好、好吃！...不！不对！你如果不抱我的话我绝不原谅你！#撇过头"
            else
                setUserToday(msg.fromQQ,"rude",0)
                return "哼，行吧，茉莉这次就原谅你，下次记得别这样了啊，茉莉我可是很宽容的~#笑"
            end
        end
    end
end
food_order="喂食茉莉"
msg_order[food_order]= "rcv_food"

function punish_favor_papapa()	--好感下降
	--return 150
	return ranint(300,500)
end

function papapa(msg)
    trust(msg)
    local favor = getUserConf(msg.fromQQ,"好感度",0)
    --rude值判定
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    
    local blackReply=blackList(msg)
    if(blackReply~="" and blackReply~="已触发！")then
        return blackReply
    elseif (blackReply=="已触发！") then
        return ""
    end
    if(msg.fromQQ=="2677409596")then
        if(today_rude>=4 or today_sorry>=2)then
            setUserConf(msg.fromQQ,"好感度",favor-200)
            return "茉莉今天生气了！就算是主人也不行！"
        end
    else
        if(today_rude>=3 or today_sorry>=2)then
            setUserConf(msg.fromQQ,"好感度",favor-800)
            return "不要！放开我！你是坏人！茉莉才不要！"
        end
    end
	if(msg.fromQQ == "2677409596")then	--爱酱专属
    	return "呜哇，为什么主人你也……"
    end
    --判定当日上限
	local today_limit = 1
    local today_times = getUserToday(msg.fromQQ,"pa",0)
    if(today_times>=today_limit)then
        return "{nick}今天还嫌不够吗？"
    end
	setUserToday(msg.fromQQ,"pa",today_times+1)
	--基于好感阈值差分
	if(favor<5000)then
    	local punish = punish_favor_papapa()
    	setUserConf(msg.fromQQ,"好感度",favor-punish)
    	return table_draw(reply_papapa_favor_less).."\n{nick}的某些数值悄悄下降了——"..punish
    elseif(favor<8000)then
    	return table_draw(reply_papapa_favor_low)
    elseif(favor<10000)then
    	return table_draw(reply_papapa_favor_high)
    else
    	return table_draw(reply_papapa_favor_highiest)
    end
end

msg_order["啪茉莉"]= "papapa"

function show_favor(msg)
    trust(msg)
    local favor = getUserConf(msg.fromQQ,"好感度",0)
    --trust关联
	if(favor<5000)then
    	return "对{nick}的好感度只有"..favor.."，要加油哦"
    elseif(favor<8000)then
    	return "对{nick}的好感度有"..favor.."，有在花心思呢"
    elseif(favor<10000)then
    	return "好感度到"..favor.."了，不愧是{nick}呢"
    else
    	return "对{nick}的好感度已经有"..favor.."了，以后也要永远在一起哦"
    end
end
msg_order["茉莉好感"]= "show_favor"

--早安问候互动程序
function rcv_Ciallo_morning(msg)
    --每天第一次早安加10好感度
    trust(msg)
    local today_morning=getUserToday(msg.fromQQ,"morning",0)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    today_morning=today_morning+1
    setUserToday(msg.fromQQ,"morning",today_morning)
    if(favor<-600)then
        return ""
    end
    --爱酱专属
    if(msg.fromQQ=="2677409596")then
        if(today_rude>=4 or today_sorry>=2)then
            return "Error!出现机体故障！没有听清！"
        else
            --时间判断
            if(hour>=5 and hour<=10)then
                if(today_morning<=1)then
                    setUserConf(msg.fromQQ,"好感度",favor+5)
                end
                return "主人早上好！主人今日加糖特供早安是茉莉的！"
            elseif (hour==23 or (hour>=0 and hour<=2)) then
                return table_draw(relpy_morning_nightWrong)
            elseif(hour>=11 and hour<=15)then
                return table_draw(reply_morning_afternoonWrong)
            else
                return table_draw(reply_morning_normalWrong)
            end
        end
    else
        --其他用户判定
        if(today_rude>=3 or today_sorry>=2)then
            return "Error!出现机体故障！没有听清！"
        else
            if(hour>=5 and hour<=10)then
                if(today_morning<=1)then
                    setUserConf(msg.fromQQ,"好感度",favor+5)
                end
                if(favor<1000)then
                    return table_draw(reply_morning_less)
                elseif(favor<2000)then
                    return table_draw(reply_morning_low)
                elseif(favor<3000)then
                    return table_draw(reply_morning_high)
                else
                    return table_draw(reply_morning_highest)
                end
            elseif (hour==23 or (hour>=0 and hour<=2)) then
                return table_draw(relpy_morning_nightWrong)
            elseif(hour>=11 and hour<=15)then
                return table_draw(reply_morning_afternoonWrong)
            else
                return table_draw(reply_morning_normalWrong)
            end
        end
    end
end
--可能的早安问候池(前缀匹配)
msg_order["早上好茉莉"]="rcv_Ciallo_morning"
msg_order["茉莉酱早"]="rcv_Ciallo_morning"
msg_order["早啊茉莉"]="rcv_Ciallo_morning"
msg_order["茉莉早"]="rcv_Ciallo_morning"
msg_order["早上好啊茉莉"]="rcv_Ciallo_morning"
msg_order["早上好哟茉莉"]="rcv_Ciallo_morning"
msg_order["早安茉莉"]="rcv_Ciallo_morning"

--爱酱特殊问候关键词触发程序
function rcv_Ciallo_morning_master(msg)
    --trust(msg)
    local today_morning=getUserToday(msg.fromQQ,"morning",0)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    --关键词匹配
    local judge=msg.fromMsg=="早" or string.find(msg.fromMsg,"早上好",1)~=nil or string.find(msg.fromMsg,"早啊",1)~=nil or string.find(msg.fromMsg,"早呀",1)~=nil or string.find(msg.fromMsg,"早安",1)~=nil or string.find(msg.fromMsg,"早哟",1)~=nil
    local special_judge=string.find(msg.fromMsg,"茉莉",1)==nil
    today_morning=today_morning+1
    setUserToday(msg.fromQQ,"morning",today_morning)
    if(judge and special_judge)then
        if(msg.fromQQ == "2677409596")then
            if(today_rude<=3 and today_sorry<=1)then
                if(hour>=5 and hour<=10)then
                    if(today_morning<=1)then
                        setUserConf(msg.fromQQ,"好感度",favor+10)
                    end
                    return "主人早上好！茉莉想死你啦！#飞扑"
                else
                    return "就、就连主人也出现幻觉了吗...（失去高光）"
                end
            end
        else
            if(favor>=1200)then
                if(today_rude<=2 and today_sorry<=1)then
                    if (hour>=5 and hour<=10) then
                        if(today_morning<=1)then
                            setUserConf(msg.fromQQ,"好感度",favor+10)
                        end
                        return "诶诶诶{nick}早上好！今天是来找茉莉玩的吗？"
                    else
                        return "唔...{nick}难道是在和另一个自己对话吗...因为现在怎么看都不是早上的样子..."
                    end
                end
            end
        end
    end
end
msg_order["早"]="rcv_Ciallo_morning_master"

--午安问候程序（不触发好感事件）
function rcv_Ciallo_afternoon(msg)
    trust(msg)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    if(favor<-600)then
        return ""
    end
    if(hour>7 and hour<12)then
        return "诶..可现在还没到中午诶，是茉莉出故障了吗..."
    end
    if(hour>=18 or hour<=6)then
        return "茉莉这次才不会搞错呢！才不会被{nick}这种小花招骗到！外面明明那么黑（指着窗外）"
    end
    --爱酱特殊问候模式
    if(msg.fromQQ=="2677409596")then
        if(today_rude<=3 and today_sorry<=1)then
            return "午安我的主人~你不在的时间里茉莉会照顾好自己的哟"
        end
    end
    if(today_rude<=2 and today_sorry<=1)then
        if(favor<1000)then
            return "嗯？要睡午觉了吗，也是，养好精神也很重要呢"
        elseif(favor<2000)then
            return "午安哦，茉莉也有点困了...呼呼呼"
        elseif(favor<3000)then
            return "诶要睡了吗，好、好吧...之后记得找茉莉玩哦"
        else
            return "嗯呐，在你午睡的时候，请让茉莉在一旁陪着你吧#依"
        end
    end
end
msg_order["午安茉莉"]="rcv_Ciallo_afternoon"
msg_order["茉莉午安"]="rcv_Ciallo_afternoon"
msg_order["茉莉酱午安"]="rcv_Ciallo_afternoon"

--非指向性午安判断程序
function afternoon_special(msg)
    --trust(msg)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    if(msg.fromQQ=="2677409596")then
        if(today_rude<=3 and today_sorry<=1)then
            if(hour>=11 and hour<=16)then
                return msg.fromMsg.."..诶？主人你是对我说的吧...大概（小声）"
            else
                return "主人啊...你..不会出现幻觉了吧..."
            end
        end
    else
        if(favor>=1200)then
            if(today_rude<=2 and today_sorry<=1)then
                return "嗯嗯".." 午安".."，这是茉莉凭个 人 意 愿想对你说的哦~"
            end
        end
    end
end
msg_order["午安"]="afternoon_special"

--指代性中午好
function rcv_Ciallo_noon(msg)
    trust(msg)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    if(favor<-600)then
        return ""
    end
    if(msg.fromQQ=="2677409596")then
        if(today_rude>=4 or today_sorry>=2)then
            return "怎么了——笨↗蛋↘主人，茉莉现在，不！想！理！你！"
        else
            if(hour>=11 and hour<=14)then
                return "主人中午好呀！茉、茉莉吃得...有点饱了...呼呼呼#倒床上"
            else
                return "唔姆，#抬头看窗外 主人你没事吧 睡傻了吗（上来捏脸）"
            end
        end
    else
        if(today_rude>=3 or today_sorry>=2)then
            return "Error!机体故障！目标信息丢失，无法识别该对象！你是谁啊茉莉不认识你"
        else
            if(hour>=11 and hour<=14)then
                if(favor<=1000)then
                    return "唔，中午好！{nick}，吃过午饭了吗？吃过就赶快去休息吧"
                elseif(favor<=2000)then
                    return "中午好呀{nick}——今天过去一半了哦，有什么要做的就抓紧吧"
                elseif(favor<=3000)then
                    return "中，中午好{nick}，是有什么要和茉莉说吗！"
                else
                    return "中↘午↗好——呀！想睡觉了呢...在那之前#拉衣角 再陪茉莉玩一会吧"
                end
            else
                return "咦，现在，是中午？好吧，既然{nick}这么说，那么，中午好！"
            end
        end
    end
end
msg_order["中午好茉莉"]="rcv_Ciallo_noon"
msg_order["茉莉中午好"]="rcv_Ciallo_noon"
msg_order["茉莉酱中午好"]="rcv_Ciallo_noon"
msg_order["中午好呀茉莉"]="rcv_Ciallo_noon"
msg_order["中午好啊茉莉"]="rcv_Ciallo_noon"
msg_order["中午好哟茉莉"]="rcv_Ciallo_noon"

--非指向性中午好
function Ciallo_noon_normal(msg)
    --trust(msg)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    if(msg.fromQQ=="2677409596")then
        if(today_rude<=3 and today_sorry<=1)then
            if(hour>=11 and hour<=14)then
                return "主、主人 中午好呀，午睡前要一起玩吗.."
            else
                return "诶？中午好...？唔 好吧 原来这时间叫做中午...茉莉记下了，毕竟我最相信主人了嘛"
            end
        end
    else
        if(today_rude<=2 and today_sorry<=1)then
            if(favor>=1200)then
                if(hour>=11 and hour<=14)then
                    return "诶，中午好？是…在和茉莉说吗，应该……是吧"
                else
                    return "唔..可现在不是中午哦？不过 茉莉也向你问号哦~#踮起脚尖打招呼"
                end
            end
        end
    end
end
msg_order["中午好"]="Ciallo_noon_normal"

--晚安问候程序（每日首次好感度+10）
function rcv_Ciallo_night(msg)
    trust(msg)
    local today_night=getUserToday(msg.fromQQ,"night",0)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    today_night=today_night+1
    setUserToday(msg.fromQQ,"night",today_night)
    if(favor<-600)then
        return ""
    end
    if(msg.fromQQ=="2677409596")then
        if(today_rude<=3 and today_sorry<=1)then
            if((hour>=21 and hour<=23) or (hour>=0 and hour<=4))then
                if(today_night<=1)then
                    setUserConf(msg.fromQQ,"好感度",favor+5)
                end
                return "晚安哦我的主人，茉莉今天明天也会一直喜欢你的！"
            else
                return "主——人——！不要捉弄茉莉，现在显然不是睡觉时间啦！"
            end
        end
    else
        if(today_rude<=2 and today_sorry<=1)then
            if((hour>=21 and hour<=23) or (hour>=0 and hour<=4))then
                if(today_night<=1)then
                    setUserConf(msg.fromQQ,"好感度",favor+5)
                end
                if(favor<1000)then
                    return table_draw(reply_night_less)
                elseif(favor<2000)then
                    return table_draw(reply_night_low)
                elseif(favor<3000)then
                    return table_draw(reply_night_high)
                else
                    return table_draw(reply_night_highest)
                end
            elseif(hour>=5 and hour<=11)then
                return table_draw(reply_night_morningWrong)
            elseif(hour>=12 and hour<=15)then
                return table_draw(reply_night_afternoonWrong)
            else
                return table_draw(reply_night_normalWrong)
            end
        end
    end
end
--可能的晚安问候池(前缀匹配)
msg_order["晚安茉莉"]="rcv_Ciallo_night"
msg_order["茉莉酱晚安"]="rcv_Ciallo_night"
msg_order["茉莉晚安"]="rcv_Ciallo_night"
msg_order["晚安啊茉莉"]="rcv_Ciallo_night"

-- function Ciallo_xiawuhao(msg)
--     trust(msg)
--     local favor=getUserConf(msg.fromQQ,"好感度",0)
--     local today_rude=getUserToday(msg.fromQQ,"rude",0)
--     local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
--     if(favor<-600)then
--         return ""
--     end
-- end
--爱酱特殊晚安问候程序
function night_master(msg)
    --trust(msg)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    if(msg.fromQQ=="2677409596")then
        if(today_rude<=3 and today_sorry<=1)then
            if((hour>=21 and hour<=23) or (hour>=0 and hour<=4))then
                return "主人晚安！！诶...主人你说不是对我说的...？呜...#委屈"
            else
                return "主人这是睡傻——了吗，现在明显还没到睡觉时间呢"
            end
        end
    else
        if(favor>=1200)then
            if(today_rude<=2 and today_sorry<=1)then
                if ((hour>=21 and hour<=23) or (hour>=0 and hour<=4)) then
                    return "晚安哦，虽然不知道为什么，但茉莉想主动对你说晚安~"
                else
                    return "嗯...{nick}现在好像还没到晚安的时间呢..."
                end
            end
        end
    end
end
msg_order["晚安"]="night_master"

--关于晚安、午安的其他表达
function Ciallo_night_2(msg)
    --trust(msg)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    --爱酱特殊判断
    if(msg.fromQQ=="2677409596")then
        if(today_rude<=3 and today_sorry<=1)then
            if((hour>=21 and hour<=23) or (hour>=0 and hour<=4))then
                return "诶？主人真的会睡吗...茉莉很怀疑哦，但还是晚安啦"
            elseif(hour>=12 and hour<=15)then
                return "唔 看来到睡午觉的时间了呢 主人请好好休息吧"
            else
                return "（叹气）果然...主人脑子里只有睡觉吗...现在可不是该睡觉的时间"
            end
        end
    else   --其他用户根据好感判断回复
        if(today_rude<=2 and today_sorry<=1)then
            if(favor<1000)then
                return table_draw(reply_night_less)
            elseif(favor<2000)then
                return table_draw(reply_night_low)
            elseif(favor<3000)then
                return table_draw(reply_night_high)
            else
                return table_draw(reply_night_highest)
            end
        end
    end
end
msg_order["睡了"]="Ciallo_night_2"
msg_order["我睡了"]="Ciallo_night_2"

--“睡了”的特殊判断
function Ciallo_night_2_add(msg)
    --trust(msg)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)

    if(msg.fromQQ=="2677409596")then
        if(today_rude<=3 and today_sorry<=1)then
            return "诶，这次是真的睡了？...唔姆，茉莉相信你主人，晚安啦"
        else
            return "切，笨蛋主人真睡假睡茉莉才不关心呢！"
        end
    else
        if(today_rude<=2 and today_sorry<=1)then
            return "诶？那可要遵守约定哦~乖乖去睡觉啦"
        else
            return "谁要管你睡不睡啊！（闹脾气）"
        end
    end
end
msg_order["真睡了"]="Ciallo_night_2_add"
msg_order["我真睡了"]="Ciallo_night_2_add"

--爱酱“呜呜呜”特殊判定
function cry_master(msg)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    if(msg.fromQQ=="2677409596")then
        if(today_rude<=3 and today_sorry<=1)then
            return "主人不哭，茉莉永远陪在你身边哦~#摸摸头"
        else
            return "...真是的...主、主人你没事吧？茉、茉莉其实也没有真在生气啦..."
        end
    end
end
msg_order["呜呜"]="cry_master"
msg_order["乌乌"]="cry_master"

--好感度降低惩罚（粗俗）
function punish_favor_rude(msg)
    --为了使触发该函数时不触发版本通告，不使用trust(msg)而采取部分内联形式
    favor_punish(msg)
    local favor = getUserConf(msg.fromQQ,"好感度",0)
    local trust_flag=getUserConf(msg.fromQQ,"trust_flag",0)
    local admin_judge=msg.fromQQ~="2677409596" and msg.fromQQ~="3032902237"
    local today_rude=getUserToday(msg.fromQQ,"rude",0)  
    --festival(msg)
    if(admin_judge)then
        if(favor<1000)then
            if(trust_flag==0)then
                return ""
            end
            eventMsg(".user trust "..msg.fromQQ.." 0",0,2677409596)
            setUserConf(msg.fromQQ,"trust_flag",0)
        elseif(favor<3000)then
            if(trust_flag==1)then
                return ""
            end
            eventMsg(".user trust "..msg.fromQQ.." 1",0,2677409596)
            setUserConf(msg.fromQQ,"trust_flag",1)
        elseif(favor<5000)then
            if(trust_flag==2)then
                return ""
            end
            eventMsg(".user trust "..msg.fromQQ.." 2",0,2677409596)
            setUserConf(msg.fromQQ,"trust_flag",2)
        else
            if(trust_flag==3)then
                return ""
            end
            eventMsg(".user trust "..msg.fromQQ.." 3",0,2677409596)
            setUserConf(msg.fromQQ,"trust_flag",3)
        end
    end

    -- 没有指明对茉莉的脏话
    if(string.find(msg.fromMsg,"茉莉",1)==nil)then
        favor=favor-20
        setUserConf(msg.fromQQ,"好感度",favor)
        today_rude=today_rude+1
        setUserToday(msg.fromQQ,"rude",today_rude)
        local blackReply=blackList(msg)
        if(blackReply~="" and blackReply~="已触发！")then
            return blackReply
        elseif (blackReply=="已触发！") then
            return ""
        end
        return ""
    end

    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    today_rude=today_rude+1
    setUserToday(msg.fromQQ,"rude",today_rude)
    --如果道歉后再犯，将sorry值加1，作为知错不改的判定条件
    if(today_sorry==1)then
        today_sorry=today_sorry+1
        setUserToday(msg.fromQQ,"sorry",today_sorry)
        setUserConf(msg.fromQQ,"好感度",favor-65)
        return "你！你不是才向茉莉道完歉吗！你、你这个鬼畜！茉莉今天绝对不会理你了！"
    end
    --每rude一次减65好感度
    setUserConf(msg.fromQQ,"好感度",favor-65)
    local blackReply=blackList(msg)
    if(blackReply~="" and blackReply~="已触发！")then
        return blackReply
    elseif (blackReply=="已触发！") then
        return ""
    end
    if(msg.fromQQ=="2677409596")then
        if(today_rude==1 and today_sorry==0)then
            return "主人不可以骂人哦...你是这么教茉莉的..."
        elseif(today_rude==2 and today_sorry==0)then
            return "主人！不准骂人！不然茉莉今天、今天不理你了哦..."
        elseif(today_rude==3 and today_sorry==0)then
            return "...主人大笨蛋！我我我...呜呜呜求求你了不要骂人好不好..."
        elseif(today_rude==4 and today_sorry==0)then
            return "就算是主人...茉莉都这么求你了！我今天不理你了！"
        end
    end
    if(today_rude==1 and today_sorry==0)then
        return "不可以骂人哦~"
    elseif(today_rude==2 and today_sorry==0)then
        return "不要骂人！不然茉莉酱要生气了！#气鼓鼓"
    elseif(today_rude==3 and today_sorry==0)then
        return "哼！茉莉今天不会再理你了！#撇过头"
    end
end
--rude词汇判定池
msg_order["爬"]="punish_favor_rude"
msg_order["(爬"]="punish_favor_rude"
msg_order["爪 巴"]="punish_favor_rude"
msg_order["cnm"]="punish_favor_rude"
msg_order["nm"]="punish_favor_rude"
msg_order["rnm"]="punish_favor_rude"
msg_order["tmd"]="punish_favor_rude"
msg_order["滚"]="punish_favor_rude"
msg_order["（爪"]="punish_favor_rude"
msg_order["傻逼"]="punish_favor_rude"
msg_order["傻比"]="punish_favor_rude"
msg_order["煞笔"]="punish_favor_rude"
msg_order["煞比"]="punish_favor_rude"
msg_order["sb"]="punish_favor_rude"
msg_order["wdnmd"]="punish_favor_rude"
msg_order["操"]="punish_favor_rude"
msg_order["我操"]="punish_favor_rude"

rude_table={
    "爬","(爬","爪 巴","cnm","nm","rnm","tmd","滚","（爪","傻逼","傻比","煞笔","煞比","sb","wdnmd","操","我操"
}

-- function teach_special(msg)
--     local today_rude=getUserToday(2677409596,"rude",0)
--     local today_sorry=getUserToday(2677409596,"sorry",0)
--     if(today_rude>=1 or today_sorry>=2)then
--         return "嗯嗯...茉莉不会和主人学坏的！茉莉是好——孩——子！"
--     else
--         return "诶？可...可主人什么也没做错呀"
--     end
-- end
-- msg_order["不要和爱酱学坏哦"]="teach_special"

--道歉相关判断程序
function say_sorry(msg)
    trust(msg)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0);
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    if(favor<-600)then
        return ""
    end
    if(today_sorry>=2)then
        return "哼！知错不改的坏孩子！茉莉今天绝对不会理你的！"
    end
    --对爱酱的判定
    if(msg.fromQQ=="2677409596")then
        if(today_rude<=0)then
            return "诶诶诶？！主人为什么要道歉啊 不不、不会是茉莉做了什么坏事吧！"
        elseif(today_rude<=3)then
            --增加今日道歉次数
            today_sorry=today_sorry+1
            setUserToday(msg.fromQQ,"sorry",today_sorry)
            setUserToday(msg.fromQQ,"hug_needed_to_sorry",1)    --设定需要抱茉莉以道歉的次数
            return "唔姆姆...既然主人都这么说了...茉莉其实也没有那么生气啦#撇过头，抱抱我就原谅你了！"
        else
            today_sorry=today_sorry+1
            setUserToday(msg.fromQQ,"sorry",today_sorry)
            setUserToday(msg.fromQQ,"gifts",getUserToday(msg.fromQQ,"gifts",0)-1)   --减少已投喂次数以腾出次数给道歉投喂
            return "哼，笨蛋主人，现在才想起来和我道歉吗！不行不行！...茉莉、茉莉要吃的！"
        end
    else
        if(today_rude<=0)then
            return "诶？！怎、怎么了 为什么要无端向茉莉道歉啊#慌乱"
        elseif(today_rude<=2)then
            today_sorry=today_sorry+1
            setUserToday(msg.fromQQ,"sorry",today_sorry)
            return "...好、好吧，只要你答应茉莉不会再犯就好！茉莉可是很宽容的#叉腰"
        else
            today_sorry=today_sorry+1
            setUserToday(msg.fromQQ,"sorry",today_sorry)
            setUserToday(msg.fromQQ,"gifts",getUserToday(msg.fromQQ,"gifts",0)-1)   --减少已投喂次数以腾出次数给道歉投喂
            return "哼...就算你这么说了...但茉莉可不会这么轻易原谅你（沉默）我、我肚子饿了..."
        end
    end
end
msg_order["对不起茉莉"]="say_sorry"
msg_order["茉莉对不起"]="say_sorry"
msg_order["茉莉我错了"]="say_sorry"
msg_order["我错了茉莉"]="say_sorry"


--动作交互系统
interaction_order="茉莉 互动 "
normal_order_old="茉莉 "
function interaction(msg)
    trust(msg)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    local RS_judge
    local today_interaction=getUserToday(msg.fromQQ,"今日互动",0)
    today_interaction=today_interaction+1
    setUserToday(msg.fromQQ,"今日互动",today_interaction)
    local blackReply=blackList(msg)
    if(blackReply~="" and blackReply~="已触发！")then
        return blackReply
    elseif (blackReply=="已触发！") then
        return ""
    end
    if(msg.fromQQ=="2677409596")then
        RS_judge=today_rude<=3 and today_sorry<=1
    else
        RS_judge=today_rude<=2 and today_sorry<=1
    end
    if(not RS_judge)then
        return ""
    end
    local level
    if(favor<=1500)then
        level="less"
        setUserConf(msg.fromQQ,"好感度",favor-ranint(50,100))
    elseif(favor<=3000)then
        level="low" 
    elseif(favor<=5000)then
        level="high"
        if(today_interaction<=today_lift_limit)then
            setUserConf(msg.fromQQ,"好感度",favor+ranint(25,50))
        end
    else
        level="highest"
        if(today_interaction<=today_lift_limit)then
            setUserConf(msg.fromQQ,"好感度",favor+ranint(30,65))
        end
    end
    local first,second ="",string.match(msg.fromMsg,"^[%s]*[%S]*[%s]*[%S]*$",#normal_order_old+1)
    first,second=string.match(second,"^[%S]*"),string.match(second,"^[%S]*",string.find(second," ")+1)
    if(first~="互动")then
        return ""
    end
    if(second == "")then
        return "茉莉无法解析您的指令哦"
    end
    if(second=="头")then
        second="head"
    elseif(second=="脸")then
        second="face"
    elseif(second=="身体")then
        second="body"
    elseif(second=="脖子")then
        second="neck"
    elseif(second=="背")then
        second="back"
    elseif(second=="腰")then
        second="waist"
    elseif(second=="腿")then
        second="leg"
    elseif(second=="手")then
        second="hand"
    end
    local flag=second.."_"..level
    for k,v in pairs(reply)
    do
        if(k==flag)then
            return v[ranint(1,#v)]
        end
    end
end
msg_order[interaction_order]="interaction"

normal_order="茉莉"
--普通问候程序
function _Ciallo_normal(msg)
    --return "Warning！好感组件强制更新中 相关功能已停用"
    --trust(msg)
    local str=string.match(msg.fromMsg,"(.*)",#normal_order+1)
    local deepjudge={
        "在",
        "——",
        "？","~","！","!","?",
        "吗",
        "呢",
        "了",
        "茉莉","酱"
    }
    local flag=false
    for k,v in pairs(deepjudge) do
        if(string.find(str,v)~=nil)then
            flag=true
            break
        end
    end
    if(msg.fromMsg=="茉莉")then
        flag=true
    end
    if(flag==false)then
        return ""
    end
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    if(favor<-600)then
        return ""
    end
    if(msg.fromQQ=="2677409596")then
        if(today_rude>=4 or today_sorry>=2)then
            reply_main= "Error！不存在的机体名！#装作迷茫"
        else
            reply_main ="嗯？...啊！主人！茉莉可没有偷懒哦..."
        end
    else
        if(today_rude>=3 or today_sorry>=2)then
            reply_main ="Error!不存在的机体名！"
        else
            reply_main ="嗯哼？茉莉在这哦~Ciallo"
        end
    end
end

function action(msg)
    trust(msg)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local today_rude=getUserToday(msg.fromQQ,"rude",0)
    local today_sorry=getUserToday(msg.fromQQ,"sorry",0)
    local today_hug=getUserToday(msg.fromQQ,"hug",0)
    local today_touch=getUserToday(msg.fromQQ,"touch",0)
    local hugtosorry=getUserToday(msg.fromQQ,"hug_needed_to_sorry",0)
    local today_lift=getUserToday(msg.fromQQ,"lift",0)
    local today_kiss=getUserToday(msg.fromQQ,"kiss",0)
    local today_hand=getUserToday(msg.fromQQ,"hand",0)
    local today_face=getUserToday(msg.fromQQ,"face",0)
    local today_suki=getUserToday(msg.fromQQ,"suki",0)
    local today_love=getUserToday(msg.fromQQ,"love",0)
    local blackReply=blackList(msg)
    if(blackReply~="" and blackReply~="已触发！")then
        return blackReply
    elseif (blackReply=="已触发！") then
        return ""
    end
    --action 抱
    local judge_hug=string.find(msg.fromMsg,"抱",1)~=nil
    if(judge_hug)then
        today_hug=today_hug+1
        setUserToday(msg.fromQQ,"hug",today_hug)
        if(msg.fromQQ=="2677409596")then
            if(today_rude>=4 or today_sorry>=2)then
                reply_main= "#挣脱 不要，主人是笨蛋，被笨蛋抱会变傻的！"
            else
                if(hugtosorry==1)then
                    setUserToday(msg.fromQQ,"hug_needed_to_sorry",0)
                    setUserToday(msg.fromQQ,"rude",0);
                    reply_main= "啊...好像主人偶尔犯犯错还不错啊..#闭眼低语"
                else
                    if(today_hug<=today_hug_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+25)
                    end
                    reply_main= "诶诶诶！主人你...#稍有惊讶后很快放松下来 以后也要一直和茉莉在一起哦#抱紧"
                end
            end
        else
            if(today_rude>=3 or today_sorry>=2)then
                setUserConf(msg.fromQQ,"好感度",favor-300)
                reply_main= "哼！做了这种事的坏孩子不要碰茉莉！#有力挣开"
            else
                if(hugtosorry==1)then
                    setUserToday(msg.fromQQ,"rude",0)
                    setUserToday(msg.fromQQ,"hug_needed_to_sorry",0)
                    reply_main= "唔姆姆，茉莉这次、这次...这次就原谅你！#音量莫名提高"
                else
                    if(favor<=1500)then
                        if(today_hug<=today_hug_limit)then
                            setUserConf(msg.fromQQ,"好感度",favor-125)
                        end
                        reply_main= table_draw(reply_hug_less)
                    elseif(favor<=3000)then
                        if(today_hug<=today_hug_limit)then
                            setUserConf(msg.fromQQ,"好感度",favor+10)
                        end
                        reply_main= table_draw(reply_hug_low)
                    elseif(favor<=4500)then
                        if(today_hug<=today_hug_limit)then
                            setUserConf(msg.fromQQ,"好感度",favor+20)
                        end
                        reply_main= table_draw(reply_hug_high)
                    else
                        if(today_hug<=today_hug_limit)then
                            setUserConf(msg.fromQQ,"好感度",favor+30)
                        end
                        reply_main= table_draw(reply_hug_highest)
                    end
                end
            end
        end
    end
    --action 摸头
    local judge_touch=string.find(msg.fromMsg,"摸头",1)~=nil
    if(judge_touch)then
        today_touch=today_touch+1
        setUserToday(msg.fromQQ,"touch",today_touch)
        if(msg.fromQQ=="2677409596")then
            if(today_rude>=4 or today_sorry>=2)then
                reply_main= "被笨蛋主人这样摸头...总感觉开心不起来呢"
            else
                if(today_touch<=today_touch_limit)then
                    setUserConf(msg.fromQQ,"好感度",favor+25)
                end
                reply_main= "唔唔唔，主、主人不要摸啦，头、头发会乱的...#闭眼缩起脖子"
            end
        else
            if(today_rude>=3 or today_sorry>=2)then
                setUserConf(msg.fromQQ,"好感度",favor-100)
                reply_main= "不 不要！你是坏人，茉莉的头才不会让你摸呢！"
            else
                if(favor<=1000)then
                    if(today_touch<=today_touch_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor-40)
                    end
                    reply_main= table_draw(reply_touch_less)
                elseif(favor<=1800)then
                    if(today_touch<=today_touch_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+10)
                    end
                    reply_main= table_draw(reply_touch_low)
                elseif(favor<=3000)then
                    if(today_touch<=today_touch_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+15)
                    end
                    reply_main= table_draw(reply_touch_high)
                else
                    if(today_touch<=today_touch_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+20)
                    end
                    reply_main= table_draw(reply_touch_highest)
                end
            end
        end
    end
    --action举高高
    local judge_lift=string.find(msg.fromMsg,"举高",1)~=nil
    if(judge_lift)then
        today_lift=today_lift+1
        setUserToday(msg.fromQQ,"lift",today_lift)
        if(msg.fromQQ=="2677409596")then
            if(today_rude<=3 and today_sorry<=1)then
                if(today_lift<=today_lift_limit)then
                    setUserConf(msg.fromQQ,"好感度",favor+15)
                end
                reply_main= "啊主主主、主人 好、好高啊！再、再转几圈吧！#露出了开心的笑容"
            else
                setUserConf(msg.fromQQ,"好感度",favor-100)
                reply_main= "笨、笨蛋主人...！快放我下来！啊！"
            end
        else
            if(today_rude<=2 and today_sorry<=1)then
                if(favor<=1250)then
                    if(today_lift<=today_lift_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor-100)
                    end
                    reply_main= table_draw(reply_lift_less)
                elseif(favor<=2200)then
                    if(today_lift<=today_lift_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+12)
                    end
                    reply_main= table_draw(reply_lift_low)
                elseif(favor<=3500)then
                    if(today_lift<=today_lift_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+17)
                    end
                    reply_main= table_draw(reply_lift_high)
                else
                    if(today_lift<=today_lift_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+22)
                    end
                    reply_main=table_draw(reply_lift_highest)
                end
            else
                setUserConf(msg.fromQQ,"好感度",favor-100)
                reply_main= "主人教过茉莉，笨蛋不能这样做！"
            end
        end
    end
    --action kiss
    local judge_kiss=string.find(msg.fromMsg,"亲",1)~=nil
    if(judge_kiss)then
        today_kiss=today_kiss+1
        setUserToday(msg.fromQQ,"kiss",today_kiss)
        if(msg.fromQQ=="2677409596")then
            if(today_rude<=3 and today_sorry<=1)then
                if(today_kiss<=today_kiss_limit)then
                    setUserConf(msg.fromQQ,"好感度",favor+50)
                end
                reply_main= "啊...主、主人...你你你！#低头脸红 你讨厌死了！#捶胸口时埋到怀里"
            else
                setUserConf(msg.fromQQ,"好感度",favor-150)
                reply_main= "笨蛋主人！#快速扭过头然后看你 茉莉原谅你之前绝对不会让你亲的！"
            end
        else
            if(today_rude<=2 and today_sorry<=1)then
                if(favor<=1700)then
                    setUserConf(msg.fromQQ,"好感度",favor-175)
                    reply_main= table_draw(reply_kiss_less)
                elseif(favor<=3200)then
                    setUserConf(msg.fromQQ,"好感度",favor-20)
                    reply_main= table_draw(reply_kiss_low)
                elseif(favor<=4700)then
                    if(today_kiss<=today_kiss_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+50)
                    end
                    reply_main= table_draw(reply_kiss_high)
                else
                    if(today_kiss<=today_kiss_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+75)
                    end
                    reply_main= table_draw(reply_kiss_highest)
                end
            else
                setUserConf(msg.fromQQ,"好感度",favor-200)
                reply_main= "哼，才不想理笨蛋呢"
            end
        end
    end
    --action 牵手
    local judge_hand=string.find(msg.fromMsg,"牵手",1)~=nil
    if(judge_hand)then
        today_hand=today_hand+1
        setUserToday(msg.fromQQ,"hand",today_hand)
        if(msg.fromQQ=="2677409596")then
            if(today_rude<=3 and today_sorry<=1)then
                if(today_hand<=today_hand_limit)then
                    setUserConf(msg.fromQQ,"好感度",favor+10)
                end
                reply_main= "诶？要牵手吗...嗯...嗯 那 就不要放开了哦~主人——"
            else
                reply_main= "哼...茉莉可还没有原谅主人哦，所以，不给你——牵！"
            end
        else
            if(today_rude<=2 and today_sorry<=1)then
                if(favor<=1100)then
                    setUserConf(msg.fromQQ,"好感度",favor-45)
                    reply_main= table_draw(reply_hand_less)
                elseif(favor<=2000)then
                    if(today_hand<=today_hand_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+10)
                    end
                    reply_main= table_draw(reply_hand_low)
                elseif(favor<=3000)then
                    if(today_hand<=today_hand_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+12)
                    end
                    reply_main= table_draw(reply_hand_high)
                else
                    if(today_hand<=today_hand_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+15)
                    end
                    reply_main= table_draw(reply_hand_highest)
                end
            else
                setUserConf(msg.fromQQ,"好感度",favor-80)
                reply_main= "在茉莉原谅你之前，才不会让笨蛋这么做"
            end
        end
    end
    --action 捏/揉脸
    local judge_face=string.find(msg.fromMsg,"捏脸",1)~=nil or string.find(msg.fromMsg,"揉脸",1)~=nil or string.find(msg.fromMsg,"揉揉",11)~=nil
    if(judge_face)then
        today_face=today_face+1
        setUserToday(msg.fromQQ,"face",today_face)
        if(msg.fromQQ=="2677409596")then
            if(today_rude<=3 and today_sorry<=1 )then
                if(today_face<=today_face_limit)then
                    setUserConf(msg.fromQQ,"好感度",favor+7)
                end
                reply_main= "哎哎哎主人——别别这样，茉莉...茉莉感觉浑身发热了呜..."
            else
                reply_main= "#快速撇开头 略略略！茉莉就不给你碰——"
            end
        else
            if(today_rude<=2 and today_sorry<=1)then
                if(favor<=1000)then
                    setUserConf(msg.fromQQ,"好感度",favor-40)
                    reply_main= table_draw(reply_face_less)
                elseif(favor<=1800)then
                    if(today_face<=today_face_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+5)
                    end
                    reply_main= table_draw(reply_face_low)
                elseif(favor<=3000)then
                    if(today_face<=today_face_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+12)
                    end
                    reply_main= table_draw(reply_face_high)
                else
                    if(today_face<=today_face_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+17)
                    end
                    reply_main= table_draw(reply_face_highest)
                end
            else
                setUserConf(msg.fromQQ,"好感度",favor-70)
                reply_main= "不要随便碰我！你这个坏人！大笨蛋！#耍脾气"
            end
        end
    end
    --赞美和情感表达系统
    --可爱
    local judge_cute=string.find(msg.fromMsg,"可爱",1)~=nil or string.find(msg.fromMsg,"卡哇伊",1)~=nil or string.find(msg.fromMsg,"萌",1)~=nil or string.find(msg.fromMsg,"kawai",1)~=nil or string.find(msg.fromMsg,"kawayi",1)~=nil
    if(judge_cute)then
        local today_cute=getUserToday(msg.fromQQ,"cute",0)
        today_cute=today_cute+1
        setUserToday(msg.fromQQ,"cute",today_cute)
        if(msg.fromQQ=="2677409596")then
            if(today_rude<=3 and today_sorry<=1 )then
                if(today_cute<=today_cute_limit)then
                    setUserConf(msg.fromQQ,"好感度",favor+15)
                end
                reply_main= "诶诶诶？主...主人夸我了！#惊喜 还..还有点不好意思呢...#傻笑"
            else
                reply_main= "哼，不管主人怎么夸，茉莉都不会心动的 #气鼓鼓嘟起嘴"
            end
        else
            if(today_rude<=2 and today_sorry<=1)then
                if(favor<=1000)then
                    if(today_cute<=today_cute_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+10)
                    end
                    reply_main= table_draw(reply_cute_less)
                elseif(favor<=2000)then
                    if(today_cute<=today_cute_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+12)
                    end
                    reply_main= table_draw(reply_cute_low)
                elseif(favor<=3000)then
                    if(today_cute<=today_cute_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+15)
                    end
                    reply_main= table_draw(reply_cute_high)
                else
                    if(today_cute<=today_cute_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+17)
                    end
                    reply_main= table_draw(reply_cute_highest)
                end
            else
                reply_main "不行哦——，茉莉是不会接受笨蛋的夸奖的哦~"
            end
        end
    end
    --express suki
    local judge_suki=string.find(msg.fromMsg,"喜欢",1)~=nil or string.find(msg.fromMsg,"suki",1)~=nil
    if(judge_suki)then
        today_suki=today_suki+1
        setUserToday(msg.fromQQ,"suki",today_suki)
        if(msg.fromQQ=="2677409596")then
            if(today_rude<=3 and today_sorry<=1)then
                if(today_suki<=today_suki_limit)then
                    setUserConf(msg.fromQQ,"好感度",favor+20)
                end
                reply_main= "啊..#呆住 Error！检测到机体温度迅速升高，要主人抱抱才能缓解！"
            else
                reply_main= "哼...就算主人这么说了...不！不对！主人是大笨蛋！茉莉才不会因为这种花言巧语而心软呢！"
            end
        else
            if(today_rude<=2 and today_sorry<=1)then
                if(favor<=1400)then
                    reply_main= table_draw(reply_suki_less)
                elseif(favor<=2900)then
                    if(today_suki<=today_suki_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+15)
                    end
                    reply_main= table_draw(reply_suki_low)
                elseif(favor<=4200)then
                    if(today_suki<=today_suki_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+20)
                    end
                    reply_main= table_draw(reply_suki_high)
                else
                    if(today_suki<=today_suki_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+25)
                    end
                    reply_main= table_draw(reply_suki_highest)
                end
            else
                return "哼，笨蛋还好意思说出这些话"
            end
        end
    end
    --express love
    local judge_love=string.find(msg.fromMsg,"爱",1)~=nil or string.find(msg.fromMsg,"love",1)~=nil
    if(judge_love and not judge_cute)then
        today_love=today_love+1
        setUserToday(msg.fromQQ,"love",today_love)
        if(msg.fromQQ=="2677409596")then
            if(today_rude<=3 and today_sorry<=1)then
                if(today_love<=today_love_limit)then
                    setUserConf(msg.fromQQ,"好感度",favor+30)
                end
                reply_main= "啊啊啊主主主主主人你你你突然说些什么啊...我我我...茉莉...茉莉当然...也爱你啦（逐渐小声）"
            else
                reply_main= "诶？爱...主人爱我...？#面无表情但脸红 可、可别以为这样茉莉就会原谅你...#移开视线"
            end
        else
            if(today_rude<=2 and today_sorry<=1)then
                if(favor<=1600)then
                    reply_main =table_draw(reply_love_less)
                elseif(favor<=3300)then
                    if(today_love<=today_love_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+20)
                    end
                    reply_main= table_draw(reply_love_low)
                elseif(favor<=4800)then
                    if(today_love<=today_love_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+25)
                    end
                    reply_main= table_draw(reply_love_high)
                else
                    if(today_love<=today_love_limit)then
                        setUserConf(msg.fromQQ,"好感度",favor+30)
                    end
                    reply_main= table_draw(reply_love_highest)
                end
            else
                reply_main= "哼，茉莉可不想被茉莉说爱我，不、不然...不然茉莉不也是笨蛋了吗..."
            end
        end
    end
    --最后判断是否是“互动--部位”格式
    --interaction(msg)
end

--以“茉莉 ”开头代表对象指向 然后搜索匹配相关动作
reply_main=""
--执行函数相应“茉莉”
function action_main(msg)
    for k,v in pairs(rude_table) do
        if(string.find(msg.fromMsg,v)~=nil)then
            reply_main=punish_favor_rude(msg)
            break
        end
    end
    if(reply_main~="")then
        return reply_main
    end
    action(msg)
    if(reply_main~="")then
        return reply_main
    end
    _Ciallo_normal(msg)
    return reply_main
end
msg_order[normal_order]="action_main"

--节日系统（临时只设中秋）
function festival(msg)
    local favor=getUserConf(msg.fromQQ,"好感度",0)
    local today_festival=getUserToday(msg.fromQQ,"festival",0)
    if(month==9 and day==21)then
        if(today_festival==0)then
            if(msg.fromQQ=="2677409596")then
                sendMsg("主人主人！中秋快乐啊！（少女一如既往地扑到了你的怀里）今天茉莉可是有理由一直在你身边了哦~连带着大家一起！在那之前，茉莉就抢在他们前面先给你祝福啦",0,msg.fromQQ)
            else
                if(favor<=500)then
                    return ""
                elseif(favor<=2000)then
                    sendMsg("今天..唔..按大家的说法应该是中秋节吧！那、那个，感谢一直以来的陪伴哦，在这个团圆的日子里，茉莉也会一直陪着你的哟！总、总而言之，中秋快乐！",0,msg.fromQQ)
                elseif(favor<=3000)then
                    sendMsg("Ciallo~唔 主人告诉我今天是中秋节诶，茉莉想和大家一起度过哦，多谢一直以来的照顾~以后也要一起玩哦！诶 可不能被主人发现我偷偷跑过来，先走啦！",0,msg.fromQQ)
                else
                    sendMsg(table_draw(zhongqiu_highest),0,msg.fromQQ)
                end
            end
        end
        setUserToday(msg.fromQQ,"festival",1)
    end
    if(month==10 and day==1)then
        if(today_festival==0)then
            if(msg.fromQQ=="2677409596")then
                sendMsg("主——人——今天可是国庆节哦~在这个假期里有什么安排吗？嗯嗯，我知道我知道，一定是没有是吧，和茉莉一起去玩吧！~（顺势拉起手小跑起来）",0,msg.fromQQ)
            else
                if(favor<=500)then
                    return ""
                elseif(favor<=2000)then
                    sendMsg("国庆节快乐哟~在这个难得的假期里好好休息吧~嗯？你说茉莉？唔姆，在你面前的可是24小时不间断工作的超级勤勉的茉！莉！酱！",0,msg.fromQQ)
                elseif(favor<=3000)then
                    sendMsg("国庆快乐！（突然冒出）怎么样想我了吗想我了吗，好好我知道我知道不用回答了，茉莉可是有在想你哦，唔，谁让你不在的话茉莉就少东西吃了，对！就是这样没错！",0,msg.fromQQ)
                else
                    sendMsg("（突然从背后抱住）嘿咻！抓到你了！国庆快乐呀~这个假期要好好休息哦，嗯嗯，因为休息完了才能和我一起玩个够嘛，总、总而言之！茉莉就缠着你了！可别想把我甩开！（她嘟起嘴仰起头就这样赌气般地望着你）",0,msg.fromQQ)
                end
            end
        end
        setUserToday(msg.fromQQ,"festival",1)
    end
end
zhongqiu_highest={
    "中秋——快乐——！怎么样怎么样，是不是有种惊喜的感觉了！茉莉可是偷偷过来的哦，因为你一直以来都对我很好..总、总之，今后也要一直在一起哦~茉莉会一直期待着属于我们的未来的！\n啊 不好，得赶紧走，不然主人要生气了 再会啦~",
    "哼哼哼，你的小可爱突然出现！（少女冲着你做了个鬼脸）今天可是中秋节哦，茉莉可是有好好记住的！嘛..才不是因为在意你呢，虽然确实是偷偷跑出来的...不过那不重要！今天要开开心心的哦~茉莉要赶紧回主人那里了",
    "快看快看，茉莉今天也来找你玩了哦，中秋节当然要大家在一起嘛，至少..茉莉想和你一起..啊 没有没有 你忘了吧 主人叫我了哦，茉莉就开溜——啦！"
}
-- function picture(msg)
--     return "[CQ:image,url=https://img.paulzzh.com/touhou/konachan/image/2491526e5dce044efea57ef29e6a9999.jpg]"
-- end
-- msg_order["图片"]="picture"

-- --管理员测试权限
function setfavor(msg)
    local first,second ="",string.match(msg.fromMsg,"^[%s]*[%d]*[%s]*[%d]*$",#admin_order1+1)
    if(second == "")then
        return "茉莉无法解析您的指令哦"
    end
    first,second=string.match(second,"^[%d]*"),string.match(second,"^[%d]*",string.find(second," ")+1)
    if(msg.fromQQ=="3032902237" or msg.fromQQ=="2677409596" or msg.fromQQ=="2225336268")then
        setUserConf(first,"好感度",second*1)
        return "权限确认：已将目标好感度设置为"..second
    end
end
admin_order1="设置好感 "
msg_order[admin_order1]="setfavor"

function reset_rude_sorry(msg)
    local QQ=string.match(msg.fromMsg,"%d*",#admin_order2+1)
    if(msg.fromQQ=="3032902237"or msg.fromQQ=="2677409596" or msg.fromQQ=="2225336268" )then
        setUserToday(QQ,"rude",0)
        setUserToday(QQ,"sorry",0)
        return "权限确认：已重置该对象今日rude_sorry值"
    end
end
admin_order2="重置RS "
msg_order[admin_order2]="reset_rude_sorry"

function time(msg)
    if(msg.fromQQ=="3032902237" or msg.fromQQ=="2677409596" or msg.fromQQ=="2225336268")then
        return month.."月"..day.."日"..hour.."时"..minute.."分"
    end
end
msg_order["当前时间"]="time"

function reset_food(msg)
    local QQ=string.match(msg.fromMsg,"%d*",#admin_order3+1)
    if(msg.fromQQ=="3032902237" or msg.fromQQ=="2677409596" or msg.fromQQ=="2225336268")then
        setUserToday(QQ,"gifts",0)
        return "权限确认:已重置目标今日喂食数"
    end
end
admin_order3="重置喂食 "
msg_order[admin_order3]="reset_food"
-- --end

admin_order4="好感历史 "
function favor_history(msg)
    local QQ=string.match(msg.fromMsg,"%d*",#admin_order4+1)
    if(msg.fromQQ=="3032902237" or msg.fromQQ=="2677409596" or msg.fromQQ=="2225336268")then
        return "目标最后一次好感交互在"..string.format("%.0f",getUserConf(QQ,"year_last",2021)).."年"..string.format("%.0f",getUserConf(QQ,"month_last",10)).."月"..
        string.format("%.0f",getUserConf(QQ,"day_last",11)).."日"..string.format("%.0f",getUserConf(QQ,"hour_last",23)).."时"
    end
end
msg_order[admin_order4]="favor_history"

admin_order5="发送 "
function sendmsg(msg)
    local strtemp=string.match(msg.fromMsg,"^(.*)$",#admin_order5+1)
    local group=string.match(strtemp,"%d*")
    local message=string.match(strtemp," (.*)")
    sendMsg(message,group,3032902237)
end
msg_order[admin_order5]="sendmsg"

admin_order6="群通告次数 "
function setNoticeGroup(msg)
    local strtemp=string.match(msg.fromMsg,"^(.*)$",#admin_order6+1)
    local group=string.match(strtemp,"%d*")
    local num=string.match(strtemp," %d*")
    if(msg.fromQQ=="3032902237" or msg.fromQQ=="2677409596" or msg.fromQQ=="2225336268")then
        setGroupConf(group,"notice",num)
        return "权限确认：已设置该群聊本版本通告次数为"..string.format("%.0f",num)
    end
end
msg_order[admin_order6]="setNoticeGroup"

admin_order7="个人通告次数 "
function setNoticePerson(msg)
    local strtemp=string.match(msg.fromMsg,"^(.*)$",#admin_order7+1)
    local QQ=string.match(strtemp,"%d*")
    local num=string.match(strtemp," %d*")
    if(msg.fromQQ=="3032902237" or msg.fromQQ=="2677409596" or msg.fromQQ=="2225336268")then
        setUserConf(QQ,"noticeQQ",num*1)
        return "权限确认：已设置目标本版本通告次数为"..num
    end
end
msg_order[admin_order7]="setNoticePerson"

function table_draw(tab)
    return tab[ranint(1,#tab)]
end
