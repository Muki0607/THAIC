---=====================================
---THAIC Resource v1.00a
---东方梦摇篮资源 v1.00a
---=====================================

---版本更新记录
---v1.00a
---初始版本

---@class aic.res @东方梦摇篮资源
aic.res = {}
local lib = aic.res

local dir_res = "mod/Danmaku_Resource/"

---全资源表，用于存放已加载的资源的类型与名称
lib.res_list = {}

lib.img_list = {
    --诺艾儿立绘
    'boss_face_default',
    'boss_face_fight',
    'boss_face_final',
    'boss_face_normal',
    'boss_face_smile',
    'boss_face_smile2',
    'boss_face_smile3',
    'boss_face_thinking',
    'boss_face_embarassed',
    'boss_face_speachless',
    'boss_face_assured',
    'boss_face_understand',
    'boss_face_lose',
    'boss_face_lose2',
    'boss_face_lose3',
    'boss_face_lose4',
    --伊夏立绘
    'Ixia_face_default',
    'Ixia_face_smile',
    'Ixia_face_surprise',
    'Ixia_face_angry',
    'Ixia_face_notworryyou',
    --普莉姆拉立绘
    'Primula_face_smile',
    'Primula_face_smile2',
    'Primula_face_smile3',
    'Primula_face_surprise',
    'Primula_face_speachless',
    'Primula_face_teach',
    'Primula_face_teach2',
    'Primula_face_teach3',
    'Primula_face_memory',
    'Primula_face_memory2',
    'Primula_face_memory3',
    'Primula_face_fight',
    --紫立绘
    'Yukari_face_default',
    'Yukari_face_smile',
    'Yukari_face_fight',
    --隐岐奈立绘
    'Okina_face_default',
    --梅法立绘
    'Mepha_face_default',
    'Mepha_face_smile',
    'Mepha_face_fight',
    --魔法图标
    'spell1',
    'spell2',
    'spell3',
    'spell4',
    'spell5',
    --对话框
    'dialog_frame',
    --OBJ资源
    'nuclear',
    'bow',
    'square4',
    'Primula_cast_ef',
    'Primula_cast_ef2',
    'Primula_cast_ef3',
    'Primula_smoke'
}

lib.imgrp_list = {
    --诺艾儿额外行走图
    {}
}

lib.wkimg_list = {
    --诺艾儿行走图
}

---广义资源类型（部分非lstg资源类型）
---@alias restype '"tex"' | '"img"' | '"ani"' | '"bgm"' | '"snd"' | '"psi"' | '"fnt"' | '"ttf"' | '"fx"' | '"model"' | '"pack"' | '"lua"' | '"imgrp"' | '"wkimg"'

---安全地加载资源，并记录已加载资源
---@param restype restype @资源类型
---@param resname string @资源名称
---@param filename string @文件路径
---@vararg boolean|string|number @额外参数
---@return boolean|nil @部分函数可能返回加载是否成功
function lib.SafeLoad(restype, resname, filename, ...)
    local arg = { ... }
    local loadfunc
    if restype == "lua" then
        loadfunc = DoFile
    elseif restype == "tex" then
        loadfunc = LoadTexture
    elseif restype == "img" then
        loadfunc = LoadImageFromFile
    elseif restype == 'imgrp' then
        loadfunc = LoadImageGroupFromFile
    elseif restype == 'wkimg' then
        loadfunc = lib.LoadWalkImage
    elseif restype == "ani" then
        loadfunc = LoadAniFromFile
    elseif restype == "bgm" then
        loadfunc = function(name, path, loopend, looplength)
            MusicRecord(name, path, loopend, looplength)
            LoadMusicRecord(name)
        end
    elseif restype == "snd" then
        loadfunc = LoadSound
    elseif restype == "psi" then
        loadfunc = LoadPS
    elseif restype == "fnt" then
        loadfunc = LoadFont
    elseif restype == "ttf" then
        loadfunc = LoadTTF
    elseif restype == "fx" then
        loadfunc = LoadFX
    elseif restype == "model" then
        loadfunc = LoadModel
    elseif restype == "pack" then
        loadfunc = LoadPack
    end
    return TryExcept(
        function()
            loadfunc(resname, filename, unpack(arg))
        end,
        {
            [LoadFailed] = function()
                if restype == "lua" then
                    filename, resname = resname, "脚本"
                elseif restype == "model" then
                    filename, resname = resname, "模型"
                elseif restype == "pack" then
                    filename, resname = resname, "压缩包"
                end
                lstg.MsgBoxWarn("加载游戏资源 " .. resname .. " 时发现文件 " .. filename
                    .. " 丢失。\n请检查该文件是否被移动或删除。\n若无法找到文件，请重新下载游戏。\n若文件存在且重启游戏后仍然出现此提示框，请报告作者。")
            end,
            [""] = function()
                lstg.MsgBoxWarn("加载游戏资源" .. resname .. "时出现未知错误。\n若重启游戏后仍然出现此提示框，请报告作者。")
            end
        },
        function()
            table.insert(lib.res_list[restype], resname)
        end
    )
end

---只加载行走图
---@param img string @文件路径/资源名称
---@param nCol number @纵向列数（每排最大行走图数）
---@param nRow number @横向排数（每列最大行走图数）
---@param a number @横向判定
---@param b number @纵向判定
function lib.LoadWalkImage(img, nCol, nRow, a, b)
    local number_n = {}
    for i = 1, nRow do
        number_n[i] = nCol
    end
    LoadTexture('anonymous:' .. img, img)
    local bt_n, bt_m = GetTextureSize('anonymous:' .. img)
    local w, h = bt_n / nCol, bt_m / nRow
    for i = 1, nRow do
        LoadImageGroup('anonymous:' .. img .. i, 'anonymous:' .. img,
            0, h * (i - 1), w, h, number_n[i], 1, a, b)
    end
    lstg.tmpvar._WLS_IMG_CHECK[img] = true
end

---只设置行走图
---@param obj lstg.GameObject @要设置行走图的游戏对象
---@param img string @资源名称
---@param nCol number @纵向列数（每排最大行走图数）
---@param nRow number @横向排数（每列最大行走图数）
---@param imgs number[] @每排行走图数，#imgs = nCol
---@param anis number[] @每排行走图重复次数， #anis = nRow 
---@param intv number @行走图切换间隔
function lib.SetWalkImage(obj, img, nCol, nRow, imgs, anis, intv)
    for i = 1, 4 do
        obj['img' .. i] = nil
        obj['ani' .. i] = nil
    end
    for i = 1, nRow do
        obj['img' .. i] = {}
    end
    for i = 2, nRow do
        obj['ani' .. i] = imgs[i] - anis[i - 1]
    end
    for i = 1, nRow do
        for j = 1, imgs[i] do
            obj['img' .. i][j] = 'anonymous:' .. img .. i .. j
        end
    end
    obj.ani_intv = intv or obj.ani_intv or 8
    obj.lr = obj.lr or 1
    obj.nn, obj.mm = imgs, anis
    self.mode = nCol
end

---加载所有资源
function lib.LoadAllResource()
    for _, i in ipairs({ "tex", "img", "ani", "bgm", "snd", "psi", "fnt", "ttf", "fx", "model", "pack", "lua", "imgrp", "wkimg" }) do
        if lib[i .. "_list"] then
            for _, j in ipairs(lib[i .. "_list"]) do
                lib.SafeLoad(unpack(j))
            end
        end
    end
end


