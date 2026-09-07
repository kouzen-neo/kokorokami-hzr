-- Code Auto Create Begin
local M = Class('Activity_Gacha', UIItemBase)
function M:ctor()
    M.super.ctor(self)
    self.PathPrefab = 'ABOriginal/UI/Prefab/Template/Activity_Gacha.prefab'
    -- 没有使用组建缓存列表
    self.CC = {
        -- Image 列表
        {'Activity_Gacha','/',2},{'Btn_Qianwangtaofa','Btn_Qianwangtaofa',2},
        -- UITemplate 列表
        {'Activity_Gacha01','/',10},
        -- TextMeshProUGUI 列表
        {'Text_ShiJian','HuoDongShiJian/Text_ShiJian',20},{'Text_XiaoShi','HuoDongShiJian/Text_XiaoShi',20},
    }
end
-- Code Auto Create End
function M:OnInit()
    UIEvent.LuaClick(self.Btn_Qianwangtaofa().gameObject,Handle(self,function ()
        MgrUI.GoHide(UID.GachaPool_UI)
    end))
end
function M:OnUpdateUI(pData)
    ActivityControl.SetCurGiftID(pData[1])
    local tActivityData = ActivityControl.GetCurActivityByID(pData[1])
    local tCurData = ActivityControl.GetBuyGiftCfg()[pData[1]]
    --背景图替换
    if tCurData.backImg ~= "0" then
        MgrRes.LoadSprite(self.Activity_Gacha(), tCurData.backImg)
    end

    local tEndTime = string.split(tActivityData.endTime,'-')
    local tBeginTime = string.split(tActivityData.beginTime,'-')
    self.Text_XiaoShi().text = Global.GetTimeFormat(tBeginTime,tEndTime)
end

return M