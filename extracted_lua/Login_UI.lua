-- Code Auto Create Begin
local M = Class('Login_UI', UIBase)
function M:ctor()
    M.super.ctor(self)
    self.Uid = UID.Login_UI
    self.PathPrefab = 'ABOriginal/Prefab/Form/Form[Login_UI].prefab'
    self.Name = 'Form[Login_UI]'
    self.Layer = UILayerLv.Normal
    self.Depth = 1
    -- 没有使用组建缓存列表
    self.CC = {
        -- Image 列表
        {'Usm_Bg','Usm_Bg',2},{'Img_Logo','Img_Logo',2},{'Img_Touch','Img_Touch',2},{'Btn_Touch','Btn_Touch',2},{'Img_Area','Img_Area',2},{'Img_AreaBg','Img_Area/Img_AreaBg',2},{'Btn_Area','Img_Area/Btn_Area',2},{'Tog_Agree','Text_Agree/Tog_Agree',2},{'Img','Text_Agree/Tog_Agree/Img',2},{'Image','Text_Agree/Tog_Agree/Img/Image',2},{'Img_Hl','Text_Agree/Tog_Agree/Img/Img_Hl',2},{'usr','Text_Agree/usr',2},{'priv','Text_Agree/priv',2},{'Btn_Switch','RightPanel/Btn_Switch',2},{'Image01','RightPanel/Btn_Switch/Image',2},{'Btn_Log','RightPanel/Btn_Log',2},{'Image02','RightPanel/Btn_Log/Image',2},{'Btn_Kefu','RightPanel/Btn_Kefu',2},{'Image03','RightPanel/Btn_Kefu/Image',2},{'Btn_Delete','RightPanel/Btn_Delete',2},{'Image04','RightPanel/Btn_Delete/Image',2},{'Btn_Fenxiang','RightPanel/Btn_Fenxiang',2},{'Image05','RightPanel/Btn_Fenxiang/Image',2},{'SharePanel','SharePanel',2},{'shareMask','SharePanel/shareMask',2},{'Panel','SharePanel/Panel',2},{'Img_Biaotixian','SharePanel/Panel/Img_Biaotixian',2},{'Btn_FB','SharePanel/Panel/Btn_FB',2},{'Img_FBicon','SharePanel/Panel/Btn_FB/Img_FBicon',2},{'FBRedDotIcon','SharePanel/Panel/Btn_FB/FBRedDotIcon',2},{'Btn_Discord','SharePanel/Panel/Btn_Discord',2},{'Img_Discordicon','SharePanel/Panel/Btn_Discord/Img_Discordicon',2},{'DiscordRedDotIcon','SharePanel/Panel/Btn_Discord/DiscordRedDotIcon',2},{'Btn_Line','SharePanel/Panel/Btn_Line',2},{'Img_Lineicon','SharePanel/Panel/Btn_Line/Img_Lineicon',2},{'LineRedDotIcon','SharePanel/Panel/Btn_Line/LineRedDotIcon',2},{'Img_Xian2','SharePanel/Img_Xian2',2},{'Img_Xian1','SharePanel/Img_Xian1',2},
        -- Toggle 列表
        {'Tog_Agree01','Text_Agree/Tog_Agree',13},
        -- TextMeshProUGUI 列表
        {'Text_Ver','Text_Ver',20},{'Text_Touch','Img_Touch/Text_Touch',20},{'Text_Area','Img_Area/Text_Area',20},{'Text_Ping','Img_Area/Text_Ping',20},{'Text_Agree','Text_Agree',20},{'Text_Name','SharePanel/Panel/Text_Name',20},{'Text_FB','SharePanel/Panel/Btn_FB/Text_FB',20},{'Text_Discord','SharePanel/Panel/Btn_Discord/Text_Discord',20},{'Text_Line','SharePanel/Panel/Btn_Line/Text_Line',20},
    }
end
-- Code Auto Create End
require("LocalData/LanguageerrorLocalData")

function M:OnInit()
    local success, err = pcall(function()
        self:OnInitImp()
    end)
    if not success then
        if nil ~= err then
            MgrUI.Pop(UID.ClosePop_UI,{"<size=28>" .. err .. "</size>", function() end, true},true);
        else
            MgrUI.Pop(UID.ClosePop_UI,{"crash in Login_UI.OnInitImp.", function() end},true);
        end
    end
end

function M:OnInitImp()
    CJNBattleMgr.SetGameSpeed(1)
    self.isLogin = false
    self.isFastLogin = false
    local isTouchStart = false
    ---设置所有音量
    SettingViewModel.SetAllSound(SettingViewModel.GetAllSound())
    ---设置背景音量
    SettingViewModel.SetBGMSound(SettingViewModel.GetBGMSound())
    ---设置音效音量
    SettingViewModel.SetEffectSound(SettingViewModel.GetEffectSound())
    ---设置语音音量
    SettingViewModel.SetRoleSound(SettingViewModel.GetRoleSound())
    ---播放bgm
    MgrSound.PlayBGM(SteamLocalData.tab[113021][2],0.2)
    ---协议
    self.isAgree = UnityEngine.PlayerPrefs.GetInt("Agree") == 1 --true
    if self.isAgree then
        self.Text_Agree().gameObject:SetActive(false)
    end
    self.Tog_Agree01().isOn = UnityEngine.PlayerPrefs.GetInt("Agree") == 1
    Tools.ToggleValueChange(self.Tog_Agree01(),function(isOn)
        self.isAgree = isOn
        if isOn then
            UnityEngine.PlayerPrefs.SetInt("Agree",1)
        else
            UnityEngine.PlayerPrefs.SetInt("Agree",0)
        end
    end,nil)
    UIEvent.LuaClick(self.usr().gameObject,function()
        MgrUI.Pop(UID.AgreementPop_UI,{1,self},true)
    end)
    UIEvent.LuaClick(self.priv().gameObject,function()
        MgrUI.Pop(UID.AgreementPop_UI,{2,self},true)
    end)
    self.Text_Ver().text = "Ver"..MgrHot.CS:GetAppVer()..".R"..MgrRes.GetPackageVersion()
    ---打开登录
    UIEvent.LuaClick(self.Btn_Touch().gameObject,function()
        if not self.isAgree then
            MgrUI.Pop(UID.AgreementPop_UI,{1,self},true)
            return
        end
        if MgrSdk.IsFlyFun() then
            if MgrSdk.GetSdkAccessToken() == "" or MgrSdk.GetSdkAccessToken() == nil then
                MgrUI.Pop(UID.LoginPop02_UI)
                return
            end
            UnityEngine.DebugEx.LogError("zqx StartAccountLogin")
            MgrUI.Pop(UID.ChargeLoading_UI,nil,true)
            MgrSdk.AccountLogin(function(code,request)
                UnityEngine.DebugEx.LogError("zqx AccountLogin code:"..request)
                UnityEngine.DebugEx.LogError("zqx AccountLogin request:"..request)
                if code == 0 then
                    ---登录成功，打印用户信息
                    -- UnityEngine.DebugEx.Log("zqx AccountLogin:"..request)
                    local info = string.split(request, "&")
                    MgrNet.JpLogin(info[1], info[2], Handle(self, self.LoginReq))
                else
                    ---添加错误码弹窗
                    MgrUI.PopHide(UID.ChargeLoading_UI)
                    MgrUI.Pop(UID.PopTip_UI, {MgrLanguageData.GetLanguageByKey(LanguageerrorLocalData.tab[code][2]), 1}, true)
                end
            end)
        else
            MgrUI.Pop(UID.LoginPop_UI,{1},true)
        end
    end)
    ---显示公告
    UIEvent.LuaClick(self.Btn_Log().gameObject,function()
        MgrUI.Pop(UID.GongGaoPop)
        --MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("login_ui_develop"),1},true)
    end)
    ---切换账户
    UIEvent.LuaClick(self.Btn_Switch().gameObject,function()
        if MgrSdk.IsFlyFun() then
            --切换账号存在问题，SDK方要求先执行Logout
            MgrSdk.FlyFunLogout(Handle(self, self.OnLogout))
            --引继码输入框
            MgrUI.Pop(UID.LoginPop02_UI)
        else
            MgrUI.Pop(UID.LoginPop_UI,{2},true)
        end
    end)
    --删除账号
    UIEvent.LuaClick(self.Btn_Kefu().gameObject,function()
        if MgrSdk.IsFlyFun() then
            MgrSdk.FlyFunOpenGm()
        end
    end)
    self.SharePanel().gameObject:SetActive(false)
    UIEvent.LuaClick(self.Btn_Fenxiang().gameObject,function()
        self.SharePanel().gameObject:SetActive(true)
    end)
    UIEvent.LuaClick(self.shareMask().gameObject,function()
        self.SharePanel().gameObject:SetActive(false)
    end)
    UIEvent.LuaClick(self.Btn_FB().gameObject,function()
        Tools.OpenUrl("https://www.facebook.com/hazereverb/")
    end)
    UIEvent.LuaClick(self.Btn_Line().gameObject,function()
        Tools.OpenUrl("https://line.me/ti/g2/HLES3FK6gFC1rz1jgC4BVzRSEmzszBWWn40pMA?utm_source=invitation&utm_medium=link_copy&utm_campaign=default")
    end)
    UIEvent.LuaClick(self.Btn_Discord().gameObject,function()
        Tools.OpenUrl("https://discord.gg/ayf9Xp7d37")
    end)
    UIEvent.LuaClick(self.Img_Area().gameObject, function()
        MgrUI.Pop(UID.AreaList_UI,nil,true);
    end);

    ---播放视频背景
    local criMana = self.Usm_Bg().gameObject:GetComponent("CriManaMovieControllerForUI")
    criMana.player:SetFile(nil,MgrRes.GetABPath("USM/Common/Common/title-A.usm"))
    criMana:Play()
    
    MgrUI.Pop(UID.PartLoading_UI,nil,true);
    self:CheckArea();
    MgrNet.CS:StartPing();
end

function M:OnShowFinish()
    Event.Add("BackKey", Handle(self, self.OnBackKey))
    Event.Add("LoginSuccess", Handle(self, self.OnLoginSuccess))
    Event.Add("ServerReady", Handle(self, self.OnServerReady));
    ---登录创建完成后销毁检测更新界面
    LoginViewModel.CloseCheckUpdate()
    ---创建PartLoading_UI
    MgrUI.Pop(UID.PartLoading_UI,1,true)
    if MgrSdk.isSwitchAccount then
        MgrUI.Pop(UID.LoginPop02_UI)
    end
end

function M:LoginReq(info)
    UnityEngine.DebugEx.LogError("zqx LoginReq:"..serpent.block(info))
    MgrSdk.isSwitchAccount = false
    if info.errNo == 0 then
        self.isLogin = true
        self.isFastLogin = false
        --self.Btn_FB().gameObject:SetActive(true)
        -- self.Btn_Log().gameObject:SetActive(true)
        -- self.Btn_Switch().gameObject:SetActive(true)
        -- if MgrSdk.GetPlatform() == "2" then
        --     self.Btn_Delete().gameObject:SetActive(true)
        -- else
        --     self.Btn_Delete().gameObject:SetActive(false)
        -- end
        ---@type UserInfo 保存输入
        local user = {
            name = info.account,
            userId = info.userID,
            token = info.token,
            gate = info.addrGate
        }
        MgrNet.verifyInfo = user
        MgrNet.IsSocket = false
        self:ConnectServer()
    else
        if info.errNo == 20000 then
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("servererror_tips20000"), function ()
                self:LoginError()
            end},true)
        elseif info.errNo == 20001 then
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("loginpop_ui_tips17"), function ()
                self:LoginError()
            end},true)
        elseif info.errNo == 23002 then
            MgrUI.Pop(UID.NoticePop_UI, {info.errMsg, function ()
                MgrSdk.QuitApp()
            end}, true)
        else
            ---登录失败
            local str = MgrLanguageData.GetLanguageByKey("loginpop_ui_tips18")..string.format(":(%d)",info.errNo)
            MgrUI.Pop(UID.ClosePop_UI,{str, function ()
                self:LoginError()
            end},true)
        end
        MgrUI.PopHide(UID.ChargeLoading_UI)
    end
end

function M:FastLoginReq(info)
    if info.errNo == 0 then
        self.isLogin = true
        self.isFastLogin = true
        --self.Btn_FB().gameObject:SetActive(true)
        self.Btn_Log().gameObject:SetActive(true)
        -- self.Btn_Switch().gameObject:SetActive(true)
        if MgrSdk.GetPlatform() == "2" then
            self.Btn_Delete().gameObject:SetActive(true)
        else
            self.Btn_Delete().gameObject:SetActive(false)
        end
        ---@type UserInfo 保存输入
        local user = {
            name = info.account,
            userId = info.userID,
            token = info.token,
            gate = info.addrGate
        }
        MgrNet.verifyInfo = user
        ---储存本地账号信息
        LoginViewModel.SaveLocalAccount(info)
        MgrNet.IsSocket = false
        self:ConnectServer()
    else
        if info.errNo == 20000 then
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("servererror_tips20000"), function ()
                self:LoginError()
            end},true)
        elseif info.errNo == 20001 then
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("loginpop_ui_tips17"), function ()
                self:LoginError()
            end},true)
        elseif info.errNo == 23002 then
            MgrUI.Pop(UID.NoticePop_UI, {info.errMsg, function ()
                MgrSdk.QuitApp()
            end}, true)
        else
            ---登录失败
            local str = MgrLanguageData.GetLanguageByKey("loginpop_ui_tips18")..string.format(":(%d)",info.errNo)
            MgrUI.Pop(UID.ClosePop_UI,{str, function ()
                self:LoginError()
            end},true)
        end
    end
end

function M:ConnectServer()
    if MgrNet.IsSocket then
        return
    end
    if not MgrNet.ConnectServer(Handle(self,self.LauncherGameReq),Handle(self,self.LauncherGameAck),Handle(self,self.LauncherGameNtf)) then
        ---验证失败（网络异常或未保存token）
        MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("loginpop_ui_tips14"), function ()
            self:LoginError()
        end},true)
        MgrUI.PopHide(UID.ChargeLoading_UI)
    end
end

---进入游戏Req
function M:LauncherGameReq(err,msgId)
    if err == false then
        ---网络异常处理
        MgrNet.IsSocket = false
        MgrUI.Pop(UID.PopTip_UI,{string.format(MgrLanguageData.GetLanguageByKey("mgrnet_tips1"),err),1},true)
        MgrUI.PopHide(UID.ChargeLoading_UI)
    end
end
---进入游戏Ack
function M:LauncherGameAck(buffer, tag)
    local info = assert(pb.decode('PBClient.ClientVerifyACK',buffer))
    if info.errNo ~= 0 then
        ---失败
        MgrNet.IsSocket = false
        if info.errNo >= 20000 then
            MgrUI.Pop(UID.PopTip_UI,{MgrLanguageData.GetLanguageByKey("servererror_tips20000"),1},true)
        else
            MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("loginpop_ui_tips14"), function ()
                self:LoginError()
            end},true)
        end
        MgrUI.PopHide(UID.ChargeLoading_UI)
    end
end
---进入游戏Ntf
function M:LauncherGameNtf(buffer, tag)
    local info = assert(pb.decode('PBClient.ClientVerifyNTF',buffer))
    UnityEngine.DebugEx.LogError("zqx 登录推送："..serpent.block(info)) ---查看table内容
    if info.errNo == 0 then
        MgrNet.IsLogin = true
        ---更新网关推送数据
        MgrModel.PushData(info, false)
        -- local localInfo = LoginViewModel.GetLocalAccount()
        -- local status = UnityEngine.PlayerPrefs.GetString(localInfo.account .. "_Platform9000")
        -- if status ~= "bind" then
        --     MgrNet.HttpBindSdk(info.userID, MgrSdk.platform.Password, localInfo.account, localInfo.pwd, function (result)
        --         UnityEngine.PlayerPrefs.SetString(localInfo.account .. "_Platform9000", "bind")
        --         if result.code == 1 then
        --             print("zqx bind success")
        --         else
        --             UnityEngine.DebugEx.LogError("zqx bind error:"..serpent.block(result))
        --         end
        --     end)
        -- end
        if MgrUI.GetCurUI().Uid == UID.Login_UI then
            ---跳转到大厅
            LoginViewModel.EnterHome()
            ---Qoo恢復已購商品
            MgrSdk.CS:RestorePurchase()
            ShopViewModel.RestoreIOS()
        end
    else
        ---验证失败（服务器未通过）
        MgrNet.IsSocket = false
        UnityEngine.DebugEx.LogError("连接tcp失败"..info.errNo)
        MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("loginpop_ui_tips14"),function ()
            self:LoginError()
        end},true)
        MgrUI.PopHide(UID.ChargeLoading_UI)
    end
end

function M:LoginError()

end

function M:OnBackKey()
    print("Login OnBackKey:", MgrUI.IsPopOpen())
    local isSharePanel = self.SharePanel().gameObject.activeSelf --分享选择界面是否打开

    if not MgrUI.IsPopOpen() and MgrUI.IsShow(self.Uid) then --没有pop打开
        if isSharePanel then
            self.SharePanel().gameObject:SetActive(false)
            return
        else
            MgrSdk.ShowExitView()
        end
    end
end

function M:OnLoginSuccess()
    self.isLogin = true
    self.isFastLogin = false
    MgrSdk.isSwitchAccount = false
    self:ConnectServer()
end

---@private
function M:OnLogout(code, request)
    if code == 0 then
        UnityEngine.DebugEx.LogError("[Debug] MgrSdk.FlyFunLogout callback. success");
        MgrSdk.isSwitchAccount = true
    else
        UnityEngine.DebugEx.LogError("[Debug] MgrSdk.FlyFunLogout callback. failed. code: " .. code .. ", msg: " .. request);
    end
end

local CheckAreaTimer = "Login_UI.CheckArea";
local CheckServerTimer = "Login_UI.CheckServer";
local RefreshPingTimer = "Login_UI.RefreshPing";

function M:CheckArea()
    local state = MgrNet.CS:GetAreaState();
    if CS.RequestState.Ready == state then
        ---成功
        MgrUI.PopHide(UID.PartLoading_UI);
        self:OnAreaReady();
        return;
    end
    if CS.RequestState.Error == state then
        ---失败
        MgrUI.PopHide(UID.PartLoading_UI);
        MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("downloadpanel_tips2"), function()
            ---重试
            MgrUI.Pop(UID.PartLoading_UI,nil,true);
            MgrNet.CS:ReqArea();
            self:DelayCheckArea();
        end},true);
        return;
    end
    self:DelayCheckArea();
end

function M:DelayCheckArea()
    MgrTimer.Cancel(CheckAreaTimer);
    MgrTimer.AddDelay(CheckAreaTimer,0.2, Handle(self, self.CheckArea));
end

function M:OnAreaReady()
    if (-1 == MgrNet.CS:GetAreaIdx()) then
        ---从未选过，自动弹
        MgrUI.Pop(UID.AreaList_UI,nil,true);
    else
        self:ReqServer();
    end
end

function M:ReqServer()
    MgrUI.Pop(UID.PartLoading_UI,nil,true);
    MgrNet.CS:ReqServer();
    self:DelayCheckServer();
end

function M:CheckServer()
    local state = MgrNet.CS:GetServerState();
    if CS.RequestState.Ready == state then
        MgrUI.PopHide(UID.PartLoading_UI);
        self:OnServerReady();
        return;
    end
    if CS.RequestState.Error == state then
        ---失败
        MgrUI.PopHide(UID.PartLoading_UI);
        MgrUI.Pop(UID.ClosePop_UI,{MgrLanguageData.GetLanguageByKey("downloadpanel_tips2"), function()
            ---重试
            self:ReqServer();
        end},true);
        return;
    end
    self:DelayCheckServer();
end

function M:DelayCheckServer()
    MgrTimer.Cancel(CheckServerTimer);
    MgrTimer.AddDelay(CheckServerTimer,0.2, Handle(self, self.CheckServer));
end

function M:OnServerReady()
    ---刷新area信息
    self.Text_Area().text = "[ "..MgrNet.CS:GetCurAreaName().." ]";
    self:RefreshPing();    
    ---显示公告
    NoticeControl.GetNotice(function()
        MgrUI.Pop(UID.GongGaoPop,nil,true)
    end)
end

function M:RefreshPing()
    MgrTimer.Cancel(RefreshPingTimer);
    MgrTimer.AddDelay(RefreshPingTimer,3, Handle(self, self.RefreshPing));
    local areaIdx = MgrNet.CS:GetAreaIdx();
    local isOpen = MgrNet.CS:GetAreaOpen(areaIdx);
    if not isOpen then
        self.Text_Ping().text = MgrLanguageData.GetLanguageByKey("loginpop_ui_tips31");
        self.Text_Ping().color = Color(0.7, 0.7, 0.7, 1);
        return;
    end
    local pingTime = MgrNet.CS:GetAreaPing(areaIdx);
    if pingTime >= 3000 then
        self.Text_Ping().text = ">" .. pingTime .. " ms";
    else
        self.Text_Ping().text = pingTime .. " ms";
    end
    if (pingTime <= 200) then
        self.Text_Ping().color = Color(0.22, 0.71, 0.17, 1);
    elseif (pingTime <= 400) then
        self.Text_Ping().color = Color(0.88, 0.81, 0.21, 1);
    else
        self.Text_Ping().color = Color(0.71, 0.17, 0.17, 1);
    end
end

function M:OnClose()
    Event.Remove("BackKey", Handle(self, self.OnBackKey))
    Event.Remove("LoginSuccess", Handle(self, self.OnLoginSuccess))
    Event.Remove("ServerReady", Handle(self, self.OnServerReady));
    MgrTimer.Cancel(CheckAreaTimer);
    MgrTimer.Cancel(CheckServerTimer);
    MgrTimer.Cancel(RefreshPingTimer);
    MgrNet.CS:EndPing();
end

return M