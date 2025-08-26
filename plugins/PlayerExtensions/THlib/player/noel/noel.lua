---THAIC Added
noel_player = Class(player_class)
--特殊型机体（诺艾儿·柯涅尔）LSC简化版
--和其他几个机体不同，尽量做了在梦摇篮外使用的适配
-------------------------------------------------------
---一些适配
if not aic then
    CheckEnhancer = function() end
    CheckDiff = function() end
end

-------------------------------------------------------
function noel_player:init(slot)
    LoadTexture('noel_player', 'THlib/player/noel/noel.png')
    -----------------------------------------
    LoadImageGroup('noel_player', 'noel_player', 0, 0, 200, 200, 3, 1, 0.5, 0.5)
    -----------------------------------------
    --射击素材，懒得去解包找所以和作为boss的诺艾儿一样用lstg弹型模拟
    CopyImage('noel_arrow', 'arrow_big4')
    CopyImage('noel_arrow_ef', 'arrow_big4')
    CopyImage('noel_fireball', 'ball_light4')
    -----------------------------------------
    LoadImageFromFile('noel_support', 'THlib/player/noel/noel_support.png')
    -----------------------------------------

    -----------------------------------------

    -----------------------------------------
    player_class.init(self)
    self.name = 'Noel'
    self.hspeed = 4.5
    self.lspeed = 2.5
    self.imgs = {}
    self.A = 0.5
    self.B = 0.5
    self.hscale = 0.6
    self.vscale = 0.6
    --纯粹占位用的假行走图
    if slot and slot == 2 and jstg.players[1].name == self.name then
        for i = 1, 24 do self.imgs[i] = 'img_void' end
    else
        for i = 1, 24 do self.imgs[i] = 'img_void' end
    end
    self.slist =
    {
        { nil,                nil,              nil,            nil },
        { { 0, 36, 0, 24 },   nil,              nil,            nil },
        { { -32, 0, -12, 24 }, { 32, 0, 12, 24 }, nil,          nil },
        { { -32, -8, -16, 20 }, { 0, -32, 0, 28 }, { 32, -8, 16, 20 }, nil },
        { { -36, -12, -16, 20 }, { -16, -32, -6, 28 }, { 16, -32, 6, 28 }, { 36, -12, 16, 20 } },
        { { -36, -12, -16, 20 }, { -16, -32, -6, 28 }, { 16, -32, 6, 28 }, { 36, -12, 16, 20 } },
    }
    self.anglelist =
    {
        { 90,  90,  90, 90 },
        { 90,  90,  90, 90 },
        { 100, 80,  90, 90 },
        { 100, 90,  80, 90 },
        { 110, 100, 80, 70 },
    }
    self.default_dmglist = { 0.3, 0.3, 0.3, 0.3 }
    self.dmglist = { 0.3, 0.3, 0.3, 0.3 }
    self.spellname = { '箭咒「纯白之弓」', '爆咒「地面炸弹」', '引咒「聚能火球」' }
    self.deathtime = 30 --长到令人睡着再醒来的决死时间
    self.default_deathtime = self.deathtime
    self._img = 'noel_player1' --真正渲染用的行走图
    self.cd = 8 --近战攻击cd
    self.default_cd = self.cd
    self.magic_type = 0 --使用魔法种类
    self.prechant_point = 0 --吟唱前摇
    self.chant_point = 0 --吟唱已消耗魔力
    self.max_cp = { 33, 75, 80, 83 } --各魔法所需魔力
    self.is_boss = false --是否是LSC演出中自机
    ---摘自旧版Linput.lua
    ---
    ---判定某个键盘按键是否在当前帧被释放（rep键位版）
    ---@param key string @按键名称
    ---@return boolean @是否在当前帧被释放
    function self.KeyIsReleased(key)
        key = setting.keys[key]
        if key then
            return KeyStatePre[key] and (not KeyState[key])
        else
            return false
        end
    end
end

-------------------------------------------------------
function noel_player:shoot()
    if self.is_boss then return end
    local s = Player_scale or 1
    PlaySound('plst00', 0.3, self.x / 1024)
    self.nextshoot = 4
    self.cd = self.cd - 1
    local dmgfix3 = 1 --插件的加伤
    if CheckEnhancer(16) then
        if CheckDiff(4) then
            self.nextshoot = int(self.nextshoot * 2 / 3)
        end
        dmgfix3 = 1.5
    end
    New(noel_bullet_arrow_small, self.x + 10, self.y, 24, 90, 2 * dmgfix3)
    New(noel_bullet_arrow_small, self.x - 10, self.y, 24, 90, 2 * dmgfix3)
    if self.support > 0 then
        if self.slow == 1 or self.is_boss then
            for i = 1, 4 do
                if self.sp[i] and self.sp[i][3] > 0.5 then
                    New(noel_fireball_small, self.supportx + self.sp[i][1] - 3,
                        self.supporty + self.sp[i][2] * s, 24, 90, self.dmglist[i] * dmgfix3 * 0.8)
                    New(noel_fireball_small, self.supportx + self.sp[i][1] + 3,
                        self.supporty + self.sp[i][2] * s, 24, 90, self.dmglist[i] * dmgfix3 * 0.8)
                end
            end
        else
            if self.cd == 0 then
                New(noel_melee_attack, self.x, self.y, 150, 50 * dmgfix3)
                self.cd = self.default_cd
            end
        end
    end
end
-------------------------------------------------------
function noel_player:frame()
    player_class.frame(self)
    local intv = 8
    local i = int((self.timer % (intv * 3)) / intv) + 1
    self._img = 'noel_player' .. i
    if self.is_boss then
        self.nextshoot = 114514
        self.nextspell = 114514
        self.nextsp = 114514
        return
    end
    for i = 1, 4 do
        local power = int(lstg.var.power / 100)
        local p
        if power >= i + 1 then p = 1
        else p = 0.5 + lstg.var.power % 100 / 200 end
        self.dmglist[i] = self.default_dmglist[i] * p
    end
    if KeyIsDown('spell') then
        if KeyIsDown('shoot') then
            self.system:burst()
        else
            if self.watershard then
                self.watershard:fire()
            else
                if self.prechant_point < 30 then
                    if KeyIsDown('up') then
                        self.magic_type = 4
                    elseif KeyIsDown('left') or KeyIsDown('right') then
                        self.magic_type = 2
                    elseif KeyIsDown('down') then
                        self.magic_type = 3
                    end
                    if not IsValid(self.spell_ui) then
                        self.spell_ui = New(noel_spell_ui, self)
                    end
                    self.prechant_point = self.prechant_point + 1
                else
                    self.chant_point = min(self.chant_point + 1, self.max_cp[self.magic_type])
                    self.power = max(0, self.power - 1)
                end
            end
        end
    else
        self.prechant_point = 0
    end
    if self.KeyIsReleased('spell') then
        if self.chant_point == self.max_cp[self.magic_type] then
            self.spelling_flag = true
        end
    end
end
-------------------------------------------------------
function noel_player:spell()
    if self.is_boss then return end
    if not self.spelling_flag then return end
    local p = 0
    if CheckEnhancer(9) then p = p + 60 end
    self.collect_line = self.collect_line - 300
    local dir = self.get_dir()
    if aic then
        if self.magic_type == 1 then
            New(noel_arrow_big, self.x, self.y, dir, 250)
        elseif self.magic_type == 2 then
            New(noel_fireball_big, self.x, self.y, dir, 400)
        elseif self.magic_type == 3 then
            New(noel_dropbomb, self.x, self.y, dir, 400)
        elseif self.magic_type == 4 then
            self.watershard = New(noel_watershard, self)
        end
    else
    end
    self.chant_point = 0
    New(tasker, function()
        task.Wait(90)
        self.collect_line = self.collect_line + 300
    end)
    self.protect = self.protect + p
end

if not noel_player.special then
    function noel_player:special()
        
    end
end

-------------------------------------------------------
function noel_player:render()
    local s = Player_scale or 1
    local s2 = 0.5 + 0.2 * sin(3 * self.timer)
    SetImageState('noel_support', '', Color(255, 0, 255, 255))
    for i = 1, 4 do
        if self.sp[i] and self.sp[i][3] > 0.5 then
            Render('noel_support', self.supportx + self.sp[i][1] * s, self.supporty + self.sp[i][2] * s, self.timer * 3, s * s2)
        end
    end
    --因为行走图数量不足所以选择手动渲染
    Render(self._img, self.x, self.y, 0, self.hscale * s, self.vscale * s)
    if not self.is_boss then
        SetImageState('white', '', Color(150, 255, 255, 255))
        RenderRect('white', self.x - 20, self.x + 40, self.y - 30, self.y - 20)
        SetImageState('white', '', Color(255, 112, 127, 155))
        RenderRect('white', self.x - 20, self.x + 40 * lstg.var.power / lstg.var.maxpower, self.y - 30, self.y - 20)
        SetImageState('white', '', Color(255, 127, 153, 156))
        RenderRect('white', self.x + 40 * lstg.var.power / lstg.var.maxpower * self.chant_point / self.max_cp[self.magic_type],
            self.x + 40 * lstg.var.power / lstg.var.maxpower, self.y - 30, self.y - 20)
    end
end

-------------------------------------------------------
noel_arrow_small = Class(player_bullet_straight)

function noel_arrow_small:kill()
    New(noel_arrow_ef, self.x, self.y)
end

-------------------------------------------------------
noel_fireball_small = Class(player_bullet_straight)

function noel_fireball_small:kill()
    New(noel_fireball_ef, self.x, self.y)
end

-------------------------------------------------------
noel_arrow_big = Class(player_bullet_straight)

function noel_arrow_big:init(img, x, y, v, angle, dmg)
    player_bullet_straight.init(self, img, x, y, v, angle, dmg)
    self.group = GROUP_SPELL
    self.hscale = 2
    self.vscale = 2
    self.a = 32
    self.b = 16
end

function noel_arrow_big:kill()
    New(noel_arrow_ef, self.x, self.y)
end

function noel_arrow_big:colli()
    if other.group == GROUP_ENEMY_BULLET then
        Del(other)
    end
end

-------------------------------------------------------
noel_fireball_big = Class(player_bullet_straight)

function noel_fireball_big:kill()
    New(noel_fireball_ef, self.x, self.y, true)
end

-------------------------------------------------------
noel_arrow_ef = Class(object)

function noel_arrow_ef:init(x, y)
    self.x = x
    self.y = y
    self.rot = 90
    self.img = 'noel_arrow'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.group = GROUP_GHOST
    self.vy = 2.25
end

function noel_arrow_ef:frame()
    if self.timer == 15 then
        self.y = 600
        Del(self)
    end
end

function noel_arrow_ef:render()
    SetImageState(self.img, '', Color(255 - self.timer * 255 / 15, 255, 255, 255))
    object.render(self)
end

-------------------------------------------------------
noel_fireball_ef = Class(object)

function noel_fireball_ef:init(x, y)
    self.x = x
    self.y = y
    self.rot = 90
    self.img = 'noel_arrow'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.group = GROUP_GHOST
    self.vy = 2.25
end

function noel_fireball_ef:frame()
    if self.timer == 15 then
        self.y = 600
        Del(self)
    end
end

function noel_fireball_ef:render()
    SetImageState(self.img, '', Color(255 - self.timer * 255 / 15, 255, 255, 255))
    object.render(self)
end

-------------------------------------------------------

AddPlayerToPlayerList('Noel Cornehl', 'noel_player', 'Noel')
