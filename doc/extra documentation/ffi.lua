--- LuaJIT ffi library
--- translated by Muki with 通义千问

--- FFI（Foreign Function Interface）库允许从纯Lua代码调用外部C函数并使用C数据结构。
--- 术语解释
--- cdecl — 抽象C类型声明（Lua字符串格式）。
--- ctype — C类型对象。这是由`ffi.typeof()`返回的一种特殊类型的cdata，当被调用时充当cdata构造器角色。
--- cdata — C数据对象。它保存对应ctype类型的值。
--- ct — C类型规格，可用于大部分API函数。它可以是cdecl、ctype，或者是充当模板类型的cdata。
--- cb — 回调对象。这是一个C数据对象，存储着一个特殊的函数指针。从C代码中调用这个函数会运行相关的Lua函数。
--- VLA — 可变长度数组使用问号（?）代替元素数量来声明，例如 "int[?]"。在创建时必须提供元素数量（nelem）。
--- VLS — 可变长度结构体是指最后一个元素为VLA的C结构体类型。声明和创建时遵循相同的规则。
--- 声明和访问外部符号：
--- 外部符号必须先声明，然后通过索引C库命名空间进行访问，这会自动将符号绑定到特定库。

---@class ffi
ffi = {}

--- 该函数用于添加多种类型的C声明或外部符号（命名变量或函数）。参数def必须为Lua字符串形式。建议采用字符串参数的语法糖，如下所示：
---```
--- ffi.cdef [[
--- typedef struct foo { int a, b; } foo_t;  // 声明一个结构体和typedef
--- int dofoo(foo_t *f, int n);  /* 声明一个外部C函数 */
--- ]]
---```
--- 字符串内容（上述绿色部分）必须是一组由分号分隔的C声明序列。对于单个声明，末尾的分号可以省略。
--- 注意，虽然已经声明了外部符号，但它们还未绑定到任何特定地址。通过C库命名空间实现绑定（参见下方说明）。
--- C声明尚未经过C预处理器处理。除了`#pragma pack`外，不允许使用任何预处理器标记。
--- 对于现有C头文件中的`#define`，建议替换为`enum`、`static const`或`typedef`，并/或一次性通过外部C预处理器处理文件。小心不要引入来自无关头文件的不需要或冗余声明。
function ffi.cdef(def)
end

--- 这是默认的C库命名空间，注意此处'C'为大写字母。它绑定到目标系统上的默认符号集或库。
--- 基本上，这些符号与C编译器在未指定额外链接库时默认提供的相同。
---@class ffi.C
ffi.C = {}

--- 此函数根据指定名称加载动态库，并返回一个新的C库命名空间，该命名空间绑定到库的符号。
--- 在POSIX系统上，若`global`为真，则也会将库符号加载到全局命名空间。
function ffi.load(name, global)
end

--- 创建cdata对象
--- 下述API函数创建cdata对象（type()返回"cdata"），所有创建的cdata对象都可以被垃圾收集器回收。

--- 根据给定的`ct`创建`cdata`对象。`VLA/VLS`类型需要`nelem`参数。
--- 第二种语法使用`ctype`作为构造器，两者在其他方面完全等价。
---@return ffi.cdata
function ffi.new(ct, nelem, init)
end


--- 根据给定的`ct`创建`ctype`对象，尤其适用于仅需解析`cdecl`一次，然后反复使用`ctype`对象作为构造器的情况。
function ffi.typeof(ct)
end

--- 根据给定的`ct`创建标量`cdata`对象，并使用C类型转换规则的"`cast`"变体初始化`cdata`对象。
--- 该函数主要用于覆盖指针兼容性检查，或者将指针转换为地址或反之亦然。
---@return ffi.cdata
function ffi.cast(ct, init)
end

--- 根据给定的`ct`创建`ctype`对象并将其与元表关联。只允许结构体/联合类型、复数和向量。
--- 如有需要，其他类型可封装在结构体内。`ctype`对象与元表的关联是永久性的，不可更改。
--- 元表内容及其（若有）`__index`表内容同样不可在之后修改。
--- 所关联的元表自动应用于此类型的任何用途，不论对象如何创建或源自何处。
--- 请注意，预先定义的类型操作具有优先级（例如，声明的字段名无法被覆盖）。
--- 所有标准的Lua元方法都已实现，在任何类型的混合操作中直接调用，没有捷径。
--- 对于二元操作，首先检查左操作数是否存在有效的`ctype`元方法。
--- __gc元方法仅适用于结构体/联合类型，并在创建实例期间隐式调用`ffi.gc()`。
function ffi.metatype(ct, metatable)
end

--- 该功能将终结器与指针或聚合`cdata`对象关联起来。`cdata`对象保持不变。
--- 此函数使得非托管资源能够安全地集成到LuaJIT垃圾收集器的自动内存管理中。
--- 典型用法示例：
---```
--- local p = ffi.gc(ffi.C.malloc(n), ffi.C.free)
--- ...
--- p = nil -- 对p的最后一个引用消失
---```
--- 垃圾收集器最终会执行终结器：`ffi.C.free(p)`
--- `cdata`对象的终结器工作原理类似于`userdata`对象的`__gc`元方法：
--- 当指向cdata对象的最后一个引用消失时，将以`cdata`对象作为参数调用关联的终结器。
--- 终结器可以是Lua函数、`cdata`函数或`cdata`函数指针。
--- 通过设置为**nil**的终结器，可以在显式删除资源之前移除现有的终结器，例如：
---```
--- ffi.C.free(ffi.gc(p, nil)) -- 手动释放内存。
---```
function ffi.gc(cdata, finalizer)
end


-- C类型信息
-- 以下API函数提供了关于C类型的信息，它们对于检查cdata对象特别有用。

--- 返回`ct`的字节大小。如果大小未知（例如对于"void"或函数类型），则返回**nil**。
--- 对于`VLA/VLS`类型，除了`cdata`对象外，还需要提供`nelem`参数。
---@return number
function ffi.sizeof(ct, nelem)
end

--- 返回ct所需的最小字节对齐值。
---@return number
function ffi.alignof(ct)
end

---使用示例：
---```
--- ofs,bpos,bsize = ffi.offsetof(ct, field)
---```
--- 返回相对于`ct`起始位置的`field`字段的偏移量（以字节为单位），其中`ct`必须为结构体。
--- 此外，对于位字段，还会返回其位置和字段大小（以位为单位）。
---@return number,number,number
function ffi.offsetof(ct, field)
end

--- 如果`obj`具有由`ct`给出的C类型，则返回**true**；否则返回**false**。
--- 忽略C类型限定符（如`const`等）。指针按照标准指针兼容规则进行检查，但对于`void *`并无特殊处理。
--- 如果`ct`指定了一个结构体/联合体类型，则接受指向该类型的指针。除此之外，类型必须完全匹配。
--- 注意：此函数接受所有类型的Lua对象作为`obj`参数，但对于非`cdata`对象始终返回**false**。
---@return boolean
function ffi.istype(ct, obj)
end


-- 实用函数

--- 返回最后一次表明错误条件的C函数调用设置的错误编号。如果存在可选参数`newerr`，错误编号会被设置为新值，并返回之前的值。
--- 此函数提供了一种便携且独立于操作系统的获取和设置错误编号的方法。
--- 请注意，只有部分C函数会设置错误编号，而且只有当函数确实指示出错误条件时（例如返回值为-1或NULL），该错误编号才有意义。否则，它可能包含也可能不包含先前设置的任何值。
--- 建议仅在必要时调用此函数，并尽可能靠近相关C函数返回后的调用。
--- `errno`值在钩子、内存分配、JIT编译器调用和其他内部VM活动中得到保留。
--- Windows上的`GetLastError()`返回的值也遵循同样的原则，但您需要自行声明并调用它。
---@return string
function ffi.errno(newerr)
end

--- 从`ptr`指向的数据创建一个内联的Lua字符串。
--- 如果可选参数`len`缺失，则ptr将转换为"`char *`"，并且假定数据是以零结尾的。字符串长度通过`strlen()`计算得出。
--- 否则，`ptr`将转换为"`void *`"，而len则表示数据的长度。数据中可能包含嵌入的零，并且不一定要求按字节对齐（尽管这可能会导致字节顺序问题）。
--- 此函数主要用于将C函数返回的临时"`const char *`"指针转换为Lua字符串，并存储它们或将它们传递给期望接收Lua字符串的其他函数。
--- Lua字符串是对数据的一个（内联）副本，与原始数据区域不再有任何关系。Lua字符串对8位是友好的，可以用来存放任意的、非字符数据。
--- 性能提示：如果已知字符串长度，传入长度会更快。例如，当长度由类似`sprintf()`的C调用返回时。
---@return string
function ffi.string(ptr, len)
end

--- 将`src`指向的数据复制到`dst`。`dst`将转换为"`void *`"，`src`将转换为"`const void *`"。
--- 在第一种语法中，`len`指定要复制的字节数。注意事项：如果`src`是一个Lua字符串，则len必须不超过`#src+1`。
--- 在第二种语法中，复制源必须是一个Lua字符串。将字符串的所有字节以及一个零终止符复制到dst（即`#src+1`个字节）。
--- 性能提示：`ffi.copy()`可以作为一个更快（可内联）的替代方案，用于替换C库函数`memcpy()`、`strcpy()`和`strncpy()`。
function ffi.copy(dst, src, len)
end

--- 使用由`c`指定的`len`个常量字节填充dst指向的数据。如果省略了`c`，则数据将被清零填充。
--- 性能提示：`ffi.fill()` 可以作为C库函数 `memset(dst, c, len)` 的更快（可内联）替代方案。请注意参数顺序的不同！
function ffi.fill(dst, len, c)
end

-- 目标特定信息

--- 如果参数（一个Lua字符串）适用于目标ABI（应用程序二进制接口），则返回**true**；否则返回**false**。当前定义的参数如下：
---```
--->  参数                描述
---> [32bit]            32位架构 
---> [64bit]            64位架构
---> [le]               小端架构
---> [be]               大端架构
---> [fpu]           目标具有硬件FPU
---> [softfp]        softfp调用约定
---> [hardfp]        hardfp调用约定
---> [eabi]         标准ABI的EABI变体
---> [win]         标准ABI的Windows变体
---```
function ffi.abi(param)
end

--- 包含目标操作系统名称。内容与`jit.os`相同。
ffi.os = ""
--- 包含目标架构名称。内容与`jit.arch`相同。
ffi.arch = ""


-- 回调方法


--- 回调的C类型具有一些额外的方法
---@class ffi.callback
local cb = {}

--- 释放与回调关联的资源。关联的Lua函数将不再被固定并可能被垃圾回收。
--- 回调函数指针不再有效，不应再被调用（它可能被随后创建的回调重用）。
function cb:free()
end

--- 将新的Lua函数与回调关联。回调的C类型和回调函数指针保持不变。
--- 这种方法有助于在不每次都创建新回调并重新注册的情况下动态切换回调接收者（例如，在GUI库中使用时）。
function cb:set(func)
end

-- 扩展的标准库函数

--- 以下标准库函数已被扩展以支持与cdata对象一起工作：
---```
--- local n = tonumber(cdata)
---```
--- 将数值型cdata对象转换为double类型，并以Lua数值形式返回。
--- 这对于封装的64位整数值特别有用。注意：这种转换可能会导致精度损失。
---```
--- local s = tostring(cdata)
---```
--- 返回64位整数（"nnnLL" 或 "nnnULL"）或复数（"re±imi"）的字符串表示形式。
--- 否则，返回ctype对象（"ctype"）或cdata对象（"cdata: address"）的C类型字符串表示，除非您使用__tostring元方法覆盖它（请参阅ffi.metatype()）。
---```
--- local iter, obj, start = pairs(cdata)
--- iter, obj, start = ipairs(cdata)
---```
--- 调用相应ctype的__pairs或__ipairs元方法。
---
---@class ffi.cdata
local cdata = {}

-- Lua解析器扩展
-- Lua源代码解析器将带有后缀LL或ULL的数字字面量当作带符号或无符号64位整数处理。
-- 大小写不敏感，但推荐使用大写以提高可读性。
-- 它同时支持十进制（如42LL）和十六进制（如0x2aLL）字面量。

-- 复数的虚部可通过在数字字面量后附加i或I来指定，例如12.5i。
-- 需要注意的是，要获取虚部值为1的复数，你需要使用1i，因为i本身仍引用名为i的变量。

return ffi
