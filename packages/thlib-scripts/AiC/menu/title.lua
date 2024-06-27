local lib = aic.menu

------------------------------------------------------------

---主菜单
lib.title = Class(object)

---@param pos number @初始选择位置
---@param l number @菜单长度
function lib.title:init(pos, l)
    --写入当前版本号
    lstg.var.aic_version = aic.version
    --初始化PlayerData
    if not scoredata.player_data then
        scoredata.player_data = {}
    end
    for _, p in ipairs({ 'reimu_player', 'marisa_player', 'sakuya_player', 'muki_player', 'nenyuki_player' }) do
        if not scoredata.player_data[p] then
            lib.InitPlayerData(p)
        end
    end
    --初始化MusicRecord
    if not scoredata.music_record then
        scoredata.music_record = {}
    end
    self.num = 0 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.pos = pos or 1
    self.x = screen.width * 0.75
    self.y = screen.height * 0.25 + 30
    self.default_x = screen.width * 0.75
    self.default_y = screen.height * 0.25 + 30
    self.bound = false
    self.t = 30
    self.wait = 30
    self.alpha = 0
    self.scale = 0.45
    self.jump =
    {
        { lib.difficulty_select },
        {
            lib.difficulty_select,
            function() practice = 'stage' end,
        },
        {
            lib.spell_practice,
            function() practice = 'spell' end
        },
        { lib.replay },
        { lib.library },
        { lib.music_room },
        { lib.option },
        { lib.manual },
        quit = function()
            lib.Fly(self)
            task.New(self, function()
                task.Wait(self.t)
                stage.QuitGame()
            end)
        end
    }
    self.l = l or #self.jump + 1
    lib.Fly(self, 1, 'left')
    lstg.tmpvar.current_menu = self

    if #lib.menu_stack == 0 then table.insert(lib.menu_stack, lib.title) end
    lib.ClearMenuStack() --这里必须清空栈，否则从关卡中返回时虽然回到主菜单，但菜单栈中仍有东西

    if lstg.tmpvar.submenu_bg and IsValid(lstg.tmpvar.submenu_bg) then
        lstg.tmpvar.submenu_bg.s = -1
    end

    --有rep时先存rep
    if lib.last_replay then
        lib.PushMenuStack(lib.name_regist)
    end
    self.invalid_menu = { 2, 3 }
    self.parrot = {}
    local dx = { 0, -98, -130, -85, -85, -120 }
    for _, i in ipairs(self.invalid_menu) do
        table.insert(self.parrot,
            New(aic.misc.party_parrot, self.x + dx[i] + 10, self.y + (5 - i) * 30, 0.07, 25, 5, true, true))
    end
    if aic.misc.GetCurrentBGM() ~= 'aic_bgm1' and aic.misc.GetCurrentBGM() ~= 'aic_bgm30' then
        if setting.newbgm then
            _play_music('aic_bgm30', nil, false)
        else
            _play_music('aic_bgm1', nil, false)
        end
    end
end

function lib.title:frame()
    task.Do(self)

    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        local lastkey = GetLastKey()
        --高速开始
        if lastkey == KEY.S then
            if not scoredata.player_select then return end
            New(tasker, function()
                if setting.newopening then
                    PlaySound('aic_opening_new', 0.5)
                else
                    PlaySound('aic_opening', 0.5)
                end
                task.New(self, function()
                    lib.BgmFadeOut(aic.misc.GetCurrentBGM(), 59)
                end)
                lstg.var.player_name = player_list[scoredata.player_select][2]
                lstg.var.rep_player = player_list[scoredata.player_select][3]
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
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            PlaySound('cancel00', 0.3)
            if self.pos == self.l then
                self.wait = 114514
                self.jump.quit()
            else
                self.pos = self.l
            end
        end
        if KeyIsPressed('shoot') then
            if not aic.table.Search(self.invalid_menu, self.pos) then
                self.wait = 114514
                PlaySound('ok00', 0.3)
                lib.Fly(self, 0, 'left')
            end
            if self.pos == self.l then
                self.jump.quit()
                return
            elseif aic.table.Search(self.invalid_menu, self.pos) then
                PlaySound('invalid', 0.5)
                return
            end
            for _, p in ipairs(self.parrot) do
                if IsValid(p) then Del(p) end
            end
            if self.jump[self.pos][2] then self.jump[self.pos][2]() end
            lstg.tmpvar.submenu_bg = New(lib.submenu_bg)
            self.param = { self.pos }
            lib.PushMenuStack(self.jump[self.pos][1])
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

function lib.title:render()
    SetViewMode('ui')
    SetImageState('Muki_AiC_menu_bg_Noel', '', Color(self.alpha, 255, 255, 255))
    SetImageState('Muki_AiC_menu_bg_logo', '', Color(self.alpha, 255, 255, 255))
    Render('Muki_AiC_menu_bg_Noel', self.x - screen.width * 0.25, self.y + screen.height * 0.25 - 30, 0, 0.5)
    Render('Muki_AiC_menu_bg_logo', self.x - screen.width * 0.2, self.y + screen.height * 0.25 + 15, 0, 0.4)
    local d, x, y = 30, self.x, self.y
    for i = 1, self.l do
        if i == self.pos then
            SetImageState('Muki_AiC_menu_title' .. i, '', Color(self.alpha, 32, 208, 255))
        else
            SetImageState('Muki_AiC_menu_title' .. i, '', Color(self.alpha, 255, 255, 255))
        end
        Render('Muki_AiC_menu_title' .. i, x, y + (5 - i) * d, 0, self.scale)
    end
    DrawText('main_font_zh2', "v" .. aic.version, 5, 15, 0.75,
        color(COLOR_WHITE, self.alpha), nil, "left")
    SetViewMode('world')
end

function lib.title:del()
    PreserveObject(self)
    for _, p in ipairs(self.parrot) do
        if IsValid(p) then Del(p) end
    end
    RawDel(self)
end
