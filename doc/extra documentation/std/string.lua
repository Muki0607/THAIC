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
--- 这个库提供了字符串处理的通用函数。 例如字符串查找、子串、模式匹配等。
--- 当在 Lua 中对字符串做索引时，第一个字符从 1 开始计算（而不是 C 里的 0 ）。
--- 索引可以是负数，它指从字符串末尾反向解析。 即，最后一个字符在 -1 位置处，等等。
---
--- 字符串库中的所有函数都在表 `string` 中。 它还将其设置为字符串元表的 `__index` 域。
--- 因此，你可以以面向对象的形式使用字符串函数。 例如，`string.byte(s,i)` 可以写成 `s:byte(i)`。
--- 字符串库假定采用单字节字符编码。
string = {}

---
--- 返回字符 `s[i]`， `s[i+1]`， …　，`s[j]` 的内部数字编码。
--- `i` 的默认值是 1 ； `j` 的默认值是 `i`。 这些索引以函数 `string.sub` 的规则修正。
---
--- 数字编码没有必要跨平台。
---@overload fun(s:string):number
---@param s string
---@param i number
---@param j number
---@return number
function string.byte(s, i, j) end

---
--- 接收零或更多的整数。 返回和参数数量相同长度的字符串。
--- 其中每个字符的内部编码值等于对应的参数值。
---
--- 数字编码没有必要跨平台。
---@return string
function string.char(...) end

---
--- 返回包含有以二进制方式表示的（一个 *二进制代码块* ）指定函数的字符串。
--- 之后可以用 `load` 调用这个字符串获得 该函数的副本（但是绑定新的上值）。
--- 如果　`strip` 为真值， 二进制代码块不携带该函数的调试信息 （局部变量名，行号，等等。）。
---
--- 带上值的函数只保存上值的数目。 当（再次）加载时，这些上值被更新为 **nil** 的实例。 
--- 你可以使用调试库按你需要的方式来序列化上值，并重载到函数中）
---@overload fun(func:fun()):string
---@param func fun()
---@param strip boolean
---@return string
function string.dump(func, strip) end

---
--- 查找第一个字符串 `s` 中匹配到的 `pattern` 。 
--- 如果找到一个匹配，`find` 会返回 `s` 中关于它起始及终点位置的索引；否则，返回 **nil**。
--- 第三个可选数字参数 `init` 指明从哪里开始搜索； 默认值为 1 ，同时可以是负值。 
--- 第四个可选参数 `plain` 为 **true** 时， 关闭模式匹配机制。 此时函数仅做直接的 “查找子串”的操作，
--- 而 `pattern` 中没有字符被看作转义字符。 注意，如果给定了 `plain`　，就必须写上 `init` 。
---
--- 如果在模式中定义了捕获，捕获到的若干值也会在两个索引之后返回。
---@overload fun(s:string, pattern:string):number, number, string
---@param s string
---@param pattern string
---@param init number
---@param plain boolean
---@return number, number, string
function string.find(s, pattern, init, plain) end

---
--- 返回不定数量参数的格式化版本， 格式化串为第一个参数（必须是一个字符串）。
--- 格式化字符串遵循 ISO C 函数 `sprintf` 的规则。
--- 不同点在于选项 `*`, `h`, `L`, `l`, `n`, `p` 不支持， 另外还增加了一个选项 `q`。
--- `q` 选项将一个字符串格式化为两个双引号括起，对内部字符做恰当的转义处理的字符串。
--- 该字符串可以安全的被 Lua 解释器读回来。 例如，调用
---```
--- string.format('%q', 'a string with "quotes" and \\n new line')
--- 会产生字符串：
---```
---```
--- "a string with \\"quotes\\" and \\
--- new line"
---```
---```
---```
--- 选项 `A` 和 `a` （如果有的话）， `E`, `e`, `f`, `G`, 和 `g` 都需要一个对应的数字参数。
--- 选项 `c`, `d`, `i`, `o`, `u`, `X` 和 `x` 则期待一个整数。
--- 选项 `q` 需要一个字符串； 选项 `s` 需要一个没有内嵌零的字符串。
--- 如果选项 `s` 对应的参数不是字符串，它会用和 `tostring` 一致的规则转换成字符串。
---@param formatstring string
---@return string
function string.format(formatstring, ...) end

---
--- 返回一个迭代器函数。 每次调用这个函数都会继续以 `pattern` 对 `s` 做匹配，并返回所有捕获到的值。
--- 如果 `pattern` 中没有指定捕获，则每次捕获整个 `pattern`。
---
--- 下面这个例子会循环迭代字符串 `s` 中所有的单词， 并逐行打印：
---```
--- s = "hello world from Lua"
--- for w in string.gmatch(s, "%a+") do
---   print(w)
--- end
---```
--- 下一个例子从指定的字符串中收集所有的键值对 `key=value` 置入一张表：
---```
--- t = {}
--- s = "from=world, to=Lua"
--- for k, v in string.gmatch(s, "(%w+)=(%w+)") do
---   t[k] = v
--- end
---```
--- 对这个函数来说，模板前开始的 ‘`^`’ 不会当成锚点。因为这样会阻止迭代。
---@param s string
---@param pattern string
---@return fun():string, table
function string.gmatch(s, pattern) end

---
--- 将字符串 `s` 中，所有的（或是在 `n` 给出时的前 `n` 个） `pattern` 都替换成 `repl` ，并返回其副本。
--- `repl` 可以是字符串、表、或函数。 `gsub` 还会在第二个返回值返回一共发生了多少次匹配。
--- `gsub` 这个名字来源于 *Global SUBstitution* 。
---
--- 如果 `repl` 是一个字符串，那么把这个字符串作为替换品。
--- 字符 `%` 是一个转义符： `repl` 中的所有形式为 `%d` 的串表示 第 *d* 个捕获到的子串，*d* 可以是 1 到 9 。 串 `%0` 表示整个匹配。 串 `%%` 表示单个 `%`。
---
--- 如果 `repl` 是张表，每次匹配时都会用第一个捕获物作为键去查这张表。
---
--- 如果 `repl` 是个函数，则在每次匹配发生时都会调用这个函数。 所有捕获到的子串依次作为参数传入。
---
--- 任何情况下，模板中没有设定捕获都看成是捕获整个模板。
---
--- 如果表的查询结果或函数的返回结果是一个字符串或是个数字， 都将其作为替换用串； 而在返回 **false** 或 **nil**　时不作替换 （即保留匹配前的原始串）。
---
--- 这里有一些用例：
---```
--- x = string.gsub("hello world", "(%w+)", "%1 %1")
--- --> x="hello hello world world"
---
--- x = string.gsub("hello world", "%w+", "%0 %0", 1)
--- --> x="hello hello world"
---
--- x = string.gsub("hello world from Lua", "(%w+)%s\*(%w+)", "%2 %1")
--- --> x="world hello Lua from"
---
--- x = string.gsub("home = $HOME, user = $USER", "%$(%w+)", os.getenv)
--- --> x="home = /home/roberto, user = roberto"
---
--- x = string.gsub("4+5 = $return 4+5$", "%$(.-)%$", function (s)
---       return load(s)()
---     end)
--- --> x="4+5 = 9"
---
--- local t = {name="lua", version="5.3"}
--- x = string.gsub("$name-$version.tar.gz", "%$(%w+)", t)
--- --> x="lua-5.3.tar.gz"
---```
---@overload fun(s:string, pattern:string, repl:string|fun()):string, number
---@param s string
---@param pattern string
---@param repl string|fun()
---@param n number
---@return string, number
function string.gsub(s, pattern, repl, n) end

---
--- 接收一个字符串，返回其长度。 空串 `""` 的长度为 0 。
--- 内嵌零也统计在内，因此 `"a\000bc\000"` 的长度为 5 。
---@param s string
---@return number
function string.len(s) end

---
--- 接收一个字符串，将其中的大写字符都转为小写后返回其副本。
--- 其它的字符串不会更改。 对大写字符的定义取决于当前的区域设置。
---@param s string
---@return string
function string.lower(s) end

---
--- 在字符串 `s` 中找到第一个能用 `pattern` 匹配到的部分。
--- 如果能找到，`match` 返回其中的捕获物； 否则返回 **nil** 。
--- 如果 `pattern` 中未指定捕获， 返回整个 `pattern` 捕获到的串。
--- 第三个可选数字参数 `init` 指明从哪里开始搜索； 它默认为 1 且可以是负数。
---@overload fun(s:string, pattern:string):any
---@param s string
---@param pattern string
---@param init number
---@return any
function string.match(s, pattern, init) end

---
--- 返回一个打包了（即以二进制形式序列化） `v1`, `v2` 等值的二进制字符串。
--- 字符串 `fmt` 为打包格式。
---@param fmt string
---@param v1 string
---@param v2 string
---@return string
function string.pack(fmt, v1, v2, ...) end

---
--- 返回以指定格式用 `string.pack` 打包的字符串的长度。
--- 格式化字符串中不可以有变长选项 ‘`s`’ 或 ‘`z`’ 。
---@param fmt string
---@return number
function string.packsize(fmt) end

---
--- 返回 `n` 个字符串 `s` 以字符串 `sep` 为分割符连在一起的字符串。
--- 默认的 `sep` 值为空字符串（即没有分割符）。 如果 `n` 不是正数则返回空串。
---
--- 注意一次对这个函数的调用就可以非常简单地耗尽你的机器的内存。
---@overload fun(s:string, n:number):string
---@param s string
---@param n number
---@param sep string
---@return string
function string.rep(s, n, sep) end

---
--- 返回字符串 `s` 的翻转串。
---@param s string
---@return string
function string.reverse(s) end

---
--- 返回 `s` 的子串， 该子串从 `i` 开始到 `j` 为止； `i` 和 `j` 都可以为负数。
--- 如果不给出 `j` ，就当它是 -1 （和字符串长度相同）。
--- 特别地， 调用 `string.sub(s,1,j)` 可以返回 `s` 的长度为 `j` 的前缀串，
--- 而 `string.sub(s, -i)` 返回长度为 `i` 的后缀串。
--- 如果在对负数索引转义后 `i` 小于 1 的话，就修正回 1 。 如果 `j` 比字符串的长度还大，就修正为字符串长度。 如果在修正之后，`i` 大于 `j`， 函数返回空串。
---@overload fun(s:string, i:number):string
---@param s string
---@param i number
---@param j number
---@return string
function string.sub(s, i, j) end

---
--- 返回以格式 `fmt` 打包在字符串 `s` （参见 `string.pack`） 中的值。
--- 选项 `pos`（默认为 1 ）标记了从 `s` 中哪里开始读起。
--- 读完所有的值后，函数返回 `s` 中第一个未读字节的位置。
---@overload fun(fmt:string, s:string):string
---@param fmt string
---@param s string
---@param pos number
---@return string
function string.unpack(fmt, s, pos) end

---
--- 接收一个字符串，将其中的小写字符都转为大写后返回其副本。
--- 其它的字符串不会更改。 对小写字符的定义取决于当前的区域设置。
---@param s string
---@return string
function string.upper(s) end
