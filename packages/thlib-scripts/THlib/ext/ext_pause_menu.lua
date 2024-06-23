---THAIC Arranged
---=====================================
---pause menu
---=====================================

----------------------------------------
---暂停菜单

---@class ext.pausemenu @暂停菜单对象
ext.pausemenu = plus.Class()

function ext.pausemenu:init()
    self.kill = true

    self.pos = 1
    self.pos2 = 2
    self.ok = false
    self.choose = false
    self.lock = true

    self.timer = 0
    self.t = 30

    self.eff = 0
    self.mask_color = Color(0, 255, 255, 255)
    self.mask_alph = { 85, 76, 74 }
    self.mask_x = { 85, 76, 74 }

    self.text = {
        --普通模式
        { 'Return to Game', 'Return to Title', 'Manual', 'Option', 'Give up and Retry' },
        --replay模式
        { 'Return to Game', 'Return to Title', 'Manual', 'Option', 'Replay Again' },
        --完美无缺模式
        { 'Return to Game', 'Return to Title', 'Manual', 'Option', 'Return to Waypoint' }
    }

    self.bgmlist = {} --用来储存正在播放的bgm

    self.manual = ext.manual
    self.option = ext.option
    self.option:init()
end

function ext.pausemenu:frame()
    if self.kill then
        return "killed"
    elseif not self.manual.kill then
        self.manual:frame()
        return "manual"
    elseif not self.option.kill then
        self.option:frame()
        return "option"
    end

    --如果有可用的暂停菜单文字，则优先使用已有的
    local pause_menu_text
    if lstg.tmpvar.pause_menu_text then
        pause_menu_text = lstg.tmpvar.pause_menu_text
    else
        --根据是否是replay状态选择暂停菜单文字
        if ext.replay.IsReplay() then
            pause_menu_text = self.text[2]
        else
            pause_menu_text = self.text[1]
        end
    end
    --执行自身task
    task.Do(self)
    --执行选项操作
    if (not self.lock and self.manual.kill and self.option.kill) and self.t < 1 then
        --local lastkey = GetLastKey()
        --关闭暂停菜单
        if aic.input.CheckLastKey('menu') and (not lstg.tmpvar.death) then
            if not ext.rep_over then
                self.t = 60
                PlaySound('aic_pause_menu_off', 0.3)
                self.choose = false
                self:FlyOut()
            end
        end
        --直接重开
        if aic.input.CheckLastKey('retry') and (not lstg.tmpvar.death) then
            self.t = 60
            PlaySound('ok00', 0.3)
            self.choose = false
            if ext.replay.IsReplay() then
                ext.pause_menu_order = 'Replay Again'
            else
                ext.pause_menu_order = 'Give up and Retry'
            end
            self:FlyOut()
        end
        --槽位切换
        do
            if aic.input.CheckLastKey('up') then
                self.t = 4
                PlaySound('select00', 0.3)
                if not self.choose then
                    self.pos = self.pos - 1
                else
                    self.pos2 = self.pos2 - 1
                end
            elseif aic.input.CheckLastKey('down') then
                self.t = 4
                PlaySound('select00', 0.3)
                if not self.choose then
                    self.pos = self.pos + 1
                else
                    self.pos2 = self.pos2 + 1
                end
            end
            self.pos = (self.pos - 1) % (#pause_menu_text) + 1
            self.pos2 = (self.pos2 - 1) % (2) + 1
        end
        --取消操作
        if aic.input.CheckLastKey('spell') then
            if self.choose then
                self.t = 15
                PlaySound('aic_pause_menu_off', 0.7)
                self.choose = false
            else
                if not ext.rep_over and (not lstg.tmpvar.death) then
                    self.t = 60
                    PlaySound('aic_pause_menu_off', 0.7)
                    self:FlyOut()
                end
            end
        end
        --按键操作
        if aic.input.CheckLastKey('shoot') then
            if self.choose then
                if self.pos2 == 1 then
                    --确认选项，推送命令，暂停菜单关闭
                    self.t = 60
                    PlaySound('ok00', 0.3)
                    ext.PushPauseMenuOrder(pause_menu_text[self.pos])
                    self.choose = false
                    self:FlyOut()
                else
                    --取消选项
                    self.t = 15
                    PlaySound('cancel00', 0.3)
                    self.choose = false
                end
            else
                --未选中状态，进入二级菜单
                self.t = 15
                PlaySound('ok00', 0.3)
                --这太蠢了，完全不兼容添加选项
                --[[
                if self.pos == 1 then
                    --对第一个选项特化处理
                    ext.PushPauseMenuOrder(pause_menu_text[self.pos])
                    self:FlyOut()
                else
                    self.choose = true
                end
                ]]
                local confirm
                for _, v in ipairs({ 'Return to Title', 'Give up and Retry', 'Replay Again' }) do
                    if pause_menu_text[self.pos] == v then confirm = true end
                end
                if confirm then
                    self.choose = true
                elseif pause_menu_text[self.pos] == 'Manual' then
                    --ext.PushPauseMenuOrder(pause_menu_text[self.pos])
                    --self:FlyOut()
                    self.manual.kill = false
                    self.manual:flyin()
                elseif pause_menu_text[self.pos] == 'Option' then
                    self.option.kill = false
                    self.option:flyin()
                else
                    ext.PushPauseMenuOrder(pause_menu_text[self.pos])
                    self:FlyOut()
                end
            end
        end
    end
    --last op
    self.timer = self.timer + 1
    if self.t > 0 then
        self.t = self.t - 1
    end
    if self.choose then
        self.eff = min(self.eff + 1, 15)
    else
        self.eff = max(self.eff - 1, 0)
    end
end

function ext.pausemenu:render()
    if self.kill then
        return "killed"
    end

    --准备一些变量
    local pm = self --ext.pausemenu
    local dx = 208
    local dy = 260
    local m
    if ext.replay.IsReplay() then
        m = 2
    else
        m = 1
    end
    --绘制黑色遮罩
    SetViewMode 'ui'
    SetImageState('white', '', pm.mask_color)
    RenderRect('white', 0, screen.width, 0, screen.height)

    --这里直接借用暂停菜单的遮罩，不再重新渲染遮罩
    if not self.manual.kill then
        self.manual:render()
        return "manual"
    elseif not self.option.kill then
        self.option:render()
        return "option"
    end

    --渲染底图
    SetImageState('pause_eff', '',
        Color(pm.mask_alph[1] / 3, 200 * self.eff / 15 + 55, 200 * (1 - self.eff / 15) + 55,
            200 * (1 - self.eff / 15) + 55))
    Render('pause_eff', -150 + 180 * self.eff / 15 + dx, -115 + dy, 4 + 4 * sin(self.timer * 3), 0.5, 0.5)
    --准备选项
    local pause_menu_text
    local pause_menu_choose = { 'yes', 'no' }
    if lstg.tmpvar.pause_menu_text then
        pause_menu_text = lstg.tmpvar.pause_menu_text
    else
        pause_menu_text = pm.text[m]
    end
    --又是一个不明所以的写法
    --[[
    local textnumber = 0
    if pause_menu_text[3] then
        textnumber = 3
    else
        textnumber = 2
    end
    ]]
    local textnumber = #pause_menu_text
    if pause_menu_text then
        if lstg.tmpvar.pause_menu_text then
            --有现有的文字时高亮处理
            if ext.rep_over then
                if self.choose then
                    SetImageState('pause_replayover', '', Color(pm.mask_alph[1] + 15, 100, 100, 100))
                else
                    SetImageState('pause_replayover', '', Color(pm.mask_alph[1] + 15, 255, 255, 255))
                end
                Render('pause_replayover', pm.mask_x[1] + dx, -30 + dy, 0, 0.7, 0.7)
            elseif ext.focus_lose then
                if self.choose then
                    SetImageState('pause_pausemenu', '', Color(pm.mask_alph[1] + 15, 100, 100, 100))
                else
                    SetImageState('pause_pausemenu', '', Color(pm.mask_alph[1] + 15, 255, 255, 255))
                end
                Render('pause_pausemenu', pm.mask_x[1] + dx, -30 + dy, 0, 0.7, 0.7)
            elseif not ext.sc_pr then
                if self.choose then
                    SetImageState('pause_gameover', '', Color(pm.mask_alph[1] + 15, 100, 100, 100))
                else
                    SetImageState('pause_gameover', '', Color(pm.mask_alph[1] + 15, 255, 255, 255))
                end
                Render('pause_gameover', pm.mask_x[1] + dx, -30 + dy, 0, 0.7, 0.7)
            end
        else
            --没有现有的文字时高亮处理
            --[[
            if m == 1 then
                if self.choose then
                    SetImageState('pause_pausemenu', '', Color(pm.mask_alph[1] + 15, 100, 100, 100))
                else
                    SetImageState('pause_pausemenu', '', Color(pm.mask_alph[1] + 15, 255, 255, 255))
                end
                Render('pause_pausemenu', pm.mask_x[1] + dx, -30 + dy, 0, 0.7, 0.7)
            else
                if self.choose then
                    SetImageState('pause_replayover', '', Color(pm.mask_alph[1] + 15, 100, 100, 100))
                else
                    SetImageState('pause_replayover', '', Color(pm.mask_alph[1] + 15, 255, 255, 255))
                end
                Render('pause_replayover', pm.mask_x[1] + dx, -30 + dy, 0, 0.7, 0.7)
            end
            --]]
            --这里rep没结束，不应该渲染replayover
            if self.choose then
                SetImageState('pause_pausemenu', '', Color(pm.mask_alph[1] + 15, 100, 100, 100))
            else
                SetImageState('pause_pausemenu', '', Color(pm.mask_alph[1] + 15, 255, 255, 255))
            end
            Render('pause_pausemenu', pm.mask_x[1] + dx, -30 + dy, 0, 0.7, 0.7)
            
        end
        --渲染选项列表
        for i = 1, textnumber do
            if not (self.choose) then
                if i == self.pos and pm.mask_alph[min(i, 3)] + 15 >= 245 then
                    SetImageState('pause_' .. pause_menu_text[i], '',
                        Color(pm.mask_alph[min(i, 3)] + 15, 155 + 100 * sin(self.timer * 4.5), 255, 222))
                else
                    SetImageState('pause_' .. pause_menu_text[i], '', Color(pm.mask_alph[min(i, 3)] + 15, 100, 100, 100))
                end
            else
                if i == self.pos and pm.mask_alph[min(i, 3)] + 15 >= 245 then
                    SetImageState('pause_' .. pause_menu_text[i], '', Color(55, 255, 255, 255))
                else
                    SetImageState('pause_' .. pause_menu_text[i], '', Color(55, 100, 100, 100))
                end
            end
            Render('pause_' .. pause_menu_text[i], pm.mask_x[min(i, 3)] + (1 + i) * 10 + dx, -30 - i * 40 + dy, 0, 0.62,
                0.62)
        end
    end
    --渲染确定选项
    if self.choose then
        Render('pause_really', 0 + dx, -50 + dy, 0, 0.62, 0.62)
        for i = 1, 2 do
            if i == self.pos2 then
                SetImageState('pause_' .. pause_menu_choose[i], '',
                    Color(pm.mask_alph[i] + 15, 155 + 100 * sin(self.timer * 4.5), 255, 255))
            else
                SetImageState('pause_' .. pause_menu_choose[i], '', Color(pm.mask_alph[i] + 15, 100, 100, 100))
            end
            Render('pause_' .. pause_menu_choose[i], 15 + i * 10 + dx, -50 - i * 40 + dy, 0, 0.62, 0.62)
        end
    end
    SetViewMode 'world'
end

function ext.pausemenu:FlyIn()
    --清除一些flag
    ext.pop_pause_menu = nil

    self.kill = false --标记为开启状态

    --暂停计时器
    if aic.ext.real_timer then
        aic.ext.PauseTimer()
    end

    self.pos = 1
    self.pos2 = 2
    self.ok = false
    self.choose = false
    self.lock = true

    self.timer = 0
    self.t = 30

    self.eff = 0
    self.mask_color = Color(0, 255, 255, 255)
    self.mask_alph = { 0, 0, 0 }
    self.mask_x = { 0, 0, 0 }

    task.New(self, function()
        self:PauseSound()
        PlaySound('aic_pause_menu_on', 0.5)

        for i = 1, 50 do
            self.mask_color = Color(i * 4.1, 85, 76, 74)
            self.mask_alph = {
                min(i * 8, 239),
                max(min((i - 10) * 8, 239), 0),
                max(min((i - 20) * 8, 239), 0),
            }
            self.mask_x = {
                min(-210 + i, -180),
                min(-220 + i, -180),
                min(-230 + i, -180),
            }
            task.Wait(1)
        end
        self.lock = false
    end)
end

function ext.pausemenu:FlyOut()
    self.lock = true

    --应该是针对疮痍曲的淡出……
    if not (ext.sc_pr) then
        task.New(self, function()
            local _, bgm = EnumRes('bgm')
            for i = 1, 30 do
                for _, v in pairs(bgm) do
                    if GetMusicState(v) == 'playing' then
                        SetBGMVolume(v, 1 - i / 30)
                    end
                end
                task.Wait(1)
            end
        end)
    end
    task.New(self, function()
        for i = 30, 1, -1 do
            self.mask_color = Color(i * 7, 85, 76, 74)
            for j = 1, 3 do
                self.mask_alph[j] = i * 8
            end
            task.Wait(1)
        end
        task.New(stage.current_stage, function()
            task.Wait(1)
            self:ResumeSound()
        end)

        self.kill = true --标记为关闭状态

        --恢复计时器
        if aic.ext.real_timer then
            aic.ext.ResumeTimer()
        end

        --清除一些flag
        lstg.tmpvar.death = false
        ext.rep_over = false
    end)
end

function ext.pausemenu:PauseSound()
    self.bgmlist = {} --先清空列表
    if not (ext.sc_pr) then
        local _, bgm = EnumRes('bgm')
        for _, v in pairs(bgm) do
            --[[
            if GetMusicState(v) ~= 'stopped' and v ~= 'deathmusic' then
                PauseMusic(v)
            end
            --]]
            --新的处理方法（实验性），只处理正在播放的bgm，不处理暂停的bgm
            if GetMusicState(v) == "playing" and v ~= 'aic_bgm13' then
                PauseMusic(v)
                self.bgmlist[v] = true --标记
            end
        end
    end
    --[=[
    local sound, _ = EnumRes('snd')
    for _,v in pairs(sound) do
        if GetSoundState(v)~='stopped' and v ~= 'pause' then
            PauseSound(v)
        end
    end
    ]=]
end

function ext.pausemenu:ResumeSound()
    local _, bgm = EnumRes('bgm')
    for _, v in pairs(bgm) do
        --只对标记过为播放状态的bgm进行恢复
        if GetMusicState(v) ~= 'stopped' and self.bgmlist[v] then
            ResumeMusic(v)
        end
    end
    --[=[
    local sound,_=EnumRes('snd')
    for _,v in pairs(sound) do
        if GetSoundState(v)=='paused' then
            ResumeSound(v)
        end
    end
    ]=]
    --StopMusic(deathmusic)
end

function ext.pausemenu:IsKilled()
    local flag = self.kill
    return flag
end

--manual（纯table版）
--如果你要问为什么非要写这么谔谔的东西我只能说plus.Class和obj用一样的函数就是莫名奇妙没法渲染出来
--同时也证明了事实上用table来模拟obj是很简单的事情
--当然这不算严格意义上的obj，而是相当于对原暂停菜单回调函数的扩写
---@class manual @东方风Manual
ext.manual = {
    x = screen.width * 0.5,
    y = screen.height * 0.5,
    default_x = screen.width * 0.5,
    default_y = screen.height * 0.5,
    pos = 1,
    t = 16,
    l = 11,
    alpha = 255,
    scale = 0.5,
    level = 1,
    wait = 0,
    timer = 0,
    kill = true,
    frame = function(self)
        task.Do(self)
        if self.kill then return end
        self.timer = self.timer + 1
        self.wait = max(self.wait - 1, 0)
        if self.wait < 1 and not self.locked then
            --local lastkey = GetLastKey()
            if self.level == 1 then
                if aic.input.CheckLastKey('spell') or aic.input.CheckLastKey('menu') then
                    PlaySound('cancel00', 0.3)
                    self:flyout('quit')
                end
                if aic.input.CheckLastKey('shoot') then
                    PlaySound('ok00', 0.3)
                    self:flyout(-1)
                    task.New(self, function()
                        task.Wait(self.t)
                        self.level = 2
                        self.x = self.default_x
                        self.y = self.default_y
                        for i = 1, self.t do
                            self.alpha = i * 255 / self.t
                            task.Wait()
                        end
                        self.locked = false
                    end)
                end
                if aic.input.CheckLastKey('up') then
                    self.wait = 10
                    PlaySound('select00', 0.3)
                    if self.pos > 1 then
                        self.pos = self.pos - 1
                    else
                        self.pos = self.l
                    end
                elseif aic.input.CheckLastKey('down') then
                    self.wait = 10
                    PlaySound('select00', 0.3)
                    if self.pos < self.l then
                        self.pos = self.pos + 1
                    else
                        self.pos = 1
                    end
                end
            else
                if aic.input.CheckLastKey('spell') or aic.input.CheckLastKey('menu') then
                    PlaySound('cancel00', 0.3)
                    self.level = 1
                    self:flyout(-1)
                    self:flyin()
                end
                if aic.input.CheckLastKey('up') and self.pos > 1 then
                    self.wait = 10
                    PlaySound('select00', 0.3)
                    self:flyout(-1)
                    task.New(self, function()
                        task.Wait(self.t)
                        self.pos = self.pos - 1
                        self.x = self.default_x
                        self.y = self.default_y
                        for i = 1, self.t do
                            self.alpha = i * 255 / self.t
                            task.Wait()
                        end
                        self.locked = false
                    end)
                elseif aic.input.CheckLastKey('down') and self.pos < self.l then
                    self.wait = 10
                    PlaySound('select00', 0.3)
                    self:flyout(1)
                    task.New(self, function()
                        task.Wait(self.t)
                        self.pos = self.pos + 1
                        self.x = self.default_x
                        self.y = self.default_y
                        for i = 1, self.t do
                            self.alpha = i * 255 / self.t
                            task.Wait()
                        end
                        self.locked = false
                    end)
                end
            end
        end
    end,
    render = function(self)
        if self.kill then return end
        SetViewMode('ui')
        --SetImageState('white', '', Color(150, 85, 76, 74))
        --RenderRect('white', 0, screen.width, 0, screen.height)
        local d, x, y = 30, self.x, self.y
        if self.level == 1 then
            if self.locked then
                for i = 1, self.l do
                    if i == self.pos then
                        SetImageState('Muki_AiC_help_menu1', '', Color(self.alpha, 255, 255, 255))
                        Render('Muki_AiC_help_menu' .. i, x, y + (5 - i) * d, 0, self.scale)
                    else
                        SetImageState('Muki_AiC_help_menu' .. i, '', Color(self.alpha, 64, 64, 64))
                        Render('Muki_AiC_help_menu' .. i, x, y + (5 - i) * d, 0, self.scale)
                    end
                end
            else
                for i = 1, self.l do
                    if i == self.pos then
                        local co = 159.5 + 95.5 * cos(5 * self.timer)
                        SetImageState('Muki_AiC_help_menu' .. i, '', Color(self.alpha, co, co, co))
                    else
                        SetImageState('Muki_AiC_help_menu' .. i, '', Color(self.alpha, 64, 64, 64))
                    end
                    Render('Muki_AiC_help_menu' .. i, x, y + (5 - i) * d, 0, self.scale)
                end
            end
        else
            SetImageState('Muki_AiC_help' .. self.pos, '', Color(self.alpha, 255, 255, 255))
            Render('Muki_AiC_help' .. self.pos, x, y, 0, self.scale)
        end
        SetViewMode('world')
    end,
    flyin = function(self)
        self.locked = true
        --self.wait = self.t
        self.x = self.default_x + screen.width * 0.25
        self.y = self.default_y
        task.New(self, function()
            task.Wait(self.t / 4)
            for i = 1, self.t * 3 / 4 do
                self.alpha = i * 255 / (self.t * 3 / 4)
                task.Wait()
            end
            self.locked = false
        end)
        task.New(self, function()
            task.MoveTo(self.default_x, self.y, self.t, 2)
        end)
    end,
    flyout = function(self, dir)
        self.locked = true
        --self.wait = self.t
        task.New(self, function()
            for i = 1, self.t do
                self.alpha = 255 - i * 255 / self.t
                task.Wait()
            end
        end)
        if dir == 1 then
            task.New(self, function()
                --task.MoveTo(self.x, screen.height * 1.5, self.t, 2)
                task.MoveTo(self.x, self.y + 20, self.t, 2)
            end)
        elseif dir == -1 then
            task.New(self, function()
                --task.MoveTo(self.x, screen.height * -0.5, self.t, 2)
                task.MoveTo(self.x, self.y - 20, self.t, 2)
            end)
        elseif dir == 'quit' then
            task.New(self, function()
                --task.MoveTo(self.x, screen.height * -0.5, self.t, 2)
                task.MoveTo(self.x, self.y - 20, self.t, 2)
                self.kill = true
                self.pos = 1
                self.timer = 0
            end)
        end
    end
}
 
--同上
---@class manual @launcher风Option
ext.option = {
    x = screen.width * 0.5,
    y = screen.height * 0.5,
    default_x = screen.width * 0.5,
    default_y = screen.height * 0.5,
    pos1 = 1,
    pos2 = 1,
    t = 16,
    l1 = 15,
    l2_key = 9,
    l2_keysys = 5,
    l2 = 9 + 5,
    alpha = 255,
    scale = 0.5,
    level = 1,
    wait = 0,
    timer = 0,
    kill = true,
    key_changing = false,
    setting = loadConfigureTable(), --因为需要存读文件，为了安全起见这边和插件菜单一样单独先存一份，保存时再存整个表到setting
    res = { { 640, 480, true }, { 800, 600 }, { 960, 720, true }, { 1024, 768, true }, { 1280, 960, true }, { 1600, 1200 }, { 1920, 1440, true } },
    text1 = {
        { '用户名', setting.username, setting.username },
        { '分辨率', 7, { 1, 3, 4, 5, 7 } },
        { '显示模式', '全屏模式', '窗口模式' },
        { '垂直同步', '关', '开' },
        { '音效音量', 21, { 1, 5, 9, 13, 17, 21 } },
        { '背景音乐音量', 21, { 1, 5, 9, 13, 17, 21 } },
        { '自动射击', '关', '开' },
        { '自动低速', '关', '开' },
        { '双击闪避（未实装）', '关', '开' },
        { '进入关卡时音效', '旧版', '新版' },
        { '标题画面背景音乐', '普通版', '完全版' },
        { '健全模式', '开', '开（超健全）' },
        '键位设定',
        '使用默认设定',
        '保存并退出' },
    text2 = {
        '用户名仅可在标题画面更改。',
        '设置窗口显示模式下\n游戏窗口的大小。',
        '设置游戏的显示模式。',
        '启用垂直同步（VSync）\n可避免画面撕裂。',
        '设置音效的音量。',
        '设置背景音乐的音量。',
        '设置是否启用自动射击。\n若启用，需按住射击键以停火。\n不建议与自动低速一起使用。',
        '设置是否启用自动低速。\n若启用，在开火时\n将自动进入低速模式。\n不建议与自动射击一起使用。',
        '设置是否启用双击闪避（实验性）。\n若启用，双击方向键即可闪避。\n目前本功能尚处于测试阶段，\n若发生报错请报告作者。',
        '设置进入关卡时播放的音效。\n旧版为0.24a之前的音效，\n新版为0.24a之后的音效。',
        '设置标题画面的背景音乐。\n普通版为原作游戏的版本，\n完全版在普通版的基础上\n增加了一段额外旋律。',
        '设置是否显示性方面的描写。\n\n\n当然在这里你是没法关掉它的……',
        '更改键盘的按键。\n本游戏目前不支持手柄。',
        '将所有设定还原至默认值。',
        '保存设定并退出。\n若不想保存设定，\n请直接按取消键退出。',
    },
    text3 = { { 'UP', '上移' }, { 'DOWN', '下移' }, { 'LEFT', '左移' }, { 'RIGHT', '右移' },
        { 'SLOW', '低速移动' }, { 'SHOOT', '射击/确认' }, { 'SPELL', '符卡/取消' }, { 'SPECIAL', '系统特殊功能' },
        { 'SKILL', '自机特殊功能' }, { 'REPFAST', '录像播放加速' }, { 'REPSLOW', '录像播放减速' },
        { 'MENU', '暂停/返回' }, { 'SNAPSHOT', '截图' }, { 'RETRY', '快速重新开始' } },
    setname = { 'username', 'resx', 'windowed', 'vsync', 'sevolume', 'bgmvolume', 'autofire', 'autoslow', 'autododge', 'newopening', 'newbgm', 'safemode' },
    
    init = function(self)
        for k, v in ipairs(self.res) do
            if v[1] == self.setting.resx then
                self.pos_res = k
            end
        end
        for _, v in ipairs({ 'autofire', 'autoslow', 'autododge', 'newopening', 'newbgm' }) do 
            self.setting[v] = self.setting[v] or false
        end
        self.setting.safemode = self.setting.safemode or true
    end,
    frame = function(self)
        task.Do(self)
        if self.kill then return end
        self.timer = self.timer + 1
        self.wait = max(self.wait - 1, 0)
        if self.wait < 1 and not self.locked then
            --local lastkey = GetLastKey()
            local set = self.setting
            if self.level == 1 then
                --一层（主设置）逻辑
                if KeyIsDown('spell') or aic.input.CheckLastKey('menu') then
                    --不保存直接退出
                    PlaySound('cancel00', 0.5)
                    self:flyout('quit') 
                end
                if KeyIsDown('shoot') then
                    if self.pos1 == 1 then
                        --关卡内不能改用户名（因为会影响到scoredata的读取）
                        PlaySound('aic_setting_limited', 0.5)
                    elseif self.pos1 == 13 then
                        --进入键位设置
                        PlaySound('ok00', 0.5)
                        self.key_changing = false
                        self:flyout(-1)
                        task.New(self, function()
                            task.Wait(self.t)
                            self.level = 2
                            self.x = self.default_x
                            self.y = self.default_y
                            for i = 1, self.t do
                                self.alpha = i * 255 / self.t
                                task.Wait()
                            end
                            self.locked = false
                        end)
                    elseif self.pos1 == 14 then
                        --还原默认设置
                        PlaySound('ok00', 0.5)
                        self.setting = sp.copy(default_setting) --抄一份默认设置
                        for _, v in ipairs({ 'autofire', 'autoslow', 'autododge', 'newopening', 'newbgm' }) do 
                            self.setting[v] = false
                        end
                        self.setting.safemode = true
                    elseif self.pos1 == 15 then
                        --保存并退出
                        set.resx = self.res[self.pos_res][1]
                        set.resy = self.res[self.pos_res][2]
                        self.applySetting(set)
                        PlaySound('ok00', 0.5)
                        self:flyout('quit')
                    end
                end
                --上下移动与调节逻辑
                if KeyIsDown('up') then
                    self.wait = 8
                    PlaySound('aic_setting_move', 0.5)
                    if self.pos1 > 1 then
                        self.pos1 = self.pos1 - 1
                    else
                        self.pos1 = self.l1
                    end
                elseif KeyIsDown('down') then
                    self.wait = 8
                    PlaySound('aic_setting_move', 0.5)
                    if self.pos1 < self.l1 then
                        self.pos1 = self.pos1 + 1
                    else
                        self.pos1 = 1
                    end
                elseif KeyIsDown('left') then
                    self.wait = 8
                    if self.pos1 == 1 or (self.pos1 == 5 and set.sevolume == 0) or (self.pos1 == 6 and set.bgmvolume == 0) or (self.pos1 == 12 and not set.safemode) then
                        PlaySound('aic_setting_limited', 0.3)
                    else
                        PlaySound('aic_setting_scroll', 0.5)
                    end
                    if self.pos1 == 2 then
                        if self.pos_res > 1 then
                            self.pos_res = self.pos_res - 1
                        else
                            self.pos_res = 7
                        end
                    elseif self.pos1 == 5 then
                        set.sevolume = max(0, set.sevolume - 5)
                    elseif self.pos1 == 6 then
                        set.bgmvolume = max(0, set.bgmvolume - 5)
                    elseif self.pos1 == 12 and set.safemode then
                        set.safemode = not set.safemode
                    else
                        for k, v in pairs(self.setname) do
                            if self.pos1 == k and v ~= 'safemode' then
                                set[v] = not set[v]
                            end
                        end
                    end
                elseif KeyIsDown('right') then
                    self.wait = 8
                    if self.pos1 == 1 or (self.pos1 == 5 and set.sevolume == 100) or (self.pos1 == 6 and set.bgmvolume == 100) or (self.pos1 == 12 and set.safemode) then
                        PlaySound('aic_setting_limited', 0.3)
                    else
                        PlaySound('aic_setting_scroll', 0.5)
                    end
                    if self.pos1 == 2 then
                        if self.pos_res < 7 then
                            self.pos_res = self.pos_res + 1
                        else
                            self.pos_res = 1
                        end
                    elseif self.pos1 == 5 then
                        set.sevolume = min(100, set.sevolume + 5)
                    elseif self.pos1 == 6 then
                        set.bgmvolume = min(100, set.bgmvolume + 5)
                    elseif self.pos1 == 12 and not set.safemode then
                        set.safemode = not set.safemode
                    else
                        for k, v in pairs(self.setname) do
                            if self.pos1 == k and v ~= 'safemode' then
                                set[v] = not set[v]
                            end
                        end
                    end
                end
            else
                if self.key_changing then
                    if aic.input.InputState ~= 'keyboard' then
                        local KEY, keylist
                        if aic.input.dinput.isConnected(1) then KEY, keylist = DJOY
                        else KEY = XJOY end
                        local key = aic.input.GetLastJoy()
                        for _, v in pairs(KEY) do
                            if key == v and v ~= 0 then
                                if self.pos2 <= self.l2_key then
                                    local keys, k = set.joysticks, string.lower(self.text3[self.pos2][1])
                                    keys[k] = v
                                else
                                    local keysys, k = set.joysticksys, string.lower(self.text3[self.pos2][1])
                                    keysys[k] = v
                                end
                                self.key_changing = false
                                PlaySound('aic_ok', 0.5)
                            end
                        end
                    else
                        for _, v in pairs(KEY) do
                            if GetKeyState(v) then
                                if self.pos2 <= self.l2_key then
                                    local keys, k = set.keys, string.lower(self.text3[self.pos2][1])
                                    keys[k] = v
                                else
                                    local keysys, k = set.keysys, string.lower(self.text3[self.pos2][1])
                                    keysys[k] = v
                                end
                                self.key_changing = false
                                PlaySound('aic_ok', 0.5)
                            end
                        end
                    end
                else
                    if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
                        PlaySound('cancel00', 0.5)
                        self.level = 1
                        self:flyout(-1)
                        self:flyin()
                    elseif KeyIsPressed('shoot') then
                        PlaySound('select00', 0.5)
                        if self.pos2 == self.l2 then
                            self.level = 1
                            self:flyout(-1)
                            self:flyin()
                        else
                            self.wait = 30
                            self.key_changing = true
                        end
                    end
                    if KeyIsDown('up') then
                        self.wait = 8
                        PlaySound('aic_setting_move', 0.5)
                        if self.pos2 > 1 then
                            self.pos2 = self.pos2 - 1
                        else
                            self.pos2 = self.l2
                        end
                    elseif KeyIsDown('down') then
                        self.wait = 8
                        PlaySound('aic_setting_move', 0.5)
                        if self.pos2 < self.l2 then
                            self.pos2 = self.pos2 + 1
                        else
                            self.pos2 = 1
                        end
                    end
                end
            end
        end
    end,
    render = function(self)
        if self.kill then return end
        SetViewMode('ui')
        --SetImageState('white', '', Color(150, 85, 76, 74))
        --RenderRect('white', 0, screen.width, 0, screen.height)
        SetImageState('Muki_AiC_square_empty', '', color(COLOR_WHITE, self.alpha))
        SetImageState('Muki_AiC_square_middle', '', color(COLOR_WHITE, self.alpha))
        local d, x, y = 30, self.x - 30, self.y + screen.height * 0.45
        local x1, x2 = x - screen.width * 0.4, x + screen.width * 0.1

        if self.level == 1 then
            --设置名称与值
            for i = 1, self.l1 do
                local text = self.text1[i]
                if type(text) == 'string' then
                    --键位设定、使用默认设定、保存并退出
                    DrawText('main_font_zh2', text, x1, y + (self.pos1 / 3 - i) * d, 1,
                        color(COLOR_WHITE, self.alpha), nil, 'left')
                else
                    DrawText('main_font_zh2', text[1], x1, y + (self.pos1 / 3 - i) * d, 1,
                        color(COLOR_WHITE, self.alpha), nil, 'left')
                    if type(text[2]) == 'string' then
                        --选择项类型
                        local x, dx, dy = (x1 + x2) / 2, 5, -10
                        if i ~= 1 then
                            Render('Muki_AiC_square_empty', x - dx, y + (self.pos1 / 3 - i) * d + dy, 0, 0.25)
                            Render('Muki_AiC_square_empty', x + dx, y + (self.pos1 / 3 - i) * d + dy, 0, 0.25)
                            if i == 12 then
                                Render('Muki_AiC_square_empty', x + 3 * dx, y + (self.pos1 / 3 - i) * d + dy, 0, 0.25)
                            end
                        end
                        if self.setting[self.setname[i]] then
                            DrawText('main_font_zh2', text[3], x2, y + (self.pos1 / 3 - i) * d,
                                1, color(COLOR_WHITE, self.alpha), nil, 'right')
                            if i ~= 1 then
                                if i == 12 then
                                    Render('Muki_AiC_square_middle', x + 3 * dx, y + (self.pos1 / 3 - i) * d + dy, 0, 0.25)
                                else
                                    Render('Muki_AiC_square_middle', x + dx, y + (self.pos1 / 3 - i) * d + dy, 0, 0.25)
                                end
                            end
                        else
                            DrawText('main_font_zh2', text[2], x2, y + (self.pos1 / 3 - i) * d,
                                1, color(COLOR_WHITE, self.alpha), nil, 'right')
                            if i ~= 1 then
                                if i == 12 then
                                    Render('Muki_AiC_square_middle', x + dx, y + (self.pos1 / 3 - i) * d + dy, 0, 0.25)
                                else
                                    Render('Muki_AiC_square_middle', x - dx, y + (self.pos1 / 3 - i) * d + dy, 0, 0.25)
                                end
                            end
                        end
                    else
                        --拖动条类型（虽然并不能拖）
                        local x, d1, d2, dy = (x1 + x2) / 2 - 20, 2, 5, -15
                        for j = 1, text[2] do
                            local len = 5
                            if aic.table.Search(text[3], j) then len = 10 end
                            --[[aic.ui.RenderStroke(RenderRect, color(COLOR_BLACK, self.alpha), 'white',
                                x + j * d2, x + j * d2 + d1,
                                y + (self.pos1 / 3 - i) * d + dy, y + (self.pos1 / 3 - i) * d + len + dy)]]
                            SetImageState('white', '', color(COLOR_WHITE, self.alpha))
                            RenderRect('white', x + j * d2, x + j * d2 + d1,
                                y + (self.pos1 / 3 - i) * d + dy, y + (self.pos1 / 3 - i) * d + len + dy)
                            local y0 = y + (self.pos1 / 3 - i) * d + dy + 15
                            local p
                            if i == 2 then
                                p = self.pos_res
                            elseif i == 5 then
                                p = self.setting.sevolume / 5 + 1
                            elseif i == 6 then
                                p = self.setting.bgmvolume / 5 + 1
                            end
                            if j == p then
                                local x0 = x + j * d2 + d1 / 2
                                Render('Muki_AiC_square_empty', x0, y0, 0, 0.1)
                                Render('Muki_AiC_square_middle', x0, y0, 0, 0.1)
                            end
                        end
                        --[[
                        aic.ui.RenderStroke(RenderRect, color(COLOR_BLACK, self.alpha), 'white',
                            x + d2, x + text[2] * d2 + d1,
                            y + (self.pos1 / 3 - i) * d - d1 + dy, y + (self.pos1 / 3 - i) * d + dy)
                        SetImageState('white', '', color(COLOR_WHITE, self.alpha))]]
                        RenderRect('white', x + d2, x + text[2] * d2 + d1,
                            y + (self.pos1 / 3 - i) * d - d1 + dy, y + (self.pos1 / 3 - i) * d + dy)
                    end
                end
            end

            --分辨率
            local res = self.res[self.pos_res][1] .. 'x' .. self.res[self.pos_res][2]
            if self.res[self.pos_res][3] then res = res .. '（推荐）' end
            DrawText('main_font_zh2', res,
                x2, y + (self.pos1 / 3 - 2) * d, 1, color(COLOR_WHITE, self.alpha), nil, 'right')

            --音量
            DrawText('main_font_zh2', self.setting.sevolume .. '%',
                x2, y + (self.pos1 / 3 - 5) * d, 1, color(COLOR_WHITE, self.alpha), nil, 'right')
            DrawText('main_font_zh2', self.setting.bgmvolume .. '%',
                x2, y + (self.pos1 / 3 - 6) * d, 1, color(COLOR_WHITE, self.alpha), nil, 'right')

            --设置说明
            DrawText('main_font_zh2', self.text2[self.pos1],
                x2 + 150, y - 5 * d, 1, color(COLOR_WHITE, self.alpha), nil, 'centerpoint')
            if self.pos1 == 12 then
                DrawText('main_font_zh2', '\n未满18岁或正在录像的玩家\n请务必选择健全模式为开。',
                    x2 + 150, y - 5 * d + 8, 1, color(COLOR_RED, self.alpha), nil, 'centerpoint')
            end

            --指示光标
            if not self.locked then
                for i = 1, self.l1 do
                    if i == self.pos1 then
                        DrawText('main_font_zh2', '<', x1 - 25 - 5 * sin(3 * self.timer),
                            y + (self.pos1 / 3 - i) * d, 1, color(COLOR_WHITE, self.alpha), nil, 'left')
                        DrawText('main_font_zh2', '>', x2 + 25 + 5 * sin(3 * self.timer),
                            y + (self.pos1 / 3 - i) * d, 1, color(COLOR_WHITE, self.alpha), nil, 'right')
                    end
                end
            end
        else
            --键位名称与当前键位
            --在这里学到的教训：如果你打算写一个三层以上的嵌套，不要嫌麻烦，每一层的索引都应该单独写出来，否则出现nil时都不知道是哪一层的问题
            local keyname, key = aic.input.KeyNameList()
            local keys, keysys = self.setting.keys, self.setting.keysys
            if aic.input.InputState == 'xjoy' then
                keyname = XJOY
                keys, keysys = self.setting.joysticks, self.setting.joysticksys
            elseif aic.input.InputState == 'djoy' then
                keyname = DJOY
                keys, keysys = self.setting.joysticks, self.setting.joysticksys
            end
            for i = 1, self.l2 - 1 do
                if aic.input.InputState == 'keyboard' then
                    if i <= self.l2_key then
                        local k = string.lower(self.text3[i][1])
                        key = keyname[keys[k]]
                    else
                        local k = string.lower(self.text3[i][1])
                        key = keyname[keysys[k]]
                    end
                else
                    if i <= self.l2_key then
                        local k = string.lower(self.text3[i][1])
                        key = aic.table.Search(keyname, keys[k])
                    else
                        local k = string.lower(self.text3[i][1])
                        key = aic.table.Search(keyname, keysys[k])
                    end
                end

                --键位设定
                DrawText('main_font_zh2', self.text3[i][1], x1, y + (self.pos2 / 3 - i) * d + 8, 0.5,
                    color(COLOR_WHITE, self.alpha), nil, 'left')
                DrawText('main_font_zh2', self.text3[i][2], x1, y + (self.pos2 / 3 - i) * d, 1,
                    color(COLOR_WHITE, self.alpha), nil, 'left')
                if key then
                    DrawText('main_font_zh2', key, x2, y + (self.pos2 / 3 - i) * d,
                        1, color(COLOR_WHITE, self.alpha), nil, 'right')
                end
            end

            --返回选项
            DrawText('main_font_zh2', '返回设置', x1, y + (self.pos2 / 3 - self.l2) * d, 1,
                color(COLOR_WHITE, self.alpha), nil, 'left')
            
            --设置说明
            local text = '选择需要更改的键位。'
            if self.key_changing then text = '按下新的键位。' end
            if self.pos2 == self.l2 then text = '返回设置。\n键位设置将在设置保存的同时变更。' end
            DrawText('main_font_zh2', text,
                x2 + 150, y - 3 * d, 1, color(COLOR_WHITE, self.alpha), nil, 'centerpoint')

            --指示光标
            local l, r, o = '<', '>', 3
            if self.key_changing then l, r, o = '>', '<', 5 end
            if not self.locked then
                for i = 1, self.l2 do
                    if i == self.pos2 then
                        DrawText('main_font_zh2', l, x1 - 25 - 5 * sin(o * self.timer),
                            y + (self.pos2 / 3 - i) * d, 1, color(COLOR_WHITE, self.alpha), nil, 'left')
                        DrawText('main_font_zh2', r, x2 + 25 + 5 * sin(o * self.timer),
                            y + (self.pos2 / 3 - i) * d, 1, color(COLOR_WHITE, self.alpha), nil, 'right')
                    end
                end
            end

        end
        SetViewMode('world')
    end,
    flyin = function(self)
        self.locked = true
        --self.wait = self.t
        self.x = self.default_x + screen.width * 0.25
        self.y = self.default_y
        task.New(self, function()
            task.Wait(self.t / 4)
            for i = 1, self.t * 3 / 4 do
                self.alpha = i * 255 / (self.t * 3 / 4)
                task.Wait()
            end
            self.locked = false
        end)
        task.New(self, function()
            task.MoveTo(self.default_x, self.y, self.t, 2)
        end)
    end,
    flyout = function(self, dir)
        self.locked = true
        --self.wait = self.t
        task.New(self, function()
            for i = 1, self.t do
                self.alpha = 255 - i * 255 / self.t
                task.Wait()
            end
        end)
        if dir == 1 then
            task.New(self, function()
                --task.MoveTo(self.x, screen.height * 1.5, self.t, 2)
                task.MoveTo(self.x, self.y + 20, self.t, 2)
            end)
        elseif dir == -1 then
            task.New(self, function()
                --task.MoveTo(self.x, screen.height * -0.5, self.t, 2)
                task.MoveTo(self.x, self.y - 20, self.t, 2)
            end)
        elseif dir == 'quit' then
            task.New(self, function()
                --task.MoveTo(self.x, screen.height * -0.5, self.t, 2)
                task.MoveTo(self.x, self.y - 20, self.t, 2)
                self.kill = true
                self.pos = 1
                self.timer = 0
            end)
        end
    end,
    applySetting = function(newsetting)
        setting.resx, setting.resy, setting.windowed, setting.vsync = newsetting.resx, newsetting.resy, newsetting.windowed, newsetting.vsync
        if not lstg.ChangeVideoMode(setting.resx, setting.resy, setting.windowed, setting.vsync) then
            setting.windowed = true
            saveConfigure()
            if not lstg.ChangeVideoMode(newsetting.resx, newsetting.resy, newsetting.windowed, newsetting.vsync) then
                stage.QuitGame()
                return
            end
        end
        ResetScreen(true)
        ResetUI()
        saveConfigureTable(newsetting)
        loadConfigure()
        lstg.SetSEVolume(newsetting.sevolume / 100)
        lstg.SetBGMVolume(newsetting.bgmvolume / 100)
    end
}

----------------------------------------
---暂停菜单资源

--[[
LoadTexture('pause', 'THlib/UI/pause.png')
LoadImage('pause_pausemenu', 'pause', 2, 0, 168, 70)
SetImageCenter('pause_pausemenu', 0, 35)
LoadImage('pause_gameover', 'pause', 172, 0, 170, 70)
SetImageCenter('pause_gameover', 0, 35)
LoadImage('pause_replayover', 'pause', 352, 0, 162, 70)
SetImageCenter('pause_replayover', 0, 35)
LoadImage('pause_Return to Game', 'pause', 0, 80, 245, 60)
SetImageCenter('pause_Return to Game', 0, 30)
LoadImage('pause_Return to Title', 'pause', 0, 140, 260, 56)
SetImageCenter('pause_Return to Title', 0, 28)
LoadImage('pause_Give up and Retry', 'pause', 0, 197, 200, 58)
SetImageCenter('pause_Give up and Retry', 0, 29)
LoadImage('pause_Restart', 'pause', 0, 197, 200, 58)
SetImageCenter('pause_Restart', 0, 29)
LoadImage('pause_yes', 'pause', 200, 196, 112, 60)
SetImageCenter('pause_yes', 0, 30)
LoadImage('pause_no', 'pause', 340, 196, 112, 60)
SetImageCenter('pause_no', 0, 30)
LoadImage('pause_Quit and Save Replay', 'pause', 0, 256, 360, 58)
SetImageCenter('pause_Quit and Save Replay', 0, 29)
LoadImage('pause_really', 'pause', 0, 316, 240, 60)
SetImageCenter('pause_really', 0, 30)
LoadImage('pause_savereplay', 'pause', 0, 368, 188, 60)
SetImageCenter('pause_savereplay', 0, 30)
LoadImage('pause_Replay Again', 'pause', 0, 432, 224, 56)
SetImageCenter('pause_Replay Again', 0, 28)
LoadImage('pause_Continue', 'pause', 232, 432, 120, 58)
SetImageCenter('pause_Continue', 0, 29)
LoadImage('pause_Manual', 'pause', 0, 490, 150, 56)
SetImageCenter('pause_Manual', 0, 28)
LoadImage('pause_eff', 'pause', 408, 320, 104, 384)
]]

local pause = { 'pausemenu', 'gameover', 'replayover', 'Return to Game', 'Return to Title', 'Give up and Retry',
    'yes', 'no', 'Quit and Save Replay', 'really', 'savereplay', --以后谁再把replay写成reply我打死他
    'Replay Again', 'Continue', 'Manual', 'Option', 'Mission Incomplete', 'Return to Waypoint' }

local center = { { 0, 35 }, { 0, 35 }, { 0, 35 }, { 0, 30 }, { 0, 28 }, { 0, 29 }, { 0, 29 },
    { 0, 30 }, { 0, 30 }, { 0, 29 }, { 0, 30 }, { 0, 30 }, { 0, 28 }, { 0, 29 }, { 0, 28 },
    { 0, 28 }, { 0, 32 }, { 0, 30 } }

for k, v in ipairs(pause) do
    LoadImageFromFile('pause_' .. v, 'THlib/UI/pause_menu/pause_' .. v .. '.png')
    if center[k] then SetImageCenter('pause_' .. v, center[k][1], center[k][2]) end
end
LoadImageFromFile('pause_eff', 'THlib/UI/pause_menu/pause_eff_new.png')
--重复加载，这是不ao的
LoadImageFromFile('pause_Restart', 'THlib/UI/pause_menu/pause_Give up and Retry.png')
SetImageCenter('pause_Restart', 0, 29)

for i = 1, 10 do
    LoadImageFromFile('Muki_AiC_help' .. i, 'THlib/UI/pause_menu/help/Muki_AiC_help' .. i .. '.png')
    LoadImageFromFile('Muki_AiC_help_menu' .. i, 'THlib/UI/pause_menu/help/Muki_AiC_help_menu' .. i .. '.png')
end
