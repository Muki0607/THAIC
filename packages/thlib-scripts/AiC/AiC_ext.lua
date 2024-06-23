---=====================================
---THAIC Extra Game Loop v1.01a
---东方梦摇篮 ext扩展库 v1.01a
---=====================================

---版本更新记录
---v1.00a
---初始版本
---v1.01a
---添加lib.StartTimer、lib.PauseTimer、lib.ResumeTimer、lib.StopTimer函数，提供用于统计处理落的高精度计时器

---@class aic.ext @东方梦摇篮ext扩展库
aic.ext = {}
local lib = aic.ext

---用于统计处理落的高精度计时器
---@type lstg.StopWatch
aic.ext.real_timer = nil

---支持时缓系统与3Dobj参数更新的帧函数
function lib.DoFrameEx()
    DoFrameEx()
    for _, o in ObjList(GROUP_ALL) do
        if o.Is3D then
            aic.view3d.UpdateObj(o)
        end
        if o.slowsys then
            local sys = o.slowsys
            for _, k in ipairs({ 'frame', 'ax', 'ay', 'vx', 'vy', 'omiga' }) do
                if o[k] ~= sys[k] then
                    sys[k] = o[k]
                    if k == 'frame' then
                        o[k] = function() end
                    else
                        o[k] = 0
                    end
                end
            end
            if ext.slowTicker % sys.timerate == 0 then
                sys.vx = sys.vx + sys.ax
                sys.vy = sys.vy + sys.ay
                o.x = o.x + sys.vx
                o.y = o.y + sys.vy
                o.rot = o.rot + sys.omiga
                sys.timer = sys.timer + 1
                sys.frame(o)
            end
            o.timer = sys.timer
        end
    end
end

---为单个object设置时缓，将会接管该单位的帧函数与更新，不影响后更新
---@param unit lstg.GameObject @要设置的单位
---@param timerate number @单位执行帧函数的周期，即时缓倍率的倒数，必须为整数
function lib.SetTimeSlow(unit, timerate)
    assert(IsValid(unit), "invalid object.")
    unit.slowsys = unit.slowsys or {}
    local sys = unit.slowsys
    for _, k in ipairs({ 'frame', 'ax', 'ay', 'vx', 'vy', 'omiga' }) do
        sys[k] = unit[k]
        unit[k] = 0
    end
    unit.frame = function() end
    sys.timerate = max(1, abs(int(timerate or 1)))
end

---启动高精度计时器
function lib.StartTimer()
    lib.real_timer = StopWatch()
    lib.frame_counter = 0
end

---暂停高精度计时器
function lib.PauseTimer()
    lib.real_timer:Pause()
end

---恢复高精度计时器
function lib.ResumeTimer()
    lib.real_timer:Resume()
end

---关闭高精度计时器，返回总时间
---@return number 总时间（秒）
function lib.StopTimer()
    lib.real_timer:Pause()
    return lib.real_timer:GetElapsed()
end

---获取高精度计时器当前时间
---@return number 当前时间（秒）
function lib.GetTimer()
    lib.real_timer:Pause()
    local time = lib.real_timer:GetElapsed()
    lib.real_timer:Resume()
    return time
end

