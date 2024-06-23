---=====================================
---THAIC DirectInput Extention v1.00a
---东方梦摇篮DirectInput拓展 v1.00a
---=====================================

---版本更新记录
---v1.00a
---初始版本

local dinput = require("dinput")

---@class aic.input.dinput
local M = {}
aic.input.dinput = M
M.AxisRange = aic.input.AxisRange
local AR = M.AxisRange

--------------------------------------------------------------------------------
--- 简介

-- 本库为将dinput函数映射至xinput同名函数的兼容库
-- 主要用途是简化dinput手柄输入的获取，使获取输入时不用再烦恼要处理dinput还是xinput

--------------------------------------------------------------------------------
--- 按键常量

--- 仅用于兼容
M.Null           = 0

--- DirectInput的方向键通过解析rgdwPOV处理，这里的方向键常量仅用于兼容
--- 手柄方向键，上
M.Up             = -1

--- 手柄方向键，下
M.Down           = -3

--- 手柄方向键，左
M.Left           = -4

--- 手柄方向键，右
M.Right          = -2

--- 手柄 start 按键（一般作为菜单键使用）
M.Start          = 10

--- 手柄 back 按键（一般作为返回键使用）
M.Back           = 13

--- 手柄 select 按键
M.Select         = 9

--- 手柄左摇杆按键（按压摇杆）
M.LeftThumb      = 11

--- 手柄右摇杆按键（按压摇杆）
M.RightThumb     = 12

--- 手柄左肩键1
M.LeftShoulder   = 5

--- 手柄左肩键2
M.LeftShoulder2  = 7

--- 手柄右肩键1
M.RightShoulder  = 6

--- 手柄右肩键2
M.RightShoulder2 = 8

--- 手柄 A 按键
M.A              = 3

--- 手柄 B 按键
M.B              = 2

--- 手柄 X 按键
M.X              = 4

--- 手柄 Y 按键
M.Y              = 1

--- 未知按键
for i = 14, 32 do
    M["Button" .. i] = i
end

--------------------------------------------------------------------------------
--- 方法

--- 重新枚举手柄设备，获取手柄输入，并返回手柄数量
--- DirectInput 重新枚举设备的过程非常耗时，该方法应仅在需要的时候调用
---@return number
function M.refresh()
    return dinput.refresh()
end

--- 获取手柄输入，每帧需要且只需调用一次
function M.update()
    return dinput.update()
end

--- 判断手柄是否已经连接（模拟实现，DirectInput不直接提供此功能）
---@param index number
---@return boolean
function M.isConnected(index)
    local rawState = dinput.getRawState(index)
    return rawState ~= nil
end

--- 根据索引和按键码获取按键状态（模拟XInput按键到DirectInput按钮映射）
---@param index number
---@param keycode number
---@return boolean
---@overload fun(keycode:number):boolean
function M.getKeyState(index, keycode)
    if keycode == nil then
        -- 使用默认手柄
        keycode, index = index, 1
    end
    local rawState = dinput.getRawState(index)
    if rawState then
        return rawState.rgbButtons[keycode] or false
    else
        return false
    end
end

--- 根据索引获取手柄左扳机状态（模拟XInput的扳机为DirectInput的模拟轴）
---@param index number
---@return number
---@overload fun():number
function M.getLeftTrigger(index)
    index = index or 1 -- 使用默认手柄
    local rawState = dinput.getRawState(index)
    if rawState then
        -- 假设左扳机映射到lZ轴，实际映射需根据硬件配置
        return ((rawState.lZ + AR.ZMin) / (AR.ZMax - AR.ZMin) - 0.5) * 2 -- 转换范围从[-32767,32767]到[-1,1]
    else
        return 0
    end
end

--- 根据索引获取手柄右扳机状态（同理模拟）
---@param index number
---@return number
---@overload fun():number
function M.getRightTrigger(index)
    index = index or 1 -- 使用默认手柄
    local rawState = dinput.getRawState(index)
    if rawState then
        -- 假设右扳机映射到lRz轴，实际映射需根据硬件配置
        return ((rawState.lRz + AR.RzMin) / (AR.RzMax - AR.RzMin) - 0.5) * 2 -- 同样转换范围
    else
        return 0
    end
end

---@alias dinput_axis '"X"' | '"Y"'
---@alias dinput_thumb '"Left"' | '"Right"'

--- 根据索引获取手柄摇杆轴状态（模拟XInput的摇杆为DirectInput的模拟轴读取）
---@param index number
---@param axis dinput_axis
---@param thumb dinput_thumb
---@return number
---@overload fun(axis:string, thumb:string):number
---@overload fun(thumb:string):number
---@overload fun():number
function M.getThumbAxis(index, axis, thumb)
    index = index or 1 -- 使用默认手柄
    thumb = thumb or "Left"
    axis = axis or "X"
    local rawState = dinput.getRawState(index)
    if rawState then
        if thumb == "Left" then
            if axis == "X" then
                return ((rawState.lX + AR.XMin) / (AR.XMax - AR.XMin) - 0.5) * 2
            elseif axis == "Y" then
                return (-(rawState.lY + AR.YMin) / (AR.YMax - AR.YMin) + 0.5) * 2 -- 注意Y轴的反向
            end
        elseif thumb == "Right" then
            if axis == "X" then
                if AR.RxMax == AR.RxMin then --支持非常规摇杆轴映射
                    return ((rawState.lZ + AR.ZMin) / (AR.ZMax - AR.ZMin) - 0.5) * 2
                else
                    return ((rawState.lRx + AR.RxMin) / (AR.RxMax - AR.RxMin) - 0.5) * 2
                end
            elseif axis == "Y" then
                if AR.RyMax == AR.RyMin then --支持非常规摇杆轴映射
                    return (-(rawState.lRz + AR.RzMin) / (AR.RzMax - AR.RzMin) + 0.5) * 2
                else
                    return (-(rawState.lRy + AR.RyMin) / (AR.RyMax - AR.RyMin) + 0.5) * 2 -- 反向
                end
            end
        end
    end
    return 0
end

--- 重定向获取摇杆轴状态的函数以简化调用
M.getLeftThumbX = function(index) return M.getThumbAxis(index, "X", "Left") end
M.getLeftThumbY = function(index) return M.getThumbAxis(index, "Y", "Left") end
M.getRightThumbX = function(index) return M.getThumbAxis(index, "X", "Right") end
M.getRightThumbY = function(index) return M.getThumbAxis(index, "Y", "Right") end

return M
