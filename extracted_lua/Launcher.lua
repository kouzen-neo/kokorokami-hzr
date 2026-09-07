local g = require 'Game' --这里入口

-----注册调试工具（不要提交SVN）
if CMgrHot.Instance:IsEditor() then
    --package.cpath = package.cpath .. ';C:/Users/tingzhou/AppData/Roaming/JetBrains/Rider2021.1/plugins/EmmyLua/classes/debugger/emmy/windows/x64/?.dll'
    --local dbg = require('emmy_core')
    --dbg.tcpListen('localhost', 9971)
end

g:Start()





