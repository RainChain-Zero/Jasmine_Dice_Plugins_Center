msg_order = {}

help_pic = "/home/mirai/Dice3349795206/plugin/HelpPic/"

function Help_petpet()
    return "具体说明及演示请查阅文档https://rainchain-zero.github.io/JasmineDoc/manual/nonebot2/petpet.html\n[CQ:image,file=" ..
        help_pic .. "petpet.jpg]"
end
msg_order["/help petpet"] = "Help_petpet"

function help_ark()
    return "明日方舟泰拉TRPG：\n人物做成：https://rainchain-zero.github.io/JasmineDoc/manual/dice!/ark/ark.html\n检定：https://rainchain-zero.github.io/JasmineDoc/manual/dice!/ark/rk.html\n先攻：https://rainchain-zero.github.io/JasmineDoc/manual/dice!/ark/ac.html"
end
msg_order["/help ark"] = "help_ark"
