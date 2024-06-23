---=====================================
---THAIC UI v1.00a
---东方梦摇篮UI v1.00a
---=====================================

---版本更新记录
---v1.00a
---初始版本

---@class aic.ui @东方梦摇篮UI
aic.ui = {}
local lib = aic.ui

COLOR_BLACK = 17
COLOR_WHITE = 18
---lstg默认弹型颜色对应Color，增加了常用的黑色与白色
lib.Color = {
    Color(255, 140, 0, 0), Color(255, 255, 0, 0), Color(255, 70, 0, 140), Color(255, 255, 0, 255), 
    Color(255, 0, 0, 140), Color(255, 0, 0, 255), Color(255, 0, 255, 255), Color(255, 0, 178, 133), 
    Color(255, 0, 255, 0), Color(255, 35, 140, 0), Color(255, 255, 255, 0), Color(255, 166, 255, 77), 
    Color(255, 255, 128, 0), Color(255, 255, 255, 115), Color(255, 102, 102, 102), Color(255, 34, 34, 34), 
    Color(255, 0, 0, 0), Color(255, 255, 255, 255)
}

---获取lstg默认弹型颜色对应Color
---@param color number @颜色编号
---@param alpha number @透明度
---@overload fun(color:number):lstg.Color
---@return lstg.Color
function lib.color(color, alpha)
    color = min(max((color or 18), 1), 18)
    alpha = min(max((alpha or 255), 0), 255)
    local co = lib.Color[color]
    local a, r, g, b = co:ARGB()
    return Color(alpha, r, g, b)
end

function lib.RenderRT(rtname, x, y, rot, hscale, vscale)
    x = x or screen.width / 2
    y = y or screen.height / 2
    hscale = hscale or 1
    vscale = vscale or hscale
    local self = RenderTargetClass.Create(rtname)
    local w, h = GetTextureSize(rtname)
    local sw, sh = screen.width, screen.height
    self:uv('uv', w / 2, h / 2, 0, w / 2, h / 2)
    self:xy('ui', x, y, rot, hscale, vscale)--不要问为啥，我也想知道为啥
    self:render()
end

function lib.RenderRTRect(rtname, l, r, b, t, rot)
    local self = RenderTargetClass.Create(rtname)
    local w, h = GetTextureSize(rtname)
    local sw, sh = screen.width, screen.height
    self:uvRect('uv', 0, w, h, 0, 0)
    self:xyRect('ui', l, r, b, t, rot)
    self:render()
end

--[[
---简化的RenderTarget渲染,已用RT扩展代替
---@param rendertarget string @rendertarget
---@param x1 number
---@param x2 number
---@param y1 number
---@param y2 number
---@deprecated_AiC
function lib.RenderRT(rendertarget, x1, x2, y1, y2)
    local w, h = GetTextureSize(rendertarget)
    local white = color()
    x1 = x1 or 0
    x2 = x2 or w
    y1 = y1 or 0
    y2 = y2 or h
    local viewmode = lstg.viewmode
    SetViewMode('ui')
    RenderTexture(rendertarget, '',
        { x1, y2, 0.5, 0, 0, white },
        { x2, y2, 0.5, w, 0, white },
        { x2, y1, 0.5, w, h, white },
        { x1, y1, 0.5, 0, h, white }
    )
    SetViewMode(viewmode)
end
--]]

---@alias align 'left' | 'center' | 'right' | 'top' | 'vcenter' | 'bottom' | 'wordbreak' | 'singleline' | 'expantextabs' | 'noclip' | 'calcrect' | 'rtlreading' | 'paragraph' | 'centerpoint'

---通用文字渲染，带描边
---
---'paragraph'等效于同时取'left'、'top'和'wordbreak'
---
---'centerpoint' 等效于同时取'center'、'vcenter'和'noclip'
---@param font string @字体
---@param text string @渲染文字
---@param x number @x坐标
---@param y number @y坐标
---@param s number @缩放比例
---@param co1 lstg.Color @文字颜色
---@param co2 lstg.Color @描边颜色
---@vararg align @对齐方式
function lib.DrawText(font, text, x, y, s, co1, co2, ...)
    font = font or "main_font_zh2"
    s = s or 1
    co1 = co1 or Color(255, 255, 255, 255)
    local alpha = co1:ARGB()
    co2 = co2 or Color(alpha, 0, 0, 0)
    local _x, _y
    if CheckRes('fnt', font) then
        SetFontState(font, '', co2)
        for i = 0, 8 do
            _x = x + sqrt(2) * cos(i * 45)
            _y = y + sqrt(2) * sin(i * 45)
            RenderText(font, text, _x, _y, s, ...)
        end
        SetFontState(font, '', co1)
        RenderText(font, text, x, y, s, ...)
    else
        for i = 0, 8 do
            _x = x + sqrt(2) * cos(i * 45)
            _y = y + sqrt(2) * sin(i * 45)
            RenderTTF2(font, text, _x, _x, _y, _y, s, co2, ...)
        end
        RenderTTF2(font, text, x, x, y, y, s, co1, ...)
    end
end

---带文字效果渲染文字
---只能使用很少的一部分文字效果，color与Color效果也不好
---@param font string @字体
---@param text string @渲染文字
---@param x number @x坐标
---@param y number @y坐标
---@param s number @缩放比例
---@param co1 lstg.Color @文字颜色
---@param co2 lstg.Color @描边颜色
---@vararg align @对齐方式
function lib.DrawText_ex(font, text, x, y, s, co1, co2, ...)
    s = s or 1
    co1 = co1 or Color(255, 255, 255, 255)
    local alpha = co1:ARGB()
    co2 = co2 or Color(alpha, 0, 0, 0)
    local _x, _y
    local fulltext = aic.custom_dialog.MultiGetTextEffect(text)
    local ttfdrawer = aic.custom_dialog.TTFDrawer(fulltext, { rawtext = text, fulltext = fulltext })
    local fmt = 0
    local arg = { ... }
    for i = 1, #arg do
        fmt = fmt + ENUM_TTF_FMT[arg[i]]
    end
    for i = 0, 8 do
        _x = x + sqrt(2) * cos(i * 45)
        _y = y + sqrt(2) * sin(i * 45)
        ttfdrawer:render(font,
            x, x, y, y, 12 * s, 32 * s, 0, 0,
            s, co2, fmt)  
    end
    ttfdrawer:render(font,
        x, x, y, y, 12 * s, 32 * s, 0, 0,
        s, co1, fmt)  
end

--为什么lua不能像py那样指定参数呢（恼
---渲染描边
---非常谔谔的写法，应当在SetImageState/SetFontState前调用
---@param func function @渲染函数
---@param co lstg.Color @描边颜色
---@vararg any @剩余参数
function lib.RenderStroke(func, co, ...)
    co = co or color(COLOR_BLACK)
    local arg = { ... }
    local xpos = { [Render] = { 2 }, [RenderRect] = { 2, 3 }, [Render4V] = { 2, 5, 8, 11 },
        [RenderText] = { 3 }, [RenderTTF] = { 3, 4 }, [RenderTTF2] = { 3, 4 } }
    local ypos = { [Render] = { 3 }, [RenderRect] = { 4, 5 }, [Render4V] = { 3, 6, 9, 12 },
        [RenderText] = { 4 }, [RenderTTF] = { 5, 6 }, [RenderTTF2] = { 5, 6 } }
    local setstate = {
        [Render] = function()
            SetImageState(arg[1], '', co)
        end,
        [RenderRect] = function()
            SetImageState(arg[1], '', co)
        end,
        [Render4V] = function()
            SetImageState(arg[1], '', co)
        end,
        [RenderText] = function()
            SetFontState(arg[1], '', co)
        end,
        [RenderTTF] = function()
            arg[7] = co
        end,
        [RenderTTF2] = function()
            arg[7] = co
        end
    }
    setstate[func]()
    for i = 0, 8 do
        for j = 1, #xpos[func] do
            arg[xpos[func][j]] = arg[xpos[func][j]] + sqrt(2) * cos(i * 45)
        end
        for j = 1, #ypos[func] do
            arg[ypos[func][j]] = arg[ypos[func][j]] + sqrt(2) * sin(i * 45)
        end
        func(unpack(arg))
    end
end

---player 下标
lib.player_pointer = Class(object)

function lib.player_pointer:init()
    self.scale = 1
    self.x = 0
    self.y = 0
    self.layer = LAYER_TOP + 0.1
    self.bound = false
end

function lib.player_pointer:render()
    SetViewMode('ui')
    local w = lstg.world
    SetRenderRect(w.l, w.r, w.b - max(16 * self.scale, 0), w.t,
        w.scrl, w.scrr, w.scrb - max(16 * self.scale, 0), w.scrt)
    local x, y = player.x, lstg.world.b
    SetImageState("player_pointer", "", Color(150, 255, 255, 255))
    Render("player_pointer", x, y, 0, self.scale)
    SetViewMode('world')
end

---控制玩家相关UI显示
---@param pointer boolean @是否显示位置指示器
---@param spellname boolean @是否显示玩家符卡名
function lib.SetPlayerUI(pointer, spellname)
    lstg.ui.player_pointer.hide = not pointer
    lstg.ui.player_spellname_hide = not spellname
end

--符卡类型
---@alias card_type ' "normal" = 普通符卡 '|' "great" = 大型符卡 '|' "time" = 耐久符卡'

---更改剩余符卡显示类型
---@param num number @符卡编号
---@param type card_type @符卡类型
function lib.SetCardLeft(num, type)
    type = type or ''
    _sc_left_type = _sc_left_type or {}
    _sc_left_type[num] = type
end

local function Muki_stroke(font, text, x, y, co, ...)
    local _x, _y
    for i = 0, 8 do
        _x = x + sqrt(2) * cos(i * 45)
        _y = y + sqrt(2) * sin(i * 45)
        RenderTTF(font, text,
            _x, _x, _y, _y,
            co,
            ...)
    end
end

---新建符卡名
---@param boss lstg.GameObject @符卡名所属boss
---@param name string @符卡名
---@param slot number @符卡名槽位（从1开始）
---@param xc number @x坐标偏移量
---@param yu number @y坐标偏移量
---@param IsPlayer boolean @是否为玩家符卡名
---@param t number @持续时间（仅玩家符卡名时有效）
---@param layer number @图层
---@param score number @SCB分数
function lib.NewSpellname(boss, name, slot, xc, yu, IsPlayer, t, layer, score)
    boss = boss or _boss
    if (not boss or not IsValid(boss)) and not IsPlayer then return end
    name = name or ' '
    slot = slot or 1
    xc = xc or 0
    yu = yu or -5
    score = score or 200000000
    layer = layer or LAYER_TOP + 446
    if not IsPlayer then t = nil end
    return New(lib.spellname, boss, name, slot, score, layer, xc, yu, IsPlayer, t)
end


--在我的努力修改下已经变成屎山了（指到处塞满调参用变量）
--From OWQzd3Rn2
--Arranged by Muki
---符卡名（玩家符卡名及boss符卡名）
lib.spellname = Class(object)

function lib.spellname:init(b, name, slot, score, lay, xc, yu, IsPlayer, t)
    self.x, self.y = 0, 0
    self.img = "img_void"
    self.layer = lay
    self.group = GROUP_NONTJT
    self.xc = xc
    self.yu = yu
    self.IsPlayer = IsPlayer
    if self.IsPlayer then
        self.align = 'left'
    else
        self.align = 'right'
    end

    if self.IsPlayer then
        self.spell_name_bg = 'player_spell_name_bg'
    else
        self.spell_name_bg = 'boss_spell_name_bg'
    end

    if score == nil then
        score = true
    end
    self.layer = lay
    self.boss = b
    self.name = name or ""
    self.slot = slot or 1
    self.score = score
    self.xp = -8
    self.yp = 0
    self.ybot = 345
    self.xoffset = 200
    self.xoffset2 = 0
    self.yoffset = -self.ybot
    self.waitx = 500
    self.default_waitx = self.waitx
    self._dy2 = 0
    self.t = t
    if self.IsPlayer then
        self.waitx = 1000
        self.default_waitx = self.waitx
        self.xc = self.xc - 175
        self.yu = self.yu + 120
        self.yp = -185
        self.slot = 1
        self.xoffset = -200
        self._dy2 = -130
    end
    if self.name == "" then
        RawDel(self)
    end
    self.x = 192 + self.xc
    self.y = 200 + self.yu - (self.slot - 2) * 44
    self.bound = false
    self.flag = 0
    self._scale = 1
    self._scale2 = 1
    self._alpha = 0
    self.talpha = 0
    self.talpha2 = 0
end

function lib.spellname:frame()
    if self.t and self.timer >= self.t and not self.delsign then Del(self) end
    task.Do(self)
    local b = self.boss
    if not b and not self.IsPlayer then return end
    local sc_hist = 0
    if IsValid(b) then
        sc_hist = b._sc_hist
    end
    self.sc_hist = sc_hist
    local t, t1, t2, ct, t3 = 60, 30, 30, 10, 40
    local etc = abs(t2 - t3) - 0
    if IsValid(b) then
        local dy = (b.ui_slot - 1) * 44
        self._dy = dy
        local bonus, aic_bonus
        if b.sc_bonus then
            bonus = string.format("0%.0f", b.sc_bonus - b.sc_bonus % 10)
            aic_bonus = string.format(b.sc_bonus - b.sc_bonus % 10)
        else
            aic_bonus = "FAILED"
            bonus = "FAILED"
        end
        self.bonus = bonus
        self.aic_bonus = aic_bonus
        local players
        if Players then
            players = Players(b)
        else
            players = { player }
        end
        local _flag = false
        local x = self.x
        local y = self.y + self.yoffset + dy
        for _, p in pairs(players) do
            if IsValid(p) and abs(p.x - x) <= 180
                and abs(p.y - y) <= 60
                and self.timer > 100 + etc + t1 then
                _flag = true
                break
            end
        end
        if _flag then
            self.flag = self.flag + 1
        else
            self.flag = self.flag - 1
        end
    else
        self.flag = 0
        self._dy = 0
    end
    self.flag = min(max(0, self.flag), 18)
    if not (self.death) then
        if self.IsPlayer then
            if self.timer > 30 then
                self.xoffset = min(self.xoffset + 10, 0)
            end
        else
            if self.timer > 30 then
                self.xoffset = max(self.xoffset - 10, 0)
            end
        end
        self.xoffset2 = 0
        local _t = self.timer - 60
        local _t1 = 100 + etc
        local _t2 = _t1 + t1
        local _t3 = 60 + etc
        local _t4 = _t3 + t
        local _t5 = t3 - ct
        local _t6 = _t5 + t2
        if self.timer > _t1 and self.timer < _t2 then
            self.talpha = min(self.talpha + (1 / t1), 1)
        end
        if self.timer > _t3 and self.timer < _t4 then
            local tmp = (90 / t) * (_t - etc)
            self.yoffset = -self.ybot + (self.ybot + self.yp + self._dy2) * sin(tmp * sin(tmp))
        end
        if self.timer > _t5 and self.timer < _t6 then
            self.talpha2 = min(self.talpha2 + (1 / t2), 1)
            self._scale2 = max(1 - sin((90 / t2) * (self.timer - t3 + ct)), 0)
        end
        if self.timer < t3 then
            self._scale = max(150 - 120 * sin((90 / t3) * self.timer), 30) / 30
        end
        self._alpha = min(self.timer / t3, 1)
        if not self.IsPlayer then
            self.waitx = self.default_waitx * max(0, (1 - (self.timer - _t6) / 60)) --为了解决SCB和history莫名奇妙先出来的问题
        end
    else
        if IsValid(b) and b.is_exploding and not (self.explodeFlag) then
            self.timer = -60
            self.explodeFlag = true
        end
        if self.timer > 0 then
            self.xoffset = min(self.xoffset + 8 + self.xp, 220)
        end
        self.xoffset2 = self.xoffset
        self._scale = 1
        self._alpha = 1
        if self.timer > 60 then
            RawDel(self)
        end
    end
end

function lib.spellname:render()
    local b = self.boss
    if (IsValid(b) and b.hp > 0) or self.IsPlayer then
        local sc_hist = self.sc_hist or { 0, 0 }
        if self.IsPlayer then sc_hist = { 0, 0 } end
        --local sc_hist = {100,1000} --想看master效果的自己改这个
        local bonus = self.bonus
        local aic_bonus = self.aic_bonus
        local dy = self._dy
        local x = self.x + self.xoffset + self.xp
        local y = self.y + self.yoffset - dy + self.yp
        local alpha = 1 - self.flag / 30
        local alpha2 = alpha * self._alpha
        local s = GetImageScale()
        SetImageState(self.spell_name_bg, "",
            Color(alpha * 255 * self.talpha2, 255, 255, 255))
        x = self.x + self.xoffset2
        if self.IsPlayer then
            Render(self.spell_name_bg, x - 200, y - 15, 0, 1 + 0.5 * self._scale2)
        else
            Render(self.spell_name_bg, x, y - 15, 0, 1 + 0.5 * self._scale2)
        end
        x = self.x + self.xoffset2 + self.xp
        y = y - 25
        local aicx, aicy = x, y
        SetImageScale(s * self._scale)
        if self.IsPlayer then
            if self.delsign then
                Muki_stroke("main_font_zh1", self.name, aicx - 180, aicy - 2, Color(alpha * 255 * self.talpha2, 0, 0, 0), self.align,
                    "noclip")
                RenderTTF("main_font_zh1", self.name,
                    aicx - 180, aicx - 180, aicy - 2, aicy - 2,
                    Color(alpha * 255 * self.talpha2, 255, 255, 255),
                    self.align, "noclip")
            else
                Muki_stroke("main_font_zh1", self.name, aicx - 180, aicy - 2, Color(alpha2 * 255, 0, 0, 0), self.align,
                    "noclip")
                RenderTTF("main_font_zh1", self.name,
                    aicx - 180, aicx - 180, aicy - 2, aicy - 2,
                    Color(alpha2 * 255, 255, 255, 255),
                    self.align, "noclip")
            end
        else
            Muki_stroke("main_font_zh1", self.name, aicx, aicy - 2, Color(alpha2 * 255, 0, 0, 0), self.align,
                "noclip")
            RenderTTF("main_font_zh1", self.name,
                aicx, aicx, aicy - 2, aicy - 2,
                Color(alpha2 * 255, 255, 255, 255),
                self.align, "noclip")
        end
        SetImageScale(s)
        local a = alpha * 255 * self.talpha
        local shift
        if sc_hist[1] >= 10 and sc_hist[2] >= 100 then shift = true end --history是否偏移
        if self.score and not self.Isplayer then
            --local fontsize = 0.5
            local xm, ym = 4, -1 --字符坐标偏移值
            x = self.x + self.xoffset - 5 + self.xp + self.waitx
            y = self.y - dy - 31 + self.yp
            aicx = self.x + self.xoffset - 5 + self.xp + 10 + self.waitx
            aicy = self.y - dy - 31 + self.yp - 13
            SetFontState("bonus2", "", Color(a, 0, 0, 0))
            --RenderText("bonus2", bonus, x - 90, y, fontsize, "right")
            --RenderText("bonus2", string.format("%d/%d", sc_hist[1], sc_hist[2]), x, y, fontsize, "right")
            --RenderText("bonus", "BONUS          HISTORY", x - 40, y, 0.5, "right")
            SetImageState("cardui_history", "", Color(a, 255, 255, 255))
            SetImageState("cardui_bonus", "", Color(a, 255, 255, 255))
            SetFontState("bonus2", "", Color(a, 255, 255, 255))
            --x = x - 1
            --y = y + 1
            --RenderTTF("pixel", "Bonus                           History", aicx - 55, aicx - 55, aicy, aicy, Color(255, 0, 255, 255), "right")
            if shift then
                Render("Muki_AiC_spell_history", x - 58 + self.xp, y - 18 + self.yp, 0, 0.5)
            else
                Render("Muki_AiC_spell_history", x - 38 + self.xp, y - 18 + self.yp, 0, 0.5)
            end
            Render("Muki_AiC_spell_bonus", x - 151 + self.xp, y - 18 + self.yp, 0, 0.5)


            if not self.IsPlayer and (not (self.death) or (self.death and IsValid(b) and b.is_exploding and self.timer <= 0)) then
                x = x + xm + 4 + self.xp
                y = y + ym + self.yp
                aicx = aicx + xm + 4 + self.xp - 5
                aicy = aicy + ym + self.yp + 6
                if bonus ~= "FAILED" then
                    if shift then
                        Muki_stroke("pixel", aic_bonus, aicx - 90, aicy, Color(255, 0, 0, 0), "right")
                        RenderTTF("pixel", aic_bonus, aicx - 90, aicx - 90, aicy, aicy,
                            Color(255, 255, 255, 255), "right")
                    else
                        Muki_stroke("pixel", aic_bonus, aicx - 70, aicy, Color(255, 0, 0, 0), "right")
                        RenderTTF("pixel", aic_bonus, aicx - 70, aicx - 70, aicy, aicy,
                            Color(255, 255, 255, 255), "right")
                    end
                else
                    if shift then
                        Muki_stroke("pixel", "Failed", aicx - 90, aicy, Color(255, 0, 0, 0), "right")
                        RenderTTF("pixel", "Failed", aicx - 90, aicx - 90, aicy, aicy,
                            Color(255, 255, 255, 255), "right")
                    else
                        Muki_stroke("pixel", "Failed", aicx - 70, aicy, Color(255, 0, 0, 0), "right")
                        RenderTTF("pixel", "Failed", aicx - 70, aicx - 70, aicy, aicy,
                            Color(255, 255, 255, 255), "right")
                    end
                end
                if sc_hist[2] < 1000 then
                    --对history显示实在相化
                    --悲报：实在相支持三位数history显示（
                    if shift then
                        Muki_stroke("pixel", string.format(sc_hist[1] .. "/" .. sc_hist[2]), aicx - 10,
                            aicy, Color(255, 0, 0, 0), "right")
                        RenderTTF("pixel", string.format(sc_hist[1] .. "/" .. sc_hist[2]), aicx - 10,
                            aicx - 10, aicy, aicy, Color(255, 255, 255, 255), "right")
                    else
                        Muki_stroke("pixel", string.format(sc_hist[1] .. "/" .. sc_hist[2]), aicx, aicy,
                            Color(255, 0, 0, 0), "right")
                        RenderTTF("pixel", string.format(sc_hist[1] .. "/" .. sc_hist[2]), aicx, aicx,
                            aicy, aicy, Color(255, 255, 255, 255), "right")
                    end
                elseif sc_hist[1] <= 99 then
                    Muki_stroke("pixel", string.format(sc_hist[1] .. "/999+"), aicx - 5, aicy,
                        Color(255, 0, 0, 0), "right")
                    RenderTTF("pixel", string.format(sc_hist[1] .. "/999+"), aicx - 5, aicx - 5, aicy,
                        aicy, Color(255, 255, 255, 255), "right")
                elseif sc_hist[1] > 99 then
                    --由于我没有闲到去把哪张卡收一百次，所以我只能猜实在相也是一百次就master
                    --虽然实在相有没有master都是个问题
                    Muki_stroke("pixel", 'MASTER', aicx - 8, aicy, Color(255, 0, 0, 0), "right")
                    RenderTTF("pixel", 'MASTER', aicx - 8, aicx - 8, aicy, aicy,
                        Color(255, 255, 255, 255), "right")
                end
                --[[if self.yp == 0 then
                    if sc_hist[2] < 1000 then
                        --对history显示实在相化
                        --悲报：实在相支持三位数history显示（
                        if shift then
                            Muki_stroke("pixel", string.format(sc_hist[1] .. "/" .. sc_hist[2]), aicx - 10,
                                aicy, Color(255, 0, 0, 0), "right")
                            RenderTTF("pixel", string.format(sc_hist[1] .. "/" .. sc_hist[2]), aicx - 10,
                                aicx - 10, aicy, aicy, Color(255, 255, 255, 255), "right")
                        else
                            Muki_stroke("pixel", string.format(sc_hist[1] .. "/" .. sc_hist[2]), aicx, aicy,
                                Color(255, 0, 0, 0), "right")
                            RenderTTF("pixel", string.format(sc_hist[1] .. "/" .. sc_hist[2]), aicx, aicx,
                                aicy, aicy, Color(255, 255, 255, 255), "right")
                        end
                    elseif sc_hist[1] <= 99 then
                        Muki_stroke("pixel", string.format(sc_hist[1] .. "/999+"), aicx - 5, aicy,
                            Color(255, 0, 0, 0), "right")
                        RenderTTF("pixel", string.format(sc_hist[1] .. "/999+"), aicx - 5, aicx - 5, aicy,
                            aicy, Color(255, 255, 255, 255), "right")
                    elseif sc_hist[1] > 99 then
                        --由于我没有闲到去把哪张卡收一百次，所以我只能猜实在相也是一百次就master
                        --虽然实在相有没有master都是个问题
                        Muki_stroke("pixel", 'MASTER', aicx - 8, aicy, Color(255, 0, 0, 0), "right")
                        RenderTTF("pixel", 'MASTER', aicx - 8, aicx - 8, aicy, aicy,
                            Color(255, 255, 255, 255), "right")
                    end
                else
                    x = x - 52
                    Muki_stroke("pixel", string.format(sc_hist[1] .. "/" .. sc_hist[2]), x, y,
                        Color(255, 0, 0, 0), "left")
                    RenderTTF("pixel", string.format(sc_hist[1] .. "/" .. sc_hist[2]), x, x, y, y,
                        Color(255, 255, 255, 255), "left")
                end]]
            end
        end
    else
        RawDel(self)
    end
end

function lib.spellname:kill()
    self.class.del(self)
end

function lib.spellname:del()
    PreserveObject(self)
    if self.t then
        self.delsign = true
        task.New(self, function()
            for i = 1, 30 do
                self._alpha = (30 - i) / 30
                self.talpha2 = (30 - i) / 30
                task.Wait()
            end
            RawDel(self)
        end)
    else
        if not (self.death) then
            self.death = true
            self.timer = -1
        end
    end
end

--周末活血条，费了老大劲把它竖过来
--在原本的基础上加上了阶段血条支持
--总喜欢在别人的东西上修修改改的屑（
lib.hpbar = plus.Class()
function lib.hpbar:init(ui, system)
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + 114514
    self.ui = ui
    self.system = system
    self.timer2 = 0
    self.timer3 = 0
end

function lib.hpbar:frame()
    boss.hpbar.frame(self)
    task.Do(self)
    local _ui = self.ui
    local b = self.system.boss
    if not (_ui.drawhp) or not (IsValid(b)) then
        self._mode = -1
        return
    end
    if not (_ui.hpbarcolor1) and not (_ui.hpbarcolor2) and not (b.time_sc) then
        self._mode = -1
    else
        self._mode = 0
    end
end
function lib.hpbar:render()
    SetViewMode('ui')
    local color_full_white = Color(0xFFFFFFFF)
    --local color_full_dark = Color(0xFF000000)
    local _ui = self.ui
    local b = self.system.boss
    if not (_ui.drawhp) or not (IsValid(b)) then
        return
    end

    if self._mode == nil or self._mode == -1 then
        return
    end

    local tex = "Muki_AiC_lifebar"
    local rate = b.hpbarlen
    if b.time_sc and b.t3 then
        tex = "Muki_AiC_timebar"
        rate = 1 - b.timer / b.t3
    end

    local p1, p2, p3, p4
    --local w = lstg.world
    local b, t, l, r = 0, screen.height, -20, 0
    local height = t - b
    --local l, r, t, t2 = w.l, w.r, w.t, w.t - 20
    --local width = r - l
    local boss = self.system.boss

    local open_time_rate = min(1, boss.timer / 30)
    local offset_x = 20 * open_time_rate
    rate = open_time_rate * rate
    l = l + offset_x
    r = r + offset_x
    p1 = { l, height * rate, 0.5, 0, 672 * (1 - rate), color_full_white }
    p2 = { r, height * rate, 0.5, 40, 672 * (1 - rate), color_full_white }
    p3 = { r, b, 0.5, 40, 672, color_full_white }
    p4 = { l, b, 0.5, 0, 672, color_full_white }
    RenderTexture(tex, "", p1, p2, p3, p4)

    p1 = { l, t, 0.5, 40, 0, color_full_white }
    p2 = { r, t, 0.5, 80, 0, color_full_white }
    p3 = { r, b, 0.5, 80, 672, color_full_white }
    p4 = { l, b, 0.5, 40, 672, color_full_white }
    RenderTexture(tex, "mul+add", p1, p2, p3, p4)
    if not (boss.time_sc and boss.t3) then
        local text = int(max(0, boss.hp)) .. "/" .. boss.maxhp
        local co = boss.hp_co or Color(open_time_rate * 255, 0, 0, 0)
        DrawText('menuttf', text, 25, 5, 0.75, Color(open_time_rate * 255, 255, 255, 255), co, 'paragraph', 'bottom')
    end

    if boss._sp_point_auto and #boss._sp_point_auto ~= 0 then
        local p, h
        for i = 1, #boss._sp_point_auto do
            p = boss._sp_point_auto[i]
            if not (boss.time_sc and boss.t3) then
                h = (1 - p.dmg / boss.maxhp) * height    
            else
                h = (1 - p.timer / boss.t3) * height
            end
            SetImageState("Muki_AiC_bossbar_node", '', Color(open_time_rate * 255, 255, 255, 255))
            Render("Muki_AiC_bossbar_node", (l + r) / 2, h, 0, 0.1)
            SetImageState("Muki_AiC_bossbar_node", 'mul+add', Color(open_time_rate * 255, 255, 255, 255))
            Render("Muki_AiC_bossbar_node", (l + r) / 2, h, 0, 0.1)
        end
    end

    --这一堆屎山简直没眼看
    --什么时候等我脑袋清醒点再过来优化这个逻辑
    self.lastname = self.lastname or boss.name
    if boss.name ~= self.lastname then
        self.tempname = boss.name
        boss.name = self.lastname
        self.timer2 = 30
        self.timer3 = 30
    elseif self.tempname and self.timer2 == 0 then
        self.lastname = self.tempname
        boss.name = self.tempname
    end
    self.timer2 = max(0, self.timer2 - 1)
    if self.timer2 == 0 then self.timer3 = max(0, self.timer3 - 1) end

    if _ui.drawname and boss.name then
        local name = 'Muki_AiC_bossname_' .. boss.name
        if CheckRes('img', name) then
            if self.timer2 > 0 then
                SetImageState(name, '', Color(min(open_time_rate, self.timer2 / 30) * 255, 255, 255, 255))
                Render(name, 47, 5, 0, 0.3)
                SetImageState(name, 'mul+add', Color(min(open_time_rate, self.timer2 / 30) * 50, 255, 255, 255))
                Render(name, 47, 5, 0, 0.3)
            else
                SetImageState(name, '', Color(min(open_time_rate, 1 - (self.timer3 / 30)) * 255, 255, 255, 255))
                Render(name, 47, 5, 0, 0.3)
                SetImageState(name, 'mul+add', Color(min(open_time_rate, 1 - (self.timer3 / 30)) * 50, 255, 255, 255))
                Render(name, 47, 5, 0, 0.3)
            end
        end
    end

    SetViewMode('world')

    --[[
    p1 = { r, t, 0.5, 672, 0, color_full_white }
    p2 = { r - width * rate, t, 0.5, 672 - 672 * rate, 0, color_full_white }
    p3 = { r - width * rate, t2, 0.5, 672 - 672 * rate, 40, color_full_white }
    p4 = { r, t2, 0.5, 672, 40, color_full_white }
    RenderTexture(tex, "", p1, p2, p3, p4)

    p1 = { r, t, 0.5, 672, 40, color_full_white }
    p2 = { r - width, t, 0.5, 0, 40, color_full_white }
    p3 = { r - width, t2, 0.5, 0, 80, color_full_white }
    p4 = { r, t2, 0.5, 672, 80, color_full_white }
    RenderTexture(tex, "mul+add", p1, p2, p3, p4)

    if boss.show_hp then
        local text = int(max(0, b.hp)) .. "/" .. b.maxhp
        SetFontState("bonus", "", color_full_dark)
        RenderText("bonus", text, -1, t2 + 12, 0.6, "centerpoint")
        RenderText("bonus", text, 0, t2 + 12, 0.6, "centerpoint")
        RenderText("bonus", text, 1, t2 + 12, 0.6, "centerpoint")
        RenderText("bonus", text, -1, t2 + 11, 0.6, "centerpoint")
        RenderText("bonus", text, 1, t2 + 11, 0.6, "centerpoint")
        RenderText("bonus", text, -1, t2 + 10, 0.6, "centerpoint")
        RenderText("bonus", text, 0, t2 + 10, 0.6, "centerpoint")
        RenderText("bonus", text, 1, t2 + 10, 0.6, "centerpoint")
        SetFontState("bonus", "", color_full_white)
        RenderText("bonus", text, 0, t2 + 11, 0.6, "centerpoint")
    end]]
end

---增加一个auto阶段点
---@param dmg number @目标损失血量
---@param timer number @目标计时器
---@param current boolean @是否使用真实帧数计时
function lib.AddSPPoint(dmg, timer, current)
    local b = _boss
    if not (b and IsValid(b)) then return end
    if b._sp_point_auto == nil then
        b._sp_point_auto = {}
    end
    local point = {
        dmg = dmg,
        timer = timer,
        current = current,
    }
    table.insert(b._sp_point_auto, point)
end

---增加一个auto阶段点（按剩余百分比计算）
---@param percent number @目标剩余血量/时间百分比
---@param maxhp number @最大血量
---@param t3 number @符卡时长（帧）
---@param current boolean @是否使用真实帧数计时
function lib.AddSPPoint2(percent, maxhp, t3, current)
    maxhp = maxhp or _infinite
    t3 = t3 or _infinite
    local b = _boss
    if not (b and IsValid(b)) then return end
    if b._sp_point_auto == nil then
        b._sp_point_auto = {}
    end
    local point = {
        dmg = maxhp * (1 - percent),
        timer = t3 * (1 - percent),
        current = current,
    }
    table.insert(b._sp_point_auto, point)
end

---检查剩余auto阶段点数量
---@param num number @检查阶段点数量
---@return boolean @剩余阶段点数量是否小于num
function lib.CheckSPPoint(num)
    local b = _boss
    if not (b and IsValid(b)) then return end
    return #b._sp_point_auto < num
end

----------------------------------------
---资源（部分资源在UI.lua中）

--boss血条
LoadImageGroupFromFile("Muki_AiC_lifebar", "THlib/UI/Muki_AiC_lifebar.png", false, 2, 1)
LoadImageGroupFromFile("Muki_AiC_timebar", "THlib/UI/Muki_AiC_timebar.png", false, 2, 1)
LoadImageFromFile("Muki_AiC_bossbar_node", "THlib/UI/Muki_AiC_bossbar_node.png")

--boss名
LoadImageFromFile("Muki_AiC_bossname_Noel Cornehl", "THlib/UI/Muki_AiC_bossname_Noel Cornehl.png")
SetImageCenter("Muki_AiC_bossname_Noel Cornehl", 100, 500)
LoadImageFromFile("Muki_AiC_bossname_Noel Cornehl & Ixia Polystachya", "THlib/UI/Muki_AiC_bossname_Noel Cornehl & Ixia Polystachya.png")
SetImageCenter("Muki_AiC_bossname_Noel Cornehl & Ixia Polystachya", 100, 1280)
LoadImageFromFile("Muki_AiC_bossname_Primula", "THlib/UI/Muki_AiC_bossname_Primula.png")
SetImageCenter("Muki_AiC_bossname_Primula", 100, 320)
