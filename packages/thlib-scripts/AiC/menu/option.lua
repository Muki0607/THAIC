local lib = aic.menu

---option（大致与ext的option相同）
lib.option = Class(object)

function lib.option:init()
    self.num = 6
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.default_x = screen.width * 0.5
    self.default_y = screen.height * 0.5
    self.pos1 = 1
    self.pos2 = 1
    self.t = 16
    self.l1 = 15
    self.l2_key = 9
    self.l2_keysys = 5
    self.l2 = self.l2_key + self.l2_keysys
    self.alpha = 255
    self.scale = 0.5
    self.level = 1
    self.wait = 30
    self.timer = 0
    self.key_changing = false
    self.username_changing = false
    self.username = setting.username
    self.bound = false
    self.setting = loadConfigureTable() --因为需要存读文件，为了安全起见这边和插件菜单一样单独先存一份，保存时再存整个表到setting
    self.res = { { 640, 480, true }, { 800, 600 }, { 960, 720, true }, { 1024, 768, true }, { 1280, 960, true }, { 1600, 1200 }, { 1920, 1440, true } }
    self.text1 = {
        { '用户名', self.username, self.username },
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
        '保存并退出' }
    self.text2 = {
        '更改用户名。\n按Backspace键删除已输入字符，\n按Esc键保存更改。\n用户名与游戏存档绑定，\n更改用户名可以更换存档（需重启游戏）。',
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
        '更改键盘或手柄的按键。',
        '将所有设定还原至默认值。',
        '保存设定并退出。\n若不想保存设定，\n请直接按取消键退出。',
    }
    self.text3 = { { 'UP', '上移' }, { 'DOWN', '下移' }, { 'LEFT', '左移' }, { 'RIGHT', '右移' }, { 'SLOW', '低速移动' }, { 'SHOOT', '射击/确认' }, { 'SPELL', '符卡/取消' }, { 'SPECIAL', '系统特殊功能' }, { 'SKILL', '自机特殊功能' }, { 'REPFAST', '录像播放加速' }, { 'REPSLOW', '录像播放减速' }, { 'MENU', '暂停/返回' }, { 'SNAPSHOT', '截图' }, { 'RETRY', '快速重新开始' } }
    self.setname = { 'username', 'resx', 'windowed', 'vsync', 'sevolume', 'bgmvolume', 'autofire', 'autoslow', 'autododge', 'newopening', 'newbgm', 'safemode' }
    
    for k, v in ipairs(self.res) do
        if v[1] == self.setting.resx then
            self.pos_res = k
        end
    end
    for _, v in ipairs({ 'autofire', 'autoslow', 'autododge', 'newopening', 'newbgm' }) do 
        self.setting[v] = self.setting[v] or false
    end
    self.setting.safemode = self.setting.safemode or true

    self.applySetting = function(newsetting)
        setting.resx, setting.resy, setting.windowed, setting.vsync = newsetting.resx, newsetting.resy, newsetting.windowed, newsetting.vsync
        if not lstg.ChangeVideoMode(setting.resx, setting.resy, setting.windowed, setting.vsync) then
            setting.windowed = true
            saveConfigure()
            if not lstg.ChangeVideoMode(newsetting.resx, newsetting.resy, newsetting.windowed, newsetting.vsync) then
                stage.QuitGame()
                return
            end
        end
        lstg.SetSEVolume(newsetting.sevolume / 100)
        lstg.SetBGMVolume(newsetting.bgmvolume / 100)
        saveConfigureTable(newsetting)
        loadConfigure()
        ResetScreen(true)
        ResetUI()
    end

    self.flyin = function()
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
    end

    self.flyout = function(dir)
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
            lib.PopMenuStack()
        end
    end
    lib.Fly(self, 1, 'right')
end

function lib.option:frame()
    task.Do(self)
    self.timer = self.timer + 1
    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 and not self.locked then
        --local lastkey = GetLastKey()
        local set = self.setting
        if self.level == 1 then
            --一层（主设置）逻辑
            if self.username_changing then
                if aic.input.CheckLastKey('menu') then
                    self.wait = self.t
                    self.username_changing = false
                end
                local lastchar = aic.input.GetLastChar()
                if #self.username < 8 and lastchar then
                    self.wait = 8
                    self.username = self.username .. lastchar
                end
                if GetKeyState(KEY.ESCAPE) then
                    self.wait = self.t
                    set.username = self.username
                    self.username_changing = false
                end
                if GetKeyState(KEY.BACKSPACE) then
                    self.wait = 8
                    self.username = string.sub(self.username, 1, -2)
                end
                return
            end
            if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
                --不保存直接退出
                PlaySound('cancel00', 0.5)
                self.flyout('quit') 
            end
            if KeyIsPressed('shoot') then
                self.wait = self.t
                if self.pos1 == 1 then
                    PlaySound('ok00', 0.5)
                    self.username_changing = true
                elseif self.pos1 == 13 then
                    --进入键位设置
                    PlaySound('ok00', 0.5)
                    self.key_changing = false
                    self.flyout(-1)
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
                    self.flyout('quit')
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
                    self.flyout(-1)
                    self.flyin()
                elseif KeyIsPressed('shoot') then
                    PlaySound('select00', 0.5)
                    if self.pos2 == self.l2 then
                        self.level = 1
                        self.flyout(-1)
                        self.flyin()
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
end

function lib.option:render()
    SetViewMode('ui')
    --SetImageState('white', '', Color(150, 85, 76, 74))
    --RenderRect('white', 0, screen.width, 0, screen.height)
    --副标题
    lib.DrawSubTitle(self, screen.width * 0.8)
    SetImageState('Muki_AiC_square_empty', '', color(COLOR_WHITE, self.alpha))
    SetImageState('Muki_AiC_square_middle', '', color(COLOR_WHITE, self.alpha))
    local d, x, y = 30, self.x - 30, self.y + screen.height * 0.45
    local x1, x2 = x - screen.width * 0.4, x + screen.width * 0.1

    if self.level == 1 then
        lib.DrawTips(self, { '确认', '返回上一级菜单' }, { '选择设置项', '更改设置项' })
        --设置名称与值
        for i = 1, self.l1 do
            local text = self.text1[i]
            if type(text) == 'string' then
                --用户名、键位设定、使用默认设定、保存并退出
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
                        if i == 1 then
                            --不知道为什么这里直接用表里的不行
                            DrawText('main_font_zh2', self.username, x2, y + (self.pos1 / 3 - i) * d,
                                1, color(COLOR_WHITE, self.alpha), nil, 'right')
                        else
                            DrawText('main_font_zh2', text[3], x2, y + (self.pos1 / 3 - i) * d,
                                1, color(COLOR_WHITE, self.alpha), nil, 'right')
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
        local l, r, o = '<', '>', 3
        if self.username_changing then l, r, o = '>', '<', 5 end
        if not self.locked then
            for i = 1, self.l1 do
                if i == self.pos1 then
                    DrawText('main_font_zh2', l, x1 - 25 - 5 * sin(o * self.timer),
                        y + (self.pos1 / 3 - i) * d, 1, color(COLOR_WHITE, self.alpha), nil, 'left')
                    DrawText('main_font_zh2', r, x2 + 25 + 5 * sin(o * self.timer),
                        y + (self.pos1 / 3 - i) * d, 1, color(COLOR_WHITE, self.alpha), nil, 'right')
                end
            end
        end
    else
        lib.DrawTips(self, { '更改键位', '返回上一级菜单' }, { '选择键位' })
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
end
