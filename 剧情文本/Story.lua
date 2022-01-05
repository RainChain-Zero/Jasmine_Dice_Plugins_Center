--[[
    @author 慕北_Innocent(RainChain)
    @version 1.6
    @Created 2021/12/05 00:04
    @Last Modified 2022/01/02 14:51
    ]]
Story0=
{
    [1]="意识沉湎于量子之海下，冰山一角的微弱光芒猛然收缩，亿万泡沫在摇曳辉映下，绚烂炸裂，或是坍缩为奇点，难以名状的窒息感下，光怪陆离的线条紊乱中，如同溺死之人的最后一抹希望，零星的光子浮出了阴暗的里侧。\f“{nick}，还好吗？”混沌的意识中，你如饥似渴般抓取着记忆，片刻之后，过往一股脑地涌入了那片贫瘠的土地，你终于意识到呼唤“此名”的人是谁。",
    [2]=[[“怎么了，茉莉？”
口中响起下意识的回应，撑起厚重的眼皮后，你才发现熟悉的少女坐在床边，以关切的目光注视着你。
眼前这个白发红瞳的美少女，是和你同居的室友。
“你刚刚在客厅突然昏倒了，我只能把你搬到床上，没想到这么快就醒过来了，身体出问题了吗？”]],

    --!选项1
    [3]=[[选项1：（输入".c 序号"）
1.“不，没什么问题。”
2.“头，有点昏的样子。”
3.“好像，感觉，有点......奇怪。”]],

    --? 选项1选择1
    [4]=[[“真的吗？可不要骗我哦。”她撅了一下小嘴，看起来有些不满，也不知道是为什么。
“嗯，没事的。”你如是回复道
“那我还有事，得先走了哦，照顾好自己。” 精致的小脸表达了无可奈何的情感，最后还是叹了一口气
“知道了，祝一路顺风。”你故作轻松地微笑起来，目送眼前披着棉袄的靓影离开，直到玄关的门响起砰的一声，你才下意识放松下来]],
    
    --?选项1选择2
    [5]=
    {
        [1]=[[“是这段时间太累了吧。”茉莉撇了撇嘴“谁叫你一点都不注意作息，出事了才知道问题。怎么样，要去医院看看吗？”
看着她像个老妈子一样说教，你的脸上不由得浮现出一抹苦笑“好啦，我知道了，去医院的话，暂时就不用了吧。”]],
        [2]=[[她叹了一口气“好吧，那你照顾好自己，最好还是去医院看看，我还有事，先出门一趟。”说完便踏着轻快的步子离开了房间
“嗯，再见。”看着她离开，再扫四周，看着这个有些乱的房间，一股真实感才从你心头涌上。]],
    },

    --? 选项1选择3
    [6]=
    {
        [1]=[[“唉，那是，什么意思？”少女可爱的小脸流露出不解的神情。
“我...我不知道”你试图去回忆什么，但脑海中一一闪过的只有过去和茉莉在这栋小屋的记忆，突然间，一种无言的焦躁填补了你剩下的思维，你抱住了头，恍若刚才病症又一次发作。]],
        [2]=[[咔嚓，似乎，像是老旧电视机那被充斥着黑白雪花的屏幕，闪过你的眼前，又如绚烂的亿万星光体斗转星移。
等到你回过神来时，感到身上已经是大汗淋漓，呼吸道也被粗重的气流略过，缓慢地抬起头后，映入眼帘的是少女澄澈的红瞳，她盯着你的脸，一时间，你不知道该作何反应，十多秒钟后，你才想起这种距离对你们的关系有些过于亲密了。]],
        [3]=[[“对，对不起...”你发出了莫名其妙的道歉
“？？”你几乎都可以看到茉莉头上冒出的问号了，似乎还是粉红色的
“感谢，你，照顾，我。”你连说话都开始结巴起来，大冬天里，脸上的温度却开始反常的上升。]],
        [4]=[[“没事啦，咱们是室友嘛，现在感觉怎么样了？”她脸上的疑惑很快被微笑代替
“还好吧...”连你自己也不能确定自己的状态
“最好去医院看看哦，啊，得走了，对了，我炖了一锅排骨汤，放在桌上了，等会起来记得喝啊。”她看了一眼手机，似乎是发现时间有些晚了，交代完事情就匆忙离开了。]],
    },
    --! 选项1结尾

    --! 选项2
    [7]={
        [1]=[[你扫视着这个房间，不知为何，叹了口气。
选项2：（输入".c 序号"）
1.在手机上进行医院挂号
2.起身离开房间
3.待在床上思考一会]],
        [2]=[[选项2：（输入".c 序号"）
1.在手机上进行医院挂号(不可选)
2.起身离开房间
3.待在床上思考一会]],
        [3]=[[选项2：（输入".c 序号"）
1.在手机上进行医院挂号
2.起身离开房间
3.待在床上思考一会(不可选)]],
        [4]=[[选项2：（输入".c 序号"）
1.在手机上进行医院挂号(不可选)
2.起身离开房间
3.待在床上思考一会(不可选)]]
    },

    --? 选项2选择1
    [8]=[[在被窝里翻找出自己的手机，用指纹打开。熟悉的社交账号，熟悉的app，熟悉的游戏，一切都在向你倾诉着一股归属感。很快，你找到医院挂号的app，挂了一个神经内科的号，嗯，下午的。
完成这一系列操作后，你扫视着这个屋子，一时间，不知道该干点什么，正常情况的话，你现在应该去打工，不过考虑到身体问题，还是请几天假比较好。]],
    --! 返回选项2，选择2 or 3，记录选择1已被选择

    --? 选项2选择2
    [9]=[[你在被窝里翻出了自己的衣服，说老实话，这大冬天里起床可真是一件累人事。最终，你成功起身，来到了客厅。一张大概可以共四人落座的小桌子上，放着一碗冒着热气的排骨汤。转头望去，客厅里还剩下两张沙发，以及通往厨房和厕所的路。
拿起桌上放的排骨汤，喝了几口后，人间的温度重新回到了你的身上。
--序章 『惊蛰』 The End]],
    --! 本章End

    --? 选项2选择3
    [10]=[[你在被窝里辗转反侧，始终不肯起床，奇怪的陌生感笼罩着你的心头。
回望过去，从你记事的记忆一点一滴在你的心头播放，最终，你暂且消去了心头的疑云，毕竟，自己现在除了消耗时间什么也干不了。]]
    --! 返回选项2，若1未选择，1可选；2可选

}

Special0=
{
    [1]="『元旦特典 预想此时应更好』\f“砰！”玄关处响起恰到好处的关门声，而小脑袋从里面的房间探出来，看到了还在换鞋的你。\f"..
    "不经意的抬头时，你才发现茉莉在盯着你看，那一头浅灰的瀑布垂下，隐藏着玫红眸子，对你眨了眨，露出些许浅浅笑意。\f"..
    "即使早已见惯了这副光景，但心跳依然被提起了速，连神经递质也开始忙活。不过现在还有其他问题——",
    [2]="“怎么了，茉莉？”你对于她这副扭扭捏捏的样子的有些奇怪\f“那个...能帮我...扎一下头发吗？”她的声音到后面逐渐沉入低谷，像是在说什么见不得人的事情。\f"..
    "“什么？”你显然没有听得很清楚。\f"..
    "“扎头发...帮我扎头发啦！”像是忽然放弃了什么似的，不仅音量，连声调都上去了。",

    --! 选项1
    [3]="选项1：(输入“.c 序号”)\n1. “你......自己不会吗？”\n2. “可以是可以啦，不过，为什么？”\n3. “知道了，等我放完东西就来。”",

    --? 选项1 选择1
    [4]=
    {
        [1]="你看到她的头飞快缩了回去，房门随即就被猛的关上了，她脚剁得有点响......很显然，你可能...说错了点什么。\f嗯...现在你已经换好了鞋，坐在了沙发上，无声的焦虑正环绕着你，在这几分钟里，你从草履虫思考到全超导托克马克核聚变，从狭义相对论思考到量子力学，你不明白为什么会这样。",
        [2]="不过短暂的思考时间结束了，茉莉打开房门，带着已经扎好的单马尾走了出来，她大概是用亮红色的眼睛白了你一眼，就走进了厨房。\f而你刚刚觉醒的第六感发挥了作用，它告诉你现在应该跟上一起去厨房，于是你飞快起身，在厨房遇到了已经换上围裙的茉莉。",
        [3]="她嘟起的嘴角无疑是在表达什么信号“所以，快点来帮我切菜。”这道看似的请求的命令让你迟疑半分。\f“怎么今天要下厨了？”你略显疑惑，这可算是少见的。",
        [4]="“你还真忘了啊......是元旦哦”她轻叹一口气。\f"..
        "“我day到啦，是元旦”你才想起来回来的路上有看到张灯结彩的街道，不过自己的心思并不在那上面......\f"..
        "“答对了，所以你还不过来晚饭就没你的份了。”你寻思了一下，最终还是不想在这种日子吃外卖。"
    },

    --? 选项1 选择2
    [5]=
    {
        [1]="紧咬着晶莹剔透的唇瓣，她的小脸红的大半，成型的蒸汽就快冒出来了。\f"..
        "“你，你别管嘛，快点来！”\f"..
        "看到她这副样子，你只好先轻轻点了点头，放下手中其他的事情后，你才缓步踏入她的房间，而女孩早已静坐在梳妆台前，她的双手安静地放在白丝上，两颗红宝石对你示意快点，你顺手拿起一旁的奶白色发带站到了她身后。\f"..
        "“所以，要怎么扎？”\f"..
        "“单马尾啦，方便些。”",
        [2]="“方便，是要干什么吗？”话语间，你的手已经抚起这上好的绸缎，“云髻峨峨，修眉联娟”不经地联想起这句诗，你正要开始手上的活，却撇见镜子里的女孩已经垂下了头，看不见神情。\f"..
        "“等会要下厨啦......”她的声音像是喃喃细语。\f"..
        "那为什么要我扎？你顺理成章地得出这个结论，不过却很识趣地没有将它抛出来。",
        [3]="“嗯...那你怎么今天要下厨了？”\f"..
        "“元旦哦，就知道你个笨蛋又忘了。”\f"..
        "你这才恍然大悟般想起已经是元旦了，最近一直在想别的事情...但这个话茬是有点接不上了，房间里顿时安静下来。",
        [4]="直到你喊出一句好了，女孩的头才抬起来，看向镜子里精致的自己，打量了一下，就起身走向外面“走吧，去厨房”\f"..
        "“诶，我也要去吗？”\f"..
        "“如果你不想晚饭没有你的份的话。”\f"..
        "你苦笑一声，只得追了上去。"
    },

    --? 选项一 选择3
    [6]=
    {
        [1]="你很快答应下来，并未感到有什么奇怪的，而茉莉也缩回了自己的房间。等到你将自己的东西放好，才轻声找到她。\f似乎是等候已久的样子，女孩端坐在梳妆台的椅子上，安安静静地，像是落入人间的月仙子，浅灰的瀑布垂到肩下，而白皙如玉的双手待在大腿上，那双红里透黑的美眸正紧紧地盯着你，你不由得轻笑出声。",
        [2]="“笑，笑什么？”她有些疑惑。\f"..
        "你没有解释什么，只是拿起一旁的发带走到她身后“要扎什么？”\f"..
        "“单马尾，一会要下厨。”一抹酒红不知为何从她的锁骨蔓延开来。\f"..
        "啊...是元旦啊，你依稀的记忆里这才浮现出时间\f"..
        "“你也要来帮忙哦。”\f"..
        "“行吧，赏我口饭吃就行”对于茉莉的手艺，你还是比较喜欢的。",
        [3]="无言的时间一点一点溜走，你们有一句没一句地聊着什么。\f不过马尾很快就扎好了，她看了几眼就快步离开了房间，还对你做了一个招手的动作。你扫视了几眼眼前整洁而干净的房间，看到似乎是还没收起来的黑色长裙随意地扔在床边，就带着轻笑离开了这里。"
    },

    --! 返回主线
    [7]="你们在厨房忙上忙下，油烟不全被抽走，却平添几丝烟火气，你的心底似乎也有什么暖洋洋的东西，也只是把它留在心里，维持着片刻里这忙碌的宁静。\f"..
    "当你们已经可以坐下来歇息时，桌子上已经摆了几道菜和汤，虽然可能吃不完，但是氛围比较重要！",
    [8]="你看着眼前的一碗汤圆，总觉得还要坚持这种事情的茉莉有些怪。“生活要有仪式感嘛”她解答了你眼中的疑惑，并自顾自地开始吃起来。\f"..
    "听闻此言，你也只好耸耸肩，一勺舀起汤圆，轻咬一口，是红糖馅的，她就喜欢吃甜食，该让她注意蛀牙了，心中如此想着，舌头传来的触感却让你充分感受到了糖精的诱惑。",
    [9]="稍微点了点头，你才注意到女孩的红眸似乎是悄悄注意着你，但当抬起头，她又收回了目光。\f"..
    "“？”你头上冒出一个问号，但却没有追问下去，而是转头干起来自己的饭。时间一点一点流逝，你觉得应该说点什么",
    [10]="“说起来，咱真的有什么好团圆的吗？”团圆，对你们来说其实是个比较陌生的概念，在你的记忆里，出于某些原因，这个动词不太适用于你们。\f"..
    "记忆就像一座幽深的潭水，很少有人去打捞里面的东西，你也深知这其中深浅，所以只是试探性地问了一句。",
    [11]="“怎么了，不可以吗？”尽管听上去像是抱怨，但实际上，却像是女生的小委屈一样...\f"..
    "“不，没什么......”你在心底默默思考着：她这个样子，算是接受这里了...？不，还是算了，不去寄托任何期望，才不会有任何失望...",
    [12]="回过神来，才发现女孩的红瞳在朦胧间已然隐上一层水雾，只是死死看着碗里，机械地重复着吃汤圆的动作。\f"..
    "你想说点什么，努力张开了嘴，拼尽全力让声带振动起来，但得到的只有女孩的勺子砰在碗壁上的声音。\f"..
    "等到碗里的汤圆被吃完，还在尝试做着重复动作的右手才迟迟地发现自己只是在汤水里荡起一圈波纹。\f"..
    "女孩怔了怔，将勺子放回碗里后，双手像是无处可去，只能使劲抓住自己的大腿，牙齿抵住下唇，微微地打着颤。",
    [13]="“啪嗒”表面张力终于承受不住下坠的牵引，一泪水落在女孩的大腿上，也落在你的心里。\f"..
    "眼泪如决堤的洪水一样冲出来，你总算夺回了僵硬身体的控制权。"..
    "坐到她身旁的椅子上，听着那仍然在努力控制的抽泣，你不免生出一丝懊悔，与此同时，自己确实得做点什么了。",

    --! 选项二（好感锁）
    [14]="选项2：(输入“.c 序号”)\n1.你看着女孩清秀的侧脸，暗下决心，用手捧起她的脸颊......（3000好感可选）\n2.你犹豫半分，用手将女孩轻轻抱了过来。（2000好感可选）\n3.你静静看着，决定陪在她身旁",
    
    --? 选项二选择1
    [15]=
    {
        [1]="你将女孩的头轻轻抬起，用粗暴的方式闯入了她的世界...等到她回过神来的时候，你们的眼神已然重叠在一起。",
        [2]="“唔...咕......”女孩的喉咙发出了不满的声音，双手象征性地锤了几下你的背，整个身子就如烂泥般瘫软下来。\f"..
        "你眼角的余光瞥见酒色红晕从她纤细的脖颈浸染开来，等到她的呼吸逐渐趋于平稳，你才恋恋不舍的移开唇瓣。",
        [3]="拿起纸巾，你拭去残留的泪痕，原本如瓷娃娃精致的小脸，现在早已是混乱不堪。\f"..
        "好点了吗？”你试着轻轻安抚她，但她只是一言不发的盯着你，那双赤瞳看得你心里有点发慌——“该不会，生气了吧。\f”"..
        "就在你开始胡思乱想的时候，耳旁传来了软软的答复。",
        [4]="“下次...要提前说。”",
        [5]="你松了口气，老实说，刚才那么做是没有办法的办法，好在还算管用...\f"..
        "结束短暂的庆幸，你发现女孩已经开始自顾自的干起饭来，好似之前的事都从没发生过一样，你嘴角一抽，也开始填饱自己的肚子。"
    },

    --? 选项二选择2
    [16]=
    {
        [1]="她在你怀里，不止地小声抽泣着，没有对你的行为做出任何反抗。\f"..
        "看着怀中的女孩，你默默感受着另一个躯体传过来的温度。亲亲一嗅，就能闻到少女的幽香。\f"..
        "她晶莹的泪珠滴滴落下，打湿了你胸前的薄衣。冰冷的悲伤从你跳动的心脏蔓延开来...",
        [2]="女孩的感情浸染在你的记忆原野中，恍惚间，你眼前闪现出那一天的画面...雨吞噬了那个夜晚，你喘着粗气...\f"..
        "等你回过神来的时候，她的抽泣已经渐渐停止，只剩下时不时吸鼻涕的声音。你拿起桌上的餐巾，一点一点擦去过往的痕迹，直到你能听到她安稳的呼吸声。\f"..
        "你俯下脑袋，轻轻咬了一下她的小耳朵，尽力放低声音说道。",
        [3]="“我在这里。”",
        [4]="嗯...可惜现在看不到她的表情，你只能感到怀中的美人，身体明显颤抖了一下。\f"..
        "好吧，在那之后，她把你赶回了自己的座位，全程低着脑袋，吃起自己的饭来。\f"..
        "至少没有生我的气，你这样想到，随后也开始了手上的动作。",
    },

    --? 选项二选择3(END)
    [17]=
    {
        [1]="你在旁边，静静的陪伴着她，看着女孩落泪的模样，你开始后悔之前的话语，其实完全没必要的，不是吗？她并不属于自己，过去不是，现在不是，将来也不是。\f"..
        "你像是在说服自己一样，讲着一大堆谜语，但最终的思绪还是回到了女孩身上，她睡着了，倒在你的身上。\f"..
        "你轻叹一口气，用纸巾小心翼翼地将她脸庞的泪痕擦去，再将她抱到她自己房间的床上，轻轻盖上被子，你凝视着女孩安稳的睡颜，忽然俯下身去，在她的额头上亲吻了一下。",
        [2]="实际上，你猜女孩可能只在装睡，但你还是这么做了，或许给她一个逃避现实的机会，又或许是给自己一个躲避回忆的机会，无论如何，你心中依然五味陈杂。",
        [3]="回到客厅，没有吃多少的饭菜还在摆在桌上，现在你当然已经没什么胃口，简单填饱了肚子，就这样将饭菜收拾起来。\f"..
        "你站在阳台，夜色如墨，这座城市已然陷入沉睡，但它似乎永远不会欢迎你，无尽的思绪，最终将你拉入睡乡。"..
        "“此情可待成追忆，只是当时已惘然。”\n——『元旦特典 预想此时应更好』end"
    },

    --! 回归主线
    [18]="被她这么一闹腾，时间削去不少，等到你们都在沙发上打饱嗝的时候，午夜已经悄悄接近。\f"..
    "你随手点开手机上某个粉色app，打算看点跨年的节目，来消磨时间，茉莉的小脑袋也凑过来一起看。\f"..
    "而你的手悄悄摸上她的头，轻轻揉了起来，女孩闷哼一声，小粉拳挥在你的身上，不痛不痒。",
    [19]="不过她好像突然想起什么似的，跑回卧室，拿出两张卡片，你接过来，仔细一看，才发现是类似于明信片的东西“这是要干什么？”\f"..
    "“嗯...算是我的一点点想法吧，就这个写下我们的新年愿望，好不好？”女孩的声色映出她的想法。",
    [20]="你寻思这是不是有点幼稚？好吧，倒也没那么幼稚，只是...你有点不习惯这种感觉。\f"..
    "她明红的眸子里满是期待，你只得无奈点了点头，拿起一旁的笔。不过要写什么呢？",

    --! 选项三
    [21]="选项3：(输入“.c 序号”)\n1.希望我接下来一年...能做到应该做的事\n2.希望茉莉能过好接下来的生活\n3.希望我们能好好活下去",

    [22]="写好了，你抬起头来，刚好对上女孩的冉冉笑意，看起来她也写完了。\f"..
    "“写的什么？”你随意地问了问\f"..
    "“不给你看——”她将手中的贺卡塞入了胸里\f"..
    "“？？”你脑袋上冒出两个问号“这是从哪学的？",
    [23]="“哼”女孩笑起来很好看“防止你对我使坏啦，比如...挠我痒痒之类的。”\f"..
    "好吧，你不得不承认，刚刚确实有那么一瞬间冒出了这种想法...\f"..
    "“想看的话，必须要交换哦。”听到女孩的平等建议，你叹了口气",

    --! 选项四
    [24]="选项4：(输入“.c 序号”)\n1.“喏，拿去吧”\n2.“嗯...还是，自己拿着吧”",

    --? 选项四选择1
    [25]=
    {
        [1]="你很大方的将自己写的贺卡递过去，而茉莉也将自己的给了你。\f"..
        "一行娟秀的字迹映入你的眼帘：希望{nick}和茉莉今年不会分开。\f"..
        "怎么说呢？果然是她会写出来的话，天真，但总是饱含希望。\f"..
        "你看向茉莉，她也读完了你写的话。",

        --! 依据选项三指定内容
        [2]=
        {
            --? 选项三选择1
            [1]="“什么嘛，别老是想着一个人扛下所有啦......”她无奈地叹了口气，对你一点办法都没有。",
            --? 选项三选择2
            [2]="“我才不需要你来担心，笨蛋...”她埋下头，低声说着什么。",
            --? 选项三选择3
            [3]="“谁想和你一直活下去，瞎写什么呢......”微微涨红的脸诉说着什么不满。"
        },
        [3]="此时，你的手机上还播放着跨年节目。一时间，氛围有点凝固，双方都觉得应该说点什么，但又觉得不应该说点什么。\f"..
        "但你最终还是打破了这份平静。“好啦，交换也交换过了，接下来怎么办？”",
        [4]="“那...烧掉吧”女孩说出了让你有些诧异的答案。\f"..
        "“为什么？”\f"..
        "“烧掉的话，天上的神明说不定就能听到我们的请求。”女孩以平静的口吻诉说的这份请求。",
        [5]="虽然不太能理解，但你决定还是尊重她的意愿。\f"..
        "在手机播放的倒计时中，你点燃了打火机，硬纸片没那么好烧，火焰一点一点的向上攀爬着，将字迹化为灰烬，或许在这净火之中，真的有什么能传达出去。",
        [6]="最后一秒的倒计时结束，一切都踏入了新的一年，你和茉莉对视一眼，倒映出对方的模样。过往纷繁，或许它们不再追究你们，又或许它们会追上你们，谁知道呢。\f"..
        "“东风夜放花千树，更吹落，星如雨。”\n——『元旦特典 预想此时应更好』end"
    },

    --? 选项四选择2
    [26]=
    {
        [1]="你有点不想让茉莉知道自己写的是什么，所以并不打算交换\f"..
        "“那...好吧”女孩的声音听起来有点落寞，这表示她其实挺想看看你写的是什么。\f"..
        "氛围顿时有点凝固，你不知道该说些什么，但好在手机还在持续播放着跨年节目，并不是特别的尴尬。",
        [2]="“那...能把它们烧了吗？”女孩突然提出了奇怪的请求。\f"..
        "“烧了？为什么”这听起来有些奇怪。",
        [3]="“嗯...这样或许愿望就能实现。”\f"..
        "虽然不知道为什么会这样，但你觉得这样也挺好的。",
        [4]="最后，在火焰的光芒中，节目迎来了跨年的倒计时，滴答，滴答，你们踏入了新的一年，而火光里映出你们的未来，忽明忽灭，正不止地燃烧着。\f"..
        "“雕栏玉砌应犹在，只是朱颜改。”\n——『元旦特典 预想此时应更好』end"
    }
}