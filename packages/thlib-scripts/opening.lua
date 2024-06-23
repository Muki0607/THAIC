---开场加载界面
---将于AiC.misc中重载

op = {}

op.opening_scene = Class(object)

op.finished_sign = false

function op.opening_scene:init()
    self.group = GROUP_GHOST
    self.bound = false
    New(op.loading_sign)
end

function op.opening_scene:frame()
    if op.finished_sign and self.timer > 300 then Del(self) end
end

function op.opening_scene:render()
    SetViewMode('ui')
    RenderRect('Muki_AiC_opening_scene', 0, screen.width, 0, screen.height)
    SetViewMode('world')
end

---加载标志（少女折寿中）
---将于AiC.misc中重载
op.loading_sign = Class(object)

---@param t number @加载动画旋转一圈的周期
function op.loading_sign:init(t)
    self.group = GROUP_GHOST
    self.x = screen.width * 0.8
    self.y = screen.height * 0.15
    self.bound = false
    self.scale = 0.5
    self.t = t or 180
end

function op.loading_sign:frame()
    if op.finished_sign and self.timer > 300 then Del(self) end
end

function op.loading_sign:render()
    SetViewMode('ui')
    SetImageState('Muki_AiC_loading_sign1', '', Color(200 + 50 * sin(5 * self.timer), 255, 255, 255))
    SetImageState('Muki_AiC_loading_sign2', '', Color(200 + 50 * sin(5 * self.timer), 255, 255, 255))
    Render('Muki_AiC_loading_sign1', self.x, self.y, 0, self.scale)
    Render('Muki_AiC_loading_sign2', self.x + 15, self.y - 25, 0, self.scale)
    local t = self.timer % self.t + 1
    local dt = self.t / 4
    local dir = int(t / dt) + 1
    local o = 1440 / self.t
    for i = 1, 4 do
        Render('Muki_AiC_loading_sign3', self.x + 90 + 15 * sin(i * 90), self.y - 10 + 15 * cos(i * 90), 0, self.scale)
        SetImageState('Muki_AiC_loading_sign4', '', Color(max(0, 100 + 155 * sin(o * self.timer - 30)), 255, 255, 255))
        Render('Muki_AiC_loading_sign4', self.x + 90 + 15 * sin(dir * 90), self.y - 10 + 15 * cos(dir * 90), 0, self.scale)
    end
    SetViewMode('world')
end

----------------------------------------
---资源

--开场加载界面
LoadImageFromFile('Muki_AiC_opening_scene', 'THlib/UI/Muki_AiC_opening_scene.png')

--加载标志
for i = 1, 4 do
    LoadImageFromFile('Muki_AiC_loading_sign' .. i, 'THlib/UI/loading/Muki_AiC_loading_sign' .. i .. '.png')
end

return op
