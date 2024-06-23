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
--- 这个库提供了表处理的通用函数。 所有函数都放在表 `table` 中。
---
--- 记住，无论何时，若一个操作需要取表的长度，
--- 这张表必须是一个真序列，或是拥有 `__len` 元方法。
--- 所有的函数都忽略传入参数的那张表中的非数字键。
table = {}

---
--- 提供一个列表，其所有元素都是字符串或数字，返回字符串 `list[i]..sep..list[i+1] ··· sep..list[j]`。
--- `sep` 的默认值是空串， `i` 的默认值是 1 ， `j` 的默认值是 `#list` 。 如果 `i` 比 `j` 大，返回空串。
---@overload fun(list:table):string
---@overload fun(list:table, sep:string):string
---@overload fun(list:table, sep:string, i:number):string
---@param list table
---@param sep string
---@param i number
---@param j number
---@return string
function table.concat(list, sep, i, j) end

---
--- 在 `list` 的位置 `pos` 处插入元素 `value` ， 并后移元素 `list[pos], list[pos+1], ···, list[#list]` 。
--- `pos` 的默认值为 `#list+1` ， 因此调用 `table.insert(t,x)` 会将 `x` 插在列表 `t` 的末尾。
---@overload fun(list:table, value:any):number
---@param list table
---@param pos number
---@param value any
---@return number
function table.insert(list, pos, value) end

---
--- 将元素从表 `a1` 移到表 `a2`。 这个函数做了次等价于后面这个多重赋值的等价操作： `a2[t],··· = a1[f],···,a1[e]`。
--- `a2` 的默认值为 `a1`。 目标区间可以和源区间重叠。 索引 `f` 必须是正数。
---
--- 返回目标表`a2`。
---@overload fun(a1:table, f:number, e:number, t:number):table
---@param a1 table
---@param f number
---@param e number
---@param t number
---@param a2 table
---@return table
function table.move(a1, f, e, t, a2) end

---
--- 返回用所有参数以键 1,2, 等填充的新表， 并将 “`n`” 这个域设为参数的总数。
--- 注意在某些参数是 **nil** 时，这张返回的表不一定是一个序列。
---@return table
function table.pack(...) end

---
--- 移除 `list` 中 `pos` 位置上的元素，并返回这个被移除的值。
--- 当 `pos` 是在 1 到 `#list` 之间的整数时， 它向前移动元素 `list[pos+1], list[pos+2], ···, list[#list]` 并删除元素 `list[#list]`；
--- 索引 `pos` 可以是 `#list + 1` ，或在 `#list` 为 0 时可以是 0 ； 在这些情况下，函数删除元素 `list[pos]`。
---
--- pos 默认为 `#list`， 因此调用 `table.remove(l)` 将移除表 `l` 的最后一个元素。
---@overload fun<V>(list:table<number, V> | V[]):V
---@generic V
---@param list table<number, V>
---@param pos number
---@return V
function table.remove(list, pos) end

---
--- 在表内从 `list[1]` 到 `list[#list]` *原地* 对其间元素按指定次序排序。
--- 如果提供了 `comp` ， 它必须是一个可以接收两个列表内元素为参数的函数。
--- 当第一个元素需要排在第二个元素之前时，返回真 （因此 `not comp(list[i+1],list[i])` 在排序结束后将为真）。
--- 如果没有提供 `comp`， 将使用标准 Lua 操作 `<` 作为替代品。
---
--- 排序算法并不稳定； 即当两个元素次序相等时，它们在排序后的相对位置可能会改变。
---@overload fun(list:table):number
---@generic V
---@param list table<number, V> | V[]
---@param comp fun(a:V, b:V):boolean
---@return number
function table.sort(list, comp) end

---
--- 返回列表中的元素。 这个函数等价于
---```
--- return list[i], list[i+1], ···, list[j]
---```
--- `i` 默认为 1 ，`j` 默认为 `#list`。
---@overload fun(list:table):any
---@param list table
---@param i number
---@param j number
---@return any
function table.unpack(list, i, j) end

return table
