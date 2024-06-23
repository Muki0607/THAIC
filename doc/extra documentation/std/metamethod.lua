---THAIC Added
---Standard Lua Metamethod Hints by Muki

---本文档适用于Lua5.1（当前LuaSTG的版本），但同时也包含后续版本的元方法
---应当注意，对于Lua5.3及之后的版本，table库中的函数会触发元方法；对于这之前的版本，table库中的函数不会触发元方法。

---相加操作元方法，对应操作`a + b`
---
---返回值将被调整至一个
---
---@type function
---@return any
function __add(a, b) end

---相减操作元方法，对应操作`a - b`
---
---返回值将被调整至一个
---
---@type function
---@return any
function __sub(a, b) end

---相乘操作元方法，对应操作`a * b`
---
---返回值将被调整至一个
---
---@type function
---@return any
function __mul(a, b) end

---相除操作元方法，对应操作`a / b`
---
---返回值将被调整至一个
---
---@type function
---@return any
function __div(a, b) end

---求余操作元方法，对应操作`a % b`
---
---返回值将被调整至一个
---
---@type function
---@return any
function __mod(a, b) end

---乘方操作元方法，对应操作`a ^ b`
---
---返回值将被调整至一个
---
---@type function
---@return any
function __pow(a, b) end

---取负操作元方法，对应操作`-a`
---
---返回值将被调整至一个
---
---@type function
---@return any
function __unm(a) end

---连接操作元方法，对应操作`a .. b`
---
---返回值将被调整至一个
---
---@type function
---@return any
function __concat(a, b) end

---取长度操作元方法，对应操作`#a`
---
---返回值将被调整至一个
---
---@type function
---@return any
function __len(a) end

---判断等于操作元方法，对应操作`a == b`
---
---返回值将被调整至一个并转换为布尔值
---
---@type function
---@return boolean
function __eq(a, b) end

---判断小于等于操作元方法，对应操作`a < b`
---
---返回值将被调整至一个并转换为布尔值
---
---@type function
---@return boolean
function __lt(a, b) end

---判断小于操作元方法，对应操作`a <= b`
---
---返回值将被调整至一个并转换为布尔值
---
---@type function
---@return boolean
function __le(a, b) end

---转换至字符串操作元方法，对应操作`tostring(a)`/`print(a)`
---
---返回值将被调整至一个
---
---@type function
---@return any
function __tostring(a) end

---索引操作元方法，对应操作`table[key]`
---
---@type function|table
---@return ...
function __index(table, key) end

---索引赋值操作元方法，对应操作`table[key] = value`
---
---@type function|table
---@return ...
function __newindex(table, key, value) end

---函数调用操作元方法，对应操作`func()`
---
---@type function
---@return ...
function __call(func, ...) end

---终结器元方法，当表被回收时被调用
---
---如果在设置元表后再为元表加上该域，该元方法将不会起效
---
---返回值将被调整至一个
---
---@type function
---@return ...
function __gc(table) end

---元表元方法，当调用`getmetatable(table)`时，若存在该元方法则返回其关联的值
---
---@type any
__metatable = nil

---控制表的弱属性的值
---
---@alias metatable_weakmode '"k"' | '"v"' | '"kv"'
---@type string|metatable_weakmode
__mode = nil

---当使用C API `luaL_newmetatable` 为用户数据设置元表时会将其名称赋值给该元表的__name域。
---
---这个值可用于错误输出函数，同时也会在该元表中不存在`__tostring`元方法时作为`tostring(userdata)`的返回值。
---
---@type string
__name = nil

-----------------------------------

---以下元方法在当前Lua版本下不可用

---于Lua5.4中加入
---
---关闭变量元方法，当待关闭变量生命周期结束时被调用，如果生命周期结束是由错误引发的则将traceback作为第二个参数传入
---
---@type function
---@deprecated
function __close(a, b) end

---于Lua5.3中加入
---
---整除操作元方法，对应操作`a // b`
---
---返回值将被调整至一个
---
---@type function
---@deprecated
function __idiv(a, b) end

---于Lua5.3中加入
---
---按位与操作元方法，对应操作`a & b`
---
---返回值将被调整至一个
---
---@type function
---@deprecated
function __band(a, b) end

---于Lua5.3中加入
---
---按位或操作元方法，对应操作`a | b`
---
---返回值将被调整至一个
---
---@type function
---@deprecated
function __bor(a, b) end

---于Lua5.3中加入
---
---按位异或操作元方法，对应操作`a ~ b`
---
---返回值将被调整至一个
---
---@type function
---@deprecated
function __bxor(a, b) end

---于Lua5.3中加入
---
---按位非操作元方法，对应操作`~a`
---
---返回值将被调整至一个
---
---@type function
---@deprecated
function __bnot(a) end

---于Lua5.3中加入
---
---左移操作元方法，对应操作`a << n`
---
---返回值将被调整至一个
---
---@type function
---@deprecated
function __shl(a, n) end

---于Lua5.3中加入
---
---右移操作元方法，对应操作`a >> n`
--- 
---返回值将被调整至一个
---
---@type function
---@deprecated
function __shr(a, n) end

---于Lua5.2中加入，于Lua5.3中移除
---
---ipairs遍历元方法，对应操作`ipairs(a)`
---
---返回值将被调整至三个
---
---@type function
---@deprecated
function __ipairs(a) end

---于Lua5.2中加入
---
---pairs遍历元方法，对应操作`pairs(a)`
---
---返回值将被调整至三个
---
---@type function
---@deprecated
function __pairs(a) end
