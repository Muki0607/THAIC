---THAIC Arranged
--title所使用的菜单类的定义


---@class menu.simpleMenu:menu.menuObject
menu.simpleMenu = plus.Class(menu.menuObject)

function menu.simpleMenu:init(name, title)
    menu.menuObject.init(self)
    self.alpha = 1
    self.x = screen.width * 0.5 - screen.width
    self.y = screen.height * 0.5
    self.title = title
    self.name = name
    self.pos = 1
    self.pos_pre = 1
    self.pos_changed = 0
    --
    self:setParam(0, 0, ui.menu.line_height, "center", "menu")
end

function menu.simpleMenu:frame()
    self.timer = self.timer + 1
    task.Do(self)
    if not self:isActive() then
        return
    end
    if KeyIsPressed('up') then
        self.pos = self.pos - 1
        PlaySound('select00', 0.3)
    end
    if KeyIsPressed('down') then
        self.pos = self.pos + 1
        PlaySound('select00', 0.3)
    end
    self.pos = (self.pos - 1 + self.itemCount) % self.itemCount + 1
    if KeyIsPressed('shoot') and self.item[self.pos].func then
        self.item[self.pos]:func()
        PlaySound('ok00', 0.3)
    elseif KeyIsPressed('spell') and self.exitFunc then
        self:exitFunc()
        PlaySound('cancel00', 0.3)
    end
    if self.pos_changed > 0 then
        self.pos_changed = self.pos_changed - 1
    end
    if self.pos_pre ~= self.pos then
        self.pos_changed = ui.menu.shake_time
    end
    self.pos_pre = self.pos
end

---comment
---@param name string 菜单名称
---@param title string 菜单标题
---@return menu.simpleMenu
function menu.simpleMenu.create(name, title)
    local m = menu.simpleMenu(name, title)
    menu.addMenu(name, m)
    return m
end

function menu.simpleMenu:render()
    self:drawMenu()
end

function menu.simpleMenu:drawMenu()
    local yos
    if self.title == "" then
        yos = (self.itemCount + 1) * ui.menu.line_height * 0.5
    else
        yos = (self.itemCount - 1) * ui.menu.line_height * 0.5
        SetFontState(self.font, "", Color(self.alpha * 255, unpack(ui.menu.title_color)))
        RenderText(self.font, self.title, self.x + self.offx, self.y + self.offy + yos + ui.menu.line_height,
            ui.menu.font_size, self.align, "vcenter")
    end
    for i = 1, self.itemCount do
        if i == self.pos then
            local color = {}
            local k = cos(self.timer * ui.menu.blink_speed) ^ 2
            for j = 1, 3 do
                color[j] = ui.menu.focused_color1[j] * k + ui.menu.focused_color2[j] * (1 - k)
            end

            local xos = ui.menu.shake_range * sin(ui.menu.shake_speed * self.pos_changed)

            SetFontState(self.font, "", Color(self.alpha * 255, unpack(color)))
            RenderText(self.font, self.item[i].name, self.x + self.offx + xos,
                self.y + self.offy - i * ui.menu.line_height + yos, ui.menu.font_size, self.align, "vcenter")
            --	RenderTTF("menuttf",text[i],x+xos+2,x+xos+2,y-i*ui.menu.line_height+yos,y-i*ui.menu.line_height+yos,Color(alpha*255,0,0,0),"centerpoint")
            --	RenderTTF("menuttf",text[i],x+xos,x+xos,y-i*ui.menu.line_height+yos,y-i*ui.menu.line_height+yos,Color(alpha*255,unpack(color)),"centerpoint")
        else
            SetFontState(self.font, "", Color(self.alpha * 255, unpack(ui.menu.unfocused_color)))
            --Print(self.item[i].name)
            RenderText(self.font, self.item[i].name, self.x + self.offx,
                self.y + self.offy - i * self.dy + yos, ui.menu.font_size, self.align, "vcenter")
            --	RenderTTF("menuttf",text[i],x+2,x+2,y-i*ui.menu.line_height+yos,y-i*ui.menu.line_height+yos,Color(alpha*255,0,0,0),"centerpoint")
            --	RenderTTF("menuttf",text[i],x,x,y-i*ui.menu.line_height+yos,y-i*ui.menu.line_height+yos,Color(alpha*255,unpack(ui.menu.unfocused_color)),"centerpoint")
        end
    end
end

---设置菜单参数
---@param offsetX number x偏移
---@param offsetY number y偏移
---@param deltaY number y增量
---@param align string 对齐模式
---@param font string 字体
function menu.simpleMenu:setParam(offsetX, offsetY, deltaY, align, font)
    self.align = align
    self.offx = offsetX
    self.offy = offsetY
    self.dy = deltaY
    self.font = font
end

---@class menu.ScprMenu:menu.menuObject
menu.ScprMenu = plus.Class(menu.menuObject)

function menu.ScprMenu:init(exit_func)
    menu.menuObject.init(self)
    self.alpha = 1
    self.exit_func = exit_func
    self.name = "scpr"
    self.x = screen.width * 0.5 + screen.width
    self.y = screen.height * 0.5
    self.npage = max(int((#_sc_table - 1) / ui.menu.sc_pr_line_per_page) + 1, 1)
    self.page = 0
    self.pos = 1
    self.pos_changed = 0
end

function menu.ScprMenu:frame()
    self.timer = self.timer + 1
    task.Do(self)
    if not self:isActive() then
        return
    end
    if self.pos_changed > 0 then
        self.pos_changed = self.pos_changed - 1
    end
    if GetLastKey() == setting.keys.up then
        self.pos = self.pos - 1
        PlaySound('select00', 0.3)
        self.pos_changed = ui.menu.shake_time
    end
    if GetLastKey() == setting.keys.down then
        self.pos = self.pos + 1
        PlaySound('select00', 0.3)
        self.pos_changed = ui.menu.shake_time
    end
    self.pos = (self.pos + ui.menu.sc_pr_line_per_page - 1) % ui.menu.sc_pr_line_per_page + 1
    if GetLastKey() == setting.keys.left then
        self.page = self.page - 1
        self.pos_changed = ui.menu.shake_time
        PlaySound('select00', 0.3)
    end
    if GetLastKey() == setting.keys.right then
        self.page = self.page + 1
        self.pos_changed = ui.menu.shake_time
        PlaySound('select00', 0.3)
    end
    self.page = (self.page + self.npage) % self.npage
    if KeyIsPressed 'shoot' then
        local index = self.pos + self.page * ui.menu.sc_pr_line_per_page
        if _sc_table[index] then
            if self.exit_func then
                self.exit_func(index)
            end
            PlaySound('ok00', 0.3)
        else
            PlaySound('invalid', 0.5)
        end
    elseif KeyIsPressed 'spell' then
        PlaySound('cancel00', 0.3)
        if self.exit_func then
            self.exit_func(nil)
        end
    end
end

function menu.ScprMenu:render()
    --[[
        ui.DrawMenu('View Replay',self.text,self.pos,self.x,self.y+ui.menu.line_height,self.alpha,self.timer,self.pos_changed)
        SetFontState('menu','',Color(self.alpha*255,unpack(ui.menu.title_color)))
        RenderText('menu',string.format('<-  page %d/%d  ->',self.page+1,self.npage),self.x,self.y-5.5*ui.menu.line_height,ui.menu.font_size,'centerpoint')
        --]]
    SetViewMode('ui')
    SetImageState('white', '', Color(0xC0000000) * self.alpha)
    RenderRect('white', self.x - ui.menu.sc_pr_width * 0.5 - ui.menu.sc_pr_margin,
        self.x + ui.menu.sc_pr_width * 0.5 + ui.menu.sc_pr_margin,
        self.y - ui.menu.sc_pr_line_height * (ui.menu.sc_pr_line_per_page + 2) * 0.5 - ui.menu.sc_pr_margin,
        self.y + ui.menu.sc_pr_line_height * (ui.menu.sc_pr_line_per_page + 2) * 0.5 + ui.menu.sc_pr_margin)
    local text1 = {}
    local text2 = {}
    local offset = self.page * ui.menu.sc_pr_line_per_page
    for i = 1, ui.menu.sc_pr_line_per_page do
        if _sc_table[i + offset] then
            text1[i] = _editor_class[_sc_table[i + offset][1]].name
            text2[i] = _sc_table[i + offset][2]
        else
            text1[i] = '---'
            text2[i] = '---'
        end
    end
    ui.DrawMenuTTF('sc_pr', '', text1, self.pos, self.x - ui.menu.sc_pr_width * 0.5, self.y, self.alpha, self.timer,
        self.pos_changed, 'left')
    ui.DrawMenuTTF('sc_pr', '', text2, self.pos, self.x + ui.menu.sc_pr_width * 0.5, self.y, self.alpha, self.timer,
        self.pos_changed, 'right')
    RenderTTF('sc_pr', 'Spell Practice', self.x, self.x,
        self.y + (ui.menu.sc_pr_line_per_page + 1) * ui.menu.sc_pr_line_height * 0.5,
        self.y + (ui.menu.sc_pr_line_per_page + 1) * ui.menu.sc_pr_line_height * 0.5,
        Color(self.alpha * 255, unpack(ui.menu.title_color)), 'centerpoint')
    RenderTTF('sc_pr', string.format('<-  page %d/%d  ->', self.page + 1, self.npage), self.x, self.x,
        self.y - (ui.menu.sc_pr_line_per_page + 1) * ui.menu.sc_pr_line_height * 0.5,
        self.y - (ui.menu.sc_pr_line_per_page + 1) * ui.menu.sc_pr_line_height * 0.5,
        Color(self.alpha * 255, unpack(ui.menu.title_color)), 'centerpoint')
end

---@param exit_func fun(index:integer) 退出时的回调函数
---@return menu.ScprMenu
function menu.ScprMenu.create(exit_func)
    local m = menu.ScprMenu(exit_func)
    menu.addMenu("scpr", m)
    return m
end

---------

LoadTTF("replayfnt", 'assets/font/SourceHanSansCN-Bold.otf', 30)
LoadImageFromFile('replay_title', 'THlib/UI/replay_title.png')
LoadImageFromFile('save_rep_title', 'THlib/UI/save_rep_title.png')

local REPLAY_USER_NAME_MAX = 8

function FetchReplaySlots()
    local ret = {}
    ext.replay.RefreshReplay()

    for i = 1, ext.replay.GetSlotCount() do
        local text = {}
        local slot = ext.replay.GetSlot(i)
        if slot then
            -- 使用第一关的时间作为录像时间
            local date = os.date("!%Y/%m/%d", slot.stages[1].stageDate + setting.timezone * 3600)

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
                stage_num = 'All'
            end
            text = { string.format('No.%02d', i), slot.userName, date, slot.stages[1].stagePlayer, diff, stage_num }
        else
            text = { string.format('No.%02d', i), '--------', '----/--/--', '--------', '--------', '---' }
        end
        --[[
                    text = string.format(REPLAY_DISPLAY_FORMAT1, i, date, slot.userName, totalScore)
                else
                    text = string.format(REPLAY_DISPLAY_FORMAT2, i, "N/A", 0)
                end
            ]]
        table.insert(ret, text)
    end
    return ret
end

---@class menu.replayLoaderMenu:menu.menuObject
menu.replayLoaderMenu = plus.Class(menu.menuObject)

---@param exitCallback fun(filename:string, stageName:string)
---@return menu.replayLoaderMenu
function menu.replayLoaderMenu.create(exitCallback)
    local m = menu.replayLoaderMenu(exitCallback)
    menu.addMenu("replayLoader", m)
    return m
end

function menu.replayLoaderMenu:init(exitCallback)
    menu.menuObject.init(self)
    self.x = screen.width * 0.5 + screen.width
    self.y = screen.height * 0.5

    self.exitCallback = exitCallback

    self.shakeValue = 0

    self.state = 0
    self.state1Selected = 1
    self.state1Text = {}
    self.state2Selected = 1
    self.state2Text = {}

    self.alpha = 0
    self.name = 'ReplayLoader'

    menu.replayLoaderMenu:Refresh()
end

function menu.replayLoaderMenu:Refresh()
    self.state1Text = FetchReplaySlots()
end

function menu.replayLoaderMenu:frame()
    self.timer = self.timer + 1
    task.Do(self)
    if not self:isActive() then
        return
    end
    if self.shakeValue > 0 then
        self.shakeValue = self.shakeValue - 1
    end

    -- 控制逻辑
    if self.state == 0 then
        --local lastKey = GetLastKey()
        if KeyIsDown('up') then
            self.state1Selected = max(1, self.state1Selected - 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsDown('down') then
            self.state1Selected = min(ext.replay.GetSlotCount(), self.state1Selected + 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            -- 构造关卡列表
            local slot = ext.replay.GetSlot(self.state1Selected)
            if slot ~= nil then
                self.state = 1
                self.state2Text = {}
                self.state2Selected = 1
                self.shakeValue = ui.menu.shake_time

                for i, v in ipairs(slot.stages) do
                    local stage = string.match(v.stageName, '^(.+)@.+$')
                    local score = string.format("%012d", v.score)
                    table.insert(self.state2Text, { stage, score })
                end
                PlaySound('ok00', 0.3)
            end
        elseif KeyIsPressed("spell") then
            if self.exitCallback then
                self.exitCallback()
            end
            PlaySound('cancel00', 0.3)
        end
    elseif self.state == 1 then
        local slot = ext.replay.GetSlot(self.state1Selected)
        --local lastKey = GetLastKey()
        if KeyIsDown('up') then
            self.state2Selected = max(1, self.state2Selected - 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsDown('down') then
            self.state2Selected = min(#slot.stages, self.state2Selected + 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            -- 转场
            slot = ext.replay.GetSlot(self.state1Selected)
            if self.exitCallback then
                self.exitCallback(slot.path, slot.stages[self.state2Selected].stageName)
            end
            PlaySound('ok00', 0.3)
        elseif KeyIsPressed("spell") then
            self.shakeValue = ui.menu.shake_time
            self.state = 0
        end
    end
end

function menu.replayLoaderMenu:render()
    SetViewMode('ui')
    if self.state == 0 then
        ui.DrawRepText(
            "replayfnt",
            "replay_title",
            self.state1Text,
            self.state1Selected,
            self.x,
            self.y,
            self.alpha,
            self.timer,
            self.shakeValue
        )
    elseif self.state == 1 then
        ui.DrawRepText2(
            "replayfnt",
            "replay_title",
            self.state2Text,
            self.state2Selected,
            self.x,
            self.y + 120,
            self.alpha,
            self.timer,
            self.shakeValue,
            "center")
    end
end

local _keyboard = {}
do
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
end
---@class menu.replaySaverMenu:menu.menuObject
menu.replaySaverMenu = plus.Class(menu.menuObject)

---@param stages table 存放存入replay中的关卡的表
---@param finish integer 关卡完成情况
---@param exitCallback function 退出的回调函数
---@return menu.replaySaverMenu
function menu.replaySaverMenu.create(stages, finish, exitCallback)
    local m = menu.replaySaverMenu(stages, finish, exitCallback)
    menu.addMenu("ReplaySaver", m)
    return m
end

function menu.replaySaverMenu:init(stages, finish, exitCallback)
    menu.menuObject.init(self)
    self.x = screen.width * 0.5 - screen.width
    self.y = screen.height * 0.5

    self.finish = finish or 0
    self.stages = stages
    self.exitCallback = exitCallback
    self.alpha = 0
    self.shakeValue = 0

    self.state = 0
    self.state1Selected = 1
    self.state1Text = FetchReplaySlots()
    self.state2CursorX = 0
    self.state2CursorY = 0
    self.state2UserName = ""

    self.name = 'ReplaySaver'
end

function menu.replaySaverMenu:frame()
    self.timer = self.timer + 1
    task.Do(self)
    if not self:isActive() then
        return
    end

    if self.shakeValue > 0 then
        self.shakeValue = self.shakeValue - 1
    end

    -- 控制逻辑
    if self.state == 0 then
        --local lastKey = GetLastKey()
        if KeyIsDown('up') then
            self.state1Selected = max(1, self.state1Selected - 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsDown('down') then
            self.state1Selected = min(ext.replay.GetSlotCount(), self.state1Selected + 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            -- 跳转到录像保存状态
            self.state = 1
            --self.state2CursorX = 0
            --self.state2CursorY = 0
            --self.state2UserName = ""
            --由OLC修改，保存rep时菜单用来记录名称的参数
            if scoredata.repsaver == nil then
                scoredata.repsaver = ""
            end
            self.state2UserName = scoredata.repsaver
            if self.state2UserName ~= "" then
                self.state2CursorX = 12
                self.state2CursorY = 6
            else
                self.state2CursorX = 0
                self.state2CursorY = 0
            end
        elseif KeyIsPressed("spell") then
            if self.exitCallback then
                self.exitCallback()
            end
            PlaySound('cancel00', 0.3)
        end
    elseif self.state == 1 then
        --local lastKey = GetLastKey()
        if KeyIsDown('up') then
            self.state2CursorY = self.state2CursorY - 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsDown('down') then
            self.state2CursorY = self.state2CursorY + 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsDown('left') then
            self.state2CursorX = self.state2CursorX - 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsDown('right') then
            self.state2CursorX = self.state2CursorX + 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            if self.state2CursorX == 12 and self.state2CursorY == 6 then
                if self.state2UserName == "" then
                    self.state2UserName = "Anonymous"
                else
                    --由OLC添加，保存rep时菜单用来记录名称的参数
                    scoredata.repsaver = self.state2UserName
                end

                -- 保存录像
                ext.replay.SaveReplay(self.stages, self.state1Selected, self.state2UserName, self.finish)

                if self.exitCallback then
                    self.exitCallback()
                end
                PlaySound("extend", 0.5)
            end

            if #self.state2UserName == REPLAY_USER_NAME_MAX then
                self.state2CursorX = 12
                self.state2CursorY = 6
            elseif self.state2CursorX == 11 and self.state2CursorY == 6 then
                if #self.state2UserName == 0 then
                    self.state = 0
                else
                    self.state2UserName = string.sub(self.state2UserName, 1, -2)
                end
                PlaySound('cancel00', 0.3)
            elseif self.state2CursorX == 10 and self.state2CursorY == 6 then
                local char = string.char(0x20)
                self.state2UserName = self.state2UserName .. char
                PlaySound('ok00', 0.3)
            else
                local char = string.char(_keyboard[self.state2CursorY * 13 + self.state2CursorX + 1])
                self.state2UserName = self.state2UserName .. char
                PlaySound('ok00', 0.3)
            end
        elseif KeyIsPressed("spell") then
            if #self.state2UserName == 0 then
                self.state = 0
            else
                self.state2UserName = string.sub(self.state2UserName, 1, -2)
            end
            --			self.state = 0
            PlaySound('cancel00', 0.3)
        end

        self.state2CursorX = (self.state2CursorX + 13) % 13
        self.state2CursorY = (self.state2CursorY + 7) % 7
    end
end

function menu.replaySaverMenu:render()
    SetViewMode('ui')
    if self.state == 0 then
        ui.DrawRepText(
            "replayfnt",
            "save_rep_title",
            self.state1Text,
            self.state1Selected,
            self.x,
            self.y,
            self.alpha,
            self.timer,
            self.shakeValue
        )
    elseif self.state == 1 then
        Render("save_rep_title", self.x, self.y + ui.menu.sc_pr_line_height + 15 * ui.menu.sc_pr_line_height * 0.5)
        ---- 绘制键盘
        -- 未选中按键
        SetFontState("replay", "", Color(255 * self.alpha, unpack(ui.menu.unfocused_color)))
        for x = 0, 12 do
            for y = 0, 6 do
                if x ~= self.state2CursorX or y ~= self.state2CursorY then
                    --[[					RenderText(
                                            "replay",
                                            string.char(0x20 + y * 12 + x),
                                            self.x + (x - 5.5) * ui.menu.char_width,
                                            self.y - (y - 3.5) * ui.menu.line_height,
                                            ui.menu.font_size,
                                            'centerpoint'
                                        )]]
                    RenderText(
                        "replay",
                        string.char(_keyboard[y * 13 + x + 1]),
                        self.x + (x - 5.5) * ui.menu.char_width,
                        self.y - (y - 3.5) * ui.menu.line_height,
                        ui.menu.font_size,
                        'centerpoint'
                    )
                end
            end
        end
        -- 激活按键
        local color = {}
        local k = cos(self.timer * ui.menu.blink_speed) ^ 2
        for i = 1, 3 do
            color[i] = ui.menu.focused_color1[i] * k + ui.menu.focused_color2[i] * (1 - k)
        end
        SetFontState("replay", "", Color(255 * self.alpha, unpack(color)))
        RenderText(
            "replay",
            string.char(_keyboard[self.state2CursorY * 13 + self.state2CursorX + 1]),
            self.x + (self.state2CursorX - 5.5) * ui.menu.char_width +
            ui.menu.shake_range * sin(ui.menu.shake_speed * self.shakeValue),
            self.y - (self.state2CursorY - 3.5) * ui.menu.line_height,
            ui.menu.font_size,
            "centerpoint"
        )

        -- 标题
        SetFontState("replay", "", Color(255 * self.alpha, unpack(ui.menu.title_color)))
        RenderText("replay", self.state2UserName, self.x, self.y - 5.5 * ui.menu.line_height, ui.menu.font_size,
            "centerpoint")
    end
end

return menu
