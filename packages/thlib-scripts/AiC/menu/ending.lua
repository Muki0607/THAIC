local lib = aic.menu

------------------------------------------------------------

---结局（staff画面也在这里）
lib.ending = Class(object)

function lib.ending:init()
    self.num = 14 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.default_x = screen.width * 0.5
    self.default_y = screen.height * 0.5
    self.bound = false
    self.t = 30
    self.wait = 30
    self.pos = 1
    self.l = 4
    self.alpha = 0
    self.text_scale = 1
    self.text_co = color()
    self.intv = 4
    self.text = ''
    self.text1 = { 'B', 'C', 'D', 'E' }
    self.text2 = aic.l10n.dialog.ending_name
    self.text3 = aic.l10n.dialog.staff
    self.texty = screen.height * 0.75
    self.ttfdrawer = aic.custom_dialog.TTFDrawer('', self)
    function self.ShowEnding()
        if not lib.EndingFlag then return end
        self.playing = true
        task.New(self, function()
            if lib.EndingFlag ~= 'D' then
                _play_music('aic_bgm18', nil, false)
            end
            local d = aic.l10n.dialog.dialog_ending[lib.EndingFlag]
            local l
            for i, v in ipairs(d.text) do
                l = sp.string(v):GetCharCount()
                local snd = d.snd[i]
                for j = 1, l do
                    self.text = self.text .. sp.string(v):Sub(j, j)
                    PlaySound(snd, 1, 0, true)
                    task.Wait(self.intv)
                end
                self.text = self.text .. '\n'
                task.Wait(self.t)
                if i % 28 == 0 then self.text = '' end
            end
            self.finished = true
        end)
    end
    scoredata.ending = scoredata.ending or { A = false, B = false, C = false, D = false, E = false }
    self.ending = scoredata.ending
end

function lib.ending:frame()
    task.Do(self)
    self.ttfdrawer:set(self.text)
    if self.staff_flag1 then
        if not self.staff_flag2 then
            self.staff_flag2 = true
            self.finished = false
            _play_music('aic_bgm19')
            task.New(self, function()
                for _ = 1, _infinite do
                    local dy = screen.height * #self.text3 / (70 * 60)
                    if KeyIsDown('shoot') then dy = dy * 3 end
                    self.texty = min(self.texty + dy, screen.height * (#self.text3 + 0.5))
                    if self.texty == screen.height * (#self.text3 + 0.5) then self.finished = true end
                    task.Wait()
                end
            end)
            task.New(self, function()
                for _ = 1, _infinite do
                    if self.finished and KeyIsPressed('shoot') then lib.PopMenuStack() end
                    task.Wait()
                end
            end)
        end
        return
    end
    if self.finished and KeyIsPressed('shoot') then 
        if lib.StaffFlag then
            self.staff_flag1 = true
            lib.EndingFlag = nil
        else
            PlaySound('cancel00', 0.3)
            lib.EndingFlag = nil
            lib.PopMenuStack()
        end
    end
    if lib.EndingFlag then
        if (not self.finished) and (not self.playing) then
            self.ShowEnding()
        end
        return
    else
        self.text = ''
        self.wait = max(self.wait - 1, 0)
        if self.wait < 1 then
            if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
                PlaySound('cancel00', 0.3)
                lib.PopMenuStack()
            end
            if KeyIsPressed('shoot') then
                if self.ending[self.text1[self.pos]] then
                    lib.EndingFlag = self.text1[self.pos]
                    PlaySound('ok00', 0.3)
                else
                    PlaySound('invalid', 0.5)
                end
            end
            if KeyIsDown('up') then
                self.wait = 10
                PlaySound('select00', 0.3)
                if self.pos > 1 then
                    self.pos = self.pos - 1
                else
                    self.pos = self.l
                end
            elseif KeyIsDown('down') then
                self.wait = 10
                PlaySound('select00', 0.3)
                if self.pos < self.l then
                    self.pos = self.pos + 1
                else
                    self.pos = 1
                end
            end
        end
    end
end

function lib.ending:render()
    SetViewMode('ui')
    if self.staff_flag1 then
        for i, v in ipairs(self.text3) do
            if #v == 2 then
                DrawText('main_font_zh2', v[1], self.x, self.texty - screen.height * i, 2.5, nil, nil, 'centerpoint')
                DrawText('main_font_zh2', v[2], self.x, self.texty - screen.height * i - 35, 1.5, nil, nil, 'centerpoint')
            elseif #v == 3 then
                DrawText('main_font_zh2', v[1], self.x, self.texty - screen.height * i, 2, nil, nil, 'centerpoint')
                DrawText('main_font_zh2', v[2], self.x, self.texty - screen.height * i - 25, 1, nil, nil, 'centerpoint')
                DrawText('main_font_zh2', v[3], self.x, self.texty - screen.height * i - 85, 2, nil, nil, 'centerpoint')
            else
                DrawText('main_font_zh2', v[1], self.x, self.texty - screen.height * i, 2, nil, nil, 'centerpoint')
                DrawText('main_font_zh2', v[2], self.x, self.texty - screen.height * i - 25, 1, nil, nil, 'centerpoint')
                DrawText('main_font_zh2', v[3], self.x, self.texty - screen.height * i - 55, 2, nil, nil, 'centerpoint')
                DrawText('main_font_zh2', v[4], self.x, self.texty - screen.height * i - 80, 0.75, nil, nil, 'centerpoint')
            end
        end
        return
    end
    if lib.EndingFlag then
        local x, y = 15, screen.height - 15
        self.ttfdrawer:render('dialog',
            x, x, y, y, 16, 32, 0, 0,
            self.text_scale, self.text_co, 4)
    else
        lib.DrawTips(self, { '选择', '返回上一级菜单' })
        local d, x, y, text1, text2 = 75, self.x, self.y - 25, self.text1, self.text2
        for i = 1, self.l do
            if i == self.pos then
                if self.ending[self.text1[self.pos]] then
                    DrawText("main_font_zh2", '结局' .. text1[i], x, y + (2.5 - i) * d, 1.25,
                        color(COLOR_BLACK, self.alpha), Color(self.alpha, 32, 208, 255), 'centerpoint')
                    DrawText("main_font_zh2", text2[i], x, y + (2.5 - i) * d - 20, 1,
                        color(COLOR_BLACK, self.alpha), Color(self.alpha, 32, 208, 255), 'centerpoint')
                else
                    DrawText("main_font_zh2", '结局' .. text1[i], x, y + (2.5 - i) * d, 1.25,
                        color(COLOR_BLACK, self.alpha), Color(self.alpha, 32, 208, 255), 'centerpoint')
                    DrawText("main_font_zh2", '？？？？', x, y + (2.5 - i) * d - 20, 1,
                        color(COLOR_BLACK, self.alpha), Color(self.alpha, 32, 208, 255), 'centerpoint')
                end
            else
                if self.ending[self.text1[self.pos]] then
                    DrawText("main_font_zh2", '结局' .. text1[i], x, y + (2.5 - i) * d, 1.25,
                        color(COLOR_BLACK, self.alpha), color(COLOR_WHITE, self.alpha), 'centerpoint')
                    DrawText("main_font_zh2", text2[i], x, y + (2.5 - i) * d - 20, 1,
                        color(COLOR_BLACK, self.alpha), color(COLOR_WHITE, self.alpha), 'centerpoint')
                else
                    DrawText("main_font_zh2", '结局' .. text1[i], x, y + (2.5 - i) * d, 1.25,
                        color(COLOR_BLACK, self.alpha), color(COLOR_DEEP_GRAY, self.alpha), 'centerpoint')
                    DrawText("main_font_zh2", '？？？？', x, y + (2.5 - i) * d - 20, 1,
                        color(COLOR_BLACK, self.alpha), color(COLOR_DEEP_GRAY, self.alpha), 'centerpoint')
                end
            end
        end
    end

    SetViewMode('world')
end
