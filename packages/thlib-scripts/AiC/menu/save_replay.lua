local lib = aic.menu

---录像保存菜单
lib.save_replay = Class(object)

---@param stages table @关卡表
---@param finish number @0为未通关，1为通关
---@param name string @机签
function lib.save_replay:init(score_pos, data)
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
    self.t = 8
    self.wait = 30
    self.alpha = 0
    self.lname = 8 --REPLAY_USER_NAME_MAX
    self.format1 = "%02d %s %" .. self.lname .. "s %012d"
    self.format2 = "%02d ----/--/-- --:--:-- %" .. self.lname .. "s %012d"
    self.stages = lib.last_replay
    self.finish = lib.last_replay_finish
    self.name = scoredata.repsaver
    self.posX = 0
    self.posY = 0
    self.info_y = screen.height / 2
    --覆盖rep时警告
    self.warn = false
    self.warn_confirm = false
    self.score_pos = score_pos
    self.data = data

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

    ---更新名称
    function self.UpdateName()
        self.data[self.score_pos][1] = self.name
    end
    self.UpdateName()

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
                lib.last_replay = nil
                lib.ClearMenuStack()
                lib.PopMenuStack()
                lib.PushMenuStack(lib.title)
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
                    self.SaveReplay()
                    lib.ClearMenuStack()
                    lib.PopMenuStack()
                    lib.PushMenuStack(lib.title)
                end

                if #self.name == self.lname then
                    self.posX = 12
                    self.posY = 6
                elseif self.posX == 11 and self.posY == 6 then
                    if #self.name ~= 0 then
                        self.name = string.sub(self.name, 1, -2)
                        self.UpdateName()
                    end
                    PlaySound('cancel00', 0.3)
                elseif self.posX == 10 and self.posY == 6 then
                    local char = string.char(0x20)
                    self.name = self.name .. char
                    self.UpdateName()
                    PlaySound('ok00', 0.3)
                else
                    local char = string.char(self.keyboard[self.posY * 13 + self.posX + 1])
                    self.name = self.name .. char
                    self.UpdateName()
                    PlaySound('ok00', 0.3)
                end
            elseif KeyIsPressed("spell") then
                if #self.name == 0 then
                    self.wait = self.t
                    self.level = 1
                else
                    self.wait = self.t
                    self.name = string.sub(self.name, 1, -2)
                    self.UpdateName()
                end
                PlaySound('cancel00', 0.3)
            end
        end
    end
end

function lib.save_replay:render()
    SetViewMode('ui')
    if self.level == 1 then
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
    else
        -- 绘制键盘
        -- 未选中按键
        SetFontState("replay", "", Color(255 * self.alpha, unpack(ui.menu.unfocused_color)))
        --是谁写的在Lua里还从0开始数啊（恼）
        --担心哪里会有逻辑出问题就没改了
        local w, h, _y = 18, 15, self.y - 45
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
                            self.x + (x - 5.5) * w, _y - (y - 3.5) * h,
                            0.7, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                    elseif x == 11 then
                        DrawText("main_font_zh2", 'BS',
                            self.x + (x - 5.5) * w, _y - (y - 3.5) * h,
                            0.7, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                    else
                        DrawText("main_font_zh2", string.char(self.keyboard[y * 13 + x + 1]),
                            self.x + (x - 5.5) * w, _y - (y - 3.5) * h,
                            0.75, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                    end
                else
                    DrawText("main_font_zh2", string.char(self.keyboard[y * 13 + x + 1]),
                        self.x + (x - 5.5) * w, _y - (y - 3.5) * h,
                        0.75, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                end
            end
        end
    end
    --覆盖rep时警告
    if self.warn then
        local co = { [true] = { 32, 208, 255 }, [false] = { 255, 255, 255 } }

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
