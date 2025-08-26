---THAIC Arranged
--From (附带文件)避弹AI设计原理与实现.docx in 群文件
--听说是把直流群搞炸了的那位的杰作
--整个是个非常谔谔的if堆出来的屎山，而且我严重怀疑是个半成品，但我根本做不出来所以没资格说什么
--去除了谔谔的需要GROUP_LASER组（请在看到这东西时对自己进行记忆清除，忘掉有这个东西，因为它根本不存在）的激光检测
--去除了对scoredata的调用，提高效率（更重要的是这玩意放在和core同级的话不知道为什么没法调用scoredata）
--去除了大量未使用或无效的方法，而且有一个每帧创建obj偷吃我性能（咬牙切齿
--现在这个版本应该可以拿到任何私坑里用了

Hana_AI = {} --初始化，放在了初始化函数里面
Hana_AI.Return_point_x, Hana_AI.Return_point_y = 0, -160 --返回点初始化
Hana_AI.Return_point_cd = 1 --鼠标操作CD
Hana_AI.Return_point_open_return = 1 --1表示开启,会在有弹幕的区域进行指向移动
function Hana_AI_initialization()
    --包括了部分的初始化
    if Hana_AI.Archive_initialization ~= 1 then
        --初始化信息
        --scoredata.Hana_AI = {}
        Hana_AI.Archive_initialization = 1
        Hana_AI.Start_state = 0  --启动状态 --F7键
        Hana_AI.true_player = 0  --选择路径模式 --P键
        Hana_AI.Stren_return = 0 --强化返回模式 --R键
    end
end

Hana_AI_initialization() --存档初始化函数
local abs, max, min = math.abs, math.max, math.min --效率优化

--临时点,用来做连续
Hana_AI.temp_point = Class(object)

function Hana_AI.temp_point:init(x, y, life)
    self.x = x
    self.y = y
    self.layer = LAYER_ENEMY_BULLET + 1
    task.New(self, function()
        task.Wait(life)
        RawKill(self)
    end)
end

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

--这里是设置所需的变量
local operation_cd = 0 --看得出来您是真喜欢全局变量啊
--operation_cd = 0 --操作cd,整体共用

function Hana_AI.Set_switch()
    --检测按键来进行操作
    if operation_cd == 0 then
        local key, KEY = GetLastKey(), KEY --用于获取按键信息
        if key == KEY.F7 and _debug.hana_ai then
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
        --[[
        if Hana_AI.Start_state == 1 then
            --检测是否开机，开机则进行检测
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
        --]]
    else
        operation_cd = operation_cd - 1
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
    --输入角度,用于修改自机行走图方向
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
Hana_AI.ai_c.set_world(lstg_l, lstg_r, lstg_b, lstg_t) --目前这个边界是固定的 --需要修改
function Hana_AI.Mouse_control()
    --鼠标控制的部分
    if _debug.hana_ai and Hana_AI.Return_point_cd > 0 then
        Hana_AI.Return_point_cd = Hana_AI.Return_point_cd - 1
        return
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

function Hana_AI.Frame_action()
    if Hana_AI.Archive_initialization ~= 1 then
        --初始化信息
        Hana_AI.Archive_initialization = 1
        Hana_AI.Start_state = 0
        Hana_AI.true_player = 0
        Hana_AI.Stren_return = 0
    end
    Hana_AI.Set_switch() --检测按键操作拉更新设置
    if Hana_AI.Start_state == 0 then
        return --关闭状态,不继续进行
    end
    Hana_AI.Mouse_control() --鼠标控制的部分
    Hana_AI.ai_c.set_state(1, Hana_AI.Stren_return) --设置是否强化返回功能

    --很野蛮的处理方式
    --看这里 看这里 这里是追击boss 以及自动B和C的功能 多Boss兼容看Data和模拟操作自行修改
    --lstg.SetSplash(true) --开启鼠标显示
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
    if Move_vector["x"] ~= 0 or Move_vector["y"] ~= 0 then
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
        --x = ai.Get_ai_attribute(1)
        --y = ai.Get_ai_attribute(2)
        local x = ai.Get_ai_attribute(1)
        local y = ai.Get_ai_attribute(2)
        if ai.Get_ai_attribute(3) > 5 then
            Hana_AI.Slow = 0
            player.__slow_flag = false
        else
            Hana_AI.Slow = 1
            player.__slow_flag = true
        end
        local no_danger = ai.Get_ai_attribute(5)
        if no_danger < 5 then --大于10的话无弹幕，不动
            if Hana_AI.true_player == 1 then --如果是玩家移动模式
                ang = Angle(0, 0, x, y)
                Hana_AI.Walking_diagram_ang_conversion(ang)
            else --否，扩展移动模式
                if bullet_size_num ~= 0 then
                    player.x = player.x + x
                    player.y = player.y + y
                    ang = Angle(0, 0, x, y)
                    Hana_AI.Walking_diagram_ang_conversion(ang)
                end
            end
        else --这段和下面是重复的，我不想移动if，太多了
            if Dist(player.x, player.y, Hana_AI.Return_point_x, Hana_AI.Return_point_y) > Return_dist then
                local ang = Angle(player.x, player.y, Hana_AI.Return_point_x, Hana_AI.Return_point_y)
                local x = player.hspeed * cos(ang)
                local y = player.hspeed * sin(ang)
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
            local x = player.hspeed * cos(ang)
            local y = player.hspeed * sin(ang)
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
end
