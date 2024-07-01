local lib = aic.menu

---录像保存菜单
lib.save_replay = Class(object)

---@param data table @分数数据
---@param rep_saved boolean @是否已保存录像
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
    self.l = 12 --一页中显示的rep数
    self.page = 1 --当前页数
    self.lpage = 4 --总页数
    self.slot = nil --当前位置rep
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.default_x = screen.width * 0.5
    self.default_y = screen.height * 0.5
    self.bound = false
    self.t = 8
    self.wait = 30
    self.alpha = 0
    self.lname = 8 --REPLAY_USER_NAME_MAX
    self.format1 = "%02d %s %" .. self.lname .. "s %012d"
    self.format2 = "%02d ----/--/-- --:--:-- %" .. self.lname .. "s %012d"
    self.stages = lib.last_replay
    self.finish = lib.last_replay_finish and 1 or 0 --非常简洁漂亮的写法
    self.name = scoredata.repsaver
    self.posX = 0
    self.posY = 0
    self.info_y = 0
    self.rep_saved = false --是否已保存rep
    self.warn1 = false --未保存rep时警告
    self.warn2 = false --覆盖rep时警告

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
            for m = 1, 7 do
                DrawText("main_font_zh2", text[i][m] or 'nil', x + xos[m], y - max(0, (i - self.l * (self.page - 1))) * lineh + yos, 0.8,
                    Color(self.alpha, unpack(color)), nil, "vcenter", "left")
            end
        else
            for m = 1, 7 do
                DrawText("main_font_zh2", text[i][m] or 'nil', x + xos[m], y - max(0, (i - self.l * (self.page - 1))) * lineh + yos, 0.8,
                    _color(COLOR_WHITE, self.alpha), nil, "vcenter", "left")
            end
        end
    end

    ---渲染要保存的rep信息
    function self.DrawRepInfo2(xos, x, y, text)
        for m = 1, 7 do
            DrawText("main_font_zh2", text[m] or 'nil', x + xos[m], y, 0.8,
                color(COLOR_WHITE, self.alpha), nil, "vcenter", "left")
        end
    end

    --[[
    ---更新名称
    function self.UpdateName()
        self.data[self.score_pos][1] = aic.string.Filter(self.name, '\"')
    end
    self.UpdateName()
    --]]    

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

    ---退出
    function self.quit()
        lib.last_replay = nil
        self.wait = 114514
        lib.Fly(self, 0, 'right', true)
        lib.ClearMenuStack(0)
        lib.PushMenuStack(lib.title)
    end

    ---保存rep并返回至rep列表
    function self.SaveReplay()
        self.replay_saved = true
        ext.replay.SaveReplay(self.stages, self.pos1, self.name, self.finish)
        lib.FetchReplaySlots(self)
        PlaySound('extend', 1)
        self.warn1, self.warn2 = false
        self.wait = self.t * 2
        lib.Fly(self, 0, 'down')
        task.New(self, function()
            task.Wait(self.t)
            self.level = 1
            self.x = self.default_x + 20
            self.y = self.default_y
            lib.Fly(self, 1, "left")
        end)
    end
    
    lib.FetchReplaySlots(self)
    lib.Fly(self, 1, 'left')
end

function lib.save_replay:frame()
    task.Do(self)
    self.name = aic.string.Filter(self.name, '\"')
    self.wait = max(self.wait - 1, 0)
    self.posX = (self.posX + 13) % 13
    self.posY = (self.posY + 7) % 7
    if self.level == 2 then
        if self.info_y ~= self.y then --将rep信息移动至保存位置
            if abs(self.info_y - self.y) < 20 then
                self.info_y = self.y
            else
                self.info_y = self.info_y - 20 * sign(self.info_y - self.y)
            end
        end
    end
    if self.wait < 1 then
        --local lastkey = GetLastKey()
        self.pos1 = min(max(0, self.pos1), self.l * self.lpage)
        self.slot = ext.replay.GetSlot(self.pos1)
        lib.GetExtRepInfo(self)
        if self.level == 1 then
            if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
                if self.replay_saved then
                    self.warn1 = false
                    self.quit()
                else
                    self.wait = 30
                    self.warn1 = not self.warn1
                    self.warn2 = false
                end
                PlaySound('cancel00', 0.5)
            elseif KeyIsPressed('shoot') then
                local lineh = 15
                local yos = (self.l + 1) * lineh * 0.5 + 30
                self.info_y = self.y - max(0, (self.pos1 - self.l * (self.page - 1))) * lineh + yos --确认rep的y坐标
                self.name = aic.string.Filter(scoredata.repsaver, '\"') --再次进入保存界面时重置名称
                self.wait = 30
                if self.warn1 then
                    self.warn1 = false
                    self.quit()
                else
                    if self.warn2 then
                        self.level = 2
                    else
                        if self.slot then
                            self.warn2 = true
                        else
                            self.level = 2
                        end
                    end
                end
                PlaySound('ok00', 0.3)
            end
            if not (self.warn1 or self.warn2) then
                if KeyIsDown('up') then
                    self.wait = 8
                    PlaySound('select00', 0.5)
                    if self.pos1 > 1 + self.l * (self.page - 1) then
                        self.pos1 = self.pos1 - 1
                    else
                        self.pos1 = self.l * self.page
                    end
                elseif KeyIsDown('down') then
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
                    if self.page < self.lpage then
                        self.page = self.page + 1
                        self.pos1 = self.pos1 + self.l
                    else
                        self.page = 1
                        self.pos1 = self.pos1 - self.l * (self.lpage - 1)
                    end
                end
            end
        else
            if KeyIsDown('up') then
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
                    self.SaveReplay()
                end

                if #self.name == self.lname then
                    self.posX = 12
                    self.posY = 6
                elseif self.posX == 11 and self.posY == 6 then
                    if #self.name ~= 0 then
                        self.name = string.sub(self.name, 1, -2)
                    end
                    PlaySound('cancel00', 0.3)
                elseif self.posX == 10 and self.posY == 6 then
                    local char = string.char(0x20)
                    self.name = self.name .. char
                    PlaySound('ok00', 0.3)
                else
                    local char = string.char(self.keyboard[self.posY * 13 + self.posX + 1])
                    self.name = self.name .. char
                    PlaySound('ok00', 0.3)
                end
            elseif KeyIsPressed("spell") or aic.input.CheckLastKey('menu') then
                if #self.name == 0 then
                    self.wait = self.t * 2
                    lib.Fly(self, 0, 'down')
                    task.New(self, function()
                        task.Wait(self.t)
                        self.level = 1
                        self.x = self.default_x + 20
                        self.y = self.default_y
                        lib.Fly(self, 1, "left")
                    end)
                else
                    self.wait = self.t
                    self.name = string.sub(self.name, 1, -2)
                end
                PlaySound('cancel00', 0.3)
            end
        end
    end
end

function lib.save_replay:render()
    SetViewMode('ui')
    lib.DrawSubTitle(self)
    local _color = color
    local x, y, text, pos, timer = self.x, self.y, sp.copy(self.text1), self.pos1, self.timer
    local lineh = 15
    local xos = { -300, -240, -180, -80, -20, 40, 80 }
    local yos = (self.l + 1) * lineh * 0.5 + 30

    --普莉姆拉老师！
    SetImageState('Muki_AiC_menu_replay_Primula', '', color(COLOR_WHITE, self.alpha))
    Render('Muki_AiC_menu_replay_Primula', x + 150, y, 0, -0.5, 0.5)

    if self.level == 1 then
        lib.DrawTips(self, { '选择保存位置', '取消保存Replay' }, { '移动', '翻页' })

        --自动保存位
        self.DrawRepInfo(0, xos, yos, lineh, x, y, text, pos, timer)
        for i = 1 + self.l * (self.page - 1), self.l * self.page do
            self.DrawRepInfo(i, xos, yos, lineh, x, y, text, pos, timer)
        end

        local text3, y = self.text3_kt, y - self.l * lineh * 0.5 + 20
        if self.warn1 then
            DrawText("main_font_zh2", 'Replay尚未保存。是否退出？\n若要退出，请按下确认键。',
                x + xos[1], y - lineh * 1.25, 0.75, _color(COLOR_RED, self.alpha))
        elseif self.warn2 then
            DrawText("main_font_zh2", '该位置已有Replay。是否覆盖？\n若要覆盖，请再次按下确认键。',
                x + xos[1], y - lineh * 1.25, 0.75, _color(COLOR_RED, self.alpha))
        else
            --额外信息渲染
            if text3 then
                local len = text3('len')
                --通过键表实现对值表的散列部分进行有序读取（即有序字典）
                for i = 1, len - 1 do
                    DrawText("main_font_zh2", text3('get', i) .. ": " .. text3[i], x + xos[1], y - i * lineh * 1.25, 0.75,
                        _color(COLOR_WHITE, self.alpha))
                end
                --对携带插件特化处理，给予足够空间渲染插件图标
                DrawText("main_font_zh2", text3('get', len) .. ": ", x + xos[1], y - len * lineh * 1.25 - 10, 0.75,
                    _color(COLOR_WHITE, self.alpha))
                for k, v in ipairs(text3[len]) do
                    local s = 0.35
                    if v >= 12 and v ~= 16 then s = s * 2 end
                    Render('Muki_AiC_menu_enhancer_select' .. v, x + xos[1] + 40 + k * 28, y - len * lineh * 1.25 - 10, 0, s)
                end
            end
        end
    else
        lib.DrawTips(self, { '输入字符', '删除字符' })
        -- 绘制键盘
        -- 未选中按键
        SetFontState("replay", "", Color(255 * self.alpha, unpack(ui.menu.unfocused_color)))
        --是谁写的在Lua里还从0开始数啊（恼）
        --担心哪里会有逻辑出问题就没改了
        local w, h, _x, _y = 18, 15, self.x - 100, self.y - 100
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
                            _x + (x - 5.5) * w, _y - (y - 3.5) * h,
                            0.7, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                    elseif x == 11 then
                        DrawText("main_font_zh2", 'BS',
                            _x + (x - 5.5) * w, _y - (y - 3.5) * h,
                            0.7, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                    else
                        DrawText("main_font_zh2", string.char(self.keyboard[y * 13 + x + 1]),
                            _x + (x - 5.5) * w, _y - (y - 3.5) * h,
                            0.75, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                    end
                else
                    DrawText("main_font_zh2", string.char(self.keyboard[y * 13 + x + 1]),
                        _x + (x - 5.5) * w, _y - (y - 3.5) * h,
                        0.75, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                end
            end
        end

        ---录像信息
        local slot = lib.GetReplayData(0)
        local text = { string.format('No.%02d', self.pos1), self.name, slot[3], slot[4], slot[5], slot[6], slot[7] }
        self.DrawRepInfo2(xos, self.x, self.info_y, text)
    end

    SetViewMode('world')
end
