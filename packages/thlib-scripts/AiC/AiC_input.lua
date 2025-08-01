---=====================================
---THAIC Input v1.05a
---东方梦摇篮输入 v1.05a
---=====================================

---版本更新记录
---v1.00a
---初始版本
---v1.01a
---增加lib.MouseIsDown、lib.MouseIsPressed函数，允许像键盘输入一样处理鼠标输入
---v1.02a
---增加lib.MouseIsReleased函数
---增加lib.KeyIsDown、lib.KeyIsPressed、lib.KeyIsReleased函数，允许以keycode调用这些函数
---v1.02b
---增加KeyIsReleased全局函数
---v1.03a
---增加lib.KeyIsDoublePressed、lib.MouseIsDoublePressed函数，允许检测双击
---v1.04a
---增加lib.GetJoystickInput、lib.GetLastJoy、lib.CheckLastKey函数，用于处理手柄输入
---由于手柄输入已经整合入KeyState，大部分对手柄输入判定可以直接使用对键盘输入判定的函数（KeyIsDown、KeyIsPressed）
---v1.05a
---添加dinput，增加对老旧设备的支持
---模仿原作将上下左右映射至左摇杆，但目前在使用CheckLastKey检测方向时不能很好的识别

---@class aic.input @东方梦摇篮输入
aic.input = {}
local lib = aic.input

---@class xinput @XInput，用于处理手柄输入
local xinput = require("xinput")
---@class dinput @DirectInput，用于处理较老的手柄的输入
local dinput = require("dinput")

---xinput摇杆键位表
lib.xinputJoystickKey = {
    'Up', 'Down', 'Left', 'Right', 'Start', 'Back',
    'LeftThumb', 'RightThumb', 'LeftShoulder', 'RightShoulder',
    'A', 'B', 'X', 'Y'
}

---dinput摇杆键位表
lib.dinputJoystickKey = {
    'Up', 'Down', 'Left', 'Right', 'Start', 'Back',
    'LeftThumb', 'RightThumb', 'LeftShoulder', 'RightShoulder',
    'A', 'B', 'X', 'Y',
    'Select', 'LeftShoulder2', 'RightShoulder2'
}
---未知键位
for i = 14, 32 do
    table.insert(lib.dinputJoystickKey, "Button" .. i)
end

---摇杆模拟量输入取值范围，用于dinput设备
---
---@type table<string, number>
lib.AxisRange = {
    XMin = 0,  YMin = 0,  ZMin = 0,
    XMax = 0,  YMax = 0,  ZMax = 0,
    RxMin = 0, RyMin = 0, RzMin = 0,
    RxMax = 0, RyMax = 0, RzMax = 0,
    Slider0Min = 0, Slider1Min = 0,
    Slider0Max = 0, Slider1Max = 0,
}

---鼠标状态
---
---@type table<string, boolean>
lib.MouseState = {
    x = 0,
    y = 0,
    wheel = 0,
    left = false,
    middle = false,
    right = false,
    X1 = false,
    X2 = false
}

---上一帧鼠标状态
---
---@type table<string, boolean>
lib.MouseStatePre = {
    x = 0,
    y = 0,
    wheel = 0,
    left = false,
    middle = false,
    right = false,
    X1 = false,
    X2 = false
}

---手柄状态
---
---@type table<string, boolean>
lib.JoystickState = {
    Up = false,
    Down = false,
    Left = false,
    Right = false,
    Start = false,
    Back = false,
    LeftThumb = false,
    RightThumb = false,
    LeftShoulder = false,
    RightShoulder = false,
    A = false,
    B = false,
    X = false,
    Y = false,
    LeftTrigger = 0,
    RightTrigger = 0,
    LeftThumbX = 0,
    LeftThumbY = 0,
    RightThumbX = 0,
    RightThumbY = 0,
    --dinput键位
    Select = false,
    LeftShoulder2 = false,
    RightShoulder2 = false,
}
---未知键位
for i = 14, 32 do
    lib.JoystickState["Button" .. i] = false
end

---上一帧手柄状态
---
---@type table<string, boolean>
lib.JoystickStatePre = {
    Up = false,
    Down = false,
    Left = false,
    Right = false,
    Start = false,
    Back = false,
    LeftThumb = false,
    RightThumb = false,
    LeftShoulder = false,
    RightShoulder = false,
    A = false,
    B = false,
    X = false,
    Y = false,
    LeftTrigger = 0,
    RightTrigger = 0,
    LeftThumbX = 0,
    LeftThumbY = 0,
    RightThumbX = 0,
    RightThumbY = 0,
    --dinput键位
    Select = false,
    LeftShoulder2 = false,
    RightShoulder2 = false,
}
---未知键位
for i = 14, 32 do
    lib.JoystickStatePre["Button" .. i] = false
end

---额外按键状态
---@type table<number, boolean>
lib.KeyState = {}
---@type table<number, boolean>
lib.KeyStatePre = {}

---用于判断键盘按键双击的表
---
---@type table<number, number>
lib.KDPTime = {}

---用于判断键盘按键双击的表
---
---@type table<number, boolean>
lib.KDPState = {}

---用于判断键盘按键双击的表
---
---@type table<string, number>
lib.MDPTime = { left = 0, middle = 0, right = 0, X1 = 0, X2 = 0 }

---用于判断鼠标按键双击的表
---
---@type table<string, boolean>
lib.MDPState = { left = false, middle = false, right = false, X1 = false, X2 = false }

---键盘按键双击最大间隔（帧）
---
---@type number
lib.KDP_intv = 20

---鼠标按键双击最大间隔（帧）
---
---@type number
lib.MDP_intv = 20

---当前主输入方式
---
---@type '"keyboard"' | '"joystick"'
lib.InputState = 'keyboard'

---获取额外键盘输入
function lib.GetKeyboardInput()
    for _, v in pairs(KEY) do
        lib.KeyStatePre[v] = lib.KeyState[v]
        lib.KeyState[v] = GetKeyState(v)
    end
end

---获取鼠标输入
function lib.GetMouseInput()
    for k, v in pairs({ left = 0, middle = 1, right = 2, X1 = 3, X2 = 4 }) do
        lib.MouseStatePre[k] = lib.MouseState[k]
        lib.MouseState[k] = GetMouseState(v)
        if lib.MouseState[k] then
            if lib.MDPTime[k] > 0 then
                lib.MDPState[k] = true
            end
            lib.MDPTime[k] = lib.MDP_intv
        else
            lib.MDPState[k] = false
        end
        lib.MDPTime[k] = max(0, lib.MDPTime[k] - 1)
    end
    lib.MouseStatePre.wheel = lib.MouseState.wheel
    lib.MouseState.wheel = GetMouseWheelDelta()
    lib.MouseStatePre.x, lib.MouseStatePre.y = lib.MouseState.x, lib.MouseState.y
    lib.MouseState.x, lib.MouseState.y = GetMousePosition()
end

---获取手柄输入
function lib.GetJoystickInput()
    local M, joykey
    if xinput.isConnected(1) then
        M = xinput
        joykey = lib.xinputJoystickKey
    elseif lib.dinput.isConnected(1) then
        M = lib.dinput
        joykey = lib.dinputJoystickKey
    end
    for k, v in pairs(lib.JoystickState) do
        lib.JoystickStatePre[k] = v
    end
    for _, v in ipairs(joykey) do
        lib.JoystickState[v] = M.getKeyState(M[v])
    end
    for _, v in ipairs({ 'LeftTrigger', 'RightTrigger', 'LeftThumbX', 'LeftThumbY',
        'RightThumbX', 'RightThumbY' }) do
        lib.JoystickState[v] = M['get' .. v]()
    end
    --支持摇杆
    setting.joyblindarea = setting.joyblindarea or 0.2
    if abs(M.getLeftThumbX()) > setting.joyblindarea then
        lib.JoystickState.Left = lib.JoystickState.LeftThumbX < 0
        lib.JoystickState.Right = lib.JoystickState.LeftThumbX > 0
    end
    if abs(M.getLeftThumbY()) > setting.joyblindarea then
        lib.JoystickState.Up = lib.JoystickState.LeftThumbY > 0
        lib.JoystickState.Down = lib.JoystickState.LeftThumbY < 0
    end
end

---判定上一个按键是否是给定按键，支持手柄
---存在一定问题，可以的话尽量用KeyIsPressed和KeyIsDown代替
---@param key string @键位名称
---@return boolean @上一个按键是否是给定按键，支持手柄
function lib.CheckLastKey(key)
    if (xinput.isConnected(1) or dinput.count() > 0) and lib.InputState == 'joystick' then
        if setting.joysticks[key] then
            return lib.GetLastJoy() == setting.joysticks[key]
        else
            return lib.GetLastJoy() == setting.joysticksys[key]
        end
    else
        if setting.keys[key] then
            return GetLastKey() == setting.keys[key]
        else
            return GetLastKey() == setting.keysys[key]
        end
    end
end

---摘自Linput.lua
---
---判定某个键盘按键是否被按下
---@param key number @keycode
---@return boolean @是否被按下
function lib.KeyIsDown(key)
    return lib.KeyState[key]
end

---摘自Linput.lua
---
---判定某个键盘按键是否在当前帧被按下
---@param key number @keycode
---@return boolean @是否在当前帧被按下
function lib.KeyIsPressed(key)
    return lib.KeyState[key] and (not lib.KeyStatePre[key])
end

---摘自旧版Linput.lua
---
---判定某个键盘按键是否在当前帧被释放
---@param key number @keycode
---@return boolean @是否在当前帧被释放
function lib.KeyIsReleased(key)
    return lib.KeyStatePre[key] and (not lib.KeyState[key])
end

---摘自旧版Linput.lua
---
---判定某个键盘按键是否在当前帧被释放（rep键位版）
---@param key string @按键名称
---@return boolean @是否在当前帧被释放
function KeyIsReleased(key)
    key = setting.keys[key]
    if key then
        return KeyStatePre[key] and (not KeyState[key])
    else
        return false
    end
end

---判定某个键盘按键是否在当前帧被双击
---@param key number @keycode
---@return boolean @是否在当前帧被双击
function lib.KeyIsDoublePressed(key)
    return lib.KDPState[key]
end

---判定某个键盘按键是否在当前帧被双击（rep键位版）
---@param key string @按键名称
---@return boolean @是否在当前帧被双击
function lib.KeyIsDoublePressed(key)
    key = setting.keys[key]
    if key then
        return lib.KDPState[key]
    else
        return false
    end
end

---鼠标obj，会自动跟随鼠标位置
lib.cursor = Class(object)

function lib.cursor:init(img)
    self.img = img or 'img_void'
    self.bound = false
    self.layer = LAYER_TOP + _infinite
    self.x, self.y = lib.GetMousePosition()
end

function lib.cursor:frame()
    self.x, self.y = lib.GetMousePosition()
end

function lib.cursor:render()
    SetViewMode('ui')
    Render(self.img, self.x, self.y)
    SetViewMode('world')
end

--改自getMousePositionToUI
---获取当前鼠标位置，可指定坐标系
---
---转world系时根据鼠标位置会存在一定误差，最大可能达到25单位距离左右
---@param viewmode viewmode @坐标系
---@param mousestate table @要获取的mousestate，可以是MouseState|MouseStatePre
---@return number, number
function lib.GetMousePosition(viewmode, mousestate)
    viewmode = viewmode or 'ui'
    mousestate = mousestate or lib.MouseState
    local x, y = mousestate.x, mousestate.y
    -- 转换到 UI 视口
    x = x - screen.dx
    y = y - screen.dy
    --转换一次
    x = x / screen.scale
    y = y / screen.scale
    --不知道为什么到world要转二次……
    if viewmode == 'world' then
        x = x / screen.scale
        y = y / screen.scale
    end
    -- UI系转其他系
    return PosTrans(x, y, 'ui', viewmode)
end

---获取鼠标滚轮方向
---@return sign @鼠标滚轮增量方向
function lib.GetMouseDirection()
    return sign(lib.MouseState.wheel)
end

---获取本帧内鼠标位移
---@param viewmode viewmode @坐标系
---@return number, number
function lib.GetMousePosDelta(viewmode)
    local x1, y1 = lib.GetMousePosition(viewmode, lib.MouseStatePre)
    local x2, y2 = lib.GetMousePosition(viewmode)
    return x2 - x1, y2 - y1
end

function lib.IsMouseInRect(viewmode, l, r, b, t)
    local x, y = lib.GetMousePosition(viewmode)
    return IsIn(x, l, r) and IsIn(y, b, t)
end

---@alias MouseState '"none"' | '"left"' | '"middle"' | '"right"' | '"X1"' | '"X2"'

---获取最后鼠标状态
---@return MouseState @鼠标按键
function lib.GetLastClick()
    local state = { left = 0, middle = 1, right = 2, X1 = 3, X2 = 4 }
    for k, v in pairs(state) do
        if GetMouseState(v) then
            return k
        end
    end
    return "none"
end

---判定某个鼠标按键是否被按下
---@param index MouseState @鼠标按键
---@return boolean @是否被按下
function lib.MouseIsDown(index)
    return lib.MouseState[index]
end

---判定某个鼠标按键是否在当前帧被按下
---@param index MouseState @鼠标按键
---@return boolean @是否在当前帧被按下
function lib.MouseIsPressed(index)
    return lib.MouseState[index] and (not lib.MouseStatePre[index])
end

---判定某个鼠标按键是否在当前帧被释放
---@param index MouseState @鼠标按键
---@return boolean @是否在当前帧被释放
function lib.MouseIsReleased(index)
    return lib.MouseStatePre[index] and (not lib.MouseState[index])
end

---判定某个鼠标按键是否在当前帧被双击
---@param index MouseState @鼠标按键
---@return boolean @是否在当前帧被双击
function lib.MouseIsDoublePressed(index)
    return lib.MDPState[index]
end

---获取最后手柄状态，斜上斜下将被视为上下
---@return number @手柄按键常量，将根据当前接入手柄的类型发生变化
function lib.GetLastJoy()
    local M, joykey
    if xinput.isConnected(1) then
        M = xinput
        joykey = lib.xinputJoystickKey
    elseif dinput.count() > 0 then
        M = lib.dinput
        joykey = lib.dinputJoystickKey
    end
    if not M then return 0 end
    --支持摇杆
    setting.joyblindarea = setting.joyblindarea or 0.2
    if abs(M.getLeftThumbX()) > setting.joyblindarea or abs(M.getLeftThumbY()) > setting.joyblindarea then
        if M.getLeftThumbY() > 0 then return M.Up end
        if M.getLeftThumbY() < 0 then return M.Down end
        if M.getLeftThumbX() < 0 then return M.Left end
        if M.getLeftThumbX() > 0 then return M.Right end
    end
    --[[
    if abs(M.getLeftThumbY()) > setting.joyblindarea then
        if M.getLeftThumbY() > 0 then return M.UP end
        if M.getLeftThumbY() < 0 then return M.Down end
    end
    if abs(M.getLeftThumbX()) > setting.joyblindarea then
        if M.getLeftThumbX() < 0 then return M.Left end
        if M.getLeftThumbX() > 0 then return M.Right end
    end
    ]]
    for _, v in ipairs(joykey) do
        if M.getKeyState(M[v]) then return M[v] end
    end
    return M.Null
end

---判定某个手柄按键是否被按下
---@param index number @手柄按键
---@return boolean @是否被按下
function lib.JoyIsDown(index)
    return lib.JoystickState[index]
end

---判定某个手柄按键是否在当前帧被按下
---@param index number @手柄按键
---@return boolean @是否在当前帧被按下
function lib.JoyIsPressed(index)
    return lib.JoystickState[index] and (not lib.JoystickStatePre[index])
end

---判定某个手柄按键是否在当前帧被释放
---@param index number @手柄按键
---@return boolean @是否在当前帧被释放
function lib.JoyIsReleased(index)
    return lib.JoystickStatePre[index] and (not lib.JoystickState[index])
end

---返回修正后的键位名称表
---@return table 键位名称表
function lib.KeyNameList()
    local ret = KeyCodeToName()
    ret[KEY.ESCAPE] = "Esc"
    ret[KEY.CTRL] = "Ctrl"
    ret[KEY.ALT] = "ALT"
    ret[KEY.LEFT] = "←"
    ret[KEY.UP] = "↑"
    ret[KEY.RIGHT] = "→"
    ret[KEY.DOWN] = "↓"
    ret[KEY.MINUS] = "-"
    ret[KEY.EQUALS] = "="
    ret[KEY.BACKSLASH] = "\\"
    ret[KEY.LBRACKET] = "["
    ret[KEY.RBRACKET] = "]"
    ret[KEY.SEMICOLON] = ";"
    ret[KEY.APOSTROPHE] = "\'"
    ret[KEY.COMMA] = ","
    ret[KEY.PERIOD] = "."
    ret[KEY.SLASH] = "/"
    for i = KEY.NUMPAD0, KEY.NUMPAD9 do
        ret[i] = "小键盘" .. (i - KEY.NUMPAD0)
    end
    ret[KEY.MULTIPLY] = "小键盘*"
    ret[KEY.DIVIDE] = "小键盘/"
    ret[KEY.ADD] = "小键盘+"
    ret[KEY.SUBTRACT] = "小键盘-"
    ret[KEY.DECIMAL] = "小键盘."
    ret[0xE8] = "小键盘Enter"
    return ret
end

--这里没有像梦无垠那样设置文字缓冲区，因为这个工作交给输入法了
---获取字符输入
---@return string @输入的字符
function lib.GetLastChar()
    local K = lstg.Input.Keyboard --使用完全版键盘
    local shift = GetKeyState(K.LeftShift) or GetKeyState(K.RightShift)
    if GetKeyState(K.Space) then
        return ' '
    end
    if GetKeyState(K.Tab) then
        return '\t'
    end
    if GetKeyState(K.Enter) then
        return '\n'
    end
    for i = K.NumPad0, K.NumPad9 do
        if GetKeyState(i) then
            return tostring(i - K.NumPad0)
        end
    end
    for i = K.Multiply, K.Divide do
        if GetKeyState(i) then
            local k = i - K.Multiply + 1
            return ({ '*', '+', '\n', '-', '.', '/' })[k]
        end
    end
    if GetKeyState(K.NumPadEnter) then
        return '\n'
    end
    if shift then
        for i = K.D0, K.D9 do
            if GetKeyState(i) then
                local k = i - K.D0 + 1
                return ({ ')', '!', '@', '#', '$', '%', '^', '&', '*', '(' })[k]
            end
        end
        for i = K.A, K.Z do
            if GetKeyState(i) then
                return aic.table.Search(K, i)
            end
        end
        for i = K.Semicolon, K.Tilde do
            if GetKeyState(i) then
                local k = i - K.Semicolon + 1
                return ({ ':', '+', '<', '_', '?', '~' })[k]
            end
        end
        for i = K.OpenBrackets, K.Quotes do
            if GetKeyState(i) then
                local k = i - K.OpenBrackets + 1
                return ({ '{', '|', '}', '\"' })[k]
            end
        end
    else
        for i = K.D0, K.D9 do
            if GetKeyState(i) then
                return tostring(i - K.D0)
            end
        end
        for i = K.A, K.Z do
            if GetKeyState(i) then
                return string.lower(aic.table.Search(K, i))
            end
        end
        for i = K.Semicolon, K.Tilde do
            if GetKeyState(i) then
                local k = i - K.Semicolon + 1
                return ({ ';', '=', ',', '-', '.', '/', '`' })[k]
            end
        end
        for i = K.OpenBrackets, K.Quotes do
            if GetKeyState(i) then
                local k = i - K.OpenBrackets + 1
                return ({ '[', '\\', ']', '\'' })[k]
            end
        end
    end
    return ''
end

---反转字符串大小写，用于处理CapsLock
---@param str string 要反转的字符串
---@return string 反转后的字符串
function lib.ReverseCap(str)
    local ret = sp.string(str):HandleString()
    for k, v in ipairs(ret) do
        if string.fing(v, '%l') then
            ret[k] = string.upper(v)
        else
            ret[k] = string.lower(v)
        end
    end
    return table.concat(ret)
end

---重置所有输入状态
function lib.ResetState()
    lib.KeyState = {}
    lib.KeyStatePre = {}
    for i = 0, 255 do
        lib.KDPTime[i] = 0
        lib.KDPState[i] = false
    end
    lib.MDPTime = { left = 0, middle = 0, right = 0, X1 = 0, X2 = 0 }
    lib.MDPState = { left = false, middle = false, right = false, X1 = false, X2 = false }
    lib.MouseState = {
        x = 0,
        y = 0,
        wheel = 0,
        left = false,
        middle = false,
        right = false,
        X1 = false,
        X2 = false
    }
    lib.MouseStatePre = {
        x = 0,
        y = 0,
        wheel = 0,
        left = false,
        middle = false,
        right = false,
        X1 = false,
        X2 = false
    }
    lib.JoystickState = {
        Up = false,
        Down = false,
        Left = false,
        Right = false,
        Start = false,
        Back = false,
        LeftThumb = false,
        RightThumb = false,
        LeftShoulder = false,
        RightShoulder = false,
        A = false,
        B = false,
        X = false,
        Y = false,
        LeftTrigger = 0,
        RightTrigger = 0,
        LeftThumbX = 0,
        LeftThumbY = 0,
        RightThumbX = 0,
        RightThumbY = 0,
        --dinput键位
        Select = false,
        LeftShoulder2 = false,
        RightShoulder2 = false,
    }
    for i = 14, 32 do
        lib.JoystickState["Button" .. i] = false
    end
    lib.JoystickStatePre = {
        Up = false,
        Down = false,
        Left = false,
        Right = false,
        Start = false,
        Back = false,
        LeftThumb = false,
        RightThumb = false,
        LeftShoulder = false,
        RightShoulder = false,
        A = false,
        B = false,
        X = false,
        Y = false,
        LeftTrigger = 0,
        RightTrigger = 0,
        LeftThumbX = 0,
        LeftThumbY = 0,
        RightThumbX = 0,
        RightThumbY = 0,
        --dinput键位
        Select = false,
        LeftShoulder2 = false,
        RightShoulder2 = false,
    }
    for i = 14, 32 do
        lib.JoystickStatePre["Button" .. i] = false
    end
    lib.AxisRange = dinput.getAxisRange(1) or lib.AxisRange
end

--刷新一遍手柄设备
xinput.refresh()
dinput.refresh()

--更新setting
local JOY
if xinput.isConnected(1) then
    JOY = XJOY
    Log(2, '[input] xinput joystick detected.')
elseif dinput.count() > 0 then --这里还没加载dinput扩展，不能用isConnected
    JOY = DJOY
    Log(2, '[input] dinput joystick detected.')
end
default_setting.joysticks = {
    --实际上下左右移动需要靠摇杆
    up = JOY.Up,
    down = JOY.Down,
    left = JOY.Left,
    right = JOY.Right,
    slow = JOY.RightShoulder,
    shoot = JOY.X,
    spell = JOY.A,
    special = JOY.Y,
    skill = JOY.B,
}
default_setting.joysticksys = {
    repfast = JOY.LeftThumb,
    repslow = JOY.RightThumb,
    menu = JOY.Start,
    snapshot = JOY.Back,
    retry = JOY.LeftShoulder,
}
setting.joysticks = setting.joysticks or default_setting.joysticks
setting.joysticksys = setting.joysticksys or default_setting.joysticksys
setting.joyblindarea = setting.joyblindarea or 0.2
saveConfigure()

lib.ResetState()
