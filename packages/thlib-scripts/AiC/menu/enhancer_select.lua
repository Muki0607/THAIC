local lib = aic.menu

------------------------------------------------------------

--最屎山的一个菜单，没有之一
---插件选择菜单
lib.enhancer_select = Class(object)

function lib.enhancer_select:init()
    self.num = 10 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP

    self.initialize = function()
        --本来要写多插件配置的，有申必bug，不想修，鸽了
        --[[
        if not scoredata.enhancer_select_num then
            scoredata.enhancer_select_num = 1
        end
        if (not scoredata.enhancer_select) or (not scoredata.enhancer_select[1]) or type(scoredata.enhancer_select[1]) ~= 'table' then
            scoredata.enhancer_select = { {}, {}, {}, {}, {} }
        end
        if not lstg.var.enhancer_select then
            lstg.var.enhancer_select = {}
            if scoredata.enhancer_select[scoredata.enhancer_select_num] then
                --lstg.var.enhancer_select = scoredata.enhancer_select
                for i = 1, 8 do
                    if scoredata.enhancer_select[scoredata.enhancer_select_num][i] then
                        lstg.var.enhancer_select[i] = scoredata.enhancer_select[scoredata.enhancer_select_num][i]
                        --防止莫名其妙的bug导致插件重复
                        for k1, v1 in ipairs(lstg.var.enhancer_select) do
                            for k2, v2 in ipairs(lstg.var.enhancer_select) do
                                if k1 ~= k2 and v1 == v2 then lstg.var.enhancer_select[k2] = nil end
                            end
                        end
                    end
                end
            end
        end
        ]]
        if not scoredata.enhancer_select then
            scoredata.enhancer_select = {}
        end
        if not scoredata.enhancer_slot then
            scoredata.enhancer_slot = 5
        end
        lstg.var.enhancer_select = {}
        --由于scoredata的元表特性table系的函数（insert，remove，unpack）全部不能用，只能点对点赋值
        for i = 1, 8 do
            if scoredata.enhancer_select[i] then
                lstg.var.enhancer_select[i] = scoredata.enhancer_select[i]
                --防止莫名其妙的bug导致插件重复
                for k1, v1 in ipairs(lstg.var.enhancer_select) do
                    for k2, v2 in ipairs(lstg.var.enhancer_select) do
                        if k1 ~= k2 and v1 == v2 then lstg.var.enhancer_select[k2] = nil end
                    end
                end
            end
        end
    end

    self.initialize()

    self.pos1 = 1
    self.pos2 = 1
    self.text_pos = lstg.var.enhancer_select[self.pos1]
    self.pos1_aft = self.pos1
    self.pos2_aft = self.pos2
    self.level = 1
    self.level_pre = self.level
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.default_x = screen.width * 0.5
    self.default_y = screen.height * 0.5
    self.bound = false
    self.t = 30
    self.wait = 30
    self.alpha = 0
    self.text_alpha = 0  --说明文字透明度
    self.l = 16          --总插件数
    self.n = { 5, 6, 5 } --各行插件数
    self.posn = 1        --当前所在行数

    --一些暴力调参得到的常量
    self.position = {} --各插件原坐标
    --这是什么地才写法
    for i = 1, 3 do
        local dx, x = -30
        if i == 2 then
            x = 0
        else
            x = 75 / 2
        end
        local y = 300 - i * 75 - 48
        for _ = 1, self.n[i] do
            x = x + 75
            table.insert(self.position, { x + dx, y })
        end
    end
    local d = 45
    self.slot_position = {} --各插件槽坐标
    --以当前版本最多10个插件槽来说最长的可能是消耗20个（9个+诺艾儿的法杖11个）
    --但多准备点总不是坏事
    for i = 1, 10 do
        table.insert(self.slot_position, { 0 + (i - 1) * d, 0, 0 })
        table.insert(self.slot_position, { 18 + (i - 1) * d, 9, 0 })
        table.insert(self.slot_position, { 17 + (i - 1) * d, -4, 180 })
        table.insert(self.slot_position, { 35 + (i - 1) * d, 5, 180 })
    end
    self.cost = { 2, 2, 3, 4, 1, 1, 2, 3, 2, 2, 2, 5, 0, 2, 3, scoredata.enhancer_slot + 1 } --各插件消耗

    self.text =
    {
        { '盗垒滑步', '使携带者免疫体术攻击，\n闪避后的无敌时间增加30f。' },
        { '藏巧守拙', '携带者Miss时不丢失魔力，\n但禁用收点线。\n\n适用于经常Miss的人。\n\n※不能与濡湿预兆同时携带' },
        { '双重闪避', '允许携带者连续闪避两次，\n闪避消耗降低25%。\n\n适用于喜欢闪避的人。' },
        { '超载咏唱', '允许携带者释放符卡时\n使用魔力补足缺少的过充魔力；\n符卡消耗增加10%。\n\n适用于经常使用符卡的人。' },
        { '抓地鞋', '允许携带者使用闪避时\n不按下方向键，\n此时将不进行移动。\n\n适用于只需要无敌时间的人。' },
        { '长法杖', '使携带者的射击\n判定大小增加50%，\n但伤害不变。\n对激光无效。' },
        { '祈雨御守', '当携带者击破敌人时，\n增加道具的掉落数量。' },
        { '濡湿预兆', '无论携带者Miss前魔力为多少，\n总会产生500魔力。\n\n适用于恐惧火力不足的人。\n\n※不能与藏巧守拙同时携带' },
        { '恐高症', '使携带者使用符卡后\n无敌时间增加60f。' },
        { '血之虹瞳', '携带者拾取过充魔力道具时\n不再增加5点过充魔力，\n而是增加1点生命值。' },
        { '猫之缓降', '当携带者处于收点线以上时\n获得60f无敌时间，\n冷却时间300f。\n\n适用于经常在收点时Miss的人。' },
        { '珠辉的素描本', '将符卡变为「珠辉的素描本」，\n伤害较低、无敌时间较短。\n符卡消耗降低60%。' },
        { '椎奈的编程指导书', '跳过所有对话。' },
        { '菖蒲的小型终端', '最大闪避距离增加100%。' },
        { '歌夜的耳机', '禁用符卡和闪避，\n受到伤害降低50%。' },
        { '诺艾儿的法杖', '射击伤害增加50%，\n单次Miss时魔力槽碎裂程度\n增加100%。\n若难度为噩梦则\n额外增加50%射击速度。\n\n本插件消耗插槽数始终为\n最大插槽数+1。' },
    }
    if _debug.pmode then
        self.text[12] = { '珠辉的素描本', '开启完美无缺模式。\n游戏会自动存档，\n当Miss时可以回到上一个存档点。' }
    end

    --一堆乱七八糟的函数

    self.quit = function()
        task.New(self, function()
            for i = 1, self.t do
                self.text_alpha = (255 - i * 255 / 30)
                task.Wait()
            end
        end)
    end

    --保存选择
    self.save = function()
        --scoredata.enhancer_select = lstg.var.enhancer_select
        --[[
        for i = 1, 8 do
            if lstg.var.enhancer_select[i] then
                scoredata.enhancer_select[scoredata.enhancer_select_num][i] = lstg.var.enhancer_select[i]
            end
        end
        ]]
        scoredata.enhancer_select = {}
        for i = 1, 8 do
            if lstg.var.enhancer_select[i] then
                --防止莫名其妙的bug导致插件重复
                for k1, v1 in ipairs(lstg.var.enhancer_select) do
                    for k2, v2 in ipairs(lstg.var.enhancer_select) do
                        if k1 ~= k2 and v1 == v2 then lstg.var.enhancer_select[k2] = nil end
                    end
                end
                scoredata.enhancer_select[i] = lstg.var.enhancer_select[i]
            end
        end
    end

    --位置移动
    self.move = function()
        self.pos2_aft = max(1, min(self.l, self.pos2_aft))
        local t = self.t
        task.New(self, function()
            local bool1, bool2
            if self.level_pre == 1 and self.level == 1 then
                bool1 = self.pos1 <= #lstg.var.enhancer_select
                bool2 = self.pos1_aft <= #lstg.var.enhancer_select
            elseif self.level_pre == 1 and self.level == 2 then
                bool1 = self.pos1 <= #lstg.var.enhancer_select
                bool2 = self.pos2_aft <= #self.cost and not CheckEnhancer(self.pos2_aft)
            elseif self.level_pre == 2 and self.level == 1 then
                bool1 = self.pos2 <= #self.cost and not CheckEnhancer(self.pos2)
                bool2 = self.pos1_aft <= #lstg.var.enhancer_select
            else
                bool1 = self.pos2 <= #self.cost and not CheckEnhancer(self.pos2)
                bool2 = self.pos2_aft <= #self.cost and not CheckEnhancer(self.pos2_aft)
            end
            for i = 1, t / 2 do
                if bool1 then
                    self.text_alpha = 255 - i * 255 / (t / 2)
                end
                task.Wait()
            end
            if self.level == 1 then
                self.text_pos = lstg.var.enhancer_select[self.pos1_aft]
            else
                self.text_pos = self.pos2_aft
            end
            for i = 1, t / 2 do
                if bool2 then
                    self.text_alpha = i * 255 / (t / 2)
                end
                task.Wait()
            end
            if self.level == 1 then
                self.pos1 = self.pos1_aft
            else
                self.pos2 = self.pos2_aft
            end
            if self.pos2 > aic.table.Sum(self.n, 1, self.posn) then
                self.posn = self.posn + 1
            else
                local n
                if self.posn > 1 and self.pos2 <= aic.table.Sum(self.n, 1, self.posn - 1) then
                    self.posn = self.posn - 1
                end
            end
        end)
    end

    --重新计算已装备插件位置
    self.refresh = function(t)
        for k, v in ipairs(lstg.var.enhancer_select) do
            task.New(self.enhancer[v], function()
                local x, y = self.get_position(k)
                if self.level == 1 and lstg.var.enhancer_select[self.cursor.pos] then
                    --self.text_pos = lstg.var.enhancer_select[self.cursor.pos]
                end
                task.MoveTo(x, y, t, 2)
            end)
        end
    end

    --插件装备与卸载
    self.fly = function(equip, pos)
        if not self.enhancer[pos] then return end
        if equip == 1 then
            task.New(self.enhancer[pos], function()
                local x, y = self.get_position(#lstg.var.enhancer_select)
                task.MoveTo(x, y, self.t, 2)
            end)
        else
            task.New(self.enhancer[pos], function()
                self.refresh(30)
                task.MoveTo(self.position[pos][1], self.position[pos][2], self.t, 2)
            end)
        end
    end

    --移动光标
    self.cursor_move = function(x, y, pos)
        task.New(self.cursor, function()
            task.MoveTo(x, y, self.t, 2)
            if pos then
                self.cursor.pos = pos
            end
        end)
    end

    --计算已消耗插件槽总和
    self.cost_calc = function()
        local s = 0
        for _, v in ipairs(lstg.var.enhancer_select) do
            s = s + self.cost[v]
        end
        return s
    end

    --根据位置获取已装备插件区坐标
    self.get_position = function(pos)
        return -20 + pos * 75, screen.height * 0.65, pos
    end

    --根据二层位置获取一层位置
    self.find = function(pos)
        --[[
        for k, v in ipairs(lstg.var.enhancer_select) do
            if v == pos then return k end
        end
        --]]
        return aic.table.Search(lstg.var.enhancer_select, pos)
    end

    --重新创建插件图标和选择光标
    self.recreate = function()
        if self.cursor and IsValid(self.cursor) then
            Del(self.cursor)
        end
        if self.enhancer then
            for i = 1, self.l do
                if self.enhancer[i] and IsValid(self.enhancer[i]) then
                    Del(self.enhancer[i])
                end
            end
        else
            self.enhancer = {}
        end
        if #lstg.var.enhancer_select > 0 then
            for i = 1, #self.cost do
                if not CheckEnhancer(i) then
                    self.enhancer[i] = New(lib.enhancer, self, self.position[i][1], self.position[i][2], i)
                end
            end
            for k, v in ipairs(lstg.var.enhancer_select) do
                local x, y = self.get_position(k)
                if not self.enhancer[v] then
                    self.enhancer[v] = New(lib.enhancer, self, x, y, v)
                end
            end
        else
            for i = 1, #self.cost do
                table.insert(self.enhancer, New(lib.enhancer, self, self.position[i][1], self.position[i][2], i))
            end
        end
        self.cursor = New(lib.enhancer_cursor, self, self.get_position(self.pos1))
    end

    self.recreate()

    task.New(self, function()
        for i = 1, 30 do
            self.text_alpha = i * 255 / 30
            task.Wait()
        end
    end)
end

function lib.enhancer_select:frame()
    task.Do(self)
    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        --local lastkey = GetLastKey()
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            PlaySound('cancel00', 0.3)
            self.wait = 114514
            self.save()
            self.quit()
            lib.PopMenuStack()
        end
        if KeyIsPressed('shoot') then
            if self.level == 1 and #lstg.var.enhancer_select >= self.pos1 then
                self.wait = self.t + 5
                PlaySound('aic_enhancer_unequip', 0.5)
                self.fly(0, lstg.var.enhancer_select[self.pos1])
                table.remove(lstg.var.enhancer_select, self.pos1)
                self.save()
            elseif self.level == 2 and #self.cost >= self.pos2 then
                local bool = not ((CheckEnhancer(2) and self.pos2 == 8) or (CheckEnhancer(8) and self.pos2 == 2))
                if CheckEnhancer(self.pos2) then
                    self.wait = self.t + 5
                    PlaySound('aic_enhancer_unequip', 0.5)
                    self.fly(0, self.pos2)
                    table.remove(lstg.var.enhancer_select, self.find(self.pos2))
                    self.save()
                elseif self.cost_calc() < scoredata.enhancer_slot and bool then
                    self.wait = self.t + 5
                    PlaySound('aic_enhancer_equip', 0.5)
                    self.fly(1, self.pos2)
                    table.insert(lstg.var.enhancer_select, self.pos2)
                    self.save()
                end
            end
        end
        if KeyIsPressed('special') then
            if self.cost_calc() > scoredata.enhancer_slot then
                lstg.var.enhancer_overload = true
            else
                --防止重开换插件后仍为过载状态
                lstg.var.enhancer_overload = false
            end
            self.wait = 114514
            self.save()
            if setting.newopening then
                PlaySound('aic_opening_new', 0.5)
            else
                PlaySound('aic_opening', 0.5)
            end
            task.New(self, function()
                lib.BgmFadeOut(aic.misc.GetCurrentBGM(), 59)
            end)
            if practice then
                New(tasker, function()
                    Del(self)
                    if _debug.skip_loading or GetKeyState(KEY.S) then
                        New(mask_fader, 'close')
                        task.Wait(30)
                        New(mask_fader, 'open')
                    else
                        New(aic.misc.loading_scene)
                        task.Wait(270)
                        New(mask_fader, 'open')
                    end
                    stage.group.PracticeStart(stage.groups['SpellCard'])
                end)
            else
                New(tasker, function()
                    Del(self)
                    if _debug.skip_loading or GetKeyState(KEY.S) then
                        New(mask_fader, 'close')
                        task.Wait(30)
                        New(mask_fader, 'open')
                    else
                        New(aic.misc.loading_scene)
                        task.Wait(270)
                        New(mask_fader, 'open')
                    end
                    if stage.groups.SpellCard then
                        stage.group.Start(stage.groups.SpellCard)
                    else
                        --其他难度待添加
                        stage.group.Start(stage.groups.Normal)
                    end
                end)
            end
        end
        --[[
        if GetKeyState(setting.keys.slow) and (GetKeyState(setting.keys.left) or GetKeyState(setting.keys.right)) then
            self.wait = 60
            self.save()
            if GetKeyState(setting.keys.left) then
                if scoredata.enhancer_select_num > 1 then
                    scoredata.enhancer_select_num = scoredata.enhancer_select_num - 1
                else
                    scoredata.enhancer_select_num = 5
                end
            else
                if scoredata.enhancer_select_num < 5 then
                    scoredata.enhancer_select_num = scoredata.enhancer_select_num + 1
                else
                    scoredata.enhancer_select_num = 1
                end
            end
            self.initialize()
            self.recreate()
        end
        ]]
        if KeyIsDown('up') and self.level == 2 then
            if self.pos2 <= self.n[1] then
                self.wait = self.t + 5
                PlaySound('select00', 0.3)
                self.level_pre = 2
                self.level = 1
                self.pos1_aft = 1
                self.move()
                self.cursor_move(self.get_position(self.pos1_aft))
            else
                self.wait = self.t + 5
                PlaySound('select00', 0.3)
                self.pos2_aft = self.pos2 - self.n[self.posn - 1]
                self.level_pre = 2
                self.move()
                self.cursor_move(self.position[self.pos2_aft][1], self.position[self.pos2_aft][2])
            end
        elseif KeyIsDown('down') then
            if self.level == 1 then
                self.wait = self.t + 5
                PlaySound('select00', 0.3)
                self.level_pre = 1
                self.level = 2
                self.pos2_aft = 1
                self.move()
                self.cursor_move(self.position[self.pos2_aft][1], self.position[self.pos2_aft][2])
            elseif self.level == 2 and self.pos2 <= self.l - self.n[#self.n] then
                self.wait = self.t + 5
                PlaySound('select00', 0.3)
                self.pos2_aft = self.pos2 + self.n[self.posn]
                self.level_pre = 2
                self.move()
                self.cursor_move(self.position[self.pos2_aft][1], self.position[self.pos2_aft][2])
            end
        elseif KeyIsDown('left') then
            if self.level == 1 and self.pos1 > 1 then
                self.wait = self.t + 5
                PlaySound('select00', 0.3)
                self.pos1_aft = self.pos1 - 1
                self.level_pre = 1
                self.move()
                local x, y = self.get_position(self.pos1_aft)
                self.cursor_move(x, y)
            elseif self.level == 2 and self.pos2 > 1 then
                self.wait = self.t + 5
                PlaySound('select00', 0.3)
                self.pos2_aft = self.pos2 - 1
                self.level_pre = 2
                self.move()
                self.cursor_move(self.position[self.pos2_aft][1], self.position[self.pos2_aft][2])
            end
        elseif KeyIsDown('right') then
            local maxn
            if self.cost_calc() >= scoredata.enhancer_slot then
                maxn = #lstg.var.enhancer_select
            else
                maxn = #lstg.var.enhancer_select + 1
            end
            if self.level == 1 and self.pos1 < maxn then
                self.wait = self.t + 5
                PlaySound('select00', 0.3)
                self.pos1_aft = self.pos1 + 1
                self.level_pre = 1
                self.move()
                local x, y = self.get_position(self.pos1_aft)
                self.cursor_move(x, y)
            elseif self.level == 2 and self.pos2 < self.l then
                self.wait = self.t + 5
                PlaySound('select00', 0.3)
                self.pos2_aft = self.pos2 + 1
                self.level_pre = 2
                self.move()
                self.cursor_move(self.position[self.pos2_aft][1], self.position[self.pos2_aft][2])
            end
        end
    end
end

function lib.enhancer_select:render()
    SetViewMode('ui')

    --遮罩
    SetImageState('white', '', Color(max(0, self.alpha - 100), 0, 0, 0))
    RenderRect('white', 0, screen.width, 0, screen.height)

    --副标题
    lib.DrawSubTitle(self)

    --文字说明
    local x, y = self.x - screen.width * 0.45, self.y
    if self.cost_calc() > scoredata.enhancer_slot then
        DrawText('aic_menu', '插件过载', x, y + screen.height * 0.25 + 10, 1, Color(self.alpha, 184, 96, 184))
    else
        DrawText('aic_menu', '已装备', x, y + screen.height * 0.25 + 10, 1, Color(self.alpha, 255, 255, 255))
    end
    DrawText('aic_menu', '插件槽', x, y + screen.height * 0.1 - 10, 1, Color(self.alpha, 255, 255, 255))

    --已装备插件区背景
    if self.cost_calc() > scoredata.enhancer_slot then
        SetImageState('Muki_AiC_menu_enhancer_select_bg', '', Color(self.alpha, 184, 96, 184))
        for i = 1, #lstg.var.enhancer_select do
            local x, y = self.get_position(i)
            Render('Muki_AiC_menu_enhancer_select_bg', x, y, 0, 0.25)
        end
    elseif self.cost_calc() == scoredata.enhancer_slot then
        SetImageState('Muki_AiC_menu_enhancer_select_bg', '', Color(self.alpha, 100, 100, 100))
        for i = 1, #lstg.var.enhancer_select do
            local x, y = self.get_position(i)
            Render('Muki_AiC_menu_enhancer_select_bg', x, y, 0, 0.25)
        end
    else
        SetImageState('Muki_AiC_menu_enhancer_select_bg', '', Color(self.alpha, 100, 100, 100))
        for i = 1, #lstg.var.enhancer_select + 1 do
            local x, y = self.get_position(i)
            Render('Muki_AiC_menu_enhancer_select_bg', x, y, 0, 0.25)
        end
    end

    --插件槽
    SetImageState('Muki_AiC_menu_enhancer_select_slot1', '', Color(self.alpha, 255, 255, 255))
    SetImageState('Muki_AiC_menu_enhancer_select_slot2', '', Color(self.alpha, 255, 255, 255))
    SetImageState('Muki_AiC_menu_enhancer_select_slot3', '', Color(self.alpha, 255, 255, 255))
    for i = 1, scoredata.enhancer_slot do
        local _x, _y, rot = unpack(self.slot_position[i])
        Render('Muki_AiC_menu_enhancer_select_slot1', x + _x + 10, y + _y - 10, rot, 0.5)
    end
    for i = 1, self.cost_calc() do
        local _x, _y, rot = unpack(self.slot_position[i])
        Render('Muki_AiC_menu_enhancer_select_slot2', x + _x + 10, y + _y - 10, rot, 0.5)
    end
    if self.cost_calc() > scoredata.enhancer_slot then
        for i = self.cost_calc() - self.cost[lstg.var.enhancer_select[#lstg.var.enhancer_select]] + 1, self.cost_calc() do
            local _x, _y, rot = unpack(self.slot_position[i])
            Render('Muki_AiC_menu_enhancer_select_slot3', x + _x + 10, y + _y - 10, rot, 0.5)
        end
    end

    --插件背景
    for i = 1, self.l do
        SetImageState('Muki_AiC_menu_enhancer_select_bg', '', Color(self.alpha, 100, 100, 100))
        Render('Muki_AiC_menu_enhancer_select_bg', self.position[i][1], self.position[i][2], 0, 0.25)
    end

    --右侧插件说明
    local x, y = x + screen.width * 0.75, y + screen.height * 0.25
    local pos, bool = self.text_pos
    if self.level == 1 then
        bool = self.pos1_aft <= #lstg.var.enhancer_select
    else
        bool = self.text_pos and self.text_pos <= #self.cost and not CheckEnhancer(self.text_pos)
    end
    if bool and self.text[pos] then
        DrawText('aic_menu', self.text[pos][1], x + 30, y,
            1, Color(min(self.alpha, self.text_alpha), 255, 255, 255), nil, 'centerpoint')
        DrawText('aic_menu', self.text[pos][2], x - 50, y - 200,
            0.75, Color(min(self.alpha, self.text_alpha), 255, 255, 255), nil, 'vcenter')
        DrawText('aic_menu', '消耗', x - 20, y - 100,
            0.75, Color(min(self.alpha, self.text_alpha), 255, 255, 255), nil, 'vcenter')
        SetImageState('Muki_AiC_menu_enhancer_select_slot2', '', Color(min(self.alpha, self.text_alpha), 255, 255, 255))
        if self.cost[pos] <= 6 then
            local n = 0
            for i = 1, self.cost[pos] do
                if i % 2 == 1 then
                    n = n + 1
                    if self.cost[pos] > i then
                        Render('Muki_AiC_menu_enhancer_select_slot2', x + n * 30, y - 115, 0, 0.5)
                    else
                        Render('Muki_AiC_menu_enhancer_select_slot2', x + n * 30, y - 100, 0, 0.5)
                    end
                else
                    Render('Muki_AiC_menu_enhancer_select_slot2', x + n * 30, y - 85, 0, 0.5)
                end
            end
        else
            Render('Muki_AiC_menu_enhancer_select_slot2', x + 30, y - 100, 0, 0.5)
            DrawText('aic_menu', 'x ' .. self.cost[pos], x + 50, y - 100,
                0.85, Color(min(self.alpha, self.text_alpha), 255, 255, 255), nil, 'vcenter')
        end
        SetImageState('Muki_AiC_menu_enhancer_select' .. pos, '', Color(min(self.alpha, self.text_alpha), 255, 255, 255))
        local s = 0.75
        if pos >= 12 and pos ~= 16 then s = s * 1.5 end
        Render('Muki_AiC_menu_enhancer_select' .. pos, x + 30, y - 40, 0, s)
    end

    --键位提示
    local key1 = { '卸下插件', '返回上一级菜单', '开始游戏' }
    local key2 = { '携带插件', '返回上一级菜单', '开始游戏' }
    if CheckEnhancer(pos) then
        lib.DrawTips(self, key1, 'up', 'down', 'left', 'right')
    else
        lib.DrawTips(self, key2, 'up', 'down', 'left', 'right')
    end

    SetViewMode('world')
end

function lib.enhancer_select:del()
    PreserveObject(self)
    for i = 1, self.l do
        if self.enhancer[i] and IsValid(self.enhancer[i]) then
            Del(self.enhancer[i])
        end
    end
    if self.cursor and IsValid(self.cursor) then
        Del(self.cursor)
    end
    RawDel(self)
end

---插件图标
lib.enhancer = Class(object)

function lib.enhancer:init(master, x, y, n)
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + 5
    self.x = x
    self.y = y
    self.num = n
    self.master = master
    self.alpha = master.alpha
    self.hscale = 0.75
    self.vscale = 0.75
    if self.num >= 12 and self.num ~= 16 then
        self.hscale = 1.5
        self.vscale = 1.5
    end
    self.bound = false
    self.img = 'Muki_AiC_menu_enhancer_select' .. n
end

function lib.enhancer:frame()
    task.Do(self)
    self.alpha = self.master.alpha
end

function lib.enhancer:render()
    SetViewMode('ui')
    SetImageState(self.img, '', Color(self.alpha, 255, 255, 255))
    object.render(self)
    SetViewMode('world')
end

---插件选择菜单光标
lib.enhancer_cursor = Class(object)

function lib.enhancer_cursor:init(master, x, y)
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + 10
    self.x = x
    self.y = y
    self.master = master
    self.alpha = master.alpha
    self.rot = 45
    self.vscale = 1.25
    self.hscale = 1.25
    self.bound = false
    self.pos = 1
    self.debug = _debug.enhancer_debug
    self.img = 'Muki_AiC_menu_enhancer_select_cursor'
end

function lib.enhancer_cursor:frame()
    task.Do(self)
    self.alpha = self.master.alpha
    SetImageState(self.img, '', Color(self.alpha, 255, 255, 255))
    self.vscale = 1.25 + 0.15 * sin(5 * self.timer)
    self.hscale = 1.25 + 0.15 * sin(5 * self.timer)
end

function lib.enhancer_cursor:render()
    SetViewMode('ui')
    object.render(self)
    if self.debug then
        DrawText('aic_menu', 'level=' .. self.master.level, self.x, self.y + 50)
        DrawText('aic_menu', 'pos1=' .. self.master.pos1, self.x, self.y + 25)
        DrawText('aic_menu', 'pos2=' .. self.master.pos2, self.x, self.y)
        DrawText('aic_menu', 'posn=' .. self.master.posn, self.x, self.y - 25)
        local t = ''
        if #lstg.var.enhancer_select > 0 then
            for i = 1, #lstg.var.enhancer_select do
                if i > 1 then
                    t = t .. ',' .. tostring(lstg.var.enhancer_select[i])
                else
                    t = t .. tostring(lstg.var.enhancer_select[i])
                end
            end
        else
            t = 'nothing...'
        end
        DrawText('aic_menu', 'select=' .. t, self.x, self.y - 50)
    end
    SetViewMode('world')
end
