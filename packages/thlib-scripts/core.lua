---=====================================
---core
---所有基础的东西都会在这里定义
---=====================================

---@class lstg @内建函数库
lstg = lstg or {}

--Lua标准库行为变更（支持__ipairs与__pairs元方法）
local old_ipairs, old_pairs = ipairs, pairs

---
--- 返回三个值（迭代函数、表 `t` 以及 0 ）， 如此，以下代码
---```
--- for i,v in ipairs(t) do _body_ end
---```
--- 将迭代键值对(`1,t[1]`) ，(`2,t[2]`)， … ，直到第一个空值。
---@generic V
---@param t table<number, V>|V[]
---@return fun(tbl: table<number, V>):number, V
function ipairs(t, ...)
    local mt = getmetatable(t)
    if mt and mt.__ipairs then
        local ret = { mt.__ipairs(t, ...) }
        return ret[1], ret[2], ret[3]
    else
        return old_ipairs(t)
    end
end

---
--- 如果 `t` 有元方法 `__pairs`， 以 `t` 为参数调用它，并返回其返回的前三个值。
---
--- 否则，返回三个值：`next` 函数， 表 `t`，以及 **nil**。 因此以下代码
---```
--- for k,v in pairs(t) do _body_ end
---```
--- 能迭代表 `t` 中的所有键值对。
---
--- 参见函数 `next` 中关于迭代过程中修改表的风险。
---@generic K, V
---@param t table<K, V>|V[]
---@return fun(tbl: table<K, V>):K, V
function pairs(t, ...)
    local mt = getmetatable(t)
    if mt and mt.__pairs then
        local ret = { mt.__pairs(t, ...) }
        return ret[1], ret[2], ret[3]
    else
        return old_pairs(t)
    end
end

----------------------------------------
---各个模块

lstg.DoFile("gconfig.lua")--全局配置信息
lstg.DoFile("lib/Llog.lua")--简单的log系统
lstg.DoFile("lib/Lglobal.lua")--用户全局变量
lstg.DoFile("lib/Lmath.lua")--数学常量、数学函数、随机数系统
lstg.DoFile("plus/plus.lua")--CHU神的plus库，replay系统、plusClass、NativeAPI
lstg.DoFile("lib/Lobject.lua")--Luastg的Class、object
lstg.DoFile("lib/Lresources.lua")--资源的加载函数、资源枚举和判断
lstg.DoFile("lib/Lscreen.lua")--world、3d、viewmode的参数设置
lstg.DoFile("lib/Linput.lua")--按键状态更新
lstg.DoFile("lib/Ltask.lua")--task
lstg.DoFile("lib/Lstage.lua")--stage关卡系统
lstg.DoFile("lib/Ltext.lua")--文字渲染
lstg.DoFile("lib/Lscoredata.lua")--玩家存档
lstg.DoFile("lib/Lplugin.lua")--用户插件
require("lib.debug.AllView")
lstg.DoFile("ColliCheck.lua")--碰撞箱显示，由plugin搬运至pacakages

---debug功能控制开关
lstg.DoFile("lib/debug/_debug.lua")
if not _debug._debug then _debug = {} end

---加载在AiC模块前的外来模块(来自群文件)
lstg.DoFile("extra_lib/Hana_AI_v_1.lua")--HanaAI，用于LSC中自机AI
lstg.DoFile("extra_lib/RenderTargetExtension.lua")--RT扩展,用于简化RenderTarget渲染

---AiC模块
lstg.DoFile("AiC/AiC.lua")--AiC扩展函数库

---加载在AiC模块后的外来模块(来自群文件)
lstg.DoFile("extra_lib/limit_func_ETC.lua")--空气墙，用于制作平台及部分演出

----------------------------------------
---用户定义的一些函数

--- 加载 THlib 后，会被重载以适应 replay 系统
--- 逻辑帧更新，不和 FrameFunc 一一对应
function DoFrame()
    --设置标题
    --lstg.SetTitle(string.format("%s | %.2f FPS | %d OBJ | %s", setting.mod, lstg.GetFPS(), lstg.GetnObj(), gconfig.window_title))
    --lstg.SetTitle(string.format("%s", gconfig.window_title)) -- 启动器阶段不用显示那么多信息
    lstg.SetTitle("东方梦摇篮 ~ Alice In Cradle v" .. aic.version)
    --获取输入
    GetInput()
    --切关处理
    if stage.NextStageExist() then
        stage.Change()
    end
    stage.Update()
    --object frame function
    ObjFrame()
    --碰撞检测
    BoundCheck()
    CollisionCheck(GROUP_PLAYER, GROUP_ENEMY_BULLET)
    CollisionCheck(GROUP_PLAYER, GROUP_ENEMY)
    CollisionCheck(GROUP_PLAYER, GROUP_INDES)
    CollisionCheck(GROUP_ENEMY, GROUP_PLAYER_BULLET)
    CollisionCheck(GROUP_NONTJT, GROUP_PLAYER_BULLET)
    CollisionCheck(GROUP_ITEM, GROUP_PLAYER)
    --后更新
    UpdateXY()
    AfterFrame()
end

function BeforeRender()
end

function AfterRender()
end

function GameExit()
end

----------------------------------------
---全局回调函数，底层调用

local Ldebug = require("lib.Ldebug")

function GameInit()
    --加载mod包
    if setting.mod ~= 'launcher' then
        ---THAIC Added
        setting.mod = setting.mod or "Muki_AliceInCradle"
        Include 'root.lua'
        lstg.plugin.DispatchEvent("afterMod")
    else
        Include 'launcher.lua'
    end
    --最后的准备
    lstg.RegisterAllGameObjectClass() -- 对所有class的回调函数进行整理，给底层调用
    InitScoreData()--装载玩家存档

    SetViewMode("world")
    if stage.next_stage == nil then
        error('Entrance stage not set.')
    end
    SetResourceStatus("stage")
end

function FrameFunc()
    Ldebug.update()
    DoFrame(true, true)
    Ldebug.layout()
    return stage.QuitFlagExist()
end

function RenderFunc()
    if stage.current_stage.timer >= 0 and stage.next_stage == nil then
        BeginScene()
        UpdateScreenResources()
        BeforeRender()
        stage.current_stage:render()
        ObjRender()
        AfterRender()
        Ldebug.draw()
        EndScene()
    end
end

function FocusLoseFunc()
end

function FocusGainFunc()
end
