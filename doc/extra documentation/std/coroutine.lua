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
--- 关于协程的操作作为基础库的一个子库， 被放在一个独立表 `coroutine` 中。
coroutine = {}

---
--- 该函数于Lua5.4加入。
--- 关闭协程 `co` ，即关闭所有待关闭的变量，使协程处于死亡状态。给定的协程必须已死亡或挂起。
--- 如果关闭某个变量时出错，则返回 **false** 加上错误对象；否则返回 **true**。
---@param f fun():thread
---@return thread
function coroutine.close(co) end

---
--- 创建一个主体函数为 `f` 的新协程。 `f` 必须是一个 Lua 的函数。
--- 返回这个新协程，它是一个类型为 `"thread"` 的对象。
---@param f fun():thread
---@return thread
function coroutine.create(f) end

---
--- 如果正在运行的协程可以让出，则返回真。
--- 不在主线程中或不在一个无法让出的 C 函数中时，当前协程是可让出的。
--- 在Lua5.4中，你可以传入可选的参数`co`。若如此做，将返回该线程是否可让出。
---@overload fun(co:thread):boolean
---@return boolean
function coroutine.isyieldable() end

---
--- 开始或继续协程 `co` 的运行。 当你第一次延续一个协程，它会从主体函数处开始运行。
--- `val1`, … 这些值会以参数形式传入主体函数。 如果该协程被让出，`resume` 会重新启动它； `val1`, … 这些参数会作为让出点的返回值。
---
--- 如果协程运行起来没有错误， `resume` 返回 **true** 加上传给 `yield` 的所有值 （当协程让出），
--- 或是主体函数的所有返回值（当协程中止）。 如果有任何错误发生， `resume` 返回 **false** 加错误消息。
---@overload fun(co:thread):boolean|any
---@param co thread
---@param val1 string
---@return thread|any
function coroutine.resume(co, val1, ...) end

---
--- 返回当前正在运行的协程加一个布尔值。
--- 如果当前运行的协程是主线程，其为真。
---@return thread, boolean
function coroutine.running() end

---
--- 以字符串形式返回协程 `co` 的状态：
--- 当协程正在运行（它就是调用 `status` 的那个） ，返回 `"running"`；
--- 如果协程调用 `yield` 挂起或是还没有开始运行，返回 `"suspended"`；
--- 如果协程是活动的，但并不在运行（即它正在延续其它协程），返回 `"normal"`；
--- 如果协程运行完主体函数或因错误停止，返回 `"dead"`。
---@param co thread
---@return string
function coroutine.status(co) end

---
--- 创建一个主体函数为 `f` 的新协程。 `f` 必须是一个 Lua 的函数。
--- 返回一个函数， 每次调用该函数都会延续该协程。 传给这个函数的参数都会作为 `resume` 的额外参数。
--- 和 `resume` 返回相同的值， 只是没有第一个布尔量。 如果发生任何错误，抛出这个错误。
---@param f fun():thread
---@return fun():any
function coroutine.wrap(f) end

---
--- 挂起正在调用的协程的执行。
--- 传递给 `yield` 的参数都会转为 `resume` 的额外返回值。
---@return any
function coroutine.yield(...) end
