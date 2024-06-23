---THAIC Arranged
-- 用于简化 rendertarget 的渲染
-- 请不要在未经修改情况下直接使用 Patch 节点导入该文件
-- 发现异常可在交流群反馈

---@class RTClass
local RTClass = {}
RenderTargetClass = RTClass -- 全局表

---@class RTClass.private
local private = {}

--------------------------------------------------
--#region 公有函数 / 变量

---设置顶点坐标时的坐标系
---@alias RTClass.ViewMode nil | "" | "world" | "ui" | "uv" | "uv1" 
--- nil     @同 ""
--- ""      @默认, 由具体环境决定坐标系
--- "world" @在 world 坐标系下设置, 自动转换
--- "ui"    @在 ui 坐标系下设置, 自动转换
--- "uv"    @(不用于设置 XY) 在纹理 uv 坐标系下设置
--- "uv1"   @(不用于设置 XY) 归一化的 uv 坐标系, 坐标值 0 ~ 1

---@class RTClass.onlyUI : number
RTClass.onlyUI = 1
---@class RTClass.notScreen : number
RTClass.notScreen = 2

---创建实例
---@param rtname string @rendertarget 资源名
---@param settings nil | RTClass.onlyUI | RTClass.notScreen @特殊设置
--- nil                @基本上你只需要这个
--- RTClass.onlyUI     @仅显示 UI 部分, 版面涂黑
--- RTClass.notScreen  @取消对 scale 的自动修正
---@return RTClass
function RTClass.Create(rtname, settings)
    ---@class RTClass
    local self = {}
    ---@class RTClass.data
    self._data = private.DataInit(rtname, settings)
    return setmetatable(self, RTClass)
end

---设置纹理
---@param rtname string
function RTClass:texture(rtname)
    self._data.rtName = rtname
end

---设置混合模式
---@param blend lstg.BlendMode | nil
function RTClass:blend(blend)
    self._data.blend = blend or ""
end

---设置颜色
---@param color1 lstg.Color
---@param color2 lstg.Color
---@param color3 lstg.Color
---@param color4 lstg.Color
---@overload fun(self)                   
---@overload fun(self, color:lstg.Color) 
function RTClass:color(color1, color2, color3, color4)
    local t = self._data.textab
    if color1 then
        if color2 then
            t[1][6] = color1
            t[2][6] = color2
            t[3][6] = color3
            t[4][6] = color4
        else
            for i = 1, 4 do
                t[i][6] = color1
            end
        end
    else
        for i = 1, 4 do
            t[i][6] = private.white
        end
    end
end

--------------------------------------------------

---设置顶点 XY 坐标，仿 Render() 参数
---@param viewmode RTClass.ViewMode
---@param x number
---@param y number
---@param rot number | nil
---@param hscale number | nil @照 screen.hScale 自动修正 hscale
---@param vscale number | nil @照 screen.vScale 自动修正 vscale
function RTClass:xy(viewmode, x, y, rot, hscale, vscale)
    private.SetXYZ(self, viewmode, true)

    local data = self._data
    data.x, data.y = x, y
    data.rot = rot or 0
    data.hscale = hscale or 1
    data.vscale = vscale or data.hscale
end

---设置顶点 XY 坐标，仿 RenderRect() 参数
---@param viewmode RTClass.ViewMode
---@param left number
---@param right number
---@param bottom number
---@param top number
---@param rot number | nil @指定方框的旋转
function RTClass:xyRect(viewmode, left, right, bottom, top, rot)
    if not rot then
        private.SetXYZ(self, viewmode, false,
            left, top, 0.5,
            right, top, 0.5,
            right, bottom, 0.5,
            left, bottom, 0.5
        )
    else
        local x, y = (left + right) / 2, (bottom + top) / 2
        local dx1, dy1 = private.Rotate(left - x, top - y, rot)
        local dx2, dy2 = private.Rotate(right - x, top - y, rot)
        private.SetXYZ(self, viewmode, false,
            x + dx1, y + dy1, 0.5,
            x + dx2, y + dy2, 0.5,
            x - dx1, y - dy1, 0.5,
            x - dx2, y - dy2, 0.5
        )
    end
end

---设置顶点 XY 坐标，仿 Render4V() 参数
---@param viewmode RTClass.ViewMode
function RTClass:xy4V(viewmode, x1, y1, x2, y2, x3, y3, x4, y4)
    private.SetXYZ(self, viewmode, false,
        x1, y1, 0.5,
        x2, y2, 0.5,
        x3, y3, 0.5,
        x4, y4, 0.5
    )
end

---设置顶点 XYZ 坐标
function RTClass:xyz(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
    private.SetXYZ(self, nil, false,
        x1, y1, z1,
        x2, y2, z2,
        x3, y3, z3,
        x4, y4, z4
    )
end

--------------------------------------------------

---设置顶点 UV 坐标，仿 Render() 参数
---@param viewmode RTClass.ViewMode
---@param u number
---@param v number
---@param rot number | nil
---@param a number
---@param b number | nil
function RTClass:uv(viewmode, u, v, rot, a, b)
    rot = rot or 0
    b = b or a
    local du1, dv1 = private.Rotate(-a, b, rot)
    local du2, dv2 = private.Rotate(a, b, rot)

    private.SetUV(self, viewmode,
        u + du1, v + dv1,
        u + du2, v + dv2,
        u - du1, v - dv1,
        u - du2, v - dv2
    )
end

---设置顶点 UV 坐标，仿 RenderRect() 参数
---@param viewmode RTClass.ViewMode
---@param left number
---@param right number
---@param bottom number
---@param top number
---@param rot number | nil @指定方框的旋转
function RTClass:uvRect(viewmode, left, right, bottom, top, rot)
    if rot then
        RTClass.uv(self, viewmode,
            (left + right) / 2, (bottom + top) / 2, rot,
            (right - left) / 2, (top - bottom) / 2
        )
    else
        private.SetUV(self, viewmode,
            left, top,
            right, top,
            right, bottom,
            left, bottom
        )
    end
end

---设置顶点 UV 坐标，仿 Render4V() 参数
---@param viewmode RTClass.ViewMode
function RTClass:uv4V(viewmode, u1, v1, u2, v2, u3, v3, u4, v4)
    private.SetUV(self, viewmode, u1, v1, u2, v2, u3, v3, u4, v4)
end

--------------------------------------------------

---设置纹理中心点 (基本不用)
---@param viewmode RTClass.ViewMode
---@param u number
---@param v number
function RTClass:center(viewmode, u, v)
    local data = self._data
    data.u, data.v = private.UVTrans(u, v, viewmode, data.rtName)
    private.SetInvalidCenter(self)
end

--------------------------------------------------

---执行渲染操作，手动调用
function RTClass:render()
    local data = self._data
    local tab = data.textab

    -- default render
    if data.onlyUI or private.IsValidXY(self) then
        private.DefaultRender(self)
        return
    end

    -- default UV
    if private.IsValidUV(self) then
        local texw, texh = GetTextureSize(data.rtName)
        tab[1][4], tab[1][5] = 0000, 0000
        tab[2][4], tab[2][5] = texw, 0000
        tab[3][4], tab[3][5] = texw, texh
        tab[4][4], tab[4][5] = 0000, texh
    end

    -- setmode obj
    if data.XYOBJ then
        private.SetXYModeObj(self)
    end

    -- tmpXY to XY
    local viewmode = data.XYVIEWMODE
    for i = 1, 4 do
        tab[i][1], tab[i][2] = private.XYTrans(
            data.tmpX[i], data.tmpY[i], viewmode
        )
    end

    -- render
    RenderTexture(data.rtName, data.blend,
        tab[1], tab[2], tab[3], tab[4]
    )
end

--#endregion

--------------------------------------------------
--#region 私有函数 / 变量

private.white = Color(255, 255, 255, 255)

RTClass.__index = RTClass

---set XYZ, general method
---@param self RTClass
---@param viewmode RTClass.ViewMode
---@param XYOBJ boolean
---@param ... number
function private.SetXYZ(self, viewmode, XYOBJ, ...)
    local data = self._data
    local tab = data.textab
    local pos = { ... }

    data.XYOBJ = XYOBJ
    data.XYVIEWMODE = viewmode or ""
    private.SetInvalidXY(self)

    if XYOBJ then
        for i = 1, 4 do
            tab[i][3] = 0.5
        end
    else
        for i = 1, 4 do
            data.tmpX[i], data.tmpY[i], tab[i][3]
            = pos[i * 3 - 2], pos[i * 3 - 1], pos[i * 3]
        end
    end
end

---set UV, general method
---@param self RTClass
---@param viewmode RTClass.ViewMode
---@param ... number
function private.SetUV(self, viewmode, ...)
    private.SetInvalidUV(self)

    local data = self._data
    local tab = data.textab
    local pos = { ... }
    for i = 1, 4 do
        tab[i][4], tab[i][5] = private.UVTrans(
            pos[i * 2 - 1], pos[i * 2], viewmode, data.rtName
        )
    end
end

---set XY is valid
---@param self RTClass
---@return boolean
function private.IsValidXY(self)
    return not self._data.SETXY
end

---set UV is valid
---@param self RTClass
---@return boolean
function private.IsValidUV(self)
    return not self._data.SETUV
end

---set center is valid
---@param self RTClass
---@return boolean
function private.IsValidCenter(self)
    return not self._data.SETCENTER
end

---set invalid set XY
---@param self RTClass
function private.SetInvalidXY(self)
    self._data.SETXY = true
end

---set invalid set UV
---@param self RTClass
function private.SetInvalidUV(self)
    self._data.SETUV = true
end

---set invalid set center
---@param self RTClass
function private.SetInvalidCenter(self)
    self._data.SETCENTER = true
end

---self.data initialize
---@param rtname string
---@param settings RTClass.onlyUI | RTClass.notScreen | nil
---@return RTClass.data
function private.DataInit(rtname, settings)
    ---@class RTClass.data
    local data = {}

    -- settings
    data.onlyUI = (settings == RTClass.onlyUI)
    data.notScreen = (settings == RTClass.notScreen)

    -- rtName
    data.rtName = rtname

    -- blend mode
    data.blend = ""

    -- RenderTexture table
    data.textab = {
        { 0, 0, 0.5, 0, 0, private.white },
        { 0, 0, 0.5, 0, 0, private.white },
        { 0, 0, 0.5, 0, 0, private.white },
        { 0, 0, 0.5, 0, 0, private.white },
    }

    -- tmp x & y
    data.tmpX = { 0, 0, 0, 0 }
    data.tmpY = { 0, 0, 0, 0 }

    -- setmode obj
    data.x, data.y = 0, 0
    data.u, data.v = 0, 0
    data.rot = 0
    data.hscale, data.vscale = 1, 1
    data.hscale0, data.vscale0 = 1, 1
    private.SetScale0(data)

    -- state
    data.XYOBJ = false
    data.SETXY = false
    data.SETUV = false
    data.SETCENTER = false
    data.XYVIEWMODE = ""

    return data
end

---set hscale0 & vscale0
---@param data RTClass.data
function private.SetScale0(data)
    if not data.notScreen then
        data.hscale0 = screen.hScale
        data.vscale0 = screen.vScale
    end
end

---rotate 2d
---@param x number
---@param y number
---@param a number
function private.Rotate(x, y, a)
    return x * cos(a) - y * sin(a), x * sin(a) + y * cos(a)
end

---XY transform
---@param x number
---@param y number
---@param viewmode RTClass.ViewMode
---@return number, number
function private.XYTrans(x, y, viewmode)
    if viewmode == "ui" and lstg.viewmode == 'world' then
        -- UI to World
        local w = lstg.world
        return
            w.l + (w.r - w.l) * (x - w.scrl) / (w.scrr - w.scrl),
            w.b + (w.t - w.b) * (y - w.scrb) / (w.scrt - w.scrb)
    elseif viewmode == "world" and lstg.viewmode == 'ui' then
        -- World to UI
        local w = lstg.world
        return
            w.scrl + (w.scrr - w.scrl) * (x - w.l) / (w.r - w.l),
            w.scrb + (w.scrt - w.scrb) * (y - w.b) / (w.t - w.b)
    else
        return x, y
    end
end

---UV trans
---@param x number
---@param y number
---@param viewmode RTClass.ViewMode
---@param rtName string
---@param isVector boolean | nil
---@return number, number
function private.UVTrans(x, y, viewmode, rtName, isVector)
    local texw, texh = GetTextureSize(rtName)
    if viewmode == "uv1" then
        return
            x * texw,
            y * texh
    elseif viewmode == "ui" then
        local scrw, scrh = screen.width, screen.height
        if isVector then
            return
                x * texw / scrw,
                -y * texh / scrh
        else
            return
                x * texw / scrw,
                (scrh - y) * texh / scrh
        end
    elseif viewmode == "world" then
        local scrw, scrh = screen.width, screen.height
        if isVector then
            return
                x * texw / scrw,
                -y * texh / scrh
        else
            x, y = WorldToUI(x, y)
            return
                x * texw / scrw,
                (scrh - y) * texh / scrh
        end
    else
        return x, y
    end
end

local img_black = 'IMG:BLACK:8180'
--CopyImage(img_black, 'white')
LoadImageFromFile('AiC_white', 'THlib/misc/Muki_AiC_white.png')
CopyImage(img_black, 'AiC_white')
SetImageState(img_black, '', Color(255, 0, 0, 0))

---default render function
---@param self RTClass
function private.DefaultRender(self)
    local data = self._data
    local sw, sh = screen.width, screen.height
    local tw, th = GetTextureSize(data.rtName)
    local viewmode = lstg.viewmode

    if viewmode ~= "ui" then SetViewMode("ui") end
    RenderTexture(data.rtName, data.blend,
        { 00, sh, 0.5, 00, 00, data.textab[1][6] },
        { sw, sh, 0.5, tw, 00, data.textab[2][6] },
        { sw, 00, 0.5, tw, th, data.textab[3][6] },
        { 00, 00, 0.5, 00, th, data.textab[4][6] }
    )

    if data.onlyUI then
        local w = lstg.world
        RenderRect(img_black, w.scrl, w.scrr, w.scrb, w.scrt)
    end
    if viewmode ~= "ui" then SetViewMode(viewmode) end
end

---set XY if setmode is obj
---@param self RTClass
function private.SetXYModeObj(self)
    local data = self._data
    local tab = data.textab

    local u, v = {}, {}
    for i = 1, 4 do
        u[i], v[i] = tab[i][4], tab[i][5]
    end
    if private.IsValidCenter(self) then
        data.u = (u[1] + u[2] + u[3] + u[4]) / 4
        data.v = (v[1] + v[2] + v[3] + v[4]) / 4
    end

    for i = 1, 4 do
        u[i] = u[i] - data.u
        v[i] = data.v - v[i]
        u[i], v[i] = private.Rotate(
            u[i] * data.hscale / data.hscale0,
            v[i] * data.vscale / data.vscale0,
            data.rot
        )
        data.tmpX[i] = data.x + u[i]
        data.tmpY[i] = data.y + v[i]
    end
end

--#endregion

--------------------------------------------------
return RTClass
