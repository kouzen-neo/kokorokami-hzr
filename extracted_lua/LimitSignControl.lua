require("LocalData/SignineventLocalData")
require("LocalData/ActivityLocalData")
require("LocalData/OpensignineventLocalData")
---管理器
LimitSignControl = {}

local LimitSignDataList = {}
local group = ActivityLocalData.tab[43000][6] ---版本号
local activityid = 43000
local limitSign = {} --服务器初始化数据
local ActivityInfo = {}
---百日签到数据
local SignAllData = {}
local SignAllActID = 0
function LimitSignControl.Init()
    local actData = nil
    for i,v in pairs(ActivityLocalData.tab) do
        if v[2] == ActivityControl.activityTypeEnum.LIMITSIGN then
            actData = v
        end
    end
    if actData == nil then
        return
    end
    group = actData[6]
    activityid = actData[1]
    local tab = {} 
    for i, v in ipairs(SignineventLocalData.tab) do
        if group == v.group and activityid == v.activityid then
            table.insert(tab,v)
        end
    end
    LimitSignDataList = tab

    if PlayerControl.GetPlayerData().limitSign then
        limitSign = nil
        for i,v in pairs(PlayerControl.GetPlayerData().limitSign) do
            if v.activityId == activityid then
                limitSign = v
                break
            end
        end
    else
        limitSign = nil
    end
    LimitSignControl.IsOverTime5()
    --初始化百日签到
    LimitSignControl.InitSignAll()
end

function LimitSignControl.GetActivityInfo()
    return ActivityInfo
end

function LimitSignControl.SetActivityInfo(_ActivityInfo)
    ActivityInfo = _ActivityInfo
end

---限时签到红点
function LimitSignControl.CheckLimitSignRedDot()
    if LimitSignControl.GetIsSignDay() then
        RedDotControl.GetDotData("limitSign"):SetState(true)
    else
        RedDotControl.GetDotData("limitSign"):SetState(false)
    end
end

---获得活动数据
function LimitSignControl.GetLimitSignData()
    local tab = {}
    table.insert(tab,{id = 0})
    for i, v in ipairs(LimitSignDataList) do
        table.insert(tab,v)
    end
    table.insert(tab,{id = 0})
    return tab
end

---已经签到天数
function LimitSignControl.GetSignDay()
    if limitSign then
        return limitSign.day
    else
        return 0
    end
end

function LimitSignControl.GetInitData()
    return limitSign
end

function LimitSignControl.SetInitData(_time,_day)
    if limitSign then
        limitSign.day = _day
        limitSign.time = _time
    else
        limitSign = {
            time = _time,
            day = _day
        }
    end
end

---今天是否可以签到
-- local _month = tonumber(os.date("%m",tonumber(limitSign.time)))
--     local _day = tonumber(os.date("%d",tonumber(limitSign.time)))
--     local weekday = tonumber(os.date("%w",tonumber(limitSign.time))) --- 0-6 周日-周六
--     local hour = tonumber(os.date("%H",tonumber(limitSign.time)))
--     local min = tonumber(os.date("%M",tonumber(limitSign.time)))
function LimitSignControl.GetIsSignDay()
    if not ActivityControl.CheckActiveOpen(ActivityControl.activityTypeEnum.LIMITSIGN) then
        return false
    end
    if limitSign == nil then
        return true
    else
        --return not Global.CheckIsSameDay(Global.GetTimeByStr(limitSign.time),MgrNet.GetServerTime())
        if limitSign.day < #LimitSignDataList and tonumber(limitSign.time) < LimitSignControl.GetTime5Today() and Global.GetCurTime() > LimitSignControl.GetNextTime5Today(tonumber(limitSign.time)) then
            --if limitSign.day < #LimitSignDataList and tonumber(limitSign.time) < LimitSignControl.GetTime5Today() and Global.GetCurTime() > LimitSignControl.GetTime5Today() then
            return true
        else
            return false
        end
    end
end

--今天5点的时间戳
function LimitSignControl.GetTime5Today()
    local _year = tonumber(os.date("%Y",Global.GetCurTime()))
    local _month = tonumber(os.date("%m",Global.GetCurTime()))
    local _day = tonumber(os.date("%d",Global.GetCurTime()))
    local weekday = tonumber(os.date("%w",Global.GetCurTime())) --- 0-6 周日-周六
    local hour = tonumber(os.date("%H",Global.GetCurTime()))
    local min = tonumber(os.date("%M",Global.GetCurTime()))
    local sec = tonumber(os.date("%S",Global.GetCurTime()))
    local time = os.time({ year = _year, month = _month, day = _day, hour = 5, minute = 0, second = 0 })
    print(time)
    --return tonumber(os.date("%H",Global.GetCurTime())) >= 5
    return time
end


--第二天5点的时间戳
function LimitSignControl.GetNextTime5Today(_time)
    local _year = tonumber(os.date("%Y",_time))
    local _month = tonumber(os.date("%m",_time))
    local _day = tonumber(os.date("%d",_time))
    local weekday = tonumber(os.date("%w",_time)) --- 0-6 周日-周六
    local hour = tonumber(os.date("%H",_time))
    local min = tonumber(os.date("%M",_time))
    local sec = tonumber(os.date("%S",_time))

    local time = 0
    if hour < 5 then
        time = os.time({ year = _year, month = _month, day = _day, hour = 5, minute = 0, second = 0 })
    else
        time = os.time({ year = _year, month = _month, day = _day + 1, hour = 5, minute = 0, second = 0 })
    end
    --local time = os.time({ year = _year, month = _month, day = _day + 1, hour = 5, minute = 0, second = 0 })
    print(time)
    --return tonumber(os.date("%H",Global.GetCurTime())) >= 5
    return time
end

--今天是否超过5点
function LimitSignControl.IsOverTime5()
    ---当前的小时
    local curTime = Global.GetCurTime()
    local curHour = os.date("*t",curTime)
end

---今天是否已经签到
function LimitSignControl.IsSignToday()
    return Global.CheckIsSameDay()
end
---一键领取所有
 function LimitSignControl.ClientLimitSignReq(_id,_actId,callback)
     local ClientLimitSignReq  =
     {
         id = _id,
         activityId = _actId
     }
     ---序列化
     local bytes = assert(pb.encode('PBClient.ClientLimitSignReq',ClientLimitSignReq))
     ItemControl.AckError = true
     ---发送数据
     MgrNet.SendReq(MID.CLIENT_LIMIT_SIGN_REQ,bytes,0,nil,
         function(...)
             LimitSignControl.ActivityRewardSendACK(...)
         end,
         function(...)
             LimitSignControl.ActivityRewardSendNTF(...)
             if callback then
                 callback()
             end
         end
     )
 end
 ---领取活动奖励ACK
 function LimitSignControl.ActivityRewardSendACK(buffer, tag)
     local tab = assert(pb.decode('PBClient.ClientLimitSignAck',buffer))
     
     if tab.errNo~=0 then
         MgrUI.Pop(UID.PopTip_UI, { MgrLanguageData.GetErrorByKey(tab.errNo), 1 }, true)
     end
 end
---领取通行证活动奖励NTF
function LimitSignControl.ActivityRewardSendNTF(buffer, tag)
    ---解析活动奖励
    local tab = assert(pb.decode('PBClient.ClientLimitSignNtf',buffer))
    --状态
    local tSignData = LimitSignControl.GetSignDataByID(SignAllActID)
    tSignData.day = tSignData.day+1
    tSignData.ableDay = 0
    --百日签到红点
    LimitSignControl.CheckSignAllDot()
    --奖励道具
    if tab.goods then
        local goodsList = {}
        for i, v in pairs(tab.goods) do
            if v.hero ~= nil then
                Log.Error("不允许通过签到直接获取角色，请修改签到奖励配置为物品")
            end
            for _, v1 in pairs(v.goods) do
                goodsList[#goodsList + 1] = v1
            end
        end
        --将奖励推送进背包
        ItemControl.PushGroupItemData(goodsList, ItemControl.PushEnum.add)
        --弹出奖励弹窗
        if #goodsList > 0 then
            MgrUI.Pop(UID.ItemAchievePop_UI, { goodsList, function()
                SignViewModel.OpenUIAndSign()
            end }, true)
        end
    else
        MgrUI.Pop(UID.PopTip_UI, { MgrLanguageData.GetLanguageByKey("passportcontrol_tips3"), 2 }, true)
    end

    ---刷新背包缓存数据
    BagViewModel.ReloadCacheData()
end

function LimitSignControl.ReturnActivityID()
    return activityid
end
---根据活动ID获取签到数据
function LimitSignControl.GetSignDataByID(_actId)
    if PlayerControl.GetPlayerData().limitSign then
        for i,v in ipairs(PlayerControl.GetPlayerData().limitSign) do
            if v.activityId == _actId then
                return v
            end
        end
    else
        PlayerControl.GetPlayerData().limitSign = {}
    end
    local tSignData = {
        activityId = _actId,
        day = 0,    --已签到天数
        time = 0,   --上次签到时间
        ableDay = 1 --可签到天数
    }
    table.insert(PlayerControl.GetPlayerData().limitSign, tSignData)
    return tSignData
end
---初始化百日签到
function LimitSignControl.InitSignAll()
    for i, v in ipairs(OpensignineventLocalData.tab) do
        local tData = {
            id = v.id,
            actID = v.activityid,
            sort = v.day,
            reward = v.reward
        }
    print("limitActId===="..v.activityid)
        if SignAllData[v.activityid] == nil then
            SignAllData[v.activityid] = {}
            SignAllActID = v.activityid
        end
        table.insert(SignAllData[v.activityid], tData)
    end
    --百日签到红点
    LimitSignControl.CheckSignAllDot()
end
---根据活动ID获取百日签到数据
function LimitSignControl.GetSignAllByID(_actId)
    return SignAllData[_actId]
end
---百日签到红点
function LimitSignControl.CheckSignAllDot()
    local tData = LimitSignControl.GetSignDataByID(SignAllActID)
    if tData.day >= #SignAllData[SignAllActID] then
        RedDotControl.GetDotData("LimitSignAll"):SetState(false)
    else
        RedDotControl.GetDotData("LimitSignAll"):SetState(tData.ableDay==1)
    end
end
--检测百日签到是否结束
function LimitSignControl.CheckComplete()
    local tData = LimitSignControl.GetSignDataByID(SignAllActID)
    print("limit===="..SignAllActID)
    print("limit===="..#SignAllData[SignAllActID])
    return tData.day >= #SignAllData[SignAllActID]
end

function LimitSignControl.Clear()
    FundDataList = {}
    SignAllData = {}
    SignAllActID = 0
end

return LimitSignControl