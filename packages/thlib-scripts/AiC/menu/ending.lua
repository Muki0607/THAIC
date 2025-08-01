local lib = aic.menu

------------------------------------------------------------

---主菜单
lib.ending = Class(object)

function lib.ending:init()
    self.num = 14 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.x = 15
    self.y = screen.height - 15
    self.default_x = 15
    self.default_y = screen.height - 15
    self.bound = false
    self.t = 30
    self.alpha = 0
    self.text_scale = 1
    self.text_co = color()
    self.intv = 4
    self.text = ''
    self.ttfdrawer = aic.custom_dialog.TTFDrawer('', self)
    _play_music('aic_bgm18', nil, false)
    task.New(self, function()
        local d = aic.l10n.dialog.dialog_true_ending
        local l
        for i, v in ipairs(d.text) do
            l = sp.string(v):GetCharCount()
            local snd = d.snd[i]
            for j = 1, l do
                self.text = self.text .. sp.string(v):Sub(j, j)
                PlaySound(snd, 1, 0, true)
                task.Wait(self.intv)
            end
            self.text = self.text .. '\n'
            task.Wait(self.t)
            if i % 28 == 0 then self.text = '' end
        end
        self.finished = true
    end)
end

function lib.ending:frame()
    task.Do(self)
    if self.text then self.ttfdrawer:set(self.text) end
    if self.finished and KeyIsPressed('shoot') then 
        lib.ClearMenuStack(0)
        lib.PushMenuStack(lib.title)
    end
end

function lib.ending:render()
    SetViewMode('ui')
    if self.text then
        local x, y = self.x, self.y
        self.ttfdrawer:render('dialog',
            x, x, y, y, 16, 32, 0, 0,
            self.text_scale, self.text_co, 4)
    end
    SetViewMode('world')
end
