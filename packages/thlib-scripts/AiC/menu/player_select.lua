local lib = aic.menu

------------------------------------------------------------

---自机选择菜单
lib.player_select = Class(object)

function lib.player_select:init()
    self.num = 9 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.pos = scoredata.player_select or 1
    self.text_pos = self.pos
    self.x = screen.width * 0.5 * (2 - self.pos)
    self.y = screen.height * 0.5
    self.default_x = screen.width * 0.5 * self.pos
    self.default_y = screen.height * 0.5
    self.bound = false
    self.t = 30
    self.wait = 30
    self.alpha = 0
    self.text_alpha = 0 --说明文字透明度
    self.l = 5
    self._alpha = {}    --各自机图标透明度
    for _ = 1, self.l do
        table.insert(self._alpha, 55)
    end
    self._alpha[self.pos] = 255
    self.scale = {} --各自机图标缩放比
    for _ = 1, self.l do
        table.insert(self.scale, 0.6)
    end
    self.scale[self.pos] = self.scale[self.pos] * 1.25
    self.quit = function()
        task.New(self, function()
            for i = 1, self.t do
                self.text_alpha = (255 - i * 255 / 30)
                task.Wait()
            end
        end)
    end
    self.move = function(dir)
        local t = self.t
        local sign
        if dir == 'left' then
            sign = 1
        else
            sign = -1
        end
        task.New(self, function()
            task.MoveTo(self.x + sign * screen.width / 2, self.y, t, 2)
        end)
        task.New(self, function()
            local pos = self.pos
            local scale1 = self.scale[pos]
            local scale2 = self.scale[pos - sign]

            for i = 1, t do
                self.scale[pos] = scale1 * (1 - 0.2 * i / t)
                self._alpha[pos] = self._alpha[pos] - 200 / t
                self.scale[pos - sign] = scale2 * (1 + 0.25 * i / t)
                self._alpha[pos - sign] = self._alpha[pos - sign] + 200 / t
                task.Wait()
            end
            self.pos = self.pos - sign
        end)
        task.New(self, function()
            for i = 1, t / 2 do
                self.text_alpha = 1 - i * 255 / (t / 2)
                task.Wait()
            end
            self.text_pos = self.text_pos - sign
            for i = 1, t / 2 do
                self.text_alpha = i * 255 / (t / 2)
                task.Wait()
            end
        end)
    end
    task.New(self, function()
        for i = 1, 30 do
            self.text_alpha = i * 255 / 30
            task.Wait()
        end
    end)
end

function lib.player_select:frame()
    task.Do(self)
    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        --local lastkey = GetLastKey()
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            PlaySound('cancel00', 0.3)
            self.wait = 114514
            self.quit()
            lib.PopMenuStack()
        end
        if KeyIsPressed('shoot') then
            self.wait = 114514
            PlaySound('ok00', 0.3)
            scoredata.player_select = self.pos
            lstg.var.player_name = player_list[self.pos][2]
            lstg.var.rep_player = player_list[self.pos][3]
            self.quit()
            lib.PushMenuStack(lib.enhancer_select)
        end
        if (KeyIsDown('up') or KeyIsDown('left')) and self.pos > 1 then
            self.wait = self.t + 5
            PlaySound('select00', 0.3)
            self.move('left')
        elseif (KeyIsDown('down') or KeyIsDown('right')) and self.pos < self.l then
            self.wait = self.t + 5
            PlaySound('select00', 0.3)
            self.move('right')
        end
    end
end

function lib.player_select:render()
    SetViewMode('ui')
    lib.DrawSubTitle(self)

    local x, y = self.x - screen.width * 1.25, self.y - screen.height * 0.15
    for i = 1, self.l do
        SetImageState('Muki_AiC_menu_player_select' .. i, '', Color(min(self.alpha, self._alpha[i]), 255, 255, 255))
        Render('Muki_AiC_menu_player_select' .. i, x + screen.width * 0.5 * (i + 1), y, 0, self.scale[i])
    end
    local x, y = screen.width * 0.7, screen.height * 0.5
    for i = 1, self.l do
        if self.text_pos == i then
            SetImageState('Muki_AiC_menu_player_select_text' .. i, '',
                Color(min(self.alpha, self.text_alpha), 255, 255, 255))
            Render('Muki_AiC_menu_player_select_text' .. i, x, y, 0, 0.75)
        end
    end

    lib.DrawTips(self, { '选择自机', '返回上一级菜单' })

    SetViewMode('world')
end
