local lib = aic.menu

------------------------------------------------------------

---难度选择菜单
lib.difficulty_select = Class(object)

function lib.difficulty_select:init()
    self.num = 8 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.pos = aic.sys.GetDiff() or 1
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
    self._alpha = { 55, 55, 55, 55 } --各难度图标透明度
    self._alpha[self.pos] = 255
    self.scale = { 0.35, 0.35, 0.35, 0.15 } --各难度图标缩放比
    self.scale[self.pos] = self.scale[self.pos] * 1.25
    self.l = 4
    self.text =
    {
        { '休闲', '伤害倍率：0.8x\n魔力槽碎裂概率：50%', '即使未接触过弹幕游戏的人\n也能安心享受的难度。\n放心大胆地miss吧。' },
        { '普通', '伤害倍率：1.0x\n魔力槽碎裂概率：75%', '为曾接触过其他低密度\n弹幕游戏的玩家准备的难度。\n在符卡的使用上请不要吝啬。' },
        { '噩梦', '伤害倍率：1.2x\n魔力槽碎裂概率：90%', '为有经验的东方玩家准备的难度，\n弹幕更具挑战性。\n从这里开始，不再有任何仁慈。' },
        { '地狱', '伤害倍率：1.5x\n魔力槽碎裂概率：100%', '献给各位机师的难度。\n向LNNNN*进发吧。\n在此难度下如果处于插件过载状态，\n一次Miss就会满身疮痍。\n*Lunatic No Miss No Bomb No Dodge No Enhancer。' }
    }
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
        local pos = self.pos
        task.New(self, function()
            task.MoveTo(self.x + sign * screen.width / 2, self.y, t, 2)
        end)
        task.New(self, function()
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

function lib.difficulty_select:frame()
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
            scoredata.difficulty_select = self.pos
            self.quit()
            lib.PushMenuStack(lib.player_select)
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

function lib.difficulty_select:render()
    SetViewMode('ui')
    lib.DrawSubTitle(self)
    lib.DrawTips(self, { '选择难度', '返回上一级菜单' })

    local x, y = self.x - screen.width * 1.25, self.y
    for i = 1, self.l do
        SetImageState('Muki_AiC_menu_difficulty_select' .. i, '', Color(min(self.alpha, self._alpha[i]), 255, 255, 255))
        --暴力调参
        if i == 4 then
            x = x - 20
            y = y - 50
        end
        Render('Muki_AiC_menu_difficulty_select' .. i, x + screen.width * 0.5 * (i + 1), y, 0, self.scale[i])
    end

    local x, y = screen.width * 0.7, screen.height * 0.35
    local co = { { 0, 144, 44 }, { 0, 84, 178 }, { 0, 9, 197 }, { 167, 66, 174 } } --各难度对应颜色
    DrawText('aic_menu', self.text[self.text_pos][1], x, y + 135, 2,
        Color(min(self.alpha, self.text_alpha), unpack(co[self.text_pos])), nil, 'centerpoint')
    DrawText('aic_menu', self.text[self.text_pos][2], x, y + 80, 1,
        Color(min(self.alpha, self.text_alpha), 255, 255, 255), nil, 'centerpoint')
    local dy = 0
    if self.text_pos == 4 then dy = -20 end
    DrawText('aic_menu', self.text[self.text_pos][3] .. '\n弹幕难度区分尚未实装，\n当前难度仅影响系统。', x, y + 10 + dy, 1,
        Color(min(self.alpha, self.text_alpha), 255, 255, 255), nil, 'centerpoint')

    SetViewMode('world')
end
