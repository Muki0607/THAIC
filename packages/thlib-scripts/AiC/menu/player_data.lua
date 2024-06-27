local lib = aic.menu

---玩家数据
---符卡数据部分因为需要分难度所以暂且搁置
lib.player_data = Class(object)

---@param scnum number @总符卡数
function lib.player_data:init(scnum)
    self.num = 13 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.default_x = screen.width * 0.5
    self.default_y = screen.height * 0.5
    self.bound = false
    self.t = 30
    self.wait = 30
    self.alpha = 0
    self.player_list = { "reimu_player", "marisa_player", "sakuya_player", "muki_player", "nenyuki_player" }
    self.diff_list = { "Easy", "Normal", "Hard", "Lunatic", --[["Extra"]] }
    self.sc_list = aic.l10n.ui.sc_list
    self.data = nil
    self.playdata = nil
    self.posX = 1 --自机选择
    self.posY = 1 --难度选择
    self.lX = #self.player_list
    self.lY = #self.diff_list
    self.lsc = scnum --总符卡数
    self.l = 10 --一页中显示的符卡数
    self.page = 1 --当前页数

    ---获取玩家数据
    ---
    ---由于涉及到scoredata的读取，不能每帧调用，否则会极其卡
    ---@return table
    function self.GetData()
        local data = scoredata.player_data
        local ret = {}
        if data then
            local score = data[self.player_list[self.posX]].high_score[self.posY]
            ret = sp.copy(score)
        end
        self.data = ret
    end

    --我都不知道套了多少层if……这是为了安全起见
    ---获取符卡历史
    ---
    ---由于涉及到scoredata的读取，不能每帧调用，否则会极其卡
    ---@return table
    function self.GetSCHist()
        local hist = scoredata.spell_card_hist or {}
        local ret = {}
        local function GetDefaultSCHist(ret, i)
            table.insert(ret, {
                4 * (i - 1) + self.posY,
                string.rep("？", min(#self.sc_list[self.posY][i], 21)),
                0,
                0
            })
        end
        for i = 1, self.lsc do
            local sg = hist[self.diff_list[self.posY]]
            if sg then
                local sc = sg[self.sc_list[self.posY][i]]
                if sc then
                    local record = sc[self.player_list[self.posX]]
                    if record then
                        table.insert(ret, {
                            i + self.posY - 1, --符卡编号
                            self.sc_list[self.posY][i], --符卡名
                            record[1], --收取次数
                            record[2] --挑战次数
                        })
                    else
                        GetDefaultSCHist(ret, i)
                    end
                else
                    GetDefaultSCHist(ret, i)
                end
            else
                GetDefaultSCHist(ret, i)
            end
        end
        self.data = ret
    end

    ---获取游戏次数、游玩时长、通关次数
    ---
    ---由于涉及到scoredata的读取，不能每帧调用，否则会极其卡
    ---@return table
    function self.GetPlayData()
        local data = scoredata.player_data
        local ret = {}
        if data then
            ret = {
                data[self.player_list[self.posX]].played_num,
                (function()
                    local time = data[self.player_list[self.posX]].played_time
                    if time < 0 then time = 0 end
                    local h = int(time / 3600)
                    time = time - h * 3600
                    local m = int(time / 60)
                    time = time - m * 60
                    local s = int(time)
                    return string.format("%d:%02d:%02d", h, m, s)
                end)(),
                data[self.player_list[self.posX]].finished_num[self.posY]
            }
        end
        self.playdata = ret
    end

    if self.lsc then
        self.lpage = int(self.lsc / self.l) + 1 --总页数
        self.GetSCHist()
    else
        self.GetData()
    end
    self.GetPlayData()

    lib.Fly(self, 1, 'left')
end

function lib.player_data:frame()
    task.Do(self)
    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        local lastkey = GetLastKey()
        if self.lsc and KeyIsPressed('shoot') then
            if self.page < self.lpage then
                self.page = self.page + 1
            else
                self.page = 1
            end
        end
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            self.wait = 114514
            lib.PopMenuStack()
            PlaySound('cancel00', 0.3)
        elseif KeyIsDown('up') then
            self.wait = self.t
            if self.posY > 1 then
                self.posY = self.posY - 1
            else
                self.posY = self.lY
            end
            PlaySound('select00', 0.3)
        elseif KeyIsDown('down') then
            self.wait = self.t
            if self.posY < self.lY then
                self.posY = self.posY + 1
            else
                self.posY = 1
            end
            PlaySound('select00', 0.3)
        elseif KeyIsDown('left') then
            self.wait = self.t
            if self.posX > 1 then
                self.posX = self.posX - 1
            else
                self.posX = self.lX
            end
            PlaySound('select00', 0.3)
        elseif KeyIsDown('right') then
            self.wait = self.t
            if self.posX < self.lX then
                self.posX = self.posX + 1
            else
                self.posX = 1
            end
            PlaySound('select00', 0.3)
        end
        local key = { setting.keys.shoot, setting.keys.up, setting.keys.down,
            setting.keys.left, setting.keys.right }
        --有按键输入时进行一次刷新
        if lastkey ~= KEY.NULL and aic.table.Search(key, lastkey) then
            self.GetPlayData()
            if self.lsc then
                self.GetSCHist()
            else
                self.GetData()
            end
        end
    end
end

--真的是调参地狱，我不想再碰这玩意了
function lib.player_data:render()
    SetViewMode('ui')
    local x, y = self.x, self.y - 70
    local lineh = 20
    local yos = (self.l + 1) * lineh * 0.5
    local co1, co2 = { 247, 225, 158 }, { 166, 129, 193 }
    local data, playdata = self.data, self.playdata
    lib.DrawSubTitle(self)
    if playdata then
        local d = 25
        local player = { "博丽 灵梦", "雾雨 魔理沙", "十六夜 咲夜", "小林 无记", "千幻 念雪" }
        local player_co = { { 255, 136, 170 }, { 221, 221, 85 }, { 85, 204, 255 }, { 76, 231, 235 }, { 165, 164, 249 } }
        --咲字渲不出来
        if self.posX == 3 then
            DrawText('sc_name', "咲", x + 20, y + 198, 1.3,
                Color(self.alpha, unpack(player_co[self.posX])), nil, 'center')
        end
        DrawText('main_font_zh2', player[self.posX], x, y + 195, 1.25,
            Color(self.alpha, unpack(player_co[self.posX])), nil, 'center')
        DrawText('main_font_zh2', '<', x - d * 2.25 - d / 5 * sin(3 * self.timer),
            y + 195, 1.25, color(COLOR_WHITE, self.alpha), nil, 'left')
        DrawText('main_font_zh2', '>', x + d * 2.25 + d / 5 * sin(3 * self.timer),
            y + 195, 1.25, color(COLOR_WHITE, self.alpha), nil, 'right')
        
        local diff = { "EASY", "NORMAL", "HARD", "LUNATIC", "EXTRA" }
        DrawText('main_font_zh2', diff[self.posY], x, y + 160, 1.25,
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
    if data then
        if self.lsc then --符卡数据渲染
            local xos = { -275, -250, -80, -30, 130, 220 }
            for i = 1 + self.l * (self.page - 1), self.l * self.page do
                local co
                if data[i][4] and data[i][4] > 0 then
                    if data[i][3] > 0 then
                        co = { 136, 136, 255 }
                    else
                        co = { 255, 255, 255 }
                    end
                else
                    co = { 136, 136, 136 }
                end
                for j = 1, 4 do
                    local align = 'left'
                    local text = data[i][j]
                    if j == 0 then
                    elseif j == 1 then
                    elseif j == 2 then
                    elseif j == 3 then
                    end
                    DrawText("main_font_zh2", text,
                        x + xos[1], y - i * lineh + yos + 25, 0.9, Color(self.alpha, unpack(co)), nil, 'vcenter', align)
                end
            end
        else --游玩数据渲染
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
                for j = 0, 5 do
                    local align = 'left'
                    local text = data[i][j]
                    if j == 0 then
                        text = i
                        align = 'right'
                    elseif j == 1 then
                        if tonumber(text) then
                            text = string.format("%2d", tonumber(text))
                        end
                    elseif j == 2 then
                        if tonumber(text) and tonumber(text) < 10000000000 then
                            text = string.format("%9d", tonumber(text))
                        end
                        align = 'right'
                    elseif j == 3 then
                        text = string.gsub(text, ' ', '     ')
                    end
                    DrawText("main_font_zh2", text,
                        x + xos[j + 1], y - i * lineh + yos + 25, 0.9, Color(self.alpha, r, g, b), nil, 'vcenter', align)
                end
                r = r + _d_r
                g = g + _d_g
                b = b + _d_b
            end
        end
    end
    SetViewMode('world')
end
