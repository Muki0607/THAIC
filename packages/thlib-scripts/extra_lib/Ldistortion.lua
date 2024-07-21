---@diagnostic disable: assign-type-mismatch
---@Name:原作风Boss背后纹理扭曲特效(lstg.Mesh改进版)
---@Note:基于个人项目未考虑screen.scale等因素,如需使用请自行修改.
---@Author:Eva


---||===============================================================================================================================================||
---||===============================================================================================================================================||
---@生成rendertarget

local DtTex = "rt_eff_distortion_texture"
lstg.CreateRenderTarget(DtTex)
lstg.SetTextureSamplerState(DtTex, "linear+wrap")


---@参数设置
local Cut = 16 ---@网格数(n*n)
local MinRadius = 16 ---@最小半径(px)
local MinDiameter = MinRadius * 2
local Const_Expand = 20 ---@凸透镜衰减范围(px)(还原放大骚气)
local Const_Expand_Radius = 16 ---@凸透镜的线性扩张距离(px)
local PhaseX = 180 ---@顶点初始X相位
local PhaseY = 90 ---@顶点初始Y相位
local PhaseX_i = 90 ---@顶点X相位差
local PhaseY_i = 45 ---@顶点Y相位差
local Blow_RangeX = 10 ---@顶点X振幅
local Blow_RangeY = -10 ---@顶点Y振幅
local Phase_SpeedX = 10 ---@顶点X振荡速度
local Phase_SpeedY = 5 ---@顶点Y振荡速度


---@坐标计算用
local CanvasW, CanvasH = 640, 480 ---@窗口大小
local WorldLeft = lstg.world.l ---@Wolrd坐标系左端-192
local WorldTop = lstg.world.t ---@Wolrd坐标系顶端224

local WorldWidth = lstg.world.r - lstg.world.l ---@World宽
local WorldHeight = lstg.world.t - lstg.world.b ---@World长

local FrameLeft = lstg.world.scrl
local FrameTop = lstg.world.scrt

local BaseU, BaseV = FrameLeft, (CanvasH - FrameTop) ---@World到Uv的XY偏移量


---||===============================================================================================================================================||
---||===============================================================================================================================================||
---@用obj来捕获纹理
local ObjPush = Class(object)
local ObjPop = Class(object)

---@捕获图层layer_A到图层layer_B之间的纹理
function ObjPush:init(layer_A)
    self.layer = layer_A
    self.group = GROUP_GHOST
end

function ObjPush:render()
    PushRenderTarget(DtTex)
    RenderClear(Color(0, 0, 0, 0))
end

---@弹出
function ObjPop:init(layer_A, layer_B)
    self.layer = layer_B
    self.group = GROUP_GHOST
    self.servant = New(ObjPush, layer_A)
end

local function DrawTextureToScreen()
    local Iro = Color(255, 255, 255, 255)
    RenderTexture(DtTex, "one",
        { WorldLeft, WorldTop, 0.5, BaseU + 0, BaseV + 0, Iro },
        { WorldLeft + WorldWidth, WorldTop, 0.5, BaseU + WorldWidth, BaseV + 0, Iro },
        { WorldLeft + WorldWidth, WorldTop - WorldHeight, 0.5, BaseU + WorldWidth, BaseV + WorldHeight, Iro },
        { WorldLeft, WorldTop - WorldHeight, 0.5, BaseU + 0, BaseV + WorldHeight, Iro }
    )
end

function ObjPop:render()
    PopRenderTarget()
    DrawTextureToScreen()
end

---@捕获+绘制纹理
function Distortion_CaptureAndDraw(a, b)
    New(ObjPop, a, b)
end

---||===============================================================================================================================================||
---||===============================================================================================================================================||


---@小轮子,World坐标系转Screen(UV)
local function WorldToUv(x, y)
    return (x + (BaseU + WorldWidth * 0.5)) / CanvasW, (-y + (BaseV + WorldHeight * 0.5)) / CanvasH
end

---@Mesh数据初始化
local VertexN = (Cut + 1) * (Cut + 1) ---@顶点数
local IndexN = Cut * Cut * 6 ---@索引数
local DistortionMesh = lstg.MeshData(VertexN, IndexN) ---@申请lstg.Mesh
local CalculatorMesh = {} ---@存储计算数据用的table

---@DistortionMesh顶点排序如下所示(2x2示例)
---||=======================
---||
---||  0        1        2
---||
---||
---||  3        4        5
---||
---||
---||  6        7        8
---||
---||=======================


---@CalculatorMesh排序如下所示(2x2示例)
---||===============
---||
---||  (1)     (2)
---||
---||
---||  (3)     (4)
---||
---||===============


for j = 0, Cut - 1 do
    for i = 0, Cut - 1 do
        ---@顶点复用索引设置
        DistortionMesh:setIndex(j * (6 * Cut) + i * 6 + 0, j * (Cut + 1) + i + 0)
        DistortionMesh:setIndex(j * (6 * Cut) + i * 6 + 1, j * (Cut + 1) + i + 1)
        DistortionMesh:setIndex(j * (6 * Cut) + i * 6 + 2, (j + 1) * (Cut + 1) + i + 0)

        DistortionMesh:setIndex(j * (6 * Cut) + i * 6 + 3, j * (Cut + 1) + i + 1)
        DistortionMesh:setIndex(j * (6 * Cut) + i * 6 + 4, (j + 1) * (Cut + 1) + i + 1)
        DistortionMesh:setIndex(j * (6 * Cut) + i * 6 + 5, (j + 1) * (Cut + 1) + i + 0)

        ---@设置顶点XYZ
        DistortionMesh:setVertexPosition(j * (Cut + 1) + i + 0, -MinRadius + (MinDiameter / Cut) * i,
            MinRadius - (MinDiameter / Cut) * j, 0.5)
        DistortionMesh:setVertexPosition(j * (Cut + 1) + i + 1, -MinRadius + (MinDiameter / Cut) * (i + 1),
            MinRadius - (MinDiameter / Cut) * j, 0.5)
        DistortionMesh:setVertexPosition((j + 1) * (Cut + 1) + i + 1, -MinRadius + (MinDiameter / Cut) * (i + 1),
            MinRadius - (MinDiameter / Cut) * (j + 1), 0.5)
        DistortionMesh:setVertexPosition((j + 1) * (Cut + 1) + i + 0, -MinRadius + (MinDiameter / Cut) * i,
            MinRadius - (MinDiameter / Cut) * (j + 1), 0.5)

        CalculatorMesh[j * Cut + (i + 1)] = {}

        Unit = CalculatorMesh[j * Cut + (i + 1)]

        Unit.x1, Unit.y1 = -MinRadius + (MinDiameter / Cut) * i, MinRadius - (MinDiameter / Cut) * j
        Unit.x2, Unit.y2 = -MinRadius + (MinDiameter / Cut) * (i + 1), MinRadius - (MinDiameter / Cut) * j
        Unit.x3, Unit.y3 = -MinRadius + (MinDiameter / Cut) * (i + 1), MinRadius - (MinDiameter / Cut) * (j + 1)
        Unit.x4, Unit.y4 = -MinRadius + (MinDiameter / Cut) * i, MinRadius - (MinDiameter / Cut) * (j + 1)

        Unit.distance1 = Dist(0, 0, Unit.x1, Unit.y1)
        Unit.distance2 = Dist(0, 0, Unit.x2, Unit.y2)
        Unit.distance3 = Dist(0, 0, Unit.x3, Unit.y3)
        Unit.distance4 = Dist(0, 0, Unit.x4, Unit.y4)

        Unit.angle1 = Angle(0, 0, Unit.x1, Unit.y1)
        Unit.angle2 = Angle(0, 0, Unit.x2, Unit.y2)
        Unit.angle3 = Angle(0, 0, Unit.x3, Unit.y3)
        Unit.angle4 = Angle(0, 0, Unit.x4, Unit.y4)

        Unit.disx1, Unit.disy1 = Unit.distance1 * cos(Unit.angle1), Unit.distance1 * sin(Unit.angle1)
        Unit.disx2, Unit.disy2 = Unit.distance2 * cos(Unit.angle2), Unit.distance2 * sin(Unit.angle2)
        Unit.disx3, Unit.disy3 = Unit.distance3 * cos(Unit.angle3), Unit.distance3 * sin(Unit.angle3)
        Unit.disx4, Unit.disy4 = Unit.distance4 * cos(Unit.angle4), Unit.distance4 * sin(Unit.angle4)

        Unit.ratio1 = 1 - min(1, max(Unit.distance1 / MinRadius, 0))
        Unit.ratio2 = 1 - min(1, max(Unit.distance2 / MinRadius, 0))
        Unit.ratio3 = 1 - min(1, max(Unit.distance3 / MinRadius, 0))
        Unit.ratio4 = 1 - min(1, max(Unit.distance4 / MinRadius, 0))

        Unit.e_ratio1 = Unit.distance1 > 0 and 1 - min(1, max(Unit.distance1 / Const_Expand_Radius, 0)) ^ 2 or 0
        Unit.e_ratio2 = Unit.distance2 > 0 and 1 - min(1, max(Unit.distance2 / Const_Expand_Radius, 0)) ^ 2 or 0
        Unit.e_ratio3 = Unit.distance3 > 0 and 1 - min(1, max(Unit.distance3 / Const_Expand_Radius, 0)) ^ 2 or 0
        Unit.e_ratio4 = Unit.distance4 > 0 and 1 - min(1, max(Unit.distance4 / Const_Expand_Radius, 0)) ^ 2 or 0

        Unit.phasex1 = PhaseX + PhaseX_i * (j * 16 + i)
        Unit.phasex2 = PhaseX + PhaseX_i * ((j + 1) * 16 + i + 1)
        Unit.phasey1 = PhaseY + PhaseY_i * (j * 16 + i)
        Unit.phasey2 = PhaseY + PhaseY_i * ((j + 1) * 16 + i + 1)

        Unit.u1, Unit.v1 = Unit.x1 / CanvasW, -Unit.y1 / CanvasH
        Unit.u2, Unit.v2 = Unit.x2 / CanvasW, -Unit.y2 / CanvasH
        Unit.u3, Unit.v3 = Unit.x3 / CanvasW, -Unit.y3 / CanvasH
        Unit.u4, Unit.v4 = Unit.x4 / CanvasW, -Unit.y4 / CanvasH

        Unit.aratio1 = Unit.distance1 >= MinRadius and 0 or 1
        Unit.aratio2 = Unit.distance2 >= MinRadius and 0 or 1
        Unit.aratio3 = Unit.distance3 >= MinRadius and 0 or 1
        Unit.aratio4 = Unit.distance4 >= MinRadius and 0 or 1

        Unit.cratio1 = 1 - min(1, max(Unit.distance1 / MinRadius, 0)) ^ 2
        Unit.cratio2 = 1 - min(1, max(Unit.distance2 / MinRadius, 0)) ^ 2
        Unit.cratio3 = 1 - min(1, max(Unit.distance3 / MinRadius, 0)) ^ 2
        Unit.cratio4 = 1 - min(1, max(Unit.distance4 / MinRadius, 0)) ^ 2
    end
end

---@申请Object载体
local ObjDistortion = Class(object)

---@Object函数定义
function ObjDistortion:init(target, radius, layer, A, R, G, B)
    self.layer        = layer or LAYER_BG + 1
    self.color        = { A, R, G, B } or { 255, 255, 0, 0 }
    self.group        = GROUP_GHOST
    self.target       = target
    self.radius       = 20
    self.radius_speed = 2
    self._radius      = radius
    self.count        = 0
    self.scale_factor = 1
    self.x, self.y    = target.x or 0, target.y or 0
    self.uvx, self.uvy = WorldToUv(0, 0)
    self.mesh         = DistortionMesh
end

local m1, m2, m3, m4 ---@四个振荡值
local l1, l2, l3, l4 ---@中心凸透
local r1, r2, r3, r4 ---@衰减距离
local Databox ---@只是用来缩略
local Scale ---@只是用来缩略

local k = 0.5 ---@mesh扩张系数(缩放变换)

function ObjDistortion:frame()
    ---||=============================================||
    ---@半径随时间扩大

    self.radius = min(self.radius + self.radius_speed, self._radius)
    self.scale_factor = self.radius / MinRadius

    ---||=============================================||
    ---@更新计时器，更新位置

    if IsValid(self.target) then
        self.x, self.y = self.target.x, self.target.y
        self.uvx, self.uvy = WorldToUv(self.x, self.y)
        self.count = self.count + 1
    else
        Del(self)
    end

    ---||=============================================||
    ---@更新顶点XY和UV(不幸的是,几乎所有顶点都需要实时更新)
    for j = 0, Cut - 1 do
        for i = 0, Cut - 1 do
            Databox = CalculatorMesh[j * Cut + i + 1]
            Scale   = self.scale_factor
            ---@振荡值更新
            m1      = Blow_RangeX * cos(Databox.phasex1 + Phase_SpeedX * self.count)
            m2      = Blow_RangeX * cos(Databox.phasex2 + Phase_SpeedX * self.count)
            m3      = Blow_RangeY * sin(Databox.phasey1 + Phase_SpeedY * self.count)
            m4      = Blow_RangeY * sin(Databox.phasey2 + Phase_SpeedY * self.count)
            ---@中心凸透(只是用来缩略)
            l1      = Const_Expand * Databox.e_ratio1
            l2      = Const_Expand * Databox.e_ratio2
            l3      = Const_Expand * Databox.e_ratio3
            l4      = Const_Expand * Databox.e_ratio4
            ---@衰减距离(去除指数运算)
            r1      = Databox.ratio1 * Databox.ratio1 * k
            r2      = Databox.ratio2 * Databox.ratio2 * k
            r3      = Databox.ratio3 * Databox.ratio3 * k
            r4      = Databox.ratio4 * Databox.ratio4 * k
            ---@顶点XY更新
            self.mesh:setVertexPosition(j * (Cut + 1) + i + 0,
                self.x + Scale * (Databox.x1 + Databox.disx1 * r1) + m1 * Databox.ratio1 + l1 * cos(Databox.angle1),
                self.y + Scale * (Databox.y1 + Databox.disy1 * r1) + m3 * Databox.ratio1 + l1 * sin(Databox.angle1), 0.5)

            self.mesh:setVertexPosition(j * (Cut + 1) + i + 1,
                self.x + Scale * (Databox.x2 + Databox.disx2 * r2) + m2 * Databox.ratio2 + l2 * cos(Databox.angle2),
                self.y + Scale * (Databox.y2 + Databox.disy2 * r2) + m4 * Databox.ratio2 + l2 * sin(Databox.angle2), 0.5)

            self.mesh:setVertexPosition((j + 1) * (Cut + 1) + i + 1,
                self.x + Scale * (Databox.x3 + Databox.disx3 * r3) + m2 * Databox.ratio3 + l3 * cos(Databox.angle3),
                self.y + Scale * (Databox.y3 + Databox.disy3 * r3) + m4 * Databox.ratio3 + l3 * sin(Databox.angle3), 0.5)

            self.mesh:setVertexPosition((j + 1) * (Cut + 1) + i + 0,
                self.x + Scale * (Databox.x4 + Databox.disx4 * r4) + m1 * Databox.ratio4 + l4 * cos(Databox.angle4),
                self.y + Scale * (Databox.y4 + Databox.disy4 * r4) + m3 * Databox.ratio4 + l4 * sin(Databox.angle4), 0.5)
            ---@顶点UV更新(注意是0~1)
            self.mesh:setVertexCoords(j * (Cut + 1) + i + 0, self.uvx + Databox.u1 * Scale, self.uvy + Databox.v1 * Scale)
            self.mesh:setVertexCoords(j * (Cut + 1) + i + 1, self.uvx + Databox.u2 * Scale, self.uvy + Databox.v2 * Scale)
            self.mesh:setVertexCoords((j + 1) * (Cut + 1) + i + 1, self.uvx + Databox.u3 * Scale,
                self.uvy + Databox.v3 * Scale)
            self.mesh:setVertexCoords((j + 1) * (Cut + 1) + i + 0, self.uvx + Databox.u4 * Scale,
                self.uvy + Databox.v4 * Scale)
            ---@顶点Color更新
            self.mesh:setVertexColor(j * (Cut + 1) + i + 0,
                Color(self.color[1] * Databox.aratio1, 255 + (self.color[2] - 255) * Databox.cratio1,
                    255 + (self.color[3] - 255) * Databox.cratio1, 255 + (self.color[4] - 255) * Databox.cratio1))
            self.mesh:setVertexColor(j * (Cut + 1) + i + 1,
                Color(self.color[1] * Databox.aratio2, 255 + (self.color[2] - 255) * Databox.cratio2,
                    255 + (self.color[3] - 255) * Databox.cratio2, 255 + (self.color[4] - 255) * Databox.cratio2))
            self.mesh:setVertexColor((j + 1) * (Cut + 1) + i + 1,
                Color(self.color[1] * Databox.aratio3, 255 + (self.color[2] - 255) * Databox.cratio3,
                    255 + (self.color[3] - 255) * Databox.cratio3, 255 + (self.color[4] - 255) * Databox.cratio3))
            self.mesh:setVertexColor((j + 1) * (Cut + 1) + i + 0,
                Color(self.color[1] * Databox.aratio4, 255 + (self.color[2] - 255) * Databox.cratio4,
                    255 + (self.color[3] - 255) * Databox.cratio4, 255 + (self.color[4] - 255) * Databox.cratio4))
        end
    end
end

function ObjDistortion:render()
    RenderMesh(DtTex, "", self.mesh)
end

---||===============================================================================================================================================||
---||===============================================================================================================================================||

---应用纹理扭曲特效
---@param target any 目标
---@param radius number 半径(原作常见大小有144和160)
---@param layer number 图层(一般是LAYER_BG+1)
---@param A number 不透明度
---@param R number R值
---@param G number G值
---@param B number B值
function DistortionApply(target, radius, layer, A, R, G, B)
    return New(ObjDistortion, target, radius, layer, A, R, G, B)
end
