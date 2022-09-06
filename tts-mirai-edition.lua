package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"

npcList = {
	"派蒙",
	"凯亚",
	"安柏",
	"丽莎",
	"琴",
	"香菱",
	"枫原万叶",
	"迪卢克",
	"温迪",
	"可莉",
	"早柚",
	"托马",
	"芭芭拉",
	"优菈",
	"云堇",
	"钟离",
	"魈",
	"凝光",
	"雷电将军",
	"北斗",
	"甘雨",
	"七七",
	"刻晴",
	"神里绫华",
	"戴因斯雷布",
	"雷泽",
	"神里绫人",
	"罗莎莉亚",
	"阿贝多",
	"八重神子",
	"宵宫",
	"荒泷一斗",
	"九条裟罗",
	"夜兰",
	"珊瑚宫心海",
	"五郎",
	"散兵",
	"女士",
	"达达利亚",
	"莫娜",
	"班尼特",
	"申鹤",
	"行秋",
	"烟绯",
	"久岐忍",
	"辛焱",
	"砂糖",
	"胡桃",
	"重云",
	"菲谢尔",
	"诺艾尔",
	"迪奥娜",
	"鹿野院平藏"
}

msg_order = {["/让"] = "letSpeaker", ["说"] = "doSpeaker"}

function letSpeaker(msg)
	local favor = GetUserConf("favorConf", msg.fromQQ, "favor", 0)
	if favor < 500 then
		return "该功能需要好感度达到500哦~"
	end
	local npc = string.match(msg.fromMsg, "^/让(.-)说")
	if npc then
		local prefix = "/让" .. npc .. "说"
		local text = string.sub(msg.fromMsg, #prefix + 1)
		for i = 1, #npcList do
			if npcList[i] == npc then
				return "[CQ:record,url=http://233366.proxy.nscc-gz.cn:8888?speaker=" .. npcList[i] .. "&text=" .. text .. "]"
			end
		end
		return #npcList
	else
		return
	end
end

function doSpeaker(msg)
	local p, b
	for i = 1, #npcList do
		p, b = string.find(msg.fromMsg, npcList[i])
		if p or b then
			break
		end
	end
	if p or b then
		return "[CQ:record,url=http://233366.proxy.nscc-gz.cn:8888?speaker=" ..
			string.sub(msg.fromMsg, p, b) .. "&text=" .. string.sub(msg.fromMsg, #"说" + 1) .. "&format=wav]"
	else
		return "[CQ:record,file=http://233366.proxy.nscc-gz.cn:8888?speaker=神里绫华&text=" ..
			string.sub(msg.fromMsg, #"说" + 1) .. "&format=wav]"
	end
end
