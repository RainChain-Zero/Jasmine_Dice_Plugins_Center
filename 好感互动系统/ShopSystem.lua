--[[
    @author 慕北_Innocent(RainChain)
    @version 1.1
    @Created 2022/01/30 20:13
    @Last Modified 2022/01/31 18:06
    ]]

msg_order={}

package.path=getDiceDir().."/plugin/ReplyAndDescription/?.lua"
require "itemDescription"

--商店主面板
function ShopMenu(msg)
    if(getUserConf(msg.fromQQ,"isShopUnlocked",0)==0)then
        return "您还没有解锁商店功能哦~"
    end
    local res="南云の小店：（输入“购买 数量 商品名”即可购买，数量不填默认为1）\n提示：可通过“查询 物品名”查看详细信息\n"
    local cnt=1
    for k,_ in pairs(ItemShop)
    do
        res=res..string.format("%.0f",cnt).."."..k..":"..ItemShop[k].price.."\n"
        cnt=cnt+1
    end
    return res
end
msg_order["进入商店"]="ShopMenu"

--购买商品
purchase_order="购买"
function BuyItem(msg)
    local num,item="",""
    num,item=string.match(msg.fromMsg,"[%s]*(%d*)[%s]*(.*)",#purchase_order+1)
    if(num=="" or num==nil)then
        num=1
    end
    if(num==1 and (item==nil or item==""))then
        return ""
    end
    if(getUserConf(msg.fromQQ,"isShopUnlocked",0)==0)then
        return "您还没有解锁商店功能，无法购买哦~"
    end
    if(item==nil or item=="")then
        return "请输入要购买的商品哦~"
    end
    --判断道具是否存在
    local flag=false
    for k,_ in pairs(ItemShop)
    do
        if(string.find(k,item)~=nil)then
            flag=true
            item=k
            break
        end
    end
    if(not flag)then
        return "你在小店来回寻找，几乎要把这里翻了个底朝天，也没找到你想要的东西呢"
    end

    local FL=getUserConf(msg.fromQQ,"FL",500)  --初始FL为500
    local price=tonumber(string.match(ItemShop[item].price,"%d*"))*num
    if(FL<price)then
        return "诶？身上好像没带够FL...看来只能下次来了呢"
    else
        setUserConf(msg.fromQQ,"FL",FL-price)
        setUserConf(msg.fromQQ,item,getUserConf(msg.fromQQ,item,0)+num)
        --判断是否初次在小店购买（第一章剧情判断用）
        if(getUserConf(msg.fromQQ,"isShopUnlocked",0)==10)then
            setUserConf(msg.fromQQ,"isShopUnlocked",1)
        end
        return "购买成功！感谢惠顾南云小店~期待您的下次光临~"
    end
end
msg_order[purchase_order]="BuyItem"