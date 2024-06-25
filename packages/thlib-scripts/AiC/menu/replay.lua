local lib = aic.menu

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
