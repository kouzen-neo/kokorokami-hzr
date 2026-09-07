require("LocalData/ActorLinesLocalData")
---看板娘VM
PosterGirlViewModel = {}

------------------------------角色立绘---------------------------------
PosterGirlViewModel.CurSpineObj=nil          ---立绘对象
PosterGirlViewModel.CurFrontSpineObj = nil   ---前景spine
PosterGirlViewModel.CurBgSpineObj = nil      ---背景spine

-----------------------------角色语音----------------------------------
PosterGirlViewModel.Tab_MainSceneRoleVoiceData={}  ---存储主界面角色随机语音信息表
PosterGirlViewModel.RoleVoiceWordText={} ---当前角色台词文本Obj
PosterGirlViewModel.IsVoiceEnd = true
PosterGirlViewModel.VoiceObj = nil
PosterGirlViewModel.VoiceIcon = nil
PosterGirlViewModel.isRoleVoice = true
---语音是否可以停止
PosterGirlViewModel.CanStop = true
---台词类型
PosterGirlViewModel.WordsType = {
    LvUp = 1,       --等级提升
    StarUp = 2,     --星级提升
    Awaken = 3,     --觉醒
    SkillUp = 4,    --技能提升
}
---spine类型
PosterGirlViewModel.spineType = {
    front = 1,   --前景
    role = 2,    --角色
    bottom = 3,  --后景
}

PosterGirlViewModel.ClothesType = {
    wear = 1,       --穿上
    undress = 2,    --脱下
}

---当前衣服状态
PosterGirlViewModel.CurClothes = nil

PosterGirlViewModel.VoiceCache = {}

--------------------------立绘------------------------------

--- 向一个立绘展示框中初始化一个人物立绘信息
function PosterGirlViewModel.GetRoleSpineToBox(_Root,type)
    local _RoleId = PlayerControl.GetPlayerData().HomeRole
    local _skin = HeroControl.GetSkinDataBySkinId(_RoleId)
    --判断是否启用多状态切换
    if _skin and _skin.newSwitch then
        --初始化皮肤功能需求
        SkinControl.InitSpineState(true,true,SkinControl.UIType.home,_skin.id)
        ---创建皮肤
        SkinControl.CreateRoleSpine(_Root,type)
        PosterGirlViewModel.ClearSpine()
        return
    end
    --清理旧spine
    SkinControl.ClearSpine()
    local posInfo
    if type == PosterGirlViewModel.spineType.role then  --角色spine
        --if _RoleId >= 90000 then
        --    posInfo = PosterGirlControl.PosterGirlDataByID(_RoleId).coordinate0
        --else
            posInfo = CharactercoordinatesLocalData.tab[_RoleId].coordinate0
        --end
        local _info1 = string.split(posInfo,";")
        local _info2 = string.split(_info1[1],",")
        local x = tonumber(_info2[1])
        local y = tonumber(_info2[2])
        local scale = tonumber(_info1[2])
        ---清理旧spine
        if PosterGirlViewModel.CurSpineObj then
            GameObject.Destroy(PosterGirlViewModel.CurSpineObj)
        end
        PosterGirlViewModel.CurClothes = PosterGirlViewModel.ClothesType.wear
        MgrRes.LoadWatch3DSpine(_Root,_RoleId,x,y,scale,nil,function(_ReturnObj)
            PosterGirlViewModel.CurSpineObj = _ReturnObj
            _ReturnObj.transform:GetComponent("SkeletonAnimation"):SetOrderLayer(-1,"Default")
            _ReturnObj.layer = 5
            local _CurRoleID = PlayerControl.GetPlayerData().HomeRole
            local _ActorLinesType
            --if _CurRoleID >= 90000 and _CurRoleID < 200000 then     ---看板娘
            --    _ActorLinesType = tonumber(Live2dLocalData.tab[_CurRoleID][3])
            --else
            local curRoleSkin = PlayerControl.GetPlayerData().HomeRole
            _ActorLinesType = tonumber(RoleuiskinLocalData.tab[curRoleSkin].interaction)
            --end
            local _FinalActorLineID=0
            for key, value in pairs(ActorLinesLocalData.tab) do
                if value[2] == _ActorLinesType and value[4] == 2 then
                    _FinalActorLineID=value[1]
                end
            end
            if PosterGirlViewModel.CurClothes == PosterGirlViewModel.ClothesType.undress then
                CMgrSpine.Instance:SetSpineAnimation(PosterGirlViewModel.CurSpineObj,"idle2",true)
                ---如果随机到主界面随机语音修改随机语音播放的动画
                if ActorLinesLocalData.tab[_FinalActorLineID][4] == 4 then
                    CMgrSpine.Instance:SetSpineAnimation(PosterGirlViewModel.CurSpineObj,"idle2",true)
                end
            else
                CMgrSpine.Instance:SetSpineAnimation(PosterGirlViewModel.CurSpineObj,"idle",true)
            end
            PosterGirlViewModel.InitMainSceneRoleRandVoiceData()
        end)
    elseif type == PosterGirlViewModel.spineType.bottom then  --背景spine
        if _skin.backgroundpic ~= "0" then
            ---清理旧背景spine
            if PosterGirlViewModel.CurBgSpineObj then
                GameObject.Destroy(PosterGirlViewModel.CurBgSpineObj)
            end
            --MgrRes.LoadSkinBG(_skin.backgroundpic,_Root,0,-1000)
            if string.find(_skin.backgroundpic,'Watch_3D_bg') then
                local coordinate = string.split(CharactercoordinatesLocalData.tab[_RoleId].coordinate8,";")
                local x = tonumber(string.split(coordinate[1],",")[1])
                local y = tonumber(string.split(coordinate[1],",")[2])
                local scale = coordinate[3] == '0' and tonumber(coordinate[2]) or -tonumber(coordinate[2])
                MgrRes.LoadCgSpine(_Root, _RoleId,_skin.backgroundpic,x,y,scale,_skin.morning,function(_ReturnObj)
                    PosterGirlViewModel.CurBgSpineObj = _ReturnObj
                    _ReturnObj.transform:GetComponent("SkeletonAnimation"):SetOrderLayer(-2,"Default")
                    _ReturnObj.layer = 5
                end,true)
            else
                local coordinate = string.split(CharactercoordinatesLocalData.tab[_RoleId].coordinate8,";")
                local x = tonumber(string.split(coordinate[1],",")[1])
                local y = tonumber(string.split(coordinate[1],",")[2])
                local scale = coordinate[3] == '0' and tonumber(coordinate[2]) or -tonumber(coordinate[2])
                MgrRes.LoadCgSpine(_Root, _RoleId,_skin.backgroundpic,x,y,scale,nil,function(_ReturnObj)
                    PosterGirlViewModel.CurBgSpineObj = _ReturnObj
                end,true)
            end
        else
            local posInfo = MainuiskinLocalData.tab[tonumber(SteamLocalData.tab[113040][2])].bgcoordinate
            local _info1 = string.split(posInfo,";")
            local _info2 = string.split(_info1[1],",")
            local path = MainuiskinLocalData.tab[tonumber(SteamLocalData.tab[113040][2])].backgroundpic
            local x = tonumber(_info2[1])
            local y = tonumber(_info2[2])
            local scale = tonumber(_info1[2])
            ---清理旧背景spine
            if PosterGirlViewModel.CurBgSpineObj then
                GameObject.Destroy(PosterGirlViewModel.CurBgSpineObj)
            end
            MgrRes.LoadCgSpine(_Root, _RoleId,path,x,y,scale,MainuiskinLocalData.tab[tonumber(SteamLocalData.tab[113040][2])].morning,function(_ReturnObj)
                PosterGirlViewModel.CurBgSpineObj = _ReturnObj
            end,true)
        end
    elseif type == PosterGirlViewModel.spineType.front then   --前景spine
        if _skin.foregroundpic ~= "0" then
            ---清理旧前景spine
            if PosterGirlViewModel.CurFrontSpineObj then
                GameObject.Destroy(PosterGirlViewModel.CurFrontSpineObj)
            end
            local img = _Root.transform:GetComponent("Image")
            img.enabled = false
            local coordinate = string.split(CharactercoordinatesLocalData.tab[_RoleId].coordinate9,";")
            local x = tonumber(string.split(coordinate[1],",")[1])
            local y = tonumber(string.split(coordinate[1],",")[2])
            local scale = coordinate[3] == '0' and tonumber(coordinate[2]) or -tonumber(coordinate[2])
            MgrRes.LoadSkinFrontBG(_skin.type,img,_skin.foregroundpic,_Root,x,y,scale,nil,function(_ReturnObj)
                _ReturnObj.transform:GetComponent("SkeletonAnimation"):SetOrderLayer(0,"Default")
                PosterGirlViewModel.CurFrontSpineObj = _ReturnObj
            end)
        else
            local posInfo = MainuiskinLocalData.tab[tonumber(SteamLocalData.tab[113040][2])].fgcoordinate
            local _info1 = string.split(posInfo,";")
            local _info2 = string.split(_info1[1],",")
            local path = MainuiskinLocalData.tab[tonumber(SteamLocalData.tab[113040][2])].foregroundpic
            local x = tonumber(_info2[1])
            local y = tonumber(_info2[2])
            local scale = tonumber(_info1[2])
            local Img = _Root.transform:GetComponent("Image")
            Img.enabled = false
            ---清理旧前景spine
            if PosterGirlViewModel.CurFrontSpineObj then
                GameObject.Destroy(PosterGirlViewModel.CurFrontSpineObj)
            end
            ---如果是图片
            if MainuiskinLocalData.tab[tonumber(SteamLocalData.tab[113040][2])].type == 0 then
                if path ~= "0" and _skin.backgroundpic == "0" then
                    Img.enabled = true
                    MgrRes.LoadSprite(Img,path)
                else
                    Img.enabled = false
                end
            else
                Img.enabled = false
                if path ~= "0" then
                    MgrRes.LoadCgSpine(_Root, _RoleId,path,x,y,scale,MainuiskinLocalData.tab[tonumber(SteamLocalData.tab[113040][2])].morning,function(_ReturnObj)
                        PosterGirlViewModel.CurFrontSpineObj = _ReturnObj
                    end,true)
                end
            end
        end
    end
end

function PosterGirlViewModel.CreatSpecialSpineToBox(root,type)
    local roleID = PlayerControl.GetPlayerData().curRoleID
    local _skin = HeroControl.GetSkinDataByRoleID(roleID)
    --local key = PlayerControl.GetPlayerData().UID.."LobbySpine"
    -----设置状态
    --UnityEngine.PlayerPrefs.SetInt(key,1)  --value为0是默认spine,为1是特殊spine
    if type == PosterGirlViewModel.spineType.role then
        local posInfo = CharactercoordinatesLocalData.tab[_skin.id].coordinate7
        local _info1 = string.split(posInfo,";")
        local _info2 = string.split(_info1[1],",")
        local x = tonumber(_info2[1])
        local y = tonumber(_info2[2])
        local scale = tonumber(_info1[2])
        ---清理旧spine
        if PosterGirlViewModel.CurSpineObj then
            GameObject.Destroy(PosterGirlViewModel.CurSpineObj)
        end
        MgrRes.LoadCgSpine(root, _skin.id,"ABOriginal/Role/".._skin.id.."/BgSpine/Watch_3D_role.prefab",x,y,scale,nil,function(_ReturnObj)
            PosterGirlViewModel.CurSpineObj = _ReturnObj
            PosterGirlViewModel.InitMainSceneRoleRandVoiceData()
        end)
    elseif type == PosterGirlViewModel.spineType.bottom then
        local posInfo = CharactercoordinatesLocalData.tab[_skin.id].coordinate8
        local _info1 = string.split(posInfo,";")
        local _info2 = string.split(_info1[1],",")
        local x = tonumber(_info2[1])
        local y = tonumber(_info2[2])
        local scale = tonumber(_info1[2])
        ---清理旧背景spine
        if PosterGirlViewModel.CurBgSpineObj then
            GameObject.Destroy(PosterGirlViewModel.CurBgSpineObj)
        end
        MgrRes.LoadCgSpine(root, _skin.id,"ABOriginal/Role/".._skin.id.."/BgSpine/Watch_3D_bg.prefab",x,y,scale,nil,function(_ReturnObj)
            PosterGirlViewModel.CurBgSpineObj = _ReturnObj
        end)
    elseif type == PosterGirlViewModel.spineType.front then
        local posInfo = CharactercoordinatesLocalData.tab[_skin.id].coordinate9
        local _info1 = string.split(posInfo,";")
        local _info2 = string.split(_info1[1],",")
        local x = tonumber(_info2[1])
        local y = tonumber(_info2[2])
        local scale = tonumber(_info1[2])
        local Img = root.transform:GetComponent("Image")
        ---清理旧前景spine
        if PosterGirlViewModel.CurFrontSpineObj then
            GameObject.Destroy(PosterGirlViewModel.CurFrontSpineObj)
        end
        Img.enabled = false
        MgrRes.LoadCgSpine(root, _skin.id,"ABOriginal/Role/".._skin.id.."/BgSpine/Watch_3D_front.prefab",x,y,scale,nil,function(_ReturnObj)
            PosterGirlViewModel.CurFrontSpineObj = _ReturnObj
        end)
    end
end

function PosterGirlViewModel.ClearSpine()
    if PosterGirlViewModel.CurSpineObj then
        GameObject.Destroy(PosterGirlViewModel.CurSpineObj)
        PosterGirlViewModel.CurSpineObj = nil
    end
    if PosterGirlViewModel.CurBgSpineObj then
        GameObject.Destroy(PosterGirlViewModel.CurBgSpineObj)
        PosterGirlViewModel.CurBgSpineObj = nil
    end
    if PosterGirlViewModel.CurFrontSpineObj then
        GameObject.Destroy(PosterGirlViewModel.CurFrontSpineObj)
        PosterGirlViewModel.CurFrontSpineObj = nil
    end
end

--- 根据当前展示看板娘ID随机播放语音
function PosterGirlViewModel.InitMainSceneRoleRandVoiceData(isSpecial)
    PosterGirlViewModel.Tab_MainSceneRoleVoiceData={}
    --local _CurRoleID = PlayerControl.GetPlayerData().HomeRole
    local _ActorLinesType
    --if _CurRoleID >= 90000 and _CurRoleID < 200000 then     ---看板娘
    --    _ActorLinesType = tonumber(Live2dLocalData.tab[_CurRoleID][3])
    --else
        --_ActorLinesType = tonumber(RoleattributeLocalData.tab[_CurRoleID][3])  ---当前台词组别
        local curRoleSkin = PlayerControl.GetPlayerData().HomeRole
        _ActorLinesType = tonumber(RoleuiskinLocalData.tab[curRoleSkin].interaction)
    --end
    PosterGirlViewModel._TotalWeight = 0 --当前随机总权重
    for id, value in pairs(ActorLinesLocalData.tab) do
        ---特殊spine
        if isSpecial then
            if PosterGirlViewModel.CurClothes == PosterGirlViewModel.ClothesType.wear then
                ---选择穿衣服时的待机语音
                if value[2] == _ActorLinesType and value[3] == 91 then
                    PosterGirlViewModel._TotalWeight = PosterGirlViewModel._TotalWeight+10
                    table.insert(PosterGirlViewModel.Tab_MainSceneRoleVoiceData,{id,PosterGirlViewModel._TotalWeight})
                end
            else
                ---选择脱衣服时的待机语音
                if value[2] == _ActorLinesType and value[3] == 94 then
                    PosterGirlViewModel._TotalWeight = PosterGirlViewModel._TotalWeight+10
                    table.insert(PosterGirlViewModel.Tab_MainSceneRoleVoiceData,{id,PosterGirlViewModel._TotalWeight})
                end
            end
        else
            ---普通spine
            if value[2] == _ActorLinesType and value[4] == 4 then
                -- 匹配到对应的角色台词组别并且交互类型为 4
                PosterGirlViewModel._TotalWeight = PosterGirlViewModel._TotalWeight+10
                table.insert(PosterGirlViewModel.Tab_MainSceneRoleVoiceData,{id,PosterGirlViewModel._TotalWeight})
            end
        end

    end
end

--------------------------语音------------------------------
--- 设置台词Obj
function PosterGirlViewModel.SetRoleVoiceWordText(_lineObj,imgObj,iconObj)
    PosterGirlViewModel.RoleVoiceWordText = _lineObj
    PosterGirlViewModel.VoiceObj = imgObj
    PosterGirlViewModel.VoiceIcon = iconObj
end

---根据id播放语音
function PosterGirlViewModel.PlayRoleVoice(type)
    ---主动通过ID播放的语音让它播放完
    PosterGirlViewModel.CanStop = false
    --local _CurRoleID = PlayerControl.GetPlayerData().HomeRole
    local _ActorLinesType
    --if _CurRoleID >= 90000 and _CurRoleID < 200000 then     ---看板娘
    --    _ActorLinesType = tonumber(Live2dLocalData.tab[_CurRoleID][3])
    --else
        --_ActorLinesType = tonumber(RoleattributeLocalData.tab[_CurRoleID][3])  ---当前台词组别
        local curRoleSkin = PlayerControl.GetPlayerData().HomeRole
        _ActorLinesType = tonumber(RoleuiskinLocalData.tab[curRoleSkin].interaction)
    --end
    local _FinalActorLineID=0
    for key, value in pairs(ActorLinesLocalData.tab) do
        if value[2] == _ActorLinesType and value[4] == type then
            _FinalActorLineID=value[1]
        end
    end
    print(_FinalActorLineID.."播放的声音类型"..type)
    PosterGirlViewModel.PlayTargetRoleAniVoice(_FinalActorLineID)
end

---播放主界面角色进入语音
function PosterGirlViewModel.PlayMainSceneRoleVoice()
    --local _CurRoleID = PlayerControl.GetPlayerData().HomeRole
    local _ActorLinesType
    --if _CurRoleID >= 90000 and _CurRoleID < 200000 then     ---看板娘
    --    _ActorLinesType = tonumber(Live2dLocalData.tab[_CurRoleID][3])
    --else
        --_ActorLinesType = tonumber(RoleattributeLocalData.tab[_CurRoleID][3])  ---当前台词组别
        local curRoleSkin = PlayerControl.GetPlayerData().HomeRole
        _ActorLinesType = tonumber(RoleuiskinLocalData.tab[curRoleSkin].interaction)
    --end
    local _FinalActorLineID = 0
    for key, value in pairs(ActorLinesLocalData.tab) do
        if value[2] == _ActorLinesType and value[4] == 26 then
            _FinalActorLineID=value[1]
        end
    end
    PosterGirlViewModel.PlayTargetRoleAniVoice(_FinalActorLineID)
end

--- 根据权重表随机出一个下标
function PosterGirlViewModel.GetRandIndexByHashTab(_MaxWeight,_WeightHashTab)
    if _MaxWeight == 0 then
        return
    end
    local _randNum=math.random(_MaxWeight)
    print("随机权重".._randNum)
    local _FinalVoiceLineId="" --最终台词下标
    -- print("本次随机数为".._randNum.."总权重为".._MaxWeight)
    local _IsFound=false --是否找到比第一个元素权重大的权重下标(没有找到则默认返回第一个元素的下标)
    local _CurMaxWeightInSearch=0 --当前本次遍历中小于随机数的最大的权重
    for key, value in pairs(_WeightHashTab) do
        --判断当前随机数是否大于当前阶段上限阈值以及是否小于权重表最大阈值，否则不更新
        if value[2] < _randNum and value[2] <= _MaxWeight then

            -- 符合条件迭代更新
            if value[2] >= _CurMaxWeightInSearch then
                -- 判断当前比较的权重是否大于已经对比过的权重各种最大权重值，小于则不更新
                _FinalVoiceLineId=_WeightHashTab[key+1][1]   --高于当前阶段的最大阈值，返回下一阶段的台词ID
                _IsFound=true
                _CurMaxWeightInSearch=value[2]
            end
        end
    end
    if _IsFound == false then
        -- 设置为默认最低等级权重台词
        _FinalVoiceLineId=_WeightHashTab[1][1]
    end
    return _FinalVoiceLineId
end

---根据对应的ID播放对应的角色动画以及语音等 改为等待当前动画播放完毕自动播放 LTODO
function PosterGirlViewModel.PlayTargetRoleAniVoice(_ActorLineId)
    print("PlayTargetRoleAniVoice _ActorLineId:".._ActorLineId)
    if not NoviceControl.GroupsIsTrigger(tonumber(SteamLocalData.tab[120001][2])) or NoviceViewModel.Noviceing then
        PosterGirlViewModel.VoiceObj:SetActive(false)
        return
    end
    MgrTimer.Cancel("RoleVoice")
    MgrTimer.Cancel("RangeVoice")
    if _ActorLineId == nil then
        return
    end
    local _AniName=ActorLinesLocalData.tab[_ActorLineId][6] --动画文件名
    local _ActorLineWord=ActorLinesLocalData.tab[_ActorLineId][7]
    local _AudioName=ActorLinesLocalData.tab[_ActorLineId][13]
    local _AudioType = ActorLinesLocalData.tab[_ActorLineId][3]
    local _BackAniName = "idle"

    --UnityEngine.Debug.LogError("当前状态: ".. ((PosterGirlViewModel.CurClothes == PosterGirlViewModel.ClothesType.undress) and "脱衣状态" or "穿衣状态"))
    if _AudioType == 93 then  --脱衣语音
        PosterGirlViewModel.CurClothes = PosterGirlViewModel.ClothesType.undress
    elseif _AudioType == 96 then  --穿衣语音
        PosterGirlViewModel.CurClothes = PosterGirlViewModel.ClothesType.wear
    end
    if PosterGirlViewModel.CurClothes == PosterGirlViewModel.ClothesType.undress then
        _BackAniName = "idle2"  --脱衣状态
        ---如果随机到主界面随机语音修改随机语音播放的动画
        if ActorLinesLocalData.tab[_ActorLineId][4] == 4 then
            _AniName = "idle2"
        end
    else
        _BackAniName = "idle"   --穿衣状态
    end
    --随机动作，排除待机动作
    if _AniName == "idle" or _AniName == "idle2" then
        _AniName = "0"
    end
    
    if PosterGirlViewModel.CurSpineObj ~= nil and _AniName ~= "0" then
        --UnityEngine.Debug.LogError("状态转变为 ".. ((PosterGirlViewModel.CurClothes == PosterGirlViewModel.ClothesType.undress) and "脱衣状态" or "穿衣状态") .." 要播放的动画: ".._AniName.." 后面衔接的动画: ".. _BackAniName)
        CMgrSpine.Instance:SetSpineAnimation(PosterGirlViewModel.CurSpineObj,_AniName,false,nil,_BackAniName)
    end
    --UnityEngine.DebugEx.LogError(_AniName.." ".._BackAniName.." ".._AudioType)
    if  PosterGirlViewModel.RoleVoiceWordText.gameObject ~= nil then
        PosterGirlViewModel.RoleVoiceWordText.text=_ActorLineWord
    end

    --强制引导结束关闭引导语音
    if not NoviceViewModel.Noviceing then
        MgrSound.Stop(5)
    end
    MgrSound.PlayRole(_AudioName,nil,nil,false,0,0,tostring(PlayerControl.GetPlayerData().HomeRole))
    
    if PosterGirlViewModel.isRoleVoice == false then
        return
    end

    PosterGirlViewModel.VoiceObj:SetActive(true)
    PosterGirlViewModel.ListenVoice()
end

---根据当前好感度等级权重随机出本次的好感度交互台词ID
function PosterGirlViewModel.GetCurFavorWords(idx)
    local _CurRoleID = HeroControl.GetRoleDataByID(PlayerControl.GetPlayerData().HomeRole) and PlayerControl.GetPlayerData().HomeRole or HeroControl.GetSkinDataBySkinId(PlayerControl.GetPlayerData().HomeRole).roleId
    --判断是否启用多状态切换
    if HeroControl.GetSkinDataBySkinId(PlayerControl.GetPlayerData().HomeRole).newSwitch then
        SkinControl.OnClickRoleBack(idx)
        return
    end
    ---检测当前spine是否是idle状态
    if CMgrSpine.Instance:CheckCurAniIsIdle(PosterGirlViewModel.CurSpineObj, PosterGirlViewModel.CurClothes == PosterGirlViewModel.ClothesType.undress) == false then
        return
    end
    local _CurRoleFavor=HeroControl.GetRoleDataByID(_CurRoleID).favor --默认100好感度
    local _ActorLinesType   --台词组别
    --if RoleattributeLocalData.tab[_CurRoleID] ~= nil then
        --_ActorLinesType=tonumber(RoleattributeLocalData.tab[_CurRoleID][3])  --当前台词组别
        local curRoleSkin = PlayerControl.GetPlayerData().HomeRole
        _ActorLinesType = tonumber(RoleuiskinLocalData.tab[curRoleSkin].interaction)
    --else
    --    _ActorLinesType=tonumber(Live2dLocalData.tab[_CurRoleID][3])  --当前看板娘台词组别
    --end
    if idx then    ---皮肤做多个点击区域
        local _CurTotalSumWeight=0
        local _tempActorLineIdTab={}  --临时表存储对应的文本台词ID和对应权重
        for key, value in pairs(ActorLinesLocalData.tab) do
            if value[2] == _ActorLinesType and value[4] == 5 then   --_ActorLinesType为台词组(==皮肤ID),value[4]==5 为触摸交互
                local str = string.split(value[5],"_")
                if str[1] == "15" and idx == tonumber(str[2]) then  --15为点击区域触发动作和语音
                    ---算权重
                    local _TempVarTab= string.split(value[5],"_")
                    local _ReturnVar = TableToObject.GetTargetWeight2(_TempVarTab,_CurRoleFavor)
                    if _ReturnVar ~= false then
                        _CurTotalSumWeight=_CurTotalSumWeight+(tonumber(_ReturnVar)*1000)
                        table.insert(_tempActorLineIdTab,{value[1],_CurTotalSumWeight})
                    end
                elseif str[1] == "14" and idx == tonumber(str[2]) then  ---14_2_idle_0_0.8
                    ---匹配到对应的角色台词组别
                    if value[2] == _ActorLinesType then
                        local _TempVarTab = str
                        local _ReturnVar = TableToObject.GetTargetWeight2(_TempVarTab,0)
                        if _ReturnVar ~= false then
                            ---当前看板娘穿着衣服
                            if PosterGirlViewModel.CurClothes == PosterGirlViewModel.ClothesType.wear then
                                ---穿着衣服时点击角色只会播放脱衣语音或穿衣触摸
                                if value[3] == 92 or value[3] == 93 then
                                    _CurTotalSumWeight=_CurTotalSumWeight+(tonumber(_ReturnVar)*1000)
                                    table.insert(_tempActorLineIdTab,{value[1],_CurTotalSumWeight})
                                end
                            else
                                ---脱着衣服时点击角色只会播放穿衣语音或脱衣触摸
                                if value[3] == 95 or value[3] == 96 then
                                    _CurTotalSumWeight=_CurTotalSumWeight+(tonumber(_ReturnVar)*1000)
                                    table.insert(_tempActorLineIdTab,{value[1],_CurTotalSumWeight})
                                end
                            end
                        end
                    end
                end
            end
        end
        local _FinalVoiceLineId = PosterGirlViewModel.GetRandIndexByHashTab(_CurTotalSumWeight,_tempActorLineIdTab)
        PosterGirlViewModel.PlayTargetRoleAniVoice(_FinalVoiceLineId)
        ---后面要加特效
    else
        local _tempActorLineIdTab={}  --临时表存储对应的文本台词ID和对应权重
        local _CurTotalSumWeight=0 --当前总权重值
        for key, value in pairs(ActorLinesLocalData.tab) do
            ---当前是默认看板娘
            if UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."LobbySpine") == 0 and tonumber(string.split(value[5],"_")[1]) ~= 14 then
                ---匹配到对应的角色台词组别
                if value[2] == _ActorLinesType and value[4] == 5 and tonumber(string.split(value[5],"_")[1]) == 1 then
                    ---切割对应的触发条件得到条件表
                    local _TempVarTab= string.split(value[5],"_")
                    local _ReturnVar = TableToObject.GetTargetWeight(_TempVarTab,_CurRoleFavor)
                    if _ReturnVar ~= false then
                        ---插入 台词ID 达标的权重值*1000+表中已存的权重值
                        ---按顺序插入累加的权重值，通过分段记录的权重值来判断本次随机出来的值属于哪个区间
                        ---Etc tab[1]切割出的权值为0.8  tab[2]切割出的权值为1.5 tab[3]切割出的权值为2.8
                        ---    对应tab[1]存储的权值字段为800 tab[2]为800+1500 tab[3]为800+1500+2800
                        ---    随机一个整数在(1,max) max本轮为800+1500+2800
                        ---    遍历表中判断迭代更新大于这个随机数的字段的下标
                        ---    假设本轮随机数为1300 则tab[1]符合 tab[2]符合 最中迭代更新随机数下标为tab[2]
                        ---------------------------------------------------------------------
                        if value[3] == 91 or value[3] == 94 then
                            if PosterGirlViewModel.CurClothes == PosterGirlViewModel.ClothesType.wear then
                                if value[3] == 91 then
                                    _CurTotalSumWeight=_CurTotalSumWeight+(tonumber(_ReturnVar)*1000)
                                    table.insert(_tempActorLineIdTab,{value[1],_CurTotalSumWeight})
                                end
                            else
                                if value[3] == 94 then
                                    _CurTotalSumWeight=_CurTotalSumWeight+(tonumber(_ReturnVar)*1000)
                                    table.insert(_tempActorLineIdTab,{value[1],_CurTotalSumWeight})
                                end
                            end
                        else
                            _CurTotalSumWeight=_CurTotalSumWeight+(tonumber(_ReturnVar)*1000)
                            table.insert(_tempActorLineIdTab,{value[1],_CurTotalSumWeight})
                        end
                    end
                end
            elseif UnityEngine.PlayerPrefs.GetInt(PlayerControl.GetPlayerData().UID.."LobbySpine") == 0 and tonumber(string.split(value[5],"_")[1]) == 14 then
                ---匹配到对应的角色台词组别
                if value[2] == _ActorLinesType then
                    local _TempVarTab= string.split(value[5],"_")
                    local _ReturnVar = TableToObject.GetTargetWeight(_TempVarTab,0)
                    if _ReturnVar ~= false then
                        ---当前看板娘穿着衣服
                        if PosterGirlViewModel.CurClothes == PosterGirlViewModel.ClothesType.wear then
                            ---穿着衣服时点击角色只会播放脱衣语音或穿衣触摸
                            if value[3] == 92 or value[3] == 93 then
                                _CurTotalSumWeight=_CurTotalSumWeight+(tonumber(_ReturnVar)*1000)
                                table.insert(_tempActorLineIdTab,{value[1],_CurTotalSumWeight})
                            end
                        else
                            ---脱着衣服时点击角色只会播放穿衣语音或脱衣触摸
                            if value[3] == 95 or value[3] == 96 then
                                _CurTotalSumWeight=_CurTotalSumWeight+(tonumber(_ReturnVar)*1000)
                                table.insert(_tempActorLineIdTab,{value[1],_CurTotalSumWeight})
                            end
                        end
                    end
                end
            end
        end
        local _FinalVoiceLineId = PosterGirlViewModel.GetRandIndexByHashTab(_CurTotalSumWeight,_tempActorLineIdTab)
        PosterGirlViewModel.PlayTargetRoleAniVoice(_FinalVoiceLineId)
    end
end

--- 监听语音是否结束
function PosterGirlViewModel.ListenVoice()
    MgrTimer.AddRepeat("RoleVoice",0.2,function()
        if MgrSound.CheckRoleStatus(tostring(PlayerControl.GetPlayerData().HomeRole)) then
            PosterGirlViewModel.VoiceObj:SetActive(false)
            PosterGirlViewModel.RangeRoleVoice()
            MgrTimer.Cancel("RoleVoice")
        end
    end,-1,nil)
end

function PosterGirlViewModel.GetPlayId(int_roleid , int_type)
    for id, value in pairs(ActorLinesLocalData.tab) do
        -- statements
        if value[2] == int_roleid and value[4] == int_type then
            return value[1]
        end
    end
end

---随机播放语音/60秒一次
function PosterGirlViewModel.RangeRoleVoice()
    MgrTimer.AddRepeat("RangeVoice",40,function()
        if PosterGirlViewModel.CanStop then
            return
        end
        --先判断时间,如果时间为准点,播放时间,如果电量为准点,播放电量语音
        if  PlayerControl.GetPlayerData().curRoleID == 90000 then
            local timefloat=   Tools.GetTime_float()
            -- if timefloat- HomeViewModel.LastBatteryTime>0.08 then
            --     local Battery= MgrSdk.GetBattery()
            --     if Battery<11 then
            --         PosterGirlViewModel.PlayTargetRoleAniVoice(PosterGirlViewModel.GetPlayId(PlayerControl.GetPlayerData().curRoleID , 57))
            --         MgrTimer.Cancel("RangeVoice")
            --         return
            --     elseif Battery<31 then
            --         PosterGirlViewModel.PlayTargetRoleAniVoice(PosterGirlViewModel.GetPlayId(PlayerControl.GetPlayerData().curRoleID , 56))
            --         MgrTimer.Cancel("RangeVoice")
            --         return
            --     elseif Battery<51 then
            --         PosterGirlViewModel.PlayTargetRoleAniVoice(PosterGirlViewModel.GetPlayId(PlayerControl.GetPlayerData().curRoleID , 55))
            --         MgrTimer.Cancel("RangeVoice")
            --         return
            --     end
            -- end
            HomeViewModel.LastBatteryTime = timefloat
            print(timefloat) --0.02误差内都可以播放准时语音
            if  timefloat >8.98 and timefloat<9.02 then
                PosterGirlViewModel.PlayTargetRoleAniVoice(PosterGirlViewModel.GetPlayId(PlayerControl.GetPlayerData().curRoleID , 58))
                MgrTimer.Cancel("RangeVoice")
                return
            elseif timefloat >11.98 and timefloat<12.02 then
                PosterGirlViewModel.PlayTargetRoleAniVoice(PosterGirlViewModel.GetPlayId(PlayerControl.GetPlayerData().curRoleID , 59))
                MgrTimer.Cancel("RangeVoice")
                return
            elseif timefloat >14.98 and timefloat<15.02 then
                PosterGirlViewModel.PlayTargetRoleAniVoice(PosterGirlViewModel.GetPlayId(PlayerControl.GetPlayerData().curRoleID , 60))
                MgrTimer.Cancel("RangeVoice")
                return
            elseif timefloat >17.98 and timefloat<18.02 then
                PosterGirlViewModel.PlayTargetRoleAniVoice(PosterGirlViewModel.GetPlayId(PlayerControl.GetPlayerData().curRoleID , 61))
                MgrTimer.Cancel("RangeVoice")
                return
            elseif timefloat >21.98 and timefloat<22.02 then
                PosterGirlViewModel.PlayTargetRoleAniVoice(PosterGirlViewModel.GetPlayId(PlayerControl.GetPlayerData().curRoleID , 62))
                MgrTimer.Cancel("RangeVoice")
                return
            elseif timefloat >23.98 and timefloat<0.02 then
                PosterGirlViewModel.PlayTargetRoleAniVoice(PosterGirlViewModel.GetPlayId(PlayerControl.GetPlayerData().curRoleID , 63))
                MgrTimer.Cancel("RangeVoice")
                return
            end
        end
        local _RandId = PosterGirlViewModel.GetRandIndexByHashTab(PosterGirlViewModel._TotalWeight,PosterGirlViewModel.Tab_MainSceneRoleVoiceData)
        print("播放了闲置随机语音".._RandId)
        PosterGirlViewModel.PlayTargetRoleAniVoice(_RandId)
        MgrTimer.Cancel("RangeVoice")
    end,-1,nil)
end

function PosterGirlViewModel.ResetSingleVoiceAudio()
    ---如果可以停止语音
    if PosterGirlViewModel.CanStop then
        MgrSound.Stop(3,tostring(PlayerControl.GetPlayerData().HomeRole),false)
    else
        ---如果不能停止语音就重置条件
        PosterGirlViewModel.CanStop = true
    end

    MgrTimer.Cancel("RoleVoice")
    MgrTimer.Cancel("RangeVoice")
end

function PosterGirlViewModel.GetRoleWords(roleId,type)
    local ActorLinesType = tonumber(RoleuiskinLocalData.tab[roleId].interaction)  --当前台词组别
    local _type = nil
    if type == PosterGirlViewModel.WordsType.LvUp then --升级台词
        _type = 6
    elseif type == PosterGirlViewModel.WordsType.StarUp then  --升星台词
        _type = 7
    elseif type == PosterGirlViewModel.WordsType.Awaken then  --觉醒台词
        _type = 8
    elseif type == PosterGirlViewModel.WordsType.SkillUp then  --技能升级台词
        _type = 9
    end
    if _type == nil then
        _type = 6
    end
    for key, value in pairs(ActorLinesLocalData.tab) do
        if value[2] == ActorLinesType and value[4] == _type then
            return value[1]
        end
    end
    return nil
end

function PosterGirlViewModel.Clear()
    PosterGirlViewModel.CurSpineObj=nil
    PosterGirlViewModel.Tab_MainSceneRoleVoiceData={}
    PosterGirlViewModel.RoleVoiceWordText={}
    PosterGirlViewModel.IsVoiceEnd = true
    PosterGirlViewModel.VoiceObj = nil
    PosterGirlViewModel.VoiceIcon = nil
    PosterGirlViewModel.CanStop = true
    PosterGirlViewModel.CurBgSpineObj = nil
    PosterGirlViewModel.CurFrontSpineObj = nil
    PosterGirlViewModel.CurClothes = nil
    PosterGirlViewModel.isRoleVoice = true
end

function PosterGirlViewModel.CacheVoiceData()
    print("PosterGirlViewModel.CacheVoiceData")
    PosterGirlViewModel.VoiceCache = {}
    PosterGirlViewModel.ActorLine = {}
    for key, value in pairs(ActorLinesLocalData.tab) do
        local roleID = value[2]
        local type = value[4]
        if PosterGirlViewModel.VoiceCache[roleID] == nil then
            PosterGirlViewModel.VoiceCache[roleID] = {}
        end
        if PosterGirlViewModel.VoiceCache[roleID][type] == nil then
            PosterGirlViewModel.VoiceCache[roleID][type] = {}
        end
        table.insert(PosterGirlViewModel.VoiceCache[roleID][type], value)

        if PosterGirlViewModel.ActorLine[roleID] == nil then
            PosterGirlViewModel.ActorLine[roleID] = {}
        end
        table.insert(PosterGirlViewModel.ActorLine[roleID], value)
    end
end

function PosterGirlViewModel.CacheVoiceData()
    print("PosterGirlViewModel.CacheVoiceData")
    PosterGirlViewModel.VoiceCache = {}
    PosterGirlViewModel.ActorLine = {}
    for key, value in pairs(ActorLinesLocalData.tab) do
        local roleID = value[2]
        local type = value[4]
        if PosterGirlViewModel.VoiceCache[roleID] == nil then
            PosterGirlViewModel.VoiceCache[roleID] = {}
        end
        if PosterGirlViewModel.VoiceCache[roleID][type] == nil then
            PosterGirlViewModel.VoiceCache[roleID][type] = {}
        end
        table.insert(PosterGirlViewModel.VoiceCache[roleID][type], value)

        if PosterGirlViewModel.ActorLine[roleID] == nil then
            PosterGirlViewModel.ActorLine[roleID] = {}
        end
        table.insert(PosterGirlViewModel.ActorLine[roleID], value)
    end
end

return PosterGirlViewModel