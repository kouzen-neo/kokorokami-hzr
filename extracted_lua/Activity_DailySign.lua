-- Code Auto Create Begin
local M = Class('Activity_DailySign', UIItemBase)
function M:ctor()
    M.super.ctor(self)
    self.PathPrefab = 'ABOriginal/UI/Prefab/Template/Activity_DailySign.prefab'
    -- 没有使用组建缓存列表
    self.CC = {
        -- Image 列表
        {'Activity_DailySign','/',2},{'SignItemShow','DetailRewardPanel/SignItemShow',2},{'Img_Dian(qiandao)','DetailRewardPanel/SignItemShow/Img_Dian(qiandao)',2},{'Img_Richangjianglidi','DetailRewardPanel/SignItemShow/Img_Richangjianglidi',2},{'ItemPanel','DetailRewardPanel/SignItemShow/ItemPanel',2},{'SignItemRankImg','DetailRewardPanel/SignItemShow/ItemPanel/SignItemRankImg',2},{'SignItemIconImg','DetailRewardPanel/SignItemShow/ItemPanel/SignItemIconImg',2},{'Img_ItemCountPivot','DetailRewardPanel/SignItemShow/ItemPanel/Img_ItemCountPivot',2},{'Img_ItemCountBg','DetailRewardPanel/SignItemShow/ItemPanel/Img_ItemCountPivot/Img_ItemCountBg',2},{'SignItemShow2','DetailRewardPanel/SignItemShow2',2},{'Img_Dian(qiandao)01','DetailRewardPanel/SignItemShow2/Img_Dian(qiandao)',2},{'Img_Yuekajianglidi','DetailRewardPanel/SignItemShow2/Img_Yuekajianglidi',2},{'ItemPanel01','DetailRewardPanel/SignItemShow2/ItemPanel',2},{'SignItemRankImg2','DetailRewardPanel/SignItemShow2/ItemPanel/SignItemRankImg2',2},{'SignItemIconImg2','DetailRewardPanel/SignItemShow2/ItemPanel/SignItemIconImg2',2},{'Img_ItemCountPivot01','DetailRewardPanel/SignItemShow2/ItemPanel/Img_ItemCountPivot',2},{'Img_ItemCountBg01','DetailRewardPanel/SignItemShow2/ItemPanel/Img_ItemCountPivot/Img_ItemCountBg',2},{'SignItemShow3','DetailRewardPanel/SignItemShow3',2},{'Img_Dian(qiandao)02','DetailRewardPanel/SignItemShow3/Img_Dian(qiandao)',2},{'Img_Tilijianglidi','DetailRewardPanel/SignItemShow3/Img_Tilijianglidi',2},{'ItemPanel02','DetailRewardPanel/SignItemShow3/ItemPanel',2},{'SignItemRankImg3','DetailRewardPanel/SignItemShow3/ItemPanel/SignItemRankImg3',2},{'SignItemIconImg3','DetailRewardPanel/SignItemShow3/ItemPanel/SignItemIconImg3',2},{'Img_ItemCountPivot02','DetailRewardPanel/SignItemShow3/ItemPanel/Img_ItemCountPivot',2},{'Img_ItemCountBg02','DetailRewardPanel/SignItemShow3/ItemPanel/Img_ItemCountPivot/Img_ItemCountBg',2},{'LeftPanel','LeftPanel',2},{'RewardScrollRoot','LeftPanel/RewardScrollRoot',2},{'SignBtnPanel','SignBtnPanel',2},{'Time','SignBtnPanel/Time',2},{'LeijiShijian','SignBtnPanel/LeijiShijian',2},{'Btn_DailySign','SignBtnPanel/Btn_DailySign',2},{'Btn_DailySignHighLight','SignBtnPanel/Btn_DailySignHighLight',2},{'ClickToSign','ClickToSign',2},
        -- UITemplate 列表
        {'Activity_DailySign01','/',10},{'DailySignItem','LeftPanel/DailySignItem',10},
        -- Toggle 列表
        {'DailySignItem01','LeftPanel/DailySignItem',13},
        -- TextMeshProUGUI 列表
        {'Text_Richangjiangli','DetailRewardPanel/SignItemShow/Img_Richangjianglidi/Text_Richangjiangli',20},{'ItemCountText','DetailRewardPanel/SignItemShow/ItemPanel/Img_ItemCountPivot/Img_ItemCountBg/ItemCountText',20},{'RewardNameText','DetailRewardPanel/SignItemShow/RewardNameText',20},{'Text_Yuekajiangli','DetailRewardPanel/SignItemShow2/Img_Yuekajianglidi/Text_Yuekajiangli',20},{'ItemCountText2','DetailRewardPanel/SignItemShow2/ItemPanel/Img_ItemCountPivot/Img_ItemCountBg/ItemCountText2',20},{'RewardNameText2','DetailRewardPanel/SignItemShow2/RewardNameText2',20},{'RewardRemainDayText','DetailRewardPanel/SignItemShow2/RewardRemainDayText',20},{'Text_Tilijiangli','DetailRewardPanel/SignItemShow3/Img_Tilijianglidi/Text_Tilijiangli',20},{'ItemCountText3','DetailRewardPanel/SignItemShow3/ItemPanel/Img_ItemCountPivot/Img_ItemCountBg/ItemCountText3',20},{'RewardNameText3','DetailRewardPanel/SignItemShow3/RewardNameText3',20},{'TiliRemainDayText','DetailRewardPanel/SignItemShow3/TiliRemainDayText',20},{'SignTitleNameText','SignBtnPanel/Yue/SignTitleNameText',20},{'SignTitleMonthText','SignBtnPanel/Yue/SignTitleMonthText',20},{'TimeRemainText','SignBtnPanel/Time/TimeRemainText',20},{'CurTotalSignUpDateText','SignBtnPanel/LeijiShijian/CurTotalSignUpDateText',20},{'DailyBtnText','SignBtnPanel/Btn_DailySign/DailyBtnText',20},{'DailyBtnHighLightText','SignBtnPanel/Btn_DailySignHighLight/DailyBtnHighLightText',20},
    }
end
-- Code Auto Create End
---月签到
function M:OnInit()
    self.ClickToSign().gameObject:SetActive(false)
    ---奖励组
    self.ToggleObjs = {}
    ---初始化时钟
    self:InitClock()
    ---初始化事件
    self:InitClick()
    ---新的一个月
    self.newMonthComing = false
    
    Event.Add("DailySignRec",Handle(self,self.ReceiveChange))
end
---刷新
function M:OnUpdateUI()
    ---重置文本
    self:ReloadText()
    ---重置签到Toggle
    self:ReloadItems()

    self.Btn_DailySignHighLight().gameObject:SetActive(PlayerControl.GetPlayerData().monthSignFlag)
    ---是否显示月卡
    if PlayerControl.GetPlayerData().monthCardRemaining > 0 then
        --月卡生效
        self.SignItemShow2().gameObject:SetActive(true)
        ---显示月卡持续时间
        local remainDay = PlayerControl.GetPlayerData().monthCardRemaining
        self.RewardRemainDayText().text = MgrLanguageData.GetLanguageByKey("dailysign_ui_surplus") .. remainDay .. MgrLanguageData.GetLanguageByKey("dailysign_ui_sky")
        ---显示月卡奖励详情
        local rewardStr = string.split(SteamLocalData.tab[111004][2],"_")
        local cardReward = ItemControl.GetItemByIdAndType(tonumber(rewardStr[2]),tonumber(rewardStr[1]))
        ---获取背景(品质)
        MgrRes.LoadSprite(self.SignItemRankImg2(),cardReward.iconFrame)
        ---获取图标
        MgrRes.LoadSprite(self.SignItemIconImg2(),cardReward.icon)
        ---获取名称
        self.RewardNameText2().text = cardReward.name
        ---获取数量
        self.ItemCountText2().text = tonumber(rewardStr[3])
    else
        --月卡失效
        self.SignItemShow2().gameObject:SetActive(false)
    end
    -- 体力月卡
    if PlayerControl.GetPlayerData():GetNewMonthCardRemaining(110003) > 0 then
        self.SignItemShow3().gameObject:SetActive(true);
        if self.SignItemShow2().gameObject.activeSelf then
            self.SignItemShow3().gameObject.transform.localPosition = Vector3(self.SignItemShow2().gameObject.transform.localPosition.x, self.SignItemShow2().gameObject.transform.localPosition.y - 250, 0);
        else
            self.SignItemShow3().gameObject.transform.localPosition = self.SignItemShow2().gameObject.transform.localPosition;
        end
        self.TiliRemainDayText().text = MgrLanguageData.GetLanguageByKey("dailysign_ui_surplus") .. PlayerControl.GetPlayerData():GetNewMonthCardRemaining(110003) .. MgrLanguageData.GetLanguageByKey("dailysign_ui_sky")
        ---显示月卡奖励详情
        local rewards = string.split(SteamLocalData.tab[111025][2],",")
        local rewardStr = string.split(rewards[1],"_")
        local cardReward = ItemControl.GetItemByIdAndType(tonumber(rewardStr[2]),tonumber(rewardStr[1]))
        ---获取背景(品质)
        MgrRes.LoadSprite(self.SignItemRankImg3(),cardReward.iconFrame)
        ---获取图标
        MgrRes.LoadSprite(self.SignItemIconImg3(),cardReward.icon)
        ---获取名称
        self.RewardNameText3().text = cardReward.name
        ---获取数量
        self.ItemCountText3().text = tonumber(rewardStr[3])
    else
        self.SignItemShow3().gameObject:SetActive(false);
    end
end

---初始化时钟
function M:InitClock()
    local leftTime = ActivationTaskViewModel.GetLastTime("TODAY")
    local hour =  math.floor(leftTime/3600)
    local min = math.floor((leftTime - hour*3600) /60)
    local sec = math.floor((leftTime - hour*3600 - min * 60))
    self.TimeRemainText().text = (hour < 10 and "0".. hour or hour) ..":".. (min < 10 and "0".. min or min) ..":".. (sec < 10 and "0".. sec or sec)
    MgrTimer.AddRepeat("DailySignClock", 1, Handle(self,function()
        local leftTime = ActivationTaskViewModel.GetLastTime("TODAY")
        local hour =  math.floor(leftTime/3600)
        local min = math.floor((leftTime - hour*3600) /60)
        local sec = math.floor((leftTime - hour*3600 - min * 60))
        self.TimeRemainText().text = (hour < 10 and "0".. hour or hour) ..":".. (min < 10 and "0".. min or min) ..":".. (sec < 10 and "0".. sec or sec)
        print("daojishi ".. leftTime)
        if leftTime == 0 or leftTime == 86400 then
            self:ReloadText()
        end
    end) , -1, nil)
end
---初始化事件
function M:InitClick()
    ---签到点击
    UIEvent.LuaClick(self.Btn_DailySignHighLight().gameObject,Handle(self,SignViewModel.SendSign))
end
---重置文本
function M:ReloadText()
    self.SignTitleNameText().text = MgrLanguageData.GetLanguageByKey("dailysign_ui_signin_month")
    self.SignTitleMonthText().text = tonumber(os.date("%m",MgrNet.GetServerTime() - 18000 + (tonumber(SteamLocalData.tab[112007][2]) - Global.GetClientTimeZone()) * 3600))
    self.DailyBtnText().text = MgrLanguageData.GetLanguageByKey("dailysign_ui_signin_already")
    self.DailyBtnHighLightText().text = MgrLanguageData.GetLanguageByKey("dailysign_ui_signin_click")
    if self.newMonthComing then
        self.newMonthComing = false
        SignViewModel.SignData = 0
        PlayerControl.GetPlayerData():PushMonthSignBool(true)
    end
    SignViewModel.SignData = PlayerControl.GetMonthSignData()
    local cumulative = string.format(MgrLanguageData.GetLanguageByKey("dailysign_ui_signin_cumulative"),SignViewModel.SignData)
    self.CurTotalSignUpDateText().text = cumulative

    ---总共多少天
    local totalDays = Global.GetTotalDays()
    if SignViewModel.SignData >= totalDays then
        self.SignItemShow().gameObject:SetActive(false)
    else
        self.SignItemShow().gameObject:SetActive(true)
        ---显示下一次签到的物品
        --self:OnToggleClick(count + 1)
        ---获取配置
        local signCfg = SignViewModel.GetMonthLocalData()[SignViewModel.SignData + 1]
        ---获取背景(品质)
        local quality = SignViewModel.GetSignRewardQuality(signCfg.reward)
        MgrRes.LoadSprite(self.SignItemRankImg(),"Item/Rank/ItemRank_"..quality)
        ---获取图标
        MgrRes.LoadSprite(self.SignItemIconImg(),"Item/"..SignViewModel.GetSignRewardIcon(signCfg.reward))
        ---获取名称
        self.RewardNameText().text=SignViewModel.GetSignRewardName(signCfg.reward)
        ---获取数量
        self.ItemCountText().text=SignViewModel.GetSignRewardCount(signCfg.reward)
    end
    --[[
        self.YearMonthText().text = os.date("%Y年%m月",self.curTime)
        self.DayText().text = self.dayNum < 10 and "0"..self.dayNum or self.dayNum
        self.Day().text = "日"]]
end
---重置签到物品
function M:ReloadItems()
    self.DailySignItem().gameObject:SetActive(true)
    for day = 1, Global.GetTotalDays() do
        if not self.ToggleObjs[day] then
            ---不存在则创建Obj
            self.ToggleObjs[day] = GameObject.Instantiate(self.DailySignItem().gameObject,self.RewardScrollRoot().gameObject.transform,false)
            --self.ToggleObjs[day].transform:GetComponent("Toggle").isOn = false
            ---添加事件
            Tools.ToggleValueChange(self.ToggleObjs[day]:GetComponent("Toggle"),function(isOn)
                if isOn then
                    self:OnToggleClick(day)
                end
            end,nil)
        end

        ---更新Item数据
        local count = PlayerControl.GetMonthSignData()
        self.ToggleObjs[day]:GetComponent("UITemplate"):SetData({day,count})
    end
    ---选择累计天的图标
    --self.ToggleObjs[SignViewModel.GetCumulativeSign() + 1]:GetComponent("Toggle").isOn = true
    self.DailySignItem().gameObject:SetActive(false)
end
---点击奖励物品
function M:OnToggleClick(day)
    ---获取配置
    local signCfg = SignViewModel.GetMonthLocalData()[day]
    ---获取背景(品质)
    local quality = SignViewModel.GetSignRewardQuality(signCfg.reward)
    MgrRes.LoadSprite(self.SignItemRankImg(),"Item/Rank/ItemRank_"..quality)
    ---获取图标
    MgrRes.LoadSprite(self.SignItemIconImg(),"Item/"..SignViewModel.GetSignRewardIcon(signCfg.reward))
    ---获取名称
    self.RewardNameText().text=SignViewModel.GetSignRewardName(signCfg.reward)
    ---获取数量
    self.ItemCountText().text=SignViewModel.GetSignRewardCount(signCfg.reward)
    ---获得背包数据
    local rewardId = tonumber(string.split(signCfg.reward,"_")[2])
    local rewardType = tonumber(string.split(signCfg.reward,"_")[1])
    local BagItem = ItemControl.GetItemByIdAndType(rewardId,rewardType)
    MgrUI.Pop(UID.ItemDetailPop_UI,{BagItem, false, function() end},true)
end
---签到完成
function M:ReceiveChange()
    self.Btn_DailySignHighLight().gameObject:SetActive(false)

    PlayerControl.GetPlayerData().monthCardRemaining = PlayerControl.GetPlayerData().monthCardRemaining - 1 < 0 and 0 or PlayerControl.GetPlayerData().monthCardRemaining - 1
    self.RewardRemainDayText().text = MgrLanguageData.GetLanguageByKey("dailysign_ui_surplus") .. PlayerControl.GetPlayerData().monthCardRemaining .. MgrLanguageData.GetLanguageByKey("dailysign_ui_sky")
    if PlayerControl.GetPlayerData().monthCardRemaining <= 0 then
        self.SignItemShow2().gameObject:SetActive(false)
    end
    self.TiliRemainDayText().text = MgrLanguageData.GetLanguageByKey("dailysign_ui_surplus") .. PlayerControl.GetPlayerData():MinusNewMonthCardRemaining(110003) .. MgrLanguageData.GetLanguageByKey("dailysign_ui_sky")
    if PlayerControl.GetPlayerData():GetNewMonthCardRemaining(110003) <= 0 then
        self.SignItemShow3().gameObject:SetActive(false)
    else
        if self.SignItemShow2().gameObject.activeSelf then
            self.SignItemShow3().gameObject.transform.localPosition = Vector3(self.SignItemShow2().gameObject.transform.localPosition.x, self.SignItemShow2().gameObject.transform.localPosition.y - 250, 0);
        else
            self.SignItemShow3().gameObject.transform.localPosition = self.SignItemShow2().gameObject.transform.localPosition;
        end
    end
    ---重置文本
    self:ReloadText()
    ---重置签到Toggle
    self:ReloadItems()
end

return M