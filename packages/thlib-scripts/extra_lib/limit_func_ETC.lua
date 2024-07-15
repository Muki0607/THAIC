---===========================
---空气墙支持 Code by ETC Arranged by Muki
---===========================

---THAIC Arranged
--============================
--Muki-2024/7/15-v1.1aic
--更新：1、将整个库整合入aic.act中
--------2、将代码按照emmylua的方式格式化，更加易读
--------3、删去了不需要的多玩家支持

--ETC-2018/5/16-v1.1
--更新：1、更改点位置变换的方式
--------2、更新了多个函数的写法
--------3、更新了显示方式，可以区分内外了
--------4、抄了一个渲染圆环的方法

--ETC-2018/4/20-v1.0
--更新：1、增加了对ex+多玩家的支持
--------2、修复了lib.RectLimitIn的y参数赋值问题
--------3、抄了一份圆的渲染
--------4、弄了一套显示系统，可以通过misc_showlimit来显示

--ETC-2018/4/19-v0.9
--更新：1、整合成可重复使用的函数

--ETC-2018/4/15-v0.5
--更新：1、完成矩形的空气墙

--ETC-2018/4/10-v0.1
--更新：1、完成圆的空气墙
--============================

local lib = aic.rpg

--该函数用于点的坐标旋转变换
function lib.positionRot(x, y, angle)
    local c, d = (x * cos(angle) + y * sin(angle)), (y * cos(angle) - x * sin(angle))
    return c, d
end

--该函数用于点表的坐标旋转变换
function lib.positionListRot(positionList, angle)
    local tmplist = {}

    for i = 1, #positionList do
        local x, y = lib.positionRot(positionList[i][1], positionList[i][2], angle)

        tmplist[i] = {}
        tmplist[i][1], tmplist[i][2] = x, y
    end

    return tmplist
end

--该函数用于获取点表相对0,0的角度
function lib.GetPositionListAngle(positionList)
    local tmplist = {}

    for i = 1, #positionList do
        tmplist[i] = Angle(0, 0, positionList[i][1], positionList[i][2])
    end

    return tmplist
end

--一个提供渲染碰撞边界的表
--由于限制函数需每帧调用，该方法不可行
lib.LimitRenderList = {}
--table.insert(lib.LimitRenderList,xxx)
--数据:{1,centerx,centery,radius1,radius2}{2,centerx,centery,a,b,rot,IsOut}

--该函数用于创建一个限制自机在内的圈
function lib.CircleLimitIn(player, centerx, centery, radius)
    --table.insert(lib.LimitRenderList, { 1, centerx, centery, radius, 800 })
    if player.death == 0 and not player.lock then
        local STA = Angle(centerx, centery, player.x, player.y)
        --限制x轴
        if player.x > centerx then
            player.x = min(player.x, centerx + radius * cos(STA))
        else
            player.x = max(player.x, centerx + radius * cos(STA))
        end
        --限制y轴
        if player.y > centery then
            player.y = min(player.y, centery + radius * sin(STA))
        else
            player.y = max(player.y, centery + radius * sin(STA))
        end
    end
end

--该函数用于创建一个限制自机在外的圈
function lib.CircleLimitOut(player, centerx, centery, radius)
    --table.insert(lib.LimitRenderList, { 1, centerx, centery, 0, radius })
    if player.death == 0 and not player.lock then
        local STA = Angle(centerx, centery, player.x, player.y)
        --限制x轴
        if player.x > centerx then
            player.x = max(player.x, centerx + radius * cos(STA))
        else
            player.x = min(player.x, centerx + radius * cos(STA))
        end
        --限制y轴
        if player.y > centery then
            player.y = max(player.y, centery + radius * sin(STA))
        else
            player.y = min(player.y, centery + radius * sin(STA))
        end
    end
end

--该函数用于创建一个限制自机在内的矩形
function lib.RectLimitIn(player, centerx, centery, a, b, angle)
    --table.insert(lib.LimitRenderList, { 2, centerx, centery, a, b, angle, false })
    if player.death == 0 and not player.lock then
        --变换坐标
        local tmpx1, tmpy1 = lib.positionRot(player.x - centerx, player.y - centery, -angle)
        --限制坐标范围
        local tmpx2 = max(-a, min(tmpx1, a))
        local tmpy2 = max(-b, min(tmpy1, b))
        local tmpx3, tmpy3 = lib.positionRot(tmpx2, tmpy2, angle)
        player.x, player.y = tmpx3 + centerx, tmpy3 + centery
    end
end

--该函数用于创建一个限制自机在外的矩形
function lib.RectLimitOut(player, centerx, centery, a, b, angle)
    --table.insert(lib.LimitRenderList, { 2, centerx, centery, a, b, angle, true })

    if player.death == 0 and not player.lock then
        --四个顶点的位置表
        local positionlist = {
            { a,  b },
            { a,  -b },
            { -a, -b },
            { -a, b }
        }
        --得到四个顶点的角度
        local Alist = {}
        Alist = lib.GetPositionListAngle(positionlist)
        --变换player坐标
        local tmpx1, tmpy1 = lib.positionRot(player.x - centerx, player.y - centery, -angle)
        --限制player坐标
        local STA = Angle(0, 0, tmpx1, tmpy1)
        local tmpx2, tmpy2 = tmpx1, tmpy1
        if STA >= Alist[2] and STA < Alist[1]
        then
            tmpx2 = max(tmpx2, a)
        elseif (STA >= Alist[4] and STA < 180) or (STA >= -180 and STA < Alist[3])
        then
            tmpx2 = min(tmpx2, -a)
        elseif STA >= Alist[1] and STA < Alist[4]
        then
            tmpy2 = max(tmpy2, b)
        elseif STA >= Alist[3] and STA < Alist[2]
        then
            tmpy2 = min(tmpy2, -b)
        end
        --还原player坐标
        local tmpx3, tmpy3 = lib.positionRot(tmpx2, tmpy2, angle)
        player.x, player.y = centerx + tmpx3, centery + tmpy3
    end
end

--用于显示边界的object
lib.showlimit = Class(object) --special键可以开启显示，Del(lstg.tmpvar.misc_showlimit)可以删除自身
function lib.showlimit:init()
    self.x = 0
    self.y = 0
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + 2
    lstg.tmpvar.showlimit = self
    self.show = 1
end

function lib.showlimit:frame()
    if KeyIsPressed('special')
    then
        self.show = self.show * (-1)
    end
end

function lib.showlimit:render()
    if self.show == 1 then
        for i = 1, #lib.LimitRenderList do
            if lib.LimitRenderList[i][1] == 1 then
                SetImageState('white', '', Color(128, 255, 255, 255))
                lib.RenderCirque(lib.LimitRenderList[i][2], lib.LimitRenderList[i][3], lib.LimitRenderList[i][4],
                    lib.LimitRenderList[i][5], 180, '', Color(128, 255, 255, 255))
            elseif lib.LimitRenderList[i][1] == 2 then
                if lib.LimitRenderList[i][7] == true then --渲染限制在矩形外
                    local x, y = lib.LimitRenderList[i][2], lib.LimitRenderList[i][3]
                    local a, b = lib.LimitRenderList[i][4], lib.LimitRenderList[i][5]
                    local positionlist = {
                        { a,  b },
                        { a,  -b },
                        { -a, -b },
                        { -a, b }
                    }
                    local plist = lib.positionListRot(positionlist, lib.LimitRenderList[i][6])
                    SetImageState('white', '', Color(128, 255, 255, 255))
                    Render4V('white',
                        plist[1][1] + x, plist[1][2] + y, 0.5,
                        plist[2][1] + x, plist[2][2] + y, 0.5,
                        plist[3][1] + x, plist[3][2] + y, 0.5,
                        plist[4][1] + x, plist[4][2] + y, 0.5
                    )
                else --渲染限制在矩形内
                    local x, y = lib.LimitRenderList[i][2], lib.LimitRenderList[i][3]
                    local a, b = lib.LimitRenderList[i][4], lib.LimitRenderList[i][5]
                    local positionlist1 = {
                        { a,  800 },
                        { a,  b },
                        { -a, b },
                        { -a, 800 }
                    }
                    local positionlist2 = {
                        { a,  -b },
                        { a,  -800 },
                        { -a, -800 },
                        { -a, -b }
                    }
                    local positionlist3 = {
                        { 800, 800 },
                        { 800, -800 },
                        { a,   -800 },
                        { a,   800 }
                    }
                    local positionlist4 = {
                        { -a,   800 },
                        { -a,   -800 },
                        { -800, -800 },
                        { -800, 800 }
                    }
                    local plist1 = lib.positionListRot(positionlist1, lib.LimitRenderList[i][6])
                    local plist2 = lib.positionListRot(positionlist2, lib.LimitRenderList[i][6])
                    local plist3 = lib.positionListRot(positionlist3, lib.LimitRenderList[i][6])
                    local plist4 = lib.positionListRot(positionlist4, lib.LimitRenderList[i][6])
                    SetImageState('white', '', Color(128, 255, 255, 255))
                    Render4V('white',
                        plist1[1][1] + x, plist1[1][2] + y, 0.5,
                        plist1[2][1] + x, plist1[2][2] + y, 0.5,
                        plist1[3][1] + x, plist1[3][2] + y, 0.5,
                        plist1[4][1] + x, plist1[4][2] + y, 0.5
                    )
                    Render4V('white',
                        plist2[1][1] + x, plist2[1][2] + y, 0.5,
                        plist2[2][1] + x, plist2[2][2] + y, 0.5,
                        plist2[3][1] + x, plist2[3][2] + y, 0.5,
                        plist2[4][1] + x, plist2[4][2] + y, 0.5
                    )
                    Render4V('white',
                        plist3[1][1] + x, plist3[1][2] + y, 0.5,
                        plist3[2][1] + x, plist3[2][2] + y, 0.5,
                        plist3[3][1] + x, plist3[3][2] + y, 0.5,
                        plist3[4][1] + x, plist3[4][2] + y, 0.5
                    )
                    Render4V('white',
                        plist4[1][1] + x, plist4[1][2] + y, 0.5,
                        plist4[2][1] + x, plist4[2][2] + y, 0.5,
                        plist4[3][1] + x, plist4[3][2] + y, 0.5,
                        plist4[4][1] + x, plist4[4][2] + y, 0.5
                    )
                end
            end
        end
    end
    lib.LimitRenderList = {}
end

--渲染圆的替代方案
function lib.RenderCircle(x, y, r, point, mix, color)
    local ang = 360 / (2 * point)
    for angle = 360 / point, 360, 360 / point do
        local x1, y1 = x + r * cos(angle + ang), y + r * sin(angle + ang)
        local x2, y2 = x + r * cos(angle - ang), y + r * sin(angle - ang)
        SetImageState('white', mix,
            color,
            color,
            color,
            color)
        Render4V('white',
            x, y, 0.5,
            x, y, 0.5,
            x1, y1, 0.5,
            x2, y2, 0.5)
    end
end

--渲染圆环的替代方案
function lib.RenderCirque(x, y, r1, r2, point, mix, color)
    local ang = 360 / (2 * point)
    for angle = 360 / point, 360, 360 / point do
        local x11, y11 = x + r1 * cos(angle + ang), y + r1 * sin(angle + ang)
        local x12, y12 = x + r1 * cos(angle - ang), y + r1 * sin(angle - ang)
        local x21, y21 = x + r2 * cos(angle + ang), y + r2 * sin(angle + ang)
        local x22, y22 = x + r2 * cos(angle - ang), y + r2 * sin(angle - ang)
        SetImageState('white', mix,
            color,
            color,
            color,
            color
        )
        Render4V('white',
            x12, y12, 0.5,
            x11, y11, 0.5,
            x21, y21, 0.5,
            x22, y22, 0.5
        )
    end
end
