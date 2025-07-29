---=====================================
---THAIC RPG Support v1.00a
---东方梦摇篮RPG支持库 v1.00a
---=====================================

---版本更新记录
---v1.00a
---初始版本

---@class aic.rpg @东方梦摇篮RPG支持库
aic.rpg = {}
local lib = aic.rpg

---创建通常方块
---@param type number @方块类型
---@param x number @x坐标
---@param y number @y坐标
---@param a number @横向碰撞箱
---@param b number @纵向碰撞箱
---@param rot number @倾斜角
---@param allow_player number | '0 = 不可通过' | '1 = 允许通过' | '2 = 碰撞即死' | '-1 = 传递信号' @是否允许玩家通过，默认不可通过
---@param allow_bullet number | '0 = 碰撞即消' | '1 = 允许通过' | '2 = 碰撞反弹' | '-1 = 传递信号' @是否允许弹幕通过，默认碰撞即消
---@param allow_enemy number | '0 = 碰撞即死' | '1 = 允许通过' | '-1 = 传递信号' @是否允许敌人通过，默认允许通过
function lib.NewBlock(type, img, x, y, a, b, rot, allow_player, allow_bullet, allow_enemy)
    if type == 1 then
        return New(lib.rect_out, img, x, y, a, b, rot, allow_player, allow_bullet, allow_enemy)
    elseif type == 2 then
        return New(lib.rect_in, img, x, y, a, b, rot, allow_player, allow_bullet, allow_enemy)
    elseif type == 3 then
        return New(lib.circle_out, img, x, y, a, b, rot, allow_player, allow_bullet, allow_enemy)
    elseif type == 4 then
        return New(lib.circle_in, img, x, y, a, b, rot, allow_player, allow_bullet, allow_enemy)
    else
        error(InvalidArgument)
    end
end

---将obj限制在外的矩形
lib.rect_out = Class(object)

function lib.rect_out:init(img, x, y, w, h, rot, allow_player, allow_bullet, allow_enemy)
    self.group = GROUP_SPELL --会与所有子弹和敌人检测碰撞
    self.img = img or 'img_void'
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.rot = rot
    allow_player = allow_player or 0 --0为玩家不可通过，1为可通过，2为碰到即死，-1为传递信号（将_signal设为true）
    self.allow_bullet = allow_bullet or 0 --0为弹幕碰到即消失，1为直接穿过，2为碰到反弹，-1为传递信号（将_signal设为true）
    self.allow_enemy = allow_enemy or 1 --0为敌人碰到即死，1为直接穿过，-1为传递信号（将_signal设为true）
    
end

function lib.rect_out:frame()
    ColliCheck(self, player)
    if self.allow_player == 0 then
        lib.RectLimitOut(player, self.x, self.y, self.w, self.h, self.rot)
    end
end

function lib.rect_out:colli(other)
    if other.group == GROUP_ENEMY_BULLET or other.group == GROUP_INDES then
        if self.allow_bullet == 0 then
            Kill(other)
        elseif self.allow_bullet == 2 then
            other.vx = -other.vx
            other.vy = -other.vy
            other.ax = -other.ax
            other.ay = -other.ay
        elseif self.allow_bullet == -1 then
            other._signal = true
        end
    elseif other == player then
        if self.allow_player == 2 then
            Kill(player)
        elseif self.allow_bullet == -1 then
            other._signal = true
        end
    else
        if self.allow_enemy == 0 then
            Kill(other)
        elseif self.allow_bullet == -1 then
            other._signal = true
        end
    end
end

function lib.rect_out:render()
    --RenderRect(self.img, self.x - self.w, self.x + self.w, self.y - self.h, self.y + self.h)
    local x, y, w, h = self.x, self.y, self.w, self.h
    local x1, y1 = rotate(-w + x, h + y, self.rot, self.x, self.y)
    local x2, y2 = rotate(w + x, h + y, self.rot, self.x, self.y)
    local x3, y3 = rotate(w + x, -h + y, self.rot, self.x, self.y)
    local x4, y4 = rotate(-w + x, -h + y, self.rot, self.x, self.y)
    Render4V(self.img,
        x1, y1, 0.5,
        x2, y2, 0.5,
        x3, y3, 0.5,
        x4, y4, 0.5
    )
end

