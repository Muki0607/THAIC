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

-- 内建类型


---
--- nil 是值 nil 的类型， 其主要特征就是和其它值区别开；
--- 通常用来表示一个有意义的值不存在时的状态。
---@class nil

---
--- boolean 是 false 与 true 两个值的类型。
--- nil 和 false 都会导致条件判断为假； 而其它任何值都表示为真。
---@class boolean

---
--- number 类型有两种内部表现方式，整数和浮点数。
--- 对于何时使用哪种内部形式，Lua 有明确的规则， 但它也按需作自动转换。
--- 因此，程序员多数情况下可以选择忽略整数与浮点数之间的差异或者假设完全控制每个数字的内部表现方式。
--- 标准 Lua 使用 64 位整数和双精度（64 位）浮点数，
--- 但你也可以把 Lua 编译成使用 32 位整数和单精度（32 位）浮点数。
--- 以 32 位表示数字对小型机器以及嵌入式系统特别合适。（参见 luaconf.h 文件中的宏 LUA_32BITS 。）
---@class number


---
--- `string` 表示一个不可变的字节序列。
--- Lua 对 8 位是友好的： 字符串可以容纳任意 8 位值， 其中包含零 (’`\0`’) 。
--- Lua 的字符串与编码无关； 它不关心字符串中具体内容。
---@class string

---
--- Lua 可以调用（以及操作）用 Lua 或 C 编写的函数。
--- 这两种函数有统一类型 function。
---@class function

---
--- userdata 类型允许将 C 中的数据保存在 Lua 变量中。
--- 用户数据类型的值是一个内存块，
--- 有两种用户数据： 完全用户数据 ，指一块由 Lua 管理的内存对应的对象；
--- 轻量用户数据 ，则指一个简单的 C 指针。 用户数据在 Lua 中除了赋值与相等性判断之外没有其他预定义的操作。
--- 通过使用 元表 ，程序员可以给完全用户数据定义一系列的操作。
--- 你只能通过 C API 而无法在 Lua 代码中创建或者修改用户数据的值，这保证了数据仅被宿主程序所控制。
---@class userdata


---
--- thread 类型表示了一个独立的执行序列，被用于实现协程。
--- Lua 的线程与操作系统的线程毫无关系。
--- Lua 为所有的系统，包括那些不支持原生线程的系统，提供了协程支持。
---@class thread

---
--- table 是一个关联数组， 也就是说，这个数组不仅仅以数字做索引，除了 nil 和 NaN 之外的所有 Lua 值 都可以做索引。
--- （Not a Number 是一个特殊的数字，它用于表示未定义或表示不了的运算结果，比如 0/0。）
--- 表可以是 异构 的； 也就是说，表内可以包含任何类型的值（ nil 除外）。
--- 任何键的值若为 nil 就不会被记入表结构内部。
--- 换言之，对于表内不存在的键，都对应着值 nil 。

--- 表是 Lua 中唯一的数据结构， 它可被用于表示普通数组、序列、符号表、集合、记录、图、树等等。
--- 对于记录，Lua 使用域名作为索引。
--- 语言提供了 a.name 这样的语法糖来替代 a["name"] 这种写法以方便记录这种结构的使用。
--- 在 Lua 中有多种便利的方式创建表。

--- 我们使用 序列 这个术语来表示一个用 {1..n} 的正整数集做索引的表。
--- 这里的非负整数 n 被称为该序列的长度。

--- 和索引一样，表中每个域的值也可以是任何类型。
--- 需要特别指出的是：既然函数是一等公民，那么表的域也可以是函数。这样，表就可以携带方法了。

--- 索引一张表的原则遵循语言中的直接比较规则。 
--- 当且仅当 i 与 j直接比较相等时 （即不通过元方法的比较），表达式 a[i] 与 a[j] 表示了表中相同的元素。
--- 特别指出：一个可以完全表示为整数的浮点数和对应的整数相等 （例如：1.0 == 1）。
--- 为了消除歧义，当一个可以完全表示为整数的浮点数做为键值时， 都会被转换为对应的整数储存。
--- 例如，当你写 a[2.0] = true 时， 实际被插入表中的键是整数 2 。（另一方面，2 与 “2” 是两个不同的 Lua 值， 故而它们可以是同一张表中的不同项。）

---
--- 表、函数、线程、以及完全用户数据在 Lua 中被称为对象： 
--- 变量并不真的持有它们的值，而仅保存了对这些对象的引用。
--- 赋值、参数传递、函数返回，都是针对引用而不是针对值的操作，这些操作均不会做任何形式的隐式拷贝。
---@class table

---
---上述内建类型中的任意一个。
---@class any

---
---@class void

---@class self

--- 轻量用户数据，userdata的一种，并非类型
---@class lightuserdata
