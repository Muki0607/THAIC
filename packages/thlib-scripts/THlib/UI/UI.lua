---THAIC Arranged
Include "THlib/UI/uiconfig.lua"
Include "THlib/UI/font.lua"
Include "THlib/UI/title.lua"
Include "THlib/UI/sc_pr.lua"
Include "THlib/UI/newmenu/title.lua"

ui = {}

LoadTexture("boss_ui", "THlib/UI/boss_ui.png")
LoadImage("boss_spell_name_bg", "boss_ui", 0, 0, 256, 36)
SetImageCenter("boss_spell_name_bg", 256, 0)
LoadImage("player_spell_name_bg", "boss_ui", 0, 100, 256, 36)
SetImageCenter("player_spell_name_bg", 0, 0)

LoadImage("boss_pointer", "boss_ui", 0, 64, 48, 16)
SetImageCenter("boss_pointer", 24, 0)
LoadImage("player_pointer", "boss_ui", 0, 82, 48, 16)
SetImageCenter("player_pointer", 24, 0)

LoadImage("boss_sc_left", "boss_ui", 64, 64, 32, 32)
SetImageState("boss_sc_left", "", Color(255, 82, 228, 242))

LoadTexture("hint", "THlib/UI/hint.png", true)
LoadImage("hint.bonusfail", "hint", 10, 64, 236, 64)
LoadImage("hint.getbonus", "hint", 16, 144, 348, 64)
LoadImage("hint.extend", "hint", 0, 192, 160, 64)
--LoadImage("hint.power", "hint", 0, 12, 84, 32)
LoadImage("hint.graze", "hint", 86, 12, 74, 32)
LoadImage("hint.point", "hint", 160, 12, 120, 32)
--[[
LoadImage("hint.life", "hint", 288, 0, 16, 15)
LoadImage("hint.lifeleft", "hint", 304, 0, 16, 15)
LoadImage("hint.bomb", "hint", 320, 0, 16, 16)
LoadImage("hint.bombleft", "hint", 336, 0, 16, 16)
]]
LoadImage("kill_time", "hint", 232, 200, 152, 56, 16, 16)
--SetImageCenter("hint.power", 0, 16)
SetImageCenter("hint.graze", 0, 16)
SetImageCenter("hint.point", 0, 16)
--[[
LoadImageGroup("lifechip", "hint", 288, 16, 16, 15, 4, 1, 0, 0)
LoadImageGroup("bombchip", "hint", 288, 32, 16, 16, 4, 1, 0, 0)
LoadImage("hint.hiscore", "hint", 424, 8, 80, 20)
LoadImage("hint.score", "hint", 424, 30, 64, 20)
]]
LoadImage("hint.hiscore", "hint", 248, 53, 127, 32)
LoadImage("hint.score", "hint", 275, 84, 73, 27)
LoadImage("hint_enhancer1", "hint", 380, 50, 117, 32)
LoadImage("hint_enhancer2", "hint", 380, 82, 117, 30)
LoadImage("hint.power", "hint", 380, 112, 117, 30)
LoadImage("hint.Pnumber", "hint", 380, 142, 117, 30)
LoadImage("hint.Bnumber", "hint", 380, 170, 117, 32)
--LoadImage("hint.Cnumber", "hint", 352, 52, 40, 20)
SetImageCenter("hint.hiscore", 0, 16)
SetImageCenter("hint.score", 0, 14)
SetImageCenter("hint.power", 0, 17)
SetImageCenter("hint.Pnumber", 0, 17)
SetImageCenter("hint.Bnumber", 0, 17)

LoadTexture("line", "THlib/UI/line.png", true)
LoadImageGroup("line_", "line", 0, 0, 200, 8, 1, 7, 0, 0)

LoadTexture("ui_rank", "THlib/UI/rank.png")
LoadImage("rank_Easy", "ui_rank", 0, 0, 144, 32)
LoadImage("rank_Normal", "ui_rank", 0, 32, 144, 32)
LoadImage("rank_Hard", "ui_rank", 0, 64, 144, 32)
LoadImage("rank_Lunatic", "ui_rank", 0, 96, 144, 32)
LoadImage("rank_Extra", "ui_rank", 0, 128, 144, 32)
LoadImageFromFile("rank_AliceInCradle", "THlib/UI/Muki_AiC_rank.png")

LoadTexture("hint_AiC_bar_empty", "THlib/UI/Muki_AiC_bar_empty.png")
LoadTexture("hint_AiC_bar_hp", "THlib/UI/Muki_AiC_bar_hp.png")
LoadTexture("hint_AiC_bar_temp_hp", "THlib/UI/Muki_AiC_bar_temp_hp.png")
LoadTexture("hint_AiC_bar_mp", "THlib/UI/Muki_AiC_bar_mp.png")
LoadTexture("hint_AiC_bar_broken", "THlib/UI/Muki_AiC_bar_broken.png")
LoadTexture("hint_AiC_bar_broken2", "THlib/UI/Muki_AiC_bar_broken2.png")
LoadTexture("hint_AiC_bar_seperate", "THlib/UI/Muki_AiC_bar_seperate.png")
LoadTexture("hint_AiC_bar_mp_active", "THlib/UI/Muki_AiC_bar_mp_active.png")
LoadTexture("hint_AiC_bar_gap", "THlib/UI/Muki_AiC_bar_gap.png")
local bar_tw, bar_th = GetTextureSize("hint_AiC_bar_empty")
local bar_w, bar_h = bar_tw * 0.4, bar_th * 0.4

LoadImageFromFile("hint_AiC_square_empty", "THlib/UI/Muki_AiC_square_empty.png")
LoadImageFromFile("hint_AiC_square_empty_green", "THlib/UI/Muki_AiC_square_empty_green.png")
LoadImageFromFile("hint_AiC_square_middle_green", "THlib/UI/Muki_AiC_square_middle_green.png")
local squ_tw, squ_th = GetTextureSize("hint_AiC_square_empty")
local squ_w, squ_h = squ_tw * 0.4, squ_th * 0.4

LoadImageFromFile("hint_AiC_dodge_icon", "THlib/UI/Muki_AiC_dodge_icon.png")
LoadImageFromFile("hint_AiC_dodge_bar", "THlib/UI/Muki_AiC_dodge_bar.png")
LoadImageFromFile("hint_AiC_dodge_bar_empty", "THlib/UI/Muki_AiC_dodge_bar_empty.png")
LoadImageFromFile("hint_AiC_square_middle", "THlib/UI/Muki_AiC_square_middle.png")

ui.menu = {
    font_size = 0.625,
    line_height = 24,
    char_width = 20,
    num_width = 12.5,
    title_color = { 255, 255, 255 },
    unfocused_color = { 128, 128, 128 },
    --	unfocused_color={255,255,255},
    focused_color1 = { 255, 255, 255 },
    focused_color2 = { 255, 192, 192 },
    blink_speed = 7,
    shake_time = 9,
    shake_speed = 40,
    shake_range = 3,
    sc_pr_line_per_page = 12,
    sc_pr_line_height = 22,
    sc_pr_width = 320,
    sc_pr_margin = 8,
    rep_font_size = 0.6,
    rep_line_height = 20,
}

local function Stroke(font, text, x, y, co, ...)
    local _x, _y
    for i = 0, 8 do
        _x = x + sqrt(2) * cos(i * 45)
        _y = y + sqrt(2) * sin(i * 45)
        RenderTTF(font, text,
            _x, _x, _y, _y, co, ...)
    end
end

function ui.DrawMenu(title, text, pos, x, y, alpha, timer, shake, align)
    align = align or "center"
    local yos
    if title == "" then
        yos = (#text + 1) * ui.menu.line_height * 0.5
    else
        yos = (#text - 1) * ui.menu.line_height * 0.5
        --SetFontState("menu", "", Color(alpha * 255, unpack(ui.menu.title_color)))
        --RenderText("menu", title, x, y + yos + ui.menu.line_height, ui.menu.font_size, align, "vcenter")
        Stroke("menuttf", title, x + 5, y + yos + ui.menu.line_height,
            Color(alpha * 255, 0, 0, 0), "centerpoint")    
        RenderTTF("menuttf", title, x + 5, x + 5, y + yos + ui.menu.line_height,
            y + yos + ui.menu.line_height, Color(alpha * 255, unpack(ui.menu.title_color)), "centerpoint")
    end
    for i = 1, #text do
        if i == pos then
            local color = {}
            local k = cos(timer * ui.menu.blink_speed) ^ 2
            for j = 1, 3 do
                color[j] = ui.menu.focused_color1[j] * k + ui.menu.focused_color2[j] * (1 - k)
            end

            local xos = ui.menu.shake_range * sin(ui.menu.shake_speed * shake)

            --SetFontState("menu", "", Color(alpha * 255, unpack(color)))
            --RenderText("menu", text[i], x + xos, y - i * ui.menu.line_height + yos, ui.menu.font_size, align, "vcenter")
            --[[ui.Stroke("menuttf", text[i], x + xos + 2, y - i * ui.menu.line_height + yos,
                Color(alpha * 255, 0, 0, 0), "centerpoint")
            RenderTTF("menuttf", text[i], x + xos + 2, x + xos + 2, y - i * ui.menu.line_height + yos,
                y - i * ui.menu.line_height + yos, Color(alpha * 255, 0, 0, 0), "centerpoint")]]
            Stroke("menuttf", text[i], x + xos, y - i * ui.menu.line_height + yos,
                Color(alpha * 255, 0, 0, 0), "centerpoint")
            RenderTTF("menuttf", text[i], x + xos, x + xos, y - i * ui.menu.line_height + yos,
                y - i * ui.menu.line_height + yos, Color(alpha * 255, unpack(color)), "centerpoint")
        else
            --SetFontState("menu", "", Color(alpha * 255, unpack(ui.menu.unfocused_color)))
            --RenderText("menu", text[i], x, y - i * ui.menu.line_height + yos, ui.menu.font_size, align, "vcenter")
            --[[ui.Stroke("menuttf", text[i], x + 2, y - i * ui.menu.line_height + yos,
                Color(alpha * 255, 0, 0, 0), "centerpoint")
            RenderTTF("menuttf", text[i], x + 2, x + 2, y - i * ui.menu.line_height + yos, y - i * ui.menu.line_height +
                yos, Color(alpha * 255, 0, 0, 0), "centerpoint")]]
            Stroke("menuttf", text[i], x, y - i * ui.menu.line_height + yos,
                Color(alpha * 255, 0, 0, 0), "centerpoint")
            RenderTTF("menuttf", text[i], x, x, y - i * ui.menu.line_height + yos, y - i * ui.menu.line_height + yos,
                Color(alpha * 255, unpack(ui.menu.unfocused_color)), "centerpoint")
        end
    end
end

function ui.DrawMenuTTF(ttfname, title, text, pos, x, y, alpha, timer, shake, align)
    align = align or "center"
    local yos
    if title == "" then
        yos = (#text + 1) * ui.menu.sc_pr_line_height * 0.5
    else
        yos = (#text - 1) * ui.menu.sc_pr_line_height * 0.5
        RenderTTF(ttfname, title, x, x, y + yos + ui.menu.sc_pr_line_height, y + yos + ui.menu.sc_pr_line_height,
            Color(alpha * 255, unpack(ui.menu.title_color)), align, "vcenter", "noclip")
    end
    for i = 1, #text do
        if i == pos then
            local color = {}
            local k = cos(timer * ui.menu.blink_speed) ^ 2
            for j = 1, 3 do
                color[j] = ui.menu.focused_color1[j] * k + ui.menu.focused_color2[j] * (1 - k)
            end
            local xos = ui.menu.shake_range * sin(ui.menu.shake_speed * shake)
            RenderTTF(ttfname, text[i], x + xos, x + xos, y - i * ui.menu.sc_pr_line_height + yos,
                y - i * ui.menu.sc_pr_line_height + yos, Color(alpha * 255, unpack(color)), align, "vcenter", "noclip")
        else
            RenderTTF(ttfname, text[i], x, x, y - i * ui.menu.sc_pr_line_height + yos,
                y - i * ui.menu.sc_pr_line_height + yos, Color(alpha * 255, unpack(ui.menu.unfocused_color)), align,
                "vcenter", "noclip")
        end
    end
end

function ui.DrawMenuTTFBlack(ttfname, title, text, pos, x, y, alpha, timer, shake, align)
    align = align or "center"
    local yos
    if title == "" then
        yos = (#text + 1) * ui.menu.sc_pr_line_height * 0.5
    else
        yos = (#text - 1) * ui.menu.sc_pr_line_height * 0.5
        RenderTTF(ttfname, title, x, x, y + yos + ui.menu.sc_pr_line_height, y + yos + ui.menu.sc_pr_line_height,
            Color(0xFF000000), align, "vcenter", "noclip")
    end
    for i = 1, #text do
        if i == pos then
            local xos = ui.menu.shake_range * sin(ui.menu.shake_speed * shake)
            RenderTTF(ttfname, text[i], x + xos, x + xos, y - i * ui.menu.sc_pr_line_height + yos,
                y - i * ui.menu.sc_pr_line_height + yos, Color(0xFF000000), align, "vcenter", "noclip")
        else
            RenderTTF(ttfname, text[i], x, x, y - i * ui.menu.sc_pr_line_height + yos,
                y - i * ui.menu.sc_pr_line_height + yos, Color(0xFF000000), align, "vcenter", "noclip")
        end
    end
end

function ui.DrawRepText(ttfname, title, text, pos, x, y, alpha, timer, shake)
    local yos
    if title == "" then
        yos = (#text + 1) * ui.menu.sc_pr_line_height * 0.5
    else
        yos = (#text - 1) * ui.menu.sc_pr_line_height * 0.5
        Render(title, x, y + ui.menu.sc_pr_line_height + yos)
        --		RenderTTF(ttfname,title,x,x,y+yos+ui.menu.sc_pr_line_height+1,y+yos+ui.menu.sc_pr_line_height-1,Color(0xFF000000),"center","vcenter","noclip")
        --		RenderTTF(ttfname,title,x,x,y+yos+ui.menu.sc_pr_line_height,y+yos+ui.menu.sc_pr_line_height,Color(255,unpack(ui.menu.title_color)),"center","vcenter","noclip")
    end
    local _text = text
    local xos = { -300, -240, -120, 20, 130, 240 }
    for i = 1, #_text do
        if i == pos then
            local color = {}
            local k = cos(timer * ui.menu.blink_speed) ^ 2
            for j = 1, 3 do
                color[j] = ui.menu.focused_color1[j] * k + ui.menu.focused_color2[j] * (1 - k)
            end
            --			local xos=ui.menu.shake_range*sin(ui.menu.shake_speed*shake)
            SetFontState("replay", "", Color(0xFFFFFF30))
            --			RenderTTF(ttfname,text[i],x+xos,x+xos,y-i*ui.menu.sc_pr_line_height+yos,y-i*ui.menu.sc_pr_line_height+yos,Color(alpha*255,unpack(color)),align,"vcenter","noclip")
            for m = 1, 6 do
                RenderText("replay", _text[i][m], x + xos[m], y - i * ui.menu.rep_line_height + yos,
                    ui.menu.rep_font_size, "vcenter", "left")
            end
        else
            SetFontState("replay", "", Color(0xFF808080))
            --			RenderTTF(ttfname,text[i],x,x,y-i*ui.menu.sc_pr_line_height+yos,y-i*ui.menu.sc_pr_line_height+yos,Color(alpha*255,unpack(ui.menu.unfocused_color)),align,"vcenter","noclip")
            for m = 1, 6 do
                RenderText("replay", _text[i][m], x + xos[m], y - i * ui.menu.rep_line_height + yos,
                    ui.menu.rep_font_size, "vcenter", "left")
            end
        end
    end
end

function ui.DrawRepText2(ttfname, title, text, pos, x, y, alpha, timer, shake)
    local yos
    if title == "" then
        yos = (#text + 1) * ui.menu.sc_pr_line_height * 0.5
    else
        yos = (#text - 1) * ui.menu.sc_pr_line_height * 0.5
        Render(title, x, y + ui.menu.sc_pr_line_height + yos)
        --		RenderTTF(ttfname,title,x,x,y+yos+ui.menu.sc_pr_line_height+1,y+yos+ui.menu.sc_pr_line_height-1,Color(0xFF000000),"center","vcenter","noclip")
        --		RenderTTF(ttfname,title,x,x,y+yos+ui.menu.sc_pr_line_height,y+yos+ui.menu.sc_pr_line_height,Color(255,unpack(ui.menu.title_color)),"center","vcenter","noclip")
    end
    local _text = text
    local xos = { -80, 120 }
    for i = 1, #_text do
        if i == pos then
            local color = {}
            local k = cos(timer * ui.menu.blink_speed) ^ 2
            for j = 1, 3 do
                color[j] = ui.menu.focused_color1[j] * k + ui.menu.focused_color2[j] * (1 - k)
            end
            --			local xos=ui.menu.shake_range*sin(ui.menu.shake_speed*shake)
            SetFontState("replay", "", Color(0xFFFFFF30))
            --			RenderTTF(ttfname,text[i],x+xos,x+xos,y-i*ui.menu.sc_pr_line_height+yos,y-i*ui.menu.sc_pr_line_height+yos,Color(alpha*255,unpack(color)),align,"vcenter","noclip")
            RenderText("replay", _text[i][1], x + xos[1], y - i * ui.menu.rep_line_height + yos, ui.menu.rep_font_size,
                "vcenter", "center")
            RenderText("replay", _text[i][2], x + xos[2], y - i * ui.menu.rep_line_height + yos, ui.menu.rep_font_size,
                "vcenter", "right")
        else
            SetFontState("replay", "", Color(0xFF808080))
            --			RenderTTF(ttfname,text[i],x,x,y-i*ui.menu.sc_pr_line_height+yos,y-i*ui.menu.sc_pr_line_height+yos,Color(alpha*255,unpack(ui.menu.unfocused_color)),align,"vcenter","noclip")
            RenderText("replay", _text[i][1], x + xos[1], y - i * ui.menu.rep_line_height + yos, ui.menu.rep_font_size,
                "vcenter", "center")
            RenderText("replay", _text[i][2], x + xos[2], y - i * ui.menu.rep_line_height + yos, ui.menu.rep_font_size,
                "vcenter", "right")
        end
    end
end

local function formatnum(num)
    local sign = sign(num)
    num = abs(num)
    local tmp = {}
    local var
    while num >= 1000 do
        var = num - int(num / 1000) * 1000
        table.insert(tmp, 1, string.format("%03d", var))
        num = int(num / 1000)
    end
    table.insert(tmp, 1, tostring(num))
    var = table.concat(tmp, ",")
    if sign < 0 then
        var = string.format("-%s", var)
    end
    return var, #tmp - 1
end
function RenderScore(fontname, score, x, y, size, mode)
    if score < 100000000000 then
        RenderText(fontname, formatnum(score), x, y, size, mode)
    else
        RenderText(fontname, string.format("99,999,999,999"), x, y, size, mode)
    end
end

---@class lstg.lstg_ui_object
lstg.lstg_ui_object = Class(object)
function lstg.lstg_ui_object:init()
    _lstg_ui = self
    self.layer = LAYER_TOP + 1
    if lstg.ui then
        self.ui = lstg.ui
    else
        lstg.ui = lstg.lstg_ui()
        self.ui = lstg.ui
    end
    self.ui.hide_timer = 0 --闪避条用的计时器之一
    self.ui.timer = 0      --闪避条用到计时器之二
    self.layer = LAYER_PLAYER - 5
    self.ui.alpha = 255
    self.ui.player_pointer = New(aic.ui.player_pointer)
end

function lstg.lstg_ui_object:frame()
    task.Do(self)
    if int(lstg.var.exmp / 100) > lstg.var.exmp_int and not self.exmp_sign then
        task.New(self, function()
            self.exmp_sign = true
            PlaySound('aic_exmp', 1)
            for _ = 1, 25 do
                lstg.var.exmp_int = lstg.var.exmp_int + 1 / 25
                task.Wait()
            end
            self.exmp_sign = false
        end)
    end
    self.ui.timer = self.ui.timer + 1
    if BoxCheck(player, -192, -80, -224, -180) then
        self.ui.hide_timer = min(self.ui.hide_timer + 1, 15)
        self.ui.alpha = 255 - 155 / 15 * self.ui.hide_timer
    else
        self.ui.hide_timer = max(0, self.ui.hide_timer - 1)
        self.ui.alpha = 255 - 155 / 15 * self.ui.hide_timer
    end
end

function lstg.lstg_ui_object:render()
    if not CloseUI then
        self.ui:drawFrame()
        self.ui:drawScore()
    end
end

---@class lstg.lstg_ui
---@return lstg.lstg_ui
lstg.lstg_ui = plus.Class()
local lstg_ui = lstg.lstg_ui

local res_list = {
    ["tex"] = {
        "logo",
        "ui_bg",
        "ui_bg2",
        "menu_bg",
        "menu_bg2",
        integer = 1,
    },
    ["img"] = {
        "logo",
        "ui_bg",
        "ui_bg2",
        "menu_bg",
        "menu_bg2",
        integer = 2,
    },
}
function lstg_ui:reloadUI()
    for type, list in pairs(res_list) do
        for _, res in pairs(list) do
            if CheckRes(type, res) == "global" then
                RemoveResource("global", list.integer, res)
            end
        end
    end
    local pool = GetResourceStatus() or "global"
    SetResourceStatus("global")
    if self.type == 1 then
        LoadImageFromFile("logo", "THlib/UI/logo.png")
        SetImageCenter("logo", 0, 64)
        LoadImageFromFile("ui_bg", "THlib/UI/ui_bg.png")
        LoadImageFromFile("menu_bg", "THlib/UI/menu_bg.png")
    elseif self.type == 2 then
        LoadImageFromFile("logo", "THlib/UI/logo.png")
        SetImageCenter("logo", 0, 64)
        LoadImageFromFile("ui_bg", "THlib/UI/ui_bg.png")
        LoadImageFromFile("ui_bg2", "THlib/UI/ui_bg_2.png")
        LoadImageFromFile("menu_bg", "THlib/UI/menu_bg.png")
        LoadImageFromFile("menu_bg2", "THlib/UI/menu_bg_2.png")
    end
    SetResourceStatus(pool)
end

function lstg_ui:init()
    if setting.resx > setting.resy then
        self.type = 1
    else
        self.type = 2
    end
    self._dx = 0
    self.bgdx = -29
    self.logodx = 20
    self.s = 0.8
    self:reloadUI()
end

function lstg_ui:drawFrame()
    self["drawFrame" .. self.type](self)
end

function lstg_ui:drawFrame1()
    SetViewMode "ui"
    local w = lstg.world
    local x = (w.scrr - w.scrl) / 2 + w.scrl
    local y = (w.scrt - w.scrb) / 2 + w.scrb
    local hs = (w.scrr - w.scrl) / 384
    local vs = (w.scrt - w.scrb) / 448
    local dx = self._dx
    local bgdx = self.bgdx
    local logodx = self.logodx
    x = x + 96 * hs
    if CheckRes("img", "image:UI_img") then
        Render("image:UI_img", x + bgdx, y, 0, hs, vs)
    else
        Render("ui_bg", x + bgdx, y, 0, hs, vs)
    end
    if CheckRes("img", "image:LOGO_img") then
        Render("image:LOGO_img", -16 + w.scrr - 48 + logodx, 165, 0, 0.7 * self.s, 0.7 * self.s)
    else
        Render("logo", -16 + w.scrr - 48 + logodx, 165 - 45, 0, 0.7 * self.s, 0.7 * self.s)
    end
    SetFontState("menu", "", Color(0xFFFFFFFF))
    RenderText("menu",
        string.format("%.1ffps", GetFPS()),
        220 + w.scrr + dx, 1, 0.25 * self.s, "right", "bottom")
    SetViewMode "world"
end

function lstg_ui:drawFrame2()
    local dx = self._dx
    SetViewMode "ui"
    Render("ui_bg2", 198 + dx, 264)
    SetViewMode "world"
end

function lstg_ui:drawMenuBG()
    self["drawMenuBG" .. self.type](self)
end

function lstg_ui:drawMenuBG1()
    local dx = self._dx
    SetViewMode "ui"
    Render("menu_bg", 320 + dx, 240, 0, 0.5)
    SetFontState("menu", "", Color(0xFFFFFFFF))
    RenderText("menu",
        string.format("%.1ffps", GetFPS()),
        636 + dx, 1, 0.25, "right", "bottom")
    SetViewMode "world"
end

function lstg_ui:drawMenuBG2()
    local dx = self._dx
    SetViewMode "ui"
    Render("menu_bg2", 198 + dx, 264)
    SetFontState("menu", "", Color(0xFFFFFFFF))
    RenderText("menu",
        string.format("%.1ffps", GetFPS()),
        392 + dx, 1, 0.25, "right", "bottom")
    SetViewMode "world"
end

function lstg_ui:ScoreUpdate()
    local var = lstg.var
    local cur_score = var.score
    local score = self.score or cur_score
    local score_tmp = self.score_tmp or cur_score
    if score_tmp < cur_score then
        if cur_score - score_tmp <= 100 then
            score = score + 10
        elseif cur_score - score_tmp <= 1000 then
            score = score + 100
        else
            score = int(score / 10 + int((cur_score - score_tmp) / 600)) * 10 + cur_score % 10
        end
    end
    if score_tmp > cur_score then
        score_tmp = cur_score
        score = cur_score
    end
    if score >= cur_score then
        score_tmp = cur_score
        score = cur_score
    end
    self.score = score
    self.score_tmp = score_tmp
end

function lstg_ui:drawScore()
    self:ScoreUpdate()
    self["drawScore" .. self.type](self)
end

function lstg_ui:drawScore1()
    SetViewMode "ui"
    self:drawDifficulty()
    self:drawInfo1()
    SetViewMode "world"
end

function lstg_ui:drawScore2()
    SetViewMode "ui"
    self:drawInfo2()
    SetViewMode "world"
end

function lstg_ui:drawDifficulty()
    local dx = self._dx
    SetFontState("score3", "", Color(0xFFADADAD))
    local w = lstg.world
    local diff = string.match(stage.current_stage.name, "[%w_][%w_ ]*$")
    local diffimg = CheckRes("img", "image:diff_" .. diff)
    if diffimg then
        Render("image:diff_" .. diff, 112 + w.scrr + dx, 448, self.s)
    else
        --by OLC，难度显示加入符卡练习
        if ext.sc_pr and diff == "Spell Practice" and lstg.var.sc_index then
            diff = _editor_class[_sc_table[lstg.var.sc_index][1]].difficulty
            if diff == "All" then
                diff = "SpellCard"
            end
        end
        local x1 = -192 + w.scrr + dx
        local x2 = 112 + w.scrr - 15
        local y1 = 457
        local y2 = 448
        local dy = 22
        local s = stage.current_stage
        local timer = s.timer
        local a, t = 255, 1
        local x, y = x2, y2
        if lstg.var.is_parctice or s.number == 1 then
            if timer < 60 then
                x, y = x1, y1
                dy = 11
                a = int(timer / 4) % 2 * 255
            elseif timer >= 60 and timer < 150 then
                x, y = x1, y1
                dy = 11
            elseif timer >= 150 and timer < 158 then
                x, y = x1, y1
                dy = 11
                t = max((1 - (timer - 150) / 8), 0)
                a = t * 255
            elseif timer >= 158 and timer < 165 then
                t = min((timer - 158) / 9, 1)
                a = t * 255
            end
        end
        --[[
        if diff == "Easy" or diff == "Normal" or diff == "Hard" or diff == "Lunatic" or diff == "Extra" then
            SetImageState("rank_" .. diff, "", Color(a, 255, 255, 255))
            Render("rank_" .. diff, x, y, 0, 0.5 * self.s, t * 0.5 * self.s)
        else
            SetFontState("menu", "", Color(a, 255, 255, 255))
            RenderText("menu", diff, x, y + dy, 0.5 * self.s, "center")
        end
        ]]
        SetImageState("rank_AliceInCradle", "", Color(a, 255, 255, 255))
        Render("rank_AliceInCradle", x, y + 10, 0, 0.5 * self.s, t * 0.5 * self.s)
    end
end

function lstg_ui:drawInfo1()
    local dx = self._dx
    local dx2 = -30
    local dy = 15
    local w = lstg.world
    local RenderImgList = {
        { "line_1",       109 + w.scrr + dx, 419 + dy, 0, 1,   1 },
        { "line_2",       109 + w.scrr + dx, 397 + dy, 0, 1,   1 },
        { "line_3",       109 + w.scrr + dx, 349 + dy, 0, 1,   1 },
        { "line_4",       109 + w.scrr + dx, 247 + dy, 0, 1,   1 },
        { "line_5",       109 + w.scrr + dx, 311 + dy, 0, 1,   1 },
        { "line_6",       109 + w.scrr + dx, 224 + dy, 0, 1,   1 },
        { "line_7",       109 + w.scrr + dx, 202 + dy, 0, 1,   1 },
        { "hint.hiscore", 12 + w.scrr + dx,  425 + dy, 0, 0.6, 0.6 },
        { "hint.score",   10 + w.scrr + dx,  403 + dy, 0, 0.6, 0.6 },
        { "hint.Pnumber", -8 + w.scrr + dx,  371 + dy, 0, 0.7, 0.7 },
        { "hint.Bnumber", 5 + w.scrr + dx,   278 + dy, 0, 0.6, 0.6 },
        --{ "hint.Cnumber", 138 + w.scrr + dx, 316, 0, 0.85, 0.85 },
        --{ "hint.Cnumber", 138 + w.scrr + dx, 354, 0, 0.85, 0.85 },
        { "hint.power",   -8 + w.scrr + dx,  328 + dy, 0, 0.7, 0.7 },
        { "hint.point",   6 + w.scrr + dx,   230 + dy, 0, 0.6, 0.6 },
        { "hint.graze",   22 + w.scrr + dx,  208 + dy, 0, 0.5, 0.5 }
    }
    local s = stage.current_stage
    local timer = s.timer
    local alplat
    if (lstg.var.is_parctice or s.number == 1) and timer < 448 then
        local alpharate = 4
        local alphatrate = 1
        local timerrate = 3
        local y0 = 448 - timer * timerrate
        local dyt = max(300 - y0, 0)
        for i = 1, #RenderImgList do
            local p1, p2, p3, p4, p5, p6 = unpack(RenderImgList[i])
            local dy = max(p3 - y0, 0)
            local alpha = min(dy * alpharate, 255)
            local dw = 1
            if string.find(p1, "line_") then
                dw = alpha / 255
            end
            SetImageState(p1, "", Color(alpha, 255, 255, 255))
            Render(p1, p2, p3, p4, p5 * dw * self.s, p6 * self.s)
        end
        alplat = min(dyt * alphatrate, 255)
    else
        for i = 1, #RenderImgList do
            local p1, p2, p3, p4, p5, p6 = unpack(RenderImgList[i])
            SetImageState(p1, "", Color(255, 255, 255, 255))
            Render(p1, p2, p3, p4, p5 * self.s, p6 * self.s)
        end
        alplat = 255
    end
    SetFontState("score3", "", Color(alplat, 173, 173, 173))
    RenderScore("score3", max(lstg.tmpvar.hiscore or 0, self.score or 0), 216 + w.scrr + dx + dx2, 436 + dy, 0.43 * self.s, "right")
    SetFontState("score3", "", Color(alplat, 255, 255, 255))
    RenderScore("score3", self.score or 0, 216 + w.scrr + dx + dx2, 414 + dy, 0.43 * self.s, "right")
    --[[RenderText("score3", string.format("%d/5", lstg.var.chip), 214 + w.scrr, 361, 0.35, "right")
    RenderText("score3", string.format("%d/5", lstg.var.bombchip), 214 + w.scrr, 323, 0.35, "right")
    SetFontState("score1", "", Color(alplat, 205, 102, 0))
    SetFontState("score2", "", Color(alplat, 34, 216, 221))
    RenderText("score1", string.format("%d.    /4.    ", math.floor(lstg.var.power / 100)), 204 + w.scrr, 262, 0.4,
        "right")
    RenderText("score1",
        string.format("      %d%d        00", math.floor((lstg.var.power % 100) / 10), lstg.var.power % 10), 205 + w.scrr, 258.5, 0.3, "right")]]
    RenderScore("score2", lstg.var.pointrate, 204 + w.scrr + dx + dx2, 239 + dy, 0.4 * self.s, "right")
    SetFontState("score3", "", Color(alplat, 173, 173, 173))
    RenderText("score3", string.format("%d", lstg.var.graze), 204 + w.scrr + dx + dx2, 216 + dy, 0.4 * self.s, "right")
    local p1, p2, p3, p5, p6, p7, p4 = lstg.var.hp / 400, lstg.var.power / 500, lstg.var.maxpower / 500, lstg.var.maxhp / 400, lstg.var.temp_hp / 400, lstg.var.maxpower2 / 500
    if lstg.var.mp_active then p4 = lstg.var.mp_active / 5 end
    local white = color()
    local y1 = (371 + dy)
    local y2 = (329 + dy)
    local x = (63 + w.scrr + dx + dx2)
    local dx3 = 15
    local bar_w = bar_w * self.s + dx3
    RenderTexture('hint_AiC_bar_empty', '',
        { x + dx3, y1 + bar_h / 2, 0.5, 0, 0, white },
        { x + bar_w + dx3, y1 + bar_h / 2, 0.5, bar_tw, 0, white },
        { x + bar_w + dx3, y1 - bar_h / 2, 0.5, bar_tw, bar_th, white },
        { x + dx3, y1 - bar_h / 2, 0.5, 0, bar_th, white })
    RenderTexture('hint_AiC_bar_hp', '',
        { x + dx3, y1 + bar_h / 2, 0.5, 0, 0, white },
        { x + bar_w * p1 + dx3, y1 + bar_h / 2, 0.5, bar_tw * p1, 0, white },
        { x + bar_w * p1 + dx3, y1 - bar_h / 2, 0.5, bar_tw * p1, bar_th, white },
        { x + dx3, y1 - bar_h / 2, 0.5, 0, bar_th, white })
    RenderTexture('hint_AiC_bar_temp_hp', '',
        { x + bar_w * p1 + dx3, y1 + bar_h / 2, 0.5, bar_tw * p1, 0, white },
        { x + bar_w * (p1 + p6) + dx3, y1 + bar_h / 2, 0.5, bar_tw * (p1 + p6), 0, white },
        { x + bar_w * (p1 + p6) + dx3, y1 - bar_h / 2, 0.5, bar_tw * (p1 + p6), bar_th, white },
        { x + bar_w * p1 + dx3, y1 - bar_h / 2, 0.5, bar_tw * p1, bar_th, white })
    RenderTexture('hint_AiC_bar_gap', '',
        { x + bar_w * p5 + dx3, y1 + bar_h / 2, 0.5, bar_tw * p5, 0, white },
        { x + bar_w + dx3, y1 + bar_h / 2, 0.5, bar_tw, 0, white },
        { x + bar_w + dx3, y1 - bar_h / 2, 0.5, bar_tw, bar_th, white },
        { x + bar_w * p5 + dx3, y1 - bar_h / 2, 0.5, bar_tw * p5, bar_th, white })
    RenderTexture('hint_AiC_bar_empty', '',
        { x + dx3, y2 + bar_h / 2, 0.5, 0, 0, white },
        { x + bar_w + dx3, y2 + bar_h / 2, 0.5, bar_tw, 0, white },
        { x + bar_w + dx3, y2 - bar_h / 2, 0.5, bar_tw, bar_th, white },
        { x + dx3, y2 - bar_h / 2, 0.5, 0, bar_th, white })
    if lstg.var.mp_active then
        RenderTexture('hint_AiC_bar_mp_active', '',
            { x + dx3, y2 + bar_h / 2, 0.5, 0, 0, white },
            { x + bar_w * p4 + dx3, y2 + bar_h / 2, 0.5, bar_tw * p4, 0, white },
            { x + bar_w * p4 + dx3, y2 - bar_h / 2, 0.5, bar_tw * p4, bar_th, white },
            { x + dx3, y2 - bar_h / 2, 0.5, 0, bar_th, white })
        RenderTexture('hint_AiC_bar_seperate', '',
            { x + dx3, y2 + bar_h / 2, 0.5, 0, 0, white },
            { x + bar_w * p4 + dx3, y2 + bar_h / 2, 0.5, bar_tw * p4, 0, white },
            { x + bar_w * p4 + dx3, y2 - bar_h / 2, 0.5, bar_tw * p4, bar_th, white },
            { x + dx3, y2 - bar_h / 2, 0.5, 0, bar_th, white })
        SetFontState('score', '', Color(alplat, 160, 255, 239))
        RenderText('score', lstg.var.mp_active .. ' / 5', x + 22 + dx3, y2 - 5, 0.25 * self.s, 'centerpoint')
    else
        RenderTexture('hint_AiC_bar_mp', '',
            { x + dx3, y2 + bar_h / 2, 0.5, 0, 0, white },
            { x + bar_w * p2 + dx3, y2 + bar_h / 2, 0.5, bar_tw * p2, 0, white },
            { x + bar_w * p2 + dx3, y2 - bar_h / 2, 0.5, bar_tw * p2, bar_th, white },
            { x + dx3, y2 - bar_h / 2, 0.5, 0, bar_th, white })
        RenderTexture('hint_AiC_bar_broken', '',
            { x + bar_w * p3 + dx3, y2 + bar_h / 2, 0.5, bar_tw * p3, 0, white },
            { x + bar_w + dx3, y2 + bar_h / 2, 0.5, bar_tw, 0, white },
            { x + bar_w + dx3, y2 - bar_h / 2, 0.5, bar_tw, bar_th, white },
            { x + bar_w * p3 + dx3, y2 - bar_h / 2, 0.5, bar_tw * p3, bar_th, white })
        RenderTexture('hint_AiC_bar_broken2', '',
            { x + bar_w * p7 + dx3, y2 + bar_h / 2, 0.5, bar_tw * p7, 0, white },
            { x + bar_w + dx3, y2 + bar_h / 2, 0.5, bar_tw, 0, white },
            { x + bar_w + dx3, y2 - bar_h / 2, 0.5, bar_tw, bar_th, white },
            { x + bar_w * p7 + dx3, y2 - bar_h / 2, 0.5, bar_tw * p7, bar_th, white })
        SetFontState('score', '', Color(alplat, 255, 255, 255))
        RenderText('score', int(lstg.var.power) .. ' / 500', x + 22 + dx3, y2 - 5, 0.25 * self.s, 'centerpoint')
    end
    SetFontState('score', '', Color(alplat, 255, 255, 255))
    RenderText('score', int(lstg.var.hp) .. ' / ' .. lstg.var.maxhp, x + 22 + dx3, y2 + 37, 0.25 * self.s, 'centerpoint')
    local s = squ_w / squ_tw * self.s
    local x = (90 + w.scrr + dx)
    local y = (278 + dy)
    local dx = squ_w * 0.6 * self.s
    local dy = squ_h * 0.5 * self.s
    local dx3 = -15
    SetImageState('hint_AiC_square_empty', '', white)
    SetImageState('hint_AiC_square_empty_green', '', white)
    for i = 0, 7 do
        Render('hint_AiC_square_empty', x + i * dx + dx3, y + cos(180 * i) * dy, 0, s)
        if (i + 1) * 100 <= lstg.var.exmp then
            Render('hint_AiC_square_empty_green', x + i * dx + dx3, y + cos(180 * i) * dy, 0, s)
            if i + 1 <= int(lstg.var.exmp / 100) then
                if i + 1 <= lstg.var.exmp_int then
                    Render('hint_AiC_square_middle_green', x + i * dx + dx3, y + cos(180 * i) * dy, 0, s)
                else
                    Render('hint_AiC_square_middle_green', x + i * dx + dx3, y + cos(180 * i) * dy, 0,
                        s * (lstg.var.exmp_int - i))
                end
            end
        end
    end
    local i = int(lstg.var.exmp / 100)
    local p = lstg.var.exmp % 100 / 100
    RenderTexture('hint_AiC_square_empty_green', '',
        { x + i * dx - squ_w / 2 + dx3, y + cos(180 * i) * dy + squ_h * (p - 0.5), 0.5, 0, squ_th * (1 - p), white },
        { x + i * dx + squ_w / 2 + dx3, y + cos(180 * i) * dy + squ_h * (p - 0.5), 0.5, squ_tw, squ_th * (1 - p), white },
        { x + i * dx + squ_w / 2 + dx3, y + cos(180 * i) * dy - squ_h / 2, 0.5, squ_tw, squ_th, white },
        { x + i * dx - squ_w / 2 + dx3, y + cos(180 * i) * dy - squ_h / 2, 0.5, 0, squ_th, white })

    if lstg.var.enhancer_overload then
        Render('hint_enhancer2', x - 55, y - 100, 0, 0.6 * self.s)
    else
        Render('hint_enhancer1', x - 55, y - 100, 0, 0.6 * self.s)
    end
    if lstg.var.enhancer_select then
        for k, v in ipairs(lstg.var.enhancer_select) do
            local s = 0.35
            if v >= 12 and v ~= 16 then s = s * 2 end
            --目前两行加起来最多能渲染10个插件，应该够用了
            if k <= 4 then
                Render('Muki_AiC_menu_enhancer_select' .. v, x - 40 + k * 28, y - 100, 0, s)
            else
                Render('Muki_AiC_menu_enhancer_select' .. v, x - 40 + (k - 6) * 28, y - 130, 0, s)
            end
        end
    end
    SetViewMode('world')
    local x, y, w, h, tw, th, dw = -175 + dx + dx3, -205, 80, 10, 300, 50, -5
    local p = lstg.var.dodge % 100 / 100
    if lstg.var.dodge > 0 and lstg.var.dodge % 100 == 0 then p = 1 end
    local white = Color(self.alpha, 255, 255, 255)
    local pink = Color(self.alpha, 251, 213, 228)
    --从高级循环里抄来的申必写法（正弦式变化）
    local r1, g1, b1, r2, g2, b2 = 67, 193, 229, 157, 113, 170
    local _h_r, _t_r, _h_g, _t_g, _h_b, _t_b = (r2 - r1) / 2, (r2 + r1) / 2, (g2 - g1) / 2, (b2 + b1) / 2, (b2 - b1) / 2,
        (b2 + b1) / 2
    local r, g, b = _h_r * sin(5 * self.timer) + _t_r, _h_g * sin(5 * self.timer) + _t_g,
        _h_b * sin(5 * self.timer) + _t_b
    local blue_purple = Color(self.alpha, r, g, b)
    RenderTexture('hint_AiC_dodge_bar_empty', '',
        { x, y + h / 2 + 1, 0.5, 0, 0, white },
        { x + w + 2, y + h / 2 + 1, 0.5, tw + 2, 0, white },
        { x + (w + dw + 1), y - h / 2 - 1, 0.5, tw + 2, th + 2, white },
        { x, y - h / 2 - 1, 0.5, 0, th + 2, white })
    DrawText('boss_name', lstg.var.dodge .. '%', x + w, y + h / 2 + 10, 0.75 * self.s, white, nil, 'right')
    if lstg.var.dodge > 100 then
        if player.nextsp <= 0 then
            DrawText('boss_name', 'Available!!', x + w / 2 + 10, y + h / 2 + 10, 0.75 * self.s, blue_purple, nil, 'right')
        end
        SetImageState('white', '', pink)
        Render4V('white',
            x, y + h / 2, 0.5,
            x + w, y + h / 2, 0.5,
            x + w + dw, y - h / 2, 0.5,
            x, y - h / 2, 0.5
        )
        SetImageState('hint_AiC_square_empty', '', blue_purple)
        SetImageState('hint_AiC_square_middle', '', blue_purple)
    elseif lstg.var.dodge >= 75 and CheckEnhancer(3) and player.nextsp <= 0 then
        DrawText('boss_name', 'Available!!', x + w / 2 + 10, y + h / 2 + 10, 0.75 * self.s, blue_purple, nil, 'right')
        SetImageState('hint_AiC_square_empty', '', blue_purple)
        SetImageState('hint_AiC_square_middle', '', blue_purple)
    else
        SetImageState('hint_AiC_square_empty', '', white)
        SetImageState('hint_AiC_square_middle', '', white)
    end
    RenderTexture('hint_AiC_dodge_bar', '',
        { x, y + h / 2, 0.5, 0, 0, white },
        { x + w * p, y + h / 2, 0.5, tw * p, 0, white },
        { x + (w + dw) * p, y - h / 2, 0.5, (tw + dw / w * tw) * p, th, white },
        { x, y - h / 2, 0.5, 0, th, white })
    
    Render('hint_AiC_square_empty', x, y, 0, s * self.s)
    Render('hint_AiC_square_middle', x, y, 0, s * self.s)
    SetImageState('hint_AiC_dodge_icon', '', white)
    Render('hint_AiC_dodge_icon', x, y, 0, 0.4 * self.s)
    SetViewMode('ui')

    --[[SetImageState("hint.life", "", Color(alplat, 255, 255, 255))
    for i = 1, 8 do
        Render("hint.life", 89 + w.scrr + 13 * i, 371, 0, 1, 1)
    end
    SetImageState("hint.lifeleft", "", Color(alplat, 255, 255, 255))
    for i = 1, lstg.var.lifeleft do
        Render("hint.lifeleft", 89 + w.scrr + 13 * i, 371, 0, 1, 1)
    end
    SetImageState("hint.bomb", "", Color(alplat, 255, 255, 255))
    for i = 1, 8 do
        Render("hint.bomb", 89 + w.scrr + 13 * i, 334, 0, 1, 1)
    end
    SetImageState("hint.bombleft", "", Color(alplat, 255, 255, 255))
    for i = 1, lstg.var.bomb do
        Render("hint.bombleft", 89 + w.scrr + 13 * i, 334, 0, 1, 1)
    end
    local Lchip = lstg.var.chip
    if Lchip > 0 and Lchip < 5 and lstg.var.lifeleft < 8 then
        SetImageState("lifechip" .. Lchip, "", Color(alplat, 255, 255, 255))
        Render("lifechip" .. Lchip, 89 + w.scrr + 13 * (lstg.var.lifeleft + 1), 371, 0, 1, 1)
    end
    local Bchip = lstg.var.bombchip
    if Bchip > 0 and Bchip < 5 and lstg.var.bomb < 8 then
        SetImageState("bombchip" .. Bchip, "", Color(alplat, 255, 255, 255))
        Render("bombchip" .. Bchip, 89 + w.scrr + 13 * (lstg.var.bomb + 1), 334, 0, 1, 1)
    end]]
    --有谁能解释一下这为什么要渲染两遍吗
    --[=[SetFontState("score3", "", Color(alplat, 173, 173, 173))
    RenderScore("score3", max(lstg.tmpvar.hiscore or 0, self.score or 0), 216 + w.scrr, 436 + dy2, 0.43, "right")
    SetFontState("score3", "", Color(alplat, 255, 255, 255))
    RenderScore("score3", self.score or 0, 216 + w.scrr, 414 + dy2, 0.43, "right")
    --[[RenderText("score3", string.format("%d/5", lstg.var.chip), 214 + w.scrr, 361, 0.35, "right")
    RenderText("score3", string.format("%d/5", lstg.var.bombchip), 214 + w.scrr, 323, 0.35, "right")
    SetFontState("score1", "", Color(alplat, 205, 102, 0))
    SetFontState("score2", "", Color(alplat, 34, 216, 221))
    RenderText("score1", string.format("%d.    /4.    ", math.floor(lstg.var.power / 100)), 204 + w.scrr, 262, 0.4,
        "right")
    RenderText("score1",
        string.format("      %d%d        00", math.floor((lstg.var.power % 100) / 10), lstg.var.power % 10), 205 + w.scrr, 258.5, 0.3, "right")]]
    RenderScore("score2", lstg.var.pointrate, 204 + w.scrr, 239 + dy2, 0.4, "right")
    SetFontState("score3", "", Color(alplat, 255, 255, 255))
    RenderText("score3", string.format("%d", lstg.var.graze), 204 + w.scrr, 216 + dy2, 0.4, "right")
    ]=]
end

function lstg_ui:drawInfo2()
    local dx = self._dx
    RenderText("score", "HiScore", 8 + dx, 520, 0.5, "left", "top")
    RenderText("score",
        string.format("%d", max(lstg.tmpvar.hiscore or 0, lstg.var.score)),
        190 + dx, 520, 0.5, "right", "top")
    RenderText("score", "Score", 206 + dx, 520, 0.5, "left", "top")
    RenderText("score",
        string.format("%d", lstg.var.score),
        388 + dx, 520, 0.5, "right", "top")
    SetFontState("score", "", Color(0xFFFF4040))
    --[[RenderText("score",
        string.format("%1.2f", lstg.var.power / 100),
        8, 496, 0.5, "left", "top")]]
    SetFontState("score", "", Color(0xFF40FF40))
    RenderText("score",
        string.format("%d", lstg.var.faith),
        84 + dx, 496, 0.5, "left", "top")
    SetFontState("score", "", Color(0xFF4040FF))
    RenderText("score",
        string.format("%d", lstg.var.pointrate),
        160 + dx, 496, 0.5, "left", "top")
    SetFontState("score", "", Color(0xFFFFFFFF))
    RenderText("score",
        string.format("%d", lstg.var.graze),
        236 + dx, 496, 0.5, "left", "top")
    --[[RenderText("score",
        string.rep("*", max(0, lstg.var.lifeleft)),
        388, 496, 0.5, "right", "top")
    RenderText("score",
        string.rep("*", max(0, lstg.var.bomb)),
        380, 490, 0.5, "right", "top")]]
end

function ResetUI()
    lstg.ui = lstg.lstg_ui()
    function ui.DrawFrame()
    end

    function ui.DrawMenuBG()
        if lstg.ui then
            lstg.ui:drawMenuBG()
        end
    end

    function ui.DrawScore()
        if not IsValid(_lstg_ui) then
            New(lstg.lstg_ui_object)
        end
    end
end

ResetUI()
