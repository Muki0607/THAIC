local lib = aic.menu

------------------------------------------------------------

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
            17 --#aic.l10n.ui.sc_list[1]
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
    lib.DrawTips(self, { '选择', '返回上一级菜单' })
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
