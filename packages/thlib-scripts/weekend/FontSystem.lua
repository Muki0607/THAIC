FontSystem = {}
---@class FontSystem
local lib = FontSystem

lib.record = {}

function lib.AddFont(name, path, param)
    lib.record[name] = {
        path = path,
        char = {},
    }
    local t, c
    for i = 1, #param, 7 do
        t = {}
        c = param[i]
        table.insert(t, param[i + 1])
        table.insert(t, param[i + 2])
        table.insert(t, param[i + 3])
        table.insert(t, param[i + 4])
        table.insert(t, param[i + 5])
        table.insert(t, param[i + 6])
        lib.record[name].char[c] = t
    end
end

function lib.LoadFont(name)
    local tex = string.format("FontSystem@Texture@%s", name)
    local info = lib.record[name]
    assert(info, string.format("Font %q is invalid.", name))
    LoadTexture(tex, info.path)
    local c
    for char, param in pairs(info.char) do
        c = string.format("FontSystem@Char@%s@%s", name, char)
        LoadImage(c, tex, unpack(param))
    end
end

function lib.SetFontState(name, blend, color)
    local info = lib.record[name]
    assert(info, string.format("Font %q is invalid.", name))
    local c
    for char in pairs(info.char) do
        c = lib.GetChar(name, char)
        SetImageState(c, blend, color)
    end
end

function lib.GetChar(name, char)
    local info = lib.record[name]
    assert(info, string.format("Font %q is invalid.", name))
    local c
    if info and info.char[char] then
        c = string.format("FontSystem@Char@%s@%s", name, char)
        return c
    end
end

function lib.RenderChar(name, char, x, y, rot, hscale, vscale, z)
    local info = lib.record[name]
    assert(info, string.format("Font %q is invalid.", name))
    local c = lib.GetChar(name, char)
    if not(c) then return end
    rot = rot or 0
    hscale = hscale or 1
    vscale = vscale or hscale
    z = z or 0.5
    Render(c, x, y, rot, hscale, vscale, z)
end

local align_f = {
    [0] = function(w, h)
        return 0, -h / 2
    end,
    [1] = function(w, h)
        return -w / 2, -h / 2
    end,
    [2] = function(w, h)
        return -w, -h / 2
    end,
    [4] = function(w, h)
        return 0, 0
    end,
    [5] = function(w, h)
        return -w / 2, 0
    end,
    [6] = function(w, h)
        return -w, 0
    end,
    [8] = function(w, h)
        return 0, h / 2
    end,
    [9] = function(w, h)
        return -w / 2, h / 2
    end,
    [10] = function(w, h)
        return -w, h / 2
    end,
    
}

local str = sp.string("")
function lib.RenderLine(name, text, point, size, param)
    local info = lib.record[name]
    
    --检查字体存在
    assert(info, string.format("Font %q is invalid.", name))
    
    --设置坐标
    local x, y, z, hscale, vscale 
    assert(type(point) == "table", "param #3 must be a table.")
    if point.x and point.y then
        x, y = point.x, point.y
    else
        x, y = unpack(point)
    end
    z = point.z or point[3] or 0.5
    
    --设置字体大小
    local check_size = type(size) == "number" or type(size) == "table"
    assert(check_size, "param #4 must be a number or a table.")
    if type(size) == "number" then
        hscale, vscale = size, size
    elseif size.hscale and size.vscale then
        hscale, vscale = size.hscale, size.vscale
    else
        hscale, vscale = unpack(size)
    end
    vscale = vscale or hscale
    
    --其它参数
    assert(type(param) == "table", "param #5 must be a table.")
    local Cw, Ch = param.cw, param.ch
    local Lw, Lh = param.lw or Cw * 0.1, param.lh or Ch * 1.2
    local align = param.align or 5
    local spec = param.spec
    
    --文本处理
    local check_text = type(text) == "string" or type(text) == "table"
    assert(check_text, "param #2 must be a string or a table.")
    if type(text) == "table" then
        local ref = true
        for i = 1, #text do
            lib.RenderLine(name, text[i],
                {x, y - Lh * (i - 1), z},
                {hscale = hscale, vscale = vscale},
                param
            )
        end
        return
    end
    
    --整理字符串
    str:Set(text)
    local char, c
    local chars = {}
    for i = 1, str:GetCharCount() do
        char = str:Sub(i)
        c = lib.GetChar(name, char)
        if c then
            table.insert(chars, char)
        end
    end
    
    --字符串渲染所占长度
    local tw = #chars * Cw + (#chars - 1) * Lw
    
    --渲染用偏移值
    local dx, dy = align_f[align](tw, Ch)
    
    --字符特殊操作系统
    local dx2, dy2, rot
    local spec_f = function(n)
        return 0, 0, 0
    end
    if spec then
        assert(type(spec) == "function",
            "Special Char Console must be a function.")
        spec_f = spec
    end
    
    --执行渲染
    for i = 1, #chars do
        char = chars[i]
        dx2, dy2, rot = spec_f(i)
        lib.RenderChar(name, char,
            x + dx + dx2, y + dy + dy2,
            rot, hscale, vscale, z
        )
        dx = dx + Cw + Lw
    end
end

local score_param = {
    " ", 8, 1, 17, 45, -8, -1,
    "!", 33, 1, 23, 45, -6, -6,
    "\"", 64, 1, 28, 45, -6, -6,
    "#", 100, 1, 34, 45, -7, -7,
    "$", 142, 1, 32, 45, -6, -6,
    "%", 182, 1, 43, 45, -6, -6,
    "&", 233, 1, 42, 45, -7, -7,
    "'", 283, 1, 21, 45, -6, -6,
    "(", 312, 1, 26, 45, -5, -6,
    ")", 346, 1, 27, 45, -8, -4,
    "*", 381, 1, 28, 45, -1, 0,
    "+", 417, 1, 31, 45, -5, -6,
    ",", 456, 1, 23, 45, -7, -5,
    "-", 8, 47, 27, 45, -7, -6,
    ".", 43, 47, 22, 45, -6, -5,
    "/", 73, 47, 31, 45, -8, -8,
    "0", 112, 47, 33, 45, -6, -7,
    "1", 153, 47, 33, 45, -6, -7,
    "2", 194, 47, 33, 45, -7, -6,
    "3", 235, 47, 33, 45, -7, -6,
    "4", 276, 47, 35, 45, -8, -7,
    "5", 319, 47, 32, 45, -6, -6,
    "6", 359, 47, 33, 45, -6, -7,
    "7", 400, 47, 34, 45, -6, -8,
    "8", 442, 47, 34, 45, -7, -7,
    "9", 8, 93, 34, 45, -7, -7,
    ":", 50, 93, 22, 45, -6, -5,
    ";", 80, 93, 23, 45, -7, -5,
    "<", 111, 93, 29, 45, -4, -5,
    "=", 148, 93, 32, 45, -6, -6,
    ">", 188, 93, 29, 45, -5, -4,
    "?", 225, 93, 31, 45, -7, -6,
    "@", 264, 93, 38, 45, -7, -6,
    "A", 310, 93, 40, 45, -9, -8,
    "B", 358, 93, 36, 45, -6, -7,
    "C", 402, 93, 35, 45, -7, -6,
    "D", 445, 93, 38, 45, -6, -6,
    "E", 8, 139, 34, 45, -6, -7,
    "F", 50, 139, 32, 45, -6, -6,
    "G", 90, 139, 39, 45, -7, -8,
    "H", 137, 139, 39, 45, -6, -6,
    "I", 184, 139, 26, 45, -6, -6,
    "J", 218, 139, 34, 45, -8, -7,
    "K", 260, 139, 38, 45, -6, -8,
    "L", 306, 139, 34, 45, -6, -8,
    "M", 348, 139, 44, 45, -6, -6,
    "N", 400, 139, 40, 45, -7, -7,
    "O", 448, 139, 40, 45, -7, -7,
    "P", 8, 185, 35, 45, -6, -7,
    "Q", 51, 185, 43, 45, -7, -10,
    "R", 102, 185, 37, 45, -6, -8,
    "S", 147, 185, 33, 45, -7, -7,
    "T", 188, 185, 38, 45, -8, -8,
    "U", 234, 185, 39, 45, -7, -8,
    "V", 281, 185, 40, 45, -8, -8,
    "W", 329, 185, 48, 45, -8, -8,
    "X", 385, 185, 39, 45, -8, -7,
    "Y", 432, 185, 38, 45, -8, -8,
    "Z", 8, 231, 36, 45, -7, -7,
    "[", 52, 231, 25, 45, -4, -6,
    "\\", 85, 231, 30, 45, -8, -7,
    "]", 123, 231, 25, 45, -7, -3,
    "^", 156, 231, 33, 45, -6, -7,
    "_", 197, 231, 34, 45, -8, -8,
    "`", 239, 231, 24, 45, -4, -4,
    "a", 271, 231, 33, 45, -7, -7,
    "b", 312, 231, 35, 45, -8, -7,
    "c", 355, 231, 30, 45, -7, -7,
    "d", 393, 231, 35, 45, -7, -8,
    "e", 436, 231, 32, 45, -7, -7,
    "f", 476, 231, 30, 45, -7, -9,
    "g", 8, 277, 35, 45, -8, -8,
    "h", 51, 277, 36, 45, -7, -8,
    "i", 95, 277, 26, 45, -7, -8,
    "j", 129, 277, 26, 45, -9, -6,
    "k", 163, 277, 36, 45, -7, -8,
    "l", 207, 277, 26, 45, -7, -8,
    "m", 241, 277, 46, 45, -7, -8,
    "n", 295, 277, 36, 45, -7, -7,
    "o", 339, 277, 33, 45, -7, -6,
    "p", 380, 277, 34, 45, -7, -6,
    "q", 422, 277, 35, 45, -7, -8,
    "r", 465, 277, 31, 45, -7, -8,
    "s", 8, 323, 30, 45, -7, -7,
    "t", 46, 323, 30, 45, -7, -8,
    "u", 84, 323, 35, 45, -7, -8,
    "v", 127, 323, 35, 45, -8, -8,
    "w", 170, 323, 43, 45, -8, -8,
    "x", 221, 323, 35, 45, -8, -8,
    "y", 264, 323, 34, 45, -8, -7,
    "z", 306, 323, 33, 45, -8, -7,
    "{", 347, 323, 27, 45, -6, -6,
    "|", 382, 323, 19, 45, 1, 0,
    "}", 409, 323, 27, 45, -7, -5,
    "~", 444, 323, 32, 45, -6, -6,
}
lib.AddFont("score", "THlib\\UI\\font\\score.png", score_param)
lib.AddFont("score1", "THlib\\UI\\font\\score1.png", score_param)
lib.AddFont("score2", "THlib\\UI\\font\\score2.png", score_param)
lib.AddFont("score3", "THlib\\UI\\font\\score3.png", score_param)
lib.LoadFont("score")
lib.LoadFont("score1")
lib.LoadFont("score2")
lib.LoadFont("score3")

local item_param = {
    " ", 1, 1, 3, 24, -1, 4,
    "!", 5, 1, 7, 24, 1, -2,
    "\"", 13, 1, 8, 24, 3, -3,
    "#", 22, 1, 13, 24, 1, -2,
    "$", 36, 1, 12, 24, 1, -1,
    "%", 49, 1, 19, 24, 1, -1,
    "&", 69, 1, 14, 24, 1, -3,
    "'", 84, 1, 4, 24, 3, -2,
    "(", 89, 1, 9, 24, 1, -4,
    ")", 99, 1, 10, 24, -1, -3,
    "*", 110, 1, 10, 24, 2, -2,
    "+", 121, 1, 14, 24, 0, -2,
    ",", 136, 1, 5, 24, 0, 0,
    "-", 142, 1, 7, 24, 1, -1,
    ".", 150, 1, 4, 24, 1, 0,
    "/", 155, 1, 17, 24, -1, -4,
    "0", 173, 1, 13, 24, 1, -2,
    "1", 187, 1, 7, 24, 2, -2,
    "2", 195, 1, 14, 24, 0, -3,
    "3", 210, 1, 12, 24, 0, -2,
    "4", 223, 1, 13, 24, 1, -3,
    "5", 237, 1, 12, 24, 1, -2,
    "6", 1, 26, 12, 24, 1, -1,
    "7", 14, 26, 10, 24, 2, -2,
    "8", 25, 26, 13, 24, 1, -2,
    "9", 39, 26, 13, 24, 1, -2,
    ":", 53, 26, 5, 24, 1, -1,
    ";", 59, 26, 6, 24, 0, -1,
    "<", 66, 26, 13, 24, 1, -2,
    "=", 80, 26, 14, 24, 0, -2,
    ">", 95, 26, 13, 24, 1, -2,
    "?", 109, 26, 14, 24, 0, -3,
    "@", 124, 26, 15, 24, 1, -2,
    "A", 140, 26, 14, 24, 0, -2,
    "B", 155, 26, 14, 24, 0, -2,
    "C", 170, 26, 12, 24, 1, -3,
    "D", 183, 26, 14, 24, 0, -2,
    "E", 198, 26, 13, 24, 0, -3,
    "F", 212, 26, 13, 24, 0, -3,
    "G", 226, 26, 12, 24, 1, -1,
    "H", 239, 26, 14, 24, 0, -2,
    "I", 1, 51, 7, 24, 0, -3,
    "J", 9, 51, 14, 24, 0, -2,
    "K", 24, 51, 14, 24, 0, -2,
    "L", 39, 51, 11, 24, 0, -1,
    "M", 51, 51, 14, 24, 0, -2,
    "N", 66, 51, 14, 24, 0, -2,
    "O", 81, 51, 13, 24, 1, -2,
    "P", 95, 51, 14, 24, 0, -2,
    "Q", 110, 51, 13, 24, 1, -2,
    "R", 124, 51, 14, 24, 0, -2,
    "S", 139, 51, 12, 24, 1, -1,
    "T", 152, 51, 11, 24, 2, -3,
    "U", 164, 51, 13, 24, 1, -2,
    "V", 178, 51, 14, 24, 0, -2,
    "W", 193, 51, 13, 24, 1, -2,
    "X", 207, 51, 14, 24, 0, -3,
    "Y", 222, 51, 13, 24, 1, -2,
    "Z", 236, 51, 13, 24, 0, -3,
    "[", 1, 76, 9, 24, 1, -4,
    "\\", 11, 76, 11, 24, 2, -1,
    "]", 23, 76, 9, 24, 0, -3,
    "^", 33, 76, 12, 24, 0, 0,
    "_", 46, 76, 14, 24, -1, -1,
	    "`", 61, 76, 6, 24, 5, 1,
    "a", 68, 76, 14, 24, 0, -2,
    "b", 83, 76, 14, 24, 0, -2,
    "c", 98, 76, 12, 24, 1, -3,
    "d", 111, 76, 14, 24, 0, -2,
    "e", 126, 76, 13, 24, 0, -3,
    "f", 140, 76, 13, 24, 0, -3,
    "g", 154, 76, 12, 24, 1, -1,
    "h", 167, 76, 14, 24, 0, -2,
    "i", 182, 76, 7, 24, 0, -3,
    "j", 190, 76, 14, 24, 0, -2,
    "k", 205, 76, 14, 24, 0, -2,
    "l", 220, 76, 11, 24, 0, -1,
    "m", 232, 76, 14, 24, 0, -2,
    "n", 1, 101, 14, 24, 0, -2,
    "o", 16, 101, 13, 24, 1, -2,
    "p", 30, 101, 14, 24, 0, -2,
    "q", 45, 101, 13, 24, 1, -2,
    "r", 59, 101, 14, 24, 0, -2,
    "s", 74, 101, 12, 24, 1, -1,
    "t", 87, 101, 11, 24, 2, -3,
    "u", 99, 101, 13, 24, 1, -2,
    "v", 113, 101, 14, 24, 0, -2,
    "w", 128, 101, 13, 24, 1, -2,
    "x", 142, 101, 14, 24, 0, -3,
    "y", 157, 101, 13, 24, 1, -2,
    "z", 171, 101, 13, 24, 0, -3,
    "{", 185, 101, 10, 24, 1, -3,
    "|", 196, 101, 4, 24, 6, 2,
    "}", 201, 101, 11, 24, -1, -2,
    "~", 213, 101, 14, 24, 1, 1,
}
lib.AddFont("item", "THlib\\UI\\font\\item.png", item_param)
lib.LoadFont("item")

local menu_param = {
    " ", 8, 1, 17, 45, -8, -1,
    "!", 33, 1, 23, 45, -6, -6,
    "\"", 64, 1, 28, 45, -6, -6,
    "#", 100, 1, 34, 45, -7, -7,
    "$", 142, 1, 32, 45, -6, -6,
    "%", 182, 1, 43, 45, -6, -6,
    "&", 233, 1, 42, 45, -7, -7,
    "'", 283, 1, 21, 45, -6, -6,
    "(", 312, 1, 26, 45, -5, -6,
    ")", 346, 1, 27, 45, -8, -4,
    "*", 381, 1, 28, 45, -1, 0,
    "+", 417, 1, 31, 45, -5, -6,
    ",", 456, 1, 23, 45, -7, -5,
    "-", 8, 47, 27, 45, -7, -6,
    ".", 43, 47, 22, 45, -6, -5,
    "/", 73, 47, 31, 45, -8, -8,
    "0", 112, 47, 33, 45, -6, -7,
    "1", 153, 47, 33, 45, -6, -7,
    "2", 194, 47, 33, 45, -7, -6,
    "3", 235, 47, 33, 45, -7, -6,
    "4", 276, 47, 35, 45, -8, -7,
    "5", 319, 47, 32, 45, -6, -6,
    "6", 359, 47, 33, 45, -6, -7,
    "7", 400, 47, 34, 45, -6, -8,
    "8", 442, 47, 34, 45, -7, -7,
    "9", 8, 93, 34, 45, -7, -7,
    ":", 50, 93, 22, 45, -6, -5,
    ";", 80, 93, 23, 45, -7, -5,
    "<", 111, 93, 29, 45, -4, -5,
    "=", 148, 93, 32, 45, -6, -6,
    ">", 188, 93, 29, 45, -5, -4,
    "?", 225, 93, 31, 45, -7, -6,
    "@", 264, 93, 38, 45, -7, -6,
    "A", 310, 93, 40, 45, -9, -8,
    "B", 358, 93, 36, 45, -6, -7,
    "C", 402, 93, 35, 45, -7, -6,
    "D", 445, 93, 38, 45, -6, -6,
    "E", 8, 139, 34, 45, -6, -7,
    "F", 50, 139, 32, 45, -6, -6,
    "G", 90, 139, 39, 45, -7, -8,
    "H", 137, 139, 39, 45, -6, -6,
    "I", 184, 139, 26, 45, -6, -6,
    "J", 218, 139, 34, 45, -8, -7,
    "K", 260, 139, 38, 45, -6, -8,
    "L", 306, 139, 34, 45, -6, -8,
    "M", 348, 139, 44, 45, -6, -6,
    "N", 400, 139, 40, 45, -7, -7,
    "O", 448, 139, 40, 45, -7, -7,
    "P", 8, 185, 35, 45, -6, -7,
    "Q", 51, 185, 43, 45, -7, -10,
    "R", 102, 185, 37, 45, -6, -8,
    "S", 147, 185, 33, 45, -7, -7,
    "T", 188, 185, 38, 45, -8, -8,
    "U", 234, 185, 39, 45, -7, -8,
    "V", 281, 185, 40, 45, -8, -8,
    "W", 329, 185, 48, 45, -8, -8,
    "X", 385, 185, 39, 45, -8, -7,
    "Y", 432, 185, 38, 45, -8, -8,
    "Z", 8, 231, 36, 45, -7, -7,
    "[", 52, 231, 25, 45, -4, -6,
    "\\", 85, 231, 30, 45, -8, -7,
    "]", 123, 231, 25, 45, -7, -3,
    "^", 156, 231, 33, 45, -6, -7,
    "_", 197, 231, 34, 45, -8, -8,
    "`", 239, 231, 24, 45, -4, -4,
    "a", 271, 231, 33, 45, -7, -7,
    "b", 312, 231, 35, 45, -8, -7,
    "c", 355, 231, 30, 45, -7, -7,
    "d", 393, 231, 35, 45, -7, -8,
    "e", 436, 231, 32, 45, -7, -7,
    "f", 476, 231, 30, 45, -7, -9,
    "g", 8, 277, 35, 45, -8, -8,
    "h", 51, 277, 36, 45, -7, -8,
    "i", 95, 277, 26, 45, -7, -8,
    "j", 129, 277, 26, 45, -9, -6,
    "k", 163, 277, 36, 45, -7, -8,
    "l", 207, 277, 26, 45, -7, -8,
    "m", 241, 277, 46, 45, -7, -8,
    "n", 295, 277, 36, 45, -7, -7,
    "o", 339, 277, 33, 45, -7, -6,
    "p", 380, 277, 34, 45, -7, -6,
    "q", 422, 277, 35, 45, -7, -8,
    "r", 465, 277, 31, 45, -7, -8,
    "s", 8, 323, 30, 45, -7, -7,
    "t", 46, 323, 30, 45, -7, -8,
    "u", 84, 323, 35, 45, -7, -8,
    "v", 127, 323, 35, 45, -8, -8,
    "w", 170, 323, 43, 45, -8, -8,
    "x", 221, 323, 35, 45, -8, -8,
    "y", 264, 323, 34, 45, -8, -7,
    "z", 306, 323, 33, 45, -8, -7,
    "{", 347, 323, 27, 45, -6, -6,
    "|", 382, 323, 19, 45, 1, 0,
    "}", 409, 323, 27, 45, -7, -5,
    "~", 444, 323, 32, 45, -6, -6,
    0x7F, 14, 369, 22, 45, 0, 0,
}
lib.AddFont("menu", "THlib\\UI\\font\\menu.png", menu_param)
lib.LoadFont("menu")

local bonus_param = {
    " ", 1, 1, 3, 24, -1, 10,
    "!", 5, 1, 5, 24, 3, 4,
    "\"", 11, 1, 9, 24, 2, 1,
    "#", 21, 1, 12, 24, 0, 0,
    "$", 34, 1, 12, 24, 0, 0,
    "%", 47, 1, 13, 24, 0, -1,
    "&", 61, 1, 13, 24, 0, -1,
    "'", 75, 1, 5, 24, 4, 3,
    "(", 81, 1, 9, 24, 2, 1,
    ")", 91, 1, 9, 24, 1, 2,
    "*", 101, 1, 12, 24, 0, 0,
    "+", 114, 1, 12, 24, 0, 0,
    ",", 127, 1, 5, 24, 3, 4,
    "-", 133, 1, 10, 24, 1, 1,
    ".", 144, 1, 5, 24, 3, 4,
    "/", 150, 1, 10, 24, 1, 1,
    "0", 161, 1, 12, 24, 0, 0,
    "1", 174, 1, 7, 24, 1, 4,
    "2", 182, 1, 11, 24, 1, 0,
    "3", 194, 1, 10, 24, 1, 1,
    "4", 205, 1, 12, 24, 0, 0,
    "5", 218, 1, 11, 24, 1, 0,
    "6", 230, 1, 11, 24, 1, 0,
    "7", 242, 1, 10, 24, 1, 1,
    "8", 1, 26, 12, 24, 0, 0,
    "9", 14, 26, 10, 24, 1, 1,
    ":", 25, 26, 5, 24, 3, 4,
    ";", 31, 26, 5, 24, 3, 4,
    "<", 37, 26, 12, 24, 0, 0,
    "=", 50, 26, 12, 24, 0, 0,
    ">", 63, 26, 12, 24, 0, 0,
    "?", 76, 26, 10, 24, 1, 1,
    "@", 87, 26, 12, 24, 0, 0,
    "A", 100, 26, 14, 24, -1, -1,
    "B", 115, 26, 12, 24, 0, 0,
    "C", 128, 26, 12, 24, 0, 0,
    "D", 141, 26, 12, 24, 0, 0,
    "E", 154, 26, 12, 24, 0, 0,
    "F", 167, 26, 10, 24, 1, 1,
    "G", 178, 26, 12, 24, 0, 0,
    "H", 191, 26, 12, 24, 0, 0,
    "I", 204, 26, 10, 24, 1, 1,
    "J", 215, 26, 12, 24, 0, 0,
    "K", 228, 26, 12, 24, 0, 0,
    "L", 241, 26, 11, 24, 1, 0,
    "M", 1, 51, 12, 24, 0, 0,
    "N", 14, 51, 12, 24, 0, 0,
    "O", 27, 51, 12, 24, 0, 0,
    "P", 40, 51, 12, 24, 0, 0,
    "Q", 53, 51, 12, 24, 0, 0,
    "R", 66, 51, 12, 24, 0, 0,
    "S", 79, 51, 12, 24, 0, 0,
    "T", 92, 51, 12, 24, 0, 0,
    "U", 105, 51, 12, 24, 0, 0,
    "V", 118, 51, 12, 24, 0, 0,
    "W", 131, 51, 14, 24, -1, -1,
    "X", 146, 51, 12, 24, 0, 0,
    "Y", 159, 51, 12, 24, 0, 0,
    "Z", 172, 51, 12, 24, 0, 0,
    "[", 185, 51, 9, 24, 2, 1,
    "\\", 195, 51, 10, 24, 1, 1,
    "]", 206, 51, 9, 24, 1, 2,
    "^", 216, 51, 10, 24, 1, 1,
    "_", 227, 51, 12, 24, 0, 0,
    "`", 240, 51, 6, 24, 2, 4,
    "a", 1, 76, 11, 24, 0, 1,
    "b", 13, 76, 12, 24, 0, 0,
    "c", 26, 76, 12, 24, 0, 0,
    "d", 39, 76, 12, 24, 0, 0,
    "e", 52, 76, 12, 24, 0, 0,
    "f", 65, 76, 12, 24, 1, -1,
    "g", 78, 76, 12, 24, 0, 0,
    "h", 91, 76, 10, 24, 1, 1,
    "i", 102, 76, 10, 24, 1, 1,
    "j", 113, 76, 10, 24, 0, 2,
    "k", 124, 76, 11, 24, 1, 0,
    "l", 136, 76, 10, 24, 1, 1,
    "m", 147, 76, 12, 24, 0, 0,
    "n", 160, 76, 10, 24, 1, 1,
    "o", 171, 76, 12, 24, 0, 0,
    "p", 184, 76, 12, 24, 0, 0,
    "q", 197, 76, 12, 24, 0, 0,
    "r", 210, 76, 11, 24, 1, 0,
    "s", 222, 76, 12, 24, 0, 0,
    "t", 235, 76, 11, 24, 1, 0,
    "u", 1, 101, 12, 24, 0, 0,
    "v", 14, 101, 12, 24, 0, 0,
    "w", 27, 101, 14, 24, -1, -1,
    "x", 42, 101, 12, 24, 0, 0,
    "y", 55, 101, 12, 24, 0, 0,
    "z", 68, 101, 12, 24, 0, 0,
    "{", 81, 101, 11, 24, 0, 1,
    "|", 93, 101, 4, 24, 4, 4,
    "}", 98, 101, 11, 24, 1, 0,
    "~", 110, 101, 12, 24, 0, 0,
}
lib.AddFont("bonus", "THlib\\UI\\font\\bonus.png", bonus_param)
lib.LoadFont("bonus")

local replay_param = {
    " ", 0, 0, 21, 21, 0, 0,
    "!", 21, 0, 21, 21, 0, 0,
    "\"", 126, 105, 21, 21, 0, 0,
    "#", 63, 0, 21, 21, 0, 0,
    "$", 84, 0, 21, 21, 0, 0,
    "%", 105, 0, 21, 21, 0, 0,
    "&", 126, 0, 21, 21, 0, 0,
    "'", 147, 0, 21, 21, 0, 0,
    "(", 168, 0, 21, 21, 0, 0,
    ")", 189, 0, 21, 21, 0, 0,
    "*", 210, 0, 21, 21, 0, 0,
    "+", 231, 0, 21, 21, 0, 0,
    ",", 252, 0, 21, 21, 0, 0,
    "-", 273, 0, 21, 21, 0, 0,
    ".", 294, 0, 21, 21, 0, -8,
    "/", 315, 0, 21, 21, 0, 0,
    "0", 336, 0, 21, 21, -2.5, -2.5,
    "1", 357, 0, 21, 21, -2.5, -2.5,
    "2", 0, 21, 21, 21, -2.5, -2.5,
    "3", 21, 21, 21, 21, -2.5, -2.5,
    "4", 42, 21, 21, 21, -2.5, -2.5,
    "5", 63, 21, 21, 21, -2.5, -2.5,
    "6", 84, 21, 21, 21, -2.5, -2.5,
    "7", 105, 21, 21, 21, -2.5, -2.5,
    "8", 126, 21, 21, 21, -2.5, -2.5,
    "9", 147, 21, 21, 21, -2.5, -2.5,
    ":", 168, 21, 21, 21, 0, 0,
    ";", 189, 21, 21, 21, 0, 0,
    "<", 210, 21, 21, 21, 0, 0,
    "=", 231, 21, 21, 21, 0, 0,
    ">", 252, 21, 21, 21, 0, 0,
    "?", 273, 21, 21, 21, 0, 0,
    "@", 294, 21, 21, 21, 0, 0,
    "A", 315, 21, 21, 21, 0, 0,
    "B", 336, 21, 21, 21, 0, 0,
    "C", 357, 21, 21, 21, 0, 0,
    "D", 0, 42, 21, 21, 0, 0,
    "E", 21, 42, 21, 21, 0, 0,
    "F", 42, 42, 21, 21, 0, 0,
    "G", 63, 42, 21, 21, 0, 0,
    "H", 84, 42, 21, 21, 0, 0,
    "I", 105, 42, 21, 21, 0, 0,
    "J", 126, 42, 21, 21, 0, 0,
    "K", 147, 42, 21, 21, 0, 0,
    "L", 168, 42, 21, 21, 0, 0,
    "M", 189, 42, 21, 21, 0, 0,
    "N", 210, 42, 21, 21, 0, 0,
    "O", 231, 42, 21, 21, 0, 0,
    "P", 252, 42, 21, 21, 0, 0,
    "Q", 273, 42, 21, 21, 0, 0,
    "R", 294, 42, 21, 21, 0, 0,
    "S", 315, 42, 21, 21, 0, 0,
    "T", 336, 42, 21, 21, 0, 0,
    "U", 357, 42, 21, 21, 0, 0,
    "V", 0, 63, 21, 21, 0, 0,
    "W", 21, 63, 21, 21, 0, 0,
    "X", 42, 63, 21, 21, 0, 0,
    "Y", 63, 63, 21, 21, 0, 0,
    "Z", 84, 63, 21, 21, 0, 0,
    "[", 105, 63, 21, 21, 0, 0,
    "\\", 147, 105, 21, 21, 0, 0,
    "]", 147, 63, 21, 21, 0, 0,
    "^", 168, 63, 21, 21, 0, 0,
    "_", 189, 63, 21, 21, 0, 0,
    "`", 210, 63, 21, 21, 0, 0,
    "a", 231, 63, 21, 21, -2.5, -2.5,
    "b", 252, 63, 21, 21, -2.5, -2.5,
    "c", 273, 63, 21, 21, -2.5, -2.5,
    "d", 294, 63, 21, 21, -2.5, -2.5,
    "e", 315, 63, 21, 21, -2.5, -2.5,
    "f", 336, 63, 21, 21, -2.5, -2.5,
    "g", 357, 63, 21, 21, -2.5, -2.5,
    "h", 0, 84, 21, 21, -2.5, -2.5,
    "i", 21, 84, 21, 21, -2.5, -2.5,
    "j", 42, 84, 21, 21, -2.5, -2.5,
    "k", 63, 84, 21, 21, -2.5, -2.5,
    "l", 84, 84, 21, 21, -2.5, -2.5,
    "m", 105, 84, 21, 21, 0, 0,
    "n", 126, 84, 21, 21, -2, -1,
    "o", 147, 84, 21, 21, -2.5, -2.5,
    "p", 168, 84, 21, 21, -2.5, -2.5,
    "q", 189, 84, 21, 21, -2.5, -2,
    "r", 210, 84, 21, 21, -2.5, -2.5,
    "s", 231, 84, 21, 21, -2.5, -2.5,
    "t", 252, 84, 21, 21, -2.5, -2.5,
    "u", 273, 84, 21, 21, -2.5, -1.5,
    "v", 294, 84, 21, 21, -2.5, -2.5,
    "w", 315, 84, 21, 21, 0, 0,
    "x", 336, 84, 21, 21, -2.5, -2.5,
    "y", 357, 84, 21, 21, -2.5, -2.5,
    "z", 0, 105, 21, 21, -2.5, -2.5,
    "{", 21, 105, 21, 21, 0, 0,
    "|", 42, 105, 21, 21, 0, 0,
    "}", 63, 105, 21, 21, 0, 0,
    "~", 84, 105, 21, 21, 0, 0,
    "&BS", 105, 105, 21, 21, 0, 0,
    "终", 126, 105, 21, 21, 0, 0,
    "□", 147, 105, 21, 21, 0, 0,
    0x82, 168, 105, 21, 21, 0, 0,
}
lib.AddFont("replay", "THlib\\UI\\font\\replay.png", replay_param)
lib.LoadFont("replay")

local score_week_param = {
    " ", 1, 1, 13, 50, -1, 4,
    "!", 15, 1, 15, 50, 1, 1,
    "\"", 31, 1, 20, 50, 1, 1,
    "#", 52, 1, 30, 50, 0, 1,
    "$", 83, 1, 28, 50, 0, 1,
    "%", 112, 1, 31, 50, 1, 1,
    "&", 144, 1, 31, 50, 1, 0,
    "'", 176, 1, 16, 50, 0, 0,
    "(", 193, 1, 20, 50, 2, -1,
    ")", 214, 1, 20, 50, -1, 2,
    "*", 235, 1, 24, 50, 0, 0,
    "+", 260, 1, 25, 50, 1, 1,
    ",", 286, 1, 15, 50, 1, 1,
    "-", 302, 1, 22, 50, 2, 2,
    ".", 325, 1, 15, 50, 1, 1,
    "/", 341, 1, 26, 50, -1, -3,
    "0", 368, 1, 26, 50, 1, 1,
    "1", 395, 1, 19, 50, 0, 2,
    "2", 415, 1, 25, 50, 1, 1,
    "3", 441, 1, 26, 50, 0, 1,
    "4", 468, 1, 27, 50, 1, 1,
    "5", 1, 52, 26, 50, 1, 1,
    "6", 28, 52, 25, 50, 1, 1,
    "7", 54, 52, 25, 50, 1, 1,
    "8", 80, 52, 26, 50, 1, 2,
    "9", 107, 52, 25, 50, 1, 1,
    ":", 133, 52, 15, 50, 1, 1,
    ";", 149, 52, 15, 50, 1, 1,
    "<", 165, 52, 23, 50, 0, 1,
    "=", 189, 52, 23, 50, 1, 1,
    ">", 213, 52, 23, 50, 1, 0,
    "?", 237, 52, 24, 50, 0, 0,
    "@", 262, 52, 37, 50, 1, 1,
    "A", 300, 52, 32, 50, 0, -1,
    "B", 333, 52, 28, 50, 2, 1,
    "C", 362, 52, 29, 50, 1, 0,
    "D", 392, 52, 28, 50, 2, 2,
    "E", 421, 52, 27, 50, 2, 1,
    "F", 449, 52, 27, 50, 2, -1,
    "G", 477, 52, 29, 50, 1, 1,
    "H", 1, 103, 29, 50, 2, 1,
    "I", 31, 103, 15, 50, 2, 2,
    "J", 47, 103, 26, 50, -1, 2,
    "K", 74, 103, 30, 50, 2, -1,
    "L", 105, 103, 27, 50, 2, 0,
    "M", 133, 103, 32, 50, 2, 2,
    "N", 166, 103, 29, 50, 2, 2,
    "O", 196, 103, 29, 50, 1, 1,
    "P", 226, 103, 28, 50, 2, 1,
    "Q", 255, 103, 31, 50, 1, 0,
    "R", 287, 103, 29, 50, 2, 1,
    "S", 317, 103, 30, 50, 0, 0,
    "T", 348, 103, 28, 50, -1, -1,
    "U", 377, 103, 28, 50, 2, 2,
    "V", 406, 103, 31, 50, -1, -1,
    "W", 438, 103, 39, 50, -1, 0,
    "X", 478, 103, 30, 50, -1, 0,
    "Y", 1, 154, 29, 50, -1, -1,
    "Z", 31, 154, 27, 50, 1, 0,
    "[", 59, 154, 18, 50, 2, 0,
    "\\", 78, 154, 26, 50, -2, -2,
    "]", 105, 154, 19, 50, -1, 2,
    "^", 125, 154, 25, 50, 1, 1,
    "_", 151, 154, 25, 50, 0, -1,
    "`", 177, 154, 19, 50, 0, 1,
    "a", 197, 154, 25, 50, 1, 2,
    "b", 223, 154, 25, 50, 2, 1,
    "c", 249, 154, 25, 50, 1, 0,
    "d", 275, 154, 25, 50, 1, 2,
    "e", 301, 154, 26, 50, 1, 1,
    "f", 328, 154, 21, 50, 0, -1,
    "g", 350, 154, 25, 50, 1, 2,
    "h", 376, 154, 25, 50, 2, 1,
    "i", 402, 154, 15, 50, 2, 1,
    "j", 418, 154, 18, 50, -1, 2,
    "k", 437, 154, 26, 50, 2, -1,
    "l", 464, 154, 17, 50, 2, 1,
    "m", 1, 205, 35, 50, 2, 1,
    "n", 37, 205, 25, 50, 2, 1,
    "o", 63, 205, 26, 50, 1, 1,
    "p", 90, 205, 25, 50, 2, 1,
    "q", 116, 205, 25, 50, 1, 2,
    "r", 142, 205, 23, 50, 2, -1,
    "s", 166, 205, 27, 50, 0, 0,
    "t", 194, 205, 20, 50, 0, 1,
    "u", 215, 205, 25, 50, 2, 1,
    "v", 241, 205, 27, 50, 0, 0,
    "w", 269, 205, 36, 50, 0, 0,
    "x", 306, 205, 27, 50, 0, 0,
    "y", 334, 205, 27, 50, 0, -1,
    "z", 362, 205, 25, 50, 1, 0,
    "{", 388, 205, 21, 50, 1, 0,
    "|", 410, 205, 15, 50, 2, 2,
    "}", 426, 205, 21, 50, 0, 1,
    "~", 448, 205, 25, 50, 1, 1,
}
lib.AddFont("score_week", "weekend/score_week_fnt.png", score_week_param)
lib.LoadFont("score_week")
lib.AddFont("score_week_time", "weekend/score_week_fnt.png", score_week_param)
lib.LoadFont("score_week_time")
lib.SetFontState("score_week_time", "", Color(255, 255, 127, 127))
lib.AddFont("score_week_dark", "weekend/score_week_fnt.png", score_week_param)
lib.LoadFont("score_week_dark")
lib.SetFontState("score_week_dark", "", Color(255, 0, 0, 0))
lib.AddFont("score_week_point", "weekend/score_week_fnt.png", score_week_param)
lib.LoadFont("score_week_point")
lib.SetFontState("score_week_point", "", Color(255, 192, 192, 255))
lib.AddFont("score_week_graze", "weekend/score_week_fnt.png", score_week_param)
lib.LoadFont("score_week_graze")
lib.SetFontState("score_week_graze", "", Color(255, 255, 192, 192))