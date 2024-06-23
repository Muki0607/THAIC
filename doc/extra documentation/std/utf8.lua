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
--- 这个库提供了对 UTF-8 编码的基础支持。 所有的函数都放在表 `utf8` 中。
--- 此库不提供除编码处理之外的任何 Unicode 支持。
--- 所有需要了解字符含义的操作，比如字符分类，都不在此范畴。
---
--- 除非另有说明， 当一个函数需要一个字节位置的参数时，
--- 都假定这个位置要么从字节序列的开始计算， 要么从字符串长度加一的位置算。
--- 和字符串库一样，负的索引从字符串末尾计起。
utf8 = {}

---
--- 接收零或多个整数， 将每个整数转换成对应的 UTF-8 字节序列，
--- 并返回这些序列连接到一起的字符串。
---@return string
function utf8.char(...) end

---
--- 用于精确匹配到一个 UTF-8 字节序列的模式（是一个字符串，并非函数）“`[\0-\x7F\xC2-\xF4][\x80-\xBF]*`” 。 
--- 它假定处理的对象是一个合法的 UTF-8 字符串。
---@type string
utf8.charpattern = ""

---
--- 返回一系列的值，可以让
---```
--- for p, c in utf8.codes(s) do _body_ end
---```
--- 迭代出字符串 s 中所有的字符。 这里的 `p` 是位置（按字节数）而 `c` 是每个字符的编号。
--- 如果处理到一个不合法的字节序列，将抛出一个错误。
---@param s string
---@return string
function utf8.codes(s) end

---
--- 以整数形式返回 `s` 中 从位置 `i` 到 `j` 间（包括两端） 所有字符的编号。
--- 默认的 `i` 为 1 ，默认的 `j` 为 `i`。
--- 如果碰到不合法的字节序列，抛出一个错误。
---@overload fun(s:string):number
---@param s string
---@param i number
---@param j number
---@return number
function utf8.codepoint(s, i, j) end

---
--- 返回字符串 `s` 中 从位置 `i` 到 `j` 间 （包括两端） UTF-8 字符的个数。
--- 默认的 `i` 为 1 ，默认的 `j` 为 -1 。
--- 如果它找到任何不合法的字节序列， 返回 **false** 加上第一个不合法字节的位置。
---@overload fun(s:string):number
---@param s string
---@param i number
---@param j number
---@return number
function utf8.len(s, i, j) end

---
--- 返回编码在 `s` 中的第 `n` 个字符的开始位置（按字节数） （从位置 `i` 处开始统计）。
--- 负 `n` 则取在位置 `i` 前的字符。 当 `n` 是非负数时，默认的 `i` 是 1， 否则默认为 `#s + 1`。
--- 因此，`utf8.offset(s, -n)` 取字符串的倒数第 `n` 个字符的位置。
--- 如果指定的字符不在其中或在结束点之后，函数返回 **nil**。
--- 作为特例，当 `n` 等于 0 时， 此函数返回含有 `s` 第 `i` 字节的那个字符的开始位置。
--- 这个函数假定 `s` 是一个合法的 UTF-8 字符串。
---@overload fun(s:string):number
---@param s string
---@param n number
---@param i number
---@return number
function utf8.offset(s, n, i) end
