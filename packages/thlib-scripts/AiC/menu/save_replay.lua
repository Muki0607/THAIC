local lib = aic.menu

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
