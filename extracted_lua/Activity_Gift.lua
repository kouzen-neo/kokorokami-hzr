-- Code Auto Create Begin
local M = Class('Activity_Gift', UIItemBase)
function M:ctor()
    M.super.ctor(self)
    self.PathPrefab = 'ABOriginal/UI/Prefab/Template/Activity_Gift.prefab'
    -- 没有使用组建缓存列表
    self.CC = {
        -- Image 列表
        {'Activity_Gift','/',2},{'BagItem','WpPanel/BagItem',2},{'RewardRankImg','WpPanel/BagItem/wupin/RewardRankImg',2},{'RewardIconImg','WpPanel/BagItem/wupin/RewardIconImg',2},{'StarPanel','WpPanel/BagItem/wupin/StarPanel',2},{'ItemStarRoot','WpPanel/BagItem/wupin/StarPanel/ItemStarRoot',2},{'ItemStarPrefab','WpPanel/BagItem/wupin/StarPanel/ItemStarPrefab',2},{'HighLight','WpPanel/BagItem/wupin/StarPanel/ItemStarPrefab/HighLight',2},{'Img_ItemCountBg','WpPanel/BagItem/wupin/Img_ItemCountBg',2},{'TimeCountDownPanel','WpPanel/BagItem/wupin/TimeCountDownPanel',2},{'shijian2','WpPanel/BagItem/wupin/TimeCountDownPanel/shijian2',2},{'ItemContent','WpPanel/ItemContent',2},{'Btn_QianWang','Btn_QianWang',2},{'Image_huobi','Btn_QianWang/Image_huobi',2},{'Panel','Btn_QianWang/Text_Original/Panel',2},{'Btn_Details','Btn_Details',2},{'DetailsPop','DetailsPop',2},{'TouchClose','DetailsPop/TouchClose',2},{'PopBg','DetailsPop/PopBg',2},{'ItemScroll','DetailsPop/PopBg/ItemScroll',2},{'ActivityGift','DetailsPop/PopBg/ItemScroll/ActivityGift',2},{'RewardRankImg01','DetailsPop/PopBg/ItemScroll/ActivityGift/RewardRankImg',2},{'RewardIconImg01','DetailsPop/PopBg/ItemScroll/ActivityGift/RewardIconImg',2},{'Mask','DetailsPop/PopBg/ItemScroll/ActivityGift/Mask',2},{'TextBg','DetailsPop/PopBg/ItemScroll/ActivityGift/Mask/TextBg',2},{'Img_ItemCountBg01','DetailsPop/PopBg/ItemScroll/ActivityGift/Img_ItemCountBg',2},{'Content','DetailsPop/PopBg/ItemScroll/Content',2},
        -- UITemplate 列表
        {'Activity_Gift01','/',10},
        -- LoopScrollRect 列表
        {'ItemScroll01','DetailsPop/PopBg/ItemScroll',18},
        -- TextMeshProUGUI 列表
        {'ItemCountText','WpPanel/BagItem/wupin/Img_ItemCountBg/ItemCountText',20},{'CountDownText','WpPanel/BagItem/wupin/TimeCountDownPanel/CountDownText',20},{'Text_QianWang','Btn_QianWang/Text_QianWang',20},{'Text_Original','Btn_QianWang/Text_Original',20},{'Text_Shuoming','Text_Shuoming',20},{'MaskText','DetailsPop/PopBg/ItemScroll/ActivityGift/Mask/MaskText',20},{'ItemCountText01','DetailsPop/PopBg/ItemScroll/ActivityGift/Img_ItemCountBg/ItemCountText',20},{'DetailsText','DetailsPop/DetailsText',20},
    }
end
-- Code Auto Create End
function M:OnInit()
    RedDotControl.GetDotData("ActiveGift"):SetState(false)
    Event.Go("ActivityDot")
    
    self.DetailsPop().gameObject:SetActive(false)
    self.Text_Original().gameObject:SetActive(false)
    
    self.GifCfg = ActivityControl.GetBuyGiftCfg()
    self.BuyShopID = 0
    self.DetailList = {}
    self.actID = 0
    ---是否通过道具购买
    self.UseItemBuy = false
    ---支付多语言提示
    self.BuyTips = nil
    ---注册滑块
    self.ItemScroll01():SetLuaCellEvent(Handle(self, self.ItemCell))
    --充值
    UIEvent.LuaClick(self.Btn_QianWang().gameObject, function()
        if ActivityControl.CheckBuyGiftState(self.actID) then
            Global.PopTip("eventshopitem_tips1")
            return
        end
        
        if self.UseItemBuy then
            MgrUI.Pop(UID.ConfirmPop_UI, { self.BuyTips, function()
                ShopViewModel.SendBuyGoods({ self.BuyShopID, 1 }, function()
                    if self.isSHowBtn then
                        local tPrice = self.ShopItemData:GetPrice().goodsNum
                        self.Text_QianWang().text = tPrice
                        ActivityControl.AddGiftBuyTimes(self.actID)
                        if ActivityControl.CheckBuyGiftState(self.actID) then
                            self.Btn_QianWang().gameObject:SetActive(false)
                        end
                        self.BuyTips = string.format(MgrLanguageData.GetLanguageByKey("cardbuypop_tips9"), tPrice)
                        --原价折扣显示
                        local tOriginal = self.ShopItemData:GetOriginal()
                        if tOriginal and tOriginal.goodsNum > tPrice then
                            self.Text_Original().text = tOriginal.goodsNum
                            self.Text_Original().gameObject:SetActive(true)
                        else
                            self.Text_Original().gameObject:SetActive(false)
                        end
                    else
                        self.Btn_QianWang().gameObject:SetActive(false)
                    end
                end)
            end, nil, 2 })
        else
            ShopViewModel.FlyFunBuyGoods(self.BuyShopID, function()
                if self.isSHowBtn then
                    ActivityControl.AddGiftBuyTimes(self.actID)
                    if ActivityControl.CheckBuyGiftState(self.actID) then
                        self.Btn_QianWang().gameObject:SetActive(false)
                    end
                else
                    self.Btn_QianWang().gameObject:SetActive(false)
                end
            end)
        end
    end)
    --详情
    UIEvent.LuaClick(self.Btn_Details().gameObject,function()
        --获取详情
        ActivityControl.GetDetail(self.BuyShopID, Handle(self,self.ItemDetailList))
        self.DetailsPop().gameObject:SetActive(true)
    end)
    --详情关闭
    UIEvent.LuaClick(self.TouchClose().gameObject,function()
        self.DetailsPop().gameObject:SetActive(false)
    end,nil,self.DetailsPop())
end

function M:OnUpdateUI(pData)
    self.Btn_QianWang().gameObject:SetActive(false)
    self.actID = pData[1]
    local tCurData = self.GifCfg[self.actID]
    self.BuyShopID = tCurData.shopId
    self.isSHowBtn = tCurData.isShowBtn
    --判断是否显示详情按钮还是单个列表
    if tCurData.isShowBtn then
        self.Btn_Details().gameObject:SetActive(true)
        self.ItemContent().gameObject:SetActive(false)
        --获取详情
        ActivityControl.GetDetail(self.BuyShopID, Handle(self,self.ItemDetailList))
    else
        self.Btn_Details().gameObject:SetActive(false)
        self.ItemContent().gameObject:SetActive(true)

        --按钮状态
        if ActivityControl.CheckBuyGiftState(self.actID) then
            self.Btn_QianWang().gameObject:SetActive(false)
        else
            self.Btn_QianWang().gameObject:SetActive(true)
        end
    end
    --道具展示
    for num, v in pairs(tCurData.reward) do
        local tItem = GameObject.Instantiate(self.BagItem().gameObject, self.ItemContent().transform)

        local itemData = string.split(v,'_')
        local BagItemData = ItemControl.GetItemByIdAndType(tonumber(itemData[2]),tonumber(itemData[1]))

        self:InitItem(tItem, BagItemData, tonumber(itemData[3]))
    end
    self.BagItem().gameObject:SetActive(false)
    --背景图替换
    if tCurData.backImg ~= "0" then
        MgrRes.LoadSprite(self.Activity_Gift(), tCurData.backImg)
    end
    --按钮文字
    self.ShopItemData = ShopViewModel.GetShopDataByID(114001,4,self.BuyShopID)
    if self.ShopItemData then
        local tPrice = nil
        if self.ShopItemData.ladderPrice[0] and self.ShopItemData.ladderPrice[0].goodsType == 4 and self.ShopItemData.ladderPrice[0].goodsID == 110002 then
            tPrice = ShopViewModel.FindDollerPrice(self.BuyShopID)
            --通过直充购买
            self.UseItemBuy = false
        else
            tPrice = self.ShopItemData:GetPrice().goodsNum
            local data = ItemControl.GetItemByIdAndType(self.ShopItemData:GetPrice().goodsID,self.ShopItemData:GetPrice().goodsType)      --手中持有的货币数量
            MgrRes.LoadSprite(self.Image_huobi(),data.icon)
            --通过道具购买
            self.UseItemBuy = true
            self.BuyTips = string.format(MgrLanguageData.GetLanguageByKey("cardbuypop_tips9"), tPrice)
            --原价折扣显示
            local tOriginal = self.ShopItemData:GetOriginal()
            if tOriginal and tOriginal.goodsNum > tPrice then
                self.Text_Original().text = tOriginal.goodsNum
                self.Text_Original().gameObject:SetActive(true)
            else
                self.Text_Original().gameObject:SetActive(false)
            end
        end
        if tPrice then
            self.Text_QianWang().text = tPrice
        end
    else
        self.Btn_QianWang().gameObject:SetActive(false)
    end
end

function M:InitItem(_item, BagItem, itemCount)
    local _ItemStarPrefab = CJNUIMgr.GetSunUseName(_item, "ItemStarPrefab")
    local _ItemStarRoot = CJNUIMgr.GetSunUseName(_item, "ItemStarRoot")
    local _ItemCountText = CJNUIMgr.GetSunUseName(_item, "ItemCountText"):GetComponent("TextMeshProUGUI")
    local _RewardRankImg = CJNUIMgr.GetSunUseName(_item, "RewardRankImg"):GetComponent("Image")
    local _RewardIconImg = CJNUIMgr.GetSunUseName(_item, "RewardIconImg"):GetComponent("Image")
    local _Starpanel = CJNUIMgr.GetSunUseName(_item, "StarPanel")
    self.starHLObj = {}
    for i = 1, 6 do
        local obj = GameObject.Instantiate(_ItemStarPrefab.gameObject,_ItemStarRoot.gameObject.transform,false)
        self.starHLObj[i] = obj.transform:Find("HighLight").gameObject
    end
    ---为0不显示星级
    _Starpanel.gameObject:SetActive(BagItem.star > 0)
    ---大于0更新星级显示
    --if BagItem.goodsType == 2 then
    if BagItem.star > 0 then
        for i = 1,#self.starHLObj do
            self.starHLObj[i]:SetActive(i <= BagItem.star)
        end
    end
    --else
    --    self.StarPanel().gameObject:SetActive(false)
    --end

    ---设置品质
    MgrRes.LoadSprite(_RewardRankImg,BagItem.iconFrame)
    ---设置图标
    MgrRes.LoadSprite(_RewardIconImg,BagItem.icon)
    ---设置数量
    _ItemCountText.text = JNStrTool.numberAbbr(itemCount) --itemCount >= 10000 and math.floor(tonumber(itemCount)/1000).."K" or itemCount
    ---设置点击事件
    UIEvent.LuaClick(_item,function()
        MgrUI.Pop(UID.ItemDetailPop_UI,{BagItem, false, function() end},true)
    end)
end

function M:ItemDetailList(_randomInfo)
    self.DetailList = {}
    for i, v in ipairs(_randomInfo) do
        local itemData = string.split(v.item,'_')
        local BagItem = ItemControl.GetItemByIdAndType(tonumber(itemData[2]),tonumber(itemData[1]))
        local tItemData = {
            item = BagItem,
            num = itemData[3] ~= nil and tonumber(itemData[3]) or 0,
            isGot = v.isGot
        }
        table.insert(self.DetailList, tItemData)
    end

    self.ItemScroll01().totalCount = #self.DetailList
    self.ItemScroll01():RefillCells()

    --按钮状态
    if ActivityControl.CheckBuyGiftState(self.actID) then
        self.Btn_QianWang().gameObject:SetActive(false)
    else
        self.Btn_QianWang().gameObject:SetActive(true)
    end
end

function M:ItemCell(trans, idx)
    local tRankImg = CJNUIMgr.GetSunUseName(trans.gameObject, "RewardRankImg"):GetComponent("Image")
    local tIconImg = CJNUIMgr.GetSunUseName(trans.gameObject, "RewardIconImg"):GetComponent("Image")
    local tMask = CJNUIMgr.GetSunUseName(trans.gameObject, "Mask"):GetComponent("Image")
    local tItemCountBg = CJNUIMgr.GetSunUseName(trans.gameObject, "Img_ItemCountBg")
    local tItemCountText = CJNUIMgr.GetSunUseName(trans.gameObject, "ItemCountText"):GetComponent("TextMeshProUGUI")
    local BagItem = self.DetailList[idx]
    --设置品质
    MgrRes.LoadSprite(tRankImg,BagItem.item.iconFrame)
    --设置图标
    MgrRes.LoadSprite(tIconImg,BagItem.item.icon)
    --道具数量
    tItemCountBg.gameObject:SetActive(BagItem.num > 1)
    tItemCountText.text = BagItem.num
    --领取状态
    tMask.gameObject:SetActive(BagItem.isGot)
    ---设置点击事件
    UIEvent.LuaClick(trans.gameObject,function()
        MgrUI.Pop(UID.ItemDetailPop_UI,{BagItem.item, false, function() end},true)
    end)
end

return M