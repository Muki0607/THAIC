---=====================================
---THAIC 3D v1.00a
---东方梦摇篮3D v1.00a
---=====================================

---版本更新记录
---v1.00a
---初始版本

--目前并没有什么用的一个库，大部分函数还没测试过
---@class aic.view3d @东方梦摇篮3d
---@deprecated
aic.view3d = {}
local lib = aic.view3d

--非常申必的一个角（当以45°为辐角，这个角为仰角时才有x=y=z）
_3DANGLE = atan(SQRT2_2)

---注意：lstg采用万恶的左手系，使用时请注意

---直角坐标系转极坐标系
---@param x number @x坐标
---@param y number @y坐标
---@return number, number @半径，辐角
function lib.Pol(x, y)
    return hypot(x, y), atan2(y, x)
end

---直角坐标系转球坐标系
---@param x number @x坐标
---@param y number @y坐标
---@param z number @z坐标
---@return number, number, number @半径，辐角，仰角
function lib.Sph(x, y, z)
    return hypot3D(x, y, z), atan2(y, x), atan2(hypot(x, y), z)
end

---极坐标系/球坐标系转直角坐标系
---@param r number @半径
---@param th number @辐角
---@param ph number @仰角
---@return number, number, number @x坐标，y坐标，z坐标
---@overload fun(r:number, th:number):number, number
function lib.Rec(r, th, ph)
    if ph then
        return r * cos(ph) * cos(th), r * cos(ph) * sin(th), r * sin(ph)
    else
        return r * cos(th), r * sin(th)
    end
end

---@获得(x, y, z)的模
---@param x number @x坐标
---@param y number @y坐标
---@param z number @z坐标
---@return number @向量的模
function lib.hypot(x, y, z)
    return sqrt(x ^ 2 + y ^ 2 + z ^ 2)
end

---@计算空间向量的模
---@param x1 number @向量起点x坐标
---@param y1 number @向量起点y坐标
---@param z1 number @向量起点z坐标
---@param x2 number @向量终点x坐标
---@param y2 number @向量终点y坐标
---@param z2 number @向量终点z坐标
---@return number @向量的模
---@overload fun(x1:lstg.GameObject|table, y1:lstg.GameObject|table):number
---@overload fun(x1:lstg.GameObject|table, y1:number, z1:number, x2:number):number
---@overload fun(x1:number, y1:number, z1:number, x2:lstg.GameObject|table):number
function lib.Dist(x1, y1, z1, x2, y2, z2)
    if type(x1) == 'table' and type(y1) == 'table' then
        return Dist3D(x1.x, x1.y, x1.z, y1.x, y1.y, y1.z)
    elseif type(x1) == 'table' and type(y1) == 'number' and type(z1) == 'number' and type(x2) == 'number' then
        return Dist3D(x1.x, x1.y, x1.z, y1, z1, x2)
    elseif type(x1) == 'number' and type(y1) == 'number' and type(z1) == 'number' and type(x2) == 'table' then
        return Dist3D(x1, y1, z1, x2.x, x2.y, x2.z)
    elseif type(x1) == 'number' and type(y1) == 'number' and type(z1) == 'number' and type(x2) == 'number' and type(y2) == 'number' and type(z2) == 'number' then
        return hypot3D(x1 - x2, y1 - y2, z1 - z2)
    else
        error('invalid arguement.')
    end
end


---@计算空间向量的朝向，与Angle一样返回-180°~180°范围内的角
---@param x1 number @向量起点x坐标
---@param y1 number @向量起点y坐标
---@param z1 number @向量起点z坐标
---@param x2 number @向量终点x坐标
---@param y2 number @向量终点y坐标
---@param z2 number @向量终点z坐标
---@return number, number @向量的辐角，向量的仰角
---@overload fun(x1:lstg.GameObject|table, y1:lstg.GameObject|table):number, number
---@overload fun(x1:lstg.GameObject|table, y1:number, z1:number, x2:number):number, number
---@overload fun(x1:number, y1:number, z1:number, x2:lstg.GameObject|table):number, number
function lib.Angle(x1, y1, z1, x2, y2, z2)
    local th, ph
    if type(x1) == 'table' and type(y1) == 'table' then
        return Angle3D(x1.x, x1.y, x1.z, y1.x, y1.y, y1.z)
    elseif type(x1) == 'table' and type(y1) == 'number' and type(z1) == 'number' and type(x2) == 'number' and x1.x and x1.y and x1.z then
        return Angle3D(x1.x, x1.y, x1.z, y1, z1, x2)
    elseif type(x1) == 'number' and type(y1) == 'number' and type(z1) == 'number' and type(x2) == 'table' and x2.x and x2.y and x2.z then
        return Angle3D(x1, y1, z1, x2.x, x2.y, x2.z)
    elseif type(x1) == 'number' and type(y1) == 'number' and type(z1) == 'number' and type(x2) == 'number' and type(y2) == 'number' and type(z2) == 'number' then
        th = Angle(x1, y1, x2, y2)
        ph = atan2(abs(z1 - z2), Dist(x1, y1, x2, y2))
        ph = aic.math.AngleFormat(ph, 1)
        return th, ph
    else
        error('invalid arguement.')
    end
end

--实际上这才是我们熟悉的2DAngle……不过基本用不上
---@计算空间中两点与原点构成的角的大小
---@param x1 number @第一个点的x坐标
---@param y1 number @第一个点的y坐标
---@param z1 number @第一个点的z坐标
---@param x2 number @第二个点的x坐标
---@param y2 number @第二个点的y坐标
---@param z2 number @第二个点的z坐标
---@return number @两点与原点构成的角的大小
---@overload fun(x1:lstg.GameObject|table, y1:lstg.GameObject|table):number, number
---@overload fun(x1:lstg.GameObject|table, y1:number, z1:number, x2:number):number, number
---@overload fun(x1:number, y1:number, z1:number, x2:table):number, number
function lib.Angle2(x1, y1, z1, x2, y2, z2)
    if type(x1) == 'table' and type(y1) == 'table' then
        return lib.Angle2(x1.x, x1.y, x1.z, y1.x, y1.y, y1.z)
    elseif type(x1) == 'table' and type(y1) == 'number' and type(z1) == 'number' and type(x2) == 'number' and x1.x and x1.y and x1.z then
        return lib.Angle2(x1.x, x1.y, x1.z, y1, z1, x2)
    elseif type(x1) == 'number' and type(y1) == 'number' and type(z1) == 'number' and type(x2) == 'table' and x2.x and x2.y and x2.z then
        return lib.Angle2(x1, y1, z1, x2.x, x2.y, x2.z)
    elseif type(x1) == 'number' and type(y1) == 'number' and type(z1) == 'number' and type(x2) == 'number' and type(y2) == 'number' and type(z2) == 'number' then
        return aic.math.AngleFormat(acos((x1 * x2 + y1 * y2 + z1 * z2) / hypot3D(x1, y1, z1) - hypot3D(x2, y2, z2)), 1)
    else
        error('invalid arguement.')
    end
end

---获取游戏对象的速度
---@param unit lstg.GameObject|table @要获取的对象
function lib.GetV(unit)
    if unit.vx and unit.vy and unit.vz then
        return lib.Sph(unit.vx, unit.vy, unit.vz)
    else
        error('invalid lstg object.')
    end
end

---设置游戏对象的速度
---@param unit lstg.GameObject|table @要设置的对象
---@param v number
---@param a number
---@param updaterot boolean @如果该参数为true，则同时设置对象的rot
function lib.SetV(unit, v, th, ph, updaterot)
    unit.x, unit.y, unit.z = lib.Rec(v, th, ph)
    if updaterot then unit.rot, unit.phi = th, ph end
end

---检查指定对象是否在指定的长方体区域内
---@param unit lstg.GameObject|table @要检查的对象
---@param x1 number @上限的x坐标（也可以是下限）
---@param x2 number @下限的x坐标（也可以是上限）
---@param y1 number @上限的y坐标（也可以是下限）
---@param y2 number @下限的y坐标（也可以是上限）
---@param z1 number @上限的z坐标（也可以是下限）
---@param z2 number @下限的z坐标（也可以是上限）
---@return boolean @指定对象是否在指定的长方体区域内
function lib.BoxCheck(unit, x1, x2, y1, y2, z1, z2)
    if unit.x and unit.y and unit.z and type(x1) == 'number' and type(y1) == 'number' and type(z1) == 'number' and type(x2) == 'number' and type(y2) == 'number' and type(z2) == 'number' then
        local IsIn = aic.math.IsIn
        return IsIn(unit.x, x1, x2) and IsIn(unit.y, y1, y2) and IsIn(unit.z, z1, z2)
    else
        error('invalid arguement.')
    end
end

---检查空间中两个对象是否发生碰撞
---@param unit1 lstg.GameObject|table @要检查的对象1
---@param unit2 lstg.GameObject|table @要检查的对象2
---@return boolean @空间中两个对象是否发生碰撞
function lib.ColliCheck(unit1, unit2)
    if unit1.colli and unit2.colli and unit1.a and unit1.b and unit1.c and unit2.a and unit2.b and unit2.c and (unit1.a ~= 0 or unit1.b ~= 0 or unit1.c ~= 0) and (unit2.a ~= 0 or unit2.b ~= 0 or unit2.c ~= 0) then
        local r1 = hypot3D(unit1.a, unit1.b, unit1.c)
        local r2 = hypot3D(unit2.a, unit2.b, unit2.c)
        return lib.Dist(unit1, unit2) < r1 + r2
    else
        return false
    end
end

---【禁止在协同程序中调用此方法】  
---对两个碰撞组的对象进行碰撞检测  
---如果发生碰撞则触发groupidA内的对象的colli回调函数，并传入groupidB内的对象作为参数
function lib.CollisionCheck(groupidA, groupidB)
    for _, unit1 in ObjList(groupidA) do
        for _, unit2 in ObjList(groupidB) do
            if ColliCheck3D(unit1, unit2) and unit1.class.colli then
                unit1.class.colli(unit1, unit2)
            end
        end
    end
end

lib.object = Class(object)

function lib.object:init()
    object.init(self)
    self.model = 'ball'
    self.z = 0
    self.vz = 0
    self.az = 0
    self.dz = 0
    self.lastz = 0
    self.c = 0
    self.phi = 0
    self.omiga2 = 0
    self.auto3D = true
    local mt = getmetatable(self)
    local old = mt.__newindex
    local function newindex(t, k, v)
        if k == 'dz' then
            error('')
        elseif k == '_speed' then
            local _, th, ph = lib.Sph(t.vx, t.vy, t.vz)
            t._speed = v
            t.vx, t.vy, t.vz = lib.Rec(v, th, ph)
        end
        old(t, k, v)
    end
    mt.__newindex = newindex()
end

function lib.UpdateObj(o)
end

function lib.Render2D(func, th, ...)
    if not CheckRes('tex', 'rt:Render2D') then
        CreateRenderTarget('rt:Render2D')
    end
    PushRenderTarget('rt:Render2D')
    RenderClear(Color(0, 0, 0, 0))
    func(...)
    PopRenderTarget()
    local w, h = GetTextureSize('rt:Render2D')
    local x1, y1 = rotate(-w / 2, h / 2, th)
    local x2, y2 = rotate(w / 2, h / 2, th)
    local x3, y3 = rotate(w / 2, -h / 2, th)
    local x4, y4 = rotate(-w / 2, -h / 2, th)
    local white = color()
    RenderTexture('rt:Render2D', '',
        { x1, y1, 0.5, 0, 0, white },
        { x2, y2, 0.5, w, 0, white },
        { x3, y3, 0.5, w, h, white },
        { x4, y4, 0.5, 0, h, white }
    )
end

function lib.Render3D(func, ph, ...)
    if not CheckRes('tex', 'rt:Render3D') then
        CreateRenderTarget('rt:Render3D')
    end
    PushRenderTarget('rt:Render3D')
    RenderClear(Color(0, 0, 0, 0))
    func(...)
    PopRenderTarget()
    local w, h = GetTextureSize('rt:Render3D')
    local _, z1 = rotate(hypot(w / 2, h / 2), 0.5, ph)
    local z2 = -z1
    local white = color()
    RenderTexture('rt:Render3D', '',
        { -w / 2, h / 2, z1, 0, 0, white },
        { w / 2, h / 2, z1, w, 0, white },
        { w / 2, -h / 2, z2, w, h, white },
        { -w / 2, -h / 2, z2, 0, h, white }
    )
end

function lib.RenderAuto3D(func, x, y, z, ...)
    local eye = lstg.view3d.eye
    local th, ph = Angle3D(x, y, z, eye[1], eye[2], eye[3])
    Render3D(Render2D, -ph, func, th, ...)
end
