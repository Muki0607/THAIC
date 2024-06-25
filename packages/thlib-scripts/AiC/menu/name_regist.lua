local lib = aic.menu

---记录名称（机签）
---这里参考TH18要存数据，所以先输一遍名字
---部分参考新版lstg菜单
lib.name_regist = Class(object)

function lib.name_regist:init()
    self.num = 11 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.posX = 1
    self.posY = 1
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
    self.username = setting.username or ''
    self._posX = aic.sys.GetPlayer()
    self._posY = aic.sys.GetDiff()
    self.l = 10

    function self.GetScore()
        local text = {}
        local slot = ext.replay.GetSlot(0)
        -- 使用第一关的时间作为录像时间
        local date
        if slot.stages[1] then
            date = os.date("!%Y/%m/%d", slot.stages[1].stageDate + setting.timezone * 3600)
        end
        -- 统计总分数
        local totalScore = 0
        local diff, stage_num = slot.stages[1].stageExtendInfo.difficulty, 0
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
        local delay = int(((1 - lib.last_replay_frame * 60 / lib.last_replay_time) * 1000) / 10) .. '%'
        return diff, { '', totalScore, aic.sys.GetTime(date), stage_num, delay }
        --{ '--------', 1000000, '----/--/-- --:--:--', 'Stage -', '---%' }
    end

    ---获取玩家数据
    ---
    ---由于涉及到scoredata的读取，不能每帧调用，否则会极其卡
    ---@return table
    function self.GetData()
        local data = scoredata.player_data
        local ret = {}
        if data then
            local score = data[self.player_list[self._posX]].high_score[self._posY]
            for i = 1, 10 do
                if self.score[2] > score[i][2] then
                    for j = 9, i, -1 do
                        score[j + 1] = score[j]
                    end
                    score[i] = self.score
                end
            end
            ret = sp.copy(score)
        end
        self.data = ret
    end
    self.GetData() --由于自机和难度是确定的，只用调用一次就行

    ---获取游戏次数、游玩时长、通关次数
    ---
    ---由于涉及到scoredata的读取，不能每帧调用，否则会极其卡
    ---@return table
    function self.GetPlayData()
        local data = scoredata.player_data
        local ret = {}
        if data then
            ret = {
                data[self.player_list[self._posX]].played_num,
                (function()
                    local time = data[self.player_list[self._posX]].played_time
                    if time < 0 then time = 0 end
                    local h = int(time / 3600)
                    time = time - h * 3600
                    local m = int(time / 60)
                    time = time - m * 60
                    local s = int(time)
                    return string.format("%d:%02d:%02d", h, m, s)
                end)(),
                data[self.player_list[self._posX]].finished_num[self._posY]
            }
        end
        self.playdata = ret
    end
    self.GetPlayData() --由于自机和难度是确定的，只用调用一次就行

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

    _play_music('aic_bgm20', nil, false)
    lib.Fly(self, 1, 'left')
end

function lib.name_regist:frame()
    task.Do(self)
    self.wait = max(self.wait - 1, 0)
    self.posX = (self.posX + 13) % 13
    self.posY = (self.posY + 7) % 7
    if self.wait < 1 then
        --local lastkey = GetLastKey()
        if aic.input.CheckLastKey('menu') then
            PlaySound('cancel00', 0.5)
            self.wait = 114514
            lib.last_replay = nil
            lib.ClearMenuStack()
            lib.PopMenuStack()
            lib.PushMenuStack(lib.title)
        elseif KeyIsDown('up') then
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
                scoredata.repsaver = self.username
                -- 跳转至保存录像菜单
                lib.PushMenuStack(lib.save_replay)
            end

            if #self.username == self.lname then
                self.posX = 12
                self.posY = 6
            elseif self.posX == 11 and self.posY == 6 then
                if #self.username ~= 0 then
                    self.username = string.sub(self.username, 1, -2)
                end
                PlaySound('cancel00', 0.3)
            elseif self.posX == 10 and self.posY == 6 then
                local char = string.char(0x20)
                self.username = self.username .. char
                PlaySound('ok00', 0.3)
            else
                local char = string.char(self.keyboard[self.posY * 13 + self.posX + 1])
                self.username = self.username .. char
                PlaySound('ok00', 0.3)
            end
        elseif KeyIsPressed("spell") then
            if #self.username == 0 then
                self.wait = 114514
                lib.last_replay = nil
                lib.ClearMenuStack()
                lib.PopMenuStack()
                lib.PushMenuStack(lib.title)
            else
                self.wait = self.t
                self.username = string.sub(self.username, 1, -2)
            end
            PlaySound('cancel00', 0.3)
        end
    end
end

function lib.name_regist:render(IsSaveReplay)
    SetViewMode('ui')
    if not IsSaveReplay then
        lib.DrawSubTitle(self)
    end

    -- 绘制键盘
    -- 未选中按键
    SetFontState("replay", "", Color(255 * self.alpha, unpack(ui.menu.unfocused_color)))
    --是谁写的在Lua里还从0开始数啊（恼）
    --担心哪里会有逻辑出问题就没改了
    local w, h = 20, 20
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
                        self.x + (x - 5.5) * w, self.y - (y - 3.5) * h,
                        0.7, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                elseif x == 11 then
                    DrawText("main_font_zh2", 'BS',
                        self.x + (x - 5.5) * w, self.y - (y - 3.5) * h,
                        0.7, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                else
                    DrawText("main_font_zh2", string.char(self.keyboard[y * 13 + x + 1]),
                        self.x + (x - 5.5) * w, self.y - (y - 3.5) * h,
                        0.75, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                end
            else
                DrawText("main_font_zh2", string.char(self.keyboard[y * 13 + x + 1]),
                    self.x + (x - 5.5) * w, self.y - (y - 3.5) * h,
                    0.75, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
            end
        end
    end
    -- 名称
    SetFontState("replay", "", Color(255 * self.alpha, unpack(ui.menu.title_color)))
    RenderText("replay", self.username, self.x, self.y - 5.5 * ui.menu.line_height + 200, ui.menu.font_size,
        "centerpoint")
    
    local x, y = self.x, self.y - 70
    local lineh = 20
    local yos = (self.l + 1) * lineh * 0.5
    local co1, co2 = { 247, 225, 158 }, { 166, 129, 193 }
    local data, playdata = self.data, self.playdata
    if playdata then
        local d = 25
        local player = { "博丽 灵梦", "雾雨 魔理沙", "十六夜 咲夜", "小林 无记", "千幻 念雪" }
        local player_co = { { 255, 136, 170 }, { 221, 221, 85 }, { 85, 204, 255 }, { 76, 231, 235 }, { 165, 164, 249 } }
        --咲字渲不出来
        if self._posX == 3 then
            DrawText('sc_name', "咲", x + 20, y + 198, 1.3,
                Color(self.alpha, unpack(player_co[self._posX])), nil, 'center')
        end
        DrawText('main_font_zh2', player[self._posX], x, y + 195, 1.25,
            Color(self.alpha, unpack(player_co[self._posX])), nil, 'center')
        DrawText('main_font_zh2', '<', x - d * 2.25 - d / 5 * sin(3 * self.timer),
            y + 195, 1.25, color(COLOR_WHITE, self.alpha), nil, 'left')
        DrawText('main_font_zh2', '>', x + d * 2.25 + d / 5 * sin(3 * self.timer),
            y + 195, 1.25, color(COLOR_WHITE, self.alpha), nil, 'right')
        
        local diff = { "EASY", "NORMAL", "HARD", "LUNATIC", "EXTRA" }
        DrawText('main_font_zh2', diff[self._posY], x, y + 160, 1.25,
            color(COLOR_WHITE, self.alpha), nil, 'center')
        DrawText('main_font_zh2', '︿', x - 7, y + 150 + d / 2.5 + d / 7 * sin(3 * self.timer),
            1, color(COLOR_WHITE, self.alpha), nil, 'bottom')
        DrawText('main_font_zh2', '﹀', x - 7, y + 150 - d / 2.5 - d / 7 * sin(3 * self.timer),
            1, color(COLOR_WHITE, self.alpha), nil, 'top')
        
        for k, v in ipairs({ "总游戏回数", "游玩时长", "通关回数" }) do
            DrawText('main_font_zh2', v, x - d * 1.25,
                y - k * lineh - 80, 1, color(COLOR_WHITE, self.alpha), nil, 'right')
            DrawText('main_font_zh2', playdata[k], x + d * 1.25,
                y - k * lineh - 80, 1, color(COLOR_WHITE, self.alpha), nil, 'left')
        end
    end
    SetViewMode('world')
end
