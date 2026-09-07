-- Code Auto Create Begin
local M = Class('GachaPool_UI', UIBase)
function M:ctor()
    M.super.ctor(self)
    self.Uid = UID.GachaPool_UI
    self.PathPrefab = 'ABOriginal/Prefab/Form/Form[GachaPool_UI].prefab'
    self.Name = 'Form[GachaPool_UI]'
    self.Layer = UILayerLv.Normal
    self.Depth = 1
    -- 没有使用组建缓存列表
    self.CC = {
        -- Image 列表
        {'Background','Background',2},{'Role','Role',2},{'SpineRole','Role/SpineRole',2},{'RoleClickArea','Role/SpineRole/RoleClickArea',2},{'Img_SoundTextBG','Role/Img_SoundTextBG',2},{'UI_Canvas','UI_Canvas',2},{'Niudanji','UI_Canvas/RightPanel/Niudanji',2},{'Img_Niudanji','UI_Canvas/RightPanel/Niudanji/Img_Niudanji',2},{'GachaReward','UI_Canvas/RightPanel/Niudanji/ShopItemScroll/GachaReward',2},{'Btn_Free1','UI_Canvas/RightPanel/Niudanji/Btn_Free1',2},{'Img_tiket','UI_Canvas/RightPanel/Niudanji/Btn_Free1/Img_tiket',2},{'Btn_Free2','UI_Canvas/RightPanel/Niudanji/Btn_Free2',2},{'Img_tiket01','UI_Canvas/RightPanel/Niudanji/Btn_Free2/Img_tiket',2},{'Btn_Special1','UI_Canvas/RightPanel/Niudanji/Btn_Special1',2},{'Img_tiket02','UI_Canvas/RightPanel/Niudanji/Btn_Special1/Img_tiket',2},{'Btn_Special2','UI_Canvas/RightPanel/Niudanji/Btn_Special2',2},{'Img_tiket03','UI_Canvas/RightPanel/Niudanji/Btn_Special2/Img_tiket',2},{'Img_SellOut','UI_Canvas/RightPanel/Niudanji/Img_SellOut',2},{'Img_Text','UI_Canvas/RightPanel/Niudanji/Img_SellOut/Img_Text',2},{'UpperRightPanel','UI_Canvas/RightPanel/UpperRightPanel',2},{'Huobi','UI_Canvas/RightPanel/UpperRightPanel/Huobi',2},{'Img_BG','UI_Canvas/RightPanel/UpperRightPanel/Huobi/Img_BG',2},{'CurrencyIcon','UI_Canvas/RightPanel/UpperRightPanel/Huobi/CurrencyIcon',2},{'Huobi1','UI_Canvas/RightPanel/UpperRightPanel/Huobi1',2},{'Img_BG01','UI_Canvas/RightPanel/UpperRightPanel/Huobi1/Img_BG',2},{'CurrencyIcon01','UI_Canvas/RightPanel/UpperRightPanel/Huobi1/CurrencyIcon',2},{'ReturnBg','UI_Canvas/ReturnBg',2},{'Btn_GoMenu','UI_Canvas/ReturnBg/Btn_GoMenu',2},{'Btn_Back','UI_Canvas/ReturnBg/Btn_Back',2},{'Btn_Help','UI_Canvas/ReturnBg/Btn_Help',2},{'Img_Fenggexian','UI_Canvas/ReturnBg/Img_Fenggexian',2},{'UnClickBg','UI_Canvas/UnClickBg',2},{'ItemPop','UI_Canvas/UnClickBg/ItemPop',2},{'Txt_Title','UI_Canvas/UnClickBg/Txt_Title',2},{'Img_Touch','UI_Canvas/UnClickBg/Img_Touch',2},{'Img_TouchMask','UI_Canvas/UnClickBg/Img_TouchMask',2},{'RewardItemPreFab','UI_Canvas/UnClickBg/RewardItemPreFab',2},{'RewardItemBg','UI_Canvas/UnClickBg/RewardItemPreFab/RewardItemBg',2},{'RewardRankImg','UI_Canvas/UnClickBg/RewardItemPreFab/RewardRankImg',2},{'RewardIconImg','UI_Canvas/UnClickBg/RewardItemPreFab/RewardIconImg',2},{'Img_ItemCountBg','UI_Canvas/UnClickBg/RewardItemPreFab/Img_ItemCountBg',2},{'StarPanel','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel',2},{'ItemStarRoot','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel/ItemStarRoot',2},{'ItemStarPrefab1','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab1',2},{'HighLight','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab1/HighLight',2},{'ItemStarPrefab2','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab2',2},{'HighLight01','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab2/HighLight',2},{'ItemStarPrefab3','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab3',2},{'HighLight02','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab3/HighLight',2},{'ItemStarPrefab4','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab4',2},{'HighLight03','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab4/HighLight',2},{'ItemStarPrefab5','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab5',2},{'HighLight04','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab5/HighLight',2},{'ItemStarPrefab6','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab6',2},{'HighLight05','UI_Canvas/UnClickBg/RewardItemPreFab/StarPanel/ItemStarRoot/ItemStarPrefab6/HighLight',2},{'ItemGroup','UI_Canvas/UnClickBg/ItemGroup',2},{'neon','UI_Canvas/neon',2},{'white','UI_Canvas/white',2},
        -- Text 列表
        {'Text_CurrencyCount','UI_Canvas/RightPanel/UpperRightPanel/Huobi/Text_CurrencyCount',3},{'Text_CurrencyCount01','UI_Canvas/RightPanel/UpperRightPanel/Huobi1/Text_CurrencyCount',3},
        -- UITemplate 列表
        {'GachaReward01','UI_Canvas/RightPanel/Niudanji/ShopItemScroll/GachaReward',10},
        -- RawImage 列表
        {'ShopItemScroll','UI_Canvas/RightPanel/Niudanji/ShopItemScroll',15},{'Content','UI_Canvas/RightPanel/Niudanji/ShopItemScroll/Content',15},
        -- LoopScrollRect 列表
        {'ShopItemScroll01','UI_Canvas/RightPanel/Niudanji/ShopItemScroll',18},
        -- TextMeshProUGUI 列表
        {'RoleVoiceWordText','Role/Img_SoundTextBG/RoleVoiceWordText',20},{'Text_tiketNum','UI_Canvas/RightPanel/Niudanji/Btn_Free1/Img_tiket/Text_tiketNum',20},{'Text_tiketNum01','UI_Canvas/RightPanel/Niudanji/Btn_Free2/Img_tiket/Text_tiketNum',20},{'Text_tiketNum02','UI_Canvas/RightPanel/Niudanji/Btn_Special1/Img_tiket/Text_tiketNum',20},{'Text_tiketNum03','UI_Canvas/RightPanel/Niudanji/Btn_Special2/Img_tiket/Text_tiketNum',20},{'Text_Title_CN','UI_Canvas/ReturnBg/Text_Title/Text_Title_CN',20},{'Text_Title_EN','UI_Canvas/ReturnBg/Text_Title/Text_Title_EN',20},{'Txt_Back','UI_Canvas/UnClickBg/Txt_Back',20},{'ItemCountText','UI_Canvas/UnClickBg/RewardItemPreFab/Img_ItemCountBg/ItemCountText',20},
    }
end
-- Code Auto Create End
function M:OnInit()
    self.UnClickBg().gameObject:SetActive(false)
    self.RewardItemPreFab().gameObject:SetActive(false)
    self.GifCfg = ActivityControl.GetBuyGiftCfg()
    --注册滑动
    self.ShopItemScroll01():SetLuaCellEvent(Handle(self, self.ItemCell))
    --按钮
    self.BtnList = {
        [1] = { btn=self.Btn_Free1().gameObject, tiket=self.Img_tiket(), useNum=self.Text_tiketNum(), isFree=false, shopId=0, buyNum=0 },
        [2] = { btn=self.Btn_Free2().gameObject, tiket=self.Img_tiket01(), useNum=self.Text_tiketNum01(), isFree=false, shopId=0, buyNum=0 },
        [3] = { btn=self.Btn_Special1().gameObject, tiket=self.Img_tiket02(), useNum=self.Text_tiketNum02(), isFree=false, shopId=0, buyNum=0 },
        [4] = { btn=self.Btn_Special2().gameObject, tiket=self.Img_tiket03(), useNum=self.Text_tiketNum03(), isFree=false, shopId=0, buyNum=0 },
    }
    --抽奖卷
    self.CoinList = {
        [1] = { Coin=self.Huobi().gameObject, ImgCoin=self.CurrencyIcon(), CoinNum=self.Text_CurrencyCount() },
        [2] = { Coin=self.Huobi1().gameObject, ImgCoin=self.CurrencyIcon01(), CoinNum=self.Text_CurrencyCount01() },
    }
    self.CoinData = {}
    self.DetailList = {}
    ---蛋池的抽取上限
    self.PoolLimit = 0
    ---蛋池的抽取次数
    self.PoolGachaNum = 0
    
    self:InitBtn()
end

function M:ItemCell(trans,idx)
    trans:GetComponent("UITemplate"):SetData(self.DetailList[idx])
end

function M:InitBtn()
    Event.Add("BackKey", Handle(self, self.OnBackKey))
    --点击返回上一级
    UIEvent.LuaClick(self.Btn_Back().gameObject,function()
        Event.Remove("BackKey", Handle(self, self.OnBackKey))
        MgrUI.GoBack()
    end)
    --点击返回主界面
    UIEvent.LuaClick(self.Btn_GoMenu().gameObject,function()
        Event.Remove("BackKey", Handle(self, self.OnBackKey))
        MgrUI.GoBackTo(UID.Home_UI)
    end)
    ---帮助
    UIEvent.LuaClick(self.Btn_Help().gameObject, function()
        
    end)
    --点击角色播放语音
    UIEvent.LuaClick(self.RoleClickArea().gameObject,Handle(self,function()
        self:GetCurWords(97)
    end))
    --关闭奖励弹窗
    UIEvent.LuaClick(self.Img_Touch().gameObject,function()
        self.UnClickBg().gameObject:SetActive(false)
    end,nil,self.Img_Touch())
end

function M:OnShow()
    self.GiftData = self.GifCfg[ActivityControl.GetCurGiftID()]
    for i, v in ipairs(self.GiftData.shopId) do
        if #self.BtnList >= i then
            self.BtnList[i].isFree = v[1]=="0"
            self.BtnList[i].shopId = tonumber(v[2])
            self.BtnList[i].buyNum = tonumber(v[3])
        end
    end
    
    local tCoinID_List = {}
    for i, v in ipairs(self.BtnList) do
        --按钮文字
        local ShopItemData = ShopViewModel.GetShopDataByID(114001,4,v.shopId)
        if ShopItemData then
            --手中持有的货币数量
            local data = ItemControl.GetItemByIdAndType(ShopItemData:GetPrice().goodsID,ShopItemData:GetPrice().goodsType)
            if tCoinID_List[data.id] == nil then
                table.insert(self.CoinData,data)
                tCoinID_List[data.id] = data
                self.PoolGachaNum = self.PoolGachaNum + ShopItemData.buyCount
            end
            --道具图片
            MgrRes.LoadSprite(v.tiket,data.icon)
            --道具数量
            v.useNum.text = "x "..v.buyNum
            --提示
            local Tips = string.format(MgrLanguageData.GetLanguageByKey("ui_tips_9"),data.name)

            UIEvent.LuaClick(v.btn,function()
                local tCurPoolNum = self.PoolLimit-self.PoolGachaNum
                local tCanBuyCount = ShopItemData.buyMaxCount-ShopItemData.buyCount
                --超过蛋池抽取上限
                if tCurPoolNum < v.buyNum then
                    MgrUI.Pop(UID.PopTip_UI, { MgrLanguageData.GetLanguageByKey("pvptimenumpop_tips1"), 1 }, true)
                    return
                end
                --超过抽取上限
                if tCanBuyCount < v.buyNum then
                    MgrUI.Pop(UID.PopTip_UI, { MgrLanguageData.GetErrorByKey(11518), 1 }, true)
                    return
                end
                --奖励弹窗
                MgrUI.Pop(UID.ConfirmPop_UI, { Tips, function()
                    if data.count < v.buyNum and not v.isFree then
                        MgrUI.Pop(UID.CardBuyPop,{MgrLanguageData.GetLanguageByKey("drawtenthresult_ui_gashapon_tips6"), data, v.buyNum, true, Handle(self, function()
                            --抽扭蛋
                            MgrTimer.AddDelayNoName(0.1,function()
                                self:OnGacha(v)
                            end)
                        end)},true)
                    else
                        --抽扭蛋
                        self:OnGacha(v)
                    end
                end, nil, 2 })
            end)
        end
    end
    --获取详情
    ActivityControl.GetDetail(self.BtnList[1].shopId, Handle(self,self.ItemDetailList))
    --货币更新
    self:UpdateCoin()
    --创建spine
    self:CreatSpine(self.SpineRole(),self.GiftData.npc)
end
---抽扭蛋
function M:OnGacha(_btnData)
    --抽扭蛋
    ShopViewModel.SendBuyGoods({ _btnData.shopId, _btnData.buyNum }, function(_items)
        --获取详情
        ActivityControl.GetDetail(_btnData.shopId, Handle(self,self.ItemDetailList))
        --货币更新
        self:UpdateCoin()
        --奖励弹窗
        self:ShowReward(_items)
        --购买成功+1
        self.PoolGachaNum = self.PoolGachaNum + 1
    end,true)
end

function M:ItemDetailList(_randomInfo)
    self.PoolLimit = #_randomInfo
    self.DetailList = {}
    local tBagList = {}
    local isAllGet = true
    for i, v in ipairs(_randomInfo) do
        local itemData = string.split(v.item,'_')
        local BagItem = ItemControl.GetItemByIdAndType(tonumber(itemData[2]),tonumber(itemData[1]))
        if tBagList[v.item] == nil then
            tBagList[v.item] = {
                id = i,
                item = BagItem,
                num = itemData[3] ~= nil and tonumber(itemData[3]) or 0,
                isGot = v.isGot,
                count = v.isGot and 0 or 1
            }
        else
            local num = 0
            if not v.isGot then
                num = 1
                tBagList[v.item].isGot = v.isGot
            end
            tBagList[v.item].count = tBagList[v.item].count+num
        end
        if v.isGot == false then
            isAllGet = v.isGot
        end
    end
    for i, v in pairs(tBagList) do
        table.insert(self.DetailList, v)
    end
    Global.Sort(self.DetailList, { "count","id" }, {true,false} )
    --蛋池奖励全部获取后显示
    self.Img_SellOut().gameObject:SetActive(isAllGet)
    
    self.ShopItemScroll01().totalCount = #self.DetailList
    self.ShopItemScroll01():RefillCells()
end
---货币更新
function M:UpdateCoin()
    for i, v in ipairs(self.CoinList) do
        if self.CoinData[i] then
            MgrRes.LoadSprite(v.ImgCoin, self.CoinData[i].icon)
            v.CoinNum.text = self.CoinData[i].count
            v.Coin:SetActive(true)
        else
            v.Coin:SetActive(false)
        end
    end
end
---奖励弹窗
function M:ShowReward(_items)
    local CurLoopList = {}
    for idx, goods in pairs(_items) do
        if goods.goodsNum ~= 0 then
            local data = ItemControl.GetItemByIdAndType(goods.goodsID,goods.goodsType)
            CurLoopList[#CurLoopList + 1] = {
                item = data,
                num = goods.goodsNum,
            }
        end
    end
    table.sort(CurLoopList, function(a,b)
        return a.item.quality > b.item.quality
    end)

    Tools.ClearAllChild(self.ItemGroup().gameObject)
    for i, v in ipairs(CurLoopList) do
        local item = GameObject.Instantiate(self.RewardItemPreFab().gameObject,self.ItemGroup().gameObject.transform,false)
        
        local _ItemCountText = CJNUIMgr.GetSunUseName(item, "ItemCountText"):GetComponent("TextMeshProUGUI")
        local _RewardRankImg = CJNUIMgr.GetSunUseName(item, "RewardRankImg"):GetComponent("Image")
        local _RewardIconImg = CJNUIMgr.GetSunUseName(item, "RewardIconImg"):GetComponent("Image")
        --设置品质
        MgrRes.LoadSprite(_RewardRankImg,v.item.iconFrame)
        --设置图标
        MgrRes.LoadSprite(_RewardIconImg,v.item.icon)
        --道具数量
        _ItemCountText.text = v.num

        item.gameObject:SetActive(true)

        --道具详情弹窗
        UIEvent.LuaClick(_RewardRankImg.gameObject,function()
            MgrUI.Pop(UID.ItemDetailPop_UI,{ v.item, true, function() end},true)
        end)
    end
    
    self.UnClickBg().gameObject:SetActive(true)
end

---创建立绘
function M:CreatSpine(_Root, _ShopId)
    if CharactercoordinatesLocalData.tab[_ShopId] == nil then
        return
    end
    self.groupId = _ShopId
    local _PosInfoTab = CharactercoordinatesLocalData.tab[_ShopId].coordinate10
    local _tempPosTab1 = JNStrTool.strSplit(";", _PosInfoTab)
    local _tempPosTab2 = JNStrTool.strSplit(",", _tempPosTab1[1])
    MgrRes.LoadWatch3DSpineInUI(_Root, _ShopId,tonumber(_tempPosTab2[1]), tonumber(_tempPosTab2[2]), tonumber(_tempPosTab1[2]), "idle", function(obj)
        self.SpineObj = obj
        obj.transform.gameObject.layer = 5
    end)
    self:GetCurWords(97)
end

---获取当前台词
function M:GetCurWords(type)
    local _ActorLinesType = self.groupId  --当前台词组别
    local _tempActorLineIdTab = {}  --临时表存储对应的文本台词ID和对应权重
    local _CurTotalSumWeight = 0 --当前总权重值
    for key, value in pairs(ActorLinesLocalData.tab) do
        ---匹配到对应的角色台词组别
        if value[2] == _ActorLinesType and value[3] == type then
            if value[5] == "0" then
                _CurTotalSumWeight = _CurTotalSumWeight + 10
                table.insert(_tempActorLineIdTab,{value[1],_CurTotalSumWeight})
            else
                ---切割对应的触发条件得到条件表
                local _TempVarTab = JNStrTool.strSplit("_", value[5])
                local _ReturnVar = TableToObject.GetTargetWeight(_TempVarTab, 0)
                if _ReturnVar ~= false then
                    _CurTotalSumWeight = _CurTotalSumWeight + (tonumber(_ReturnVar) * 1000)
                    table.insert(_tempActorLineIdTab, { value[1], _CurTotalSumWeight })
                end
            end
        end
    end
    local _FinalVoiceLineId = PosterGirlViewModel.GetRandIndexByHashTab(_CurTotalSumWeight, _tempActorLineIdTab)
    self:PlayTargetRoleAniVoice(_FinalVoiceLineId)
end

---根据对应的ID播放对应的角色动画以及语音等 改为等待当前动画播放完毕自动播放
function M:PlayTargetRoleAniVoice(_ActorLineId)
    if _ActorLineId == nil then
        return
    end
    local _AniName = ActorLinesLocalData.tab[_ActorLineId][6] --动画文件名
    local _AudioName = ActorLinesLocalData.tab[_ActorLineId][13]
    local _ActorLineWord = ActorLinesLocalData.tab[_ActorLineId][7]

    if self.SpineObj ~= nil then
        CMgrSpine.Instance:SetSpineAnimation(self.SpineObj, _AniName, true)
    end
    ---设置文本框文本
    self.RoleVoiceWordText().text = _ActorLineWord
    self.Img_SoundTextBG().gameObject:SetActive(true)

    MgrSound.PlayRole(_AudioName, nil, nil, false, 0, 0,tostring(self.groupId))
    self:ListenVoice()
end

--- 监听语音是否结束
function M:ListenVoice()
    MgrTimer.AddRepeat("GachaRoleVoice",0.2,function()
        if MgrSound.CheckRoleStatus(tostring(self.groupId)) then
            MgrTimer.Cancel("GachaRoleVoice")
            self.Img_SoundTextBG().gameObject:SetActive(false)
        end
    end,-1,nil)
end

function M:OnBackKey()
    if not MgrUI.IsPopOpen() and MgrUI.IsShow(self.Uid) then
        Event.Remove("BackKey", Handle(self, self.OnBackKey))
        MgrUI.GoBack()
    end
end

return M