-- Code Auto Create Begin
local M = Class('PVPRankPop', UIBase)
function M:ctor()
    M.super.ctor(self)
    self.Uid = UID.PVPRankPop
    self.PathPrefab = 'ABOriginal/Prefab/Form/Form[PVPRankPop].prefab'
    self.Name = 'Form[PVPRankPop]'
    self.Layer = UILayerLv.Pop
    self.Depth = 10
    -- 没有使用组建缓存列表
    self.CC = {
        -- Image 列表
        {'BlurBg','Ani/BlurBg',2},{'Img_bg1','Ani/Img_bg1',2},{'Img_Xian1','Ani/Img_Xian1',2},{'Img_Xian2','Ani/Img_Xian2',2},{'Img_di','Ani/Img_di',2},{'NumberOne','Ani/RankPanel/NumberOne',2},{'Xian','Ani/RankPanel/NumberOne/Xian',2},{'Img_Saijidi','Ani/Rank/Img_Saijidi',2},{'Btn_Normal1','Ani/Rank/Btn_Normal1',2},{'Btn_LaskRank','Ani/Rank/Btn_Normal1/Btn_LaskRank',2},{'Btn_Normal','Ani/Rank/Btn_Normal',2},{'Btn_NextRank','Ani/Rank/Btn_Normal/Btn_NextRank',2},{'Img_Xian101','Ani/Img_Xian1',2},{'Btn_Return','Ani/Btn_Return',2},{'Btn_Back','Ani/Btn_Back',2},
        -- UITemplate 列表
        {'PVPRankItem','Ani/RankPanel/NumberOne/PVPRankItem',10},
        -- LoopScrollRect 列表
        {'RankScroll','Ani/RankPanel/RankScroll',18},
        -- TextMeshProUGUI 列表
        {'Text_CurRank','Ani/Rank/Text_CurRank',20},{'Text_Tips','Ani/Text_Tips',20},{'Text_Title','Ani/Text_Title',20},{'Text_Fanhui','Ani/Btn_Back/Text_Fanhui',20},
    }
end
-- Code Auto Create End
--- 533  643
---初始化
function M:OnInit()
    self.CurLoopList = {}
    self.isFirst = true
    self.CurPack = 0
    self.MaxPack = 0
    self.contentRect = self.RankScroll().gameObject:GetComponent("RectTransform")
    Event.Add("BackKey", Handle(self, self.OnBackKey))
    UIEvent.LuaClick(self.BlurBg().gameObject,Handle(self,self.ClosePop))
    UIEvent.LuaClick(self.Btn_Return().gameObject,Handle(self,self.ClosePop))
    UIEvent.LuaClick(self.Btn_LaskRank().gameObject,Handle(self, function()
        local version = PVPViewModel.MessageRankVersion - 1
        if version == 0 then
            return
        end
        ---重置第一次
        self.isFirst = true
        PVPViewModel.GetRankData(PVPViewModel.type,version,0,Handle(self,self.GetRankACK),Handle(self,self.GetRankNTF))
    end))
    UIEvent.LuaClick(self.Btn_NextRank().gameObject,Handle(self, function()
        local version = PVPViewModel.MessageRankVersion + 1
        if version > PVPViewModel.CurRankVersion then
            return
        end
        if version == PVPViewModel.CurRankVersion then
            version = 0
        end
        ---重置第一次
        self.isFirst = true
        PVPViewModel.GetRankData(PVPViewModel.type,version,0,Handle(self,self.GetRankACK),Handle(self,self.GetRankNTF))
    end))
    ---注册排名滑块
    self.RankScroll():SetLuaCellEvent(Handle(self,self.CellItem))
end

function M:OnBackKey()
    if not MgrUI.IsPopOpenOutSelf(self.Uid.Name) then --没有pop打开
        MgrUI.ClosePop(self.Uid)
    end
end

---更新显示
function M:OnShow(args)
    MgrSound.PlayEffect("yx_ui_tankuang_01",1,nil,false)
    ---刷新滑块
    PVPViewModel.GetRankData(PVPViewModel.type,0,0,Handle(self,self.GetRankACK),Handle(self,self.GetRankNTF))
end
function M:UpdataPlayerData()
    if self.lastRankFirst then
        self.NumberOne().gameObject:SetActive(true)
        self.PVPRankItem():SetData({self.lastRankFirst,self,true})
        self.contentRect.sizeDelta = Vector2(995, 533)

    else
        self.NumberOne().gameObject:SetActive(false)
        self.contentRect.sizeDelta = Vector2(995, 643)
    end
end
---排名滑块回调
function M:CellItem(trans,idx)
    if self.CurLoopList ~= nil then
        ---刷新item
        trans:GetComponent("UITemplate"):SetData({self.CurLoopList[idx],self})
        --if idx >= 80 then
        --    ---记录当前索引，防止反复请求
        --    if self.curRankIdx ~= nil and self.curRankIdx == idx then
        --        return
        --    end
        --    if (idx - self.CurPack*100) % 30 == 20 then
        --        self.curRankIdx = idx
        --        local page = self.CurPack + 1
        --        if page > self.MaxPack then
        --            ---超过最大页数 不请求
        --            return
        --        else
        --            ---请求下一页数据
        --            PVPViewModel.GetRankData(PVPViewModel.type,(PVPViewModel.CurRankVersion == PVPViewModel.MessageRankVersion and 0 or PVPViewModel.MessageRankVersion),page,Handle(self,self.GetRankACK),Handle(self,self.GetRankNTF))
        --        end
        --    end
        --end
    end
end

---排名滑块刷新
function M:ReloadRankView(isOnce)
    ---刷新滑块
    self.RankScroll().totalCount = #self.CurLoopList
    if isOnce then
        ---首次全刷新,若玩家有排名则刷新到玩家位置
        self.RankScroll():RefillCells(0)
    else
        ---之后不变位置刷新
        self.RankScroll():RefreshCells()
    end
end
function M:ClosePop()
    Event.Remove("BackKey", Handle(self, self.OnBackKey))
    MgrUI.ClosePop(self.Uid)
end

function M:CheckVersion()
    if PVPViewModel.CurRankVersion == 1 and PVPViewModel.CurRankVersion <= 0 then
        self.Btn_LaskRank().gameObject:SetActive(false)
        self.Btn_NextRank().gameObject:SetActive(false)
    elseif PVPViewModel.MessageRankVersion == PVPViewModel.CurRankVersion then
        self.Btn_LaskRank().gameObject:SetActive(true)
        self.Btn_NextRank().gameObject:SetActive(false)
    elseif PVPViewModel.MessageRankVersion < PVPViewModel.CurRankVersion then
        if PVPViewModel.MessageRankVersion == 1 then
            self.Btn_LaskRank().gameObject:SetActive(false)
            self.Btn_NextRank().gameObject:SetActive(true)
        else
            self.Btn_LaskRank().gameObject:SetActive(true)
            self.Btn_NextRank().gameObject:SetActive(true)
        end
    end
end
---获取排行数据
function M:GetRankACK(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientGetHighLadderRankACK',buffer))
    print(tab.errNo)
    if tab.errNo~=0 then
        MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("pvprankpop_tips1"),2},true)
        self:ClosePop()
    end
end
---获取排行数据
function M:GetRankNTF(buffer, tag)
    local tab = assert(pb.decode('PBClient.ClientGetHighLadderRankNTF',buffer))
    if tab.version ~= PVPViewModel.MessageRankVersion then
        self.CurLoopList = {}
    end
    if tab.info then
        for i, v in pairs(tab.info) do
            ---多出来的一条数据不算进去
            if v.rank ~= 101 then
                self.CurLoopList[v.rank + 1] = v
            end
        end
    end
    PVPViewModel.CurRankVersion = tab.nowVersion
    PVPViewModel.MessageRankVersion = tab.version
    self.CurPack = tab.pack
    self.MaxPack = tab.maxPack
    if self.CurPack == 0 then
        if tab.lastRankFirst then
            self.lastRankFirst = tab.lastRankFirst
        else
            self.lastRankFirst = nil
        end
    end
    self:UpdataPlayerData()
    self.Text_CurRank().text = MgrLanguageData.GetLanguageByKey("pvprankpop_rankseason")..tab.version
    if self.isFirst then
        self:ReloadRankView(true)
        self.isFirst = false
    else
        self:ReloadRankView()
    end
    self:CheckVersion()

end

return M