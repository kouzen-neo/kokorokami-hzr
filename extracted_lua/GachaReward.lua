-- Code Auto Create Begin
local M = Class('GachaReward', UIItemBase)
function M:ctor()
    M.super.ctor(self)
    self.PathPrefab = 'ABOriginal/UI/Prefab/Template/GachaReward.prefab'
    -- 没有使用组建缓存列表
    self.CC = {
        -- Image 列表
        {'GachaReward','/',2},{'RewardItemPreFab','RewardItemPreFab',2},{'RewardRankImg','RewardItemPreFab/RewardRankImg',2},{'RewardIconImg','RewardItemPreFab/RewardIconImg',2},{'Img_ItemCountBg','RewardItemPreFab/Img_ItemCountBg',2},{'StarPanel','RewardItemPreFab/StarPanel',2},{'ItemStarRoot','RewardItemPreFab/StarPanel/ItemStarRoot',2},{'ItemStarPrefab1','RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab1',2},{'HighLight','RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab1/HighLight',2},{'ItemStarPrefab2','RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab2',2},{'HighLight01','RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab2/HighLight',2},{'ItemStarPrefab3','RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab3',2},{'HighLight02','RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab3/HighLight',2},{'ItemStarPrefab4','RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab4',2},{'HighLight03','RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab4/HighLight',2},{'ItemStarPrefab5','RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab5',2},{'HighLight04','RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab5/HighLight',2},{'ItemStarPrefab6','RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab6',2},{'HighLight05','RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab6/HighLight',2},{'Shuliang','Shuliang',2},{'Mask','Mask',2},
        -- UITemplate 列表
        {'GachaReward01','/',10},
        -- TextMeshProUGUI 列表
        {'ItemCountText','RewardItemPreFab/Img_ItemCountBg/ItemCountText',20},{'Text_Shengyu','Shuliang/Text_Shengyu',20},{'Text_Shuliang','Shuliang/Text_Shuliang',20},
    }
end
-- Code Auto Create End
function M:OnInit()
    --点击查看物品详情
    UIEvent.LuaClick(self.ObjRoot,function()
        if self.BagItem.item then
            MgrUI.Pop(UID.ItemDetailPop_UI,{self.BagItem.item, false, function() end},true)
        end
    end)
end

function M:OnUpdateUI(data)
    self.BagItem = data
    --设置品质
    MgrRes.LoadSprite(self.RewardRankImg(),self.BagItem.item.iconFrame)
    --设置图标
    MgrRes.LoadSprite(self.RewardIconImg(),self.BagItem.item.icon)
    --道具数量
    self.Img_ItemCountBg().gameObject:SetActive(self.BagItem.num > 1)
    self.ItemCountText().text = self.BagItem.num
    self.Text_Shuliang().text = self.BagItem.count
    --领取状态
    self.Mask().gameObject:SetActive(self.BagItem.isGot)
end

return M