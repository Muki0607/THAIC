--小林 无记 Kobayashi Muki v1.03c by Muki
--自设自机
--改自灵梦机体（但除了行走图以外几乎没有灵梦的影子）
--符卡重视/综合型

---版本更新记录
---v1.03a
---之前更了啥完全忘了
---v1.03b
---将判定点渲染整合至主渲染中
---v1.03c
---将五线谱与射击子弹透明度降低，同时将五线谱渲染移至obj中，图层下移，减少瞎眼程度
---v1.03d
---更换了LSC的冲击波素材，优化了视觉效果
muki_player = Class(player_class)

function muki_player:init(slot)
    --懒得算纹理坐标所以基本都是截成单张图（
    -----------------------------------------
    --自机
    LoadTexture('muki_player', 'THlib\\player\\muki\\muki.png')
    LoadImageGroup('muki_player', 'muki_player', 0, 0, 32, 48, 8, 3, 0.5, 0.5)
    --自定义判定点
    LoadImageFromFile('muki_player_aura', 'THlib\\player\\muki\\muki_player_aura.png')
    -----------------------------------------
    --主炮,绿色八分音符弹
    LoadImageFromFile('muki_bullet_main_straight', 'THlib\\player\\muki\\muki_bullet_main_straight.png')
    --主炮追踪弹
    LoadImageFromFile('muki_bullet_main_trail', 'THlib\\player\\muki\\muki_bullet_main_trail.png')
    -----------------------------------------
    --副炮，绿色休止符弹
    --LoadImage('muki_support', 'muki_player', 64, 144, 16, 16)
    LoadImageFromFile('muki_bullet_sub_straight', 'THlib\\player\\muki\\muki_bullet_sub_straight.png')
    LoadImageFromFile('muki_bullet_sub_bound', 'THlib\\player\\muki\\muki_bullet_sub_bound.png')
    -----------------------------------------
    --符卡
    LoadImageFromFile('muki_bullet_spell', 'THlib\\player\\muki\\muki_bullet_spell.png')
    LoadTexture('muki_laser_bent', 'THlib\\player\\muki\\muki_laser_bent.png')
    LoadAniFromFile('muki_bullet_ef', 'THlib\\player\\muki\\muki_bullet_ef.png', true, 4, 2, 4, 0, 0, false)
    LoadImageFromFile('muki_lastspell_ef1', 'THlib\\player\\muki\\muki_lastspell_ef1.png')
    SetImageState('muki_lastspell_ef1', 'mul+add', Color(255, 255, 255, 255))
    LoadImageFromFile('muki_lastspell_ef2', 'THlib\\player\\muki\\muki_lastspell_ef2.png')
    LoadImageFromFile('muki_lastspell_cdbg', 'THlib\\player\\muki\\muki_lastspell_cdbg.png')
    for i = 0, 7 do
        LoadSound('muki_lastspell_se' .. i, 'THlib\\player\\muki\\muki_lastspell_se' .. i .. '.wav')
    end
    -----------------------------------------
    --灵击
    -----------------------------------------
    --调整透明度
    for _, v in ipairs({ 'muki_bullet_main_straight', 'muki_bullet_main_trail', 'muki_bullet_sub_straight', 'muki_bullet_sub_bound' }) do
        SetImageState(v, '', color(COLOR_WHITE, 150))
    end
    -----------------------------------------
    player_class.init(self)
    self.name = 'Muki'
    self.hspeed = 6
    self.lspeed = 3          --地表最速传说（
    self.timer2 = 0          --计算角度用
    self.cd = 60             --低速射击cd
    if CheckEnhancer(16) then
        if CheckDiff(4) then
            self.cd = int(self.cd * 2 / 3)
        end
    end
    self.lastspell = false   --最终符卡判定
    self.debug = false
    self.A = 0.87
    self.B = 0.85        --随便写的，不要问为什么（
    self.imgs = {}
    for i = 1, 24 do self.imgs[i] = 'muki_player' .. i end
    --实际上没用到子机位置表
    self.slist =
    {
        { nil,             nil,           nil,             nil },
        { { 0, 40, 0, 20 }, nil,          nil,             nil },
        { { -40, 40, -16, 20 }, { 40, 40, 16, 20 }, nil,   nil },
        { { -40, 40, -16, 20 }, { 40, 40, 16, 20 }, { 0, 40, 0, 20 }, nil },
        { { -40, 40, -40, 20 }, { 40, 40, 40, 20 }, { -20, 60, -16, 40 }, { 20, 60, 16, 40 } },
        { { -40, 40, -40, 20 }, { 40, 40, 40, 20 }, { -20, 60, -20, 40 }, { 20, 60, 20, 40 } }
    }
    self.anglelist = {}
    self.anglelist2 = {}
    --图省事的写法
    for i = 1, 5 do self.anglelist[i], self.anglelist2[i] = { 90, 90, 90, 90 }, { 0, 0, 0, 0 } end
    --决死符卡用的曲光
    Add_bentlaser_texture('muki_laser_bent', 'muki_laser_bent')
    --低速射击
    self.slowshoot = function(dmg)
        for _ = 1, 15 do
            local l = ran:Int(0, 4)
            local d = 25 * self.lh
            local y = ran:Int(0, 25) * -5
            New(muki_bullet_sub_straight, 'muki_bullet_sub_straight', self.x + d * (l - 2), -225 + y, 16,
                90, dmg, d * (l - 2), (-225 + y) - self.y)
        end
    end
    self.default_dmglist = { 0.2, 0.2, 0.2, 0.2 }
    self.dmglist = { 0.2, 0.2, 0.2, 0.2 }
    self.spellname = { '生灵「幻梦蝶华舞」', '散灵「刹那藤结术」', '「幻想华奏」' }
    self.deathtime = 12
    self.default_deathtime = self.deathtime
    self.have_death_spell = true
    self.aura_rot = 0
    self.cdbg_x = 0
    self.cdbg_y = 0
end

-------------------------------------------------------
function muki_player:frame()
    --自机帧逻辑
    -----------------------------------------
    --创建五线谱
    self.shooting_aura = self.shooting_aura or New(muki_shooting_aura)
    -----------------------------------------
    --判定点自旋
    self.aura_rot = self.aura_rot + 2
    -----------------------------------------
    --高速射击角度变化
    --这里的写法因为一些历史遗留问题可能有点怪
    if self.slow == 0 then
        self.timer2 = self.timer2 + 1
    end
    self.rot1, self.rot2 = 15 + 15 * sin(2 * self.timer2), -15 - 15 * sin(2 * self.timer2)
    self.rot3, self.rot4 = 15 + 30 * sin(2 * self.timer2), -15 - 30 * sin(2 * self.timer2)
    --for i = 1,5 do self.anglelist2[i] = {self.rot1+self.rot0,self.rot2+self.rot0,self.rot3+self.rot0,self.rot4+self.rot0} end
    for i = 1, 5 do self.anglelist2[i] = { self.rot1, self.rot2, self.rot3, self.rot4 } end
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
    --低速射击
    if not self.dialog and not self.lock then
        local dmgfix3 = 1 --插件的加伤
        if CheckEnhancer(16) then
            dmgfix3 = 1.5
        end
        if self.timer % self.cd == 0 and self.slow == 1 and self.support > 0 and KeyIsDown('shoot') then
            New(tasker, function()
                local num = min(int(lstg.var.power / 100) + 1, 5)
                for i = 1, num do
                    self.slowshoot(self.dmglist[min(i, 4)] * 4 * dmgfix3)
                    task.Wait(5)
                end
            end)
        end
    end
    -----------------------------------------
    --最终符卡
    --上上下下左右左右BABA
    --为了避免触发spell和special而没有使用这两个键
    self.qte_checker = self.qte_checker or
        New(muki_qte_checker, { 'up', 'up', 'down', 'down', 'left', 'right', 'left', 'right', 'slow', 'shoot', 'slow', 'shoot' }, 1)
    if self.qte_checker.finished then
        self.qte_checker.finished = false
        self.qte_checker.num = 1
        self.lastspell = true
    end
    -----------------------------------------
    player_class.frame(self)
end

-------------------------------------------------------
function muki_player:shoot()
    --自机射击
    PlaySound('plst00', 0.3, self.x / 1024)
    self.nextshoot = 4
    local dmgfix3 = 1 --插件的加伤
    if CheckEnhancer(16) then
        if CheckDiff(4) then
            self.nextshoot = int(self.nextshoot * 2 / 3)
        end
        dmgfix3 = 1.5
    end
    --奇怪的3way主炮
    New(muki_bullet_main_straight, 'muki_bullet_main_straight', self.x, self.y, 24, 90, 2)
    New(muki_bullet_main_trail, 'muki_bullet_main_trail', self.x - 10, self.y, 12, 105, self.target, 1200, 1 * dmgfix3)
    New(muki_bullet_main_trail, 'muki_bullet_main_trail', self.x + 10, self.y, 12, 75, self.target, 1200, 1 * dmgfix3)
    if self.slow == 0 then
        --奇怪的触板反弹追踪弹
        if self.support > 0 then
            local num = min(int(lstg.var.power / 100) + 1, 5)
            for i = 1, 4 do
                New(muki_bullet_sub_bound, 'muki_bullet_sub_bound', self.x, self.y, 8,
                    self.anglelist[num][i] + self.anglelist2[num][i], self.dmglist[i] * 7 / 2 * dmgfix3)
            end
        end
    else
        --低速射击已移动至frame中（其实这么干不是什么好事）
    end
end

-------------------------------------------------------
function muki_player:spell()
    --自机符卡
    local p = 360
    if CheckEnhancer(9) then p = p + 60 end
    self.nextspell = 300
    self.protect = p
    if self.lastspell then
        --最终符卡
        --板底伤害大概是32768 / 10000 * 1200（原版三十二割伤害）
        --贴脸极限伤害在八万左右

        --符卡不足时切换至普通符卡
        if lstg.var.exmp < 200 then
            self.lastspell = false
            muki_player.spell(self)
            return
        end
        --[[
        if lstg.var.bomb < 2 then
            self.lastspell = false
            muki_player.spell(self)
            return
        end
        lstg.var.bomb = max(lstg.var.bomb - 2, 0)
        ]]
        local cost = 200
        local before = int(lstg.var.exmp / 100)
        if CheckEnhancer(4) then cost = cost * 1.1 end
        if CheckEnhancer(4) and lstg.var.exmp < cost then
            local d = cost - lstg.var.exmp
            lstg.var.exmp = 0
            lstg.var.power = max(lstg.var.power - d, 0)
        else
            lstg.var.exmp = max(lstg.var.exmp - cost, 0)
        end
        local after = int(lstg.var.exmp / 100)
        if after < before then
            lstg.var.exmp_int = int(lstg.var.exmp / 100)
        end

        local p = 720
        if CheckEnhancer(9) then p = p + 60 end
        self.nextspell = 300
        self.protect = p

        New(muki_lastspell_cdbg)
        New(bullet_killer, self.x, self.y)
        New(tasker, function()
            local se = { 1, 1, 2, 3, 4, 5, 6, 7 }
            for i = 1, 8 do
                local hp, target = -1
                for _, g in ipairs({ GROUP_ENEMY, GROUP_NONTJT }) do
                    for _, o in ObjList(g) do
                        if o.hp and o.hp > hp then
                            hp = o.hp
                            target = o
                        end
                    end
                end
                if IsValid(target) then
                    --New(muki_lastspell_ef, target.x, target.y, 50)
                    PlaySound('muki_lastspell_se' .. se[i], 3, self.x / 256, true)
                    target.class.base.take_damage(target, 50)
                else
                    PlaySound('invalid', 3, self.x / 256, true)
                    return
                end
                task.Wait(30)
            end
            New(tasker, function()
                self.lock = true
                New(muki_lastspell_ef2, 'muki_lastspell_ef1', self.x, self.y, 20)
                PlaySound('muki_lastspell_se1', 3, self.x / 256, true)
                PlaySound('cat00', 3, self.x / 256, true)
                --PlaySound('slash', 3, self.x / 256, true)
                --PlaySound('boon01', 3, self.x / 256, true)
                --说白了梦想天生也就只是个双重风车弹
                New(tasker, function()
                    for i = 1, 180 do
                        for j = 1, 4 do
                            New(muki_bullet_lastspell, 'muki_bullet_sub_straight', self.x, self.y, 18, j * 90 + i * 5, 10, true)
                            New(muki_bullet_lastspell, 'muki_bullet_sub_straight', self.x, self.y, 18, j * 90 - i * 5, 10, true)
                        end
                        task.Wait()
                    end
                end)
                for _ = 1, 18 do
                    New(muki_lastspell_ef2, 'muki_lastspell_ef2', self.x, self.y, 20)
                    PlaySound('muki_lastspell_se0', 3)
                    for i = 1, 144 do
                        New(muki_bullet_lastspell, 'muki_bullet_sub_bound', self.x, self.y, 18, 360 / 144 * i, 10)
                    end
                    task.Wait(10)
                end
                self.lastspell = false
                self.lock = false
                New(bullet_killer, self.x, self.y)
            end)     
        end)
    elseif self.death > 0 then
        --决死符卡
        --脑子一抽用曲光做了个bomb
        --lstg.var.bomb = max(lstg.var.bomb - 1, 0)
        local cost = 100
        local before = int(lstg.var.exmp / 100)
        if CheckEnhancer(4) then cost = cost * 1.1 end
        if CheckEnhancer(4) and lstg.var.exmp < cost then
            local d = cost - lstg.var.exmp
            lstg.var.exmp = 0
            lstg.var.power = max(lstg.var.power - d, 0)
        else
            lstg.var.exmp = max(lstg.var.exmp - cost, 0)
        end
        local after = int(lstg.var.exmp / 100)
        if after < before then
            lstg.var.exmp_int = lstg.var.exmp_int - 1
        end
        --伤害限制
        local dmg_limiter = New(muki_dmg_limiter, _boss, 1200)
        --符卡主体部分
        New(tasker, function()
            New(player_spell_mask, 0, 200, 135, 30, 240, 30)
            New(bullet_killer, self.x, self.y)
            PlaySound('slash', 3, self.x / 256, true)
            PlaySound('boon01', 3, self.x / 256, true)

            --隐藏player
            local hide
            if self.hide then hide = true end
            self.hide = true
            self.lock = true

            --散开的曲光
            for i = 1, 16 do
                local a = i * 360 / 16
                New(muki_spell_laser_bent, self.x, self.y, 12, a, 50)
            end
            task.Wait(30)

            --寻找目标
            local target = {}
            local target_hp = {}
            for _, g in ipairs({ GROUP_ENEMY, GROUP_NONTJT }) do
                for _, o in ObjList(g) do
                    local w = lstg.world
                    if IsValid(o) and BoxCheck(o, w.l, w.r, w.b, w.t) then --不知道为什么测试时总有个nontjt在场外，只能这样了
                        table.insert(target, o)
                        table.insert(target_hp, o.hp)
                    end
                    if #target > 16 then
                        local _, k = muki_TableMin(target_hp)
                        table.remove(target, k)
                        table.remove(target_hp, k)
                    end
                end
            end

            --瞄准敌人的曲光
            if #target > 0 then
                for _, o in ipairs(target) do
                    if IsValid(o) then
                        for i = 1, 16 do
                            local a = i * 360 / 16
                            local x, y = o.x + 1000 * cos(a), o.y + 1000 * sin(a)
                            New(muki_spell_laser_bent, x, y, 16, Angle(o, x, y) + 180, 5)
                        end
                    end
                end
            else
                for _ = 1, 16 do
                    local x, y = muki_GetRectPos(220, 252, ran:Float(-180, 180))
                    New(muki_spell_laser_bent, x, y, 16, Angle(0, 0, x, y), 50)
                end
            end
            task.Wait(150)

            --回归的曲光
            local laser = {}
            for i = 1, 16 do
                local a = i * 360 / 16
                laser[i] = New(muki_spell_laser_bent, self.x + 500 * cos(a), self.y + 500 * sin(a), 12, a + 180, 50)
            end
            task.Wait(90)
            for i = 1, 16 do
                if IsValid(laser[i]) then RawDel(laser[i]) end
            end

            --取消player隐藏
            if IsValid(dmg_limiter) then RawDel(dmg_limiter) end
            self.hide = false
            self.lock = false
            if hide then
                self.hide = true
            end

            New(bullet_killer, self.x, self.y)
        end)
    else
        --通常符卡
        --弹幕火力优势学说的典型
        self.collect_line = self.collect_line - 300
        New(tasker, function()
            task.Wait(90)
            self.collect_line = self.collect_line + 300
        end)
        PlaySound('slash', 0.8)
        PlaySound('nep00', 1.0)
        New(player_spell_mask, 0, 200, 135, 30, 210, 30)
        New(bullet_killer, self.x, self.y)
        New(tasker, function()
            for _ = 1, 2 do
                for d = 1, 8 do
                    New(muki_bullet_spell, 'muki_bullet_main_trail', d * 180 / 8, -240, 24, 90, 5)
                    New(muki_bullet_spell, 'muki_bullet_main_trail', -d * 180 / 8, -240, 24, 90, 5)
                    task.Wait(8)
                end
                for d = 8, 1, -1 do
                    New(muki_bullet_spell, 'muki_bullet_main_trail', d * 180 / 8, -240, 24, 90, 5)
                    New(muki_bullet_spell, 'muki_bullet_main_trail', -d * 180 / 8, -240, 24, 90, 5)
                    task.Wait(8)
                end
            end
            New(bullet_killer, self.x, self.y)
        end)
    end
end

-------------------------------------------------------
function muki_player:render()
    --自机渲染

    --废弃的子机
    --[[for i = 1, 4 do
        if self.sp[i] and self.sp[i][3] > 0.5 then
            Render('muki_support', self.supportx + self.sp[i][1], self.supporty + self.sp[i][2], 90)
        end
    end]]

    player_class.render(self)
    --判定点渲染
    SetImageState('muki_player_aura', '', Color(self.lh * 255, 255, 255, 255))
    local s = Player_scale or 1
    Render('muki_player_aura', self.x, self.y, self.aura_rot, s)
    Render('muki_player_aura', self.x, self.y, -self.aura_rot, s)
end

-------------------------------------------------------
--[[function muki_player:special()
    --自机灵击（制作中）
    if self.debug then
        PlaySound('slash', 0.8)
        for i, o in ObjList(GROUP_ENEMY) do Kill(o) end
        for i, o in ObjList(GROUP_NONTJT) do Kill(o) end
        for i, o in ObjList(GROUP_ENEMY_BULLET) do Del(o) end
    elseif lstg.var.power >= 200 then
        PlaySound('slash', 0.8)
        New(bullet_killer, self.x, self.y)
        for i, o in ObjList(GROUP_ITEM) do o.attract = 8 end
        New(tasker, function()
            for i = 1, 3 do
                PlaySound('kira00', 1, self.x / 1024)
                for j = 1, 108 do
                    local a = j * 360 / 108
                    New(muki_bullet_special, 'muki_bullet_special', self.x, self.y, 12, a, 30)
                end
                task.Wait(45)
            end
        end)
        lstg.var.power = lstg.var.power - 100
        self.nextsp = 90
        self.protect = 120
    end
end]]

-------------------------------------------------------
--[[
muki_lastspell_cdbg = Class(_spellcard_background)
function muki_lastspell_cdbg:init()
    _spellcard_background.init(self)
    _spellcard_background.AddLayer(self, "muki_lastspell_cdbg", true, 0, 0, 0, 1, 1, 0, "", 1, 1, nil, nil)
    _spellcard_background.AddLayer(self, "white", true, 0, 0, 0, 0, 0, 0, "", 1, 1, nil, nil)
end
--]]
muki_lastspell_cdbg = Class(object)
function muki_lastspell_cdbg:init()
    self.img = 'muki_lastspell_cdbg'
    self.layer = LAYER_BG + 1
    self.x = 0
    self.y = 0
    self.vx = -1
    self.vy = -1
    self.alpha = 0
    self.t = 360
    self.bound = false
    SetImageState(self.img, '', Color(self.alpha, 255, 255, 255))
end

function muki_lastspell_cdbg:frame()
    task.Do(self)
    if not player.lastspell then
        Del(self)
    else
        self.alpha = min(100, self.alpha + 100 / 30)
    end
end

function muki_lastspell_cdbg:render()
    --最终符卡背景渲染，tile写法来自cdbg
    local world = lstg.world
    local img = self.img
    local x, y = self.x, self.y
    local w, h = GetTextureSize(img)
    SetImageState(img, '', Color(self.alpha, 255, 255, 255))
    for i = -int((world.r + 16 + x) / w + 0.5), int((world.r + 16 - x) / w + 0.5) do
        for j = -int((world.t + 16 + y) / h + 0.5), int((world.t + 16 - y) / h + 0.5) do
            Render(img, x + i * w, y + j * h)
        end
    end
end

function muki_lastspell_cdbg:del()
    PreserveObject(self)
    task.New(self, function()
        for _ = 1, 30 do
            self.alpha = min(100, self.alpha - 100 / 30)
            task.Wait()
        end
        RawDel(self)
    end)
end

-------------------------------------------------------
muki_lastspell_ef2 = Class(object)

function muki_lastspell_ef2:init(img, x, y, t)
    self.img = img
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER_BULLET + 50
    self.hscale = 0
    self.vscale = 0
    self.x = x
    self.y = y
    self.t = t
end

function muki_lastspell_ef2:frame()
    if self.timer > self.t then
        RawDel(self)
    else
        self.hscale = self.hscale + 12 / self.t
        self.vscale = self.vscale + 12 / self.t
    end
end
-------------------------------------------------------
muki_bullet_lastspell = Class(player_bullet_straight)

function muki_bullet_lastspell:init(img, x, y, v, rot, dmg, keep_rot)
    player_bullet_straight.init(self, img, x, y, v, rot, dmg)
    self.killflag = true
    self.a = 32
    self.b = 32
    if keep_rot then self.rot = 90 end
end
-------------------------------------------------------
muki_spell_laser_bent = Class(laser_bent)

function muki_spell_laser_bent:init(x, y, v, a, dmg)
    laser_bent.init(self, 16, x, y, 24, 32, 'muki_laser_bent', 0)
    self.group = GROUP_SPELL --以防被其他东西干扰用个没人用的组
    self.layer = LAYER_PLAYER_BULLET
    self._blend = ''
    self._colli = false
    self.dmg = dmg / 5
    self.killflag = true
    --self.vx = v * cos(a)
    --self.vy = v * sin(a)
    muki_SineMove(self, x, y, v / 2, a, 90, 15)
    self._bound = false
    self._inf_graze = false
end

function muki_spell_laser_bent:frame()
    laser_bent.frame(self)
    if self.timer > 180 then self._bound = true end
    for _, g in ipairs({ GROUP_ENEMY, GROUP_NONTJT }) do
        for _, o in ObjList(g) do
            if IsValid(o) and self.data:CollisionCheck(o.x, o.y, o.rot, o.a, o.b, o.rect) and o.class.base.take_damage then
                o.class.base.take_damage(o, self.dmg)
            end
        end
    end
end
-------------------------------------------------------
muki_dmg_limiter = Class(object)

function muki_dmg_limiter:init(boss, maxdmg)
    if not IsValid(boss) then RawDel(self) end
    self.boss = boss
    self._hp = boss.hp
    self.maxdmg = maxdmg
end

function muki_dmg_limiter:frame()
    if not IsValid(self.boss) then RawDel(self) end
    if self.boss.hp < self._hp - self.maxdmg then
        self.boss.hp = self._hp - self.maxdmg
    end
end

-------------------------------------------------------
muki_bullet_spell = Class(player_bullet_straight)

function muki_bullet_spell:init(img, x, y, v, angle, dmg)
    player_bullet_straight.init(self, img, x, y, 0, angle, dmg / 32)
    self.killflag = true
    self.a = 64
    self.b = 64
    self.vscale = 4
    self.hscale = 4
    self.v = v
end

function muki_bullet_spell:frame()
    self.vy = self.v * self.timer / 60
    if self.y > 224 then
        PlaySound('tan00', 0.75)
        Kill(self)
    end
end

function muki_bullet_spell:kill()
    New(muki_bullet_ef, self.x, self.y, self.rot + 180)
    for i = 1, 32 do
        New(muki_bullet_spell_ef, 'muki_bullet_spell', self.x, self.y, 5, 360 / 32 * i, self.dmg)
    end
end

-------------------------------------------------------
muki_bullet_spell_ef = Class(player_bullet_straight)

function muki_bullet_spell_ef:init(img, x, y, v, rot, dmg)
    player_bullet_straight.init(self, img, x, y, v, rot, dmg)
    self.killflag = true
    self.a = 32
    self.b = 32
    self.omiga = 3
end
-------------------------------------------------------
muki_bullet_main_straight = Class(player_bullet_straight)

function muki_bullet_main_straight:kill()
    New(muki_bullet_ef, self.x, self.y, self.rot + 180)
end

-------------------------------------------------------
muki_bullet_sub_straight = Class(player_bullet_straight)

function muki_bullet_sub_straight:init(img, x, y, v, rot, dmg, dx, dy)
    player_bullet_straight.init(self, img, x, y, 0, rot, dmg / 3)
    _connect(player, self)
    self.a = 16
    self.b = 32
    self.rot = 0
    self._dx = dx
    self._dy = dy
    self.v = v
    self.bound = false
    self.killflag = true
    SetImgState(self, '', 150, 255, 255, 255)
end

function muki_bullet_sub_straight:frame()
    _set_rel_pos(self, self._dx, self._dy + self.v * self.timer, 0)
    if self.timer >= 120 then self.bound = true end
end

-------------------------------------------------------
muki_bullet_main_trail = Class(player_bullet_trail)
function muki_bullet_main_trail:init(img, x, y, v, angle, target, trail, dmg)
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.img = img
    self.x = x
    self.y = y
    self.rot = angle
    self.v = v
    self.target = target
    self.trail = trail
    self.dmg = dmg
end

function muki_bullet_main_trail:frame()
    player_class.findtarget(self)
    if IsValid(self.target) and self.target.colli then
        local a = math.mod(Angle(self, self.target) - self.rot + 720, 360)
        if a > 180 then a = a - 360 end
        local da = self.trail / (Dist(self, self.target) + 1)
        if da >= abs(a) then
            self.rot = Angle(self, self.target)
        else
            self.rot = self.rot + sign(a) * da
        end
    end
    self.vx = self.v * cos(self.rot)
    self.vy = self.v * sin(self.rot)
end

function muki_bullet_main_trail:render()
    object.render(self)
    --[[
    SetImageState('white', '', Color(255, 255, 0, 0))
    if self.target then
        Render('white', self.target.x, self.target.y)
    end
    ]]
end

function muki_bullet_main_trail:kill()
    New(muki_bullet_ef, self.x, self.y, self.rot)
end

-------------------------------------------------------
muki_bullet_sub_bound = Class(player_bullet_straight)

function muki_bullet_sub_bound:init(img, x, y, v, rot, dmg)
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.a = 16
    self.b = 32
    self.img = img
    self.x = x
    self.y = y
    self.rot = rot
    self.vx = v * cos(rot)
    self.vy = v * sin(rot)
    self.v = v
    self.dmg = dmg
    self.navi = true
    self.boundsign = true
end

function muki_bullet_sub_bound:frame()
    if self.boundsign and self.x > 192 or self.x < -192 or self.y > 224 then
        local d = 114514
        local target
        for _, g in ipairs({ GROUP_ENEMY, GROUP_NONTJT }) do
            for _, o in ObjList(g) do
                if IsValid(o) and Dist(self, o) < d then
                    d = Dist(self, o)
                    target = o
                end
            end
        end
        local a
        if IsValid(target) then
            a = Angle(self, target)
        else
            a = self.rot
        end
        self.vx = self.v * cos(a)
        self.vy = self.v * sin(a)
        self.boundsign = false
        --self.target = target
    end
end

function muki_bullet_sub_bound:render()
    object.render(self)
    --[[SetImageState('white', '', Color(255, 255, 0, 0))
    if self.target then
        Render('white', self.target.x, self.target.y)
    end]]
end

function muki_bullet_sub_bound:kill()
    New(muki_bullet_ef, self.x, self.y, self.rot + 180)
end

-------------------------------------------------------
muki_bullet_ef = Class(object)

function muki_bullet_ef:init(x, y, rot)
    self.x = x
    self.y = y
    self.rot = rot
    self.img = 'muki_bullet_ef'
    self.layer = LAYER_ENEMY - 5
    self.group = GROUP_GHOST
    self.vx = 1 * cos(rot)
    self.vy = 1 * sin(rot)
    self.vscale = 0.5
    self.hscale = 0.5
end

function muki_bullet_ef:frame()
    if self.timer >= 15 then
        self.y = 600
        Del(self)
    end
end

-------------------------------------------------------
muki_shooting_aura = Class(object)

function muki_shooting_aura:init()
    self.layer = LAYER_ENEMY - 5
    self.bound = false
    self.x = player.x
    self.y = player.y
end

function muki_shooting_aura:frame()
    self.x = player.x
    self.y = player.y
end

function muki_shooting_aura:render()
    --五线谱渲染
    local alpha = abs(100 * sin(3 * player.timer))
    --极其少见的四顶点赋色（用来做渐变）
    SetImageState('white', 'mul+add', Color(alpha, 86, 228, 52), Color(alpha, 86, 228, 52), Color(alpha, 30, 243, 160), Color(alpha, 30, 243, 160))
    local d = 25 * min(1, player.lh + 0.5)
    for i = 0, 4 do
        RenderRect('white', self.x + d * (i - 2), self.x + d * (i - 2) + 2, -256, 256)
    end
end

-------------------------------------------------------

--摘自数学库
---获取表中最小元素，表中可含有非number元素
---若表中无number元素则返回nil
---@param t table @要获取最小值的table
---@return number, number @table的最小值与其索引
function muki_TableMin(t)
    local n = 1145141919810
    local kn
    for k, v in pairs(t) do
        if type(v) == 'number' then
            if v < n then n = v kn = k end
        end
    end
    if n < 1145141919810 then return n, kn end
end

--摘自数学库
---检测一个值是否处于上限和下限之间
---@param x number @要检测的值
---@param up number @上限（当然也能填下限）
---@param down number @下限（当然也能填上限）
---@param equal boolean @为false时使用大于/小于，否则使用大于等于/小于等于
function muki_IsIn(x, up, down, equal)
    if up < down then up, down = down, up end
    if equal == nil or equal then
        return x <= up and x >= down
    else
        return x < up and x > down
    end
end

---通过一个角度获取矩形边界对应坐标
---@param a number @角度
---@param w number @矩形宽度的一半
---@param h number @矩形高度的一半
---@return number, number @返回的边界坐标
function muki_GetRectPos(a, w, h)
    local isin = muki_IsIn
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

--摘自杂项库
--大概很少人直接拿这些符号做变量名（但是确实是可行的
---正弦曲线式移动，参考dld一面大蝴蝶
---@param x number @起始x坐标
---@param y number @起始y坐标
---@param v number @速度
---@param θ number @角度
---@param λ number @波长
---@param A number @振幅
---@param t number @间隔
function muki_SineMove(self, x, y, v, θ, λ, A, t)
    t = t or 1
    λ = λ or 75
    task.New(self, function()
        for i = 1, _infinite do
            self.x = x + v * cos(θ) * i - A * sin(θ) * sin(360 * v * i / λ)
            self.y = y + v * sin(θ) * i + A * cos(θ) * sin(360 * v * i / λ)
            task.Wait(t)
        end
    end)
end

--摘自杂项库
--QTE检测器，仅支持replay键位（上下左右、Shift、ZXC）
muki_qte_checker = Class(object)

---@param keylist string[] @键位列表
---@param allow_fault boolean|number @是否允许错误，为number时若为正数按错返回对应位置按键，若为负数按错倒扣对应数量按键
---@param intv number @相邻按键最大间隔，默认为_infinite
---@param time number @总限时，默认为_infinite
---@param cd number @按错时冷却，默认为0
function muki_qte_checker:init(keylist, allow_fault, intv, time, cd)
    self.keylist = keylist or {}
    self.allow_fault = allow_fault or false
    self.intv = intv or _infinite
    self.time = time or _infinite
    self.cd = cd or 0
    self.cd_timer = 0
    self.last_time = 0
    self.num = 1
    self.finished = false
    self.state = {}
end

function muki_qte_checker:frame()
    if self.finished then return 'finished' end
    if self.timer > self.last_time + self.intv or self.timer > self.time then
        Del(self)
    end
    self.cd_timer = max(0, self.cd_timer - 1)
    if self.cd_timer > 0 then return 'cooldown' end
    local keys = {
        "up", "down", "left", "right",
        "slow", "shoot", "spell", "special",
    }
    for _, v in ipairs(keys) do
        self.state[v] = false
        if KeyIsPressed(v) then self.state[v] = true end
    end
    local keydown, success
    for k, v in pairs(self.state) do
        if v then
            keydown = true
            if k == self.keylist[self.num] then
                if self.num >= #self.keylist then
                    self.finished = true
                    return
                end
                self.num = self.num + 1
                self.last_time = self.timer
                success = true
                break
            end
        end
    end
    if keydown and not success then
        if type(self.allow_fault) == 'number' then
            if sign(self.allow_fault) > 0 then
                self.num = self.allow_fault
            else
                self.num = self.num + self.allow_fault
            end
            self.cd_timer = self.cd
        elseif self.allow_fault then
            self.cd_timer = self.cd
        else
            Del(self)
        end
    end
end
