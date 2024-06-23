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
--- 这个库提供了 Lua 程序调试接口的功能。
--- 其中一些函数违反了 Lua 代码的基本假定 （例如，不会从函数之外访问函数的局部变量；
--- 用户数据的元表不会被 Lua 代码修改； Lua 程序不会崩溃），
--- 因此它们有可能危害到其它代码的安全性。 此外，库里的一些函数可能运行的很慢。
---
--- 这个库里的所有函数都提供在表 `debug` 内。 所有操作线程的函数，
--- 可选的第一个参数都是针对的线程。 默认值永远是当前线程。
debug = {}

---
--- 进入一个用户交互模式，运行用户输入的每个字符串。
--- 使用简单的命令以及其它调试设置，用户可以检阅全局变量和局部变量，
--- 改变变量的值，计算一些表达式，等等。
--- 输入一行仅包含 cont 的字符串将结束这个函数，这样调用者就可以继续向下运行。
---
--- 注意，`debug.debug` 输入的命令在文法上并没有内嵌到任何函数中，
--- 因此不能直接去访问局部变量。
function debug.debug() end

---
--- 返回三个表示线程钩子设置的值： 当前钩子函数，
--- 当前钩子掩码，当前钩子计数 （`debug.sethook` 设置的那些）。
---@overload fun():thread
---@param thread thread
---@return thread
function debug.gethook(thread) end

---@class DebugInfo
---@field linedefined number
---@field lastlinedefined number
---@field currentline number
---@field func function
---@field isvararg boolean
---@field namewhat string
---@field source string
---@field nups number
---@field what string
---@field nparams number
---@field short_src string

---
--- 返回关于一个函数信息的表。 你可以直接提供该函数， 也可以用一个数字 `f` 表示该函数。
--- 数字 `f` 表示运行在指定线程的调用栈对应层次上的函数： 0 层表示当前函数（`getinfo` 自身）；
--- 1 层表示调用 `getinfo` 的函数 （除非是尾调用，这种情况不计入栈）；等等。
--- 如果 `f` 是一个比活动函数数量还大的数字， `getinfo` 返回 **nil**。
---
--- 只有字符串 `what` 中有描述要填充哪些项， 返回的表可以包含 `lua_getinfo` 能返回的所有项。
--- `what` 默认是返回提供的除合法行号表外的所有信息。 对于选项 ‘`f`’ ，会在可能的情况下，增加 `func` 域保存函数自身。
--- 对于选项 ‘`L`’ ，会在可能的情况下，增加 `activelines` 域保存合法行号表。
---
--- 例如，表达式 `debug.getinfo(1,"n")` 返回带有当前函数名字信息的表（如果找的到名字的话），
--- 表达式 `debug.getinfo(print)` 返回关于 `print` 函数的 包含有所有能提供信息的表。
---@overload fun(f:function):DebugInfo
---@param thread thread
---@param f function
---@param what string
---@return DebugInfo
function debug.getinfo(thread, f, what) end

---
--- 此函数返回在栈的 `f` 层处函数的索引为 `local` 的局部变量 的名字和值。
--- 这个函数不仅用于访问显式定义的局部变量，也包括形参、临时变量等。
---
--- 第一个形参或是定义的第一个局部变量的索引为 1 ， 然后遵循在代码中定义次序，以次类推。
--- 其中只计算函数当前作用域的活动变量。 负索引指可变参数； -1 指第一个可变参数。
--- 如果该索引处没有变量，函数返回 **nil**。 若指定的层次越界，抛出错误。 （你可以调用 debug.getinfo 来检查层次是否合法。）
---
--- 以 ‘`(`’ （开括号）打头的变量名表示没有名字的变量 （比如是循环控制用到的控制变量， 或是去除了调试信息的代码块）。
---
--- 参数 `f` 也可以是一个函数。 这种情况下，`getlocal` 仅返回函数形参的名字。
---@overload fun(f:table, var:string):table
---@param thread thread
---@param f table
---@param var string
---@return table
function debug.getlocal(thread, f, var) end

---
--- 返回给定 `value` 的元表。 若其没有元表则返回 **nil** 。
---@param value table
---@return table
function debug.getmetatable(value) end

---
--- 返回注册表。
---@return table
function debug.getregistry() end

---
--- 此函数返回函数 `f` 的第 `up` 个上值的名字和值。 如果该函数没有那个上值，返回 **nil** 。
---
--- 以 ‘`(`’ （开括号）打头的变量名表示没有名字的变量 （去除了调试信息的代码块）。
---@param f number
---@param up number
---@return table
function debug.getupvalue(f, up) end

---
--- 返回第 `n` 个关联在 `u` 上的值加上一个布尔值，
--- 如果这个用户数据没有这个值，其为 **false** 。
--- 如果 `u` 并非用户数据，返回 **nil**。
---@param u userdata
---@param n number
---@return boolean
function debug.getuservalue(u, n) end

---
--- 将一个函数作为钩子函数设入。 字符串 `mask` 以及数字 `count` 决定了钩子将在何时调用。
--- 掩码是由下列字符组合成的字符串，每个字符有其含义：
---
--- ‘`c`’: 每当 Lua 调用一个函数时，调用钩子；
---
--- ‘`r`’: 每当 Lua 从一个函数内返回时，调用钩子；
---
--- ‘`l`’: 每当 Lua 进入新的一行时，调用钩子。
---
--- 此外， 传入一个不为零的 `count` ， 钩子将在每运行 `count` 条指令时调用。
---
--- 如果不传入参数， `debug.sethook` 关闭钩子。
---
--- 当钩子被调用时， 第一个参数是触发这次调用的事件： `"call"` （或 `"tail call"`），
--- `"return"`， `"line"`， `"count"`。 对于行事件， 钩子的第二个参数是新的行号。
--- 在钩子内，你可以调用 `getinfo` ，指定第 2 层， 来获得正在运行的函数的详细信息 （0 层指 `getinfo` 函数， 1 层指钩子函数）。
---@overload fun(hook:(fun():any), mask:any)
---@param thread thread
---@param hook fun():any
---@param mask string
---@param count number
function debug.sethook(thread, hook, mask, count) end

---
--- 这个函数将 `value` 赋给 栈上第 `level` 层函数的第 `local` 个局部变量。
--- 如果没有那个变量，函数返回 **nil** 。 如果 `level` 越界，抛出一个错误。
--- （你可以调用 `debug.getinfo` 来检查层次是否合法。） 否则，它返回局部变量的名字。
---
--- 关于变量索引和名字，参见 `debug.getlocal`。
---@overload fun(level:number, var:string, value:any):string
---@param thread thread
---@param level number
---@param var string
---@param value any
---@return string
function debug.setlocal(thread, level, var, value) end

---
--- 将 `value` 的元表设为 `table` （可以是 **nil**）。返回 `value`。
--- 以上描述是错误的，该函数的实际返回值是一个表达元表设置操作是否成功的布尔值

--- 将 `value` 的元表设为 `table` （可以是 **nil**）。
--- 若元表设置操作成功，返回 **true**; 否则返回 **false**。
---@param value any
---@param table table
---@return boolean
function debug.setmetatable(value, table) end

---
--- 这个函数将 `value` 设为函数 `f` 的第 `up` 个上值。
--- 如果函数没有那个上值，返回 **nil**； 否则返回该上值的名字。
---@param f fun():any
---@param up number
---@param value any
---@return string
function debug.setupvalue(f, up, value) end

---
--- 将 `value` 设为 `udata` 的第 `n` 个关联值。 udata 必须是一个完全用户数据。
--- 如果这个userdata没有这个值，返回 **nil**； 否则返回 `udata`。
---@param udata userdata
---@param value any
---@param n number
---@return userdata
function debug.setuservalue(udata, value, n) end

---
--- 如果 传入 `message` ，且不是字符串或 **nil**， 函数不做任何处理直接返回 `message`。
--- 否则，它返回调用栈的栈回溯信息。 字符串可选项 `message` 被添加在栈回溯信息的开头。
--- 数字可选项 `level` 指明从栈的哪一层开始回溯 （默认为 1 ，即调用 `traceback` 的那里）。
---@overload fun():string
---@param thread thread
---@param message string
---@param level number
---@return string
function debug.traceback(thread, message, level) end

---
--- 返回指定函数第 `n` 个上值的唯一标识符（一个轻量用户数据）。
---
--- 这个唯一标识符可以让程序检查两个不同的闭包是否共享了上值。
--- 若 Lua 闭包之间共享的是同一个上值 （即指向一个外部局部变量），会返回相同的标识符。
---@param f fun():number
---@param n number
---@return number
function debug.upvalueid(f, n) end

---
--- 让 Lua 闭包 `f1` 的第 `n1` 个上值引用 Lua 闭包 `f2` 的第 `n2` 个上值。
---@param f1 fun():any
---@param n1 number
---@param f2 fun():any
---@param n2 number
function debug.upvaluejoin(f1, n1, f2, n2) end
