---THAIC Arranged
--From (附带文件)避弹AI设计原理与实现.docx in 群文件
--听说是把直流群搞炸了的那位的杰作
--整个是个非常谔谔的if堆出来的屎山，但我根本做不出来所以没资格说什么
--去除了谔谔的需要GROUP_LASER组（请在看到这东西时对自己进行记忆清除，忘掉有这个东西，因为它根本不存在）的激光检测
--去除了对scoredata的调用，提高效率（更重要的是这玩意放在和core同级的话不知道为什么没法调用scoredata）

Hana_AI = {} --初始化，放在了初始化函数里面
--High_speed_rad = --[[player.hspeed or]] 4.5 --初始化高速半径
--Low_speed_rad = --[[player.lspeed or]] 2 -- 初始化低速半径
--player.hspeed = 4.5 --初始化高速半径
--player.lspeed = 2 -- 初始化低速半径--]]
Hana_AI.Return_point_x, Hana_AI.Return_point_y = 0, -160 --返回点初始化
Hana_AI.Return_point_cd = 0 --鼠标操作CD
if not _debug.hana_ai then Hana_AI.Return_point_cd = 1 end
Hana_AI.Return_point_open_return = 1 --1表示开启,会在有弹幕的区域进行指向移动
function Hana_AI_initialization()
    --包括了部分的初始化
    if Hana_AI.Archive_initialization ~= 1 then
        --初始化信息
        --scoredata.Hana_AI = {}
        Hana_AI.Archive_initialization = 1
        Hana_AI.Hide = 0         --数据显示隐藏0显示1隐藏
        Hana_AI.Start_state = 0  --启动状态,默认不启动 1启动 0 不启动，存档变量
        Hana_AI.true_player = 0  --选择路径模式
        Hana_AI.Stren_return = 0 --强化返回模式
    end
end

if not Hana_AI.ver_13 then --版本兼容
    --scoredata.Hana_AI = {}
    Hana_AI.Archive_initialization = 1
    Hana_AI.Hide = 1         --数据显示隐藏0显示1隐藏
    Hana_AI.Start_state = 0  --启动状态,默认不启动 1启动 0 不启动，存档变量
    Hana_AI.true_player = 0  --选择路径模式
    Hana_AI.Stren_return = 0 --强化返回模式
    Hana_AI.ver_12 = 1
end
Hana_AI_initialization() --存档初始化函数
local abs, max, min = math.abs, math.max, math.min --效率优化
--关于安装 将所需函数放入对应文件:
--[[
    _editor_output.lua开头写入(editor初始化后)
    DoFile('THlib\\player\\Hana_AI_v_1.0.lua')--避弹AI
    在 player_system.lua中
    ["frame.updateSlow"] 中
        if self.__slow_flag then
            self.slow = 1
        else
            self.slow = 0
        end
    之前
    写上 Hana_AI.Frame_action()--避弹AI
    在  ["frame.move"] = { 97, function(self) 末端 写上
        Hana_AI.Walking_diagram_correction(dx,dy)--避弹AI，在这里
    新版本增加：
    function object.LineLaserDo(func)--警告:这里需要一个约定,否则无法运行
    --[[确保激光和曲线激光中有这个变量
    self.IsLaser = true--(每个激光都有)
   self.IsBentLaser = true = true(曲线激光为true,普通激光无)
    并且确保激光属于GPOUP.LASER组
    --]]
--]]
--------------------------------------------------------------------迁移需要保留的函数----------------------------------------------------------------------------------------------------

local function GetDist(a, b)
    if IsValid(a) and IsValid(b) then
        return Dist(a, b)
    elseif a.x and b.x then
        return hypot(a.x - b.x, a.y - b.y)
    end
end



----------------------------------------------------------------------------------------------------------------
--快速的描绘文字（需要占用一个Obj)
--承载文本事件的Obj见 _editor_class.lua 搜索  快捷文字渲染承载Obj
--承载Obj
--承载事件的简单Obj
--local path = "THlib\\UI\\font\\"
--local ntext1 = path .. "text.ttf"
--local ntext2 = path .. "text2.ttf"

function object.BulletIndesEnemyDo(func)
    for _, o in ObjList(GROUP_ENEMY_BULLET) do
        func(o)
    end
    for _, o in ObjList(GROUP_ENEMY) do
        func(o)
    end
    for _, o in ObjList(GROUP_INDES) do
        func(o)
    end
end
--[=[
function object.LineLaserDo(func) --警告:这里需要一个约定,否则无法运行
    --[[确保激光和曲线激光中有这个变量
    self.IsLaser = true--(每个激光都有)
   self.IsBentLaser = true = true(曲线激光为true,普通激光无)
    并且确保激光属于GPOUP.LASER组
    --]]
    for _, o in ObjList(GROUP_LASER) do
        if o.IsLaser == true then
            if not o.IsBentLaser then
                func(o)
            end
        end
    end
    for _, o in ObjList(GROUP_INDES) do
        if o.IsLaser == true then
            if not o.IsBentLaser then
                func(o)
            end
        end
    end
    for _, o in ObjList(GROUP_ENEMY_BULLET) do
        if o.IsLaser == true then
            if not o.IsBentLaser then
                func(o)
            end
        end
    end
end

function object.AI_BentLaserDo(func) --警告:这里需要一个约定,否则无法运行
    --[[确保激光和曲线激光中有这个变量
    self.IsLaser = true--(每个激光都有)
   self.IsBentLaser = true = true(曲线激光为true,普通激光无)
    并且确保激光属于GPOUP.LASER组
    --]]
    for _, o in ObjList(GROUP_LASER) do
        if o.IsLaser == true then
            if o.IsBentLaser == true then
                func(o)
            end
        end
    end
    for _, o in ObjList(GROUP_INDES) do
        if o.IsLaser == true then
            if o.IsBentLaser == true then
                func(o)
            end
        end
    end
end
]=]
LoadTTF('boss_name', 'assets/font/SourceHanSansCN-Bold.otf', 20)

local function RenderTTF4(ttfname, text, x, y, color, ...)
    local fmt = 0
    for _, t in ipairs({ ... }) do
        fmt = fmt + ENUM_TTF_FMT[t]
    end
    lstg.RenderTTF(ttfname, text, x, x, y, y, fmt, color)
end
SimpleText = Class(object, {
    init = function(self, x, y, layer, text, alpha, color, lifetime, f, viewmode, ...)
        self.x, self.y = x, y
        self.layer = LAYER_TOP
        self.group = GROUP_GHOST
        self.colli = false
        self.bound = false
        self.text = text or ""
        self.alpha = alpha or 0
        self.color = color or { 255, 255, 255 }
        self.other = { ... }
        self.lifetime = lifetime + 1
        self.viewmode = viewmode or "ui"
        self.size = 1
        self.type = 'boss_name'
        task.New(self, f or function()
        end)
    end,
    frame = function(self)
        task.Do(self)
        if self.lifetime then
            if self.timer >= self.lifetime then
                RawDel(self)
            end
        end
    end,
    render = function(self)
        SetViewMode("ui")
        local s = GetImageScale()
        SetImageScale(s * self.size)
        RenderTTF4(self.type, self.text, self.x + 1, self.y - 1, Color(self.alpha, 0, 0, 0), unpack(self.other))
        RenderTTF4(self.type, self.text, self.x, self.y, Color(self.alpha, unpack(self.color)), unpack(self.other))
        SetImageScale(s)
        SetViewMode("world")
    end
})

--简化函数：
---@param x string@X坐标
---@param y string@Y坐标
---@param layer number@图层
---@param text string@显示的文本
---@param alpha number@透明度
---@param color table@颜色{R,B,G}
---@param lifetime number@存在事件(帧)
---@param f function @附加的函数
---@param viewmode string @显示模式 有如下 "ui" "world" "3d"等
function NewText(x, y, layer, text, alpha, color, lifetime, f, viewmode, ...)
    return New(SimpleText, x, y, layer, text, alpha, color, lifetime, f, viewmode, ...)
end

----------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------迁移需要保留的函数----------------------------------------------------------------------------------------------------
Hana_AI.temp_point = Class(object, { --临时点,用来做连续
    init = function(self, x, y, life)
        object.init(self, x, y, 0, LAYER_ENEMY_BULLET + 1)
        task.New(self, function()
            task.Wait(life)
            RawKill(self)
        end)
    end,
    frame = function(self)
        --帧动作,就是每帧跑一次
        task.Do(self)
    end
}, true)
Hana_AI.information_display = Class(object, { --用与于显示系统信息
    init = function(self, mode, ver_x, ver_y, bullet_num, laser_num, bullet_special_case_num, bent_laser_num)
        object.init(self, 0, 0, 0, LAYER_TOP)
        task.New(self, function()
            if Hana_AI.Hide == 0 then
                ----------------------------------------------------------------------------------------------
                NewText(720, 480, nil,
                    "AI_Open_F7 to Exit",
                    255, { 252, 242, 240 }, 1, function()
                        local self = task.GetSelf()
                        self.size = 1.2
                        task.Wait(1)
                    end, "ui", "center")
                ----------------------------------------------------------------------------------------------
                if Hana_AI.Slow == 0 then
                    NewText(720, 460, nil,
                        "Move:{High}",
                        255, { 252, 242, 240 }, 1, function()
                            local self = task.GetSelf()
                            self.size = 1
                            task.Wait(1)
                        end, "ui", "center")
                elseif Hana_AI.Slow == 1 then
                    NewText(720, 460, nil,
                        "Move:{Slow}",
                        255, { 252, 242, 240 }, 1, function()
                            local self = task.GetSelf()
                            self.size = 1
                            task.Wait(1)
                        end, "ui", "center")
                end
                ----------------------------------------------------------------------------------------------
                if ver_x or ver_y then
                    ver_x = tonumber(string.format("%.1f", ver_x))
                    ver_y = tonumber(string.format("%.1f", ver_y))
                    NewText(720, 440, nil,
                        "Vector:{" .. ver_x .. "," .. ver_y .. "}",
                        255, { 252, 242, 240 }, 1, function()
                            local self = task.GetSelf()
                            self.size = 1
                            task.Wait(1)
                        end, "ui", "center")
                else
                    ver_x = tonumber(string.format("%.1f", ver_x))
                    ver_y = tonumber(string.format("%.1f", ver_y))
                    NewText(720, 440, nil,
                        "Vector:{idle,idle}",
                        255, { 252, 242, 240 }, 1, function()
                            local self = task.GetSelf()
                            self.size = 1
                            task.Wait(1)
                        end, "ui", "center")
                end
                ---------------------------------------------------------------------------------------------
                NewText(720, 420, nil,
                    "Rally:{" ..
                    tonumber(string.format("%.1f", Hana_AI.Return_point_x)) ..
                    "," .. tonumber(string.format("%.1f", Hana_AI.Return_point_y)) .. "}",
                    255, { 252, 242, 240 }, 1, function()
                        local self = task.GetSelf()
                        self.size = 1
                        task.Wait(1)
                    end, "ui", "center")
                ----------------------------------------------------------------------------------------------
                if Hana_AI.Return_point_open_return == 1 then
                    NewText(720, 400, nil,
                        "return:{True }",
                        255, { 252, 242, 240 }, 1, function()
                            local self = task.GetSelf()
                            self.size = 1
                            task.Wait(1)
                        end, "ui", "center")
                else
                    NewText(720, 400, nil,
                        "return:{False}",
                        255, { 252, 242, 240 }, 1, function()
                            local self = task.GetSelf()
                            self.size = 1
                            task.Wait(1)
                        end, "ui", "center")
                end
                NewText(720, 360, nil,
                    "Bullet:{" .. bullet_num .. "}",
                    255, { 252, 242, 240 }, 1, function()
                        local self = task.GetSelf()
                        self.size = 1
                        task.Wait(1)
                    end, "ui", "center")
                NewText(800, 360, nil,
                    "Special_Bullet:{" .. bullet_special_case_num .. "}",
                    255, { 252, 242, 240 }, 1, function()
                        local self = task.GetSelf()
                        self.size = 1
                        task.Wait(1)
                    end, "ui", "center")
                local laser_num_ai = Hana_AI.ai_c.Get_ai_attribute(4)
                NewText(720, 340, nil,
                    "Laser:{" .. laser_num .. "," .. int(laser_num_ai) .. "}",
                    255, { 252, 242, 240 }, 1, function()
                        local self = task.GetSelf()
                        self.size = 1
                        task.Wait(1)
                    end, "ui", "center")
                NewText(720, 320, nil,
                    "BentLaser:{" .. bent_laser_num .. "}",
                    255, { 252, 242, 240 }, 1, function()
                        local self = task.GetSelf()
                        self.size = 1
                        task.Wait(1)
                    end, "ui", "center")
                ----------------------------------------------------------------------------------------------
                if Hana_AI.true_player == 0 then
                    NewText(280, 520, nil,
                        "Route:{" .. "extra" .. "}-You are now on the expansion path", --切换是219个方向还是8个方向
                        255, { 252, 242, 240 }, 1, function()
                            local self = task.GetSelf()
                            self.size = 1
                            task.Wait(1)
                        end, "ui", "center")
                else
                    NewText(280, 520, nil,
                        "Route:{" .. "player" .. "}-Warning, you are now on the normal moving path", --切换是219个方向还是8个方向
                        255, { 252, 242, 240 }, 1, function()
                            local self = task.GetSelf()
                            self.size = 1
                            task.Wait(1)
                        end, "ui", "center")
                end
                ----------------------------------------------------------------------------------------------
                ----------------------------------------------------------------------------------------------
                if Hana_AI.Stren_return == 1 then --强化返回模式--intensify
                    NewText(800, 460, nil,
                        "Intensify_return:{True }",
                        255, { 252, 242, 240 }, 1, function()
                            local self = task.GetSelf()
                            self.size = 1
                            task.Wait(1)
                        end, "ui", "center")
                else
                    NewText(800, 460, nil,
                        "Intensify_return:{False}",
                        255, { 252, 242, 240 }, 1, function()
                            local self = task.GetSelf()
                            self.size = 1
                            task.Wait(1)
                        end, "ui", "center")
                end
            end
            ----------------------------------------------------------------------------------------------
            task.Wait(1)
            RawKill(self)
        end)
    end,
    frame = function(self)
        --帧动作,就是每帧跑一次
        task.Do(self)
    end
}, true)
--这里是设置所需的变量
local operation_cd = 0 --看得出来您是真喜欢全局变量啊 --operation_cd = 0 --操作cd,整体共用
if not _debug.hana_ai then
    operation_cd = 1
end
function Hana_AI.Set_switch()
    --检测按键来进行操作
    if operation_cd == 0 then
        local key, KEY = GetLastKey(), KEY --用于获取按键信息
        if key == KEY.F7 then
            --开机与关闭
            if Hana_AI.Start_state == 0 then
                Hana_AI.Start_state = 1
                operation_cd = 10
                PlaySound('ok00', 0.3)
            else
                Hana_AI.Start_state = 0
                PlaySound('cancel00', 0.3)
                operation_cd = 10
            end
        end
        if Hana_AI.Start_state == 1 then
            --检测是否开机，开机则进行检测
            if key == KEY.H then
                --隐藏
                if Hana_AI.Hide == 0 then
                    Hana_AI.Hide = 1
                    operation_cd = 10
                    PlaySound('ok00', 0.3)
                else
                    Hana_AI.Hide = 0
                    PlaySound('cancel00', 0.3)
                    operation_cd = 10
                end
            end
            if key == KEY.P then
                --隐藏
                if Hana_AI.true_player == 0 then
                    Hana_AI.true_player = 1
                    operation_cd = 10
                    PlaySound('ok00', 0.3)
                else
                    Hana_AI.true_player = 0
                    PlaySound('cancel00', 0.3)
                    operation_cd = 10
                end
            end
            if key == KEY.R then --是否强化返回功能
                --隐藏
                if Hana_AI.Stren_return == 0 then
                    Hana_AI.Stren_return = 1
                    operation_cd = 10
                    PlaySound('ok00', 0.3)
                else
                    Hana_AI.Stren_return = 0
                    PlaySound('cancel00', 0.3)
                    operation_cd = 10
                end
            end
        end
    else
        if _debug.hana_ai then
            operation_cd = operation_cd - 1
        end
    end
end

function Hana_AI.Walking_diagram_correction(dx, dy)
    --用来修正行走图,放在自机系统的["frame.move"]末端
    if Hana_AI.Start_state == 1 and Hana_AI.true_player == 0 then
        player.x = player.x - dx
        player.y = player.y - dy
    end
end

function Hana_AI.Walking_diagram_ang_conversion(angle)
    --输入角度,用与修改自机行走图方向
    if angle < 0 then
        angle = 360 + angle
    end
    if angle % 45 > 22.5 then
        angle = int(angle / 45) + 1
    else
        angle = int(angle / 45)
    end
    if angle == 0 then
        player.__right_flag = true
    elseif angle == 1 then
        player.__right_flag = true
        player.__up_flag = true
    elseif angle == 2 then
        player.__up_flag = true
    elseif angle == 3 then
        player.__left_flag = true
        player.__up_flag = true
    elseif angle == 4 then
        player.__left_flag = true
    elseif angle == 5 then
        player.__left_flag = true
        player.__down_flag = true
    elseif angle == 6 then
        player.__down_flag = true
    else
        player.__right_flag = true
        player.__down_flag = true
    end
end

local ffi = require("ffi")
Hana_AI.ai_c = ffi.load("violet_intel.dll")
ffi.cdef [[
    void Tabulation(short num,double x,double y,double move_x,double move_y,double size);//定义弹幕的结构体
    void Laser_Loading(short num,double x1,double y1,double x2,double y2 ,double with_1,double len);//定义激光的结构体
    void Bent_Laser_Point_Loading(int num,double x,double y,double size);//定义曲线激光的点
    void set_world(double l,double r,double b,double t);//设置世界边界,记得调用一下
    void execute(double ang,double p_x,double p_y,int  bullet_num, int laser_num, int bent_laser_num);//主体部分,不会返回值
    //double Dist(double *x1,double *y1,double *x2 , double *y2);//取距离,不在lua中使用,不确定需不需要
    void set_state(int num,int parameter);//传入数据，来改变AI状态
    double Get_ai_attribute(int num);//使用这个获得数据
]]
local lstg_l, lstg_r, lstg_b, lstg_t = lstg.world.l - 12, lstg.world.r + 12, lstg.world.b - 12, lstg.world.t + 12
Hana_AI.ai_c.set_world(lstg_l, lstg_r, lstg_b, lstg_t) --目前这个边界是固定的
function Hana_AI.Mouse_control()
    --鼠标控制的部分
    if _debug.hana_ai then
        if Hana_AI.Return_point_cd > 0 then
            Hana_AI.Return_point_cd = Hana_AI.Return_point_cd - 1
            return
        end
    end
    local PointLine_toolkit_Now_x, PointLine_toolkit_Now_y = GetMousePosition() --从窗口左下角获得玩家鼠标位置
    local True_Mouse_x = PointLine_toolkit_Now_x --* (screen.width / cur_setting.resx)) - (screen.width / 2)--获得玩家鼠标的 从左下角开始的真实X位置 减去对应方向长度/2转化为弹幕使用的X坐标
    local True_Mouse_y = PointLine_toolkit_Now_y --* (screen.height / cur_setting.resy)) - (screen.height / 2) + 27--这边不知道为什么不加会有误差--获得玩家鼠标的 从左下角开始的真实Y位置减去对应方向长度/2转化为弹幕使用的Y坐标
    if GetMouseState(0) then
        --左键
        if not (True_Mouse_x <= lstg.world.l or True_Mouse_x >= lstg.world.r or True_Mouse_y <= lstg.world.b or True_Mouse_y >= lstg.world.t) then
            --出界判定
            Hana_AI.Return_point_x, Hana_AI.Return_point_y = True_Mouse_x, True_Mouse_y
            Hana_AI.Return_point_cd = 15
        end
    elseif GetMouseState(1) then
        --中键,开关强制靠近
        if Hana_AI.Return_point_open_return == 1 then
            Hana_AI.Return_point_open_return = 0
            PlaySound('cancel00', 0.3)
        else
            Hana_AI.Return_point_open_return = 1
            PlaySound('ok00', 0.3)
        end
        Hana_AI.Return_point_cd = 30
    elseif GetMouseState(2) then
        --右键
        Hana_AI.Return_point_x, Hana_AI.Return_point_y = 0, -160
        Hana_AI.Return_point_cd = 15
    end
end

Moving_track_point = {} --自机移动轨迹


function Hana_AI.Frame_action()
    if Hana_AI.Archive_initialization ~= 1 then
        --初始化信息
        scoredata.Hana_AI = {}
        Hana_AI.Archive_initialization = 1
        Hana_AI.Hide = 0 --数据显示隐藏0显示1隐藏
        Hana_AI.Start_state = 0 --启动状态,默认不启动 1启动 0 不启动，存档变量
        Hana_AI.true_player = 0 --选择路径模式
        Hana_AI.Stren_return = 0 --强化返回模式
    end
    Hana_AI.Set_switch() --检测按键操作拉更新设置
    if Hana_AI.Start_state == 0 then
        return --关闭状态,不继续进行
    end
    Hana_AI.Mouse_control() --鼠标控制的部分
    Hana_AI.ai_c.set_state(1, Hana_AI.Stren_return) --设置是否强化返回功能

    --很野蛮的处理方式                               看这里 看这里 这里是追击boss 以及自动B和C的功能 多Boss兼容看Data和模拟操作自行修改
    lstg.SetSplash(true) --开启鼠标显示
    player.__shoot_flag = true
    if IsValid(_boss) then
        if not (_boss.x <= lstg.world.l or _boss.x >= lstg.world.r) then
            Hana_AI.Return_point_x = _boss.x
        end
    else
        Hana_AI.Return_point_x = 0
    end
    if player.__death_state == 0 and player.death > 50 then
        player.__spell_flag = true
        player.__special_flag = true
    end

    local Bullet_list_near = {}   --检测的弹幕列表
    local bullet_size_num = 0     --记录输入的子弹数,目前上限100个
    local laser_size_num = 0      --记录输入的激光数,目前上限100个
    local bent_laser_size_num = 0 --记录输入的曲线激光的点的个数，目前上限为520个
    local bullet_special_case_num = 0
    local Return_dist = 6
    local x_1, x_2 = Hana_AI.Return_point_x + Return_dist, Hana_AI.Return_point_x - Return_dist --临时计算
    local y_1, y_2 = Hana_AI.Return_point_y + Return_dist, Hana_AI.Return_point_y - Return_dist --临时计算
    local priority = 1 --新优先级,1表示左,2表示右,3表示上,4表示下
    local priority_2 = 0 --二级优先级  1表示左,2表示右,3表示上,4表示下
    if Dist(player.x, player.y, Hana_AI.Return_point_x, Hana_AI.Return_point_y) < Return_dist then
        --暂时使用的返回
        priority_2 = 0
    elseif player.x > x_1 then
        if player.y > y_1 then
            --在右上
            priority = 1
            priority_2 = 4
        elseif player.y < y_2 then
            --在右下
            priority = 1
            priority_2 = 3
        else
            priority = 1
            priority_2 = 0
        end
    elseif player.x < x_2 then
        if player.y > y_1 then
            --在左上
            priority = 2
            priority_2 = 4
        elseif player.y < y_2 then
            --在左下
            priority = 2
            priority_2 = 3
        else
            priority = 2
            priority_2 = 0
        end
    else
        if player.y > y_1 then
            --正上
            priority = 4
            priority_2 = 0
        elseif player.y < y_2 then
            --正下
            priority = 3
            priority_2 = 0
        end
    end
    --[[
    local laser_counter, laser_add, laser_end_x, laser_end_y, laser_w
    local laser_add_num = 0
    object.LineLaserDo(function(unit) --读取并且直接写入激光
        if laser_size_num < 100 then  --为c层做准备
            if IsValid(unit) then
                laser_add_num = 0
                laser_size_num = laser_size_num + 1
                laser_add = unit.l1 + unit.l2 + unit.l3 --错误的激光获取方式，暂时没修改
                laser_end_x = unit.x + cos(unit.rot) * laser_add --同样这也是错误的
                laser_end_y = unit.y + sin(unit.rot) * laser_add
                laser_w = unit.w0 --要取半宽
                if laser_w == 0 then
                    laser_w = 3
                end
                Hana_AI.ai_c.Laser_Loading(laser_size_num, laser_end_x, laser_end_y, unit.x, unit.y, laser_w, laser_add)
            end
        end
    end)]]


    local i = 1        --标记被记录的子弹
    local max_coli = 0 --最大碰撞，方便统一
    local max_v, v = 0 --最大速度，和效率优化
    object.BulletIndesEnemyDo(function(unit)
        if unit.colli ~= false and unit ~= _boss then
            max_coli = max(unit.a, unit.b, max_coli)
            v = GetV(unit)
            max_v = max(v, max_v)
        end
    end)
    max_v = max_v * 1.5       --夸大化
    max_coli = max_coli * 1.1 --安全一点
    if Hana_AI.Hide == 0 then
        --外置的UI显示
        NewText(720, 380, nil,
            "Vect_Coli:{" .. string.format("%.1f", max_v) .. "," .. string.format("%.1f", max_coli) .. "}",
            255, { 252, 242, 240 }, 1, function()
                local self = task.GetSelf()
                self.size = 1
                task.Wait(1)
            end, "ui", "center")
    end
    local Dist_1        --效率提高
    local ex_rad = max_coli + max_v + player.A
    local Dist_rad = 45 --High_speed_rad * 10, High_speed_rad * 1.3
    ex_rad = ex_rad + Dist_rad
    Hana_AI.ai_c.set_state(2, ex_rad)
    object.BulletIndesEnemyDo(function(unit)
        if unit.colli ~= false then
            --计算距离，方便计算
            Dist_1 = Dist(unit, player)
            if Dist_1 <= ex_rad then           --足够近,这里选择的是移动范围12倍中,取特别大了
                if bullet_size_num < 100 then  --为c层做准备
                    Bullet_list_near[i] = unit --记录子弹
                    bullet_size_num = bullet_size_num + 1
                    i = i + 1
                end
                return
            end
        end
    end)
    --[[
    local bent_laser_table = {}
    local bent_laser_w, bent_laser_dist --曲线激光这个diaomao的判定
    local ai_ = Hana_AI.ai_c.Bent_Laser_Point_Loading --效率优化
    object.AI_BentLaserDo(function(unit) --diaomao优先个锤子，有数字在子弹里面
        --取w0做全宽，使用半宽
        bent_laser_w = unit.w0 * 0.5 --如果要监测的话 应该是使用 unit._l 来表示长度
        bent_laser_table = unit.data:SampleByLength(bent_laser_w) --这里需要while循环
        for _, point in ipairs(bent_laser_table) do  --遍历组
            bent_laser_dist = Dist(point.x, point.y, player.x, player.y) --在这里ex_rad表示长度
            if bent_laser_dist < ex_rad then --进入需要检测的范围
                if bent_laser_size_num < 520 then --为c层做准备,这里不传入激光，只传入点
                    bent_laser_size_num = bent_laser_size_num + 1
                    ai_(bent_laser_size_num, point.x, point.y, bent_laser_w) --定义曲线激光的点
                end
            end
        end
    end)]]


    ------------------------------------------------------------------------------------
    local Move_vector = {}
    Move_vector["x"] = 0
    Move_vector["y"] = 0
    for _, unit in ipairs(Bullet_list_near) do
        --让每个子弹做动作,进行初步检测
        if IsValid(unit) then
            local Chang_x, Chang_y --变化的x,y
            ------------------------------------------------------------------------------------子弹垂直可视化
            if Hana_AI.Hide == 0 then
                unit.test_temp_x = Move_vector["x"] --用于后面计算差值
                unit.test_temp_y = Move_vector["y"]
            end
            ------------------------------------------------------------------------------------
            if unit.AI_new == nil then
                --初始化判定
                unit.AI_new = 1 --初始化
                unit.last_x = unit.x --记录初始
                unit.last_y = unit.y --记录初始
            else
                --记录差值
                Chang_x = unit.x - unit.last_x --x差值
                Chang_y = unit.y - unit.last_y --y差值
                unit.last_x = unit.x --再次记录
                unit.last_y = unit.y --再次记录
                if Chang_x == 0 and Chang_y == 0 then
                    --静止的弹幕
                    local ang = Angle(unit, player) --产生一个远离开的向量,但是值只有一半
                    local x = cos(ang)
                    local y = sin(ang)
                    Move_vector["x"] = Move_vector["x"] + x * 0.5
                    Move_vector["y"] = Move_vector["y"] + y * 0.5
                else
                    --不是静止的
                    local relative_direction = 0 --子弹相对于玩家的位置(象限),不记录是否为坐标轴上的弹幕
                    local relative__direction_paralle = 0
                    local temp_unit_x, temp_unit_y = unit.x, unit.y
                    local temp_player_x, temp_player_y = player.x, player.y
                    if temp_unit_x > temp_player_x then
                        --判断相对于玩家的象限
                        if temp_unit_y > temp_player_y then
                            relative_direction = 1          --第一象限
                        elseif temp_unit_y < temp_player_y then
                            relative_direction = 4          --第四象限
                        else
                            relative__direction_paralle = 2 --处在x正方向
                        end
                    elseif temp_unit_x < temp_player_x then
                        if temp_unit_y > temp_player_y then
                            relative_direction = 2          --第二象限
                        elseif temp_unit_y < temp_player_y then
                            relative_direction = 3          --第三象限
                        else
                            relative__direction_paralle = 4 --处在x负方向
                        end
                    else
                        --和子弹仅仅Y有区别
                        if temp_unit_y > temp_player_y then
                            relative__direction_paralle = 1 --处在y正方向
                        elseif temp_unit_y < temp_player_y then
                            relative__direction_paralle = 3 --处在y负方向
                        end
                    end
                    local Speed_direction = 0          --记录速度象限
                    local Speed_direction_parallel = 0 --检测速度是否与坐标轴平行
                    if Chang_x > 0 then
                        --判断子弹速度方向
                        if Chang_y > 0 then
                            Speed_direction = 1
                        elseif Chang_y < 0 then
                            Speed_direction = 4
                        else
                            Speed_direction_parallel = 2
                        end
                    elseif Chang_x < 0 then
                        if Chang_y > 0 then
                            Speed_direction = 2
                        elseif Chang_y < 0 then
                            Speed_direction = 3
                        else
                            Speed_direction_parallel = 4
                        end
                    else
                        if Chang_y > 0 then
                            Speed_direction_parallel = 1
                        elseif Chang_y < 0 then
                            Speed_direction_parallel = 3
                        end
                    end
                    local ang = atan(-1 * Chang_y / Chang_x) ----计算垂直线段的k记录角度
                    local x = abs(cos(ang)) --计算出绝对值,以后得改
                    local y = abs(sin(ang)) --计算出绝对值,以后得改
                    if priority == 1 then --非常复杂的地方，测试结果是应该没错误
                        --优先走左边
                        if Speed_direction == 1 or Speed_direction == 3 then
                            --向左上
                            if relative_direction == 2 or relative__direction_paralle == 1 or relative__direction_paralle == 4 then
                                y = -y --特殊,右下
                            else
                                x = -x
                            end
                        elseif Speed_direction == 2 or Speed_direction == 4 then
                            --向左下
                            if relative_direction == 3 or relative__direction_paralle == 3 or relative__direction_paralle == 4 then
                                --右上,不变
                            else
                                x = -x
                                y = -y
                            end
                        elseif Speed_direction_parallel ~= 0 then
                            --一级向左
                            if Speed_direction_parallel == 1 then
                                --y正
                                if priority_2 == 3 then
                                    --左+上
                                    if relative_direction == 2 or relative_direction == 3 or relative__direction_paralle == 4 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    end
                                elseif priority_2 == 4 then
                                    --左+下
                                    if relative_direction == 2 or relative_direction == 3 or relative__direction_paralle == 4 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    end
                                else
                                    --无二级优先级
                                    if relative_direction == 2 or relative_direction == 3 or relative__direction_paralle == 4 then
                                        Move_vector["x"] = Move_vector["x"] + 1 --特殊,正右
                                    else
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    end
                                end
                            elseif Speed_direction_parallel == 2 then
                                --x正
                                if priority_2 == 3 then
                                    --左+上
                                    if relative_direction == 1 or relative_direction == 2 or relative__direction_paralle == 1 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    end
                                elseif priority_2 == 4 then
                                    --左+下
                                    if relative_direction == 3 or relative_direction == 4 or relative__direction_paralle == 3 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    end
                                else
                                    --无二级优先级
                                    Move_vector["x"] = Move_vector["x"] + 1
                                end
                            elseif Speed_direction_parallel == 3 then
                                --y负
                                if priority_2 == 3 then
                                    --左+上
                                    if relative_direction == 2 or relative_direction == 3 or relative__direction_paralle == 4 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    end
                                elseif priority_2 == 4 then
                                    --左+下
                                    if relative_direction == 2 or relative_direction == 3 or relative__direction_paralle == 4 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    end
                                else
                                    --无二级优先级
                                    if relative_direction == 2 or relative_direction == 3 or relative__direction_paralle == 4 then
                                        Move_vector["x"] = Move_vector["x"] + 1 --特殊,正右
                                    else
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    end
                                end
                            elseif Speed_direction_parallel == 4 then
                                --x负
                                if priority_2 == 3 then
                                    --左+上
                                    if relative_direction == 1 or relative_direction == 2 or relative__direction_paralle == 1 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    end
                                    Move_vector["y"] = Move_vector["y"] + 1
                                elseif priority_2 == 4 then
                                    --左+下
                                    if relative_direction == 3 or relative_direction == 4 or relative__direction_paralle == 3 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    end
                                else
                                    --无二级优先级
                                    Move_vector["x"] = Move_vector["x"] - 1
                                end
                            end
                        end
                        ------------------------------------------------------------------------------------------------------------------------------------------------
                    elseif priority == 2 then
                        --优先右
                        if Speed_direction == 1 or Speed_direction == 3 then
                            if relative_direction == 4 or relative__direction_paralle == 2 or relative__direction_paralle == 3 then
                                x = -x --特殊,向左上
                            else
                                --向右下
                                y = -y
                            end
                        elseif Speed_direction == 2 or Speed_direction == 4 then
                            if relative_direction == 1 or relative__direction_paralle == 1 or relative__direction_paralle == 2 then
                                --特殊,左下
                                x = -1 * x
                                y = -1 * y
                            else
                                --向右上 -- 不变
                            end
                        elseif Speed_direction_parallel ~= 0 then
                            if Speed_direction_parallel == 1 then
                                --y正
                                if priority_2 == 3 then
                                    --右+上
                                    if relative_direction == 1 or relative_direction == 4 or relative__direction_paralle == 2 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    end
                                elseif priority_2 == 4 then
                                    --右+下
                                    if relative_direction == 1 or relative_direction == 4 or relative__direction_paralle == 2 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    end
                                else
                                    --无二级优先级
                                    if relative_direction == 1 or relative_direction == 4 or relative__direction_paralle == 2 then
                                        Move_vector["x"] = Move_vector["x"] - 1 --特殊,正右
                                    else
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    end
                                end
                            elseif Speed_direction_parallel == 2 then
                                --x正
                                if priority_2 == 3 then
                                    --右+上
                                    if relative_direction == 1 or relative_direction == 2 or relative__direction_paralle == 1 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    end
                                elseif priority_2 == 4 then
                                    --右+下
                                    if relative_direction == 3 or relative_direction == 4 or relative__direction_paralle == 3 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    end
                                else
                                    --无二级优先级
                                    Move_vector["x"] = Move_vector["x"] + 1
                                end
                            elseif Speed_direction_parallel == 3 then
                                --y负
                                if priority_2 == 3 then
                                    --右+上
                                    if relative_direction == 1 or relative_direction == 4 or relative__direction_paralle == 2 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    end
                                elseif priority_2 == 4 then
                                    --右+下
                                    if relative_direction == 1 or relative_direction == 4 or relative__direction_paralle == 2 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    end
                                else
                                    --无二级优先级
                                    if relative_direction == 1 or relative_direction == 4 or relative__direction_paralle == 2 then
                                        Move_vector["x"] = Move_vector["x"] - 1 --特殊,正右
                                    else
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    end
                                end
                            elseif Speed_direction_parallel == 4 then
                                --x负
                                if priority_2 == 3 then
                                    --右+上
                                    if relative_direction == 1 or relative_direction == 2 or relative__direction_paralle == 1 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    end
                                elseif priority_2 == 4 then
                                    --右+下
                                    if relative_direction == 3 or relative_direction == 4 or relative__direction_paralle == 3 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    end
                                else
                                    --无二级优先级
                                    Move_vector["x"] = Move_vector["x"] - 1
                                end
                            end
                        end
                    elseif priority == 3 then
                        --优先上
                        if Speed_direction == 1 or Speed_direction == 3 then
                            if relative_direction == 2 or relative__direction_paralle == 1 or relative__direction_paralle == 4 then
                                y = -1 * y --特殊右下
                            else
                                --向左上
                                x = -x
                            end
                        elseif Speed_direction == 2 or Speed_direction == 4 then
                            if relative_direction == 1 or relative__direction_paralle == 1 or relative__direction_paralle == 2 then
                                --特殊,左下
                                x = -x
                                y = -y
                            else
                                --向右上 -- 不变
                            end
                        elseif Speed_direction_parallel ~= 0 then
                            if Speed_direction_parallel == 1 then
                                --y正
                                if priority_2 == 2 then
                                    --右+上
                                    if relative_direction == 1 or relative_direction == 4 or relative__direction_paralle == 2 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    end
                                elseif priority_2 == 1 then
                                    --左+上
                                    if relative_direction == 2 or relative_direction == 3 or relative__direction_paralle == 4 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    end
                                else
                                    --无二级优先级
                                    Move_vector["y"] = Move_vector["y"] + 1
                                end
                            elseif Speed_direction_parallel == 2 then
                                --x正
                                if priority_2 == 2 then
                                    --右+上
                                    if relative_direction == 1 or relative_direction == 2 or relative__direction_paralle == 1 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    end
                                elseif priority_2 == 1 then
                                    --左+上
                                    Move_vector["y"] = Move_vector["y"] + 1
                                else
                                    --无二级优先级
                                    if relative_direction == 1 or relative_direction == 2 or relative__direction_paralle == 1 then
                                        Move_vector["y"] = Move_vector["y"] - 1 --特殊,正下
                                    else
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    end
                                end
                            elseif Speed_direction_parallel == 3 then
                                --y负
                                if priority_2 == 2 then
                                    --右+上
                                    if relative_direction == 1 or relative_direction == 4 or relative__direction_paralle == 2 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    end
                                elseif priority_2 == 1 then
                                    --左+上
                                    if relative_direction == 2 or relative_direction == 3 or relative__direction_paralle == 4 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    end
                                else
                                    --无二级优先级
                                    Move_vector["y"] = Move_vector["y"] - 1
                                end
                            elseif Speed_direction_parallel == 4 then
                                --x负
                                if priority_2 == 2 then
                                    --右+上
                                    if relative_direction == 1 or relative_direction == 2 or relative__direction_paralle == 1 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    end
                                elseif priority_2 == 1 then
                                    --左+上
                                    Move_vector["y"] = Move_vector["y"] + 1
                                else
                                    --无二级优先级
                                    if relative_direction == 1 or relative_direction == 2 or relative__direction_paralle == 1 then
                                        Move_vector["y"] = Move_vector["y"] - 1 --特殊,正下
                                    else
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    end
                                end
                            end
                        end
                    elseif priority == 4 then
                        --优先下
                        if Speed_direction == 1 or Speed_direction == 3 then
                            if relative_direction == 4 or relative__direction_paralle == 2 or relative__direction_paralle == 3 then
                                x = -x --特殊左上
                            else
                                --向右下
                                y = -y
                            end
                        elseif Speed_direction == 2 or Speed_direction == 4 then
                            if relative_direction == 3 or relative__direction_paralle == 4 or relative__direction_paralle == 1 then
                                --特殊向右上
                            else
                                --向左下
                                x = -x
                                y = -y
                            end
                        elseif Speed_direction_parallel ~= 0 then
                            if Speed_direction_parallel == 1 then
                                --y正
                                if priority_2 == 2 then
                                    --右+下
                                    if relative_direction == 1 or relative_direction == 4 or relative__direction_paralle == 2 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    end
                                elseif priority_2 == 1 then
                                    --左+下
                                    if relative_direction == 2 or relative_direction == 3 or relative__direction_paralle == 4 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    end
                                else
                                    --无二级优先级
                                    Move_vector["y"] = Move_vector["y"] + 1
                                end
                            elseif Speed_direction_parallel == 2 then
                                --x正
                                if priority_2 == 2 then
                                    --右+下
                                    if relative_direction == 3 or relative_direction == 4 or relative__direction_paralle == 3 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    end
                                elseif priority_2 == 1 then
                                    --左+下
                                    if relative_direction == 3 or relative_direction == 4 or relative__direction_paralle == 3 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    end
                                else
                                    --无二级优先级
                                    if relative_direction == 3 or relative_direction == 4 or relative__direction_paralle == 3 then
                                        Move_vector["y"] = Move_vector["y"] + 1 --特殊,正下
                                    else
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    end
                                end
                            elseif Speed_direction_parallel == 3 then
                                --y负
                                if priority_2 == 2 then
                                    --右+下
                                    if relative_direction == 1 or relative_direction == 4 or relative__direction_paralle == 2 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    end
                                elseif priority_2 == 1 then
                                    --左+下
                                    if relative_direction == 2 or relative_direction == 3 or relative__direction_paralle == 4 then
                                        --特殊*
                                        Move_vector["x"] = Move_vector["x"] + 1
                                    else
                                        Move_vector["x"] = Move_vector["x"] - 1
                                    end
                                else
                                    --无二级优先级
                                    Move_vector["y"] = Move_vector["y"] - 1
                                end
                            elseif Speed_direction_parallel == 4 then
                                --x负
                                if priority_2 == 2 then
                                    --右+下
                                    if relative_direction == 3 or relative_direction == 4 or relative__direction_paralle == 3 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    end
                                elseif priority_2 == 1 then
                                    --左+下
                                    if relative_direction == 3 or relative_direction == 4 or relative__direction_paralle == 3 then
                                        --特殊*
                                        Move_vector["y"] = Move_vector["y"] + 1
                                    else
                                        Move_vector["y"] = Move_vector["y"] - 1
                                    end
                                else
                                    --无二级优先级
                                    Move_vector["y"] = Move_vector["y"] - 1
                                end
                            end
                        end
                    end
                    if Speed_direction_parallel == 0 then
                        --正常加减
                        Move_vector["x"] = Move_vector["x"] + x
                        Move_vector["y"] = Move_vector["y"] + y
                    end
                    ------------------------------------------------------------------------------------子弹垂直可视化
                    if Hana_AI.Hide == 0 then
                        local x = unit.test_temp_x - Move_vector["x"] --用于后面计算差值
                        local y = unit.test_temp_y - Move_vector["y"]
                        --[[这里可以查看子弹对应的属性，因为测试表示稳定即不会主动显示
                        NewText(unit.x+440, unit.y+250+unit.a, nil,
                        "{"..priority..","..priority_2..","..relative_direction..","..relative__direction_paralle..","..Speed_direction..","..Speed_direction_parallel..",}",
                        255, { 252, 242, 240 }, 1, function()
                            local self = task.GetSelf()
                            self.size = 1
                            task.Wait(1)
                        end, "ui", "center")--]]
                    end
                    ------------------------------------------------------------------------------------
                end
            end
        end
    end
    ------------------------------------------------------------------------------------
    if Move_vector["x"] ~= 0 or Move_vector["y"] ~= 0 --[[or laser_size_num ~= 0 or bent_laser_size_num ~= 0]] then
        --可以行动
        local ai = Hana_AI.ai_c --效率优化
        local ang
        if Move_vector["x"] ~= 0 or Move_vector["y"] ~= 0 then --有子弹的情况，有决策
            if Hana_AI.Return_point_open_return == 1 then
                --返回
                if Dist(player.x, player.y, Hana_AI.Return_point_x, Hana_AI.Return_point_y) > Return_dist then --这里之前忘记搞了
                    ang = Angle(player.x, player.y, Hana_AI.Return_point_x, Hana_AI.Return_point_y)
                    Move_vector["x"] = Move_vector["x"] + cos(ang) * 8 --强力的返回
                    Move_vector["y"] = Move_vector["y"] + sin(ang) * 8
                end
            end
            ang = Angle(0, 0, Move_vector["x"], Move_vector["y"])
            ang = ang - 110
            local bullet_table
            for i = 1, bullet_size_num do
                bullet_table = Bullet_list_near[i]
                ai.Tabulation(i - 1, bullet_table.x, bullet_table.y, bullet_table.dx, bullet_table.dy, bullet_table.a) --这里size直接传入了a,得改
            end
        else --无子弹有激光的情况，无决策
            ang = Angle(player.x, player.y, Hana_AI.Return_point_x, Hana_AI.Return_point_y)
            ang = ang - 110
        end
        ai.execute(ang, player.x, player.y, bullet_size_num, laser_size_num, bent_laser_size_num)
        --不是你这直接写全局变量？
        local x = ai.Get_ai_attribute(1) --x = ai.Get_ai_attribute(1)
        local y = ai.Get_ai_attribute(2) --y = ai.Get_ai_attribute(2)
        if ai.Get_ai_attribute(3) > 5 then
            Hana_AI.Slow = 0
            player.__slow_flag = false
        else
            Hana_AI.Slow = 1
            player.__slow_flag = true
        end
        local no_danger = ai.Get_ai_attribute(5)
        --local laser_num_ai = Hana_AI.ai_c.Get_ai_attribute(4)
        if no_danger < 5 then --大于10的话无弹幕，不动
            if Hana_AI.true_player == 1 then --如果是玩家移动模式
                ang = Angle(0, 0, x, y)
                Hana_AI.Walking_diagram_ang_conversion(ang)
            else --否，扩展移动模式
                if --[[laser_num_ai ~= 0 or bent_laser_size_num ~= 0 or]] bullet_size_num ~= 0 then
                    player.x = player.x + x
                    player.y = player.y + y
                    ang = Angle(0, 0, x, y)
                    Hana_AI.Walking_diagram_ang_conversion(ang)
                end
            end
        else --这段和下面是重复的，我不想移动if，太多了
            if Dist(player.x, player.y, Hana_AI.Return_point_x, Hana_AI.Return_point_y) > Return_dist then
                local ang = Angle(player.x, player.y, Hana_AI.Return_point_x, Hana_AI.Return_point_y)
                local x = 4.5 * cos(ang) --High_speed_rad * cos(ang)
                local y = 4.5 * sin(ang) -- High_speed_rad * sin(ang)
                if Hana_AI.true_player == 1 then
                    Hana_AI.Walking_diagram_ang_conversion(ang)
                    player.__slow_flag = false
                    Hana_AI.Slow = 0
                    unit = New(Hana_AI.temp_point, player.x + x * 2, player.y + y * 2, 30)
                else
                    player.x = player.x + x
                    player.y = player.y + y
                    Hana_AI.Walking_diagram_ang_conversion(ang)
                    player.__slow_flag = false
                    Hana_AI.Slow = 0
                    unit = New(Hana_AI.temp_point, player.x + x * 2, player.y + y * 2, 30)
                end
            end
        end
    else
        --无行动目标,开始返回记录点
        if Dist(player.x, player.y, Hana_AI.Return_point_x, Hana_AI.Return_point_y) > Return_dist then
            local ang = Angle(player.x, player.y, Hana_AI.Return_point_x, Hana_AI.Return_point_y)
            local x = 4.5 * cos(ang) --High_speed_rad * cos(ang)
            local y = 4.5 * sin(ang) -- High_speed_rad * sin(ang)
            if Hana_AI.true_player == 1 then
                Hana_AI.Walking_diagram_ang_conversion(ang)
                player.__slow_flag = false
                Hana_AI.Slow = 0
                unit = New(Hana_AI.temp_point, player.x + x * 2, player.y + y * 2, 30)
            else
                player.x = player.x + x
                player.y = player.y + y
                Hana_AI.Walking_diagram_ang_conversion(ang)
                player.__slow_flag = false
                Hana_AI.Slow = 0
                unit = New(Hana_AI.temp_point, player.x + x * 2, player.y + y * 2, 30)
            end
        end
    end
    New(Hana_AI.information_display, Slow_use, Move_vector["x"], Move_vector["y"], bullet_size_num, laser_size_num,
        bullet_special_case_num, bent_laser_size_num) --显示信息
end
