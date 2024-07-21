--3D坐标系转屏幕坐标系
--@author:EVA

--创建一个mxn的矩阵
function CreateMatrix(mn, ...)
    local mat = {}
    local index = 1
    local j = 1
    for i = 1, mn[2] do
        mat[i] = {}
    end
    for k, v in ipairs({ ... }) do
        mat[j][index] = v
        if index >= mn[1] then
            index = 1
            j = j + 1
        else
            index = index + 1
        end
    end
    return mat
end

--矩阵相乘
--仅支持矩形矩阵
function MatrixMix(A, B)
    --取第一行的长度
    local A_m, B_m = #A[1], #B[1]
    --取列数
    local B_n = #B
    local mix = {}
    local add = 0
    --以B矩阵为基准进行混合
    for j = 1, B_n do
        mix[j] = {}
        for i = 1, B_m do
            for ai = 1, A_m do
                add = add + (B[ai][i] * A[j][ai]) * 1
            end
            mix[j][i] = add
            add = 0
        end
    end
    return mix
end

--矩阵数乘
function MatrixMultiply(B, num)
    --取第一行的长度
    local B_m = #B[1]
    --取列数
    local B_n = #B
    local mix = {}
    --矩阵大小与B矩阵相同
    for j = 1, B_n do
        mix[j] = {}
        for i = 1, B_m do
            mix[j][i] = 0
        end
    end
    for j = 1, B_n do
        for i = 1, B_m do
            mix[j][i] = B[j][i] * num
        end
    end
    return mix
end

-- 创建三维向量
function CreateVector3(_x, _y, _z)
    return { x = _x, y = _y, z = _z }
end

-- 向量相加
function AddVector3(v1, v2)
    local v3 = { x = v1.x + v2.x, y = v1.y + v2.y, z = v1.z + v2.z }
    return v3
end

-- 向量相减
function MinusVector3(v1, v2)
    local v3 = { x = v1.x - v2.x, y = v1.y - v2.y, z = v1.z - v2.z }
    return v3
end

-- 向量点乘(数量积)
function GetVector3Multiply(v1, v2)
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
end

-- 向量倒数
function GetVector3Reversed(v)
    return { x = 1 / v.x, y = 1 / v.y, z = 1 / v.z }
end

-- 向量叉乘
function GetVector3Cross(v1, v2)
    local v3 = { x = v1.y * v2.z - v2.y * v1.z, y = v2.x * v1.z - v1.x * v2.z, z = v1.x * v2.y - v2.x * v1.y }
    return v3
end

-- 向量归一化
function NormalizeVector3(v1)
    local d = math.sqrt((v1.x) ^ 2 + (v1.y) ^ 2 + (v1.z) ^ 2)
    return { x = v1.x / d, y = v1.y / d, z = v1.z / d }
end

-- 向量转齐次矩阵（向量
function Vector3ToMatrix(v)
    local mat = {
        { v.x },
        { v.y },
        { v.z },
        { 1 }
    }
    return mat
end

-- 向量转齐次矩阵（点
function Vector3ToMatrixPoint(v)
    local mat = {
        { v.x },
        { v.y },
        { v.z },
        { 0 }
    }
    return mat
end

--LookAt矩阵(含平移)
function m_lookat(_pos, _target, upDir)
    local cN = NormalizeVector3(MinusVector3(_target, _pos))
    local cU = NormalizeVector3(GetVector3Cross(upDir, cN))
    local cV = (GetVector3Cross(cN, cU))

    local eU = GetVector3Multiply(_pos, cU)
    local eV = GetVector3Multiply(_pos, cV)
    local eN = GetVector3Multiply(_pos, cN)

    local mat = {
        { cU.x, cU.y, cU.z, -eU },
        { cV.x, cV.y, cV.z, -eV },
        { cN.x, cN.y, cN.z, -eN },
        { 0,    0,    0,    1 }
    }

    return mat
end

--透视除法矩阵(w分量上保留深度信息)
--*可以根据z分量是否处于(-zn,zf)范围内进行裁剪
--*注意zn必须>=0
--*注意此处fov为弧度制*
--fov 广角
--aspect 宽高比
--zn 近裁剪面
--zf 远裁剪面
function m_projection(fov, aspect, zn, zf)
    fov = fov * 0.5
    local e11 = 1 / (math.tan(fov) * aspect)
    local e22 = 1 / math.tan(fov)
    local e33 = (zf + zn) / (zf - zn)
    local e34 = -(2 * (zf * zn)) / (zf - zn)
    local e43 = 1.0
    local proj = {
        { e11, 0,   0,   0 },
        { 0,   e22, 0,   0 },
        { 0,   0,   e33, e34 },
        { 0,   0,   e43, 0 }
    }
    return proj
end

--创建视口变换矩阵
--X,Y 原点坐标(向右下为正方向)
function m_viewport(X, Y, width, height, maxZ, minZ)
    return
    {
        { width / 2, 0,      0,         0 },
        { 0,       height / 2, 0,       0 },
        { 0,       0,        maxZ - minZ, 0 },
        { width / 2, height / 2, minZ,  1 }
    }
end

----------------------------------------------------------
----------------------------------------------------------


--获取深度(若无特殊要求建议从SpaceToWorldWithZ中获取,以减少不必要的调用)
function GetDepth(x, y, z)
    local camPos    = CreateVector3(lstg.view3d.eye[1], lstg.view3d.eye[2], lstg.view3d.eye[3])
    local camLookAt = CreateVector3(lstg.view3d.at[1], lstg.view3d.at[2], lstg.view3d.at[3])
    local camUp     = CreateVector3(lstg.view3d.up[1], lstg.view3d.up[2], lstg.view3d.up[3])
    local lookat    = m_lookat(camPos, camLookAt, camUp)

    local mp        = Vector3ToMatrix(CreateVector3(x, y, z))
    return MatrixMix(lookat, mp)[3][1]
end

function _From3DToWorld(proj, lookat, p, flag)
    --转齐次坐标
    p = Vector3ToMatrix(p)
    --转相机坐标系
    p = MatrixMix(lookat, p)
    --透视除法矩阵(无裁剪)
    p = MatrixMix(proj, p)
    local w = p[4][1]
    local z = p[3][1]
    --除以深度（第四分量w）
    p = MatrixMultiply(p, 1 / w)
    --视口变换
    p = MatrixMix(
    m_viewport(screen.dx, screen.dy, (lstg.world.scrr - lstg.world.scrl), (lstg.world.scrt - lstg.world.scrb), 1.0, 0), p)

    if flag then
        return (p[1][1]), (p[2][1]), z
    else
        return (p[1][1]), (p[2][1]), w
    end
end

--3D坐标转屏幕2D坐标(带有Z)
--有flag时返回的是裁剪空间下的深度值(一般情况不用填flag)
function SpaceToWorldWithZ(x, y, z, flag)
    --创建投影矩阵
    local aspect    = (lstg.world.r - lstg.world.l) / (lstg.world.t - lstg.world.b)
    local proj      = m_projection(lstg.view3d.fovy, aspect, lstg.view3d.z[1], lstg.view3d.z[2])
    --创建lookat矩阵
    local camPos    = CreateVector3(lstg.view3d.eye[1], lstg.view3d.eye[2], lstg.view3d.eye[3])
    local camLookAt = CreateVector3(lstg.view3d.at[1], lstg.view3d.at[2], lstg.view3d.at[3])
    local camUp     = CreateVector3(lstg.view3d.up[1], lstg.view3d.up[2], lstg.view3d.up[3])
    local lookat    = m_lookat(camPos, camLookAt, camUp)
    local x1, y1, z1 = _From3DToWorld(proj, lookat, CreateVector3(x, y, z), flag)
    return x1, y1, z1
end

--3D坐标转屏幕2D坐标(无Z)
function SpaceToWorld(x, y, z)
    local x1, y1, z1 = SpaceToWorldWithZ(x, y, z)
    return x1, y1
end
