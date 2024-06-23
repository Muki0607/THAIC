---=====================================
---THAIC Table v1.10a
---东方梦摇篮 table扩展库 v1.10a
---=====================================

---版本更新记录
---v1.00a
---初始版本
---v1.01a
---修改了lib.Reverse，使其返回传入的表，以保留元表
---添加函数lib.Search，用于查找表中的值
---v1.02a
---添加了函数lib.Choice、lib.Randomize，用于表的随机相关操作
---添加了函数lib.Insert、lib.Remove，用于需要使用table.insert与table.remove功能且需要触发元方法的情况
---v1.03a
---添加了函数lib.Unpack、lib.UnpackKey、lib.UnpackMetatable、lib.UnpackMetatableKey，用于解包表
---v1.10a
---添加了函数lib.RemoveMetatable，用于移除表的元表
---添加了函数lib.SetValueTable、lib.SetKeyTable，用于定义一种新数据类型keytable（键表）
---添加了函数lib.GetValueTable，用于获取键表的值表
---v1.10b
---现在键表的值表可以为string类型，若如此做，在调用键表时将把_G[valuetable]作为值表
---v1.11a
---添加了函数lib.Slice用于提供表的切片
---添加了函数lib.Clear用于清空表
---添加了函数lib.rawipairs、lib.rawpairs用于在不触发元方法的情况下迭代表
---为大多数函数提供了raw参数，可选择是否触发元方法
---v1.12a
---添加了函数lib.SetMetatable、lib.GetMetatable，是debug与global的两个同名函数的整合
---添加了函数lib.MakeKeyTable，用于简化键表的使用
---添加了函数lib.Exchange用于交换表的键与值
---添加了函数lib.ToString，用于将表转换为易读的字符串

---本函数库提供了一些关于表的函数。需要注意，其中的一些函数未经测试，因此不保障其可用性。

---@class aic.table @东方梦摇篮table扩展库
aic.table = {}
local lib = aic.table

---将表转换为易读的形式
---@param t table @要转换的表
---@return string @转换后的字符串
function lib.ToString(t)
    local ret = '{ '
    for _, v in ipairs(t) do
        ret = ret .. tostring(v) .. ', '
    end
    for k, v in ipairs(t) do
        if not (type(k) == 'number' and k > 0) then
            ret = ret .. '[' .. tostring .. '] =' .. tostring(v) .. ', '
        end
    end
    ret = string.sub(ret, 1, -3) .. ' }'
    return ret
end

---反转表内元素顺序，改自spstring:reverse
---为保留元表，返回的是传入的表而不是新表
---@param t table @要反转的table
---@param raw boolean @是否不触发元方法
---@return table @反转后的table
function lib.Reverse(t)
    local temp = {}
    local len
    if raw then
        len = rawlen(t)
    else
        len = #t
    end
    for i = 1, len do
        temp[i] = table.remove(t)
    end
    for _, v in ipairs(temp) do
        table.insert(t, v)
    end
    return t
end

---获取表长度
---@param t table @要求长度的table
---@param all boolean @是否使用pairs而非ipairs
---@param raw boolean @是否不触发元方法
function lib.Len(t, all)
    if all then
        local iterator = pairs
        if raw then iterator = lib.rawpairs end
        local n = 0
        for _, _ in iterator(t) do
            n = n + 1
        end
        return n
    else
        if raw then
            return rawlen(t)
        else
            return #t
        end
    end
end

---获取表中元素之和，可指定范围
---@param t table @要求和的table
---@param s number @起始位置
---@param e number @终止位置
---@param raw boolean @是否不触发元方法
---@return number @求和结果
function lib.Sum(t, s, e, raw)
    s = s or 1
    if raw then
        e = e or rawlen(t)
    else
        e = e or #t
    end
    if e < s then e = s end
    local n = 0
    for i = s, e do
        if raw then
            n = n + rawget(t, i)
        else
            n = n + t[i]
        end
    end
    return n
end

---获取表中最大元素，表中可含有非number元素
---若表中无number元素则返回nil
---@param t table @要获取最大值的table
---@param raw boolean @是否不触发元方法
---@return number, number @table的最大值与其索引
function lib.Max(t)
    local iterator = pairs
    if raw then iterator = lib.rawpairs end
    local n = -INFINITE
    local kn
    for k, v in iterator(t) do
        if type(v) == 'number' then
            if v > n then n = v kn = k end
        end
    end
    if n > -INFINITE then return n, kn end
end

---获取表中最小元素，表中可含有非number元素
---若表中无number元素则返回nil
---@param t table @要获取最小值的table
---@param raw boolean @是否不触发元方法
---@return number, number @table的最小值与其索引
function lib.Min(t, raw)
    local iterator = pairs
    if raw then iterator = lib.rawpairs end
    local n = INFINITE
    local kn
    for k, v in iterator(t) do
        if type(v) == 'number' then
            if v < n then n = v kn = k end
        end
    end
    if n < INFINITE then return n, kn end
end

---寻找表中特定元素，返回对应的索引
---若有多个相同元素则可指定返回第几个，此时使用ipairs，只搜索数组部分元素
---若无指定元素则返回nil，因此也可用于判断表中是否有指定元素
---@param t table @要寻找的table
---@param value any @元素的值
---@param raw boolean @是否不触发元方法
---@param num number @将返回第num个value对应的索引
---@param init number @将从init处开始查找
---@return any @返回的索引
function lib.Search(t, value, raw, num, init)
    local iterator
    if raw then
        if num then
            iterator = lib.rawipairs
        else
            iterator = lib.rawpairs
        end
    else
        if num then
            iterator = ipairs
        else
            iterator = pairs
        end
    end
    init = init or 1
    local n = 0
    for k, v in iterator(t) do
        if v == value then
            n = n + 1
            if (n == num or not num) and (type(k) ~= 'number' or k >= init) then return k end
        end
    end
end

---随机抽取表内元素
---若表中无number元素则返回nil
---@param t table @要随机抽取的table
---@param all boolean @是否使用pairs而非ipairs
---@param raw boolean @是否不触发元方法
---@param pop boolean @是否删除抽取出的元素
---@return any @返回的元素
function lib.Choice(t, all, raw, pop)
    local iterator = ipairs
    if all then
        if raw then 
            iterator = lib.rawpairs
        else
            iterator = pairs
        end
    elseif raw then
        iterator = lib.rawipairs
    end
    local temp = {}
    for k, _ in iterator(t) do
        table.insert(temp, k)
    end
    local key = temp[ran:Int(1, #temp)]
    if pop then
        local value
        if raw then
            value = rawget(t, key)
            rawset(t, key, nil)
        else
            value = t[key]
            t[key] = nil
        end
        return value
    else
        if raw then
            return rawget(t, key)
        else
            return t[key]
        end
    end
end

---打乱表内元素排序
---为保留元表，返回的是传入的表而不是新表
---@param t table @要随机抽取的table
---@param raw boolean @是否不触发元方法
---@return table @返回的table
function lib.Randomize(t, raw)
    local temp = {}
    local len = #t
    for _ = 1, len do
        table.insert(temp, lib.Choice(t, false, raw, true))
    end
    for _, v in ipairs(temp) do
        table.insert(t, v)
    end
    return t
end

---清空表
---为保留元表，返回的是传入的表而不是新表
---@param t table @要清空的table
---@param all boolean @是否使用pairs而非ipairs
---@param raw boolean @是否不触发元方法
---@return table @返回的table
function lib.Clear(t, all, raw)
    local iterator = ipairs
    if all then
        if raw then 
            iterator = lib.rawpairs
        else
            iterator = pairs
        end
    elseif raw then
        iterator = lib.rawipairs
    end
    for k, _ in iterator(t) do
        if raw then
            rawset(t, k, nil)
        else
            t[k] = nil
        end
    end
    return t
end

---获取表的切片
---@param t table @要获取切片的table
---@param i number @始位标
---@param j number @末位标
---@param deep boolean @是否复制元表
---@return table @返回的切片
function lib.Slice(t, i, j, deep)
    i, j = getpos(i, j, #t)
    if not i then return end
    local ret = { unpack(t, i, j) }
    if deep then
        setmetatable(ret, getmetatable(t))
    end
    return ret
end

---返回一个装有`n`个`t`的拷贝的表，每个`t`之间以`sep`分隔
---@param t table
---@param n number
---@param sep any 
---@return table @返回的表
function lib.Repeat(t, n, sep)
    n = n or 0
    local ret = {}
    if n > 0 then
        for _ = 1, n do
            table.insert(ret, sp.copy(t, true))
            if sep ~= nil then
                table.insert(ret, sep)
            end
        end
    end
    return ret
end

---连接两个表，即将t2的元素接在t1后面
---@param t1 table @要连接的table1
---@param t2 table @要连接的table2
---@param raw boolean @是否不触发元方法
---@return table @连接后的t1
function lib.Connect(t1, t2, raw)
    local iterator, len = ipairs
    if raw then
        iterator = lib.rawipairs
        len = rawget(t1)
    else
        len = #t1
    end
    for _, v in iterator(t2) do
        len = len + 1
        if raw then
            --table.insert(t1, v)
            rawset(t1, len, v)
        else
            t1[len] = v
        end
    end
    return t1
end

---交换表的键与值
---@param t table @要交换的表
---@return table @交换后的表
function lib.Exchange(t, raw)
    local temp = {}
    local iterator = pairs
    if raw then
        iterator = lib.rawpairs
    end
    for k, v in iterator(t) do
        temp[v] = k
    end
    lib.Clear(t, true, raw)
    for k, v in pairs(temp) do
        if raw then
            rawset(t, k, v)
        else
            t[k] = v
        end
    end
    return t
end

---会触发元方法的insert函数(cooked?)
---@param t table @要插入的表
---@param k number @要插入的位置
---@param v any @要插入的值
---@overload fun(t:table, v:any)
function lib.Insert(t, k, v)
    if not v then
        t[#t + 1] = k
    else
        for key = #t, k, -1 do
            t[key + 1] = t[key]
        end
        t[k] = v
    end
end

---会触发元方法的remove函数(cooked?)
---@param t table @要进行移除的表
---@param k number @要移除的值的位置
---@return any @移除的值
function lib.Remove(t, k)
    k = k or #t
    local v, len = t[k], #t
    t[k] = nil
    for key = k + 1, len do
        t[key] = t[key - 1]
    end
    return v
end

---（在Lua5.1）会触发元方法的ipairs函数
---@param t table @要迭代的表
---@return fun():number, any @迭代器函数
function lib.ipairs(t)
    local n = #t
    local i = 0
    local ipairs_iterator = function()
        i = i + 1
        if i < n then
            return i, t[i]
        end
    end
    return ipairs_iterator
end

---（在Lua5.1）会触发元方法的pairs函数
---@param t table @要迭代的表
---@return fun():any, any @迭代器函数
function lib.pairs(t)
    local k, v
    local rawpairs_iterator = function()
        k, v = next(t, k)
        if v then
            return k, t[k]
        end
    end
    return rawpairs_iterator
end

---（在Lua5.2）不会触发元方法的ipairs函数
---@param t table @要迭代的表
---@return fun():number, any @迭代器函数
function lib.rawipairs(t)
    local n = rawlen(t)
    local i = 0
    local rawipairs_iterator = function()
        i = i + 1
        if i < n then
            return i, rawget(t, i)
        end
    end
    return rawipairs_iterator
end

---（在Lua5.2或5.3）不会触发元方法的pairs函数
---@param t table @要迭代的表
---@return fun():any, any @迭代器函数
function lib.rawpairs(t)
    local k, v
    local rawpairs_iterator = function()
        k, v = next(t, k)
        if v then
            return k, v
        end
    end
    return rawpairs_iterator
end

---解包出表的所有键
---@param t table @要解包的table
---@param all boolean @是否使用pairs而非ipairs
---@param deep boolean @深度解包
---@param raw boolean @是否不触发__metatable以外的元方法
---@return ...
function lib.UnpackKey(t, all, deep, raw)
    local iterator = ipairs
    if all then
        if raw then 
            iterator = lib.rawpairs
        else
            iterator = pairs
        end
    elseif raw then
        iterator = lib.rawipairs
    end
    local temp
    for k, _ in iterator(t) do
        table.insert(temp, k)
    end
    if deep and getmetatable(t) then
        for k, _ in iterator(getmetatable(t)) do
            table.insert(temp, k)
        end
    end
    return unpack(temp)
end

---解包出表的所有值
---@param t table @要解包的table
---@param all boolean @是否使用pairs而非ipairs
---@param deep boolean @深度解包
---@param raw boolean @是否不触发__metatable以外的元方法
---@return ...
function lib.Unpack(t, all, deep)
    local iterator = ipairs
    if all then
        if raw then 
            iterator = lib.rawpairs
        else
            --return sp.GetUnpack(t)
            iterator = pairs
        end
    elseif raw then
        iterator = lib.rawipairs
    end
    local temp
    for _, v in iterator(t) do
        table.insert(temp, v)
    end
    if deep and getmetatable(t) then
        for _, v in iterator(getmetatable(t)) do
            table.insert(temp, v)
        end
    end
    return unpack(temp)
end

---解包出表的元表的所有键
---@param t table @要解包的table
function lib.UnpackMetatableKey(t)
    if getmetatable(t) then
        return lib.UnpackKey(getmetatable(t), true)
    end
end

---解包出表的元表的所有值
---@param t table @要解包的table
function lib.UnpackMetatable(t)
    if getmetatable(t) then
        return lib.Unpack(getmetatable(t), true)
    end
end

---元表相关
---要注意所有除table和userdata以外的类型分别共用本类型的元表，
---因此一般情况下不应该修改它们的元表，即使修改也应该在操作完成后立刻还原

---访问表的元表的data域，摘自Lsetting
---要注意并非所有带元表的表都具有这个域
---@param t table @要访问的表
function lib.Visit(t)
    local ret = {}
    if getmetatable(t) and getmetatable(t).data then
        t = getmetatable(t).data
    end
    for k, v in pairs(t) do
        if type(v) == 'table' then
            ret[k] = visitTable(v)
        else
            ret[k] = v
        end
    end
    return ret
end

---移除一个值的元表
---@param value any @要移除的值
---@param force boolean @是否使用debug.setmetatable
---@return table|boolean @移除后的表|是否移除成功
function lib.RemoveMetatable(value, force)
    return lib.SetMetatable(value, nil, force)
end

---设置一个值的元表
---@param value any @要设置的值
---@param force boolean @是否使用debug.setmetatable
---@return table|userdata|boolean @设置后的表|是否设置成功
function lib.SetMetatable(value, table, force)
    if force then
        return debug.setmetatable(value, table)
    else
        return setmetatable(value, table)
    end
end

---获取一个值的元表
---@param value any @要获取的值
---@param force boolean @是否使用debug.getmetatable
---@return any @这个值的元表（或者它的__metatable的值）
function lib.GetMetatable(value, force)
    if force then
        return debug.getmetatable(value)
    else
        return getmetatable(value)
    end
end

---@class keytable : table @键表

--[=[
    关于键表：键表是本库新增的一种数据类型，它的元表中含有一个valuetable域，
    这个域是table，我们称之为值表。
    假设有一个键表kt，它对应的值表是vt，那么当以key为索引调用该键表中的值时，
    这个键表会以这个索引对应的值为索引去调用值表中的值。
    即语句kt[key]将会返回vt[kt[key]]（仅为示意，获取键表的值应参考下面的写法）。
    当尝试为键表赋值时也会进行相似的操作，
    即语句kt[key] = value等价于vt[kt[key]] = value（仅为示意，获取键表的值应参考下面的写法）。
    同样地,#kt等价于#vt。
    这类似于C/C++中指针的行为。
    你可以为一个键表设置键表，实现键表的嵌套。
    你也可以为一个值表设置多个键表。
    不能将一个键表的值表设置为它本身，否则会产生循环调用，导致栈溢出。
    键表的值表可以通过再次使用setvaluetable来更改，
    而键表本身的值存储在其元表的data域中，
    可以通过调用kt('get', key)或kt('set', key, value)来获取或修改。
    调用kt('getall')会返回整个data表，调用kt('setall', value)可以直接修改data表。
    调用kt('len')则会返回键表的长度。
    需要注意的是，由于键表的值表被视为对该表的引用，
    即使该表的其他外部引用结束，
    该表也会被键表保存而不会被垃圾收集器回收。
    这会导致外部引用结束时键表仍能读取到值表，
    请检查这是否是您想要的结果。
    要移除键表的值表（使其变回一个普通的表），请使用removemetatable。
    1.10b新增：可以将键表的值表设为一个字符串，若如此做，
    键表将在进行操作时将_G[valuetable]（即名称为该字符串的全局表）作为值表。
    请注意，操作前不会检查该全局表是否存在。
    不能以键表调用ipairs或pairs；这会导致报错。
--]=]

---键表索引元方法
---@param kt keytable @键表
---@param key any @索引
local function kt_index(kt, key)
    local vt = getmetatable(kt).valuetable
    assert((type(vt) == 'table' or type(vt) == 'string')
        and kt ~= vt, "invalid valuetable.")
    if type(vt) == 'string' then vt = _G[vt] end
    return vt[getmetatable(kt).data[key]]
end

---键表赋值元方法
---@param kt keytable @键表
---@param key any @索引
---@param value any @值
local function kt_newindex(kt, key, value)
    local vt = getmetatable(kt).valuetable
    assert((type(vt) == 'table' or type(vt) == 'string')
        and kt ~= vt, "invalid valuetable.")
    if type(vt) == 'string' then vt = _G[vt] end
    vt[getmetatable(kt).data[key]] = value
end

---键表调用元方法，用于对键表本身的值进行操作
---@generic K, V
---@param kt keytable @键表，自动传入
---@param func string | '"set"' | '"get"' | '"setall"' | '"getall"' | '"len"' | '"ipairs"' | '"pairs"' @调用的操作
---@param key any @索引
---@param value any @值
---@overload fun(kt:valuetable, func:'set', key:any, value:any)
---@overload fun(kt:valuetable, func:'get', key:any):any
---@overload fun(kt:valuetable, func:'setall', value:table)
---@overload fun(kt:valuetable, func:'getall'):table
---@overload fun(kt:valuetable, func:'len'):number
---@overload fun(kt:valuetable, func:'ipairs'):fun(tbl: table<number, V>):number, V
---@overload fun(kt:valuetable, func:'pairs'):fun(tbl: table<K, V>):K, V
local function kt_call(kt, func, key, value)
    if func == 'set' then
        getmetatable(kt).data[key] = value
    elseif func == 'get' then
        return getmetatable(kt).data[key]
    elseif func == 'setall' then
        getmetatable(kt).data = key
    elseif func == 'getall' then
        return getmetatable(kt).data
    elseif func == 'len' then
        return #getmetatable(kt).data
    elseif func == 'ipairs' then
        return ipairs(getmetatable(kt).data)
    elseif func == 'pairs' then
        return pairs(getmetatable(kt).data)
    end
end

local function kt_len(kt)
    local vt = getmetatable(kt).valuetable
    assert((type(vt) == 'table' or type(vt) == 'string')
        and kt ~= vt, "invalid valuetable.")
    if type(vt) == 'string' then vt = _G[vt] end
    if vt then return #vt end
end

local function kt_ipairs(kt)
    local n = kt("len")
    local i = 0
    local kt_ipairs_iterator = function()
        i = i + 1
        if i < n then
            return kt("get", i), kt[i]
        end
    end
    return kt_ipairs_iterator, nil, nil
end

local function kt_pairs(kt)
    local k, v
    local kt_pairs_iterator = function()
        k, v = next(kt("getall"), k)
        if v then
            return v, kt[v]
        end
    end
    return kt_pairs_iterator, nil, nil
end

---为一个表设置键表
---@param vt table @要设置的值表
---@param kt table @要设置的键表
---@return table @传入的值表
function lib.SetKeyTable(vt, kt)
    --检查参数是否合法
    assert(type(vt) == 'table' and type(kt) == 'table', ArgumentError)
    assert(kt ~= vt, "setting valuetable of a table as itself is forbidden.")
    --存储键表中所有初始值，之后将把所有初始值放入data
    local value = {}
    for k, v in pairs(kt) do
        value[k] = v
        kt[k] = nil
    end
    setmetatable(kt, {
        --键表中的值，放入单独的表以使元方法可以被调用
        data = value,
        --键表中对应的值表
        valuetable = vt,
        --索引元方法
        __index = kt_index,
        --赋值元方法
        __newindex = kt_newindex,
        --获取长度元方法
        __len = kt_len,
        --ipairs元方法
        __ipairs = kt_ipairs,
        --pairs元方法
        __pairs = kt_pairs,
        --调用元方法，用于对键表的值进行操作
        __call = kt_call
        
    })
    return vt
end

---为一个表设置值表，作用与`setkeytable`相同，只是参数顺序与返回值不同
---@param kt table @要设置的键表
---@param vt table @要设置的值表
---@return keytable @传入的键表
function lib.SetValueTable(kt, vt)
    --检查参数是否合法
    assert((type(vt) == 'table' or type(vt) == 'string')
        and type(kt) == 'table', ArguementError)
    assert(kt ~= vt, "setting valuetable of a table as itself is forbidden.")
    --存储键表中所有初始值，之后将把所有初始值放入data
    local value = {}
    for k, v in pairs(kt) do
        value[k] = v
        kt[k] = nil
    end
    return setmetatable(kt, {
        --键表中的值，放入单独的表以使元方法可以被调用
        data = value,
        --键表中对应的值表
        valuetable = vt,
        --索引元方法
        __index = kt_index,
        --赋值元方法
        __newindex = kt_newindex,
        --获取长度元方法
        __len = kt_len,
        --ipairs元方法
        __ipairs = kt_ipairs,
        --pairs元方法
        __pairs = kt_pairs,
        --调用元方法，用于对键表的值进行操作
        __call = kt_call
    })
end

---使用一个值表制作键表
---@param vt table @要制作键表的值表
---@return keytable @键表
function lib.MakeKeyTable(vt)
    local kt = {}
    for k, _ in pairs(vt) do
        table.insert(kt, k)
    end
    return setvaluetable(kt, vt)
end

---获取键表对应的值表
---@param kt keytable @要获取的键表
---@return table
function lib.GetValueTable(kt)
    local mt = getmetatable(kt)
    if mt then
        if type(mt.valuetable) == 'string' then
            return _G[mt.valuetable]
        else
            return mt.valuetable
        end
    end
end

---使用例
---@diagnostic disable-next-line: empty-block
if false then
    local kt, vt = { 'one', 'two' }, { one = 1, two = 2, three = 3 }
    setvaluetable(kt, vt)
    Print(kt[1], kt[2], kt[3]) --将会输出1, 2, nil
    kt('set', 3, true)
    vt[true] = 'True'
    Print(kt[3]) --将会输出True
    Print(kt('get', 1)) --将会输出one
    Print(#kt) --将会输出3
    Print(kt('len')) --将会输出2
end

