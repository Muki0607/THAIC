local color_full_white = Color(0xFFFFFFFF)
local color_full_dark = Color(0xFF000000)

do
    local hpbar = boss.hpbar
    local old = hpbar.frame
    function hpbar:frame()
        old(self)
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

    function hpbar:render()
        local _ui = self.ui
        local b = self.system.boss
        if not (_ui.drawhp) or not (IsValid(b)) then
            return
        end

        if self._mode == nil or self._mode == -1 then
            return
        end

        local tex = "Week_lifebar"
        local rate = b.hpbarlen
        if b.time_sc and b.t3 then
            tex = "Week_timebar"
            rate = 1 - b.timer / b.t3
        end

        local p1, p2, p3, p4
        local w = lstg.world
        local l, r, t, t2 = w.l, w.r, w.t, w.t - 20
        local width = r - l

        local open_time_rate = max(0, 30 - b.timer) / 30
        local offset_y = 20 * open_time_rate
        rate = (1 - open_time_rate) * rate
        t = t + offset_y
        t2 = t2 + offset_y

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

        if b.show_hp then
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
        end
    end
end

do
    local timeCounter = boss.timeCounter
    ---@param ui boss.ui
    ---@param system boss.system
    function timeCounter:init(ui, system)
        self.ui = ui
        self.system = system
        local b = self.system.boss
        if b.__hpbartype2 and int(b.__hpbartype2 / 10) == 2 then
            self.x, self.y = 176, lstg.world.t - 10
            self.oldstyle = true
        else
            self.x, self.y = 2, lstg.world.t - 32
            self.oldstyle = false
        end
        self.scale = 0.5
        self.scalewarning = 1
        self.scalewarning_current = 1.0
        self.scalewarning_1 = 1.25
        self.scalewarning_2 = 1.5
        self.yoffset = 0
        self.yoffsettemp = 0
        self.yoffsetmax = 24
        self.yoffsetspeedrate = 0.4
        self.open = false
        self.t1 = 10
        self.t2 = 5
        self.sound = true
        self.flag = 0
        self.cd1 = 0
        self.cd2 = 0
    end

    function timeCounter:frame()
        local _ui = self.ui
        local b = self.system.boss
        if not (IsValid(b)) then
            return
        end
        assert(self.t2 <= self.t1, "time counter's t1 > t2 must be satisfied.")
        local x, y
        if b.__hpbartype2 and int(b.__hpbartype2 / 10) == 2 then
            x, y = 176, lstg.world.t - 10
            self.oldstyle = true
        else
            x, y = 2, lstg.world.t - 32
            self.oldstyle = false
        end
        if _ui.drawhp and _ui.hpbar and _ui.hpbar._mode ~= -1 then
            y = y - 20
        end
        self.x = self.x + (x - self.x) * 0.1
        self.y = self.y + (y - self.y) * 0.1
        if _ui.countdown and self.sound then
            if _ui.countdown > self.t2 and _ui.countdown <= self.t1 and _ui.countdown % 1 == 0 then
                PlaySound("timeout", 0.6)
                self.scalewarning = self.scalewarning_1
                self.scalewarning_current = self.scalewarning_1
            end
            if _ui.countdown > 0 and _ui.countdown <= self.t2 and _ui.countdown % 1 == 0 then
                PlaySound("timeout2", 0.8)
                self.scalewarning = self.scalewarning_2
                self.scalewarning_current = self.scalewarning_2
            end
        end
        if not (self.open) then
            if not (b.__is_waiting) and b.is_combat then
                if b.is_sc then
                    self.yoffsettemp = self.yoffsetmax
                else
                    self.yoffsettemp = 0
                end
                self.open = true
            end
        elseif (b.__is_waiting and (lstg.player.dialog or not self.ui.drawtimesaver)) or (not (b.is_combat) and (lstg.player.dialog or not self.ui.drawtimesaver)) then
            self.open = false
            self.ui.drawtimesaver = nil
        end
        if self.open then
            if b.is_sc then
                self.yoffsettemp = max(0, self.yoffsettemp - 1 * self.yoffsetspeedrate)
                local s = self.yoffsettemp / self.yoffsetmax
                self.yoffset = (s * s) * self.yoffsetmax
            else
                self.yoffsettemp = min(self.yoffsetmax, self.yoffsettemp + 1 * self.yoffsetspeedrate)
                local s = self.yoffsettemp / self.yoffsetmax
                self.yoffset = (s * s) * self.yoffsetmax
            end

            if not self.ui.drawtimesaver or _ui.countdown ~= 0 then
                self.cd1 = _ui.countdown
            end

            if not b.is_combat and self.ui.drawtimesaver and not lstg.player.dialog then
                self.cd1 = self.ui.drawtimesaver
            end

            self.cd2 = (self.cd1 - int(self.cd1)) * 100
            local players
            if Players then
                players = Players(b)
            else
                players = { player }
            end
            local _flag = false
            for _, p in pairs(players) do
                if IsValid(p) and Dist(p.x, p.y, self.x, self.y) <= 70 then
                    _flag = true
                    break
                end
            end
            if _flag then
                self.flag = self.flag + 1
            else
                self.flag = self.flag - 1
            end
            self.flag = min(max(0, self.flag), 18)
        else
            self.flag = 0
        end
        if self.scalewarning > 1 then
            self.scalewarning = self.scalewarning - (self.scalewarning_current - 1.0) * 0.2
        else
            self.scalewarning = 1
            self.scalewarning_current = 1.0
        end
    end
end

do
    local pointer = boss.pointer
    function pointer:frame()
        self.y = lstg.world.b
        local b = self.system.boss
        if not (IsValid(b)) then
            return
        end
        if b.hp >= 0 then
            self.EnemyIndicater = self.EnemyIndicater + (max(0, (b.maxhp / 2 - b.hp))) / (b.maxhp / 2) * 90
        end
    end

    function pointer:render()
        local _ui = self.ui
        local b = self.system.boss
        if not (IsValid(b)) then
            return
        end
        if _ui.pointer_x and _ui.drawpointer then
            local w = lstg.world
            local scale = self.scale
            SetRenderRect(w.l, w.r, w.b - max(16 * scale, 0), w.t,
                w.scrl, w.scrr, w.scrb - max(16 * scale, 0), w.scrt)
            local x, y = _ui.pointer_x, self.y
            local distsub = 1
            local players
            if Players then
                players = Players(b)
            else
                players = { player }
            end
            for _, p in pairs(players) do
                if IsValid(p) then
                    distsub = min((1 - (min(abs(x - p.x), 64) / 128)), distsub)
                end
            end
            local hpsub = (sin(self.EnemyIndicater + 270) + 1) * 0.125
            local alpha = (1 - distsub * 0.6 - hpsub) * 255
            SetImageState("UI_EnemyMark", "", Color(alpha, 255, 255, 255))
            Render("UI_EnemyMark", x, y, 0, self.scale)
            SetViewMode "world"
        end
    end
end

do
    local infobar = boss.infobar
    ---@param ui boss.ui
    ---@param system boss.system
    function infobar:init(ui, system)
        self.ui = ui
        self.system = system
        local b = self.system.boss
        if b.__hpbartype2 and int(b.__hpbartype2 / 10) == 2 then
            self.x, self.y = -185, lstg.world.t - 11
        else
            self.x, self.y = -185, lstg.world.t - 2
        end
        self.t = 0
        self.mt = 15
        --每行星星上限数量
        self.lcount = 8
        --星星间隔
        self.stardx = 12
        self.stardy = 12
    end

    function infobar:frame()
        local _ui = self.ui
        local b = self.system.boss
        if not (IsValid(b)) then
            return
        end
        local x, y
        if b.__hpbartype2 and int(b.__hpbartype2 / 10) == 2 then
            x, y = -185, lstg.world.t - 11
        else
            x, y = -185, lstg.world.t - 2
        end
        if _ui.drawhp and _ui.hpbar and _ui.hpbar._mode ~= -1 then
            y = y - 20
        end
        self.x = self.x + (x - self.x) * 0.1
        self.y = self.y + (y - self.y) * 0.1
        local bscl = b.sc_left
        if self.sc_left == nil then
            self.sc_left = bscl
        end
        if self.sc_left > bscl then
            self.t = self.t + self.mt * (self.sc_left - bscl)
            self.sc_left = bscl
        end
        if self.t > 0 then
            self.t = self.t - 1
        end
    end

    function infobar:render()
        local _ui = self.ui
        local b = self.system.boss
        if not (IsValid(b)) then
            return
        end
        if _ui.drawname then
            local dy = (b.ui_slot - 1) * 44
            local x, y = self.x, self.y - dy
            local anisc = int(self.t / self.mt)
            local sc_left = self.sc_left + anisc
            RenderTTF('boss_name', b.name, x, x, y, y, Color(0xFF000000), "noclip")
            x = x - 1
            y = y + 1
            RenderTTF('boss_name', b.name, x, x, y, y, Color(0xFF80FF80), "noclip")
            local lcount = self.lcount
            local sdx, sdy = self.stardx, self.stardy
            local m = int((sc_left - 1) / lcount)
            local m2 = sc_left - 1 - lcount * m
            x = self.x - 9
            y = self.y - 15 - dy
            if m >= 0 then
                SetImageState("_boss_sc_left", "", Color(0xFFFFFFFF))
                for i = 0, m - 1 do
                    for j = 1, lcount do
                        Render('_boss_sc_left', x + j * sdx, y - i * sdy, 0, 0.5)
                    end
                end
                y = y - m * sdy
                for i = 1, m2 do
                    Render("_boss_sc_left", x + i * sdx, y, 0, 0.5)
                end
                local t, at, x2, y2
                t = self.mt - (self.t - anisc * self.mt)
                at = self.mt
                if self.t > 0 then
                    x2 = x + (m2 + 1) * sdx + t / 5
                    y2 = y - t / 5
                    SetImageState("_boss_sc_left", "",
                        Color(255 * (1 - (t / at)), 255, 255, 255))
                    Render("_boss_sc_left", x2, y2, 0, 0.5 + (t / at) * 0.5)
                end
            end
        end
    end
end

do
    local sc_name = boss.sc_name
    ---@param boss object @目标对象
    ---@param name string @符卡名称
    ---@param slot number @使用槽位
    function sc_name:init(b, name, score)
        if score == nil then
            score = true
        end
        self.layer = LAYER_TOP + 1
        self.boss = b
        self.name = name or ""
        self.score = score
        self.xp = -8
        self.yp = 0
        if self.name == "" then
            RawDel(self)
        end
        self.x = 192
        self.y = lstg.world.t - 8
        self.ybot = 380
        self.xoffset = 200
        self.xoffset2 = 0
        self.yoffset = -self.ybot
        if b.__hpbartype2 and int(b.__hpbartype2 / 10) == 2 then
            self.yp = -8
        end
        self.bound = false
        self.flag = 0
        self._scale = 1
        self._scale2 = 1
        self._alpha = 0
        self.talpha = 0
        self.talpha2 = 0
    end

    function sc_name:frame()
        self.y = lstg.world.t - 8
        local b = self.boss
        local _ui = b.ui
        local sc_hist = 0
        if IsValid(b) then
            sc_hist = b._sc_hist
        end
        if IsValid(_ui) then
            self.hide = not (_ui.drawspell)
            sc_hist = _ui.sc_hist
        end
        self.sc_hist = sc_hist
        local t, t1, t2, ct, t3 = 60, 30, 30, 10, 40
        local etc = abs(t2 - t3) - 0
        if IsValid(b) then
            local dy = (b.ui_slot - 1) * 44
            self._dy = dy
            local bonus
            if b.sc_bonus then
                bonus = string.format("0%.0f", b.sc_bonus - b.sc_bonus % 10)
            else
                bonus = "FAILED"
            end
            self.bonus = bonus
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
        end
        self.flag = min(max(0, self.flag), 18)
        if not (self.death) then
            if self.timer > 30 then
                self.xoffset = max(self.xoffset - 10, 0)
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
                self.yoffset = -self.ybot + (self.ybot + self.yp) * sin(tmp * sin(tmp))
            end
            if self.timer > _t5 and self.timer < _t6 then
                self.talpha2 = min(self.talpha2 + (1 / t2), 1)
                self._scale2 = max(1 - sin((90 / t2) * (self.timer - t3 + ct)), 0)
            end
            if self.timer < t3 then
                self._scale = max(150 - 120 * sin((90 / t3) * self.timer), 30) / 30
            end
            self._alpha = min(self.timer / t3, 1)
        else
            if IsValid(b) and b.is_exploding and not (self.explodeFlag) then
                self.timer = -60
                self.explodeFlag = true
            end
            if self.timer > 0 then
                self.xoffset = min(self.xoffset + 8, 220)
            end
            self.xoffset2 = self.xoffset
            self._scale = 1
            self._alpha = 1
            if self.timer > 60 then
                RawDel(self)
            end
        end
    end

    function sc_name:render()
        local b = self.boss
        local sc_hist = self.sc_hist or { 0, 0 }
        local bonus = self.bonus
        local dy = self._dy
        local x = self.x + self.xoffset + self.xp
        local y = self.y + self.yoffset - dy + self.yp
        local alpha = 1 - self.flag / 30
        local alpha2 = alpha * self._alpha
        local s = GetImageScale()
        SetImageState("_boss_spell_name_bg", "",
            Color(alpha * 255 * self.talpha2, 255, 255, 255))
        x = self.x + self.xoffset2
        Render("_boss_spell_name_bg", x, y, 0, 1 + 0.5 * self._scale2)
        x = self.x + self.xoffset2 + self.xp
        y = y - 10
        SetImageScale(s * self._scale)
        local d = sqrt(2)
        local _x, _y
        for i = 0, 8 do
            --沙雕描边
            _x = x + d * cos(i * 45)
            _y = y + d * sin(i * 45)
            RenderTTF("sc_name", self.name,
                _x, _x, _y - 2, _y - 2,
                Color(alpha2 * 255, 0, 0, 0),
                "right", "noclip")
        end
        RenderTTF("sc_name", self.name,
            x, x, y - 2, y - 2,
            Color(alpha2 * 255, 255, 255, 255),
            "right", "noclip")
        SetImageScale(s)
        local a = alpha * 255 * self.talpha
        if self.score then
            local fontsize = 0.5
            local xm, ym = 4, -1 --字符坐标偏移值
            x = self.x + self.xoffset - 5 + self.xp
            y = self.y - dy - 31 + self.yp
            SetFontState("bonus2", "", Color(a, 0, 0, 0))
            --RenderText("bonus2", bonus, x - 90, y, fontsize, "right")
            --RenderText("bonus2", string.format("%d/%d", sc_hist[1], sc_hist[2]), x, y, fontsize, "right")
            --RenderText("bonus", "BONUS          HISTORY", x - 40, y, 0.5, "right")
            SetImageState("cardui_history", "", Color(a, 255, 255, 255))
            SetImageState("cardui_bonus", "", Color(a, 255, 255, 255))
            Render("cardui_history", x - 63 + self.xp, y - 6 + self.yp, 0, 0.5)
            Render("cardui_bonus", x - 156 + self.xp, y - 6 + self.yp, 0, 0.5)
            SetFontState("bonus2", "", Color(a, 255, 255, 255))
            --x = x - 1
            --y = y + 1
            --RenderText("bonus", "BONUS          HISTORY", x - 40, y, 0.5, "right")

            if not (self.death) or (self.death and IsValid(b) and b.is_exploding and self.timer <= 0) then
                x = x + xm + 4 + self.xp
                y = y + ym + self.yp
                if bonus ~= "FAILED" then
                    RenderText("bonus2", bonus, x - 90, y, fontsize, "right")
                else
                    SetImageState("sc_failed", "", Color(a, 255, 255, 255))
                    Render("sc_failed", x - 108, y - ym - 6, 0, fontsize)
                end
                if self.yp == 0 then
                    if sc_hist[2] < 100 then
                        ---------对history显示原作化
                        x = x - 8
                        RenderText("bonus2", string.format("%02d/%02d", sc_hist[1], sc_hist[2]), x, y, fontsize, "right")
                    elseif sc_hist[1] <= 99 then
                        x = x - 8
                        RenderText("bonus2", string.format("%02d/99+", sc_hist[1], sc_hist[2]), x, y, fontsize, "right")
                    elseif sc_hist[1] > 99 then
                        SetImageState("sc_master", "", Color(a, 255, 255, 255))
                        Render("sc_master", x - 29, y - ym - 7, 0, fontsize)
                    end
                else
                    x = x - 52
                    RenderText("bonus2", string.format("%02d/%02d", sc_hist[1], sc_hist[2]), x, y, fontsize, "left")
                end
            end
        end
    end
end
