LoadImageFromFile("_scbg", "THlib/background/spellcard/background.png", true, 0, 0, false)
LoadImageFromFile("_scbg_mask", "THlib/background/spellcard/mask.png", true, 0, 0, false)

spellcard_background = Class(_spellcard_background)
spellcard_background.init = function(self)
    _spellcard_background.init(self)
    _spellcard_background.AddLayer(self, "_scbg_mask", true, 0, 0, 0, 1, 1, 0, "", 1, 1, nil, nil)
    _spellcard_background.AddLayer(self, "_scbg", false, 0, 0, 0, 0, 0, 0, "", 1, 1, nil, nil)
end
