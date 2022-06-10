msg_order={}

help_pic = "/home/mirai/Dice3349795206/plugin/HelpPic/"

function Help_petpet()
    return "具体说明及演示请查阅文档https://rainchain-zero.github.io/JasmineDoc/manual/nonebot2/petpet.html\n[CQ:image,file="..help_pic.."petpet.jpg]"
end
msg_order["/help petpet"]="Help_petpet"