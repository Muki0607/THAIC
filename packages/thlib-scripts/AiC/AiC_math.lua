---=====================================
---THAIC Math v1.01b by Muki
---东方梦摇篮数学库 v1.01b by Muki
---=====================================

---因为本人还只是高中生，所以可能出现很多地才写法（

---版本更新记录
---v1.00a
---初始版本
---v1.01a
---增加了一些table相关函数
---v1.01b
---将table相关函数独立为aic.table库

---@class aic.math @数学库
aic.math = {}
local lib = aic.math

---符号
---@alias sign '1' | '-1' | '0'

---无穷大
---@type number
INFINITE = math.huge

---常用的黄金比例
---@type number
_GOLD = (math.sqrt(5) - 1) / 2

----------------------------------------

---各种逻辑关系，目前完全用不到，但先放这里吧
function lib.xor(a, b)
    return (a and not b) or (not a and b)
end

function lib.nand(a, b)
    return not (a and b)
end

function lib.nor(a, b)
    return not (a or b)
end

function lib.xnor(a, b)
    return not lib.xor(a, b)
end

----------------------------------------

--像是人类使用了十进制（无端
--当然实际上可以用bit.arshift，但我不想require
---十进制转二进制
---@param n number @十进制数
---@return number @二进制数
function lib.dectobin(n)
    if n == 0 then return n end
    local ret = ''
    while n > 0 do
        local r = n % 2
        n = int(n / 2)
        ret = tostring(r) .. ret
    end
    return tonumber(ret)
end

---使一点绕另一点旋转特定角度
---@param x number @原x坐标
---@param y number @原y坐标
---@param a0 number @旋转角度
---@param x0 number @绕其旋转的点的x坐标
---@param y0 number @绕其旋转的点的y坐标
---@return number, number @旋转后的点的x,y坐标
function lib.rotate(x, y, a0, x0, y0)
    x0 = x0 or 0
    y0 = y0 or 0
    local d = Dist(x, y, x0, y0)
    local a = Angle(x, y, x0, y0)
    return x0 + d * cos(a + a0), y0 + d * sin(a + a0)
end

---四舍五入
---@param x number
---@return number
function lib.round(x)
    if x * 10 % 10 < 4 then
        return int(x)
    else
        return int(x + 1)
    end
end

---约等于
---@param a number @要比较的数
---@param b number @要比较的数
---@param accuracy number @精度
---@return boolean @在误差范围内是否相等
function lib.appr_equal(a, b, accuracy)
    accuracy = accuracy or 0.0001
    return abs(a - b) <= accuracy
end

---格式化角度
---说真的我都看不懂我写了啥，但总之结果没错
---@param a number @待格式化的角度
---@param type number @格式化类型，为1时返回-180~180°范围的角度，否则返回0~360°内的角度
---@return number @格式化后的角度
function lib.AngleFormat(a, type)
    local t = int(abs(a) / 360)
    a = a - sign(a) * t * 360
    if a < 0 then a = a + 360 end
    if type == 1 then --返回-180~180°内的角度
        if a > 180 then a = a - 360 end
        return a
    else --返回0~360°范围的角度
        return a
    end
end

---检测一个值是否处于上限和下限之间
---@param x number @要检测的值
---@param up number @上限（当然也能填下限）
---@param down number @下限（当然也能填上限）
---@param equal boolean @为false时使用大于/小于，否则使用大于等于/小于等于
function lib.IsIn(x, up, down, equal)
    if up < down then up, down = down, up end
    if equal == nil or equal then
        return x <= up and x >= down
    else
        return x < up and x > down
    end
end

---@alias viewmode 'world'|'ui'|'uv'

---from RT基础教程，坐标系转换
---@param x number @原x坐标
---@param y number @原y坐标
---@param from viewmode @原坐标系
---@param to viewmode @转换后坐标系
---@return number, number @转换后x，y坐标
function lib.PosTrans(x, y, from, to)
    ---检查输入合法性, 非必要
    if from ~= "world" and from ~= "ui" and from ~= "uv" then
        error 'Invalid viewmode.'
    end
    if to ~= "world" and to ~= "ui" and to ~= "uv" then
        error 'Invalid viewmode.'
    end
    ---无需转换
    if from == to then
        return x, y
    end
    ---转换至 ui 系
    if to == "ui" then
        if from == "world" then
            return WorldToUI(x, y)
        else -- from == "uv"
            return
                x / screen.hScale,
                screen.height - y / screen.vScale
        end
    end
    ---由 ui 系转换
    if from == "ui" then
        if to == "world" then
            local w = lstg.world
            return
                w.l + (w.r - w.l) * (x - w.scrl) / (w.r - w.scrl),
                w.b + (w.t - w.b) * (y - w.scrb) / (w.t - w.scrb)
        else -- to == "uv"
            return
                x * screen.hScale,
                (screen.height - y) * screen.vScale
        end
    end
    ---其他情况
    x, y = lib.PosTrans(x, y, from, "ui")
    return lib.PosTrans(x, y, "ui", to)
end

---检查坐标是否在矩形内
---@param x number @x坐标
---@param y number @y坐标
---@param l number @左边界
---@param r number @右边界
---@param b number @下边界
---@param t number @上边界
---@return boolean
---@overload fun(x:number, y:number, l:table):boolean
function lib.IsInRect(x, y, l, r, b, t)
    if type(l) == "table" then
        return x > l.x and x < (l.x + l.width) and y > (l.y - (l.height or l.width)) and y < l.y
    else
        return x > l and x < r and y > b and y < t
    end
end

---通过一个角度获取矩形边界对应坐标
---@param a number @角度
---@param w number @矩形宽度的一半
---@param h number @矩形高度的一半
---@return number, number @返回的边界坐标
function lib.GetRectPos(a, w, h)
    local isin = lib.IsIn
    local r = hypot(w, h)
    local angle = atan2(h, w)
    if isin(a, -angle, angle) then
        return w, r * sin(a)
    elseif isin(a, angle, angle + 90) then
        return r * cos(a), h
    elseif isin(a, angle + 90, 180) then
        --其他地方都好好的就这出了点问题
        --不知道原因是啥，但是暂且能用（就是这条边的密度会减半）
        return -w * 2, r * sin(a) * 2
    else
        return r * cos(a), -h
    end
end


---贝塞尔插值，由task.BezierMoveTo修改而来
---@param n number @总点数
---@param mode number @移动模式，参见Ltask.lua
---@param unpack_all boolean @是否使用坐标列格式的返回值
---@param x0 number @起始x坐标
---@param y0 number @起始y坐标
---@vararg number @控制点坐标
---@return table　@坐标列
function lib.BezierInterpolation(n, mode, unpack_all, x0, y0, ...)
    local arg = { ... }
    n = int(n)
    n = max(1, n)
    local count = (#arg) / 2
    local x = {}
    local y = {}
    local xlist = {}
    local ylist = {}
    local p = {}
    x[1] = x0
    y[1] = y0
    xlist[1] = x0
    ylist[1] = y0
    for i = 1, count do
        x[i + 1] = arg[i * 2 - 1]
        y[i + 1] = arg[i * 2]
    end
    local com_num = {}
    for i = 0, count do
        com_num[i + 1] = combinNum(i, count)
    end
    if mode == 1 then
        for s = 1 / n, 1 + 0.5 / n, 1 / n do
            s = s * s
            local _x, _y = 0, 0
            for j = 0, count do
                _x = _x + x[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ (j)
                _y = _y + y[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ (j)
            end
            table.insert(xlist, _x)
            table.insert(ylist, _y)
        end
    elseif mode == 2 then
        for s = 1 / n, 1 + 0.5 / n, 1 / n do
            s = s * 2 - s * s
            local _x, _y = 0, 0
            for j = 0, count do
                _x = _x + x[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ (j)
                _y = _y + y[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ (j)
            end
            table.insert(xlist, _x)
            table.insert(ylist, _y)
        end
    elseif mode == 3 then
        for s = 1 / n, 1 + 0.5 / n, 1 / n do
            if s < 0.5 then
                s = s * s * 2
            else
                s = -2 * s * s + 4 * s - 1
            end
            local _x, _y = 0, 0
            for j = 0, count do
                _x = _x + x[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ (j)
                _y = _y + y[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ (j)
            end
            table.insert(xlist, _x)
            table.insert(ylist, _y)
        end
    else
        for s = 1 / n, 1 + 0.5 / n, 1 / n do
            local _x, _y = 0, 0
            for j = 0, count do
                _x = _x + x[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ (j)
                _y = _y + y[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ (j)
            end
            table.insert(xlist, _x)
            table.insert(ylist, _y)
        end
    end
    for i = 1, n do
        p[2 * i - 1] = xlist[i]
        p[2 * i] = ylist[i]
    end
    if unpack_all then
        return p
    else
        local ret = {}
        local flag = true
        local t = {}
        for _, v in ipairs(p) do
            if flag then
                t[1] = v
            else
                t[2] = v
                table.insert(ret, t)
                t = {}
            end
            flag = not flag
        end
        return ret
    end
end

---各种形状拟合，默认返回点列（格式：{{x1,y1},{x2,y2},...}），如果unpack_all为true则返回坐标列（格式：{x1,y1,x2,y2,...}）
---以下函数是在sharp里用高级循环写的，所以很难看

---正多边形拟合
function lib.polygon(n, side, r, rot0, x0, y0, unpack_all)
    local p = ({})
    local rot0 = (rot0 or 0)
    local x0 = (x0 or 0)
    local y0 = (y0 or 0)
    local n = (int(n / side))
    local p0 = ({})
    local p1, p2
    do
        local i, _d_i = (1), (1)
        for _ = 1, side do
            local rot = (i * 360 / side)
            local x = (x0 + r * cos(rot + rot0))
            local y = (y0 + r * sin(rot + rot0))
            p0[i] = { x, y }
            i = i + _d_i
        end
    end
    do
        local i, _d_i = (1), (1)
        for _ = 1, side do
            if i == side then
                p1, p2 = p0[i], p0[1]
            else
                p1, p2 = p0[i], p0[i + 1]
            end
            do
                local j = (i - 1) * n + 1
                local _d_j = (1)
                local _beg_x = p1[1]
                local x = _beg_x
                local _end_x = p2[1]
                local _d_x = (_end_x - _beg_x) / (n - 1)
                local _beg_y = p1[2]
                local y = _beg_y
                local _end_y = p2[2]
                local _d_y = (_end_y - _beg_y) / (n - 1)
                for _ = 1, n do
                    p[j] = { x, y }
                    j = j + _d_j
                    x = x + _d_x
                    y = y + _d_y
                end
            end
            i = i + _d_i
        end
    end
    if unpack_all then
        local ret = {}
        for _, v in ipairs(p) do
            local v1, v2 = unpack(v)
            table.insert(ret, v1)
            table.insert(ret, v2)
        end
        return ret
    else
        return p
    end
end

---正多边形拟合（仅顶点）
function lib.polygon2(side, r, rot0, x0, y0, unpack_all)
    local p = ({})
    local rot0 = (rot0 or 0)
    local x0 = (x0 or 0)
    local y0 = (y0 or 0)
    if type(r) == 'table' then
        do
            local i, _d_i = (1), (1)
            for _ = 1, side do
                local rot = (i * 360 / side)
                local x = (x0 + r[i] * cos(rot + rot0))
                local y = (y0 + r[i] * sin(rot + rot0))
                p[i] = { x, y }
                i = i + _d_i
            end
        end
    else
        do
            local i, _d_i = (1), (1)
            for _ = 1, side do
                local rot = (i * 360 / side)
                local x = (x0 + r * cos(rot + rot0))
                local y = (y0 + r * sin(rot + rot0))
                p[i] = { x, y }
                i = i + _d_i
            end
        end
    end
    if unpack_all then
        local ret = {}
        for _, v in ipairs(p) do
            local v1, v2 = unpack(v)
            table.insert(ret, v1)
            table.insert(ret, v2)
        end
        return ret
    else
        return p
    end
end

---椭圆拟合
function lib.eclipse(n, a, b, rot0, x0, y0, unpack_all)
    local p = {}
    local b = (b or a)
    local rot0 = (rot0 or 0)
    local x0 = (x0 or 0)
    local y0 = (y0 or 0)
    do
        local i, _d_i = (1), (1)
        for _ = 1, n do
            local rot = (i * 360 / n)
            local r = (Dist(0, 0, a * cos(rot), b * sin(rot)))
            local a = (Angle(0, 0, a * cos(rot), b * sin(rot)))
            local x = (x0 + r * cos(a + rot0))
            local y = (y0 + r * sin(a + rot0))
            p[i] = { x, y }
            i = i + _d_i
        end
    end
    return p
end

---心形拟合
function lib.heart(n, a, rot0, x0, y0, k, b)
    local k = (k or 1.6) --b与a的比值，值越大心形椭圆部分越圆
    local b = (b or a * k)
    local rot0 = (rot0 or 0)
    local x0 = (x0 or 0)
    local y0 = (y0 or 0)
    local n = (int(n / 4))
    local p = ({})
    local a, b = 2 * a - sqrt(3) / 2 * b, b / 4 --传参的a和b是整个图形的，这里local的a和b是心形中椭圆部分的a和b
    do
        local i = 1
        local _d_i = (1)
        local _beg_x = 2 * sqrt(3) * b
        local x = _beg_x
        local _end_x = 0
        local _d_x = (_end_x - _beg_x) / (n)
        local _beg_y = 0
        local y = _beg_y
        local _end_y = 2 * b
        local _w_y = 0
        local _d_w_y = 1 / (n)
        for _ = 1, n do
            p[i] = { x, y }
            i = i + _d_i
            x = x + _d_x
            _w_y = _w_y + _d_w_y
            y = (_beg_y - _end_y) * (_w_y - 1) ^ 2 + _end_y
        end
    end
    do
        local i = n + 1
        local _d_i = (1)
        local _beg_rot = 90
        local rot = _beg_rot
        local _end_rot = 270
        local _d_rot = (_end_rot - _beg_rot) / (n)
        for _ = 1, n do
            p[i] = { a * cos(rot), b * sin(rot) + b }
            i = i + _d_i
            rot = rot + _d_rot
        end
    end
    do
        local i = 2 * n + 1
        local _d_i = (1)
        local _beg_rot = 90
        local rot = _beg_rot
        local _end_rot = 270
        local _d_rot = (_end_rot - _beg_rot) / (n)
        for _ = 1, n do
            p[i] = { a * cos(rot), b * sin(rot) - b }
            i = i + _d_i
            rot = rot + _d_rot
        end
    end
    do
        local i = 3 * n + 1
        local _d_i = (1)
        local _beg_x = 0
        local x = _beg_x
        local _end_x = 2 * sqrt(3) * b
        local _d_x = (_end_x - _beg_x) / (n - 1)
        local _beg_y = -2 * b
        local y = _beg_y
        local _end_y = 0
        local _w_y = 0
        local _d_w_y = 1 / (n - 1)
        for _ = 1, n do
            p[i] = { x, y }
            i = i + _d_i
            x = x + _d_x
            _w_y = _w_y + _d_w_y
            y = (_end_y - _beg_y) * _w_y ^ 2 + _beg_y
        end
    end
    do
        local i, _d_i = (1), (1)
        for _ = 1, 4 * n do
            local d = (Dist(0, 0, p[i][1], p[i][2]))
            local a = (Angle(0, 0, p[i][1], p[i][2]))
            p[i] = { x0 + d * cos(a + rot0), y0 + d * sin(a + rot0) }
            i = i + _d_i
        end
    end
    if unpack_all then
        local ret = {}
        for _, v in ipairs(p) do
            local v1, v2 = unpack(v)
            table.insert(ret, v1)
            table.insert(ret, v2)
        end
        return ret
    else
        return p
    end
end

---五角星形拟合
function lib.star(n, r1, rot0, x0, y0, r2, unpack_all)
    local r2 = (r2 or r1 * tan(30) / (tan(36) + tan(30)) / cos(36)) --这里的tan(30)实际上是1/2*cos(60)（恼
    local rot0 = (rot0 or 18)
    local x0 = (x0 or 0)
    local y0 = (y0 or 0)
    local p = ({})
    local p0 = ({})
    local p1 = ({})
    local p2 = ({})
    local n = (int(n / 10))
    if rot0 ~= 18 then rot0 = rot0 + 18 end --让图形实际角度与直观感觉相符
    do
        local i = 1
        local _d_i = (1)
        local _beg_rot = 0
        local rot = _beg_rot
        local _end_rot = 360
        local _d_rot = (_end_rot - _beg_rot) / (5)
        for _ = 1, 5 do
            p1[i] = { r1 * cos(rot), r1 * sin(rot) }
            p2[i] = { r2 * cos(rot + 36), r2 * sin(rot + 36) }
            i = i + _d_i
            rot = rot + _d_rot
        end
    end
    do
        local i, _d_i = (1), (1)
        for _ = 1, 10 do
            if i % 2 == 1 then
                p0[i] = p1[int(i / 2) + 1]
            else
                p0[i] = p2[i / 2]
            end
            i = i + _d_i
        end
    end
    do
        local i, _d_i = (1), (1)
        for _ = 1, 10 do
            if i == 10 then
                p1, p2 = p0[i], p0[1]
            else
                p1, p2 = p0[i], p0[i + 1]
            end
            do
                local j = (i - 1) * n + 1
                local _d_j = (1)
                local _beg_x = p1[1]
                local x = _beg_x
                local _end_x = p2[1]
                local _d_x = (_end_x - _beg_x) / (n - 1)
                local _beg_y = p1[2]
                local y = _beg_y
                local _end_y = p2[2]
                local _d_y = (_end_y - _beg_y) / (n - 1)
                for _ = 1, n do
                    p[j] = { x, y }
                    j = j + _d_j
                    x = x + _d_x
                    y = y + _d_y
                end
            end
            i = i + _d_i
        end
    end
    do
        local i, _d_i = (1), (1)
        for _ = 1, n * 10 do
            local d = (Dist(0, 0, p[i][1], p[i][2]))
            local a = (Angle(0, 0, p[i][1], p[i][2]))
            p[i] = { x0 + d * cos(a + rot0), y0 + d * sin(a + rot0) }
            i = i + _d_i
        end
    end
    if unpack_all then
        local ret = {}
        for _, v in ipairs(p) do
            local v1, v2 = unpack(v)
            table.insert(ret, v1)
            table.insert(ret, v2)
        end
        return ret
    else
        return p
    end
end

---废弃的五角星形拟合，似乎会产生两层叠加效果
function lib.star2(n, r1, rot0, x0, y0, r2, unpack_all)
    local p = ({})
    local rot0 = (rot0 or 0)
    local x0 = (x0 or 0)
    local y0 = (y0 or 0)
    local r2 = (r2 or r1 * tan(30) / (tan(36) + tan(30)) / cos(36))
    local n = (int(n / 20))
    do
        local i = 1
        local _d_i = (1)
        local _beg_a = 0
        local a = _beg_a
        local _end_a = 360
        local _d_a = (_end_a - _beg_a) / (10)
        for _ = 1, 10 do
            do
                local j = 2 * n * (i - 1) + 1
                local _d_j = (1)
                local _beg_r = r2
                local r = _beg_r
                local _end_r = r1
                local _d_r = (_end_r - _beg_r) / (n)
                local _beg_aa = a
                local aa = _beg_aa
                local _end_aa = a + 54
                local _d_aa = (_end_aa - _beg_aa) / (n - 1)
                for _ = 1, n do
                    p[j] = { r * cos(aa), r * sin(aa) }
                    j = j + _d_j
                    r = r + _d_r
                    aa = aa + _d_aa
                end
            end
            do
                local j = 2 * n * (i - 1) + n + 1
                local _d_j = (1)
                local _beg_r = r1
                local r = _beg_r
                local _end_r = r2
                local _d_r = (_end_r - _beg_r) / (n - 1)
                local _beg_aa = a + 54
                local aa = _beg_aa
                local _end_aa = a + 108
                local _d_aa = (_end_aa - _beg_aa) / (n - 1)
                for _ = 1, n do
                    p[j] = { r * cos(aa), r * sin(aa) }
                    j = j + _d_j
                    r = r + _d_r
                    aa = aa + _d_aa
                end
            end
            i = i + _d_i
            a = a + _d_a
        end
    end
    do
        local i, _d_i = (1), (1)
        for _ = 1, 20 * n do
            local d = (Dist(0, 0, p[i][1], p[i][2]))
            local a = (Angle(0, 0, p[i][1], p[i][2]))
            p[i] = { x0 + d * cos(a + rot0), y0 + d * sin(a + rot0) }
            i = i + _d_i
        end
    end
    if unpack_all then
        local ret = {}
        for _, v in ipairs(p) do
            local v1, v2 = unpack(v)
            table.insert(ret, v1)
            table.insert(ret, v2)
        end
        return ret
    else
        return p
    end
end
