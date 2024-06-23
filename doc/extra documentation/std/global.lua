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
--- 基础库提供了 Lua 核心函数。 如果你不将这个库包含在你的程序中， 
--- 你就需要小心检查程序是否需要自己提供其中一些特性的实现。

---
--- 如果其参数 `v` 的值为假（nil 或 false），它就调用 `error`； 否则，返回所有的参数。
--- 在错误情况时， `message` 指那个错误对象；
--- 如果不提供这个参数，参数默认为 “`assertion failed!`” 。
---@overload fun(v:any):any
---@param v any
---@param message string
---@return any
function assert(v, message) end

---
--- 这个函数是垃圾收集器的通用接口。 通过参数 `opt` 它提供了一组不同的功能：
---
--- "`collect`": 做一次完整的垃圾收集循环。 这是默认选项。
---
--- "`stop`": 停止垃圾收集器的运行。 在调用重启前，收集器只会因显式的调用运行。
---
--- "`restart`": 重启垃圾收集器的自动运行。
---
--- "`count`": 以 K 字节数为单位返回 Lua 使用的总内存数。 这个值有小数部分，所以只需要乘上 1024 就能得到 Lua 使用的准确字节数（除非溢出）。
---
--- "`step`": 单步运行垃圾收集器。 步长“大小”由 `arg` 控制。
--- 传入 0 时，收集器步进（不可分割的）一步。
--- 传入非 0 值， 收集器收集相当于 Lua 分配这些多（K 字节）内存的工作。 如果收集器结束一个循环将返回 **true** 。
---
--- "`setpause`": 将 `arg` 设为收集器的间歇率。 返回 *间歇率* 的前一个值。
---
--- "`setstepmul`": 将 `arg` 设为收集器的步进倍率。 返回 *步进倍率* 的前一个值。
---
--- "`isrunning`": 返回表示收集器是否在工作的布尔值 （即未被停止）。
---
---@overload fun():any
---@param opt string
---@param arg string
---@return any
function collectgarbage(opt, arg) end

---
--- 打开该名字的文件，并执行文件中的 Lua 代码块。
--- 不带参数调用时， `dofile` 执行标准输入的内容（stdin）。
--- 返回该代码块的所有返回值。
--- 对于有错误的情况，`dofile` 将错误反馈给调用者 （即，`dofile` 没有运行在保护模式下）。
---@overload fun():table
---@param filename string
---@return table
function dofile(filename) end

---
--- 中止上一次保护函数调用， 将错误对象 `message` 返回。函数 `error` 永远不会返回。
---
--- 当 `message` 是一个字符串时，通常 `error` 会把一些有关出错位置的信息附加在消息的前头。
--- `level` 参数指明了怎样获得出错位置。 对于 level 1 （默认值），出错位置指 `error` 函数调用的位置。
--- Level 2 将出错位置指向调用 `error` 的函数的函数；以此类推。 传入 level 0 可以避免在消息前添加出错位置信息。
---@overload fun(message:string)
---@param message string
---@param level number
function error(message, level) end

---
--- 一个全局变量（非函数）， 内部储存有全局环境。Lua 自己不使用这个变量；
--- 改变这个变量的值不会对任何环境造成影响，反之亦然。
---@class _G
_G = {}

---
--- 一个全局变量（非函数）， 内部储存有当前环境。它包含当前环境的局部变量以及所有全局变量。
--- Lua 自己不使用这个变量；改变这个变量的值不会对任何环境造成影响，反之亦然。
---@class _ENV
_ENV = {}

---
--- 在Lua5.1中，这个函数返回与_ENV相同的环境。
---@return _ENV
function getfenv() end

---
--- 在Lua5.1中，这个函数用于改变当前环境。
---@param env table
function setfenv(env) end

---
--- 如果 `object` 不包含元表，返回 **nil** 。
--- 否则，如果在该对象的元表中有 `"__metatable"` 域时返回其关联值，
--- 没有时返回该对象的元表。
---@param object any
---@return any
function getmetatable(object) end

---
--- 在Lua5.2中， 如果`t` 有元方法 `__ipairs`， 以 `t` 为参数调用它，并返回其返回的前三个值。
---
--- 如果没有该元方法或版本不是Lua5.2，返回三个值（迭代函数、表 `t` 以及 0 ）。 因此，以下代码
---```
--- for i,v in ipairs(t) do _body_ end
---```
--- 将迭代键值对(`1,t[1]`) ，(`2,t[2]`)， … ，直到第一个空值。
---@generic V
---@param t table<number, V>|V[]
---@return fun(tbl: table<number, V>):number, V
function ipairs(t) end

---
--- 加载一个代码块。
---
--- 如果 `chunk` 是一个字符串，代码块指这个字符串。
--- 如果 `chunk` 是一个函数， `load` 不断地调用它获取代码块的片断。
--- 每次对 `chunk` 的调用都必须返回一个字符串紧紧连接在上次调用的返回串之后。
--- 当返回空串、**nil**、或是不返回值时，都表示代码块结束。
---
--- 如果没有语法错误， 则以函数形式返回编译好的代码块； 
--- 否则，返回 **nil** 加上错误消息。
---
--- 如果结果函数有上值， `env` 被设为第一个上值。
--- 若不提供此参数，将使用全局环境替代它。
--- 所有其它上值初始化为 **nil**。 （当你加载主代码块时候，结果函数一定有且仅有一个上值 `_ENV` ）。
--- 然而，如果你加载一个用函数（参见 `string.dump`， 结果函数可以有任意数量的上值） 创建出来的二进制代码块时，
--- 所有的上值都是新创建出来的。 也就是说它们不会和别的任何函数共享。
---
--- `chunkname` 在错误消息和调试消息中，用于代码块的名字。 如果不提供此参数，
--- 它默认为字符串`chunk` 。 `chunk` 不是字符串时，则为 “`=(load)`” 。
---
--- 字符串 `mode` 用于控制代码块是文本还是二进制（即预编译代码块）。
--- 它可以是字符串 “`b`” （只能是二进制代码块）， “`t`” （只能是文本代码块），
--- 或 “`bt`” （可以是二进制也可以是文本）。 默认值为 “`bt`”。
---
--- Lua 不会对二进制代码块做健壮性检查。 恶意构造一个二进制块有可能把解释器弄崩溃。
---@overload fun(chunk:fun():string):any
---@param chunk fun():string
---@param chunkname string
---@param mode string
---@param env any
function load(chunk, chunkname, mode, env) end

---
--- 和 `load` 类似， 不过是从文件 `filename`
--- 或标准输入（如果文件名未提供）中获取代码块。
---@overload fun()
---@param filename string
---@param mode string
---@param env any
function loadfile(filename, mode, env) end

---
--- 运行程序来遍历表中的所有域。 第一个参数是要遍历的表，第二个参数是表中的某个键。
--- `next` 返回该键的下一个键及其关联的值。
--- 如果用 **nil** 作为第二个参数调用 `next` 将返回初始键及其关联值。
--- 当以最后一个键去调用，或是以 **nil** 调用一张空表时， `next` 返回 **nil**。
--- 如果不提供第二个参数，将认为它就是 **nil**。
--- 特别指出，你可以用 `next(t)` 来判断一张表是否是空的。
---
--- 索引在遍历过程中的次序无定义， 即使是数字索引也是这样。 
--- （如果想按数字次序遍历表，可以使用数字形式的 **for** 。）
---
--- 当在遍历过程中你给表中并不存在的域赋值， `next` 的行为是未定义的。
--- 然而你可以去修改那些已存在的域。 特别指出，你可以清除一些已存在的域。
---@overload fun(table:table):any
---@param table table
---@param index any
---@return any
function next(table, index) end

---
--- 如果 `t` 有元方法 `__pairs`， 以 `t` 为参数调用它，并返回其返回的前三个值。
---
--- 否则，返回三个值：`next` 函数， 表 `t`，以及 **nil**。 因此以下代码
---```
--- for k,v in pairs(t) do _body_ end
---```
--- 能迭代表 `t` 中的所有键值对。
---
--- 参见函数 `next` 中关于迭代过程中修改表的风险。
---@generic K, V
---@param t table<K, V>|V[]
---@return fun(tbl: table<K, V>):K, V
function pairs(t) end

---
--- 传入参数，以 _保护模式_ 调用函数 `f` 。这意味着 `f` 中的任何错误不会抛出；
--- 取而代之的是，`pcall` 会将错误捕获到，并返回一个状态码。
--- 第一个返回值是状态码（一个布尔值）， 当没有错误时，其为真。
--- 此时，`pcall` 同样会在状态码后返回所有调用的结果。
--- 在有错误时，`pcall` 返回 **false** 加错误消息。
---@overload fun(f:fun():any):boolean|table
---@param f fun():any
---@param arg1 table
---@return boolean|table
function pcall(f, arg1, ...) end

---
--- 接收任意数量的参数，并将它们的值打印到 `stdout`。
--- 它用 `tostring` 函数将每个参数都转换为字符串。
--- `print` 不用于做格式化输出。仅作为看一下某个值的快捷方式。
--- 多用于调试。 完整的对输出的控制，
--- 请使用 `string.format` 以及 `io.write`。
---@vararg any
function print(...) end

---
--- 在不触发任何元方法的情况下检查 `v1` 是否和 `v2` 相等。
--- 返回一个布尔值。
---@param v1 any
---@param v2 any
---@return boolean
function rawequal(v1, v2) end

---
--- 在不触发任何元方法的情况下获取 `table[index]` 的值。
--- `table` 必须是一张表； `index` 可以是任何值。
---@param table table
---@param index any
---@return any
function rawget(table, index) end

---
--- 在不触发任何元方法的情况下 返回对象 `v` 的长度。
--- `v` 可以是表或字符串。 它返回一个整数。
---@param v string|table
---@return number
function rawlen(v) end

--- 在不触发任何元方法的情况下 将 `table[index]` 设为 `value`。
--- `table` 必须是一张表， `index` 可以是 **nil** 与 NaN 之外的任何值。`value` 可以是任何 Lua 值。
---
--- 这个函数返回 `table`。
---@param table table
---@param index any
---@param value any
---@return table
function rawset(table, index, value) end

---
--- 加载一个模块。 这个函数首先查找 `package.loaded` 表，检测 `modname` 是否被加载过。
--- 如果被加载过，`require` 返回 `package.loaded[modname]` 中保存的值。否则，它试着为模块寻找 *加载器*。
---
--- `require` 遵循 `package.searchers` 序列的指引来查找加载器。
--- 如果改变这个序列，我们可以改变 `require` 如何查找一个模块。
--- 下列说明基于 `package.searchers` 的默认配置。
---
--- 首先 `require` 查找 `package.preload[modname]` 。 如果这里有一个值，这个值（必须是一个函数）就是那个加载器。
--- 否则 `require` 使用 Lua 加载器去查找 `package.path` 的路径。
--- 如果查找失败，接着使用 C 加载器去查找 `package.cpath` 的路径。
--- 如果都失败了，再尝试 *一体化* 加载器 （参见 `package.searchers`）。
---
--- 每次找到一个加载器，require 都用两个参数调用加载器：
--- modname 和一个在获取加载器过程中得到的参数。 （如果通过查找文件得到的加载器，这个额外参数是文件名。）
--- 如果加载器返回非空值， `require` 将这个值赋给 `package.loaded[modname]`。
--- 如果加载器没能返回一个非空值用于赋给 `package.loaded[modname]`， `require` 会在那里设入 **true** 。
--- 无论是什么情况，`require` 都会返回 `package.loaded[modname]` 的最终值。
---
--- 如果在加载或运行模块时有错误， 或是无法为模块找到加载器， require 都会抛出错误。
---@param modname string
---@return any
function require(modname) end

---
--- 如果 `index` 是个数字， 那么返回参数中第 `index` 个之后的部分；
--- 负的数字会从后向前索引（-1 指最后一个参数）。
--- 否则，`index` 必须是字符串 `"#"`， 此时 `select` 返回参数的个数。
---@generic T
---@param index number|string
---@vararg T
---@return T
function select(index, ...) end

---
--- 给指定表设置元表。 （你不能在 Lua 中改变其它类型值的元表，那些只能在 C 里做。）
--- 如果 `metatable` 是 **nil**， 将指定表的元表移除。
--- 如果原来那张元表有 `"__metatable"` 域，抛出一个错误。
---
--- 这个函数返回 `table`。
---@generic T
---@param table T
---@param metatable table
---@return T
function setmetatable(table, metatable) end

---
--- 如果调用的时候没有 `base`， `tonumber` 尝试把参数转换为一个数字。如果参数已经是一个数字，
--- 或是一个可以转换为数字的字符串， `tonumber` 就返回这个数字； 否则返回 **nil**。
---
--- 字符串的转换结果可能是整数也可能是浮点数， 这取决于 Lua 的转换文法。 
--- （字符串可以有前置和后置的空格，可以带符号。）
---
--- 当传入 `base` 调用它时， `e` 必须是一个以该进制表示的整数字符串。
--- 进制可以是 2 到 36 （包含 2 和 36）之间的任何整数。
--- 大于 10 进制时，字母 ‘`A`’ （大小写均可）表示 10 ， ‘`B`’ 表示 11，依次到 ‘`Z`’ 表示 35 。
--- 如果字符串 `e` 不是该进制下的合法数字， 函数返回 **nil**。
---@overload fun(e:string):any
---@param e string
---@param base number
---@return any
function tonumber(e, base) end

---
--- 可以接收任何类型，它将其转换为人可阅读的字符串形式。
--- 浮点数总被转换为浮点数的表现形式（小数点形式或是指数形式）。
--- （如果想完全控制数字如何被转换，可以使用 `string.format`。）
---
--- 如果 `v` 有 `"__tostring"` 域的元方法， `tostring` 会以 `v` 为参数调用它。
--- 并用它的结果作为返回值。
---@param v any
---@return string
function tostring(v) end

---
--- 将参数的类型编码为一个字符串返回。 函数可能的返回值有
--- "`nil`" （一个字符串，而不是 **nil** 值）， "`number`"， "`string`"，
--- "`boolean`"， "`table`"， "`function`"，
--- "`thread`"， "`userdata`"。
---@param v any
---@return string
function type(v) end

---
--- 一个包含有当前解释器版本号的全局变量（并非函数）。
--- 当前这个变量的值为 “`Lua 5.3`”。
_VERSION = "Lua 5.3"

---
--- 这个函数和 `pcall` 类似。
--- 不过它可以额外设置一个消息处理器 `msgh`。
---@param f fun():any
---@param msgh fun():string
---@return any
function xpcall(f, msgh, arg1, ...) end
