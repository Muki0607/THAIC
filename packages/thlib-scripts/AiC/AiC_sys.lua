---=====================================
---THAIC System v1.01b
---东方梦摇篮系统 v1.01b
---=====================================

---版本更新记录
---v1.00a
---初始版本
---v1.01a
---增加lib.CheckDiff与lib.GetDiff，用于检查与获取难度
---v1.01b
---增加lib.DropPower，用于掉落Power

---@class aic.sys @东方梦摇篮系统
---其实大部分系统还是在原本的位置修修补补，这里没多少东西
---这边几乎可以说是第二个misc了
aic.sys = {}
local lib = aic.sys

--插件编号
---@alias enhancer_num '1 = 盗垒滑步'|'2 = 藏巧守拙'|'3 = 双重闪避'|'4 = 超载咏唱'|'5 = 抓地鞋'|'6 = 长法杖'|'7 = 祈雨御守'|'8 = 濡湿预兆'|'9 = 恐高症'|'10 = 血之虹瞳'|'11 = 猫之缓降'|'12 = 珠辉的素描本'|'13 = 椎奈的编程指导书'|'14 = 菖蒲的小型终端'|'15 = 歌夜的耳机'|'16 = 诺艾儿的法杖'

---检查玩家是否携带某插件
---@param num enhancer_num @插件编号
---@return boolean
function lib.CheckEnhancer(num)
    if not lstg.var.enhancer_select then
        lstg.var.enhancer_select = {}
    end
    for _, v in ipairs(lstg.var.enhancer_select) do
        if v == num then return true end
    end
end

---检查当前难度是否大于等于某难度
---@param diff number @检查的难度
---@param equal boolean @是否要求严格等于
---@return boolean
function lib.CheckDiff(diff, equal)
    if equal then
        return scoredata.difficulty_select == diff
    else
        return scoredata.difficulty_select >= diff
    end
end

---获取当前难度编号
---@return number @当前难度编号
function lib.GetDiff()
    return scoredata.difficulty_select
end

---获取当前自机编号
---@return number @当前自机编号
function lib.GetPlayer()
    return scoredata.player_select
end

---获取当前大版本号（不同大版本间replay不通用）
---@return number @大版本号
function lib.GetVersionNumber()
    return tonumber(string.sub(aic.version, 1, 3))
end

---掉落Power
---@param p number p点数
function lib.DropPower(p, x, y)
    for _ = 1, p do
        local r = sqrt(p - 1) * 5
        local r2 = sqrt(ran:Float(1, 4)) * r
        local a = ran:Float(0, 360)
        local p = New(item_power, x + r2 * cos(a), y + r2 * sin(a))
        --p.is_power = false
        --p.is_power_blue = true
    end
end

---设置world系参数
---@param type string|'THAIC'|'FULLSCREEN'|'LSTG' @world系类型
function lib.SetWorld(type)
    local w = {--原版LuaSTG默认world参数
        l = -192, r = 192, b = -224, t = 224,
        boundl = -224, boundr = 224, boundb = -256, boundt = 256,
        scrl = 32, scrr = 416, scrb = 16, scrt = 464,
        pl = -192, pr = 192, pb = -224, pt = 224,
        world = 15}
    if type == 'THAIC' then
        FullScreen_Flag = false
        ResetWorld()
    elseif type == 'FULLSCREEN' then
        FullScreen_Flag = true
        OriginalSetWorld(w.l - 32, w.r + 224, w.b - 16, w.t + 16, 
            w.boundl - 32, w.boundr + 224, w.boundb - 16, w.boundt + 16,
            w.scrl - 32, w.scrr + 224, w.scrb - 16, w.scrt + 16,
            w.pl - 32 - 96, w.pr + 224 - 96, w.pb - 16, w.pt + 16, w.world)
        SetBound(w.boundl - 32, w.boundr + 224, w.boundb - 16, w.boundt + 16)
    elseif type == 'LSTG' then
        FullScreen_Flag = false
        OriginalSetWorld(w.l, w.r, w.b, w.t, w.boundl, w.boundr, w.boundb, w.boundt,
            w.scrl, w.scrr, w.scrb, w.scrt, w.pl, w.pr, w.pb, w.pt, w.world)
        SetBound(w.boundl, w.boundr, w.boundb, w.boundt)
    else
        error('invalid world type.')
    end
end

---@param fullscreen boolean @是否开启全屏
---@param s number @player缩放比例
function lib.SetFullScreen(fullscreen, s)
    s = s or 0.5
    if fullscreen then
        Player_scale = s
        aic.sys.SetWorld('FULLSCREEN')
        CloseUI = true
        player.bound = false
        player.grazer.bound = false
        player_hspeed_default = player.hspeed
        player_lspeed_default = player.lspeed
        player.hspeed = player.hspeed * s * 1.5
        player.lspeed = player.lspeed * s * 1.5
        player.a = player.A * s
        player.b = player.B * s
        player.hscale = s
        player.vscale = s
        player.grazer.hscale = s
        player.grazer.vscale = s
    else
        Player_scale = 1
        aic.sys.SetWorld('THAIC')
        CloseUI = false
        player.bound = true
        player.grazer.bound = true
        player.hspeed = player_hspeed_default or player.hspeed
        player.lspeed = player_lspeed_default or player.lspeed
        player.a = player.A
        player.b = player.B
        player.hscale = 1
        player.vscale = 1
        player.grazer.hscale = 1
        player.grazer.vscale = 1
    end
    
end

---以yyyy/mm/dd hh:mm:ss的格式返回时间
---@param time number @由os.time得到的时间
---@return string @格式化时间
function lib.GetTime(time)
    local t = os.date("!*t", time)
    return string.format("%d/%02d/%02d %02d:%02d:%02d",
        t.year, t.month, t.day, t.hour, t.min, t.sec)
end

---开启秘仪结界
function lib.ActivateBorder()
    New(lib.secret_ceremony_border)
    PlaySound('border', 2, nil, true)
end

--灵击的英文全称是Spiritual Hit（来自非想天则英文版）
---player灵击
---@param player lstg.GameObject @玩家
function lib.SpHit(player)
    local p = 180
    if CheckEnhancer(9) then p = p + 30 end
    player.protext = p
    player.nextspell = 120
    New(lib.Tamaki_weapon, player.x, player.y, 8, 150)
    PlaySound('cat00', 0.8)
    PlaySound('aic_sphit_use', 0.5)
end

---检查单位存活后再删除，防止报错
---@param unit lstg.GameObject @要删除的单位
---@param raw boolean @是否使用RawDel
---@return boolean @是否删除成功
function lib.SafeDel(unit, raw)
    if IsValid(unit) then
        _del(unit, not raw)
        return true
    end
end

---检查单位存活后再删除，防止报错
---@param unit lstg.GameObject @要删除的单位
---@param raw boolean @是否使用RawKill
---@return boolean @是否删除成功
function lib.SafeKill(unit, raw)
    if IsValid(unit) then
        _kill(unit, not raw)
        return true
    end
end

---检查调用环境为协程再Wait，防止报错
---@param t number @Wait时间
function lib.SafeWait(t)
    if coroutine.isyieldable() then 
        task.Wait(t)
    end
end

---安全地对存档文件进行操作
---@param func function @要进行的操作
---@return any
function lib.SafeSave(func)
    return TryExcept(
        func,
        {
            [PermissionDenied] = function()
                lstg.MsgBoxWarn("检测到游戏存档文件被其他进程占用。\n请关闭该进程后关闭本提示框。\n若本提示框持续出现，请重启游戏。")
            end,
            [""] = function()
                if not _debug.exception_handler_disabled then
                    Log(4, aic.py.last_exception)
                    lstg.MsgBoxError("读取游戏存档文件时出现未知错误。\n请尝试重启游戏。\n若重启游戏后仍然出现本提示框，请报告作者。", "游戏出现异常", true)
                else
                    raise()
                end
            end
        }
    )
end

---等待到condition为真
---@task
---@param condition boolean @用于判断的值
function lib.WaitUntil(condition)
    while not condition do
        task.Wait()
    end
end

---符卡用伤害限制器
lib.dmg_limiter = Class(object)

function lib.dmg_limiter:init(boss, maxdmg)
    if not IsValid(boss) then RawDel(self) end
    self.boss = boss
    self._hp = boss.hp
    self.maxdmg = maxdmg
end

function lib.dmg_limiter:frame()
    if not IsValid(self.boss) then RawDel(self) end
    if self.boss.hp < self._hp - self.maxdmg then
        self.boss.hp = self._hp - self.maxdmg
    end
end

--灵击，珠辉的素描本
lib.Tamaki_weapon = Class(object)

function lib.Tamaki_weapon:init(x, y, v, dmg)
    self.img = 'Muki_AiC_Tamaki_weapon'
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER_BULLET
    self.hscale = 0.5
    self.vscale = 0.5
    self.x = x
    self.y = y
    self.v = v
    self.vy = v
    self.dmg = dmg
    self.omiga = 8
    self.bound = false
    self.state = 0
    self.show = true
end

function lib.Tamaki_weapon:frame()
    if self.timer <= 60 and self.timer % 4 == 0 then
        New(lib.Tamaki_weapon_ef, self)
    end
    if self.timer < 60 then
        self.vy = self.vy - self.v / 60
        self.omiga = self.omiga - 8 / 60
    elseif self.timer == 60 then
        PlaySound('aic_sphit_explode', 1)
        New(bullet_killer, self.x, self.y)
    elseif self.timer > 60 and self.timer <= 90 then
        self.show = false
        self.state = self.state + 1 / 10
        for _, g in ipairs({ GROUP_ENEMY, GROUP_NONTJT }) do
            for _, o in ObjList(g) do
                if o.colli then
                    if o.class.base.take_damage then o.class.base.take_damage(o, self.dmg / 60) end
                end
            end
        end
    elseif self.timer <= 105 then
        self.state = self.state - 1 / 5
        for _, g in ipairs({ GROUP_ENEMY, GROUP_NONTJT }) do
            for _, o in ObjList(g) do
                if o.colli then
                    if o.class.base.take_damage then o.class.base.take_damage(o, self.dmg / 30) end
                end
            end
        end
    elseif self.timer > 105 then
        Del(self)
    end
end

function lib.Tamaki_weapon:render()
    if self.show then
        object.render(self)
    end
    if self.state < 3 then
        if self.state > 0 then
            SetImageState('white', '', Color(self.state * 255, 255, 255, 255))
            RenderRect('white', -75, 75, -256, 256)
        end
        if self.state > 1 then
            SetImageState('white', '', Color((self.state - 1) * 255, 255, 255, 255))
            RenderRect('white', -150, 150, -256, 256)
        end
        if self.state > 2 then
            SetImageState('white', '', Color((self.state - 2) * 255, 255, 255, 255))
            RenderRect('white', -224, 224, -256, 256)
        end
    else
        if self.state > 2 then
            SetImageState('white', '', Color((self.state - 2) * 255, 255, 255, 255))
            RenderRect('white', -75, 75, -256, 256)
        end
        if self.state > 1 then
            SetImageState('white', '', Color(max((self.state - 1), 1) * 255, 255, 255, 255))
            RenderRect('white', -150, 150, -256, 256)
        end
        if self.state > 0 then
            SetImageState('white', '', Color(max(self.state, 1) * 255, 255, 255, 255))
            RenderRect('white', -224, 224, -256, 256)
        end
    end
end

lib.Tamaki_weapon_ef = Class(object)

function lib.Tamaki_weapon_ef:init(master)
    self.img = 'Muki_AiC_Tamaki_weapon_ef'
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER_BULLET + 50
    self.rot = 270
    self.master = master
end

function lib.Tamaki_weapon_ef:frame()
    self.x = self.master.x
    self.y = self.master.y
    if self.timer == 4 or not self.master.show then ParticleStop(self) end
    if self.timer == 30 then Del(self) end
end

lib.secret_ceremony_border = Class(object)

function lib.secret_ceremony_border:init()
    self.img = 'Muki_AiC_border'
    self.x = player.x
    self.y = player.y
    self.layer = LAYER_PLAYER - 5
    self.bound = false
    self.omiga = 1
    self.s = 1
    self.hscale = self.s
    self.vscale = self.s
    self.alpha = 0
    player.collect_line = player.collect_line - 500
end

function lib.secret_ceremony_border:frame()
    if self.timer <= 30 then
        self.alpha = self.alpha + 100 / 30
    end
    self.hscale = self.hscale - self.s / 460
    self.vscale = self.vscale - self.s / 460
    SetImageState(self.img, '', Color(self.alpha, 255, 150, 0))
    self.x = player.x
    self.y = player.y
    player.nextspell = 114514
    if player.death ~= 0 or self.timer >= 420 then
        player.death = 0
        player.protect = 40
        _clear_bullet()
        PlaySound('bonus', 2, nil, true)
        New(boss_cast_ef_out, self.x, self.y, nil, 255, 150, 0)
        player.collect_line = player.collect_line + 500
        player.protect = 120
        player.nextspell = 60
        Del(self)
    end
end

----------------------------------------
---资源

--珠辉的素描本
LoadImageFromFile('Muki_AiC_Tamaki_weapon', 'THlib/misc/Muki_AiC_Tamaki_weapon.png')
LoadTexture('particles', 'THlib/misc/particles.png')
LoadImageGroup('parimg', 'particles', 0, 0, 32, 32, 4, 4)
LoadPS('Muki_AiC_Tamaki_weapon_ef', 'THlib/misc/Muki_AiC_Tamaki_weapon_ef.psi', 'parimg6')
--秘仪结界
LoadImageFromFile('Muki_AiC_border', 'THlib/misc/Muki_AiC_border.png')


