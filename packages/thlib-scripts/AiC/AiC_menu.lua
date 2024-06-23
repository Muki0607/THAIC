---=====================================
---THAIC Menu v1.03b
---东方梦摇篮菜单 v1.03a
---=====================================

---版本更新记录
---v1.00a
---初始版本
---v1.01a
---添加菜单栈系统与相关函数lib.PushMenuStack、lib.PopMenuStack
---v1.01b
---修复了创建菜单时飞入前位置错误的问题
---v1.01c
---修复了插件选择菜单无法保存的问题
---v1.02a
---增加了'name_regist', 'save_replay', 'replay'菜单
---v1.02b
---修复了插件选择菜单在插槽全部用完时光标仍能移到最后一个已装备插件右侧的问题
---v1.02c
---添加函数lib.ClearMenuStack、lib.InsertMenuStack
---v1.03a
---增加了'library', 'player_data'菜单
---v1.03b
---将所有使用GetLastKey的地方改为了aic.input.CheckLastKey，添加了对手柄的支持（应该）
---我自己的手柄只支持dinput所以没法测试xinput（
---由于是直接拿正则表达式一路刷下去的所以也波及了暂停菜单和原版菜单
---v1.03c
---将方向键的aic.input.CheckLastKey全部改为KeyIsDown，ZXC的全部改为KeyIsPressed
---暂停菜单未改动，因为暂停时不会更新KeyState
---主要问题在于CheckLastKey在面对手柄时极容易出问题

---@class aic.menu @东方梦摇篮菜单
aic.menu = {}
local lib = aic.menu

---仿TH18菜单（其实差别很大）
---本菜单库纯手工制作，没有先定义菜单类，工程量极大
---不过正因如此怎么加新东西都没问题
---此外因为个人码风原因所有菜单都是全局的（直接放在库里），方便调用
-------------------------------------------------------------

---要用到的文本
--local text = aic.l10n.ui

---副标题名称
---@type table
local subtitle = { 'stage_select', 'spell_select', 'replay', 'library', 'music_room', 'option', 'manual',
    'rank_select', 'player_select', 'enhancer_select', 'name_regist', 'save_replay', 'player_data', 'achievement', 'omake' }

---练习模式标志
---@type string
local practice

---菜单栈
---里面放的是各菜单的类而非实例obj
---@type table
lib.menu_stack = {}

---要存储的replay关卡表
---@type table
lib.last_replay = nil

---要存储的replay是否通关的标志
---@type boolean
lib.last_replay_finish = false

------------------------------------------------------------

---菜单飞入飞出，要求单位有t参数（飞入飞出时间）
---@param flyin number @为1时飞入，否则飞出
---@param dir string | "'up'" | "'down'" | "'left'" | "'right'" @移动方向
---@param del boolean @为true时在飞入飞出结束后删除菜单
---@param x number @移动目的x坐标
---@param y number @移动目的y坐标
---@overload fun(flyin:number, x:number, y:number)
function lib:Fly(flyin, dir, del)
    if flyin == 1 then
        task.New(self, function()
            task.Wait(self.t / 4)
            for i = 1, self.t * 3 / 4 do
                self.alpha = i * 255 / (self.t * 3 / 4)
                task.Wait()
            end
        end)
    else
        task.New(self, function()
            for i = 1, self.t do
                self.alpha = 255 - i * 255 / self.t
                task.Wait()
            end
        end)
    end
    if type(dir) == 'string' then
        local x, y
        if dir == 'up' then
            x, y = self.x, self.y + 20
        elseif dir == 'down' then
            x, y = self.x, self.y - 20
        elseif dir == 'left' then
            x, y = self.x - 20, self.y
        elseif dir == 'right' then
            x, y = self.x + 20, self.y
        else
            return
        end
        task.New(self, function()
            task.MoveTo(x, y, self.t, 2)
            if del then
                Del(self)
            end
        end)
    elseif type(dir) == 'number' then
        local x, y = dir, del or self.y
        task.New(self, function()
            task.MoveTo(x, y, self.t, 2)
            if del then
                Del(self)
            end
        end)
    end
end

---BGM渐入
---@param bgm string BGM名
---@param t number 时间
function lib.BgmFadeIn(bgm, t)
    if not bgm then return end
    for i = 1, t do
        SetBGMVolume(bgm, i / t)
        task.Wait()
    end
end

---BGM渐出
---@param bgm string BGM名
---@param t number 时间
function lib.BgmFadeOut(bgm, t)
    if not bgm then return end
    for i = 1, t do
        SetBGMVolume(bgm, 1 - i / t)
        task.Wait()
    end
end

---向菜单栈加入一个菜单，可以追加创建菜单时传入的参数
---可以看成是一种New函数
---@param menu class @菜单（注意是传入类而不是object）
function lib.PushMenuStack(menu, ...)
    --向菜单栈加入一个菜单
    table.insert(lib.menu_stack, menu)
    --上一级菜单飞出
    lib.Fly(lstg.tmpvar.current_menu, 0, 'left', true)
    --新建菜单
    lstg.tmpvar.current_menu = New(menu, ...)
    --菜单飞入
    lstg.tmpvar.current_menu.x = lstg.tmpvar.current_menu.x + 20
    lib.Fly(lstg.tmpvar.current_menu, 1, 'left')
    --存储参数，以便在弹出下一级菜单时重新以同样的参数创建本级菜单
    lstg.tmpvar.current_menu_param = { ... }
    --判定是否需要开启副背景
    if #lib.menu_stack >= 3 then lstg.tmpvar.submenusign = true end
end

---从菜单栈弹出一个菜单
---将会删除当前菜单然后重新创建上一级菜单
function lib.PopMenuStack()
    ---从菜单栈弹出一个菜单
    table.remove(lib.menu_stack)
    --菜单飞出
    lib.Fly(lstg.tmpvar.current_menu, 0, 'right', true)
    --使用预先存储的参数新建上一级菜单
    if lstg.tmpvar.current_menu_param and #lstg.tmpvar.current_menu_param > 0 then
        lstg.tmpvar.current_menu = New(lib.menu_stack[#lib.menu_stack], unpack(lstg.tmpvar.current_menu_param))
    else
        lstg.tmpvar.current_menu = New(lib.menu_stack[#lib.menu_stack])
    end
    --上一级菜单飞入
    lstg.tmpvar.current_menu.x = lstg.tmpvar.current_menu.x - 20
    lib.Fly(lstg.tmpvar.current_menu, 1, 'right')
    --判定是否需要取消副背景
    if #lib.menu_stack == 1 then lstg.tmpvar.submenusign = false end
end

---清空菜单栈
---@param level number @要保留的层数
function lib.ClearMenuStack(level)
    level = level or 1
    while #lib.menu_stack > level do
        table.remove(lib.menu_stack)
    end
end

---向菜单栈中插入菜单
---@param menu class @菜单
---@param pos number @插入的位置
function lib.InsertMenuStack(menu, pos)
    table.insert(lib.menu_stack, pos, menu)
end

---刷新replay
---就是把FetchReplaySlots搬过来了
function lib:FetchReplaySlots()
    local ret = {}
    ext.replay.RefreshReplay()

    for i = 0, ext.replay.GetSlotCount() do
        local text = {}
        local slot = ext.replay.GetSlot(i)
        if slot then
            -- 使用第一关的时间作为录像时间
            local date
            if slot.stages[1] then
                date = os.date("!%Y/%m/%d", slot.stages[1].stageDate + setting.timezone * 3600)
            end
            -- 统计总分数
            local totalScore = 0
            local diff, stage_num = 0, 0
            local tmp
            for i, k in ipairs(slot.stages) do
                totalScore = totalScore + slot.stages[i].score
                diff = string.match(k.stageName, '^.+@(.+)$')
                tmp = string.match(k.stageName, '^(.+)@.+$')
                if string.match(tmp, '%d+') == nil then
                    stage_num = tmp
                else
                    stage_num = 'St' .. string.match(tmp, '%d+')
                end
            end
            if diff == 'Spell Practice' then
                diff = 'SpellCard'
            end
            if tmp == 'Spell Practice' then
                stage_num = 'SC'
            end
            if slot.group_finish == 1 then
                stage_num = 'Clear'
            end
            if date then 
                text = { string.format('No.%02d', i), slot.userName, date, slot.stages[1].stagePlayer, diff, stage_num }
            else
                text = { string.format('No.%02d', i), '--------', '----/--/--', '--------', '--------', '---' }
            end
        else
            text = { string.format('No.%02d', i), '--------', '----/--/--', '--------', '--------', '---' }
        end
        --[[
                    text = string.format(REPLAY_DISPLAY_FORMAT1, i, date, slot.userName, totalScore)
                else
                    text = string.format(REPLAY_DISPLAY_FORMAT2, i, "N/A", 0)
                end
            ]]
        --table.insert(ret, text)
        ret[i] = text
    end
    self.text1 = ret
end

---获取额外rep信息
function lib:GetExtRepInfo()
    if self.slot then
        ---@class plus.ReplayManager.SaveData
        local slot = self.slot
        ---@class plus.ReplayManager.SaveData.StageData
        local st = slot.stages[1]
        if not st then self.text3_kt = nil return end
        local finish = { "是", [0] = "否" }
        local player = { Reimu = "博丽 灵梦", Marisa = "雾雨 魔理沙", Sakuya = "十六夜 咲夜", Muki = "小林 无记", Nenyuki = "千幻 念雪" }
        local difficulty = { "简单", "普通", "噩梦", "地狱" }
        local var = DeSerialize(st.stageExtendInfo)
        self.text3 = {
            --["用户名"] = slot.userName,
            ["是否通关"] = finish[slot.group_finish],
            ["时间"] = aic.sys.GetTime(st.stageDate + setting.timezone * 3600),
            ["总分"] = st.score,
            --["随机数种子"] = st.randomSeed,
            ["自机"] = player[st.stagePlayer] or "未知自机",
            ["游戏版本"] = var.aic_version or "未知版本",
            ["难度选择"] = difficulty[var.difficulty] or "未知难度",
            ["携带插件"] = var.enhancer_select or {}
        }
        self.text3_kt = setvaluetable({ "是否通关", "时间", "总分", "自机",
            "游戏版本", "难度选择", "携带插件" }, self.text3)
    else
        self.text3_kt = nil
    end
end

---绘制键位提示
---@param keys table @键位表，按照{shoot, spell, special}的顺序传入
function lib:DrawTips(keys)
    local text = ''
    local key = aic.input.KeyNameList()
    --移动键
    for _, v in ipairs({ 'up', 'down', 'left', 'right' }) do
        text = text .. key[setting.keys[v]]
    end
    text = text .. '移动'
    --其他操作
    for k, v in ipairs({ 'shoot', 'spell', 'special' }) do
        if keys[k] then
            text = text .. key[setting.keys[v]] .. '键 ' .. keys[k] .. ' '
        end
    end
    DrawText('aic_menu', text,
        screen.width, 10, 0.5, Color(self.alpha, 255, 255, 255), nil, 'right')
end 

---绘制菜单背景
function lib:DrawSubTitle(x, y)
    local x = x or screen.width * 0.5
    local y = y or screen.height * 0.9
    SetImageState('Muki_AiC_subtitle_' .. subtitle[self.num], '', Color(self.alpha, 255, 255, 255))
    Render('Muki_AiC_subtitle_' .. subtitle[self.num], x, y, 0, 0.4)
end

---初始化PlayerData
---@param player_name string @自机名称
function lib.InitPlayerData(player_name)
    local p = player_name
    --history原版已经记过了所以这里就不记了
    --虽然原版history真的写得超烂
    scoredata.player_data[p] = {
        played_num = 0,
        played_time = 0,
        finished_num = { 0, 0, 0, 0 },
        high_score = aic.table.Repeat({
            --机签 分数 时间 是否通关 处理落
            { '--------', 1000000, '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 900000, '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 800000, '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 700000, '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 600000, '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 500000, '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 400000, '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 300000, '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 200000, '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 100000, '----/--/-- --:--:--', 'Stage -', '---%' },
        }, 4)
    }
end

---获取全难度符卡名表
---之后应该把这玩意移到l10n去
function lib.GetSCList()
    return {
        {
            "「ステラの弾幕」", "Default Attack「Starry Shooting」", "爆咒「地面炸弹」", "箭咒「纯白之弓」",
            "引咒「聚能火球」", "防咒「魔法障壁」", "唤咒「使魔召唤」", "仿魔咒「空中回廊」",
            "仿赤咒「炎舞神乐」", "「不顾一切的圣光爆发！」", "结界「八重护盾结界」", "境符「光与影的限间」",
            "「繁星若梦」", "「Reality Reverse　—10%—」", "「Reality Reverse　—25%—」",
            "「Reality Reverse　—50%—」", "「Reality Reverse　—80%—」"
        },
        {
            "「ステラの弾幕」", "Default Attack「Starry Shooting」", "爆咒「地面炸弹」", "箭咒「纯白之弓」",
            "引咒「聚能火球」", "防咒「魔法障壁」", "唤咒「使魔召唤」", "仿魔咒「空中回廊」",
            "仿赤咒「炎舞神乐」", "「不顾一切的圣光爆发！」", "结界「八重护盾结界」", "境符「光与影的限间」",
            "「繁星若梦」", "「Reality Reverse　—10%—」", "「Reality Reverse　—25%—」",
            "「Reality Reverse　—50%—」", "「Reality Reverse　—80%—」"
        },
        {
            "「ステラの弾幕」", "Default Attack「Starry Shooting」", "爆咒「地面炸弹　速」", "散咒「纯白之弓　散」",
            "引咒「聚能火球　改」", "护咒「魔法加护」", "唤咒「使魔召唤　御」", "仿星咒「银河铁道」",
            "仿焱咒「红莲祭仪」", "「拼上性命的圣光爆发！」", "结界「十六重护盾大结界」", "境界「明与灭的樊笼」",
            "「月华流转」", "「Reality Reverse　—10%—」", "「Reality Reverse　—25%—」",
            "「Reality Reverse　—50%—」", "「Reality Reverse　—80%—」"
        },
        {
            "「ステラの弾幕」", "Default Attack「Starry Shooting」", "爆咒「地面炸弹　速」", "散咒「纯白之弓　散」",
            "引咒「聚能火球　改」", "护咒「魔法加护」", "唤咒「使魔召唤　御」", "仿月咒「空明流光」",
            "仿彗咒「流星祈愿」", "「拼上性命的圣光爆发！」", "结界「十六重护盾大结界」", "境界「明与灭的樊笼」",
            "「幻梦的摇篮」", "「Reality Reverse　—10%—」", "「Reality Reverse　—25%—」",
            "「Reality Reverse　—50%—」", "「Reality Reverse　—80%—」"
        }
    }
end

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


------------------------------------------------------------

--单独写一个obj大概是最烂的解决方法了，但是能行
---二级菜单背景
lib.submenu_bg = Class(object)

function lib.submenu_bg:init()
    self.group = GROUP_GHOST
    self.LAYER = LAYER_TOP
    self.alpha = 0
    self.s = 1
end

function lib.submenu_bg:frame()
    if self.s == 1 then
        self.alpha = min(self.alpha + 255 / 30, 255)
    else
        self.alpha = max(self.alpha - 255 / 30, 0)
    end
end

function lib.submenu_bg:render()
    SetViewMode('ui')
    SetImageState('Muki_AiC_menu_bg', '', Color(self.alpha, 255, 255, 255))
    RenderRect('Muki_AiC_menu_bg', 0, screen.width, 0, screen.height)
    SetViewMode('world')
end

------------------------------------------------------------

---难度选择菜单
lib.difficulty_select = Class(object)

function lib.difficulty_select:init()
    self.num = 8 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.pos = scoredata.difficulty_select or 1
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

    lib.DrawTips(self, { '选择难度', '返回上一级菜单' })

    SetViewMode('world')
end

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

---manual（大致与ext的manual相同）
lib.manual = Class(object)

function lib.manual:init(l, t)
    self.num = 7
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.default_x = screen.width * 0.5
    self.default_y = screen.height * 0.5
    self.pos = 1
    self.t = t or 16
    self.l = l or 11
    self.alpha = 255
    self.scale = 0.5
    self.level = 1
    self.wait = 30
    self.bound = false
    self.flyin = function()
        self.locked = true
        --self.wait = self.t
        self.x = self.default_x + screen.width * 0.5
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

function lib.manual:frame()
    task.Do(self)
    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 and not self.locked then
        --local lastkey = GetLastKey()
        if self.level == 1 then
            if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
                PlaySound('cancel00', 0.3)
                self.wait = 114514
                lib.PopMenuStack()
            end
            if KeyIsPressed('shoot') then
                PlaySound('ok00', 0.3)
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
        else
            if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
                PlaySound('cancel00', 0.3)
                self.level = 1
                self.flyout(-1)
                self.flyin()
            end
            if KeyIsDown('up') and self.pos > 1 then
                self.wait = 10
                PlaySound('select00', 0.3)
                self.flyout(-1)
                task.New(self, function()
                    task.Wait(self.t)
                    self.pos = self.pos - 1
                    self.x = self.default_x
                    self.y = self.default_y
                    for i = 1, self.t do
                        self.alpha = i * 255 / self.t
                        task.Wait()
                    end
                    self.locked = false
                end)
            elseif KeyIsDown('down') and self.pos < self.l then
                self.wait = 10
                PlaySound('select00', 0.3)
                self.flyout(1)
                task.New(self, function()
                    task.Wait(self.t)
                    self.pos = self.pos + 1
                    self.x = self.default_x
                    self.y = self.default_y
                    for i = 1, self.t do
                        self.alpha = i * 255 / self.t
                        task.Wait()
                    end
                    self.locked = false
                end)
            end
        end
    end
end

function lib.manual:render()
    SetViewMode('ui')
    --副标题
    lib.DrawSubTitle(self)

    local d, x, y = 30, self.x, self.y
    if self.level == 1 then
        if self.locked then
            for i = 1, self.l do
                if i == self.pos then
                    SetImageState('Muki_AiC_help_menu1', '', Color(self.alpha, 255, 255, 255))
                    Render('Muki_AiC_help_menu' .. i, x, y + (5 - i) * d, 0, self.scale)
                else
                    SetImageState('Muki_AiC_help_menu' .. i, '', Color(self.alpha, 64, 64, 64))
                    Render('Muki_AiC_help_menu' .. i, x, y + (5 - i) * d, 0, self.scale)
                end
            end
        else
            for i = 1, self.l do
                if i == self.pos then
                    local co = 159.5 + 95.5 * cos(5 * self.timer)
                    SetImageState('Muki_AiC_help_menu' .. i, '', Color(self.alpha, co, co, co))
                else
                    SetImageState('Muki_AiC_help_menu' .. i, '', Color(self.alpha, 64, 64, 64))
                end
                Render('Muki_AiC_help_menu' .. i, x, y + (5 - i) * d, 0, self.scale)
            end
        end
    else
        SetImageState('Muki_AiC_help' .. self.pos, '', Color(self.alpha, 255, 255, 255))
        Render('Muki_AiC_help' .. self.pos, x, y, 0, self.scale)
    end

    lib.DrawTips(self, { '选择', '返回上一级菜单' })

    SetViewMode('world')
end


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
    self.wait = 0
    self.timer = 0
    self.key_changing = false
    self.username_changing = false
    self.username = setting.username
    self.bound = false
    self.setting = loadConfigureTable() --因为需要存读文件，为了安全起见这边和插件菜单一样单独先存一份，保存时再存整个表到setting
    self.res = { { 640, 480, true }, { 800, 600 }, { 960, 720, true }, { 1024, 768, true }, { 1280, 960, true }, { 1600, 1200 }, { 1920, 1440, true } }
    self.text1 = {
        { '用户名', setting.username, setting.username },
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
        '更改用户名。\n按Esc键保存更改。',
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
        '更改键盘的按键。\n本游戏目前不支持手柄。',
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
            --[[
            if self.username_changing then
                if aic.input.CheckLastKey('menu') then
                    self.wait = self.t
                    self.username_changing = false
                end
                local lastchar = aic.input.GetLastChar()
                if aic.string.GetCharCount(self.username) < 8 then
                    self.wait = self.t
                    self.username = self.username .. lastchar
                end
                if aic.input.KeyIsPressed(KEY.ESCAPE) then
                    self.wait = self.t
                    self.username_changing = false
                end
                if aic.input.KeyIsPressed(KEY.BACKSPACE) then
                    self.username = aic.string.Sub(self.username, 1, -2)
                end
            --
            else]]
            if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
                --不保存直接退出
                PlaySound('cancel00', 0.5)
                self.flyout('quit') 
            end
            if KeyIsPressed('shoot') then
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
        --设置名称与值
        for i = 1, self.l1 do
            local text = self.text1[i]
            if type(text) == 'string' then
                --键位设定、使用默认设定、保存并退出
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
                        DrawText('main_font_zh2', text[3], x2, y + (self.pos1 / 3 - i) * d,
                            1, color(COLOR_WHITE, self.alpha), nil, 'right')
                        if i ~= 1 then
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
        if not self.locked then
            for i = 1, self.l1 do
                if i == self.pos1 then
                    DrawText('main_font_zh2', '<', x1 - 25 - 5 * sin(3 * self.timer),
                        y + (self.pos1 / 3 - i) * d, 1, color(COLOR_WHITE, self.alpha), nil, 'left')
                    DrawText('main_font_zh2', '>', x2 + 25 + 5 * sin(3 * self.timer),
                        y + (self.pos1 / 3 - i) * d, 1, color(COLOR_WHITE, self.alpha), nil, 'right')
                end
            end
        end
    else
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

    lib.DrawTips(self, { '选择', '返回上一级菜单' })

    SetViewMode('world')
end

---录像播放菜单
---部分参考新版lstg菜单
lib.replay = Class(object)

---@param pos number @初始选择位置
---@param page number @初始页数
function lib.replay:init(pos, page)
    self.num = 3 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.level = 1 --self.state
    self.text1 = {} --self.state1Text
    self.text2 = {} --self.state2Text
    self.text3 = {} --额外rep信息
    ---@type keytable
    self.text3_kt = nil --额外rep信息键表
    self.pos1 = pos or 0 --self.state1Selected
    self.l = 12 --一页中显示的rep数
    self.pos2 = 1 --self.state2Selected
    self.page = page or 1 --当前页数
    self.lpage = 4 --总页数
    self.slot = nil --当前位置rep
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.default_x = screen.width * 0.5
    self.default_y = screen.height * 0.5
    self.bound = false
    self.t = 30
    self.wait = 30
    self.alpha = 0
    self.lname = 8 --REPLAY_USER_NAME_MAX
    self.format1 = "%02d %s %" .. self.lname .. "s %012d"
    self.format2 = "%02d ----/--/-- --:--:-- %" .. self.lname .. "s %012d"

    ---退出函数，改自新版lstg菜单
    ---@param filename string @rep文件名
    ---@param stageName string @关卡名
    function self.quit(filename, stageName) --self.exitCallback
        -- 检查是否存在重放文件名
        if not filename then
            -- 退出重放加载菜单
            lib.PopMenuStack()
        else
            -- 创建新任务，在菜单阶段执行背景音乐平滑淡出
            task.New(self, function()
                lib.BgmFadeOut(aic.misc.GetCurrentBGM(), 59)
            end)

            -- 创建新任务，在菜单阶段等待一段时间后执行以下操作
            New(tasker, function()
                -- 菜单退出函数
                lib.Fly(self, 0, 'down', true)

                -- 创建一个新的蒙版淡出效果
                New(mask_fader, 'close')
                task.Wait(30)

                -- 在控制台打印重放文件名和关卡名
                Print(filename, stageName)

                -- 设置进入重放模式的标志
                stage.IsReplay = true -- 判定进入 rep 播放的 flag，由 OLC 添加

                -- 调用引擎的设置函数，加载指定的重放文件和关卡
                stage.Set(stageName, 'load', filename)
            end)
        end
    end

    ---切换至第二层菜单
    function self:changelevel()
        if self.slot ~= nil then
            self.level = 2
            self.text2 = {}
            self.pos2 = 1

            for _, v in ipairs(self.slot.stages) do
                local stage = string.match(v.stageName, '^(.+)@.+$')
                local score = string.format("%012d", v.score)
                table.insert(self.text2, { stage, score })
            end
        end
    end

    ---渲染主要rep信息
    function self.DrawRepInfo(i, xos, yos, lineh, x, y, text, pos, timer)
        local _color = color
        if i == pos then
            if i == 0 then
                text[i][1] = "Last Replay"
                text[i][2] = ""
            end
            local color = {}
            local k = cos(timer * ui.menu.blink_speed) ^ 2
            for j = 1, 3 do
                color[j] = ui.menu.focused_color1[j] * k + ui.menu.focused_color2[j] * (1 - k)
            end
            --local xos=ui.menu.shake_range*sin(ui.menu.shake_speed*shake)
            SetFontState("replay", "", Color(0xFFFFFF30))
            --RenderTTF(ttfname,text[i],x+xos,x+xos,y-i*ui.menu.sc_pr_line_height+yos,y-i*ui.menu.sc_pr_line_height+yos,Color(alpha*255,unpack(color)),align,"vcenter","noclip")
            for m = 1, 6 do
                --[[RenderText("replay", text[i][m], x + xos[m], y - i * ui.menu.rep_line_height + yos,
                    ui.menu.rep_font_size, "vcenter", "left")]]
                DrawText("main_font_zh2", text[i][m], x + xos[m], y - max(0, (i - self.l * (self.page - 1))) * lineh + yos, 0.8,
                    Color(self.alpha, unpack(color)), nil, "vcenter", "left")
            end
        else
            SetFontState("replay", "", Color(0xFF808080))
            --RenderTTF(ttfname,text[i],x,x,y-i*ui.menu.sc_pr_line_height+yos,y-i*ui.menu.sc_pr_line_height+yos,Color(alpha*255,unpack(ui.menu.unfocused_color)),align,"vcenter","noclip")
            for m = 1, 6 do
                --[[RenderText("replay", text[i][m], x + xos[m], y - i * ui.menu.rep_line_height + yos,
                    ui.menu.rep_font_size, "vcenter", "left")]]
                DrawText("main_font_zh2", text[i][m], x + xos[m], y - max(0, (i - self.l * (self.page - 1))) * lineh + yos, 0.8,
                    _color(COLOR_WHITE, self.alpha), nil, "vcenter", "left")
            end
        end
    end

    lib.FetchReplaySlots(self)
    lib.Fly(self, 1, 'left')
end

function lib.replay:frame()
    task.Do(self)
    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        --local lastkey = GetLastKey()
        self.pos1 = min(max(0, self.pos1), self.l * self.lpage)
        self.slot = ext.replay.GetSlot(self.pos1)
        lib.GetExtRepInfo(self)
        if self.level == 1 then
            if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
                PlaySound('cancel00', 0.5)
                self.wait = 114514
                self.quit()
            elseif KeyIsPressed('shoot') and self.slot then
                self.wait = 114514
                if setting.newopening then
                    PlaySound('aic_opening_new', 0.5)
                else
                    PlaySound('aic_opening', 0.5)
                end
                self.quit(self.slot.path, self.slot.stages[1].stageName)
                --[[
                self.wait = 8
                PlaySound('ok00', 0.3)
                lib.Fly(self, 0, 'down')
                task.New(self, function()
                    task.Wait(self.t)
                    self:changelevel()
                    self.x = self.default_x
                    self.y = self.default_y
                    for _ = 1, self.t do
                        task.Wait()
                        self.alpha = self.alpha + 255 / self.t
                    end
                end)
                ]]
            end
            if KeyIsDown('up') then
                self.wait = 8
                PlaySound('select00', 0.5)
                if self.pos1 > 1 + self.l * (self.page - 1) then
                    self.pos1 = self.pos1 - 1
                else
                    self.pos1 = 0
                end
            elseif KeyIsDown('down') then
                self.wait = 8
                PlaySound('select00', 0.5)
                if self.pos1 < self.l * self.page then
                    if self.pos1 == 0 then
                        self.pos1 = 1 + self.l * (self.page - 1)
                    else
                        self.pos1 = self.pos1 + 1
                    end
                end
            elseif KeyIsDown('left') then
                self.wait = 8
                PlaySound('select00', 0.5)
                if self.page > 1 then
                    self.page = self.page - 1
                    if self.pos1 == 0 then return end
                    self.pos1 = self.pos1 - self.l
                else
                    self.page = self.lpage
                    if self.pos1 == 0 then return end
                    self.pos1 = self.pos1 + self.l * (self.lpage - 1)
                end
            elseif KeyIsDown('right') then
                self.wait = 8
                PlaySound('select00', 0.5)
                if self.page < self.lpage then
                    self.page = self.page + 1
                    if self.pos1 == 0 then return end
                    self.pos1 = self.pos1 + self.l
                else
                    self.page = 1
                    if self.pos1 == 0 then return end
                    self.pos1 = self.pos1 - self.l * (self.lpage - 1)
                end
            end
        else
            if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
                PlaySound('cancel00', 0.5)
                self.wait = self.t * 2
                lib.Fly(self, 0, 'down')
                task.New(self, function()
                    task.Wait(self.t)
                    self.level = 1
                    self.x = self.default_x + 20
                    self.y = self.default_y
                    lib.Fly(self, 1, "left")
                end)
            elseif KeyIsPressed('shoot') and slot ~= nil then
                PlaySound('ok00', 0.3)
                self.wait = 114514
                if setting.newopening then
                    PlaySound('aic_opening_new', 0.5)
                else
                    PlaySound('aic_opening', 0.5)
                end
                self.quit(slot.path, slot.stages[self.pos2].stageName)
            end
            if KeyIsDown('up') then
                self.wait = 8
                PlaySound('select00', 0.5)
                if self.pos2 > 1 then
                    self.pos2 = self.pos2 - 1
                else
                    self.pos = #slot.stages
                end
            elseif KeyIsDown('down') then
                self.wait = 8
                PlaySound('select00', 0.5)
                if self.pos2 < #slot.stages then
                    self.pos2 = self.pos2 + 1
                else
                    self.pos2 = 1
                end
            end
        end
    end
end

function lib.replay:render()
    SetViewMode('ui')
    lib.DrawSubTitle(self)
    local _color = color
    if self.level == 1 then
        local x, y, text, pos, timer = self.x, self.y, sp.copy(self.text1), self.pos1, self.timer
        local lineh = 15
        local xos = { -300, -240, -120, 20, 130, 240 }
        local yos = (self.l + 1) * lineh * 0.5 + 30

        --自动保存位
        self.DrawRepInfo(0, xos, yos, lineh, x, y, text, pos, timer)
        for i = 1 + self.l * (self.page - 1), self.l * self.page do
            self.DrawRepInfo(i, xos, yos, lineh, x, y, text, pos, timer)
        end
        
        --额外信息渲染
        local text3, y = self.text3_kt, y - self.l * lineh * 0.5 + 20
        if text3 then
            local len = text3('len')
            for i = 1, len - 1 do
                DrawText("main_font_zh2", text3('get', i) .. ": " .. text3[i], x + xos[1], y - i * lineh * 1.25, 0.75,
                    _color(COLOR_WHITE, self.alpha))
            end
            DrawText("main_font_zh2", text3('get', len) .. ": ", x + xos[1], y - len * lineh * 1.25 - 10, 0.75,
                _color(COLOR_WHITE, self.alpha))
            for k, v in ipairs(text3[len]) do
                local s = 0.35
                if v >= 12 and v ~= 16 then s = s * 2 end
                Render('Muki_AiC_menu_enhancer_select' .. v, x + xos[1] + 40 + k * 28, y - len * lineh * 1.25 - 10, 0, s)
            end
        end
    else
        local x, y, text, pos, alpha = self.x, self.y, self.text2, self.pos2, self.alpha
        local xos = { -80, 120 }
        local yos = (#text + 1) * ui.menu.sc_pr_line_height * 0.5
        for i = 1, #text do
            if i == pos then
                local color = { { 255, 255, 48 }, { 128, 128, 128 } }
                --local xos=ui.menu.shake_range*sin(ui.menu.shake_speed*shake)
                DrawText('main_font_zh2', text[i][1], x + xos[1], y - i * ui.menu.sc_pr_line_height + yos, 1,
                    Color(alpha, unpack(color[1])), nil, "vcenter", "noclip")
                DrawText('main_font_zh2', text[i][2], x + xos[2], y - i * ui.menu.sc_pr_line_height + yos, 1,
                    Color(alpha, unpack(color[1])), nil, "vcenter", "noclip")
            else
                DrawText('main_font_zh2', text[i][1], x + xos[1], y - i * ui.menu.sc_pr_line_height + yos, 1,
                    Color(alpha, unpack(color[2])), nil, "vcenter", "noclip")
                DrawText('main_font_zh2', text[i][2], x + xos[2], y - i * ui.menu.sc_pr_line_height + yos, 1,
                    Color(alpha, unpack(color[2])), nil, "vcenter", "noclip")
            end
        end
    end
    SetViewMode('world')
end

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
    self.data = nil
    self.username = setting.username or ''
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
            local score = data[self.player_list[self.posX]].high_score[self.posY]
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

            if #self.username == REPLAY_USER_NAME_MAX then
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
        --渲染数据（再次偷懒）
        lib.player_data.render(self, true)
        SetViewMode('ui')
    end

    ---- 绘制键盘
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
    SetViewMode('world')
end

---录像保存菜单
lib.save_replay = Class(object)

---@param stages table @关卡表
---@param finish number @0为未通关，1为通关
---@param name string @机签
function lib.save_replay:init()
    self.num = 12 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.level = 1
    self.text1 = {} --self.state1Text
    self.text3 = {} --额外rep信息
    ---@type keytable
    self.text3_kt = nil --额外rep信息键表
    self.pos1 = 1 --self.state1Selected
    self.l = 16 --一页中显示的rep数
    self.page = 1 --当前页数
    self.lpage = 4 --总页数
    self.slot = nil --当前位置rep
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.default_x = screen.width * 0.5
    self.default_y = screen.height * 0.5
    self.bound = false
    self.t = 30
    self.wait = 30
    self.alpha = 0
    self.lname = 8 --REPLAY_USER_NAME_MAX
    self.format1 = "%02d %s %" .. self.lname .. "s %012d"
    self.format2 = "%02d ----/--/-- --:--:-- %" .. self.lname .. "s %012d"
    self.stages = lib.last_replay
    self.finish = lib.last_replay_finish
    self.name = scoredata.repsaver
    self.posX = 1
    self.posY = 1
    self.info_y = screen.height / 2
    --覆盖rep时警告
    self.warn = false
    self.warn_confirm = false
    
    function self.DrawInfo()
    end
    lib.FetchReplaySlots(self)
    lib.Fly(self, 1, 'left')
end

function lib.save_replay:frame()
    task.Do(self)
    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        --local lastkey = GetLastKey()
        self.slot = ext.replay.GetSlot(self.pos1)
        lib.GetExtRepInfo(self)
        if self.level == 1 then
            if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
                PlaySound('cancel00', 0.5)
                if self.warn then
                    self.warn = false
                    return
                end
                self.wait = 114514
                lib.PopMenuStack()
            elseif KeyIsPressed('shoot') then
                self.wait = 30
                self.level = 2
            end
            if KeyIsDown('up') then
                if self.warn then
                    return
                end
                self.wait = 8
                PlaySound('select00', 0.5)
                if self.pos1 > 1 + self.l * (self.page - 1) then
                    self.pos1 = self.pos1 - 1
                else
                    self.pos1 = self.l * self.page
                end
            elseif KeyIsDown('down') then
                if self.warn then
                    return
                end
                self.wait = 8
                PlaySound('select00', 0.5)
                if self.pos1 < self.l * self.page then
                    self.pos1 = self.pos1 + 1
                else
                    self.pos1 = 1 + self.l * (self.page - 1)
                end
            elseif KeyIsDown('left') then
                self.wait = 8
                PlaySound('select00', 0.5)
                if self.warn then
                    self.warn_confirm = not self.warn_confirm
                    return
                end
                if self.page > 1 then
                    self.page = self.page - 1
                    self.pos1 = self.pos1 - self.l
                else
                    self.page = self.lpage
                    self.pos1 = self.pos1 + self.l * (self.lpage - 1)
                end
            elseif KeyIsDown('right') then
                self.wait = 8
                PlaySound('select00', 0.5)
                if self.warn then
                    self.warn_confirm = not self.warn_confirm
                    return
                end
                if self.page < self.lpage then
                    self.page = self.page + 1
                    self.pos1 = self.pos1 + self.l
                else
                    self.page = 1
                    self.pos1 = self.pos1 - self.l * (self.lpage - 1)
                end
            end
        else
            if self.info_y ~= self.y then
                if abs(self.info_y - self.y) < 20 then
                    self.info_y = self.y
                else
                    self.info_y = self.info_y - 20 * sign(self.info_y - self.y)
                end
            end
            if KeyIsPressed('shoot') then
                self.wait = 114514
                if self.warn then
                    if self.warn_confirm then
                        ext.replay.SaveReplay(self.stages, self.pos1, self.name, self.finish)
                        lib.last_replay = nil
                    else
                        self.warn = false
                    end
                else
                    if self.slot then
                        self.warn = true
                    else
                        ext.replay.SaveReplay(self.stages, self.pos1, self.name, self.finish)
                        lib.last_replay = nil
                    end
                end
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
            elseif KeyIsPressed('shoot') then
                self.wait = self.t
                if self.posX == 12 and self.posY == 6 then
                    --由OLC添加，保存rep时菜单用来记录名称的参数
                    scoredata.repsaver = self.username
                    -- 跳转至保存录像菜单
                    lib.PushMenuStack(lib.save_replay, self.stages, self.finish, self.username)
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
            elseif KeyIsPressed('spell') then
                if #self.username == 0 then
                    self.wait = 114514
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
end

function lib.save_replay:render()
    ---超级偷懒的写法（
    if self.level == 1 then
        lib.replay.render(self)
    else
        lib.name_regist.render(self, true)
        self:DrawInfo()
    end
    SetViewMode('ui')
    --覆盖rep时警告
    if self.warn then
        local co = { [true] = {}, [false] = { 255, 255, 255 } }
        local k = cos(self.timer * ui.menu.blink_speed) ^ 2
        for i = 1, 3 do
            co[true][i] = ui.menu.focused_color1[i] * k + ui.menu.focused_color2[i] * (1 - k)
        end
        SetImageState("white", '', color(COLOR_BLACK, 150))
        RenderRect("white", screen.width / 4, screen.width * 3 / 4,
            screen.height / 4, screen.height * 3 / 4)
        DrawText("main_font_zh2", "该位置已经有回放存在。\n覆盖吗？",
            screen.width / 2, screen.height * 5 / 8, 2, nil, nil, "centerpoint")
        DrawText("main_font_zh2", "是",
            screen.width / 4, screen.height * 3 / 8, 2, Color(255, unpack(co[self.warn_confirm])), nil, "centerpoint")
        DrawText("main_font_zh2", "否",
            screen.width * 3 / 4, screen.height * 3 / 8, 2, Color(255, unpack(co[not self.warn_confirm])), nil, "centerpoint")
    end
    SetViewMode('world')
end

---library，直接抄了title
lib.library = Class(object)

function lib.library:init(pos, l)
    self.num = 4 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.pos = pos or 1
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.default_x = screen.width * 0.75
    self.default_y = screen.height * 0.25 + 30
    self.bound = false
    self.t = 30
    self.wait = 30
    self.alpha = 0
    self.text1 = { "查看得分排行", "查看符卡历史", "已达成的成就", "查看Omake文档" }
    self.text2 = { "Score Ranking", "Spellcard Record", "Trophy", "Omake" }
    self.jump =
    {
        { lib.player_data },
        {
            lib.player_data,
            17 --#lib.GetSCList()[1]
        },
        { lib.achievement },
        { lib.omake },
        quit = lib.PopMenuStack
    }
    self.l = l or #self.jump
    self.invalid_menu = { 2, 3, 4 }
    self.parrot = {}
    for _, i in ipairs(self.invalid_menu) do
        table.insert(self.parrot,
            New(aic.misc.party_parrot, self.x - 90, self.y + (2.5 - i) * 75 - 25, 0.1, 25, 5, true, true))
    end
    lib.Fly(self, 1, 'left')
end

function lib.library:frame()
    task.Do(self)

    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        --local lastkey = GetLastKey()
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            self.wait = 114514
            PlaySound('cancel00', 0.3)
            for _, p in ipairs(self.parrot) do
                if IsValid(p) then Del(p) end
            end
            self.jump.quit()
        end
        if KeyIsPressed('shoot') then
            if not aic.table.Search(self.invalid_menu, self.pos) then
                self.wait = 114514
                PlaySound('ok00', 0.3)
                lib.Fly(self, 0, 'left')
            end
            if aic.table.Search(self.invalid_menu, self.pos) then
                PlaySound('invalid', 0.5)
                return
            end
            for _, p in ipairs(self.parrot) do
                if IsValid(p) then Del(p) end
            end
            lib.PushMenuStack(self.jump[self.pos][1], self.jump[self.pos][2])
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

function lib.library:render()
    SetViewMode('ui')
    lib.DrawSubTitle(self)
    local d, x, y, text1, text2 = 75, self.x, self.y - 25, self.text1, self.text2
    for i = 1, self.l do
        if i == self.pos then
            DrawText("main_font_zh2", text1[i], x, y + (2.5 - i) * d, 1.25,
                color(COLOR_BLACK, self.alpha), Color(self.alpha, 32, 208, 255), 'centerpoint')
            DrawText("main_font_zh2", text2[i], x, y + (2.5 - i) * d - 20, 1,
                color(COLOR_BLACK, self.alpha), Color(self.alpha, 32, 208, 255), 'centerpoint')
        else
            DrawText("main_font_zh2", text1[i], x, y + (2.5 - i) * d, 1.25,
                color(COLOR_BLACK, self.alpha), color(COLOR_WHITE, self.alpha), 'centerpoint')
            DrawText("main_font_zh2", text2[i], x, y + (2.5 - i) * d - 20, 1,
                color(COLOR_BLACK, self.alpha), color(COLOR_WHITE, self.alpha), 'centerpoint')
        end
    end
    SetViewMode('world')
end

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
    self.sc_list = lib.GetSCList()
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
function lib.player_data:render(IsNameRegist)
    SetViewMode('ui')
    local x, y = self.x, self.y - 70
    local lineh = 20
    local yos = (self.l + 1) * lineh * 0.5
    local co1, co2 = { 247, 225, 158 }, { 166, 129, 193 }
    local data, playdata = self.data, self.playdata
    if IsNameRegist then
        y = y + 100
    else
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
    end
    if data then
        if self.lsc then
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
        else
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

lib.achievement = Class(object)

lib.omake = Class(object)

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
    if not self.init_sign then self.Initialize()
    end
    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        --local lastkey = GetLastKey()
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            self.wait = 114514
            PlaySound('cancel00', 0.3)
            lib.PopMenuStack()
        end
        if KeyIsPressed('shoot') then
            self.wait = self.t
            if self.pos ~= self.textpos then self.warn1 = false end
            self.textpos = self.pos
            if self.CheckRecord(self.pos) or self.warn1 then
                self.warn1 = false
                if self.pos == 27 then
                    if self.warn2 then
                        self.warn2 = false
                        task.New(self, function()
                            TryExcept(function()
                                    _play_music('aic_bgm' .. self.pos, nil, false)
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
                        TryExcept(function()
                                _play_music('aic_bgm' .. self.pos, nil, false)
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
        end
        if KeyIsDown('up') then
            self.wait = self.t
            PlaySound('select00', 0.3)
            if self.pos > 1 then
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
        end
    end
end

function lib.music_room:render()
    SetViewMode('ui')
    lib.DrawSubTitle(self)
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
            DrawText("main_font_en", '    ♪ ', x - 50, y - 180, 1, color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
            DrawText("main_font_zh2", '            ' .. text1[self.textpos] .. '\n' .. self.text2[self.textpos] .. text,
                x - 50, y - 180, 1, color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
        else
            DrawText("main_font_zh2", '            ' .. '\n' .. self.text4,
                x + 50, y - 180, 1, color(COLOR_DEEP_PURPLE, alpha), color(COLOR_BLACK, alpha))
        end
    else
        if self.CheckRecord(self.textpos) or not self.warn1 then
            DrawText("main_font_en", '    ♪ ', x - 50, y - 180, 1, color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
            DrawText("main_font_zh2", '            ' .. text1[self.textpos] .. '\n' .. self.text2[self.textpos],
                x - 50, y - 180, 1, color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
        else
            DrawText("main_font_zh2", '            ' .. '\n' .. self.text3,
                x + 50, y - 180, 1, color(COLOR_RED, alpha), color(COLOR_BLACK, alpha))
        end
    end
    if self.debug then
        local str = tostring
        DrawText("main_font_zh2", 'warn1=' .. str(self.warn1) .. '\nwarn2=' .. str(self.warn2)
            .. '\npos=' .. self.pos .. '\ntextpos=' .. self.textpos, 500, 300, 1,
            color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
    end
    SetViewMode('world')
end


----------------------------------------
---资源

--字体
LoadTTF('aic_menu', 'THlib/UI/menu/Muki_AiC_menu_font.ttf', 35)

--标题菜单
for _, m in ipairs({ { 'title', 9 }, { 'difficulty_select', 4 }, { 'player_select', 8 }, { 'enhancer_select', 16 } }) do
    for i = 1, m[2] do
        LoadImageFromFile('Muki_AiC_menu_' .. m[1] .. i,
            'THlib/UI/menu/' .. m[1] .. '/Muki_AiC_menu_' .. m[1] .. i .. '.png')
    end
end
--自机选择菜单文字
for i = 1, 8 do
    LoadImageFromFile('Muki_AiC_menu_player_select_text' .. i,
        'THlib/UI/menu/player_select/Muki_AiC_menu_player_select_text' .. i .. '.png')
end
--插件相关
LoadImageGroupFromFile('Muki_AiC_menu_enhancer_select_slot',
    'THlib/UI/menu/enhancer_select/Muki_AiC_menu_enhancer_select_slot.png', true, 3, 1)
LoadImageFromFile('Muki_AiC_menu_enhancer_select_bg',
    'THlib/UI/menu/enhancer_select/Muki_AiC_menu_enhancer_select_bg.png')
LoadImageFromFile('Muki_AiC_menu_enhancer_select_cursor',
    'THlib/UI/menu/enhancer_select/Muki_AiC_menu_enhancer_select_cursor.png')
--manual
for i = 1, 12 do
    LoadImageFromFile('Muki_AiC_help' .. i, 'THlib/UI/pause_menu/help/Muki_AiC_help' .. i .. '.png')
    LoadImageFromFile('Muki_AiC_help_menu' .. i, 'THlib/UI/pause_menu/help/Muki_AiC_help_menu' .. i .. '.png')
end
SetImageCenter('Muki_AiC_help_menu11', 148, 25)
SetImageCenter('Muki_AiC_help_menu12', 148, 25)
--副标题
for _, t in ipairs(subtitle) do
    LoadImageFromFile('Muki_AiC_subtitle_' .. t, 'THlib/UI/menu/subtitle/Muki_AiC_subtitle_' .. t .. '.png')
end
--背景
LoadImageFromFile('Muki_AiC_menu_bg', 'THlib/UI/menu/bg/Muki_AiC_menu_bg.png')
LoadImageFromFile('Muki_AiC_menu_bg_Noel', 'THlib/UI/menu/bg/Muki_AiC_menu_bg_Noel.png')
LoadImageFromFile('Muki_AiC_menu_bg_logo', 'THlib/UI/menu/bg/Muki_AiC_menu_bg_logo.png')
