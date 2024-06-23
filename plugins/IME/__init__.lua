---=================================================
---Chinese Pinyin Input Method by Muki
---汉语拼音输入法 by Muki
---=================================================

lstg.plugin.RegisterEvent("afterTHlib", "IME Extension", 100, function()
    lstg.DoFile("THlib/IME.lua")
end)
