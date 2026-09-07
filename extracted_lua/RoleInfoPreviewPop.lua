-- Code Auto Create Begin
local M = Class('RoleInfoPreviewPop', UIBase)
function M:ctor()
    M.super.ctor(self)
    self.Uid = UID.RoleInfoPreviewPop
    self.PathPrefab = 'ABOriginal/Prefab/Form/Form[RoleInfoPreviewPop].prefab'
    self.Name = 'Form[RoleInfoPreviewPop]'
    self.Layer = UILayerLv.Pop
    self.Depth = 10
    -- 没有使用组建缓存列表
    self.CC = {
        -- Image 列表
        {'BlurMask','BlurMask',2},{'RoleInfoPreview','RoleInfoPreview',2},{'ClickBackArea','RoleInfoPreview/ClickBackArea',2},{'ClickBackAreaMask','RoleInfoPreview/ClickBackAreaMask',2},{'Img_Tanchuangdi','RoleInfoPreview/Img_Tanchuangdi',2},{'Img_Xian1','RoleInfoPreview/Img_Xian1',2},{'Img_Xian2','RoleInfoPreview/Img_Xian2',2},{'Hp','RoleInfoPreview/RoleInfoPanel/Hp',2},{'HpIcon','RoleInfoPreview/RoleInfoPanel/Hp/HpIcon',2},{'Atk','RoleInfoPreview/RoleInfoPanel/Atk',2},{'AtkIcon','RoleInfoPreview/RoleInfoPanel/Atk/AtkIcon',2},{'Zhiyuan','RoleInfoPreview/RoleInfoPanel/Zhiyuan',2},{'ZhiyuanIcon','RoleInfoPreview/RoleInfoPanel/Zhiyuan/ZhiyuanIcon',2},{'Def','RoleInfoPreview/RoleInfoPanel/Def',2},{'DefIcon','RoleInfoPreview/RoleInfoPanel/Def/DefIcon',2},{'Baoji','RoleInfoPreview/RoleInfoPanel/Baoji',2},{'BaojiIcon','RoleInfoPreview/RoleInfoPanel/Baoji/BaojiIcon',2},{'Baoshang','RoleInfoPreview/RoleInfoPanel/Baoshang',2},{'BaoshangIcon','RoleInfoPreview/RoleInfoPanel/Baoshang/BaoshangIcon',2},{'Mingjie','RoleInfoPreview/RoleInfoPanel/Mingjie',2},{'MingjieIcon','RoleInfoPreview/RoleInfoPanel/Mingjie/MingjieIcon',2},{'Background','RoleInfoPreview/RoleLvPanel/Slider/Background',2},{'Fill','RoleInfoPreview/RoleLvPanel/Slider/Fill Area/Fill',2},{'Handle','RoleInfoPreview/RoleLvPanel/Slider/Handle Slide Area/Handle',2},{'Handle(1)','RoleInfoPreview/RoleLvPanel/Slider/Handle Slide Area/Handle/Handle (1)',2},{'Btn_LvDownLight','RoleInfoPreview/RoleLvPanel/Btn_LvDownLight',2},{'-(hei)2','RoleInfoPreview/RoleLvPanel/Btn_LvDownLight/-(hei)2',2},{'Btn_LvDown','RoleInfoPreview/RoleLvPanel/Btn_LvDown',2},{'-(hui)2','RoleInfoPreview/RoleLvPanel/Btn_LvDown/-(hui)2',2},{'Btn_LvUpLight','RoleInfoPreview/RoleLvPanel/Btn_LvUpLight',2},{'+(hei)2','RoleInfoPreview/RoleLvPanel/Btn_LvUpLight/+(hei)2',2},{'Btn_LvUp','RoleInfoPreview/RoleLvPanel/Btn_LvUp',2},{'+(hui)2','RoleInfoPreview/RoleLvPanel/Btn_LvUp/+(hui)2',2},{'Star','RoleInfoPreview/RoleStarPanel/Star',2},{'StarAwaken','RoleInfoPreview/RoleStarPanel/StarAwaken',2},{'StarPanel','RoleInfoPreview/RoleStarPanel/StarPanel',2},{'Btn_StarLvDownLight','RoleInfoPreview/RoleStarPanel/Btn_StarLvDownLight',2},{'-(hei)201','RoleInfoPreview/RoleStarPanel/Btn_StarLvDownLight/-(hei)2',2},{'Btn_StarLvDown','RoleInfoPreview/RoleStarPanel/Btn_StarLvDown',2},{'-(hui)201','RoleInfoPreview/RoleStarPanel/Btn_StarLvDown/-(hui)2',2},{'Btn_StarLvUpLight','RoleInfoPreview/RoleStarPanel/Btn_StarLvUpLight',2},{'+(hei)201','RoleInfoPreview/RoleStarPanel/Btn_StarLvUpLight/+(hei)2',2},{'Btn_StarLvUp','RoleInfoPreview/RoleStarPanel/Btn_StarLvUp',2},{'+(hui)201','RoleInfoPreview/RoleStarPanel/Btn_StarLvUp/+(hui)2',2},{'Btn_Xihuan','RoleInfoPreview/RoleStarPanel/Btn_Xihuan',2},{'StarAwaken_hui','RoleInfoPreview/RoleStarPanel/Btn_Xihuan/StarAwaken_hui',2},{'StarAwaken01','RoleInfoPreview/RoleStarPanel/Btn_Xihuan/StarAwaken',2},{'biaotixian','RoleInfoPreview/biaotixian',2},{'XiangxiPanel','XiangxiPanel',2},{'Img_Tanchuangdi01','XiangxiPanel/Img_Tanchuangdi',2},{'Content','XiangxiPanel/XiangxiScroll/Mask/Content',2},{'Img_Zhiyejieshao','XiangxiPanel/XiangxiScroll/Mask/Content/Img_Zhiyejieshao',2},{'Img_Shuxingjieshao','XiangxiPanel/XiangxiScroll/Mask/Content/Img_Shuxingjieshao',2},{'Img_Biaotixian','XiangxiPanel/Img_Biaotixian',2},{'Img_Xian201','XiangxiPanel/Img_Xian2',2},{'Img_Xian101','XiangxiPanel/Img_Xian1',2},
        -- Text 列表
        {'DefNameTxt','RoleInfoPreview/RoleInfoPanel/Def/DefNameTxt',3},{'PanelTitleText','XiangxiPanel/PanelTitleText',3},
        -- Slider 列表
        {'Slider','RoleInfoPreview/RoleLvPanel/Slider',5},
        -- TextMeshProUGUI 列表
        {'HpNameTxt','RoleInfoPreview/RoleInfoPanel/Hp/HpNameTxt',20},{'HPInfoTxt','RoleInfoPreview/RoleInfoPanel/Hp/HPInfoTxt',20},{'AtkNameTxt','RoleInfoPreview/RoleInfoPanel/Atk/AtkNameTxt',20},{'AtkInfoTxt','RoleInfoPreview/RoleInfoPanel/Atk/AtkInfoTxt',20},{'ZhiyuanNameTxt','RoleInfoPreview/RoleInfoPanel/Zhiyuan/ZhiyuanNameTxt',20},{'ZhiYuanInfoTxt','RoleInfoPreview/RoleInfoPanel/Zhiyuan/ZhiYuanInfoTxt',20},{'DefInfoTxt','RoleInfoPreview/RoleInfoPanel/Def/DefInfoTxt',20},{'BaojiNameTxt','RoleInfoPreview/RoleInfoPanel/Baoji/BaojiNameTxt',20},{'BaojiInfoTxt','RoleInfoPreview/RoleInfoPanel/Baoji/BaojiInfoTxt',20},{'BaoShangNameTxt','RoleInfoPreview/RoleInfoPanel/Baoshang/BaoShangNameTxt',20},{'BaoshangInfoTxt','RoleInfoPreview/RoleInfoPanel/Baoshang/BaoshangInfoTxt',20},{'MinjieNameTxt','RoleInfoPreview/RoleInfoPanel/Mingjie/MinjieNameTxt',20},{'MinjieInfoTxt','RoleInfoPreview/RoleInfoPanel/Mingjie/MinjieInfoTxt',20},{'Text_LV','RoleInfoPreview/RoleLvPanel/Text_LV',20},{'Text_Dengji','RoleInfoPreview/RoleLvPanel/Text_Dengji',20},{'PanelTitleText01','RoleInfoPreview/PanelTitleText',20},
    }
end
-- Code Auto Create End
function M:OnInit()
    self.RoleInfoPreview().gameObject:SetActive(false)
    self.XiangxiPanel().gameObject:SetActive(false)
    self.Star().gameObject:SetActive(false)
    self.StarAwaken().gameObject:SetActive(false)
    self.Slider().minValue = 1
    ---当前页签
    self.PageType = ""
    ---当前人物属性
    self.CurHero = nil
    ---是否觉醒
    self.IsAwaken = false
    ---当前等级
    self.CurLv = 1
    ---当前星级
    self.CurStarLv = 3
    ---该角色的最低星级
    self.MinStarLv = 1
    ---当前最大等级
    self.CurMaxLv = 100
    ---星数组
    self.unAwakenStar = {}
    ---觉醒星数组
    self.onAwakenStar = {}

    self.HasClick = false
    
    self.BtnType = {
        ---觉醒按钮
        BtnAwanken = 1,
        ---升星按钮
        BtnStarUp = 2,
        ---降星按钮
        BtnStarDown = 3,
        ---升级按钮
        BtnLvUp = 4,
        ---降级按钮
        BtnLvDown = 5,
    }
    
    ---按钮初始化
    self:InitButton()
end

function M:InitButton()
    Event.Add("BackKey", Handle(self, self.OnBackKey))
    ---点击周边
    UIEvent.LuaClick(self.BlurMask().gameObject,function()
        Event.Remove("BackKey", Handle(self, self.OnBackKey))
        MgrUI.ClosePop(self.Uid)
    end)
    ---觉醒按钮
    UIEvent.LuaClick(self.Btn_Xihuan().gameObject,function()
        self:OnChangeAttr(self.BtnType.BtnAwanken)
    end)
    ---星级调整按钮
    UIEvent.LuaClick(self.Btn_StarLvUpLight().gameObject,function()
        self:OnChangeAttr(self.BtnType.BtnStarUp)
    end)
    UIEvent.LuaClick(self.Btn_StarLvDownLight().gameObject,function()
        self:OnChangeAttr(self.BtnType.BtnStarDown)
    end)
    ---等级调整按钮
    UIEvent.LuaClick(self.Btn_LvUpLight().gameObject,function()
        self:OnChangeAttr(self.BtnType.BtnLvUp)
    end)
    UIEvent.LuaClick(self.Btn_LvDownLight().gameObject,function()
        self:OnChangeAttr(self.BtnType.BtnLvDown)
    end)
    ---滑动条
    Tools.OnSliderValueChange(self.Slider(),function()
        self.CurLv = math.ceil(self.Slider().value)
        self:SwitchBtnState(2)
        local tCurHeroAttr = ReadData.GetRoleAttr(self.CurHero.id, self.CurLv, self.CurStarLv, 0, self.IsAwaken)
        self:UpdataRoleInfo(tCurHeroAttr,self.IsAwaken)
    end)
end

function M:OnBackKey()
    if not MgrUI.IsPopOpenOutSelf(self.Uid.Name) then
        Event.Remove("BackKey", Handle(self, self.OnBackKey))
        MgrUI.ClosePop(self.Uid)
    end
end

function M:OnShow(args)
    self.PageType = args[1]
    
    if self.PageType == "IconDetails" then
        ---图标介绍
        self.XiangxiPanel().gameObject:SetActive(true)
    elseif self.PageType == "RoleInfo" then
        ---成长预览
        self.RoleInfoPreview().gameObject:SetActive(true)
        
        self.CurHero = args[2]
        self.IsAwaken = self.CurHero.awaken
        self.CurLv = self.CurHero.level
        self.CurStarLv = self.CurHero.star
        local tCurHeroAttr = self.CurHero:GetHeroAttr()
        self.MinStarLv = tCurHeroAttr.MinStart

        self:InitRoleInfo(tCurHeroAttr)
        self:UpdataRoleInfo(tCurHeroAttr,self.IsAwaken)
        
        self:SwitchBtnState(1)
        self:SwitchBtnState(2)
    end
end

function M:InitRoleInfo(_att)
    ---判断是否为支援角色
    if _att.Occupation == 4 then
        self.Zhiyuan().gameObject:SetActive(true)
        self.Atk().gameObject:SetActive(false)
    else
        self.Zhiyuan().gameObject:SetActive(false)
        self.Atk().gameObject:SetActive(true)
    end
    for i = 1, _att.MaxStart do
        ---预创建星
        self.unAwakenStar[i] = self:CreatStar(self.StarPanel(), self.Star())
        ---预创建觉醒星
        self.onAwakenStar[i] = self:CreatStar(self.StarPanel(), self.StarAwaken())
    end
    ---觉醒按钮图
    self.StarAwaken01().gameObject:SetActive(self.CurHero.awaken)
    self.StarAwaken_hui().gameObject:SetActive(not self.CurHero.awaken)
end

function M:UpdataRoleInfo(_attr,_isAwaken)
    ---角色名等信息
    self.CurMaxLv = _attr.LvMax
    self.Slider().maxValue = self.CurMaxLv
    self.Text_Dengji().text = (_attr.LV <= _attr.LvMax and _attr.LV or _attr.LvMax) .. "/" .. _attr.LvMax
    self.Slider().value = _attr.LV
    if tonumber(_attr.HP) >= 1000000 then
        self.HPInfoTxt().text = (self.GetMillionNumInfo(_attr.HP)) .. "M"
    else
        self.HPInfoTxt().text = math.floor(_attr.HP)
    end
    ---角色属性信息
    self.AtkInfoTxt().text = "" .. math.floor(_attr.RealAtk)
    self.ZhiYuanInfoTxt().text = "" .. math.floor(self:GetInfoCorrect(_attr.RealSuppart)) .. "%"
    self.DefInfoTxt().text = "" .. math.floor((self:GetInfoCorrect(_attr.RealDef))) .. "%"
    self.MinjieInfoTxt().text = "" .. math.floor((self:GetInfoCorrect(_attr.RealAgile))) .. "%"
    self.BaojiInfoTxt().text = "" .. math.floor((self:GetInfoCorrect(_attr.RealCrit))) .. "%"
    self.BaoshangInfoTxt().text = "" .. math.floor((self:GetInfoCorrect(_attr.RealCritDmg))) .. "%"
    
    ---设置星
    for i = 1, #self.unAwakenStar do
        self.unAwakenStar[i].gameObject:SetActive(i <= _attr.StartLV and not _isAwaken)
        ---未觉醒星
        self.onAwakenStar[i].gameObject:SetActive(i <= _attr.StartLV and _isAwaken)     ---觉醒星
    end
end

function M:OnChangeAttr(_btnType)    
    local tReset = false
    if self.BtnType.BtnAwanken == _btnType then
        ---觉醒切换
        if self.CurStarLv < self.CurHero.awakenStar then
            MgrUI.Pop(UID.PopTip_UI, { string.format(MgrLanguageData.GetLanguageByKey("character_awake_tips1"),self.CurHero.awakenStar), 1 }, true)
            return
        end
        self.IsAwaken = not self.IsAwaken
        self.StarAwaken01().gameObject:SetActive(self.IsAwaken)
        self.StarAwaken_hui().gameObject:SetActive(not self.IsAwaken)
        --self:SwitchBtnState(1)
        tReset = true
    elseif self.BtnType.BtnStarUp == _btnType then
        ---升星
        if self.CurStarLv >= #self.unAwakenStar then
            return
        end
        self.CurStarLv = self.CurStarLv + 1
        --self:SwitchBtnState(1)
        tReset = true
    elseif self.BtnType.BtnStarDown == _btnType then
        ---降星
        if self.CurStarLv <= 1 then
            return
        end
        self.CurStarLv = self.CurStarLv - 1
        --self:SwitchBtnState(1)
        tReset = true
    elseif self.BtnType.BtnLvUp == _btnType then
        ---升级
        if self.CurLv >= self.CurMaxLv then
            return
        end
        self.CurLv = self.CurLv + 1
        self.Slider().value = self.CurLv
    elseif self.BtnType.BtnLvDown == _btnType then
        ---降级
        if self.CurLv <= 1 then
            return
        end
        self.CurLv = self.CurLv - 1
        self.Slider().value = self.CurLv
    end

    local tCurHeroAttr = ReadData.GetRoleAttr(self.CurHero.id, self.CurLv, self.CurStarLv, 0, self.IsAwaken)
    self:UpdataRoleInfo(tCurHeroAttr,self.IsAwaken)
    ---刷新按钮状态
    if tReset then
        self:SwitchBtnState(1)
        self:SwitchBtnState(2)
    end
end
---切换按钮高光低光
function M:SwitchBtnState(_BtnType)
    if _BtnType == 1 then
        if self.CurStarLv >= #self.unAwakenStar then
            Tools.ObjSetLastSibling(self.Btn_StarLvUp().gameObject)
            Tools.ObjSetLastSibling(self.Btn_StarLvDownLight().gameObject)
        elseif (not self.IsAwaken and self.CurStarLv <= self.MinStarLv) or (self.IsAwaken and self.CurStarLv <= self.CurHero.awakenStar) then
            Tools.ObjSetLastSibling(self.Btn_StarLvDown().gameObject)
            Tools.ObjSetLastSibling(self.Btn_StarLvUpLight().gameObject)
        else
            Tools.ObjSetLastSibling(self.Btn_StarLvUpLight().gameObject)
            Tools.ObjSetLastSibling(self.Btn_StarLvDownLight().gameObject)
        end
    elseif _BtnType == 2 then
        if self.CurLv >= self.CurMaxLv then
            Tools.ObjSetLastSibling(self.Btn_LvUp().gameObject)
            Tools.ObjSetLastSibling(self.Btn_LvDownLight().gameObject)
        elseif self.CurLv <= 1 then
            Tools.ObjSetLastSibling(self.Btn_LvDown().gameObject)
            Tools.ObjSetLastSibling(self.Btn_LvUpLight().gameObject)
        else
            Tools.ObjSetLastSibling(self.Btn_LvUpLight().gameObject)
            Tools.ObjSetLastSibling(self.Btn_LvDownLight().gameObject)
        end
    end
end
--创建星星
function M:CreatStar(_Root, _Prefab)
    local tempObj = GameObject.Instantiate(_Prefab, _Root.transform)
    tempObj.gameObject:SetActive(true)
    tempObj.transform.localPosition = Vector3(tempObj.transform.localPosition.x, tempObj.transform.localPosition.y, 0)
    
    return tempObj
end
---取整人物信息
function M:GetInfoCorrect(_Data)
    -- statements
    local tempInt1 = 0
    local tempInt2 = 0
    local tempData = 0
    tempInt1, tempInt2 = math.modf((_Data * 10000) / 1)
    tempData = tempInt1 / 100
    return tempData
end

function M:OnClose()
    Event.Remove("BackKey", Handle(self, self.OnBackKey))
    MgrTimer.Cancel("SliderListen")
end

return M