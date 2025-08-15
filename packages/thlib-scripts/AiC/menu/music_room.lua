local lib = aic.menu

---音乐相关的函数，因为经常暴毙所以套一层TryExcept

--- 获取全局音乐音量
---@return number
function lib.GetBGMVolume()
    return GetBGMVolume()
end

--- 设置全局音乐音量
--- 当参数为 2 个时，设置指定音乐的音量
--- 不知道为啥有些时候只传一个参数会炸，只能手动模拟了
---@param bgmname string
---@param volume number
---@overload fun(volume:number)
function lib.SetBGMVolume(bgmname, volume)
    if bgmname == 'all' or type(bgmname) == 'number' then
        local _, bgm = EnumRes('bgm')
        for _, v in pairs(bgm) do
            SetBGMVolume(v, volume or bgmname)
        end
    else
        SetBGMVolume(bgmname, volume)
    end
end

---@param bgmname string
function lib.PauseMusic(bgmname)
    PauseMusic(bgmname)
end

---@param bgmname string
function lib.ResumeMusic(bgmname)
    ResumeMusic(bgmname)
end

---@param bgmname string
---@return lstg.AudioStatus
function lib.GetMusicState(bgmname)
    return GetMusicState(bgmname)
end

--[[
for _, v in ipairs({ 'GetBGMVolume', 'SetBGMVolume', 'PauseMusic', 'ResumeMusic', 'GetMusicState' }) do
    lib[v] = function(bgmname, volume)
        TryExcept(function()
                lstg[v](bgmname, volume)
            end,
            { [''] = pass })
    end
end
--]]

------------------------------------------------------------
---音乐室

lib.music_room = Class(object)

function lib.music_room:init(pos, l)
    self.num = 5 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.pos = pos or 1
    self.prepos1 = self.pos --前一个选择
    self.prepos2 = self.pos --前前一个选择
    self.headpos = 1 --显示的第一首bgm，决定所有bgm的位置
    self.textpos = 1 --下方评论对应的曲目
    self.truepos = 1 --光标所在位置
    self.warn1 = false --是否触发警告1
    self.warn2 = false --是否触发警告2
    self.random_text = '' --紫的曲子用的随机字符
    self.music_pos = 0 --音乐当前播放位置，由于没有能直接获取的函数，只能手动计时
    self.playing = false --当前是否在播放，虽然进入时在播放标题bgm但无法获得当前播放位置所以初始为false
    self.curr_bgm = 'aic_bgm1'
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.default_x = screen.width * 0.5
    self.default_y = screen.width * 0.5
    self.bound = false
    self.t = 8
    self.wait = 30
    self.alpha = 0
    self.text_alpha = 255
    self.lbgm = l or 21 --总bgm数
    if aic.DLC or _debug._debug then self.lbgm = 30 end --DLC扩充曲包
    self.l = 10 --一页显示bgm数
    self.debug = _debug.music_room_debug
    --初始化，由于文本文件在THlib加载完成前不会加载，需要等到游戏打开后再执行
    function self.Initialize()
        self.init_sign = true
        local text = aic.l10n.ui.music_room
        self.text1 = text.title
        self.text2 = text.comment
        self.text3 = text.warn1
        self.text4 = text.warn2
        self.text5 = text.warn3
    end
    ---检查bgm是否播放过
    ---@param num number @要检测的bgm编号
    function self.CheckRecord(num)
        return scoredata.music_record['aic_bgm' .. num]
    end
    lib.Fly(self, 1, 'left')
end

function lib.music_room:frame()
    task.Do(self)
    if not self.init_sign then self.Initialize() end
    self.wait = max(self.wait - 1, 0)
    self.curr_bgm = aic.misc.GetCurrentBGM() or self.curr_bgm --当前播放bgm，若暂停则为暂停前播放bgm
    if self.playing then
        self.music_pos = self.music_pos + 1
    end
    if self.wait < 1 then
        --local lastkey = GetLastKey()
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            self.wait = 114514
            lib.SetBGMVolume(setting.bgmvolume)
            PlaySound('cancel00', 0.3)
            lib.PopMenuStack()
        elseif KeyIsPressed('shoot') then
            self.wait = self.t
            if self.pos ~= self.textpos then self.warn1 = false end
            self.textpos = self.pos
            if self.CheckRecord(self.pos) or self.warn1 then
                self.warn1 = false
                if self.pos == 27 then
                    if self.warn2 then
                        self.warn2 = false
                        task.New(self, function()
                            lib.SetBGMVolume(setting.bgmvolume)
                            TryExcept(function()
                                    if self.pos == 16 and KeyIsDown('slow') then
                                        _play_music('aic_bgm16_full', nil, false)
                                        self.full_flag = true
                                    else
                                        _play_music('aic_bgm' .. self.pos, nil, false)
                                        self.full_flag = false
                                    end
                                    self.playing = true
                                    self.music_pos = 0
                                end,
                                { [''] = pass })
                            for t = 1, 30 do
                                self.text_alpha = 255 / 30 * t
                            end
                        end)
                    else
                        self.warn2 = true
                    end
                else
                    task.New(self, function()
                        lib.SetBGMVolume(setting.bgmvolume)
                        TryExcept(function()
                                if self.pos == 16 and KeyIsDown('slow') then
                                    _play_music('aic_bgm16_full', nil, false)
                                    self.full_flag = true
                                else
                                    _play_music('aic_bgm' .. self.pos, nil, false)
                                    self.full_flag = false
                                end
                                self.playing = true
                                self.music_pos = 0
                            end,
                            { [''] = pass })
                        for t = 1, 30 do
                            self.text_alpha = 255 / 30 * t
                        end
                    end)
                end
            else
                self.warn1 = true
            end
        elseif KeyIsDown('up') then
            self.wait = self.t
            PlaySound('select00', 0.3)
            if self.pos > 0 then
                self.prepos2 = self.prepos1
                self.prepos1 = self.pos
                self.pos = self.pos - 1
                --处理显示范围改变的问题
                if self.truepos == 1 then
                    self.headpos = self.headpos - 1
                else
                    self.truepos = self.truepos - 1
                end
            end
        elseif KeyIsDown('down') then
            self.wait = self.t
            PlaySound('select00', 0.3)
            if self.pos < self.lbgm then
                self.prepos2 = self.prepos1
                self.prepos1 = self.pos
                self.pos = self.pos + 1
                --处理显示范围改变的问题
                if self.truepos == 10 then
                    self.headpos = self.headpos + 1
                    
                else
                    self.truepos = self.truepos + 1
                end
            end
        elseif KeyIsDown('special') then
            self.wait = self.t
            if aic.misc.GetCurrentBGM() then
                lib.PauseMusic(self.curr_bgm)
                self.playing = false
            else
                lib.ResumeMusic(self.curr_bgm)
                self.playing = true
            end
        end
    end
end

function lib.music_room:render()
    SetViewMode('ui')
    lib.DrawSubTitle(self)
    lib.DrawTips(self, { '播放音乐', '返回上一级菜单', '暂停/继续音乐' }, { '选择音乐' })
    local d, x, y, text1 = 20, self.x - 260, self.y + 110, self.text1
    for i = 1, self.l do
        local pos, text = i + self.headpos - 1
        local title
        if self.CheckRecord(pos) then
            title = text1[pos]
        else
            title = '？？？？？？？？？？？'
        end
        if pos < 10 then
            text = 'No.　' .. pos .. '　' .. title
        else
            text = 'No.  ' .. pos .. '　' .. title
        end
        if pos == self.pos then
            DrawText("main_font_zh2", text, x - 10, y + (2.5 - i) * d, 0.9,
                Color(self.alpha, 223, 223, 103), color(COLOR_BLACK, self.alpha))
        elseif pos == self.prepos1 then
            DrawText("main_font_zh2", text, x, y + (2.5 - i) * d, 0.9,
                Color(self.alpha, 154, 154, 129), color(COLOR_BLACK, self.alpha))
        elseif pos == self.prepos2 then
            DrawText("main_font_zh2", text, x, y + (2.5 - i) * d, 0.9,
                Color(self.alpha, 134, 134, 129), color(COLOR_BLACK, self.alpha))
        else
            DrawText("main_font_zh2", text, x, y + (2.5 - i) * d, 0.9,
                Color(self.alpha, 129, 129, 129), color(COLOR_BLACK, self.alpha))
        end
    end
    local alpha = min(self.alpha, self.text_alpha)
    if self.textpos == 27 then
        if not self.warn2 then
            local text = self.random_text
            for _ = 1, 3 do
                text = text .. '\n                '
                for _ = 1, 50 do
                    text = text .. aic.table.Choice(self.text5)
                end
            end
            DrawText("main_font_zh2", '            ' .. text1[self.textpos] .. '\n' .. self.text2[self.textpos] .. text,
                x - 50, y - 180, 1, color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
        else
            DrawText("main_font_zh2", '            ' .. '\n' .. self.text4,
                x + 50, y - 180, 1, color(COLOR_DEEP_PURPLE, alpha), color(COLOR_BLACK, alpha))
        end
    else
        if self.CheckRecord(self.textpos) or not self.warn1 then
            DrawText("main_font_en", '    ♪ ', x - 50, y - 180, 1, color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
            if self.full_flag then
                DrawText("main_font_zh2", '            ' .. text1[self.textpos] .. '(full ver.)\n' .. self.text2[self.textpos],
                    x - 50, y - 180, 1, color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
            else
                DrawText("main_font_zh2", '            ' .. text1[self.textpos] .. '\n' .. self.text2[self.textpos],
                    x - 50, y - 180, 1, color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
            end
        else
            DrawText("main_font_zh2", '            ' .. '\n' .. self.text3,
                x + 50, y - 180, 1, color(COLOR_RED, alpha), color(COLOR_BLACK, alpha))
        end
    end
    if self.debug then
        local str = tostring
        DrawText("main_font_zh2", 'warn1=' .. str(self.warn1) .. '\nwarn2=' .. str(self.warn2)
            .. '\npos=' .. self.pos .. '\ntextpos=' .. self.textpos .. '\ncurr_bgm=' .. self.curr_bgm, 500, 300, 1,
            color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
        local music_pos = int(self.music_pos / 60)
        DrawText("main_font_zh2", '当前播放位置：' .. int(music_pos / 60) .. ':' .. (music_pos % 60), 500, 150, 1,
            color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
    end
    SetViewMode('world')
end
