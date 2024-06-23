---THAIC Added
---千幻 念雪 Chimabo Nenyuki v1.11aic by Muki
---自设自机
---改自魔理沙机体
---广范围/自动追踪型
---很好用，大概
---即使不正对boss也有可观伤害

---版本更新记录
---v1.10a
---完善了自机设定与介绍
---完善了符卡
---取消了原灵击，新灵击制作中
---现在主炮瞄准boss时子弹仍按原来的way数分散，而不是全部为Angle(self,_boss),这将导致高速时主炮火力降低
---现在高速与低速状态会释放不同的符卡
---修复了不兼容Hana AI的bug
---v1.10aic
---该版本为东方梦摇篮特供版，含部分特殊系统相关内容
---v1.11aic
---修复了高速时副炮追踪系统在场上仅有两个敌人时行为异常的问题，后续将于通用版中一同更新
---将default_slist改为由sp.copy复制
---v1.12aic
---将判定点渲染移至主渲染中

---已知bug
---高速时副炮追踪系统不稳定

nenyuki_player = Class(player_class)

function nenyuki_player:init(slot)
    -----------------------------------------
    --自机
    LoadTexture('nenyuki_player', 'THlib\\player\\nenyuki\\nenyuki.png')
    LoadImageGroup('nenyuki_player', 'nenyuki_player', 0, 0, 32, 48, 8, 3, 1, 1)
    --自定义判定点
    LoadImageFromFile('nenyuki_player_aura', 'THlib\\player\\nenyuki\\nenyuki_player_aura.png')
    -----------------------------------------
    --主炮
    LoadImage('nenyuki_bullet_main', 'nenyuki_player', 0, 144, 32, 16, 16, 16)
    LoadAnimation('nenyuki_bullet_main_ef', 'nenyuki_player', 0, 144, 32, 16, 4, 1, 4)
    SetImageState('nenyuki_bullet_main', '', Color(0x80FFFFFF))
    -----------------------------------------
    --副炮
    LoadImage('nenyuki_support', 'nenyuki_player', 144, 144, 16, 16)
    LoadTexture('nenyukiLaser', 'THlib\\player\\nenyuki\\nenyukiLaser.png')
    LoadTexture('nenyukiLaser_hited', 'THlib\\player\\nenyuki\\nenyukiLaser_hited.png')
    LoadTexture('nenyukiLaser2', 'THlib\\player\\nenyuki\\nenyukiLaser2.png')
    LoadImageFromFile('nenyuki_hit_par', 'THlib\\player\\nenyuki\\nenyuki_hit_par.png')
    LoadImage('nenyuki_laser_light', 'nenyuki_player', 224, 224, 32, 32)
    SetImageState('nenyuki_laser_light', 'mul+add', Color(0xFFFFFFFF))
    LoadAnimation('nenyuki_laser_ef', 'nenyuki_player', 64, 224, 32, 32, 4, 1, 2)
    SetAnimationState('nenyuki_laser_ef', 'mul+add', Color(0x80FFFFFF))
    LoadPS('nenyuki_hit', 'THlib\\player\\nenyuki\\nenyuki_hit.psi', 'nenyuki_hit_par')
    -----------------------------------------
    --高速符卡
    LoadPS('nenyuki_sp_ef', 'THlib/player/nenyuki/nenyuki_sp_ef.psi', 'parimg2')
    -----------------------------------------
    --低速符卡
    LoadTexture('nenyuki_spark', 'THlib/player/nenyuki/nenyuki_spark.png')
    LoadImage('nenyuki_spark', 'nenyuki_spark', 0, 64, 256, 128, 0, 0)
    SetImageState('nenyuki_spark', 'mul+add', Color(0xFFFFFFFF))
    SetImageCenter('nenyuki_spark', 0, 64)
    --LoadImage('nenyuki_spark_wave','nenyuki_spark',256,0,96,256,96,180)
    --SetImageState('nenyuki_spark_wave','mul+add',Color(0xFFFFFFFF))
    -----------------------------------------
    --灵击
    -----------------------------------------
    player_class.init(self)
    self.name = 'Nenyuki'
    self.hspeed = 4.7
    self.lspeed = 2.5
    self.A = 0.8
    self.B = 0.75             --随便写的，不要问为什么（
    self.support_trail = 1000 --子机追踪速度
    self.targetlist = {}
    self.imgs = {}
    for i = 1, 24 do self.imgs[i] = 'nenyuki_player' .. i end
    self.offset = { 600, 600, 600, 600 }
    --需要注意，这里的子机位置表中高速为绝对坐标，低速为相对坐标
    self.slist =
    {
        { nil,                    nil,                     nil,                    nil },
        { { -192, 180, 0, 29 },   nil,                     nil,                    nil },
        { { -192, 180, -8, 23 },  { -192, 150, 8, 23 },    nil,                    nil },
        { { -192, 180, -10, 24 }, { -192, 150, 0, 32 },    { -192, 120, 10, 24 },  nil },
        { { -192, 180, -15, 20 }, { -192, 150, -7.5, 29 }, { -192, 120, 7.5, 29 }, { -192, 90, 15, 20 } },
        { { -192, 180, -15, 20 }, { -192, 150, -7.5, 29 }, { -192, 120, 7.5, 29 }, { -192, 90, 15, 20 } },
    }
    --默认子机位置，由于子机位置表会变更所以有必要存一份
    self.default_slist = sp.copy(self.slist)
    self.anglelist = {}
    for i = 1, 5 do self.anglelist[i] = { 0, 0, 0, 0 } end
    self.targetlist = {}
    self.debug = false
    self.default_dmglist = { 0.2, 0.2, 0.2, 0.2 }
    self.dmglist = { 0.2, 0.2, 0.2, 0.2 }
    self.spellname = { '魔梦「梦魂幻想」', '恋星「星魇火花」' }
    self.deathtime = 4 --约等于没有
    self.default_deathtime = self.deathtime
    self.aura_rot = 0
end

-------------------------------------------------------
function nenyuki_player:frame()
    --自机帧逻辑
    -----------------------------------------
    --判定点自旋
    self.aura_rot = self.aura_rot + 2
    -----------------------------------------
    --场上没有敌人或miss时子机自动回归原位
    local clear = true
    for i, o in ipairs(self.targetlist) do
        if IsValid(o) then clear = false end
    end
    local num = min(5, int(lstg.var.power / 100) + 1)
    if self.death ~= 0 or clear then
        for i = 1, 4 do
            if i < num and self.sp[i] then
                self.sp[i][2] = self.default_slist[num][i][2]
            end
        end
    end
    -----------------------------------------
    --自动追踪
    if self.support > 0 then nenyuki_findtarget(self) end
    -----------------------------------------
    --改变最大激光长度以美化视觉效果
    if self.slow == 0 then
        for i = 1, 5 do self.anglelist[i] = { 0, 0, 0, 0 } end
        self.offset = { 384, 384, 384, 384 }
    else
        for i = 1, 5 do self.anglelist[i] = { 90, 90, 90, 90 } end
        self.offset = { 600, 600, 600, 600 }
    end
    -----------------------------------------
    --确保子机不出屏
    --[[for i, o in ipairs(self.targetlist) do
        if IsValid(o) and abs(o.y) > 224 then table.remove(self.targetlist, i) end
    end]]
    for i = 1, 4 do
        if i < num then
            if sign(self.slist[num][i][2]) > 0 then
                self.slist[num][i][2] = min(self.slist[num][i][2], 224)
            else
                self.slist[num][i][2] = max(self.slist[num][i][2], -224)
            end
        end
    end
    -----------------------------------------
    --设置主炮目标
    if IsValid(_boss) then
        self.main_target = self.main_target or _boss
    end
    -----------------------------------------
    --梦摇篮特殊系统，火力受小数点后数字影响
    for i = 1, 4 do
        local power = int(lstg.var.power / 100)
        local p
        if power >= i + 1 then p = 1
        else p = 0.5 + lstg.var.power % 100 / 200 end
        self.dmglist[i] = self.default_dmglist[i] * p
    end
    -----------------------------------------
    player_class.frame(self)
end

-------------------------------------------------------
function nenyuki_player:shoot()
    --自机射击
    local nextshoot = 4
    local dmgfix3 = 1 --插件的加伤
    if CheckEnhancer(16) then
        if CheckDiff(4) then
            nextshoot = int(nextshoot * 2 / 3)
        end
        dmgfix3 = 1.5
    end
    if self.timer % nextshoot == 0 then
        PlaySound('plst00', 0.15, self.x / 1024)
        local da
        local ba
        if IsValid(self.main_target) then
            da = 3.75
            ba = Angle(self, self.main_target) - 90 --为啥是-90？好问题，我也不知道（大概是和Angle有关
        else
            da = 7.5
            ba = 0
        end
        --为什么主炮也分高低速啊（恼）
        if self.slow == 0 then
            for i = 1, 7 do
                local a = 90 - da * 8 + i * da * 2 + ba
                New(nenyuki_bullet_main, 'nenyuki_bullet_main', self.x, self.y, 24, a, 3 / 7)
            end
        else
            for i = 1, 3 do
                local a = 90 - da * 2 + i * da + ba
                New(nenyuki_bullet_main, 'nenyuki_bullet_main', self.x, self.y, 24, a, 3 / 3)
            end
        end
    end
    --local power = int(lstg.var.power / 100)
    if self.support > 0 then
        if self.timer % (nextshoot * 3) == 0 then PlaySound('lazer02', 0.025) end
        local dmgfix2 = 1 --因为激光改不了射速所以只能直接加伤
        if nextshoot < 4 then dmgfix2 = 1.5 end
        local num = 30 / (self.support + 1)
        for i = 1, 4 do
            --				local angle=105-i*num
            local angle = self.anglelist[min(int(lstg.var.power / 100) + 1, 5)][i]
            if self.sp[i] and self.sp[i][3] > 0.5 then
                local target = nil
                local other = {}
                local x, y
                --确保激光判定位置正确
                if self.slow == 0 then
                    x, y = self.sp[i][1], self.sp[i][2]
                else
                    x, y = self.supportx + self.sp[i][1], self.supporty + self.sp[i][2]
                end
                for j, o in ObjList(GROUP_ENEMY) do
                    if o.colli and nenyuki_IsInLaser(x, y, angle, o, 16) then
                        local d = Dist(o.x, o.y, x, y)
                        if d < self.offset[i] then
                            target = o
                            self.offset[i] = d
                        else
                            --高速时激光具有贯通效果，但其他单位受到伤害仅为直接击中的单位受到伤害的60%
                            if self.slow == 0 then table.insert(other, o) end
                        end
                    end
                end
                for j, o in ObjList(GROUP_NONTJT) do
                    if o.colli and nenyuki_IsInLaser(x, y, angle, o, 16) then
                        local d = Dist(o.x, o.y, x, y)
                        if d < self.offset[i] then
                            target = o
                            self.offset[i] = d
                        else
                            if self.slow == 0 then table.insert(other, o) end
                        end
                    end
                end
                if target then
                    self.offset[i] = max(0, self.offset[i] - target.b)
                    New(nenyuki_laser_hit, x + self.offset[i] * cos(angle), y + self.offset[i] * sin(angle))
                    if self.slow == 1 and self.timer % 16 == 0 then
                        PlaySound('msl2', 0.3)
                        local a, r = ran:Float(0, 360), ran:Float(0, 6)
                        New(nenyuki_laser_ef, target.x + r * cos(a), target.y + r * sin(a), self.dmglist[i] * 4, 5, target)
                    end
                    local dmgfix = 1 --修正低速时过剩伤害
                    if self.slow == 1 then dmgfix = 0.5 end
                    if target.class.base.take_damage then
                        target.class.base.take_damage(target, self.dmglist[i] * 5 / 4 * dmgfix * dmgfix2 * dmgfix3)
                    end
                    if other then
                        for k, v in ipairs(other) do
                            if v.class.base.take_damage then
                                v.class.base.take_damage(v, self.dmglist[i] * 3 / 4 * dmgfix2 * dmgfix3)
                            end
                        end
                    end
                    if target.maxhp and target.hp > target.maxhp * 0.1 then
                        PlaySound('damage00', 0.3, target.x / 1024)
                    else
                        PlaySound('damage01', 0.6, target.x / 1024)
                    end
                end
            end
        end
    end
end

-------------------------------------------------------
function nenyuki_player:spell()
    --自机符卡
    local p = 360
    if CheckEnhancer(9) then p = p + 60 end
    self.collect_line = self.collect_line - 300
    New(tasker, function()
        task.Wait(90)
        self.collect_line = self.collect_line + 300
    end)
    New(player_spell_mask, 165, 58, 233, 30, 240, 30)
    if self.slow == 0 then
        PlaySound('slash', 1.0)
        PlaySound('nep00', 1.0)
        for _, v in ipairs({ 0, 0, 120, 120, 240, 240 }) do
            New(nenyuki_sp_ef, v, 1.5, self)
            New(nenyuki_sp_ef, v, -1.5, self)
        end
        misc.ShakeScreen(210, 3)
        New(tasker, function()
            New(bullet_killer, self.x, self.y)
            local rot1 = 0
            local rot2 = 0
            for i = 1, 120 do
                rot1 = rot1 + 3
                rot2 = rot2 - 3
                for i = 1, 3 do
                    local a1 = rot1 + 180 + i * 360 / 3
                    local a2 = rot2 + 180 + i * 360 / 3
                    New(player_bullet_hide, 16, 16, self.x, self.y, 12, a1, 0.3)
                    New(player_bullet_hide, 16, 16, self.x, self.y, 12, a2, 0.3)
                    for j = 1, 8 do
                        New(player_bullet_hide, 16, 16, self.x, self.y, 12, a1 + 2.1 * j, 0.45, 2 * j)
                        New(player_bullet_hide, 16, 16, self.x, self.y, 12, a1 - 2.1 * j, 0.45, 2 * j)
                        New(player_bullet_hide, 16, 16, self.x, self.y, 12, a2 + 2.1 * j, 0.45, 2 * j)
                        New(player_bullet_hide, 16, 16, self.x, self.y, 12, a2 - 2.1 * j, 0.45, 2 * j)
                    end
                end
                task.Wait(2)
            end
            PlaySound('slash', 1.0)
            New(bullet_killer, self.x, self.y)
        end)
        self.nextspell = 240
        self.protect = p
    else
        self.spark = true
        self.slowlock = true
        self.lock = true
        PlaySound('slash', 1.0)
        PlaySound('nep00', 1.0)
        self.nextspell = 300
        self.nextshoot = 300
        self.protect = p
        local radius = 50
        local omiga = 1.5
        for i = 1, 5 do
            local rot = 18 + (i - 1) * 72
            New(nenyuki_spark, radius * cos(rot), radius * sin(rot), radius, rot, omiga, 30, 240, 30, self)
        end
        --		self.hspeed=0
        --		self.lspeed=0
        New(tasker, function()
            for i = 1, 27 do
                --因为魔炮在转，所以干脆就没弄冲击波了，伤害判定直接由魔炮负责
                --New(nenyuki_spark_wave,self.x,self.y-16,90,12,0.9,self)
                task.Wait(10)
            end
            New(bullet_killer, self.x, self.y)
            PlaySound('slash', 1.0)
            self.slowlock = false
            self.lock = false
            self.spark = false
            --			player.hspeed=4.7
            --			player.lspeed=2.5
        end)
        misc.ShakeScreen(270, 5)
    end
end

-------------------------------------------------------
--[[function nenyuki_player:special()
	--自机灵击（制作中）
	if self.debug then
		PlaySound('slash',0.8)
		for i,o in ObjList(GROUP_ENEMY) do Kill(o) end
		for i,o in ObjList(GROUP_NONTJT) do Kill(o) end
		for i,o in ObjList(GROUP_ENEMY_BULLET) do Del(o) end
	elseif lstg.var.power >= 200 then
		PlaySound('slash',0.8)
		New(bullet_killer,self.x,self.y)
		for i,o in ObjList(GROUP_ITEM) do o.attract = 8 end
		lstg.var.power=lstg.var.power-100
		self.nextsp=90
		self.protect=120
	end
end]]
-------------------------------------------------------
function nenyuki_player:render()
    --自机、子机和激光的渲染
    local sz = 1.2 + 0.1 * sin(self.timer * 0.2)
    if not self.spark then
        --support
        SetImageState('nenyuki_support', '', Color(0xFFFFFFFF))
        for i = 1, 4 do
            if self.sp[i] then
                if self.slow == 1 then
                    Render('nenyuki_support', self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 0,
                        self.sp[i][3], 1)
                else
                    Render('nenyuki_support', self.sp[i][1], self.sp[i][2], 0, self.sp[i][3], 1)
                    Render('nenyuki_support', -self.sp[i][1], self.sp[i][2], 0, self.sp[i][3], 1)
                end
            end
        end
        --support deco
        SetImageState('nenyuki_support', '', Color(0x80FFFFFF))
        for i = 1, 4 do
            if self.sp[i] then
                if self.slow == 1 then
                    Render('nenyuki_support', self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 0,
                        self.sp[i][3] * sz, sz)
                else
                    Render('nenyuki_support', self.sp[i][1], self.sp[i][2], 0, self.sp[i][3] * sz, sz)
                    Render('nenyuki_support', -self.sp[i][1], self.sp[i][2], 0, self.sp[i][3] * sz, sz)
                end
            end
        end
    end
    if self.support > 0 and self.fire == 1 and self.nextshoot <= 0 then
        local num = 30 / (self.support + 1)
        local timer = self.timer * 16
        for i = 1, 4 do
            local angle = self.anglelist[int(lstg.var.power / 100) + 1][i]
            if self.sp[i] and self.sp[i][3] > 0.5 then
                local x, y
                if self.slow == 0 then
                    x, y = self.sp[i][1], self.sp[i][2]
                    --美化高速时击中效果
                    if self.offset[i] < 224 then
                        nenyuki_CreateLaser(x, y, angle, 16, timer, Color(0x804040FF), self.offset[i])
                        nenyuki_CreateLaser(x + self.offset[i], y, angle, 16, timer, Color(0x80FFFFFF),
                            384 - self.offset[i], 'nenyukiLaser_hited')
                    else
                        nenyuki_CreateLaser(x, y, angle, 16, timer, Color(0x80FFFFFF), 600)
                    end
                else
                    x, y = self.supportx + self.sp[i][1], self.supporty + self.sp[i][2]
                    if self.offset[i] < 600 then
                        nenyuki_CreateLaser(x, y, angle, 16, timer, Color(200, 165, 58, 233), self.offset[i],
                            'nenyukiLaser2')
                    else
                        nenyuki_CreateLaser(x, y, angle, 16, timer, Color(200, 165, 206, 255), 600, 'nenyukiLaser2')
                    end
                end
                Render('nenyuki_laser_light', x, y, self.timer * 5, 1 + 0.4 * sin(self.timer * 45 + i * 90))
                if self.slow == 0 then
                    Render('nenyuki_laser_light', -x, y, self.timer * 5, 1 + 0.4 * sin(self.timer * 45 + i * 90))
                end
            end
        end
    end
    player_class.render(self)
    --判定点渲染
    SetImageState('nenyuki_player_aura', '', Color(self.lh * 255, 255, 255, 255))
    Render('nenyuki_player_aura', self.x, self.y, self.aura_rot)
    Render('nenyuki_player_aura', self.x, self.y, -self.aura_rot)
end

-------------------------------------------------------
--下面是自机相关组件定义
-------------------------------------------------------
--高速时激光产生的爆风效果
nenyuki_laser_ef = Class(object)

function nenyuki_laser_ef:init(x, y, dmg, t)
    self.x = x
    self.y = y
    self.a = 4
    self.b = 4
    self.img = 'nenyuki_laser_ef'
    self.group = GROUP_PLAYER_BULLET
    self.dmg = dmg / 20
    self.killflag = true
    self.layer = LAYER_PLAYER_BULLET
    self.mute = true
    self.t = t
end

function nenyuki_laser_ef:frame()
    if self.timer == 3 and self.t > 0 then
        local a, r = ran:Float(0, 360), ran:Float(8, 16)
        New(nenyuki_laser_ef, self.x + r * cos(a), self.y + r * sin(a), self.dmg * 20, self.t - 1)
    end
    if self.timer == 15 then Del(self) end
end

-------------------------------------------------------
--主炮子弹（追踪写在shoot里，不在这里）
nenyuki_bullet_main = Class(player_bullet_straight)

function nenyuki_bullet_main:kill()
    for _, v in ipairs({ 3, 4, 5 }) do
        New(nenyuki_bullet_main_ef, self.x, self.y, self.rot, v)
    end
end

-------------------------------------------------------
--主炮击中效果
nenyuki_bullet_main_ef = Class(object)

function nenyuki_bullet_main_ef:init(x, y, rot, v)
    self.x = x
    self.y = y
    self.rot = rot
    self.vx = v * cos(rot)
    self.vy = v * sin(rot)
    self.img = 'nenyuki_bullet_main_ef'
    self.layer = LAYER_PLAYER_BULLET + 50
end

function nenyuki_bullet_main_ef:frame()
    if self.timer == 7 then Del(self) end
end

function nenyuki_bullet_main_ef:render()
    SetAnimationState('nenyuki_bullet_main_ef', '', Color(128 - 8 * self.timer, 255, 255, 255))
    object.render(self)
end

-------------------------------------------------------
--激光击中效果
nenyuki_laser_hit = Class(object)

function nenyuki_laser_hit:init(x, y)
    self.x = x
    self.y = y
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER_BULLET + 60
    self.img = 'nenyuki_hit'
end

function nenyuki_laser_hit:frame()
    if self.timer == 4 then
        ParticleStop(self)
    end
    if self.timer == 10 then Del(self) end
end

-------------------------------------------------------
--高速bomb粒子效果
nenyuki_sp_ef = Class(object)

function nenyuki_sp_ef:init(rot, omiga, player)
    self.layer = LAYER_PLAYER - 1
    self.rot = rot
    self.o = omiga
    self.img = 'nenyuki_sp_ef'
    self.player = player
end

function nenyuki_sp_ef:frame()
    self.x = self.player.x
    self.y = self.player.y
    --到底为什么omiga非得写frame里啊（恼
    self.omiga = self.o
    if self.timer > 240 then ParticleSetEmission(self, ParticleGetEmission(self) - 10) end
    if self.timer == 480 then Del(self) end
end

-------------------------------------------------------
--低速bomb魔炮
nenyuki_spark = Class(object)

function nenyuki_spark:init(x, y, radius, rot, omiga, turnOnTime, wait, turnOffTime, p)
    self.player = p
    self.x = x
    self.y = y
    self.r = radius
    self.rot = rot
    self.omiga = omiga
    self.img = 'nenyuki_spark'
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    --判定随便写的，反正差不多都是全屏
    self.a = 200
    self.b = 500
    self.dmg = 0.5
    --伤害修正
    --不过实在没太大必要修，贴脸秒boss也挺好的，反正你都扔b了不是吗（
    --咲夜低速b全中也有700伤啊（
    --[[if IsValid(_boss) then
		self.dmg=self.dmg*Dist(p,_boss)/275
	end]]
    self.rect = true
    self.killflag = true
    self.bound = false
    self.hscale = 2.5
    task.New(self, function()
        --莫名其妙的不能直接渲染，只能再加一个obj了
        self.support = New(nenyuki_spell_support, self)
        for i = 0, turnOnTime do
            self.vscale = 2.5 * i / turnOnTime
            task.Wait()
        end
        task.Wait(wait)
        for i = 0, turnOffTime do
            self.vscale = 2.5 * (1 - i / turnOffTime)
            task.Wait()
        end
        Del(self)
    end)
    task.New(self, function()
        local t = turnOnTime + wait + turnOffTime
        for i = 1, t do
            New(bullet_killer, self.x, self.y, false)
            task.Wait()
        end
    end)
end

function nenyuki_spark:frame()
    task.Do(self)
    self.x = self.player.x + self.r * cos(self.rot)
    self.y = self.player.y + self.r * sin(self.rot)
end

function nenyuki_spark:del()
    Del(self.support)
end

-------------------------------------------------------
--因为莫名奇妙不能直接在spark的render里render而单独写的support
--就是一贴图
nenyuki_spell_support = Class(object)

function nenyuki_spell_support:init(master)
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER_BULLET + 5
    self.img = 'nenyuki_support'
    self.master = master
    self.x = master.x
    self.y = master.y
    self.bound = false
end

function nenyuki_spell_support:frame()
    self.x = self.master.x
    self.y = self.master.y
end

-------------------------------------------------------
--判定目标是否在激光中
--应该不会有人看不出来这是点到直线的距离公式吧
function IsInLaser(x0, y0, a, unit, w)
    local a1 = a - Angle(x0, y0, unit.x, unit.y)
    if a % 180 == 90 then
        if abs(unit.x - x0) < ((unit.a + unit.b + w) / 2) and cos(a1) >= 0 then
            return true
        else
            return false
        end
    else
        local A = tan(a)
        local C = y0 - A * x0
        if abs(A * unit.x - unit.y + C) / hypot(A, 1) < ((unit.a + unit.b + w) / 2) and cos(a1) >= 0 then
            return true
        else
            return false
        end
    end
end

-------------------------------------------------------
--修改过后用于处理高速时横向激光的IsInLaser，由于只用处理激光角度为0的情况，复杂度大幅下降
function nenyuki_IsInLaser(x0, y0, a, unit, w)
    if a == 0 then
        if abs(unit.y - y0) - unit.b < w then
            return true
        else
            return false
        end
    else
        return IsInLaser(x0, y0, a, unit, w)
    end
end

-------------------------------------------------------
--渲染激光
function nenyuki_CreateLaser(x, y, a, w, t, c, offset, tex)
    local width = w / 2
    local n = int(offset / 256)
    local length = t % 256
    local endl = int(offset - n * 256)

    local w_x = width * cos(a)
    local w_y = width * sin(a)
    local tex = tex or 'nenyukiLaser'
    local blend = blend or 'mul+add'

    for i = 1, n do
        local vx1 = x + (length + 256 * (i - 1)) * cos(a)
        local vy1 = y + (length + 256 * (i - 1)) * sin(a)
        local vx2 = x + 256 * i * cos(a)
        local vy2 = y + 256 * i * sin(a)
        local vx3 = x + 256 * (i - 1) * cos(a)
        local vy3 = y + 256 * (i - 1) * sin(a)
        RenderTexture(
            tex, blend,
            { vx1 - w_y, vy1 + w_x, 0.5, 0, 0, c },
            { vx2 - w_y, vy2 + w_x, 0.5, 256 - length, 0, c },
            { vx2 + w_y, vy2 - w_x, 0.5, 256 - length, 16, c },
            { vx1 + w_y, vy1 - w_x, 0.5, 0, 16, c })
        RenderTexture(
            tex, blend,
            { vx3 - w_y, vy3 + w_x, 0.5, 256 - length, 0, c },
            { vx1 - w_y, vy1 + w_x, 0.5, 256, 0, c },
            { vx1 + w_y, vy1 - w_x, 0.5, 256, 16, c },
            { vx3 + w_y, vy3 - w_x, 0.5, 256 - length, 16, c })
    end

    local vx2 = x + (endl + 256 * n) * cos(a)
    local vy2 = y + (endl + 256 * n) * sin(a)
    local vx3 = x + 256 * n * cos(a)
    local vy3 = y + 256 * n * sin(a)
    if length <= endl then
        local vx1 = x + (length + 256 * n) * cos(a)
        local vy1 = y + (length + 256 * n) * sin(a)
        RenderTexture(
            tex, blend,
            { vx1 - w_y, vy1 + w_x, 0.5, 0, 0, c },
            { vx2 - w_y, vy2 + w_x, 0.5, endl - length, 0, c },
            { vx2 + w_y, vy2 - w_x, 0.5, endl - length, 16, c },
            { vx1 + w_y, vy1 - w_x, 0.5, 0, 16, c })
        RenderTexture(
            tex, blend,
            { vx3 - w_y, vy3 + w_x, 0.5, 256 - length, 0, c },
            { vx1 - w_y, vy1 + w_x, 0.5, 256, 0, c },
            { vx1 + w_y, vy1 - w_x, 0.5, 256, 16, c },
            { vx3 + w_y, vy3 - w_x, 0.5, 256 - length, 16, c })
    else
        RenderTexture(
            tex, blend,
            { vx3 - w_y, vy3 + w_x, 0.5, 256 - length, 0, c },
            { vx2 - w_y, vy2 + w_x, 0.5, endl + 256 - length, 0, c },
            { vx2 + w_y, vy2 - w_x, 0.5, endl + 256 - length, 16, c },
            { vx3 + w_y, vy3 - w_x, 0.5, 256 - length, 16, c })
    end
end

-------------------------------------------------------
--子机追踪，每个子机目标独立，但效果是经常叠一起
function nenyuki_findtarget(self)
    local d = { 114514, 114514, 114514, 114514 } --下北泽程序员常用填充数字（雾
    local num = min(5, int(lstg.var.power / 100) + 1)
    for i = 1, 4 do
        if i < num then
            local y = self.slist[num][i][2]
            --将两次遍历用for合并，减少代码量
            for _, g in ipairs({ GROUP_ENEMY, GROUP_NONTJT }) do
                for _, o in ObjList(g) do
                    if abs(o.y - y) < d[i] and abs(o.y) < 224 then
                        d[i] = abs(o.y - y)
                        self.targetlist[i] = o
                        --本来想让一个目标最多只被两个子机锁定
                        --但是似乎没太大必要
                        --[[local n = 0
                        for k = 1, 4 do
                            if self.targetlist[k] == o then n = n + 1 end
                        end
                        if n <= 2 or o == _boss then self.targetlist[i] = o end]]
                    end
                end
            end
            if self.slist[num][i] then
                if self.targetlist[i] and IsValid(self.targetlist[i]) and self.targetlist[i].colli then
                    local dy = self.support_trail / d[i]
                    if dy > d[i] then
                        self.slist[num][i][2] = self.targetlist[i].y
                    else
                        self.slist[num][i][2] = self.slist[num][i][2] +
                            sign(self.targetlist[i].y - self.slist[num][i][2]) * dy
                    end
                else
                    d[i] = abs(self.default_slist[num][i][2] - self.slist[num][i][2])
                    local dy = self.support_trail / d[i]
                    if dy > d[i] then
                        self.slist[num][i][2] = self.default_slist[num][i][2]
                    else
                        self.slist[num][i][2] = self.slist[num][i][2] +
                            sign(self.default_slist[num][i][2] - self.slist[num][i][2]) * dy
                    end
                end
            end
        end
    end
end
