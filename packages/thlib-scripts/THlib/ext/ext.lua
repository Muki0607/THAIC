---THAIC Arranged
---=====================================
---stagegroup|replay|pausemenu system
---extra game loop
---=====================================

----------------------------------------
---ext加强库

---@class ext @额外游戏循环加强库
ext = {}

local extpath = "THlib/ext/"

DoFile(extpath .. "ext_pause_menu.lua")
--暂停菜单和暂停菜单资源
DoFile(extpath .. "ext_replay.lua")
--CHU爷爷的replay系统以及切关函数重载
DoFile(extpath .. "ext_stage_group.lua")
--关卡组

---XInput，用于支持手柄输入
local xinput = require("xinput")
---DirectInput，用于支持较老的手柄的输入
local dinput = require("dinput")

ext.replayTicker = 0
--控制录像播放速度时有用
ext.slowTicker = 0
--控制时缓的变量
ext.time_slow_level = { 1, 2, 3, 4 }
--60/30/20/15 4个程度
ext.pause_menu = ext.pausemenu()
--实例化的暂停菜单对象，允许运行时动态更改样式
ext.error_level = 0
--异常堆栈等级，防止递归过深

ext.debug_data = {
    --- 调试功能版本 1
    version = 1,
    --- 允许修改更新速率
    x_speed_update = false,
    --- 更新速率，若为 2 则代表每帧更新 2 次
    --- 如果为负值，如 -2 则代表 (timer % 2) == 0 时更新一次
    --- 如果值为 0 则停止更新，用于步进模式
    x_speed_update_value = 0,
    --- 请求触发一次更新，仅当更新速率为 0 时才生效
    request_once_update = false,
    --- 更新计时器
    timer = -1,
}

--- [调试功能] 是否启用了更新速率调试
function ext.isUpdateSpeedModifierEnable()
    return (not stage.current_stage.is_menu) and ext.debug_data.x_speed_update
end

--- [调试功能] 根据自定义更新速率更新
function ext.updateWithSpeedModifier()
    local db = ext.debug_data
    db.timer = db.timer + 1
    if db.x_speed_update_value == 0 then
        if db.request_once_update then
            db.request_once_update = false
            DoFrame(true, false)
        end
    elseif db.x_speed_update_value > 0 then
        for _ = 1, ext.debug_data.x_speed_update_value do
            if not ext.pop_pause_menu then
                DoFrame(true, false)
            end
        end
    else -- if db.x_speed_update_value < 0 then
        if (db.timer % db.x_speed_update_value) == 0 then
            DoFrame(true, false)
        end
    end
end

---重置缓速计数器
function ext.ResetTicker()
    ext.replayTicker = 0
    ext.slowTicker = 0
end

---获取暂停菜单发送的命令
---@return string
function ext.GetPauseMenuOrder()
    return ext.pause_menu_order
end

---发送暂停菜单的命令，命令有以下类型：
---'Continue'
---'Return to Title'
---'Quit and Save Replay'
---'Give up and Retry'
---'Restart'
---'Replay Again'
---'Manual'（新增）
---'Option'（新增）
---'Return to Waypoint'（新增）
---'Watch Ending'（新增）
---@param msg string
function ext.PushPauseMenuOrder(msg)
    ext.pause_menu_order = msg
end

----------------------------------------
---extra user function

function GameStateChange()
end

---设置标题
function ChangeGameTitle()
    --local mod = setting.mod and #setting.mod > 0 and setting.mod
    local game = "东方梦摇篮　~ Alice In Cradle v" .. aic.version
    local ext =
        table.concat(
            {
                string.format("FPS=%.1f", GetFPS()),
                "OBJ=" .. GetnObj(),
                gconfig.window_title
            },
            " | "
        )
    if _debug.full_title then
        SetTitle(game .. " | " .. ext)
    else
        SetTitle(game)
    end
    --[[
    if mod then
        SetTitle(mod .. " | " .. ext)
    else
        SetTitle(ext)
    end
    ]]
end

---切关处理
function ChangeGameStage()
    ResetWorld()
    ResetWorldOffset()
    --by ETC，重置world偏移

    lstg.ResetLstgtmpvar()
    --重置lstg.tmpvar
    ex.Reset()
    --重置ex全局变量

    if lstg.nextvar then
        lstg.var = lstg.nextvar
        lstg.nextvar = nil
    end

    -- 初始化随机数
    if lstg.var.ran_seed then
        --Print('RanSeed',lstg.var.ran_seed)
        ran:Seed(lstg.var.ran_seed)
    end

    --刷新最高分
    if not stage.next_stage.is_menu then
        if scoredata.hiscore == nil then
            scoredata.hiscore = {}
        end
        lstg.tmpvar.hiscore = scoredata.hiscore[stage.next_stage.stage_name .. "@" .. tostring(lstg.var.player_name)]
    end
end

---获取输入
function GetInput()
    local lib = aic.input
    -- 自动切换主输入方式，确保同时只有一个主输入
    if lib.GetLastJoy() ~= xinput.Null then
        if xinput.isConnected(1) then
            lib.InputState = 'xjoy'
        else
            lib.InputState = 'djoy'
        end
    elseif GetLastKey() ~= KEY.NULL then
        lib.InputState = 'keyboard'
    end

    -- 获取额外键盘输入
    lib.GetKeyboardInput()
    -- 获取鼠标输入
    -- 暂时没有把鼠标输入加入录像系统的必要
    lib.GetMouseInput()
    -- 获取手柄输入
    if xinput.isConnected(1) or lib.dinput.isConnected(1) then
        lib.GetJoystickInput()
    end
    -- 更新KeyStatePre
    if stage.next_stage then
        KeyStatePre = {}
        -- 重置所有输入状态
        lib.ResetState()
    elseif ext.pause_menu:IsKilled() then
        -- 刷新KeyStatePre
        for k, _ in pairs(setting.keys) do
            KeyStatePre[k] = KeyState[k]
        end
    end

    -- 不是录像时更新按键状态
    if not ext.replay.IsReplay() then
        for k, v in pairs(setting.keys) do
            --支持手柄
            if lib.InputState == 'xjoy' then
                KeyState[k] = lib.JoystickState[aic.table.Search(XJOY, setting.joysticks[k])]
            elseif lib.InputState == 'djoy' then
                KeyState[k] = lib.JoystickState[aic.table.Search(DJOY, setting.joysticks[k])]
            else
                KeyState[k] = GetKeyState(v)
            end
        end
    end

    if ext.pause_menu:IsKilled() then
        -- 更新按键双击状态
        -- 为确保按键双击可以记入录像，暂停时不更新按键双击状态
        for i = 0, 255 do
            if GetKeyState(i) then
                if lib.KDPTime[i] and lib.KDPTime[i] > 0 then
                    lib.KDPState[i] = true
                end
                lib.KDPTime[i] = lib.KDP_intv
            else
                lib.KDPState[i] = false
            end
            if lib.KDPTime[i] then
                lib.KDPTime[i] = max(0, lib.KDPTime[i] - 1)
            end
        end

        if ext.replay.IsRecording() then
            -- 录像模式下记录当前帧的按键
            replayWriter:Record(KeyState)
        elseif ext.replay.IsReplay() then
            -- 回放时载入按键状态
            replayReader:Next(KeyState)
        end
    end
end

--- 逻辑帧更新，不和 FrameFunc 一一对应
function DoFrame()
    --标题设置
    ChangeGameTitle()
    --刷新输入
    GetInput()
    --切关处理
    if stage.NextStageExist() then
        stage.DestroyCurrentStage()
        ChangeGameStage()
        stage.CreateNextStage()
    end
    --stage和object逻辑
    if GetCurrentSuperPause() <= 0 or stage.nopause then
        ex.Frame()
        stage.Update()
    end
    ObjFrame()
    if GetCurrentSuperPause() <= 0 or stage.nopause then
        BoundCheck()
    end
    if GetCurrentSuperPause() <= 0 then
        CollisionCheck(GROUP_PLAYER, GROUP_ENEMY_BULLET)
        CollisionCheck(GROUP_PLAYER, GROUP_ENEMY)
        CollisionCheck(GROUP_PLAYER, GROUP_INDES)
        CollisionCheck(GROUP_ENEMY, GROUP_PLAYER_BULLET)
        CollisionCheck(GROUP_NONTJT, GROUP_PLAYER_BULLET)
        CollisionCheck(GROUP_ITEM, GROUP_PLAYER)
        --由OLC添加，可用于自机bomb
        CollisionCheck(GROUP_SPELL, GROUP_ENEMY)
        CollisionCheck(GROUP_SPELL, GROUP_NONTJT)
        CollisionCheck(GROUP_SPELL, GROUP_ENEMY_BULLET)
        CollisionCheck(GROUP_SPELL, GROUP_INDES)
        --由OLC添加，用于检查与自机碰撞，可以做？？？（好吧其实我不知道能做啥= =
        --可以做自机贴贴！（不是
        CollisionCheck(GROUP_CPLAYER, GROUP_PLAYER)
    end
    UpdateXY()
    AfterFrame()
end

---缓速和加速
function DoFrameEx()
    if ext.replay.IsReplay() then
        --播放录像时
        ext.replayTicker = ext.replayTicker + 1
        ext.slowTicker = ext.slowTicker + 1
        if GetKeyState(setting.keysys.repfast) then
            for _ = 1, 4 do
                DoFrame(true, false)
                ext.pause_menu_order = nil
            end
        elseif GetKeyState(setting.keysys.repslow) then
            if ext.replayTicker % 4 == 0 then
                DoFrame(true, false)
                ext.pause_menu_order = nil
            end
        else
            if lstg.var.timeslow then
                local tmp = min(4, max(1, lstg.var.timeslow))
                if ext.slowTicker % (ext.time_slow_level[tmp]) == 0 then
                    DoFrame(true, false)
                end
            else
                DoFrame(true, false)
            end
            ext.pause_menu_order = nil
        end
    else
        --正常游戏时
        ext.slowTicker = ext.slowTicker + 1
        if lstg.var.timeslow and lstg.var.timeslow > 0 then
            local tmp = min(4, max(1, lstg.var.timeslow))
            if ext.slowTicker % (ext.time_slow_level[tmp]) == 0 then
                DoFrame(true, false)
            end
        elseif ext.isUpdateSpeedModifierEnable() then
            ext.updateWithSpeedModifier()
        else
            DoFrame(true, false)
        end
    end
end

function BeforeRender()
end

function AfterRender()
    --暂停菜单渲染
    local state = 0
    ext.pause_menu:render()
    if achi then
        SetViewMode "ui"
        achi.ShowRender(576, 240)
    end
end

function GameExit()
end

----------------------------------------
---extra game call-back function

local Ldebug = require("lib.Ldebug")

---默认游戏帧函数
---@return boolean @是否退出游戏
function DefaultGameFrameFunc()
    if xinput.isConnected(1) then
        xinput.update()
    elseif aic.input.dinput.isConnected(1) then
        dinput.update()
    end
    Ldebug.update()
    --重设boss ui的槽位（多boss支持）
    boss_ui.active_count = 0
    --执行场景逻辑
    if ext.pause_menu:IsKilled() then
        --处理录像速度与正常更新逻辑
        --DoFrameEx()
        aic.ext.DoFrameEx()
        --按键弹出菜单
        if (aic.input.CheckLastKey('menu') or ext.pop_pause_menu) and (not stage.current_stage.is_menu) then
            ext.pause_menu:FlyIn()
        end
    end
    --暂停菜单更新
    ext.pause_menu:frame()
    Ldebug.layout()
    return stage.QuitFlagExist()
end

---默认游戏渲染函数
function DefaultGameRenderFunc()
    BeginScene()
    UpdateScreenResources()
    SetWorldFlag(1)
    BeforeRender()
    if
        stage.current_stage.timer and stage.current_stage.timer >= 0 and
        (stage.next_stage == nil or stage.next_stage.is_menu)
    then
        stage.current_stage:render()
        ObjRender()
        SetViewMode("world")
        DrawCollider()
        if Collision_Checker then
            Collision_Checker.render()
        end
    end
    AfterRender()
    Ldebug.draw()
    EndScene()
    -- 截图
    if aic.input.CheckLastKey('snapshot') then
        lstg.LocalUserData.Snapshot()
    end
    if achi then
        achi.ShowFrame()
    end
end

---游戏循环中每帧调用一次，在RenderFunc之前
---@return boolean @返回true时结束游戏循环
function FrameFunc()
    ---为了不直接让玩家看到错误信息在保护模式下调用
    return TryExcept(
        DefaultGameFrameFunc,
        {
            [""] = function()
                if not _debug.exception_handler_disabled and ext.error_level <= 5 then
                    ext.error_level = ext.error_level + 1
                    lstg.Log(4, aic.py.last_exception)
                    lstg.MsgBoxError("游戏运行时出现帧逻辑错误。\n请将游戏日志发送给作者。", "游戏出现异常", true)
                    stage.QuitGame()
                else
                    raise()
                end
            end
        }
    )
    
end

---游戏循环中每帧调用一次，在FrameFunc之后
function RenderFunc()
    ---为了不直接让玩家看到错误信息在保护模式下调用
    return TryExcept(
        DefaultGameRenderFunc,
        {
            [""] = function()
                if not _debug.exception_handler_disabled and ext.error_level <= 5 then
                    ext.error_level = ext.error_level + 1
                    lstg.Log(4, aic.py.last_exception)
                    lstg.MsgBoxError("游戏运行时出现渲染逻辑错误。\n请将游戏日志发送给作者。", "游戏出现异常", true)
                    stage.QuitGame()
                else
                    raise()
                end
            end
        }
    )
end

---窗口失去焦点的时候被调用
function FocusLoseFunc()
    --待解决：进菜单前如果失焦会导致开暂停菜单
    --没法解决，就这样吧
    --待解决：进关卡时会暂停
    --[[
    if ext.pause_menu:IsKilled() and stage.current_stage and not stage.current_stage.is_menu and not StageLoadingSign then
        ext.pop_pause_menu = true
        ext.focus_lose = true
        lstg.tmpvar.pause_menu_text = { 'Return to Game' }
    end
    ]]
end

---窗口获得焦点的时候被调用
function FocusGainFunc()
    --[[
    if not ext.pause_menu:IsKilled() and ext.focus_lose then
        ext.pausemenu:FlyOut()
        ext.focus_lose = false
        lstg.tmpvar.pause_menu_text = nil
    end
    ]]
end
