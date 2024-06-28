---=====================================
---THAIC Misc v1.00a
---东方梦摇篮杂项 v1.00a
---=====================================

---版本更新记录
---v1.00a
---初始版本

---@class aic.misc @东方梦摇篮杂项
---
---这杂项是真的杂
aic.misc = {}
local lib = aic.misc

---迭代器函数，迭代当前场上所有obj
---@param objid number @初始objid
---@return fun(flag:number, objid:number):number, lstg.GameObject
function lib.ObjIterator(objid)
    objid = objid or 0
    return NextObject, -1, objid
end

---获取当前播放音乐
---@return string @正在播放的bgm名
function lib.GetCurrentBGM()
    local _, bgm = EnumRes('bgm')
    for _, v in pairs(bgm) do
        if GetMusicState(v) == 'playing' then
            return v
        end
    end
end

---清除符卡history
function lib.ClearHistory(diff, name, player)
    if not scoredata then InitScoreData() end
    if player then
        scoredata.spell_card_hist[diff][name][player] = nil
    else
        scoredata.spell_card_hist[diff][name] = nil
    end
end

--大概很少人直接拿这些符号做变量名（但是确实是可行的
---正弦曲线式移动，参考dld一面大蝴蝶
---@param x number @起始x坐标
---@param y number @起始y坐标
---@param v number @速度
---@param θ number @角度
---@param A number @振幅
---@param λ number @波长
---@param t number @间隔
function lib:SineMove(x, y, v, θ, A, λ, n, t)
    t = t or 1
    λ = λ or 75
    n = n or _infinite
    task.New(self, function()
        self.navi = true
        for i = 1, n do
            self.x = x + v * cos(θ) * i - A * sin(θ) * sin(360 * v * i / λ)
            self.y = y + v * sin(θ) * i + A * cos(θ) * sin(360 * v * i / λ)
            task.Wait(t)
        end
    end)
end

---返回`i`与`j`对应的索引（与`string.sub`的规则相同）
---@param i number @始位标
---@param j number @末位标
---@param len number @总长度
---@overload fun(i:number, len:number):number
function lib.GetPos(i, j, len)
    i = i or 1
    if not len then
        if i < 0 then i = j + 1 + i end
        i = min(i, j)
        return i
    else
        j = j or len
        if i < 0 then i = len + 1 + i end
        if j < 0 then j = len + 1 + j end
        j = min(j, len)
        if j >= i then return i, j end
    end
end

---编辑器obj同款渐隐删除
function lib.FadeDel(unit)
    if ParticleGetn(self) > 0 then
        misc.KeepParticle(self)
    end
    if not self.hide then
        New(bubble3, self.img, self.x, self.y, self.rot, self.dx, self.dy, self.omiga, 15, self.hscale, self.hscale,
            Color(self._a, self._r, self._g, self._b), Color(0, self._r, self._g, self._b), self.layer, self._blend)
    end
end

--QTE检测器，仅支持replay键位（上下左右、Shift、ZXC）
lib.qte_checker = Class(object)

---@param keylist string[] @键位列表
---@param allow_fault boolean|number @是否允许错误，为number时若为正数按错返回对应位置按键，若为负数按错倒扣对应数量按键
---@param intv number @相邻按键最大间隔，默认为_infinite
---@param time number @总限时，默认为_infinite
---@param cd number @按错时冷却，默认为0
function lib.qte_checker:init(keylist, allow_fault, intv, time, cd)
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
    function self._frame()
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
                    for _, q in ipairs(lstg.tmpvar.qte_list) do
                        if k == q.keylist[q.num] and q ~= self then
                            return
                        end
                    end
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
end

---开场加载界面（事实上加载在这之前的黑屏界面就已经完成了）
lib.opening_scene = Class(object)

function lib.opening_scene:init(t)
    self.group = GROUP_GHOST
    self.bound = false
    self.t = t or 300
    self.alpha = 0
    self.co = task.New(self, function() 
        --加载bgm
        for i = 1, 15 do
            if i ~= 12 then
                LoadMusicRecord("aic_bgm" .. i)
            end
        end
    end)
end

function lib.opening_scene:frame()
    task.Do(self)
    if self.timer > self.t and coroutine.status(self.co) == 'dead' then
        Del(self)
        --[[
    elseif self.timer > self.t * 4 / 6 then
        self.loading_sign = self.loading_sign or New(lib.loading_sign, self.t)
        self.alpha = self.alpha + 255 / (self.t / 6)
    elseif self.timer > self.t * 3 / 6 then
        self.alpha = self.alpha - 255 / (self.t / 6)
    elseif self.timer > self.t * 2 / 6 then
        self.alpha = self.alpha + 255 / (self.t / 6)
    elseif self.timer > self.t * 1 / 6 then
        self.alpha = self.alpha - 255 / (self.t / 6)
    else
        self.alpha = self.alpha + 255 / (self.t / 6)
    --]]
    end
end

function lib.opening_scene:render()
    SetViewMode('ui')
    --暂时先不搞这玩意了
    --[[
    SetImageState('white', '', color(COLOR_BLACK))
    RenderRect('white', 0, screen.width, 0, screen.height)
    if self.timer <= self.t / 3 then
        DrawText('main_font_zh1', '制作', screen.width / 2, screen.height / 2 + 50,
            1.5, color(COLOR_WHITE, self.alpha), nil, 'centerpoint')
        DrawText('main_font_zh1', '幻想华奏制作组', screen.width / 2, screen.height / 2,
            3, color(COLOR_WHITE, self.alpha), nil, 'centerpoint')
    elseif self.timer <= self.t * 2 / 3 then
        DrawText('main_font_zh1', '原作', screen.width / 2, screen.height / 2 + 50,
            1.5, color(COLOR_WHITE, self.alpha), nil, 'centerpoint')
        DrawText('main_font_zh1', '上海爱丽丝幻乐团', screen.width / 2, screen.height / 2,
            3, color(COLOR_WHITE, self.alpha), nil, 'centerpoint')
    else
        SetImageState('Muki_AiC_opening_scene', '', color(COLOR_WHITE, self.alpha))
        RenderRect('Muki_AiC_opening_scene', 0, screen.width, 0, screen.height)
    end
    --]]
    RenderRect('Muki_AiC_opening_scene', 0, screen.width, 0, screen.height)
    SetViewMode('world')
end

---转场加载界面（同样只是走流程）
lib.loading_scene = Class(object)

function lib.loading_scene:init(t)
    self.group = GROUP_GHOST
    self.bound = false
    self.t = t or 300
    self.x = -50
    self.y = -50
    self.vx = -0.25
    self.vy = -0.25
    self.alpha = 0
    self.scale = 0
    self.layer = 114514
    New(lib.loading_sign, self.t)
end

function lib.loading_scene:frame()
    if self.timer >= self.t then
        Del(self)
    elseif self.timer >= self.t - 30 then
        self.alpha = self.alpha - 255 / 30
    elseif self.timer <= 30 then
        self.alpha = self.alpha + 255 / 30
    end
    if self.timer <= 60 then
        self.scale = self.scale + 0.5 / 60
    elseif self.timer >= self.t - 60 then
        self.scale = self.scale - 0.5 / 60
    end
end

function lib.loading_scene:render()
    SetViewMode('ui')
    SetImageState('Muki_AiC_square_empty', '', Color(self.alpha, 230, 227, 219))
    SetImageState('Muki_AiC_square_middle', '', Color(self.alpha, 230, 227, 219))
    SetImageState('white', '', Color(self.alpha, 85, 76, 74))
    RenderRect('white', 0, screen.width, 0, screen.height)
    for i = 1, 30 do
        local y = i * 25
        for j = 1, 30 do
            local x = j * 50
            if i % 2 == 1 then x = x - 25 end
            Render('Muki_AiC_square_empty', self.x + x, self.y + y, 0, 0.5)
            Render('Muki_AiC_square_middle', self.x + x, self.y + y, 0, self.scale)
        end
    end
    SetViewMode('world')
end

---加载标志（少女折寿中）
lib.loading_sign = Class(object)

---@param t1 number @持续时间
---@param t2 number @加载动画旋转一圈的周期
function lib.loading_sign:init(t1, t2)
    self.group = GROUP_GHOST
    self.x = screen.width * 0.8
    self.y = screen.height * 0.15
    self.bound = false
    self.layer = 114515
    self.scale = 0.5
    self.t1 = t1 or 300
    self.t2 = t2 or 180
end

function lib.loading_sign:frame()
    if self.timer > self.t1 then Del(self) end
end

function lib.loading_sign:render()
    SetViewMode('ui')
    SetImageState('Muki_AiC_loading_sign1', '', Color(200 + 50 * sin(5 * self.timer), 255, 255, 255))
    SetImageState('Muki_AiC_loading_sign2', '', Color(200 + 50 * sin(5 * self.timer), 255, 255, 255))
    Render('Muki_AiC_loading_sign1', self.x, self.y, 0, self.scale)
    Render('Muki_AiC_loading_sign2', self.x + 15, self.y - 25, 0, self.scale)
    local t = self.timer % self.t2 + 1
    local dt = self.t2 / 4
    local dir = int(t / dt) + 1
    local o = 1440 / self.t2
    for i = 1, 4 do
        Render('Muki_AiC_loading_sign3', self.x + 90 + 15 * sin(i * 90), self.y - 10 + 15 * cos(i * 90), 0, self.scale)
        SetImageState('Muki_AiC_loading_sign4', '', Color(max(0, 100 + 155 * sin(o * self.timer - 30)), 255, 255, 255))
        Render('Muki_AiC_loading_sign4', self.x + 90 + 15 * sin(dir * 90), self.y - 10 + 15 * cos(dir * 90), 0,
            self.scale)
    end
    SetViewMode('world')
end

--bgm标题
lib.bgm_name = Class(object)

function lib.bgm_name:init(n)
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.text = aic.l10n.ui.music_room.title
    --保留节目：暴力调参
    --由于♪无法被pixel字体渲染，渲染需要分为两部分进行，因此无法使用右对齐，只能手动对齐
    
    self.offset = { -58, -75, -26, -20, -111, -50, -16, -110, -32, -47, -3, -3, -53, -42, -164, -146, -3, -13, -19, -8,
        -85, -49, -53, -126, -40, -40, -60, -35, -45, -55 }
    self.n = n
    self.x = 200
    self.y = -205
    self.alpha = 255
    self.bound = false
    self.movex = -50 + self.offset[self.n]
    if _debug.bgm_debug then self.movex = -50 end
    task.New(self, function()
        task.MoveToEx(self.movex, 0, 30, MOVE_ACC_DEC)
        task.Wait(120)
        for i = 1, 60 do
            self.alpha = self.alpha - 255 / 60 * i
            task.Wait()
        end
        Del(self)
    end)
end

function lib.bgm_name:frame()
    task.Do(self)
end

function lib.bgm_name:render()
    if _debug.bgm_debug then
        for i = 1, #self.text do
            DrawText('main_font_en', '♪', self.x + self.offset[i], self.y - 3 + i * 10,
                1, color(COLOR_WHITE, self.alpha), nil, 'right')
            DrawText('pixel', self.text[i], self.x + self.offset[i], self.y + i * 10,
                1, color(COLOR_WHITE, self.alpha), nil, 'left')
        end
    else
        DrawText('main_font_en', '♪', self.x, self.y - 3,
            1, color(COLOR_WHITE, self.alpha), nil, 'right')
        DrawText('pixel', self.text[self.n], self.x, self.y,
            1, color(COLOR_WHITE, self.alpha), nil, 'left')
    end
end


---闪避时为了使用shader而创建的假player
lib.dodge_player = Class(object)

function lib.dodge_player:init()
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER
    self.img = player.img
    self.x = player.x
    self.y = player.y
    CreateRenderTarget('rt:aic_player_dodge')
end

function lib.dodge_player:frame()
    if not player.dodge then Del(self) end
    self.img = player.img
    self.x = player.x
    self.y = player.y
end

function lib.dodge_player:render()
    PushRenderTarget('rt:aic_player_dodge')
    RenderClear(Color(0, 0, 0, 0))
    --手动渲染子机和判定点
    _G[lstg.var.player_name].render(player)
    object.render(self)
    grazer.render(player.grazer)
    PopRenderTarget()
    PostEffect(
        'fx:glitch',
        'rt:aic_player_dodge',
        6,
        '',
        {
            { ran:Float(0, 100), 0, 0, 0 },
            { 5,                 0, 0, 0 }
        }
    )
end

---修复后的camera_setter
lib.camera_setter = Class(object)

function lib.camera_setter:init(x, y)
    player.lock = true
    self.group = GROUP_GHOST
    self.text = { 'eye', 'at', 'up', 'fovy', 'z', 'fog', 'color' }
    self.nitem = { 3, 3, 3, 1, 2, 2, 3 }
    self.pos = 1
    self.posx = 1
    self.pos_changed = 0
    self.edit = false
    self._x = x or 0
    self._y = y or 0
    self.hide = false
end

function lib.camera_setter:frame()
    if GetLastKey() == setting.keysys.retry then
        if self.hide then
            self.hide = false
            player.lock = true
        else
            self.hide = true
            player.lock = false
        end
    end
    if GetLastKey() == setting.keys.shoot and not self.hide then
        self.edit = true
        PlaySound('select00', 0.3)
        if not self.edit then
            self.posx = 1
        end
    end
    if GetLastKey() == setting.keys.spell and not self.hide then
        self.edit = false
        PlaySound('cancel00', 0.3)
    end
    if self.pos_changed > 0 and not self.hide then
        self.pos_changed = self.pos_changed - 1
    end
    if self.edit and not self.hide then
        local step = 0.1
        if KeyIsDown 'slow' then
            step = 0.01
        end
        if GetLastKey() == setting.keys.left then
            self.posx = self.posx - 1
            PlaySound('select00', 0.3)
        end
        if GetLastKey() == setting.keys.right then
            self.posx = self.posx + 1
            PlaySound('select00', 0.3)
        end
        self.posx = (self.posx - 1 + self.nitem[self.pos]) % self.nitem[self.pos] + 1
        if self.pos <= 3 or self.pos == 5 then
            local item = lstg.view3d[self.text[self.pos]]
            if GetLastKey() == setting.keys.up then
                item[self.posx] = item[self.posx] + step
                PlaySound('select00', 0.3)
            end
            if GetLastKey() == setting.keys.down then
                item[self.posx] = item[self.posx] - step
                PlaySound('select00', 0.3)
            end
        elseif self.pos == 6 then
            if GetLastKey() == setting.keys.up then
                lstg.view3d.fog[self.posx] = lstg.view3d.fog[self.posx] + step
                PlaySound('select00', 0.3)
                if lstg.view3d.fog[1] < -0.0001 then
                    if lstg.view3d.fog[1] > -0.9999 then
                        lstg.view3d.fog[1] = 0
                    elseif lstg.view3d.fog[1] > -1.9999 then
                        lstg.view3d.fog[1] = -1
                    end
                end
            end
            if GetLastKey() == setting.keys.down then
                lstg.view3d.fog[self.posx] = lstg.view3d.fog[self.posx] - step
                if lstg.view3d.fog[1] < -1.0001 then
                    lstg.view3d.fog[1] = -2
                elseif lstg.view3d.fog[1] < -0.0001 then
                    lstg.view3d.fog[1] = -1
                end
                PlaySound('select00', 0.3)
            end
            if abs(lstg.view3d.fog[1]) < 0.0001 then
                lstg.view3d.fog[1] = 0
            end
            if abs(lstg.view3d.fog[2]) < 0.0001 then
                lstg.view3d.fog[2] = 0
            end
        elseif self.pos == 7 then
            local c = {}
            local alpha
            local step = 10
            if KeyIsDown 'slow' then
                step = 1
            end
            alpha, c[1], c[2], c[3] = lstg.view3d.fog[3]:ARGB()
            if GetLastKey() == setting.keys.up then
                c[self.posx] = c[self.posx] + step
                PlaySound('select00', 0.3)
            end
            if GetLastKey() == setting.keys.down then
                c[self.posx] = c[self.posx] - step
                PlaySound('select00', 0.3)
            end
            c[self.posx] = max(0, min(c[self.posx], 255))
            lstg.view3d.fog[3] = Color(alpha, unpack(c))
        elseif self.pos == 4 then
            if GetLastKey() == setting.keys.up then
                lstg.view3d.fovy = lstg.view3d.fovy + step
                PlaySound('select00', 0.3)
            end
            if GetLastKey() == setting.keys.down then
                lstg.view3d.fovy = lstg.view3d.fovy - step
                PlaySound('select00', 0.3)
            end
        end
    else
        if GetLastKey() == setting.keys.up and not self.hide then
            self.pos = self.pos - 1
            self.pos_changed = ui.menu.shake_time
            PlaySound('select00', 0.3)
        end
        if GetLastKey() == setting.keys.down and not self.hide then
            self.pos = self.pos + 1
            self.pos_changed = ui.menu.shake_time
            PlaySound('select00', 0.3)
        end
        self.pos = (self.pos + 6) % 7 + 1
    end
    if KeyIsPressed 'special' and not self.hide then
        Print("--set camera")
        Print(string.format("Set3D('eye',%.2f,%.2f,%.2f)", unpack(lstg.view3d.eye)))
        Print(string.format("Set3D('at',%.2f,%.2f,%.2f)", unpack(lstg.view3d.at)))
        Print(string.format("Set3D('up',%.2f,%.2f,%.2f)", unpack(lstg.view3d.up)))
        Print(string.format("Set3D('fovy',%.2f)", lstg.view3d.fovy))
        Print(string.format("Set3D('z',%.2f,%.2f)", unpack(lstg.view3d.z)))
        Print(string.format("Set3D('fog',%.2f,%.2f,Color(%d,%d,%d,%d))", lstg.view3d.fog[1], lstg.view3d.fog[2],
            lstg.view3d.fog[3]:ARGB()))
        Print("--")
    end
end

local function _str(num)
    return string.format('%.2f', num)
end

function lib.camera_setter:render()
    local y = 340
    SetViewMode 'ui'
    SetImageState('white', '', Color(0xFF000000))
    RenderRect('white', 424 + self._x, 632 + self._x, 256 + self._y, 464 + self._y)
    RenderTTF('sc_pr', 'camera setting', 528 + self._x, 528 + self._x, y + 4.5 * ui.menu.sc_pr_line_height + self._y,
        y + 4.5 * ui.menu.sc_pr_line_height + self._y, Color(255, unpack(ui.menu.title_color)), 'centerpoint')
    ui.DrawMenuTTF('sc_pr', '', self.text, self.pos, 432 + self._x, y + self._y, 1, self.timer, self.pos_changed, 'left')
    local _a, _r, _g, _b = lstg.view3d.fog[3]:ARGB()
    ui.DrawMenuTTF('sc_pr', '', {
        _str(lstg.view3d.eye[1]),
        _str(lstg.view3d.at[1]),
        _str(lstg.view3d.up[1]),
        _str(lstg.view3d.fovy),
        _str(lstg.view3d.z[1]),
        _str(lstg.view3d.fog[1]),
        tostring(_r)
    }, self.pos, 496 + self._x, y + self._y, 1, self.timer, self.pos_changed, 'right')
    ui.DrawMenuTTF('sc_pr', '', {
        _str(lstg.view3d.eye[2]),
        _str(lstg.view3d.at[2]),
        _str(lstg.view3d.up[2]),
        '',
        _str(lstg.view3d.z[2]),
        _str(lstg.view3d.fog[2]),
        tostring(_g)
    }, self.pos, 560 + self._x, y + self._y, 1, self.timer, self.pos_changed, 'right')
    ui.DrawMenuTTF('sc_pr', '', {
        _str(lstg.view3d.eye[3]),
        _str(lstg.view3d.at[3]),
        _str(lstg.view3d.up[3]),
        '',
        '',
        '',
        tostring(_b)
    }, self.pos, 624 + self._x, y + self._y, 1, self.timer, self.pos_changed, 'right')
    if self.edit and self.timer % 30 < 15 then
        RenderTTF('sc_pr', '_', 432 + self.posx * 64 + self._x, 432 + self.posx * 64 + self._x,
            y + (4 - self.pos) * ui.menu.sc_pr_line_height + self._y,
            y + (4 - self.pos) * ui.menu.sc_pr_line_height + self._y, Color(255, unpack(ui.menu.title_color)), 'right',
            'vcenter', 'noclip')
    end
    SetViewMode 'world'
end

---哈酱的party parrot，用于标记未完成区域
lib.party_parrot = Class(object)

---@param x number @x坐标
---@param y number @y坐标
---@param s number @缩放比例
---@param t number @周期（请传入5的整数倍）
---@param r number @旋转半径
---@param rgb boolean @是否开启超级rgb模式
---@param ui boolean 是否使用ui系
function lib.party_parrot:init(x, y, s, t, r, rgb, ui)
    self.group = GROUP_GHOST
    self.x = x or 0
    self.y = y or 0
    self.bound = false
    self.blend = ''
    self._a = 255
    self._r = 255
    self._g = 255
    self._b = 255
    self.r = r or 25
    self.angle = 0
    self.scale = s or 0.25
    self.t = t or 25
    self.rgb = rgb
    self.ui = ui
end

function lib.party_parrot:frame()
    task.Do(self)
    if self.rgb then
        self._a, self._r, self._g, self._b = 255, 150 + 100 * sin(5 * self.timer), 150 - 100 * cos(5 * self.timer),
            150 + 100 * cos(5 * self.timer)
    end
end

function lib.party_parrot:render()
    if self.ui then SetViewMode('ui') end
    for i = 1, 5 do
        SetImageState('Muki_AiC_party_parrot' .. i, self.blend, Color(self._a, self._r, self._g, self._b))
    end
    Render('Muki_AiC_party_parrot' .. (int((self.timer % self.t) / (self.t / 5)) + 1),
        self.x + self.r * cos(5 * self.timer), self.y + self.r * sin(5 * self.timer), self.angle, self.scale)
    if self.ui then SetViewMode('world') end
end

----------------------------------------
---资源

--开场加载界面
LoadImageFromFile('Muki_AiC_opening_scene', 'THlib/UI/Muki_AiC_opening_scene.png')

--转场加载界面
LoadImageFromFile("Muki_AiC_square_empty", "THlib/UI/Muki_AiC_square_empty.png")
LoadImageFromFile("Muki_AiC_square_middle", "THlib/UI/Muki_AiC_square_middle.png")

--加载标志
for i = 1, 4 do
    LoadImageFromFile('Muki_AiC_loading_sign' .. i, 'THlib/UI/loading/Muki_AiC_loading_sign' .. i .. '.png')
end

--闪避效果用的shader
LoadFX('fx:glitch', 'THlib/shader/aic_glitch.fx')
--还没改好的上色shader
LoadFX('fx:coloring', 'THlib/shader/aic_coloring.fx')

--符卡名相关
LoadImageFromFile("Muki_AiC_spell_history", "THlib/UI/Muki_AiC_spell_history.png")
LoadImageFromFile("Muki_AiC_spell_bonus", "THlib/UI/Muki_AiC_spell_bonus.png")

--派对鹦鹉
for i = 1, 5 do
    LoadImageFromFile('Muki_AiC_party_parrot' .. i, 'THlib/UI/party_parrot/Muki_AiC_party_parrot' .. i .. '.png')
end
