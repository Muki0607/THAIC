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
--- I/O 库提供了两套不同风格的文件处理接口。 第一种风格使用隐式的文件句柄；
--- 它提供设置默认输入文件及默认输出文件的操作， 所有的输入输出操作都针对这些默认文件。 第二种风格使用显式的文件句柄。
---
--- 当使用隐式文件句柄时， 所有的操作都由表 `io` 提供。
--- 若使用显式文件句柄， `io.open` 会返回一个文件句柄，且所有的操作都由该文件句柄的方法来提供。
---
--- 表 `io` 中也提供了三个 和 C 中含义相同的预定义文件句柄： `io.stdin`， `io.stdout`， 以及 `io.stderr`。
--- I/O 库永远不会关闭这些文件。
---
--- 除非另有说明， I/O 函数在出错时都返回 **nil** （第二个返回值为错误消息，第三个返回值为系统相关的错误码）。
--- 成功时返回与 **nil** 不同的值。 在非 POSIX 系统上，
--- 根据错误码取出错误消息的过程可能并非线程安全的，因为这使用了 C 的全局变量 `errno` 。
io = {}

---
--- 等价于 `file:close()`。 不给出 `file` 时将关闭默认输出文件。
---@overload fun():void
---@param file file
function io.close(file) end

---
--- 等价于 `io.output():flush()`。
function io.flush() end

---
--- 用文件名调用它时，（以文本模式）来打开该名字的文件， 并将文件句柄设为默认输入文件。
--- 如果用文件句柄去调用它， 就简单的将该句柄设为默认输入文件。
--- 如果调用时不传参数，它返回当前的默认输入文件。
---
--- 在出错的情况下，函数抛出错误而不是返回错误码。
---@overload fun():file
---@param file file | string
---@return file
function io.input(file) end

---
--- 以读模式打开指定的文件名并返回一个迭代函数。 此迭代函数的工作方式和用一个已打开的文件去调用 `file:lines(···)` 得到的迭代器相同。
--- 当迭代函数检测到文件结束， 它不返回值（让循环结束）并自动关闭文件。
---
--- 调用 `io.lines()` （不传文件名） 等价于 `io.input():lines("*l")`；
--- 即，它将按行迭代标准输入文件。 在此情况下，循环结束后它不会关闭文件。
---
--- 在出错的情况下，函数抛出错误而不是返回错误码。
---@overload fun():any
---@param filename string
---@return fun():any
function io.lines(filename, ...) end

---
--- 这个函数用字符串 `mode` 指定的模式打开一个文件。 返回新的文件句柄。 当出错时，返回 **nil** 加错误消息。
---
--- `mode` 字符串可以是下列任意值：
---
--- “`r`”: 读模式（默认）；
---
--- “`w`”: 写模式；
---
--- “`a`”: 追加模式；
---
--- “`r+`”: 更新模式，所有之前的数据都保留；
---
--- “`w+`”: 更新模式，所有之前的数据都删除；
---
--- “`a+`”: 追加更新模式，所有之前的数据都保留，只允许在文件尾部做写入。
---
--- `mode` 字符串可以在最后加一个 ‘`b`’ ， 这会在某些系统上以二进制方式打开文件。
---@overload fun(filename:string):file
---@param filename string
---@param mode string | '"r"' | '"w"' | '"a"' | '"r+"' | '"w+"' | '"a+"' | '"rb"' | '"wb"' | '"ab"' | '"rb+"' | '"wb+"' | '"ab+"'
---@return file
function io.open(filename, mode) return file end

---
--- 类似于 `io.input`。 不过都针对默认输出文件操作。
---@overload fun():file
---@param file file | string
---@return file
function io.output(file) end

---
--- 这个函数和系统有关，不是所有的平台都提供。
---
--- 用一个分离进程开启程序 `prog`， 返回的文件句柄可用于从这个程序中读取数据 （如果 `mode` 为 `"r"`，这是默认值）
--- 或是向这个程序写入输入（当 `mode` 为 `"w"` 时）。
---@overload fun(prog:string):file
---@param prog string
---@param mode string | '"r"' | '"w"'
---@return file
function io.popen(prog, mode) end

---
--- 等价于 `io.input():read(···)`。
function io.read(...) end

---
--- 如果成功，返回一个临时文件的句柄。
--- 这个文件以更新模式打开，在程序结束时会自动删除。
function io.tmpfile() end

---
--- 检查 `obj` 是否是合法的文件句柄。 如果 `obj` 它是一个打开的文件句柄，返回字符串 `"file"`。
--- 如果 `obj` 是一个关闭的文件句柄，返回字符串 `"closed file"`。 如果 obj 不是文件句柄，返回 **nil** 。
---@param obj string|file
---@return file
function io.type(obj) end

---
--- 等价于 `io.output():write(···)`。
function io.write(...) end

--- 文件句柄对象
---@class file
local file = {}

---
--- 关闭 `file`。 注意，文件在句柄被垃圾回收时会自动关闭，但是多久以后发生，时间不可预期的。
---
--- 当关闭用 `io.popen` 创建出来的文件句柄时， `file:close` 返回与 `os.execute` 的返回值一样的值。
function file:close() end

---
--- 将写入的数据保存到 `file` 中。
function file:flush() end

---
--- 返回一个迭代器函数， 每次调用迭代器时，都从文件中按指定格式读数据。
--- 如果没有指定格式，使用默认值 “`l`” 。 作为示例，以下代码
---```
--- for c in file:lines(1) do _body_ end
---```
--- 会从文件当前位置开始，从中不断读出字符。
--- 和 `io.lines` 不同， 这个函数在循环结束后不会关闭文件。
---
--- 在出错的情况下，函数抛出错误而不是返回错误码。
---@return fun():any
function file:lines(...) end

---
--- 读文件 file， 指定的格式决定了要读什么。 对于每种格式，函数返回读出的字符对应的字符串或数字。
--- 若不能以该格式对应读出数据则返回 **nil**。 （对于最后这种情况， 函数不会读出后续的格式。）
--- 当调用时不传格式，它会使用默认格式读下一行（见下面描述）。
---
--- 提供的格式有
---
--- “`n`”: 读取一个数字，根据 Lua 的转换文法，可能返回浮点数或整数。 （数字可以有前置或后置的空格，以及符号。）
--- 只要能构成合法的数字，这个格式总是去读尽量长的串；
--- 如果读出来的前缀无法构成合法的数字 （比如空串，”`0x`” 或 “`3.4e-`”）， 就中止函数运行，返回 **nil**。
---
--- “`a`”: 从当前位置开始读取整个文件。 如果已在文件末尾，返回空串。
---
--- “`l`”: 读取一行并忽略行结束标记。 当在文件末尾时，返回 **nil** 这是默认格式。
---
--- “`L`”: 读取一行并保留行结束标记（如果有的话）， 当在文件末尾时，返回 **nil**。
---
--- **number**: 读取一个不超过这个数量字节数的字符串。 当在文件末尾时，返回 **nil**。 如果 `number` 为零， 它什么也不读，返回一个空串。 当在文件末尾时，返回 nil。
---
--- 格式 “`l`” 和 “`L`” 只能用于文本文件。
function file:read(...) end

---
--- 设置及获取基于文件开头处计算出的位置。 设置的位置由 offset 和 whence 字符串 whence 指定的基点决定。
--- 基点可以是：
---
--- “`set`”: 基点为 0 （文件开头）；
---
--- “`cur`”: 基点为当前位置；
---
--- “`end`”: 基点为文件尾；
---
--- 当 `seek` 成功时，返回最终从文件开头计算起的文件的位置。
--- 当 `seek` 失败时，返回 **nil** 加上一个错误描述字符串。
---
--- `whence` 的默认值是 "`cur`"， `offset` 默认为 0 。
--- 因此，调用 `file:seek()` 可以返回文件当前位置，并不改变它；
--- 调用 `file:seek("set")` 将位置设为文件开头（并返回 0）；
--- 调用 `file:seek("end")` 将位置设到文件末尾，并返回文件大小。
---@overload fun()
---@param whence string | '"set"' | '"cur"' | '"end"'
---@param offset number
function file:seek(whence, offset) end

---
--- 设置输出文件的缓冲模式。 有三种模式：
---
--- “`no`”: 不缓冲；输出操作立刻生效。
---
--- “`full`”: 完全缓冲；只有在缓存满或当你显式的对文件调用 `flush`（参见 `io.flush`） 时才真正做输出操作。
---
--- “`line`”: 行缓冲； 输出将缓冲到每次换行前， 对于某些特殊文件（例如终端设备）缓冲到任何输入前。
---
--- 对于后两种情况，`size` 以字节数为单位 指定缓冲区大小。 默认会有一个恰当的大小。
---@overload fun(mode:string)
---@param mode string | '"no"' | '"full"' | '"line"'
---@param size number
function file:setvbuf(mode, size) end

---
--- 将参数的值逐个写入 `file`。 参数必须是字符串或数字。
---
--- 成功时，函数返回 `file`。 否则返回 **nil** 加错误描述字符串。
function file:write(...) end

--- * `io.stderr`: 标准错误文件句柄。
---@type file
io.stderr = nil

--- * `io.stdin`: 标准输入文件句柄。
---@type file
io.stdin = nil

--- * `io.stdout`: 标准输出文件句柄。
---@type file
io.stdout = nil
