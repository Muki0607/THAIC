if not (sp and sp.string) then
    Include "weekend/spstring.lua"
end
Include "weekend/FontSystem.lua"
Include "weekend/boss_ui.lua"
Include "weekend/Achievement.lua"
Include "weekend/recipe.lua"

local res = {
    "UI_bg000",
    "UI_bg001",
    "UI_bg002",
    "UI_bg003",
    "UI_bg004",
    "UI_EnemyMark",
    "UI_sidecheck",
    "UI_Signs",
    "Week_boss_ui",
}
local name
for i = 1, #res do
    name = res[i]
    LoadImageFromFile(name, "weekend/" .. name .. ".png")
end
for i = 1, 3 do
    name = "UI_Ti0" .. i
    LoadImageFromFile(name, name .. ".png")
end
LoadTTF("editorname", "THlib\\UI\\font\\default_ttf", 40)
LoadImageGroupFromFile("Week_lifebar",
        "weekend/Week_lifebar.png", false, 1, 2)
LoadImageGroupFromFile("Week_timebar",
        "weekend/Week_timebar.png", false, 1, 2)
LoadImageGroupFromFile("Week_Bundle_Name_bg",
        "weekend/Week_Bundle_Name_bg.png", false, 1, 3)
for i = 1, 3 do
    SetImageCenter("Week_Bundle_Name_bg" .. i, 286, 20.5)
end
SetImageState("UI_bg003", "mul+alpha", Color(107, 255, 255, 255))
SetImageState("UI_bg001", "add+rev", Color(30, 255, 255, 255))
LoadImage('_boss_spell_name_bg', "Week_boss_ui", 0, 0, 256, 36)
SetImageCenter('_boss_spell_name_bg', 256, 0)
LoadImage('_boss_pointer', "Week_boss_ui", 0, 64, 48, 16)
SetImageCenter('_boss_pointer', 24, 0)
LoadImage('_boss_sc_left', "Week_boss_ui", 64, 64, 32, 32)
SetImageState('_boss_sc_left', '', Color(0xFF80FF80))
SetImageCenter("UI_EnemyMark", 32.5, 0)

local flag1, flag2, flag3
local flag1_t = 0
local flag2_t = 0
local flag3_t = 0

local function SetFlag(f1, f2, f3)
    flag1 = f1
    flag2 = f2
    flag3 = f3
end

local function ResetFlag()
    flag1, flag2, flag3 = false, false, false
    flag1_t, flag2_t, flag3_t = 0, 0, 0
end

local function FlagFrame()
    if flag1 then
        flag1_t = max(min(flag1_t + 1, 30), 0)
    else
        flag1_t = max(min(flag1_t - 1, 30), 0)
    end
    if flag2 then
        flag2_t = max(min(flag2_t + 1, 30), 0)
    else
        flag2_t = max(min(flag2_t - 1, 30), 0)
    end
    if flag3 then
        flag3_t = max(min(flag3_t + 1, 30), 0)
    else
        flag3_t = max(min(flag3_t - 1, 30), 0)
    end
end

local t1, t2, t3
local a1, a2, a3
local rot1, rot2, rot3
local rgb1, rgb2, rgb3
local function FlagRender()
    t1 = flag1_t / 30
    t2 = flag2_t / 30
    t3 = flag3_t / 30
    a1 = 192 * t1
    a2 = 192 * t2
    a3 = 192 * t3
    rot1 = 15 * t1
    rot2 = 15 * t2
    rot3 = 15 * t3
    rgb1 = 127 + a1 / 2
    rgb2 = 127 + a2 / 2
    rgb3 = 127 + a3 / 2
    SetImageState("UI_sidecheck", "", Color(a1, 255, 0, 0))
    Render("UI_sidecheck", 64, 360, rot1, 1, t1)
    SetImageState("UI_sidecheck", "", Color(a2, 0, 0, 255))
    Render("UI_sidecheck", 64, 240, rot2, 1, t2)
    SetImageState("UI_sidecheck", "", Color(a3, 0, 255, 0))
    Render("UI_sidecheck", 64, 120, rot3, 1, t3)
    SetImageState("UI_Ti01", "", Color(255, rgb1, rgb1, rgb1))
    SetImageState("UI_Ti02", "", Color(255, rgb2, rgb2, rgb2))
    SetImageState("UI_Ti03", "", Color(255, rgb3, rgb3, rgb3))
    Render("UI_Ti01", 64, 360)
    Render("UI_Ti02", 64, 240)
    Render("UI_Ti03", 64, 120)
end

local function DrawTile(img, tx, ty)
    local w = lstg.world
    if CheckRes("img", img) then
        local tw, th = GetTextureSize(img)
        for i = -int((screen.width + 16 + tx) / tw + 0.5), int((screen.width + 16 - tx) / tw + 0.5) do
            for j = -int((screen.height + 16 + ty) / th + 0.5), int((screen.height + 16 - ty) / th + 0.5) do
                Render(img, tx + i * tw, ty + j * th)
            end
        end
    end
end

local week_time = ""
local function SetWeekTime(t)
    week_time = t
end

local editor = ""
local editor_t = 0
local function ResetEditor()
    editor = ""
    editor_t = 0
end

local function SetEditor(name)
    editor = name or ""
end

local function EditorFrame()
    if editor ~= "" then
        editor_t = editor_t + 1
    else
        editor_t = max(editor_t - 1, 0)
    end
end

local editor_x, editor_r, editor_g, editor_b
local function DrawEditor()
    editor_x = 640 - 286 * max(min((editor_t / 30), 1), 0) * 0.5
    Render("Week_Bundle_Name_bg2", editor_x, 120, 0, -0.5, 1)
    editor_r = 192 + 63 * cos(editor_t)
    editor_g = 255 * sin(editor_t / 2) ^ 2
    editor_b = 127 + 127 * sin(editor_t / 4)
    for i = 0, 4 do
        RenderTTF("editorname", editor,
                editor_x + 143 + SQRT2 * cos(45 + i * 90),
                editor_x + 143 + SQRT2 * cos(45 + i * 90),
                110 + SQRT2 * sin(45 + i * 90),
                110 + SQRT2 * sin(45 + i * 90),
                Color(255, 0, 0, 0), "bottom", "right")
    end
    RenderTTF("editorname", editor, editor_x + 143, editor_x + 143, 110, 110,
            Color(255, 255, 255, 255), "bottom", "right")
end

local function formatnum(var)
    if var < 1000 then
        return tostring(var)
    end
    local tmp = {}
    while var >= 1000 do
        table.insert(tmp, 1, string.format("%03d", var - int(var / 1000) * 1000))
        var = int(var / 1000)
    end
    table.insert(tmp, 1, var)
    local s = tmp[#tmp]
    for i = #tmp - 1, 1, -1 do
        s = string.format("%s,%s", tmp[i], s)
    end
    return s
end

local t = 0
local function DrawFrame()
    SetViewMode "ui"
    DrawTile("UI_bg004", 320, 240)
    DrawTile("UI_bg003", 0, -t / 4)
    Render("UI_bg002", 320, 240)
    DrawTile("UI_bg001", 0, t / 6)
    Render("UI_bg000", 320, 240)
    Render("UI_Signs", 320, 240)
    if CheckRes("img", "image:UI_weektime") then
        Render("image:UI_weektime", 320, 473)
    else
        FontSystem.RenderLine("score_week_dark", week_time,
                { 320, 466 }, 0.65, { cw = 10, ch = 15, align = 9 })
        FontSystem.RenderLine("score_week_time", week_time,
                { 320, 466 }, 0.5, { cw = 10, ch = 15, align = 9 })
    end
    t = t + 1
end

local var, cur_var, var_size, timer, pause
local function DrawScore()
    pause = ext.pause_menu
    if pause and pause.IsKilled and pause:IsKilled() then
        pause = false
    end
    if not (pause) then
        FlagFrame()
    end
    FlagRender()
    FontSystem.RenderLine("score_week",
            os.date("%Y-%m-%d %H:%M:%S"),
            { 4, 0 }, 0.5, { cw = 8, ch = 15, align = 8 })
    FontSystem.RenderLine("score_week",
            string.format("%.1fFPS", GetFPS()),
            { 642, 0 }, 0.5, { cw = 8, ch = 15, align = 10 })
    timer = stage.current_stage.timer
    if timer >= 3 * 20 * 60 then
        timer = string.format("%dm,%ds,%dF",
                timer / 3600,
                timer / 60 % 60,
                timer % 60)
    elseif timer >= 20 * 60 then
        timer = string.format("%ds,%dF", timer / 60, timer % 60)
    else
        timer = string.format("%dF", timer)
    end
    FontSystem.RenderLine("score_week", timer,
            { 520, 16 }, 0.35, { cw = 6, ch = 8, align = 8 })
    cur_var = max(lstg.tmpvar.hiscore or 0, lstg.var.score)
    var = cur_var
    var_size = 0.6
    while var > 10000 do
        var = (var / 1000)
        var_size = var_size * 0.85
    end
    FontSystem.RenderLine("score_week", formatnum(cur_var),
            { 640, 440 }, var_size,
            { cw = 11 * var_size / 0.6, ch = 15, align = 2 })
    cur_var = lstg.var.score
    var = cur_var
    var_size = 0.6
    while var > 10000 do
        var = (var / 1000)
        var_size = var_size * 0.85
    end
    FontSystem.RenderLine("score_week", formatnum(cur_var),
            { 640, 394 }, var_size,
            { cw = 11 * var_size / 0.6, ch = 15, align = 2 })
    cur_var = lstg.var.pointrate
    var = cur_var
    var_size = 0.6
    FontSystem.RenderLine("score_week_point", formatnum(cur_var),
            { 640, 352 }, var_size,
            { cw = 11 * var_size / 0.6, ch = 15, align = 2 })
    cur_var = lstg.var.graze
    var = cur_var
    var_size = 0.6
    FontSystem.RenderLine("score_week_graze", formatnum(cur_var),
            { 640, 308 }, var_size,
            { cw = 11 * var_size / 0.6, ch = 15, align = 2 })
    if not (pause) then
        EditorFrame()
    end
    DrawEditor()
end

local function stage_init(self)
    task.New(self, function()
        while true do
            lstg.var.lifeleft = 8
            lstg.var.bomb = 8
            lstg.var.power = 400
            if GetLastKey() == KEY.F9 then
                local task = coroutine.create(function()
                end)
                self.task[1] = task
            end
            task.Wait(1)
        end
    end)
end

local week_ui = {
    DrawFrame = DrawFrame,
    DrawScore = DrawScore,
    SetFlag = SetFlag,
    ResetFlag = ResetFlag,
    SetWeekTime = SetWeekTime,
    ResetEditor = ResetEditor,
    SetEditor = SetEditor,
    stage_init = stage_init,
}
ui.lstg_weekly = week_ui

do
    local old = _init_item
    local world = {
        l = -192, r = 192, b = -224, t = 224,
        boundl = -224, boundr = 224, boundb = -256, boundt = 256,
        scrl = 128, scrr = 512, scrb = 16, scrt = 464,
        pl = -192, pr = 192, pb = -224, pt = 224, world = 7,
    }
    function _init_item(self)
        ResetFlag()
        ResetEditor()
        for k, v in pairs(week_ui) do
            ui[k] = v
        end
        OriginalSetDefaultWorld(world.l, world.r, world.b, world.t,
                world.boundl, world.boundr, world.boundb, world.boundt,
                world.scrl, world.scrr, world.scrb, world.scrt,
                world.pl, world.pr, world.pb, world.pt, world.world)
        ResetWorld()
        --jstg.worldcount = 1
        --jstg.worlds = {lstg.world}
        --jstg.UpdateWorld()
        old(self)
    end
end

function ui.DrawMenu(title, text, pos, x, y, alpha, timer, shake, align)
    align = align or "center"
    local yos
    local nText = #text
    local nScrTextAbovePos = 10
    if title ~= "" then
        nScrTextAbovePos = 8
    end
    if nText > nScrTextAbovePos + 10 then
        if title == "" then
            yos = 9 * ui.menu.line_height
        else
            yos = 8 * ui.menu.line_height
            SetFontState("menu", "", Color(alpha * 255, unpack(ui.menu.title_color)))
            RenderText("menu", title, x, y + yos + ui.menu.line_height, ui.menu.font_size, align, "vcenter")
        end
        local i = 1
        local nbeg = pos - nScrTextAbovePos
        local nend = nText, pos + 9
        if nbeg < 1 then
            nbeg = 1
            nend = nScrTextAbovePos + 10
        end
        if nend > nText then
            nbeg = nText - nScrTextAbovePos - 9
            nend = nText
        end
        for n = nbeg, nend do
            if n == pos then
                local color = {}
                local k = cos(timer * ui.menu.blink_speed) ^ 2
                for j = 1, 3 do
                    color[j] = ui.menu.focused_color1[j] * k + ui.menu.focused_color2[j] * (1 - k)
                end

                local xos = ui.menu.shake_range * sin(ui.menu.shake_speed * shake)

                SetFontState("menu", "", Color(alpha * 255, unpack(color)))
                RenderText("menu", text[n], x + xos, y - i * ui.menu.line_height + yos, ui.menu.font_size, align, "vcenter")
            else
                SetFontState("menu", "", Color(alpha * 255, unpack(ui.menu.unfocused_color)))
                RenderText("menu", text[n], x, y - i * ui.menu.line_height + yos, ui.menu.font_size, align, "vcenter")
            end
            i = i + 1
        end
    else
        if title == "" then
            yos = (#text + 1) * ui.menu.line_height * 0.5
        else
            yos = (#text - 1) * ui.menu.line_height * 0.5
            SetFontState("menu", "", Color(alpha * 255, unpack(ui.menu.title_color)))
            RenderText("menu", title, x, y + yos + ui.menu.line_height, ui.menu.font_size, align, "vcenter")
        end
        for i = 1, #text do
            if i == pos then
                local color = {}
                local k = cos(timer * ui.menu.blink_speed) ^ 2
                for j = 1, 3 do
                    color[j] = ui.menu.focused_color1[j] * k + ui.menu.focused_color2[j] * (1 - k)
                end

                local xos = ui.menu.shake_range * sin(ui.menu.shake_speed * shake)

                SetFontState("menu", "", Color(alpha * 255, unpack(color)))
                RenderText("menu", text[i], x + xos, y - i * ui.menu.line_height + yos, ui.menu.font_size, align, "vcenter")
            else
                SetFontState("menu", "", Color(alpha * 255, unpack(ui.menu.unfocused_color)))
                RenderText("menu", text[i], x, y - i * ui.menu.line_height + yos, ui.menu.font_size, align, "vcenter")
            end
        end
    end
end

Print('Week UI Loaded')