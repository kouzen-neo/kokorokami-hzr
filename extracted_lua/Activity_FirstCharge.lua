-- Code Auto Create Begin
local M = Class('Activity_FirstCharge', UIItemBase)
function M:ctor()
    M.super.ctor(self)
    self.PathPrefab = 'ABOriginal/UI/Prefab/Template/Activity_FirstCharge.prefab'
    -- 没有使用组建缓存列表
    self.CC = {
        -- Image 列表
        {'Activity_FirstCharge','/',2},{'BagItem','BagItem',2},{'RewardRankImg','BagItem/wupin/RewardRankImg',2},{'RewardIconImg','BagItem/wupin/RewardIconImg',2},{'StarPanel','BagItem/wupin/StarPanel',2},{'ItemStarRoot','BagItem/wupin/StarPanel/ItemStarRoot',2},{'ItemStarPrefab','BagItem/wupin/StarPanel/ItemStarPrefab',2},{'HighLight','BagItem/wupin/StarPanel/ItemStarPrefab/HighLight',2},{'Img_ItemCountBg','BagItem/wupin/Img_ItemCountBg',2},{'TimeCountDownPanel','BagItem/wupin/TimeCountDownPanel',2},{'shijian2','BagItem/wupin/TimeCountDownPanel/shijian2',2},{'ItemContent1','WpPanel1/ItemContent1',2},{'ItemContent2','WpPanel2/ItemContent2',2},{'Btn_Lingqu1','Btn_Lingqu1',2},{'Btn_Lingqu2','Btn_Lingqu2',2},
        -- UITemplate 列表
        {'Activity_FirstCharge01','/',10},
        -- TextMeshProUGUI 列表
        {'ItemCountText','BagItem/wupin/Img_ItemCountBg/ItemCountText',20},{'CountDownText','BagItem/wupin/TimeCountDownPanel/CountDownText',20},{'Text_Lingqu1','Btn_Lingqu1/Text_Lingqu1',20},{'Text_Lingqu2','Btn_Lingqu2/Text_Lingqu2',20},
    }
end
-- Code Auto Create End
require("LocalData/FirstchargeawardLocalData")

function M:OnInit()
    if ActivityControl.GetFirstChargeState() == 0 and RedDotControl.GetDotData("FirstCharge"):GetCurDotState() then
        ActivityControl.HideFirstChargeDot()
        Event.Go("ActivityDot")
    end

    self.FCData = ActivityControl.GetFirstChargeCfg()
    self.CurChargeList = {}
    self.ActivityID = 0
    self.LinkCode = ""
    self.WpPanel = {
        [1] = { content = self.ItemContent1(), btn = self.Btn_Lingqu1(), txt = self.Text_Lingqu1() },
        [2] = { content = self.ItemContent2(), btn = self.Btn_Lingqu2(), txt = self.Text_Lingqu2() },
    }
    --能够领取的按钮
    self.canGetBtn = {}
    
    UIEvent.LuaClick(self.Btn_Lingqu1().gameObject,Handle(self,function ()
        if self.CurChargeList[1].getState == 1 then
            ActivityControl.RewardSendReq(self.ActivityID,1,0,function()
                MgrRes.LoadSprite(self.Btn_Lingqu1(), "Lottery/Btn_Lingqudi_hui")
                self.Text_Lingqu1().text = MgrLanguageData.GetLanguageByKey("ui_tongyong_text5")
                self.CurChargeList[1].getState = 2
                --检测切换状态
                ActivityControl.CheckFirstChargeState()
            end)
        end
    end))
    UIEvent.LuaClick(self.Btn_Lingqu2().gameObject,Handle(self,function ()
        if self.CurChargeList[2].getState == 0 then
            ---跳转到对应界面
            MgrLink.LinkStart(self.LinkCode)
        elseif self.CurChargeList[2].getState == 1 then
            ActivityControl.RewardSendReq(self.ActivityID,2,0,function()
                MgrRes.LoadSprite(self.Btn_Lingqu2(), "Lottery/Btn_Lingqudi_hui")
                self.Text_Lingqu2().text = MgrLanguageData.GetLanguageByKey("ui_tongyong_text5")
                self.CurChargeList[2].getState = 2
                --检测切换状态
                ActivityControl.CheckFirstChargeState()
            end)
        end
    end))
end

function M:OnUpdateUI(pData)
    local tData = pData[1]
    self.ActivityID = tData.activityId
    self.LinkCode = tData.gotoID
    self.CurChargeList = self.FCData[self.ActivityID]
    for i, cfg in ipairs(self.CurChargeList) do
        if i > #self.WpPanel then
            break
        end
        --展示奖励
        local wardData = string.split(cfg.rewards,',')
        for num, v in pairs(wardData) do
            local tItem = GameObject.Instantiate(self.BagItem().gameObject, self.WpPanel[i].content.transform)

            local itemData = string.split(v,'_')
            local BagItemData = ItemControl.GetItemByIdAndType(tonumber(itemData[2]),tonumber(itemData[1]))

            self:InitItem(tItem, BagItemData, tonumber(itemData[3]))
        end
        --首充领取状态(0.不能领取 1.可领取 2.已领取)
        if cfg.getState == 0 then
            if i == 1 then
                self.WpPanel[i].btn.gameObject:SetActive(false)
            else
                self.WpPanel[i].txt.text = MgrLanguageData.GetLanguageByKey("ui_age_text28")
            end
        elseif cfg.getState == 1 then
            self.WpPanel[i].btn.gameObject:SetActive(true)
          
            MgrRes.LoadSprite(self.WpPanel[i].btn, "Lottery/Btn_Lingqudi_huang")
            self.WpPanel[i].txt.text = MgrLanguageData.GetLanguageByKey("ui_tongyong_text3")
        elseif cfg.getState == 2 then
            self.WpPanel[i].btn.gameObject:SetActive(true)

            MgrRes.LoadSprite(self.WpPanel[i].btn, "Lottery/Btn_Lingqudi_hui")
            self.WpPanel[i].txt.text = MgrLanguageData.GetLanguageByKey("ui_tongyong_text5")
        end
        self.canGetBtn[i] = cfg.getState
    end
    self.BagItem().gameObject:SetActive(false)
    
    if self.CurChargeList[1].backImg ~= "0" then
        MgrRes.LoadSprite(self.Activity_FirstCharge(),"Activity/"..self.CurChargeList[1].backImg)
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

return M