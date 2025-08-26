local lib = aic.menu

---记录名称（机签）
---这里参考TH18要存数据，所以先输一遍名字
---部分参考新版lstg菜单
lib.name_regist = Class(object)

function lib.name_regist:init()
    self.num = 11 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.posX = 0
    self.posY = 0
    self.x = screen.width * 0.5
    self.y = screen.height * 0.2
    self.default_x = screen.width * 0.5
    self.default_y = screen.height * 0.5
    self.bound = false
    self.t = 8
    self.wait = 30
    self.alpha = 0
    self.bound = false
    self.stages = lib.last_replay
    self.finish = lib.last_replay_finish
    self.lname = 8
    self.data = nil
    self.name = setting.username or ''
    self._posX = aic.sys.GetPlayer() --由于没有开始新的一局，此时可直接使用上一局选择来判断
    self._posY = aic.sys.GetDiff()
    self.player_list = { "reimu_player", "marisa_player", "sakuya_player", "muki_player", "nenyuki_player" }
    self.diff_list = { "Easy", "Normal", "Hard", "Lunatic", --[["Extra"]] }
    self.l = 10

    lstg.tmpvar.current_menu = self

    ---获得分数数据，由FetchReplaySlots修改而来
    ---@return table @分数数据表
    function self.GetScore()
        ext.replay.RefreshReplay() --这个不能忘，否则读到的就是上次的rep了
        local slot = ext.replay.GetSlot(0)
        -- 使用第一关的时间作为录像时间
        local date = '----/--/-- --:--:--'
        if slot.stages[1] then
            date = aic.sys.GetTime(slot.stages[1].stageDate + setting.timezone * 3600)
        end
        -- 统计总分数
        local totalScore = 0
        local stage_num = 0
        local tmp
        for i, k in ipairs(slot.stages) do
            totalScore = totalScore + slot.stages[i].score
            tmp = string.match(k.stageName, '^(.+)@.+$')
            if string.match(tmp, '%d+') == nil then
                stage_num = tmp
            else
                stage_num = 'Stage ' .. string.match(tmp, '%d+')
            end
        end
        if stage_num == 'AliceInCradle' then
            stage_num = 'Extra'
        end
        if slot.group_finish == 1 then
            stage_num = 'Clear'
        end
        local delay = lib.GetReplayDelay()
        return { '', totalScore, date, stage_num, delay }, slot --保存rep时会用到的当前rep
        --{ '--------', 1000000, '----/--/-- --:--:--', 'Stage -', '---%' }
    end
    local score
    score, self.slot = self.GetScore()
    self.data, self.score_pos = lib.SavePlayerData(score)
    if self.score_pos == 'XX' then self.data.XX = score end

    ---更新名称
    function self.UpdateName()
        self.data[self.score_pos][1] = self.name
    end
    self.UpdateName()

    ---获取键盘
    ---好暴力的写法
    ---@return table
    function self.GetKeyboard()
        local _keyboard = {}
        for i = 65, 90 do
            table.insert(_keyboard, i)
        end
        for i = 97, 122 do
            table.insert(_keyboard, i)
        end
        for i = 48, 57 do
            table.insert(_keyboard, i)
        end
        for _, i in ipairs({ 43, 45, 61, 46, 44, 33, 63, 64, 58, 59, 91, 93, 40, 41, 95, 47, 123, 125, 124, 126, 94 }) do
            table.insert(_keyboard, i)
        end
        for i = 35, 38 do
            table.insert(_keyboard, i)
        end
        for _, i in ipairs({ 42, 92, 127, 34 }) do
            table.insert(_keyboard, i)
        end
        return _keyboard
    end
    self.keyboard = self.GetKeyboard()

    lib.Fly(self, 1, 'left')
end

function lib.name_regist:frame()
    task.Do(self)
    ---疮痍曲
    if not self.music_flag then
        _play_music('aic_bgm20', nil, false)
        self.music_flag = true
    end
    self.wait = max(self.wait - 1, 0)
    self.posX = (self.posX + 13) % 13
    self.posY = (self.posY + 7) % 7
    if self.wait < 1 then
        --local lastkey = GetLastKey()
        if KeyIsDown('up') then
            self.wait = self.t
            self.posY = self.posY - 1
            PlaySound('select00', 0.3)
        elseif KeyIsDown('down') then
            self.wait = self.t
            self.posY = self.posY + 1
            PlaySound('select00', 0.3)
        elseif KeyIsDown('left') then
            self.wait = self.t
            self.posX = self.posX - 1
            PlaySound('select00', 0.3)
        elseif KeyIsDown('right') then
            self.wait = self.t
            self.posX = self.posX + 1
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            self.wait = self.t
            if self.posX == 12 and self.posY == 6 then
                --由OLC添加，保存rep时菜单用来记录名称的参数
                scoredata.repsaver = self.name
                -- 跳转至保存录像菜单
                lib.PushMenuStack(lib.save_replay, self.slot)
                PlaySound('ok00', 0.3)
            end
            if #self.name == self.lname then
                self.posX = 12
                self.posY = 6
            elseif self.posX == 11 and self.posY == 6 then
                if #self.name ~= 0 then
                    self.name = string.sub(self.name, 1, -2)
                    self.UpdateName()
                end
                PlaySound('cancel00', 0.3)
            elseif self.posX == 10 and self.posY == 6 then
                local char = string.char(0x20)
                self.name = self.name .. char
                self.UpdateName()
                PlaySound('ok00', 0.3)
            else
                local char = string.char(self.keyboard[self.posY * 13 + self.posX + 1])
                self.name = self.name .. char
                self.UpdateName()
                PlaySound('ok00', 0.3)
            end
        elseif KeyIsPressed("spell") or aic.input.CheckLastKey('menu') then
            if #self.name == 0 then
                --由OLC添加，保存rep时菜单用来记录名称的参数
                scoredata.repsaver = self.name
                -- 跳转至保存录像菜单
                lib.PushMenuStack(lib.save_replay, self.slot)
            else
                self.wait = self.t
                self.name = string.sub(self.name, 1, -2)
                self.UpdateName()
            end
            PlaySound('cancel00', 0.3)
        end
    end
end

function lib.name_regist:render()
    SetViewMode('ui')
    lib.DrawSubTitle(self)
    lib.DrawTips(self, { '输入字符', '删除字符' })

    -- 绘制键盘
    -- 未选中按键
    SetFontState("replay", "", Color(255 * self.alpha, unpack(ui.menu.unfocused_color)))
    --是谁写的在Lua里还从0开始数啊（恼）
    --担心哪里会有逻辑出问题就没改了
    local w, h, _y = 18, 15, self.y - 45
    local co
    for x = 0, 12 do
        for y = 0, 6 do    
            if x ~= self.posX or y ~= self.posY then
                co = color(COLOR_WHITE, 255 * self.alpha)
            else
                co = Color(255 * self.alpha, 32, 208, 255)
            end
            if y == 6 then
                if x == 12 then
                    DrawText("main_font_zh2", '终',
                        self.x + (x - 5.5) * w, _y - (y - 3.5) * h,
                        0.7, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                elseif x == 11 then
                    DrawText("main_font_zh2", 'BS',
                        self.x + (x - 5.5) * w, _y - (y - 3.5) * h,
                        0.7, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                else
                    DrawText("main_font_zh2", string.char(self.keyboard[y * 13 + x + 1]),
                        self.x + (x - 5.5) * w, _y - (y - 3.5) * h,
                        0.75, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                end
            else
                DrawText("main_font_zh2", string.char(self.keyboard[y * 13 + x + 1]),
                    self.x + (x - 5.5) * w, _y - (y - 3.5) * h,
                    0.75, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
            end
        end
    end
    
    local x, y = self.x, self.y + 90
    local lineh = 20
    local yos = (self.l + 1) * lineh * 0.5
    local co1, co2 = { 247, 225, 158 }, { 166, 129, 193 }
    local data = self.data
    local player = { "博丽 灵梦", "雾雨 魔理沙", "十六夜 咲夜", "小林 无记", "千幻 念雪" }
    local player_co = { { 255, 136, 170 }, { 221, 221, 85 }, { 85, 204, 255 }, { 76, 231, 235 }, { 165, 164, 249 } }
    --咲字渲不出来
    if self._posX == 3 then
        DrawText('sc_name', "咲", x + 20, y + 198, 1.3,
            Color(self.alpha, unpack(player_co[self._posX])), nil, 'center')
    end
    DrawText('main_font_zh2', player[self._posX], x, y + 195, 1.25,
        Color(self.alpha, unpack(player_co[self._posX])), nil, 'center')
    
    local diff = { "EASY", "NORMAL", "HARD", "LUNATIC", "EXTRA" }
    DrawText('main_font_zh2', diff[self._posY], x, y + 165, 1.25,
        color(COLOR_WHITE, self.alpha), nil, 'center')
    y = y + 25
    if data then
        local xos = { -275, -250, -80, -30, 130, 220 }
        --高级循环，小子
        local _beg_r = co1[1]
        local r = _beg_r
        local _end_r = co2[1]
        local _d_r = (_end_r - _beg_r) / (10 - 1)
        local _beg_g = co1[2]
        local g = _beg_g
        local _end_g = co2[2]
        local _d_g = (_end_g - _beg_g) / (10 - 1)
        local _beg_b = co1[3]
        local b = _beg_b
        local _end_b = co2[3]
        local _d_b = (_end_b - _beg_b) / (10 - 1)
        for i = 1, 10 do
            if not data[i] then return end
            for j = 0, 5 do
                local align = 'left'
                local text = data[i][j] or 'nil'
                if j == 0 then
                    text = i
                    align = 'right'
                elseif j == 1 then
                    if tonumber(text) then
                        text = string.format("%2d", tonumber(text))
                    end
                    if i == self.score_pos and #text < 8 then text = text .. '_' end
                elseif j == 2 then
                    if tonumber(text) and tonumber(text) < 10000000000 then
                        text = string.format("%9d", tonumber(text))
                    end
                    align = 'right'
                end
                if i == self.score_pos then
                    DrawText("main_font_zh2", text, x + xos[j + 1],
                        y - i * lineh + yos + 25, 0.9, Color(self.alpha, r, g, b), nil, align)
                else
                    DrawText("main_font_zh2", text, x + xos[j + 1],
                        y - i * lineh + yos + 25, 0.9, Color(self.alpha, r - 100, g - 100, b - 100), nil, align)
                end
            end
            r = r + _d_r
            g = g + _d_g
            b = b + _d_b
        end
        if self.score_pos == 'XX' then
            local i = 'XX'
            if not data[i] then return end
            for j = 0, 5 do
                local align = 'left'
                local text = data[i][j] or 'nil'
                if j == 0 then
                    text = i
                    align = 'right'
                elseif j == 1 then
                    if tonumber(text) then
                        text = string.format("%2d", tonumber(text))
                    end
                    text = text .. '_'
                elseif j == 2 then
                    if tonumber(text) and tonumber(text) < 10000000000 then
                        text = string.format("%9d", tonumber(text))
                    end
                    align = 'right'
                end
                DrawText("main_font_zh2", text, x + xos[j + 1],
                    y - 11 * lineh + yos + 25, 0.9, Color(self.alpha, r, g, b), nil, align)
            end
        end
    end

    SetViewMode('world')
end
