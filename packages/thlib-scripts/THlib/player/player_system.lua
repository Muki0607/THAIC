--THAIC Arranged
local player_lib = player_lib
---@class player.system
---@return player.system
player_lib.system = plus.Class()

local defaultKeys = {
    "up", "down", "left", "right",
    "slow", "shoot", "spell", "special",
    "skill"
}
player_lib.defaultKeys = defaultKeys

-----------------------------------------------
--debug tool
local keydown_list = {}
local status_list = {}
for i = 112, 118, 1
do
    keydown_list[i] = false
    status_list[i] = false
end
for i = 49, 56, 1
do
    keydown_list[i] = false
    status_list[i] = false
end
local boss_locked_hp
local boss_locked_time
local player_locked_hp
local player_locked_exmp
local player_locked_power
local debug_tool_used = false
-----------------------------------------------

local defaultKeyEvent = {
    { "up", "down", "key.up.down", 0, function(self)
        self.__up_flag = true
    end },
    { "up", "up", "key.up.up", 0, function(self)
        self.__up_flag = false
    end },
    { "down", "down", "key.down.down", 0, function(self)
        self.__down_flag = true
    end },
    { "down", "up", "key.down.up", 0, function(self)
        self.__down_flag = false
    end },
    { "left", "down", "key.left.down", 0, function(self)
        self.__left_flag = true
    end },
    { "left", "up", "key.left.up", 0, function(self)
        self.__left_flag = false
    end },
    { "right", "down", "key.right.down", 0, function(self)
        self.__right_flag = true
    end },
    { "right", "up", "key.right.up", 0, function(self)
        self.__right_flag = false
    end },
    { "slow", "down", "key.slow.down", 0, function(self)
        self.__slow_flag = true
    end },
    { "slow", "up", "key.slow.up", 0, function(self)
        self.__slow_flag = false
    end },
    { "shoot", "down", "key.shoot.down", 0, function(self)
        self.__shoot_flag = true
    end },
    { "shoot", "up", "key.shoot.up", 0, function(self)
        self.__shoot_flag = false
    end },
    { "spell", "down", "key.spell.down", 0, function(self)
        self.__spell_flag = true
    end },
    { "spell", "up", "key.spell.up", 0, function(self)
        self.__spell_flag = false
    end },
    { "special", "down", "key.special.down", 0, function(self)
        self.__special_flag = true
    end },
    { "special", "up", "key.special.up", 0, function(self)
        self.__special_flag = false
    end },
}
player_lib.defaultKeyEvent = defaultKeyEvent

local defaultFrameEvent = {
    ["frame.updateDeathState"] = { 100, function(self)
        if (self.death == 0 or self.death > 90) and (not self.lock) and not (self.time_stop) then
            if _debug.pmode and CheckEnhancer(12) and aic.pmode.InitializedSign and self.death > 90 then
                --aic.pmode.Load()
                ext.pop_pause_menu = true
                --lstg.tmpvar.death = true
                lstg.tmpvar.pause_menu_text = { 'Return to Waypoint', 'Return to Title', 'Manual' }
            end
            self.__death_state = 0
        elseif self.death == 90 then
            self.__death_state = 1
        elseif self.death == 84 then
            self.__death_state = 2
        elseif self.death == 50 then
            self.__death_state = 3
        elseif self.death < 50 and not (self.lock) and not (self.time_stop) then
            self.__death_state = 4
        else
            self.__death_state = -1
        end
    end },
    ["frame.updateSlow"] = { 99, function(self)
        if Hana_AI and Hana_AI.Start_state == 1 then Hana_AI.Frame_action() end
        if setting.autofire then self.__shoot_flag = not self.__shoot_flag end
        if setting.autoslow and self.__shoot_flag then self.__slow_flag = true end
        if self.__death_state == 0 then
            if self.__slow_flag then
                self.slow = 1
            else
                self.slow = 0
            end
        end
    end },
    ["frame.control"] = { 98, function(self, system)
        if self.__death_state == 0 then
            if not self.dialog then
                if (self.__shoot_flag or player_lib.debug_data.keep_shooting) and self.nextshoot <= 0 then
                    system:shoot()
                end
                local cost = 100
                if CheckEnhancer(4) then cost = cost * 1.1 end
                if not _debug.pmode and CheckEnhancer(12) then cost = cost * 0.4 end
                --这年头想放个b是真的难
                if self.__spell_flag and self.nextspell <= 0 and
                    (lstg.var.exmp >= cost or (lstg.var.exmp + lstg.var.power >= cost and CheckEnhancer(4)))
                    and not CheckEnhancer(15) and not lstg.var.block_spell then
                    system:spell()
                end
                if self.__special_flag and self.nextsp <= 0 and not CheckEnhancer(15) then
                    system:special()
                end
            else
                self.nextshoot = 15
                self.nextspell = 30
            end
        end
    end },
    ["frame.move"] = { 97, function(self)
        local dx, dy, v = 0, 0, self.hspeed
        if self.__death_state == 0 then
            if self.death == 0 and not self.lock then
                if self.slowlock then
                    self.slow = 1
                end
                if self.slow == 1 then
                    v = self.lspeed
                end
                if self.__up_flag then
                    dy = dy + 1
                end
                if self.__down_flag then
                    dy = dy - 1
                end
                if self.__left_flag then
                    dx = dx - 1
                end
                if self.__right_flag then
                    dx = dx + 1
                end
                if dx * dy ~= 0 then
                    v = v * SQRT2_2
                end
                dx = v * dx
                dy = v * dy
                self.x = self.x + dx
                self.y = self.y + dy
                self.x = math.max(math.min(self.x, lstg.world.pr - 8), lstg.world.pl + 8)
                self.y = math.max(math.min(self.y, lstg.world.pt - 32), lstg.world.pb + 16)
            end
        end
        self.__move_dx = dx
        self.__move_dy = dy
        if Hana_AI and Hana_AI.Start_state == 1 then Hana_AI.Walking_diagram_correction(dx, dy) end
    end },
    ["frame.fire"] = { 96, function(self)
        if self.__death_state == 0 then
            if self.__shoot_flag and not self.dialog then
                self.fire = self.fire + 0.16
            else
                self.fire = self.fire - 0.16
            end
            if self.fire < 0 then
                self.fire = 0
            end
            if self.fire > 1 then
                self.fire = 1
            end
        end
    end },
    ["frame.itemCollect"] = { 95, function(self)
        if self.__death_state == 0 then
            if self.y > self.collect_line and not CheckEnhancer(2) then
                for _, o in ObjList(GROUP_ITEM) do
                    local flag = false
                    if o.attract < 8 then
                        flag = true
                    elseif o.attract == 8 and o.target ~= self then
                        if (not o.target) or o.target.y < self.y then
                            flag = true
                        end
                    end
                    if o.is_power_red then flag = false end
                    if flag then
                        o.attract = 8
                        o.num = self.item
                        o.target = self
                    end
                end
            else
                if self.__slow_flag then
                    for _, o in ObjList(GROUP_ITEM) do
                        if Dist(self, o) < 48 or ((o.is_power or o.is_power_blue) and Dist(self, o) < 96) then
                            if o.attract < 3 then
                                o.attract = max(o.attract, 3)
                                o.target = self
                            end
                        end
                    end
                else
                    for _, o in ObjList(GROUP_ITEM) do
                        if Dist(self, o) < 24 or ((o.is_power or o.is_power_blue) and Dist(self, o) < 48) then
                            if o.attract < 3 then
                                o.attract = max(o.attract, 3)
                                o.target = self
                            end
                        end
                    end
                end
            end
        end
    end },
    ["frame.death1"] = { 94, function(self)
        if self.__death_state == 1 then
            if self.time_stop then
                self.death = self.death - 1
            end
            --------------------------------------------------
            --由于决死的存在，hp扣减由colli搬至这里
            local dmg = self.taking_damage or 50
            local plist = { 0.8, 1, 1.2, 1.5 }

            if not lstg.tmpvar.hit_count then lstg.tmpvar.hit_count = 0 end

            local percent = plist[scoredata.difficulty_select]
            if CheckEnhancer(15) then percent = percent * 0.5 end
            if lstg.var.enhancer_overload then percent = percent * 2 end
            dmg = dmg * percent
            if not CheckDiff(3) then
                dmg = dmg * (1 - min(0.75, lstg.tmpvar.hit_count * (3 - scoredata.difficulty_select) * 0.25))
            end
            dmg = int(dmg)

            if CheckDiff(3) then
                lstg.var.hp = max(lstg.var.hp - dmg, 0)
            elseif lstg.var.hp >= dmg * 0.75 - 1 then
                lstg.var.hp = max(lstg.var.hp - dmg, 0)
                lstg.var.temp_hp = lstg.var.temp_hp + dmg * 0.25
            else
                local d = dmg * 0.75 - lstg.var.hp + 1
                if lstg.var.temp_hp >= d then
                    lstg.var.temp_hp = max(lstg.var.temp_hp - d, 0)
                    lstg.var.hp = 1
                else
                    lstg.var.temp_hp = 0
                    lstg.var.hp = 0
                end
            end
            if CheckDiff(4) and lstg.var.enhancer_overload then
                lstg.var.hp = 0
            end

            --累计miss数
            lstg.tmpvar.hit_count = lstg.tmpvar.hit_count + 1
            --重置决死时间
            player.deathtime = player.default_deathtime
            --------------------------------------------------
            item.PlayerMiss(self)
            New(death_weapon, self.x, self.y)
            self.deathee = {}
            self.deathee[1] = New(deatheff, self.x, self.y, "first")
            self.deathee[2] = New(deatheff, self.x, self.y, "second")
            New(player_death_ef, self.x, self.y)
        end
    end },
    ["frame.death2"] = { 93, function(self)
        if self.__death_state == 2 then
            if self.time_stop then
                self.death = self.death - 1
            end
            self.hide = true
        end
    end },
    ["frame.death3"] = { 92, function(self)
        if self.__death_state == 3 then
            if self.time_stop then
                self.death = self.death - 1
            end
            self.x = 0
            self.supportx = 0
            self.y = -236
            self.supporty = -236
            self.hide = false
            New(bullet_deleter, self.x, self.y)
        end
    end },
    ["frame.death4"] = { 91, function(self)
        if self.__death_state == 4 then
            self.y = -192 - (1.2 * (self.death - 1))
        end
    end },
    ["frame.updateVar"] = { 90, function(self)
        self.lh = self.lh + (self.slow - 0.5) * 0.3
        if self.lh < 0 then
            self.lh = 0
        end
        if self.lh > 1 then
            self.lh = 1
        end
        if self.nextshoot > 0 then
            self.nextshoot = self.nextshoot - 1
        end
        if self.nextspell > 0 then
            self.nextspell = self.nextspell - 1
        end
        if self.nextsp > 0 then
            self.nextsp = self.nextsp - 1
        end
        if self.support > int(lstg.var.power / 100) then
            self.support = self.support - 0.0625
        elseif self.support < int(lstg.var.power / 100) then
            self.support = self.support + 0.0625
        end
        if abs(self.support - int(lstg.var.power / 100)) < 0.0625 then
            self.support = int(lstg.var.power / 100)
        end
        self.supportx = self.x + (self.supportx - self.x) * 0.6875
        self.supporty = self.y + (self.supporty - self.y) * 0.6875
        if self.protect > 0 then
            self.protect = self.protect - 1
        end
        if self.death > 0 then
            self.death = self.death - 1
        end
        lstg.var.pointrate = item.PointRateFunc(lstg.var)
    end },
    ["frame.updateSupport"] = { 89, function(self)
        if not (self.time_stop) then
            if self.slist then
                self.sp = {}
                if self.support == 5 then
                    for i = 1, 4 do
                        self.sp[i] = MixTable(self.lh, self.slist[6][i])
                        self.sp[i][3] = 1
                    end
                else
                    local s = int(self.support) + 1
                    local t = self.support - int(self.support)
                    for i = 1, 4 do
                        if self.slist[s][i] and self.slist[s + 1][i] then
                            self.sp[i] = MixTable(t, MixTable(self.lh, self.slist[s][i]),
                                MixTable(self.lh, self.slist[s + 1][i]))
                            self.sp[i][3] = 1
                        elseif self.slist[s + 1][i] then
                            self.sp[i] = MixTable(self.lh, self.slist[s + 1][i])
                            self.sp[i][3] = t
                        end
                    end
                end
            end
        end
    end },
    ["frame.timeStop"] = { 88, function(self)
        if self.time_stop then
            self.timer = self.timer - 1
        end
    end },
    ["frame.AiC"] = { 87, function(self)
        --魔力流失
        if lstg.var.power > lstg.var.maxpower and self.timer % 12 == 0 then
            lstg.var.power = lstg.var.power - 1
        end
        if lstg.var.power > lstg.var.maxpower2 and self.timer % 12 == 0 then
            lstg.var.power = lstg.var.power - 1
        end
        
        --临时血量回复
        if lstg.var.temp_hp > 0 and self.timer % 24 == 0 then
            lstg.var.temp_hp = lstg.var.temp_hp - 1
            lstg.var.hp = lstg.var.hp + 1
        end

        --简单难度下低血量时缓慢回血
        if lstg.var.hp < 100 and CheckDiff(1, true) and self.timer % 180 == 0 then
            lstg.var.hp = lstg.var.hp + 1
        end

        --防止超限
        lstg.var.hp = min(lstg.var.hp, lstg.var.maxhp)
        lstg.var.dodge = min(600, lstg.var.dodge)

        --双重闪避冷却
        if self.nextsp2 then
            self.nextsp2 = max(0, self.nextsp2 - 1)
        end

        --子弹大小增大
        if CheckEnhancer(6) then
            for _, o in ObjList(GROUP_PLAYER_BULLET) do
                if IsValid(o) and not o.enhanced and o.a and o.b then
                    o.enhanced = true
                    o.a = o.a * 1.5
                    o.b = o.b * 1.5
                    o.hscale = o.hscale * 1.5
                    o.vscale = o.vscale * 1.5
                end
            end
        end

        --收点保护
        self.next_collect_protect = self.next_collect_protect or 0
        self.next_collect_protect = max(0, self.next_collect_protect - 1)
        if CheckEnhancer(11) and self.y > self.collect_line and self.next_collect_protect <= 0 then
            self.next_collect_protect = 300
            self.protect = max(self.protect, 60)
            PlaySound('lgods1', 0.5)
        end

        --[[local keypretwi = aic.sys.KeyIsPressedTwice
        if player.nextsp <= 0 and ((keypretwi('up') or keypretwi('down') or keypretwi('left') or keypretwi('right'))
                and lstg.var.dodge >= 100 or (lstg.var.dodge >= 75 and CheckEnhancer(3))) then
            player._playersys:special()
        end]]
    end },
    -----------------------------------------------
    --debug tool
    ["frame.debug_tool"] = { 86, function(self)
        for i = 112, 118, 1
        do
            if (GetKeyState(i)) and _debug.debug_tool then
                if not keydown_list[i] then
                    keydown_list[i] = true
                    status_list[i] = not status_list[i]
                    if i == 112 and status_list[112] == true then
                        debug_tool_used = true
                        for i = 113, 118, 1
                        do
                            status_list[i] = false
                        end
                        for i = 49, 56, 1
                        do
                            status_list[i] = false
                        end
                    end
                    if status_list[112] then 
                        if i == 113 then
                            status_list[115] = false
                            status_list[116] = false
                            if IsValid(_boss) then
                                Kill(_boss)
                            end
                        end
                        if i == 114 then
                            status_list[115] = false
                            if IsValid(_boss) then
                                _boss.hp = _boss.hp - 100
                            end
                        end
                        if i == 115 then
                            if IsValid(_boss) then
                                boss_locked_hp = _boss.hp
                            end
                        end
                        if i == 116 then
                            if IsValid(_boss) then
                                boss_locked_time = _boss.timer
                            end
                        end
                        if i == 117 then
                            for _, unit in ObjList(GROUP_ENEMY_BULLET) do
                                Del(unit)
                            end
                        end
                        if i == 118 then
                            for _, unit in ObjList(GROUP_ENEMY) do
                                if unit ~= _boss then
                                    Del(unit)
                                end
                            end
                            for _, unit in ObjList(GROUP_NONTJT) do
                                if unit ~= _boss then
                                    Del(unit)
                                end
                            end
                        end
                    end
                end
            else
                keydown_list[i] = false
            end
        end
        for i = 49, 56, 1
        do
            if (GetKeyState(i)) then
                if not keydown_list[i] then
                    keydown_list[i] = true
                    status_list[i] = not status_list[i]
                    if status_list[112] then 
                        if i == 50 then
                            player_locked_hp = lstg.var.hp
                        end
                        if i == 51 then
                            player_locked_exmp = lstg.var.exmp
                        end
                        if i == 52 then
                            player_locked_power = lstg.var.power
                        end
                        if i == 53 then
                            status_list[52] = false
                            lstg.var.power = 500
                            PlaySound('powerup1', 0.5)
                        end
                        if i == 54 then
                            status_list[50] = false
                            lstg.var.hp = lstg.var.hp + 50
                            PlaySound('extend', 0.5)
                            New(hinter, 'hint.extend', 0.6, 0, 112, 15, 120)
                        end
                        if i == 55 then
                            status_list[51] = false
                            lstg.var.exmp = lstg.var.exmp + 100
                            PlaySound("cardget", 0.8)
                        end
                    end
                end
            else
                keydown_list[i] = false    
            end
        end
        if status_list[112] then
            if status_list[49] then
                if self.death > 0 then
                    self.death = 0
                    self.protect = 120
                end
            end
            if status_list[50] then
                lstg.var.hp = player_locked_hp
            end
            if status_list[51] then
                lstg.var.exmp = player_locked_exmp
            end
            if status_list[52] then
                lstg.var.power = player_locked_power
            end
            if status_list[115] then
                if IsValid(_boss) then
                    _boss.hp = boss_locked_hp
                end
            end
            if status_list[116] then
                if IsValid(_boss) then
                    _boss.timer = boss_locked_time
                end
            end
        end
    end },
    -----------------------------------------------
}
player_lib.defaultFrameEvent = defaultFrameEvent

local system = player_lib.system
function system:init(p, slot)
    self.player = p
    p.supportx = p.supportx or 0
    p.supporty = p.supporty or p.y
    p.hspeed = p.hspeed or 4
    p.lspeed = p.lspeed or 2
    p.collect_line = p.collect_line or 96
    p.slow = p.slow or 0
    p.A = p.A or 0
    p.B = p.B or 0
    p.lh = p.lh or 0
    p.fire = p.fire or 0
    p.lock = p.lock or false
    p.dialog = p.dialog or false
    p.nextshoot = p.nextshoot or 0
    p.nextspell = p.nextspell or 0
    p.nextsp = p.nextsp or 0
    p.item = p.item or 1
    p.death = p.death or 0
    p.protect = p.protect or 120
    p.grazer = p.grazer or New(grazer, p)
    p.support = p.support or int(lstg.var.power / 100)
    p.sp = p.sp or {}
    p.time_stop = p.time_stop or false
    p.slot = slot
    p.__death_state = 0 --自机状态
    p.__move_dx = 0 --本帧操作移动x距离
    p.__move_dy = 0 --本帧操作移动y距离
    self.listener = eventListener()
    self._keys = {}
    self._keys_remove = {}
    self.keyState = {}
    self.keyStatePre = {}
    for _, key in ipairs(defaultKeys) do
        self:regKeys(key)
    end
    for _, event in ipairs(defaultKeyEvent) do
        self:addKeyEvent(unpack(event))
    end
    for name, event in pairs(defaultFrameEvent) do
        self:addFrameEvent(name, unpack(event))
    end
end

---帧逻辑事件
function system:frame()
    local p = self.player
    p.grazer.world = p.world
    self:updateKeyState() --更新自机按键状态（之后应改为外部调用）
    self:findTarget() --更新target目标
    self:doFrameEvent() --执行帧逻辑事件
    if not (p._wisys) then
        p._wisys = PlayerWalkImageSystem(p)
    end
    if not p.time_stop then
        p._wisys:frame(p.__move_dx)
    end
end

---渲染事件
function system:render()
    --实在相式无敌时间提醒
    if player.protect > 0 and player.death <= 50 and not player.dodge then
        SetImageState('white', 'mul+add', color(COLOR_WHITE))
        aic.ui.RenderEclipseRing('white', player.x, player.y, player.protect / 2, player.protect / 2 + 5)
        SetImageState('white', 'mul+add', color(COLOR_WHITE, 100))
        aic.ui.RenderEclipseRing('white', player.x, player.y, 0, player.protect / 2)
    end
    -----------------------------------------------
    local p = self.player
    p._wisys:render()--by OLC，自机行走图系统
    -----------------------------------------------
    --debug tool
    if status_list[112] then
        lstg.RenderTTF("debug_tool_font", "[F1]debug模式", -180, -100, 170, 180, 0, Color(0xFF00FFFF))
        if keydown_list[113] then
            lstg.RenderTTF("debug_tool_font", "[F2]KillBoss", -180, -100, 160, 170, 0, Color(0xFF00FFFF))
        else
            lstg.RenderTTF("debug_tool_font", "[F2]KillBoss", -180, -100, 160, 170, 0, Color(0xAACCCCCC))
        end
        if keydown_list[114] then
            lstg.RenderTTF("debug_tool_font", "[F3]BossHP减100", -180, -100, 150, 160, 0, Color(0xFF00FFFF))
        else
            lstg.RenderTTF("debug_tool_font", "[F3]BossHP减100", -180, -100, 150, 160, 0, Color(0xAACCCCCC))
        end
        if status_list[115] then
            lstg.RenderTTF("debug_tool_font", "[F4]Boss锁HP", -180, -100, 140, 150, 0, Color(0xFF00FFFF))
        else
            lstg.RenderTTF("debug_tool_font", "[F4]Boss锁HP", -180, -100, 140, 150, 0, Color(0xAACCCCCC))
        end
        if status_list[116] then
            lstg.RenderTTF("debug_tool_font", "[F5]Boss锁时", -180, -100, 130, 140, 0, Color(0xFF00FFFF))
        else
            lstg.RenderTTF("debug_tool_font", "[F5]Boss锁时", -180, -100, 130, 140, 0, Color(0xAACCCCCC))
        end
        if keydown_list[117] then
            lstg.RenderTTF("debug_tool_font", "[F6]清子弹", -180, -100, 120, 130, 0, Color(0xFF00FFFF))
        else
            lstg.RenderTTF("debug_tool_font", "[F6]清子弹", -180, -100, 120, 130, 0, Color(0xAACCCCCC))
        end
        if keydown_list[118] then
            lstg.RenderTTF("debug_tool_font", "[F7]清小怪", -180, -100, 110, 120, 0, Color(0xFF00FFFF))
        else
            lstg.RenderTTF("debug_tool_font", "[F7]清小怪", -180, -100, 110, 120, 0, Color(0xAACCCCCC))
        end
        if status_list[49] then
            lstg.RenderTTF("debug_tool_font", "[1]miss后不掉残", -180, -100, 100, 110, 0, Color(0xFF00FFFF))
        else
            lstg.RenderTTF("debug_tool_font", "[1]miss后不掉残", -180, -100, 100, 110, 0, Color(0xAACCCCCC))
        end
        if status_list[50] then
            lstg.RenderTTF("debug_tool_font", "[2]锁自机HP", -180, -100, 90, 100, 0, Color(0xFF00FFFF))
        else
            lstg.RenderTTF("debug_tool_font", "[2]锁自机HP", -180, -100, 90, 100, 0, Color(0xAACCCCCC))
        end
        if status_list[51] then
            lstg.RenderTTF("debug_tool_font", "[3]锁过充魔力", -180, -100, 80, 90, 0, Color(0xFF00FFFF))
        else
            lstg.RenderTTF("debug_tool_font", "[3]锁过充魔力", -180, -100, 80, 90, 0, Color(0xAACCCCCC))
        end
        if status_list[52] then
            lstg.RenderTTF("debug_tool_font", "[4]锁魔力", -180, -100, 70, 80, 0, Color(0xFF00FFFF))
        else
            lstg.RenderTTF("debug_tool_font", "[4]锁魔力", -180, -100, 70, 80, 0, Color(0xAACCCCCC))
        end
        if keydown_list[53] then
            lstg.RenderTTF("debug_tool_font", "[5]满魔力", -180, -100, 60, 70, 0, Color(0xFF00FFFF))
        else
            lstg.RenderTTF("debug_tool_font", "[5]满魔力", -180, -100, 60, 70, 0, Color(0xAACCCCCC))
        end
        if keydown_list[54] then
            lstg.RenderTTF("debug_tool_font", "[6]增加50HP", -180, -100, 50, 60, 0, Color(0xFF00FFFF))
        else
            lstg.RenderTTF("debug_tool_font", "[6]增加50HP", -180, -100, 50, 60, 0, Color(0xAACCCCCC))
        end
        if keydown_list[55] then
            lstg.RenderTTF("debug_tool_font", "[7]增加100过充魔力", -180, -100, 40, 50, 0, Color(0xFF00FFFF))
        else
            lstg.RenderTTF("debug_tool_font", "[7]增加100过充魔力", -180, -100, 40, 50, 0, Color(0xAACCCCCC))
        end
    else
        if debug_tool_used then
            lstg.RenderTTF("debug_tool_font", "[F1]debug模式", -180, -100, 170, 180, 0, Color(0xAACCCCCC))
        end
    end
    -----------------------------------------------
end

---Shoot事件
function system:shoot()
    local p = self.player
    if p.class.shoot then
        p.class.shoot(p)
    end
end

---Spell事件
function system:spell()
    local p = self.player
    item.PlayerSpell()
    local cost = 100
    local before = int(lstg.var.exmp / 100)
    if CheckEnhancer(4) then cost = cost * 1.1 end
    if not _debug.pmode and CheckEnhancer(12) then cost = cost * 0.4 end
    if CheckEnhancer(4) and lstg.var.exmp < cost then
        local d = cost - lstg.var.exmp
        lstg.var.exmp = 0
        lstg.var.power = lstg.var.power - d
    else
        lstg.var.exmp = lstg.var.exmp - cost
    end
    local after = int(lstg.var.exmp / 100)
    if after < before then
        lstg.var.exmp_int = lstg.var.exmp_int - 1
    end
    if p.class.spell and not (not _debug.pmode and CheckEnhancer(12)) then
        p.class.spell(p)
        if p.spellname then
            if p.death > 90 and p.have_death_spell then
                aic.ui.NewSpellname(nil, p.spellname[2], nil, nil, nil, true, 240)
            elseif p.lastspell then
                aic.ui.NewSpellname(nil, p.spellname[3], nil, nil, nil, true, 240)
            else
                if p.spellname[p.slow + 1] then
                    if p.have_death_spell then
                        aic.ui.NewSpellname(nil, p.spellname[1], nil, nil, nil, true, 240)
                    else
                        aic.ui.NewSpellname(nil, p.spellname[p.slow + 1], nil, nil, nil, true, 240)
                    end
                end
            end
        end
    else
        self:sphit()
    end
    if p.death > 90 then
        p.deathtime = max(0, p.deathtime - 4)
    end
    p.death = 0
    p.nextcollect = 90
end

--又是一堆屎山，插满了各种条件判断
---Special事件
function system:special()
    --[[local p = self.player
    if p.class.special then
        p.class.special(p)
    end]]

    ---闪避函数
    ---@param a number @角度
    ---@param d number @距离
    ---@param IsSecond boolean @是否为第二次闪避
    local function dodge(a, d, IsSecond)
        --好高级循环，爱来自sharp
        --翻译：
        --[[
        repeat t times
        |---variables
        |   |---x:player.x => player.x + cos(a) * d (Precisely), deaccelerate
        |   |---y:player.y => player.y + sin(a) * d (Precisely), deaccelerate
        |---player.x = x
        |---player.y = y
        |---Wait 1 frame(s)
        --]]
        local t = 15
        local _beg_x = player.x
        local x = _beg_x
        local _end_x = player.x + cos(a) * d
        local _w_x = 0
        local _d_w_x = 1 / (t - 1)
        local _beg_y = player.y
        local y = _beg_y
        local _end_y = player.y + sin(a) * d
        local _w_y = 0
        local _d_w_y = 1 / (t - 1)
        player.protect = max(player.protect, t)
        for _ = 1, t do
            if CheckEnhancer(5) or not KeyIsDown('special') then break end
            player.x = max(-192, min(192, x))
            player.y = max(-224, min(224, y))
            task.Wait()
            _w_x = _w_x + _d_w_x
            --x = (_beg_x - _end_x) * (_w_x - 1) ^ 2 + _end_x
            x = max(-192, min(192, (_beg_x - _end_x) * (_w_x - 1) ^ 2 + _end_x)) --防止越界
            _w_y = _w_y + _d_w_y
            --y = (_beg_y - _end_y) * (_w_y - 1) ^ 2 + _end_y
            y = max(-224, min(224, (_beg_y - _end_y) * (_w_y - 1) ^ 2 + _end_y)) --防止越界
        end
        if lstg.var.dodge >= 75 and CheckEnhancer(3) and KeyIsDown('special') and not IsSecond then
            lstg.var.dodge = lstg.var.dodge - 75
            dodge(a, d, true)
        end
    end

    ---@return number @八向角度
    ---获取闪避方向
    local function get8dir()
        local u, d, l, r, a = KeyIsDown('up'), KeyIsDown('down'), KeyIsDown('left'), KeyIsDown('right')
        if u then
            if r then a = 45
            elseif l then a = 135
            else a = 90 end
        elseif d then
            if r then a = 315
            elseif l then a = 225
            else a = 270
            end
        elseif l then a = 180
        elseif r then a = 0
        end
        return a
    end

    local cost = 100
    if CheckEnhancer(3) then cost = 75 end

    if lstg.var.dodge >= cost and player.nextspell <= 0 and not player.dodge then
        New(tasker, function()
            --获取方向
            local a = get8dir()
            if not a and not CheckEnhancer(5) then return end

            --支持决死
            if player.death > 90 then
                player.death = 0
                player.deathtime = max(0, player.deathtime - 4)
            elseif player.death == 0 then
            else
                return
            end

            --变量变更
            lstg.var.dodge = lstg.var.dodge - cost
            player.dodge = true

            --隐藏player
            local hide --兼容自机闪避前就处于hide状态的情况
            if player.hide then hide = true end
            player.hide = true
            player.grazer.hide = true
            New(aic.misc.dodge_player)

            --闪避
            if CheckEnhancer(5) then 
                a = nil
                dodge(0, 0)
            end
            if a then
                if CheckEnhancer(14) then
                    dodge(a, (300 - 100 * player.slow))
                else
                    dodge(a, (150 - 50 * player.slow))
                end
            end

            --变量变更
            local t
            if CheckEnhancer(1) then t = 60
            else t = 30 end
            player.protect = max(player.protect, t)
            player.nextsp = 90
            task.Wait(t)
            player.dodge = false

            --取消隐藏
            if not hide then
                player.hide = false
                player.grazer.hide = false
            end
        end)
    end
end

function system:sphit()
    local p = self.player
    aic.ui.NewSpellname(nil, "「珠辉的素描本」", nil, nil, nil, true, 120)
    aic.sys.SpHit(p)
end

---碰撞回调事件
function system:colli(other)
    local p = self.player
    if (not _debug.cheat) or (not cheat) then
        if p.death == 0 and not p.dialog then
            if p.protect == 0 then
                if CheckEnhancer(1) and other.group ~= GROUP_ENEMY_BULLET and other.group ~= GROUP_INDES then
                    return
                end
                PlaySound("pldead00", 0.5)
                self.taking_damage = other.damage or 50
                p.death = 100
                if p.deathtime then p.death = 90 + p.deathtime end
            end
            if other.group == GROUP_ENEMY_BULLET then
                Del(other)
            end
        end
    else
        local t = player_lib.debug_data
        if t.invincible_enable_collider then
            if p.death == 0 and not p.dialog then
                if p.protect == 0 then
                    if t.invincible_when_hit_play_sound_effect then
                        PlaySound("pldead00", 0.5)
                    end
                    if t.invincible_when_hit_fire_particles then
                        New(player_death_ef, p.x, p.y)
                    end
                end
                if other.group == GROUP_ENEMY_BULLET then
                    if t.invincible_when_hit_delete_object then
                        Del(other)
                    end
                end
            end
        end
    end
end

---更新target目标
function system:findTarget()
    local p = self.player
    if ((not IsValid(p.target)) or (not p.target.colli)) then
        player_class.findtarget(p)
    end
    if not self:keyIsDown("shoot") then
        p.target = nil
    end
end

---注册一个按键
---@param key string @目标按键标识名
function system:regKeys(key)
    self._keys[key] = true
    self._keys_remove[key] = nil
end

---解除注册一个按键
---@param key string @目标按键标识名
function system:unregKeys(key)
    if self._keys[key] then
        self._keys_remove[key] = true
        self._keys[key] = nil
    end
end

---更新自机按键状态
function system:updateKeyState()
    local p = self.player
    local keyState = p.key or KeyState
    for key in pairs(self._keys) do
        --更新已注册按键状态并执行事件组
        self.keyStatePre[key] = self.keyState[key]
        self.keyState[key] = (keyState[key]) or false
        if self.keyState[key] then
            if self.keyStatePre[key] then
                self:doKeyEvent(key, "hold") --保持按住
            else
                self:doKeyEvent(key, "press") --按下
            end
            self:doKeyEvent(key, "down") --按住（包括按下）
        else
            if self.keyStatePre[key] then
                self:doKeyEvent(key, "release") --抬起
            else
                self:doKeyEvent(key, "none") --保持抬起
            end
            self:doKeyEvent(key, "up") --保持抬起（包括抬起）
        end
    end
    for key in pairs(self._keys_remove) do
        --移除解除注册的按键并执行应有的事件组
        if self.keyState[key] then
            self:doKeyEvent(key, "release") --抬起
            self:doKeyEvent(key, "up") --保持抬起（包括抬起）
        end
        self.keyStatePre[key] = nil
        self.keyState[key] = nil
        self._keys_remove[key] = nil
    end
end

---获取自身注册按键是否按下
---@param key string @目标按键标识名
---@return boolean
function system:keyIsDown(key)
    if self._keys[key] or self._keys_remove[key] then
        return self.keyState[key]
    end
end

---获取自身注册按键是否在当前帧按下
---@param key string @目标按键标识名
---@return boolean
function system:keyIsPressed(key)
    if self._keys[key] then
        return self.keyState[key] and not self.keyStatePre[key]
    end
end

---添加按键事件
---@param key string @目标按键标识名
---@param state string @目标按键事件
---@param eventName string @按键事件名
---@param eventLevel number @按键事件优先度
---@param eventFunc function @按键事件函数
---@return boolean @是否发生覆盖
function system:addKeyEvent(key, state, eventName, eventLevel, eventFunc)
    local event = string.format("keyEvent@%s@%s", key, state)
    return self.listener:addEvent(event, eventName, eventLevel, eventFunc)
end

---移除按键事件
---@param key string @目标按键标识名
---@param state string @目标按键事件
---@param eventName string @按键事件名
function system:removeKeyEvent(key, state, eventName)
    local event = string.format("keyEvent@%s@%s", key, state)
    self.listener:remove(event, eventName)
end

---执行按键事件
---@param key string @目标按键标识名
---@param state string @目标按键事件
function system:doKeyEvent(key, state)
    local p = self.player
    local event = string.format("keyEvent@%s@%s", key, state)
    self.listener:Do(event, p, self)
end

---添加帧逻辑事件（前）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addFrameBeforeEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("frameEvent@before", eventName, eventLevel, eventFunc)
end

---移除帧逻辑事件（前）
---@param eventName string @事件名
function system:removeFrameBeforeEvent(eventName)
    self.listener:remove("frameEvent@before", eventName)
end

---执行帧逻辑事件（前）
function system:doFrameBeforeEvent()
    local p = self.player
    self.listener:Do("frameEvent@before", p, self)
end

---添加帧逻辑事件
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addFrameEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("frameEvent@frame", eventName, eventLevel, eventFunc)
end

---移除帧逻辑事件
---@param eventName string @事件名
function system:removeFrameEvent(eventName)
    self.listener:remove("frameEvent@frame", eventName)
end

---执行帧逻辑事件
function system:doFrameEvent()
    local p = self.player
    self.listener:Do("frameEvent@frame", p, self)
end

---添加帧逻辑事件（后）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addFrameAfterEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("frameEvent@after", eventName, eventLevel, eventFunc)
end

---移除帧逻辑事件（后）
---@param eventName string @事件名
function system:removeFrameAfterEvent(eventName)
    self.listener:remove("frameEvent@after", eventName)
end

---执行帧逻辑事件（后）
function system:doFrameAfterEvent()
    local p = self.player
    self.listener:Do("frameEvent@after", p, self)
end

---添加渲染逻辑事件（前）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addRenderBeforeEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("renderEvent@before", eventName, eventLevel, eventFunc)
end

---移除渲染逻辑事件（前）
---@param eventName string @事件名
function system:removeRenderBeforeEvent(eventName)
    self.listener:remove("renderEvent@before", eventName)
end

---执行渲染逻辑事件（前）
function system:doRenderBeforeEvent()
    local p = self.player
    self.listener:Do("renderEvent@before", p, self)
end

---添加渲染逻辑事件（后）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addRenderAfterEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("renderEvent@after", eventName, eventLevel, eventFunc)
end

---移除渲染逻辑事件（后）
---@param eventName string @事件名
function system:removeRenderAfterEvent(eventName)
    self.listener:remove("renderEvent@after", eventName)
end

---执行渲染逻辑事件（后）
function system:doRenderAfterEvent()
    local p = self.player
    self.listener:Do("renderEvent@after", p, self)
end

---添加碰撞逻辑事件（前）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addColliBeforeEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("colliEvent@before", eventName, eventLevel, eventFunc)
end

---移除碰撞逻辑事件（前）
---@param eventName string @事件名
function system:removeColliBeforeEvent(eventName)
    self.listener:remove("colliEvent@before", eventName)
end

---执行碰撞逻辑事件（前）
function system:doColliBeforeEvent(other)
    local p = self.player
    self.listener:Do("colliEvent@before", p, self, other)
end

---添加碰撞逻辑事件（后）
---@param eventName string @事件名
---@param eventLevel number @事件优先度
---@param eventFunc function @事件函数
---@return boolean @是否发生覆盖
function system:addColliAfterEvent(eventName, eventLevel, eventFunc)
    return self.listener:addEvent("colliEvent@after", eventName, eventLevel, eventFunc)
end

---移除碰撞逻辑事件（后）
---@param eventName string @事件名
function system:removeColliAfterEvent(eventName)
    self.listener:remove("colliEvent@after", eventName)
end

---执行碰撞逻辑事件（后）
function system:doColliAfterEvent(other)
    local p = self.player
    self.listener:Do("colliEvent@after", p, self, other)
end
