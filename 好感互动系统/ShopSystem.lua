msg_order = {}

package.path = getDiceDir() .. "/plugin/ReplyAndDescription/?.lua"
require "itemDescription"
package.path = getDiceDir() .. "/plugin/IO/?.lua"
require "IO"
require "itemIO"
-- 商店主面板
function ShopMenu(msg)
    local ItemShop = ReadItem()
    if (GetUserConf("storyConf", msg.fromQQ, "isShopUnlocked", 0) == 0) then
        return "您还没有解锁商店功能哦~"
    end
    local res = {}
    local reply = "南云の小店：（输入“购买 数量 商品名”即可购买，数量不填默认为1）\n提示：可通过“查询 物品名”查看详细信息\n\n"
    for k, _ in pairs(ItemShop) do
        if (ItemShop[k].price ~= nil) then
            if (res[ItemShop[k].cohesion] == nil) then
                res[ItemShop[k].cohesion] = ""
            end
            res[ItemShop[k].cohesion] =
                res[ItemShop[k].cohesion] ..
                k .. "（" .. ItemShop[k].cohesion .. "）" .. ItemShop[k].class .. ":" .. ItemShop[k].price .. "\n"
        end
    end
    for _, v in ipairs(res) do
        reply = reply .. v .. "===============\n"
    end
    return reply
end
msg_order["进入商店"] = "ShopMenu"

-- 购买商品
purchase_order = "购买"
function BuyItem(msg)
    local ItemShop = ReadItem()
    local num, item = "", ""
    num, item = string.match(msg.fromMsg, "[%s]*(%d*)[%s]*(.*)", #purchase_order + 1)
    if (num == "" or num == nil) then
        num = 1
    end
    if (num == 1 and (item == nil or item == "")) then
        return ""
    end
    if (GetUserConf("storyConf", msg.fromQQ, "isShopUnlocked", 0) == 0) then
        return "『✖条件未满足』您还没有解锁商店功能，无法购买哦~"
    end
    if (item == nil or item == "") then
        return "『✖Error』请输入要购买的商品哦~"
    end
    -- 判断道具是否存在
    local flag = false
    for k, _ in pairs(ItemShop) do
        if (string.find(k, item) ~= nil) then
            if (ItemShop[k].price ~= nil) then
                flag = true
                item = k
                break
            end
        end
    end
    if (not flag) then
        return "你在小店来回寻找，几乎要把这里翻了个底朝天，也没找到你想要的东西呢"
    end
    --判断是否达到亲密度标准
    local cohesion = GetUserConf("favorConf", msg.fromQQ, "cohesion", 0)
    if (cohesion < ItemShop[item].cohesion) then
        return "『✖条件未满足』您的亲密度不足以购买此项物品哦~"
    end

    local fl = GetUserConf("itemConf", msg.fromQQ, "fl", 500) -- 初始FL为500
    local price = tonumber(string.match(ItemShop[item].price, "%d*")) * num
    if (fl < price) then
        return "『✖余量不足』诶？身上好像没带够FL...看来只能下次来了呢"
    else
        SetUserConf(
            "itemConf",
            msg.fromQQ,
            {"fl", item},
            {fl - price, GetUserConf("itemConf", msg.fromQQ, item, 0) + num}
        )
        -- 判断是否初次在小店购买（第一章剧情判断用）
        if (GetUserConf("storyConf", msg.fromQQ, "isShopUnlocked", 0) == 10) then
            SetUserConf("storyConf", msg.fromQQ, "isShopUnlocked", 1)
        end
        return "购买成功！感谢惠顾南云小店~期待您的下次光临~"
    end
end
msg_order[purchase_order] = "BuyItem"
