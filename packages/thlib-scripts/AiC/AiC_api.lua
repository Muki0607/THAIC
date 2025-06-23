---=====================================
---THAIC Global API v1.00a
---东方梦摇篮 全局API v1.00a
---=====================================

---将AiC的部分常用（也可能不常用）函数导出到全局
---要把注释也搬过来真的很麻烦
---不知不觉中已经写了这么多函数啊（感叹）

---版本更新记录
---v1.00a
---初始版本
---v1.01a
---添加函数注释

--东方梦摇篮3D
--还没做完所以暂时不导出到全局
--[[
object3D = aic.view3d.object
hypot3D = aic.view3d.hypot
Dist3D = aic.view3d.Dist
Angle3D = aic.view3d.Angle
GetV3D = aic.view3d.GetV
SetV3D = aic.view3d.SetV
BoxCheck3D = aic.view3d.BoxCheck
ColliCheck3D = aic.view3d.ColliCheck
CollisionCheck3D = aic.view3d.CollisionCheck
Render2D = aic.view3d.Render2D
Render3D = aic.view3d.Render3D
RenderAuto3D = aic.view3d.RenderAuto3D
--]]

--东方梦摇篮杂项

---返回`i`与`j`对应的索引（与`string.sub`的规则相同）
---@param i number @始位标
---@param j number @末位标
---@param len number @总长度
---@overload fun(i:number, len:number):number
getpos = aic.misc.GetPos

--东方梦摇篮系统

---检查玩家是否携带某插件
---@param num enhancer_num @插件编号
---@return boolean
CheckEnhancer = aic.sys.CheckEnhancer
---检查当前难度是否大于等于某难度
---@param diff number @检查的难度
---@param equal boolean @是否要求严格等于
---@return boolean
CheckDiff = aic.sys.CheckDiff
---获取当前难度
---@return number @当前难度
GetDiff = aic.sys.GetDiff
---检查单位存活后再删除，防止报错
---@param unit lstg.GameObject @要删除的单位
---@param raw boolean @是否使用RawDel
---@return boolean @是否删除成功
safeDel = aic.sys.SafeDel
---检查单位存活后再删除，防止报错
---@param unit lstg.GameObject @要删除的单位
---@param raw boolean @是否使用RawKill
---@return boolean @是否删除成功
safeKill = aic.sys.SafeKill
---检查调用环境为协程再Wait，防止报错
---@param t number @Wait时间
safeWait = aic.sys.SafeWait
---安全地对存档文件进行操作
---@param func function @要进行的操作
---@return any
safeSave = aic.sys.SafeSave
---等待到condition为真
---@task
---@param condition boolean @用于判断的值
WaitUntil = aic.sys.WaitUntil

--东方梦摇篮table扩展库

---移除一个值的元表
---@param value any @要移除的值
---@param force boolean @是否使用debug.setmetatable
---@return table|boolean @移除后的表|是否移除成功
removemetatable = aic.table.RemoveMetatable
---设置一个值的元表
---@param value any @要设置的值
---@param force boolean @是否使用debug.setmetatable
---@return userdata|boolean @设置后的表|是否设置成功
_setmetatable = aic.table.SetMetatable
---获取一个值的元表
---@param value any @要获取的值
---@param force boolean @是否使用debug.getmetatable
---@return any @这个值的元表（或者它的__metatable的值）
_getmetatable = aic.table.GetMetatable
---为一个表设置键表
---@param vt table @要设置的值表
---@param kt table @要设置的键表
---@return table @传入的值表
setkeytable = aic.table.SetKeyTable
---为一个表设置值表，作用与`setkeytable`相同，只是参数顺序与返回值不同
---@param kt table @要设置的键表
---@param vt table @要设置的值表
---@return keytable @传入的键表
setvaluetable = aic.table.SetValueTable
---使用一个值表制作键表
---@param vt table @要制作键表的值表
---@return keytable @键表
makekeytable = aic.table.MakeKeyTable

--东方梦摇篮UI

---获取lstg默认弹型颜色对应Color
---@param color number @颜色编号
---@param alpha number @透明度
---@overload fun(color:number):lstg.Color
---@return lstg.Color
color = aic.ui.color
---通用文字渲染，带描边
---
---'paragraph'等效于同时取'left'、'top'和'wordbreak'
---
---'centerpoint' 等效于同时取'center'、'vcenter'和'noclip'
---@param font string @字体
---@param text string @渲染文字
---@param x number @x坐标
---@param y number @y坐标
---@param s number @缩放比例
---@param co1 lstg.Color @文字颜色
---@param co2 lstg.Color @描边颜色
---@vararg align @对齐方式
function DrawText(font, text, x, y, s, co1, co2, ...)
end
DrawText = aic.ui.DrawText --这玩意直接写不知道为什么可变参数看不到……
---增加一个auto阶段点
---@param dmg number @目标损失血量
---@param timer number @目标计时器
---@param current boolean @是否使用真实帧数计时
---@overload fun(percent:number)
AddSPPoint = aic.ui.AddSPPoint
---增加一个auto阶段点（按剩余百分比计算）
---@param percent number @目标剩余血量/时间百分比
---@param maxhp number @最大血量
---@param t3 number @符卡时长（帧）
---@param current boolean @是否使用真实帧数计时
AddSPPoint2 = aic.ui.AddSPPoint2
---检查剩余auto阶段点数量
---@param num number @检查阶段点数量
---@return boolean @剩余阶段点数量是否小于num
CheckSPPoint = aic.ui.CheckSPPoint

--东方梦摇篮数学库

nand = aic.math.nand
nor = aic.math.nor
xor = aic.math.xor
xnor = aic.math.xnor
---使一点绕另一点旋转特定角度
---@param x number @原x坐标
---@param y number @原y坐标
---@param a0 number @旋转角度
---@param x0 number @绕其旋转的点的x坐标
---@param y0 number @绕其旋转的点的y坐标
---@return number, number @旋转后的点的x,y坐标
rotate = aic.math.rotate
---四舍五入
---@param x number
---@return number
round = aic.math.round
---约等于
---@param a number @要比较的数
---@param b number @要比较的数
---@param accuracy number @精度
---@return boolean @在误差范围内是否相等
appr_equal = aic.math.appr_equal
---from RT基础教程，坐标系转换
---@param x number @原x坐标
---@param y number @原y坐标
---@param from 'world'|'ui'|'uv' @原坐标系
---@param to 'world'|'ui'|'uv' @转换后坐标系
---@return number, number @转换后x，y坐标
PosTrans = aic.math.PosTrans
---检测一个值是否处于上限和下限之间
---@param x number @要检测的值
---@param up number @上限（当然也能填下限）
---@param down number @下限（当然也能填上限）
---@param equal boolean @为false时使用大于/小于，否则使用大于等于/小于等于
IsIn = aic.math.IsIn

--东方梦摇篮Python扩展库

BadArgument = "bad argument"
InvalidArgument = "invalid argument"
ArgumentError = ".+ argument"
InvalidObj = "invalid.+object"
CompileError = "falied to compile"
StackOverflow = "stack overflow"
NilValueError = "nil value"
LoadFailed = "load .+ failed"
PermissionDenied = "Permission denied"
AnyException = ".*"
---模拟`Python`中的`try..except..else..finally`块
---
---当`Try`正常运行时，返回`Try`的返回值；
---否则在错误信息中查找是否有`Except`中指定*异常*（模式字符串），若有则执行对应函数；
---若错误信息没有与任何*异常*匹配，执行`Except`中索引为''（空字符串）的函数；
---若`Except`中函数发生错误将重新抛出，否则以`Try`函数的返回值为参数执行`Else`函数，之后返回`Except`中函数的返回值。
---无论何种情况，`Finally`总会在最后执行，且一定会执行。请注意，`Finally`中的错误不会被捕获。
---当`Try`或`Except`正常运行时，以其返回值作为参数调用`Finally`；
---否则以错误信息为参数调用`Finally`。`Else`与`Finally`的返回值将被忽略。
---若在`Except`中以表作为索引，该表中的所有字符串将被视为模式字符串，任意一个模式字符串匹配成功即会执行对应函数；
---
---使用例：
---```
--->TryExcept(function()
--->    Del(object)
--->end, 
--->{
--->    [InvalidObj] = function()
--->        Print("invalid object.")
--->    end,
--->    [{ BadArgument, InvalidArgument }] = function()
--->        Print("wrong argument.")
--->    end,
--->    [''] = function()
--->        Print("unhandled error.")
--->},
--->function()
--->    Print("TryExcept successed.")
--->end,
--->function(ret)
--->    Print("TryExcept finished.")
--->end)
---```
---@param Try function @Try代码块
---@param Except table<string, function> @Except代码块
---@param Else function @Else代码块
---@param Finally function @Finally代码块
---@param plain boolean @是否使用简单查找（不使用正则表达式与转义字符）
---@return any
TryExcept = aic.py.TryExcept
---模拟`Python`中的`raise`语句，当不传入`exception`时将把最后捕获的异常抛出
raise = aic.py.Raise
---模拟`Python`中的`pass`语句，不做任何事
pass = aic.py.Pass
---模拟`Python`中的`range`迭代器
---
---使用例：
---```
---for i in range(i, j, intv) do _body_ end
---```
---等同于
---```
---for i = i, j - intv, intv do _body_ end
---```
---@param i number @始位标
---@param j number @末位标
---@param intv number @自增值
---@return fun():number @迭代器函数
---@overload fun(i:number):fun():number
---@overload fun(i:number, j:number):fun():number
range = aic.py.Range

