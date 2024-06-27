---=====================================
---THAIC Menu v1.04a
---东方梦摇篮菜单 v1.04a
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
---v1.04a
---完善了option的用户名修改功能
---增加了'music_room'菜单
---为精简主文件将所有菜单分别移至单独的文件中

---@class aic.menu @东方梦摇篮菜单
aic.menu = {}
local lib = aic.menu

---仿TH18菜单（其实差别很大）
---本菜单库纯手工制作，没有先定义菜单类，工程量极大
---不过正因如此怎么加新东西都没问题
---此外因为个人码风原因所有菜单都是全局的（直接放在库里），方便调用
-------------------------------------------------------------

---副标题名称
local subtitle = { 'stage_select', 'spell_select', 'replay', 'library', 'music_room', 'option', 'manual',
    'rank_select', 'player_select', 'enhancer_select', 'name_regist', 'save_replay', 'player_data', 'achievement', 'omake' }

---菜单名称
local menu = { 'title', 'practice', 'spell_practice', 'replay', 'library', 'music_room', 'option', 'manual',
    'difficulty_select', 'player_select', 'enhancer_select', 'name_regist', 'save_replay', 'player_data', 'achievement', 'omake' }

---练习模式标志
---@type string
local practice

---菜单栈
---里面放的是各菜单的类而非实例obj
lib.menu_stack = {}

---要存储的replay关卡表
---@type table
lib.last_replay = nil

---要存储的replay是否通关的标志
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

--[[
---保存上一局游戏数据
---@param score table @分数数据表
function lib.SavePlayerData(score)
    local player_list = { "reimu_player", "marisa_player", "sakuya_player", "muki_player", "nenyuki_player" }
    local player, diff = player_list[aic.sys.GetPlayer()], aic.sys.GetDiff()
    local hscore = scoredata.player_data[player].high_score[diff]
    --计算本次分数超过了几个记录
    local n = 0
    for i = 1, 10 do
        --Print(i, score[2], hscore[i][2])
        if score[2] > hscore[i][2] then
            n = n + 1
        end
    end
    --整理高分榜
    --我知道你想说table.sort，但那玩意在这里不起作用（因为元表？）
    if n > 0 then
        for i = 10, 10 - n + 1, -1 do
            hscore[i + 1] = hscore[i]
        end
        hscore[10 - n + 1] = score
    end
end
--]]

---保存上一局游戏数据
---@param score table @分数数据表
function lib.SavePlayerData(score)
    local player_list = { "reimu_player", "marisa_player", "sakuya_player", "muki_player", "nenyuki_player" }
    local player, diff = player_list[aic.sys.GetDiff()], aic.sys.GetDiff()
    local hscore = scoredata.player_data[player].high_score[diff]
    local function compare(t1, t2)
        return t1[2] > t2[2]
    end
    --以本次得分是否高过高分榜最后一名决定是否更新
    if compare(score, hscore[10]) then
        hscore[10] = score
    else
        return
    end
    --以分数整理高分榜
    table.sort(hscore, compare)
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

for _, m in ipairs(menu) do
    DoFile('AiC/menu/' .. m .. '.lua')
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
