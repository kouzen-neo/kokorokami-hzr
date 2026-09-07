-- Code Auto Create Begin
local M = Class('RewardItemPreFab', UIItemBase)
function M:ctor()
    M.super.ctor(self)
    self.PathPrefab = 'ABOriginal/UI/Prefab/Template/RewardItemPreFab.prefab'
    -- 没有使用组建缓存列表
    self.CC = {
        -- Image 列表
        {'RewardItemPreFab','/',2},{'RewardRankImg','RewardRankImg',2},{'RewardIconImg','RewardIconImg',2},{'Img_ItemCountBg','Img_ItemCountBg',2},{'StarPanel','StarPanel',2},{'ItemStarRoot','StarPanel/ItemStarRoot',2},{'ItemStarPrefab1','StarPanel/ItemStarRoot/ItemStarPrefab1',2},{'HighLight','StarPanel/ItemStarRoot/ItemStarPrefab1/HighLight',2},{'ItemStarPrefab2','StarPanel/ItemStarRoot/ItemStarPrefab2',2},{'HighLight01','StarPanel/ItemStarRoot/ItemStarPrefab2/HighLight',2},{'ItemStarPrefab3','StarPanel/ItemStarRoot/ItemStarPrefab3',2},{'HighLight02','StarPanel/ItemStarRoot/ItemStarPrefab3/HighLight',2},{'ItemStarPrefab4','StarPanel/ItemStarRoot/ItemStarPrefab4',2},{'HighLight03','StarPanel/ItemStarRoot/ItemStarPrefab4/HighLight',2},{'ItemStarPrefab5','StarPanel/ItemStarRoot/ItemStarPrefab5',2},{'HighLight04','StarPanel/ItemStarRoot/ItemStarPrefab5/HighLight',2},{'ItemStarPrefab6','StarPanel/ItemStarRoot/ItemStarPrefab6',2},{'HighLight05','StarPanel/ItemStarRoot/ItemStarPrefab6/HighLight',2},
        -- UITemplate 列表
        {'RewardItemPreFab01','/',10},
        -- TextMeshProUGUI 列表
        {'ItemCountText','Img_ItemCountBg/ItemCountText',20},
    }
end
-- Code Auto Create End
function M:OnUpdateUI(pData)
    self.star = {
        self.HighLight().gameObject,
        self.HighLight01().gameObject,
        self.HighLight02().gameObject,
        self.HighLight03().gameObject,
        self.HighLight04().gameObject,
        self.HighLight05().gameObject,
    }
    ---@type ItemData
    self.item = pData[1]
    self.Count = pData[2]
    ---星级
    for i = 1,6 do
        if i <= self.item.star then
            self.star[i]:SetActive(true)
        else
            self.star[i]:SetActive(false)
        end
    end
    if self.item.star == 0 then
        self.ItemStarRoot().gameObject:SetActive(false)
    end
    
    ---边框
    MgrRes.LoadSprite(self.RewardRankImg(),self.item.iconFrame)
    ---物品图标
    MgrRes.LoadSprite(self.RewardIconImg(),self.item.icon)
    ---数量
    self.ItemCountText().text = self.Count
    ---按钮
    UIEvent.LuaClick(self.ObjRoot,function()
        MgrUI.Pop(UID.ItemDetailPop_UI,{ self.item, true, nil,nil,true},true)
    end)
end

return M