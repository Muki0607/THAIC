---THAIC Arranged
---翻译来自https://wiki.luatos.com/luaGuide/luaReference.html，译者云风

-- Copyright (c) 2018. tangzx(love.tangzx@qq.com)
--
-- Licensed under the Apache License, Version 2.0 (the "License"); you may not
-- use this file except in compliance with the License. You may obtain a copy of
-- the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
-- WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
-- License for the specific language governing permissions and limitations under
-- the License.

---
--- 这个库提供了基本的数学函数。 所有函数都放在表 `math` 中。
--- 注解有 “integer/float” 的函数会对整数参数返回整数结果， 对浮点（或混合）参数返回浮点结果。
--- 圆整函数（`math.ceil`, `math.floor`, `math.fmod`） 在结果在整数范围内时返回整数，否则返回浮点数。
math = {}

---
--- 返回 `x` 的绝对值。(integer/float)
---@param x number
---@return number
function math.abs(x) return 0 end

---
--- 返回 `x` 的反余弦值（用弧度表示）。
---@param x number
---@return number
function math.acos(x) return 0 end

---
--- 返回 `x` 的反正弦值（用弧度表示）。
---@param x number
---@return number
function math.asin(x) return 0 end

---
--- 返回 `y/x` 的反正切值（用弧度表示）。 它会使用两个参数的符号来找到结果落在哪个象限中。（即使 `x` 为零时，也可以正确的处理。）
---
--- 默认的 `x` 是 1 ， 因此调用 math.atan(y) 将返回 y 的反正切值。
---@overload fun(y:number):number
---@param y number
---@param x number
---@return number
function math.atan(y, x) return 0 end

---
--- 返回不小于 `x` 的最小整数值。
---@param x number
---@return number
function math.ceil(x) return 0 end

---
--- 返回 `x` 的余弦（假定参数是弧度）。
---@param x number
---@return number
function math.cos(x) return 0 end

---
--- 将角 `x` 从弧度转换为角度。
---@param x number
---@return number
function math.deg(x) return 0 end

---
--- 返回 *e^x* 的值 （`e` 为自然对数的底）。
---@param x number
---@return number
function math.exp(x) end

---
--- 返回不大于 `x` 的最大整数值。
---@param x number
---@return number
function math.floor(x) end

---
--- `返回 x 除以 y，将商向零圆整后的余数。` (integer/float)
---@param x number
---@param y number
---@return number
function math.fmod(x, y) end

---
--- 浮点数 `HUGE_VAL`， 这个数比任何数字值都大。
---@type number
math.huge = nil

---
--- 返回以指定底的 `x` 的对数。 默认的 `base` 是 *e* （因此此函数返回 `x` 的自然对数）。
---@overload fun(x:number):number
---@param x number
---@param base number
---@return number
function math.log(x, base) end

---
--- 返回参数中最大的值， 大小由 Lua 操作 `<` 决定。 (integer/float)
---@param x number
---@return number
function math.max(x, ...) end

---
--- 最大值的整数。
---@type number
math.maxinteger = nil

---
--- 返回参数中最小的值， 大小由 Lua 操作 `<` 决定。 (integer/float)
---@param x number
---@return number
function math.min(x, ...) end

---
--- 最小值的整数。
---@type number
math.mininteger = nil

---
--- 返回 `x` 的整数部分和小数部分。 第二个结果一定是浮点数。
---@param x number
---@return number
function math.modf(x) end

---
--- π 的值。
math.pi = 3.1415

---
--- 将角 `x` 从角度转换为弧度。
---@param x number
---@return number
function math.rad(x) end

---
--- 当不带参数调用时， 返回一个 *[0,1)* 区间内一致分布的浮点伪随机数。
--- 当以两个整数 `m` 与 `n` 调用时， `math.random` 返回一个 *[m, n]* 区间 内一致分布的整数伪随机数。 （值 *n-m* 不能是负数，且必须在 Lua 整数的表示范围内。）
--- 调用 `math.random(n)` 等价于 `math.random(1,n)`。
--- 
--- 这个函数是对 C 提供的位随机数函数的封装。 对其统计属性不作担保。
---@overload fun():number
---@param m number
---@param n number
---@return number
function math.random(m, n) end

---
--- 把 `x` 设为伪随机数发生器的“种子”： 相同的种子产生相同的随机数列。
---@param x number
function math.randomseed(x) end

---
--- 返回 `x` 的正弦值（假定参数是弧度）。
---@param x number
---@return number
function math.sin(x) return 0 end

---
--- 返回 `x` 的平方根。 （你也可以使用乘方 `x^0.5` 来计算这个值。）
---@param x number
---@return number
function math.sqrt(x) return 0 end

---
--- 返回 `x` 的正切值（假定参数是弧度）。
---@param x number
---@return number
function math.tan(x) return 0 end

---
--- 如果 `x` 可以转换为一个整数， 返回该整数。
--- 否则返回 **nil**。
---@param x number
---@return number
function math.tointeger(x) end

---
--- 如果 `x` 是整数，返回 “`integer`”，
--- 如果它是浮点数，返回 “`float`”，
--- 如果 `x` 不是数字，返回 **nil**。
---@param x number
---@return number
function math.type(x) end

---
--- 如果整数 `m` 和 `n` 以无符号整数形式比较， m 在 n 之下，返回 **true** ；
--- 否则返回 **false** 。
---@param m number
---@param n number
---@return boolean
function math.ult(m, n) end

return math
