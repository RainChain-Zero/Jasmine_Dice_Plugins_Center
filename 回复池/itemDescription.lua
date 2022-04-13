-- --[[
--     @author 慕北_Innocent(RainChain)
--     @version 1.1
--     @Created 2022/01/30 19:06
--     @Last Modified 2022/01/31 17:53
--     ]] -- 物品描述
-- Item = {
--     ["FL"] = "全名叫做Flucting Light,亮银色的纸币，通用的货币，也可以转化为数字货币来开放电子设备的权限",
--     ["雪花糖"] = "其实是奶糖，但加入了一点薄荷，在香醇的同时添上几分清凉\n效果：送给茉莉后增加10好感度",
--     ["袋装曲奇"] = "你问为什么雪花糖没有袋装？是为了防止茉莉蛀牙\n效果：送给茉莉后每天增加20好感（需要进行好感交互才会触发），持续三天，效果不可叠加",
--     ["快乐水"] = "打开来冒着气泡的快乐水，不负责参与红蓝之争\n效果：送给茉莉后增加20好感",
--     ["pocky"] = "一袋经典pocky，不过上面裹的巧克力可不是重点，使用的方式可能更重要\n效果：送给茉莉后增加30好感；其他用途：？？？",
--     ["彩虹糖"] = "一袋彩虹糖，色彩不同，口味不同，惊喜不同\n效果：送给茉莉后从三种效果中随机得到一种",
--     ["推理小说"] = "茉莉在看推理小说时经常进入心流，可以出来她很喜欢这类书\n效果:使用后每次触发好感时间惩罚时降低的好感减少，效果持续5天，同类效果取最高\n注意：触发时道具效果已消失，则不会获得降低好感减少的加成。例：前5天没交互，在第六天进行交互，而道具已过期，减少的好感依旧为6天的量",
--     ["好感度"] = "用于指示和茉莉亲密关系的重要指标，具有很高的参考价值",
--     ["梦的开始"] = "一把象牙白的钥匙，晶莹剔透，不知道是用什么制作的，或许能开启什么",
--     ["未言的期待"] = "茉莉最喜欢牌子的棒棒糖，在你向她诉说些什么时给你的，听她说棒棒糖有魔力\n效果：附加永久增益：使「打工」时间缩减10%",
--     ["永恒之戒"] = "泛着耀眼光芒的钻戒，传说只有纯粹和心意相通的两人才能使其绽放出流光溢彩的永恒之光吧。\n“谁也没有见过风，更别说我和你了；谁都没有见过爱情，直到有花束抛向自己”\n效果：？？？"
-- }
-- -- 可以售卖的商品
-- ItemShop = {
--     ["雪花糖"] = {price = "10FL一颗"},
--     ["袋装曲奇"] = {price = "50FL一袋"},
--     ["快乐水"] = {price = "20FL一瓶"},
--     ["pocky"] = {price = "50FL一袋"},
--     ["彩虹糖"] = {price = "50FL一袋"},
--     ["推理小说"] = {price = "100FL一本"}
-- }

-- -- 用来赠送给茉莉的礼物
-- Gift_list = {
--     ["雪花糖"] = {
--         favor = 10,
--         reply = "“谢谢——”一声道谢后，少女将奶糖放进嘴里，嘴角不自觉地弯了起来"
--     },
--     ["袋装曲奇"] = {
--         favor = 20, -- 持续三天 每天增加20
--         reply = "“给茉莉的？好耶，你也来一块吧”眼前的少女笑着从袋子里拿出来几块递给你"
--     },
--     ["推理小说"] = {
--         -- 持续5天 降低时间惩罚减少的好感度 降低百分之多少
--         favorPunishDownRate = 0.3,
--         reply = "“新的推理小说？好久没看了的说”少女接过小说，小心翼翼拆开包装\n“欸——坏人肯定是这家伙吧”"
--     },
--     ["快乐水"] = {
--         favor = 20,
--         reply = "“咕噜咕噜”少女喝了几口快乐水，露出了满足的神情\n“好喝——！”"
--     },
--     ["pocky"] = {
--         favor = 30,
--         reply = "你抽出一根pocky，在少女眼前晃了晃。“一起吃？为什么？”\n“唔唔……唔……唔？！”"
--     },
--     ["彩虹糖"] = {
--         favor = 0,
--         reply = "出现异常，请联系系统管理员"
--     }
-- }

-- -- 彩虹糖三种不同的效果
-- function Caihongtang()
--     local index = ranint(1, 3)
--     if (index == 1) then
--         return 60,
--                "少女吃下几颗红色的原果味，经典香甜，还有较劲，但是小心蛀牙哦"
--     elseif (index == 2) then
--         return 100,
--                "嘴中尝到几颗紫色的果莓味，少女的眼睛亮了起来，看起来她很喜欢"
--     else
--         return -30,
--                "舌头触碰到绿色的酸果味，少女苦起了那张小脸，好像有些不情愿"
--     end
-- end

-- -- 对彩虹糖的属性进行赋值
-- Gift_list["彩虹糖"].favor, Gift_list["彩虹糖"].reply = Caihongtang()

