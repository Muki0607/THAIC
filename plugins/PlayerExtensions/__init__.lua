-- 自机拓展，灵梦，魔理沙，咲夜

lstg.plugin.RegisterEvent("afterTHlib", "Player Extensions", 100, function()
    lstg.DoFile("THlib/player/reimu/reimu.lua")
    lstg.DoFile("THlib/player/marisa/marisa.lua")
    lstg.DoFile("THlib/player/sakuya/sakuya.lua")
    ---THAIC Added
    lstg.DoFile("THlib/player/muki/muki.lua")
    lstg.DoFile("THlib/player/nenyuki/nenyuki.lua")
    AddPlayerToPlayerList('Kobayashi Muki', 'muki_player', 'Muki')
    AddPlayerToPlayerList('Chimabo Nenyuki', 'nenyuki_player', 'Nenyuki')
end)
