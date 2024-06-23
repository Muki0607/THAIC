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
--- 包管理库提供了从 Lua 中加载模块的基础库。
--- 只有一个导出函数直接放在全局环境中： `require`。
--- 所有其它的部分都导出在表 `package` 中。
package = {}

---
--- 一个描述有一些为包管理准备的编译期配置信息的串。 这个字符串由一系列行构成：
---
--- 第一行是目录分割串。 对于 Windows 默认是 ‘`\`’ ，对于其它系统是 ‘`/`’ 。
---
--- 第二行是用于路径中的分割符。默认值是 ‘`;`’ 。
---
--- 第三行是用于标记模板替换点的字符串。 默认是 ‘`?`’ 。
---
--- 第四行是在 Windows 中将被替换成执行程序所在目录的路径的字符串。 默认是 ‘`!`’ 。
---
--- 第五行是一个记号，该记号之后的所有文本将在构建 `luaopen_` 函数名时被忽略掉。 默认是 ‘`-`’。
package.config = ""

---
--- 这个路径被 `require` 在 C 加载器中做搜索时用到。
---
--- Lua 用和初始化 Lua 路径 `package.path` 相同的方式初始化 C 路径 `package.cpath` 。
--- 它会使用环境变量 `LUA_CPATH_5_3` 或 环境变量 `LUA_CPATH` 初始化。
--- 要么就采用 `luaconf.h` 中定义的默认路径。
package.cpath = ""


---
--- 用于 `require` 控制哪些模块已经被加载的表。 当你请求一个 `modname` 模块，
--- 且 `package.loaded[modname]` 不为假时， `require` 简单返回储存在内的值。
---
--- 这个变量仅仅是对真正那张表的引用； 改变这个值并不会改变 `require` 使用的表。
package.loaded = {}

---
--- 让宿主程序动态链接 C 库 `libname` 。
---
--- 当 `funcname` 为 “`*`”， 它仅仅连接该库，让库中的符号都导出给其它动态链接库使用。 
--- 否则，它查找库中的函数 `funcname` ，以 C 函数的形式返回这个函数。 
--- 因此，`funcname` 必须遵循原型 `lua_CFunction` （参见 `lua_CFunction`）。
---
--- 这是一个低阶函数。 它完全绕过了包模块系统。 和 `require` 不同， 它不会做任何路径查询，也不会自动加扩展名。
--- `libname` 必须是一个 C 库需要的完整的文件名，如果有必要，需要提供路径和扩展名。
--- `funcname` 必须是 C 库需要的准确名字 （这取决于使用的 C 编译器和链接器）。
---
--- 这个函数在标准 C 中不支持。 因此，它只在部分平台有效 （ Windows ，Linux ，Mac OS X, Solaris, BSD, 加上支持 `dlfcn` 标准的 Unix 系统）。
---@param libname string
---@param funcname string
---@return fun():nil
function package.loadlib(libname, funcname) end

---
--- 这个路径被 `require` 在 Lua 加载器中做搜索时用到。
---
--- 在启动时，Lua 用环境变量 `LUA_PATH_5_3` 或环境变量 `LUA_PATH` 来初始化这个变量。
--- 或采用 `luaconf.h` 中的默认路径。 环境变量中出现的所有 “`;;`” 都会被替换成默认路径。
package.path = ""

---
--- 保存有一些特殊模块的加载器 （参见 `require`）。
---
--- 这个变量仅仅是对真正那张表的引用； 改变这个值并不会改变 `require` 使用的表。
package.preload = {}

---
--- 用于 `require` 控制如何加载模块的表。
---
--- 这张表内的每一项都是一个 查找器函数。 当查找一个模块时， `require` 按次序调用这些查找器， 
--- 并传入模块名（`require` 的参数）作为唯一的一个参数。 此函数可以返回另一个函数（模块的 *加载器*）加上另一个将传递给这个加载器的参数。
--- 或是返回一个描述为何没有找到这个模块的字符串 （或是返回 **nil** 什么也不想说）。
---
--- Lua 用四个查找器函数初始化这张表。
---
--- 第一个查找器就是简单的在 `package.preload` 表中查找加载器。
---
--- 第二个查找器用于查找 Lua 库的加载库。 它使用储存在 `package.path` 中的路径来做查找工作。 查找过程和函数 `package.searchpath` 描述的一致。
---
--- 第三个查找器用于查找 C 库的加载库。 它使用储存在 `package.cpath` 中的路径来做查找工作。
--- 同样， 查找过程和函数 package.searchpath 描述的一致。 例如，如果 C 路径是这样一个字符串
---
---  "`./?.so;./?.dll;/usr/local/?/init.so`"
---
--- 查找器查找模块 foo 会依次尝试打开文件 `./foo.so，./foo.dll`， 以及 `/usr/local/foo/init.so`。
--- 一旦它找到一个 C 库， 查找器首先使用动态链接机制连接该库。 然后尝试在该库中找到可以用作加载器的 C 函数。
--- 这个 C 函数的名字是 “`luaopen_`” 紧接模块名的字符串， 其中字符串中所有的下划线都会被替换成点。
--- 此外，如果模块名中有横线， 横线后面的部分（包括横线）都被去掉。
--- 例如，如果模块名为 `a.b.c-v2.1`， 函数名就是 `luaopen_a_b_c`。
---
--- 第四个搜索器是 *一体化* 加载器。 它从 C 路径中查找指定模块的根名字。
--- 例如，当请求 `a.b.c`　时， 它将查找 `a` 这个 C 库。 如果找得到，它会在里面找子模块的加载函数。
--- 在我们的例子中，就是找　`luaopen_a_b_c`。 利用这个机制，可以把若干 C 子模块打包进单个库。 每个子模块都可以有原本的加载函数名。
---
--- 除了第一个（预加载）搜索器外，每个搜索器都会返回它找到的模块的文件名。
--- 这和 `package.searchpath` 的返回值一样。 第一个搜索器没有返回值。
package.searchers = {}

---
--- 在指定 `path` 中搜索指定的 `name` 。
---
--- 路径是一个包含有一系列以分号分割的模板构成的字符串。
--- 对于每个模板，都会用 `name` 替换其中的每个问号（如果有的话）。
--- 且将其中的 `sep` （默认是点）替换为 `rep` （默认是系统的目录分割符）。 然后尝试打开这个文件名。
---
--- 例如，如果路径是字符串
---
---  "`./?.lua;./?.lc;/usr/local/?/init.lua`"
---
--- 搜索 `foo.a` 这个名字将 依次尝试打开文件 `./foo/a.lua` ， `./foo/a.lc` ，以及 `/usr/local/foo/a/init.lua`。
---
--- 返回第一个可以用读模式打开（并马上关闭该文件）的文件的名字。
--- 如果不存在这样的文件，返回 **nil** 加上错误消息。 （这条错误消息列出了所有尝试打开的文件名。）
---@overload fun(name:string, path:string):string
---@param name string
---@param path string
---@param sep string
---@param rep string
---@return string
function package.searchpath(name, path, sep, rep) end

return package
