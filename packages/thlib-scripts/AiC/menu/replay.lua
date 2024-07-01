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
    self.t = 8
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
    function self.changelevel()
        if self.slot ~= nil then
            self.text2 = {}
            self.pos2 = 1
            self.wait = self.t * 2
            lib.Fly(self, 0, 'down')
            task.New(self, function()
                task.Wait(self.t)
                self.level = 2
                self.x = self.default_x + 20
                self.y = self.default_y
                lib.Fly(self, 1, "left")
            end)

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
                if self.warn then
                    self.wait = self.t
                    self.warn = false
                else
                    self.wait = 114514
                    self.quit()
                end
            elseif KeyIsPressed('shoot') and self.slot then
                --[[
                self.wait = 114514
                if setting.newopening then
                    PlaySound('aic_opening_new', 0.5)
                else
                    PlaySound('aic_opening', 0.5)
                end
                self.quit(self.slot.path, self.slot.stages[1].stageName)
                --[[]]
                self.wait = self.t
                if tonumber(string.sub(self.text3_kt[5], 1, 3)) ~= aic.sys.GetVersionNumber() then --检查大版本是否一致，不一致时发出警告
                    if not self.warn then
                        self.warn = true
                    else
                        PlaySound('ok00', 0.3)
                        self.changelevel()
                    end
                else
                    PlaySound('ok00', 0.3)
                    self.changelevel()
                end
                --]]
            end
            if KeyIsDown('up') then
                self.wait = self.t
                PlaySound('select00', 0.5)
                if self.pos1 > 1 + self.l * (self.page - 1) then
                    self.pos1 = self.pos1 - 1
                else
                    self.pos1 = 0
                end
            elseif KeyIsDown('down') then
                self.wait = self.t
                PlaySound('select00', 0.5)
                if self.pos1 < self.l * self.page then
                    if self.pos1 == 0 then
                        self.pos1 = 1 + self.l * (self.page - 1)
                    else
                        self.pos1 = self.pos1 + 1
                    end
                end
            elseif KeyIsDown('left') then
                self.wait = self.t
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
                self.wait = self.t
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
            elseif KeyIsPressed('shoot') then
                PlaySound('ok00', 0.3)
                self.wait = 114514
                if setting.newopening then
                    PlaySound('aic_opening_new', 0.5)
                else
                    PlaySound('aic_opening', 0.5)
                end
                self.quit(self.slot.path, self.slot.stages[self.pos2].stageName)
            end
            if KeyIsDown('up') then
                self.wait = self.t
                PlaySound('select00', 0.5)
                if self.pos2 > 1 then
                    self.pos2 = self.pos2 - 1
                else
                    self.pos = #slot.stages
                end
            elseif KeyIsDown('down') then
                self.wait = self.t
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
        local xos = { -300, -240, -180, -80, -20, 40, 80 }
        local yos = (self.l + 1) * lineh * 0.5 + 30

        --自动保存位
        self.DrawRepInfo(0, xos, yos, lineh, x, y, text, pos, timer)
        for i = 1 + self.l * (self.page - 1), self.l * self.page do
            self.DrawRepInfo(i, xos, yos, lineh, x, y, text, pos, timer)
        end

        --普莉姆拉老师！
        SetImageState('Muki_AiC_menu_replay_Primula', '', color(COLOR_WHITE, self.alpha))
        Render('Muki_AiC_menu_replay_Primula', x + 150, y, 0, -0.5, 0.5)

        lib.DrawTips(self, { '播放Replay', '返回上一级菜单' })
        
        local text3, y = self.text3_kt, y - self.l * lineh * 0.5 + 20
        if self.warn then
            DrawText("main_font_zh2", '该Replay游戏版本与当前版本相差较大，播放可能导致错误。是否继续播放？\n若要播放，请再次按下确认键。',
                x + xos[1], y - 1 * lineh * 1.25, 0.75, _color(COLOR_RED, self.alpha))
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
        lib.DrawTips(self, { '播放Replay', '返回' }, { '选择关卡' })
        local x, y, text, pos, alpha = self.x, self.y + 80, self.text2, self.pos2, self.alpha
        local lineh = 22
        local xos = { -60, 20 }
        local yos = (#text + 1) * lineh * 0.5
        local color = { { 255, 255, 48 }, { 128, 128, 128 } }
        for i = 1, #text do
            if i == pos then
                --local xos=ui.menu.shake_range*sin(ui.menu.shake_speed*shake)
                DrawText('main_font_zh2', text[i][1], x + xos[1], y - i * lineh + yos, 0.75,
                    Color(alpha, unpack(color[1])), nil, "vcenter", "noclip")
                DrawText('main_font_zh2', text[i][2], x + xos[2], y - i * lineh + yos, 0.75,
                    Color(alpha, unpack(color[1])), nil, "vcenter", "noclip")
            else
                DrawText('main_font_zh2', text[i][1], x + xos[1], y - i * lineh + yos, 0.75,
                    Color(alpha, unpack(color[2])), nil, "vcenter", "noclip")
                DrawText('main_font_zh2', text[i][2], x + xos[2], y - i * lineh + yos, 0.75,
                    Color(alpha, unpack(color[2])), nil, "vcenter", "noclip")
            end
        end
    end
    SetViewMode('world')
end
