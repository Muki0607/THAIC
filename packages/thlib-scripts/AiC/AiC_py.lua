---=====================================
---THAIC Python v1.03a
---东方梦摇篮 Python扩展库 v1.03a
---=====================================

---版本更新记录
---v1.00a
---初始版本
---v1.01a
---为lib.TryExcept增加了Finally参数
---v1.01b
---现在lib.TryExcept会视情况在调用Finally时传入参数
---v1.02a
---增加了lib.DefineException与lib.Raise，更好地支持异常处理
---v1.02b
---更改了lib.TryExcept的Else块的行为，现在它仅会在Try块正确执行时执行，符合它在Python中的行为
---原Else块行为（没有捕获任何错误时执行）被移至Except['']中
---v1.03a
---增加了lib.fstring

---@class aic.py @东方梦摇篮Python扩展库
---
---包含了一些从`Python`中复刻的函数和数据结构，并不是真的引用`Python`
aic.py = {}
local lib = aic.py

---一些常见异常，持续更新中
---有时间我要建一个真的异常类

lib.exception = {
    BadArgument = "bad argument", 
    InvalidArgument = "invalid argument",
    ArgumentError = ".+ argument",
    InvalidObj = "invalid.+object",
    CompileError = "falied to compile",
    StackOverflow = "stack overflow",
    NilValueError = "nil value",
    LoadFailed = "load .+ failed",
    PermissionDenied = "Permission denied",
    AnyException = ".*"
}

---@最后触发的异常的错误信息
---@type string
lib.last_exception = nil

---模拟`Python`中的`try..except..else..finally`块
---
---当`Try`正常运行时，返回`Try`的返回值；
---否则在错误信息中查找是否有`Except`中指定*异常*（模式字符串），若有则执行对应函数；
---若错误信息没有与任何*异常*匹配，执行`Except`中索引为''（空字符串）的函数；
---若`Except`中函数发生错误将重新抛出，否则以`Try`函数的返回值为参数执行`Else`函数，之后返回`Except`中函数的返回值。
---无论何种情况，`Finally`总会在最后执行，且一定会执行。请注意，`Finally`中的错误不会被捕获。
---当`Try`或`Except`正常运行时，以其返回值作为参数调用`Finally`；
---否则以错误信息为参数调用`Finally`。`Else`与`Finally`的返回值将被忽略。
---若在`Except`中以表作为索引，该表中的所有字符串将被视为模式字符串，任意一个模式字符串匹配成功即会执行对应函数；
---
---使用例：
---```
--->TryExcept(function()
--->    Del(object)
--->end, 
--->{
--->    [InvalidObj] = function()
--->        Print("invalid object.")
--->    end,
--->    [{ BadArgument, InvalidArgument }] = function()
--->        Print("wrong argument.")
--->    end,
--->    [''] = function()
--->        Print("unhandled error.")
--->},
--->function()
--->    Print("TryExcept successed.")
--->end,
--->function(ret)
--->    Print("TryExcept finished.")
--->end)
---```
---@param Try function @Try代码块
---@param Except table<string|table, function> @Except代码块
---@param Else function @Else代码块
---@param Finally function @Finally代码块
---@param plain boolean @是否使用简单查找（不使用正则表达式与转义字符）
---@return any
function lib.TryExcept(Try, Except, Else, Finally, plain)
    assert(Try ~= nil, InvalidArgument)
    local ret = {
        xpcall(Try, function(err)
            lib.last_exception = err
                .. "\n========== inner traceback ==========\n"
                .. debug.traceback()
                .. "\n=============================="
            return lib.last_exception
        end)
    }
    if ret[1] then
        if Finally then Finally(unpack(ret, 2)) end
        return unpack(ret, 2)
    else
        local eret, exception, func
        if Except then
            for e, f in pairs(Except) do
                if type(e) == 'table' then
                    for k, v in pairs(e) do
                        if k ~= "" and string.find(string.lower(ret[2]), string.lower(k), 1, plain) then
                            exception = k
                            func = v
                            local predefined_exception = aic.table.Search(lib.exception, exception)
                            if predefined_exception then
                                exception = predefined_exception
                            end
                            break
                        end
                    end
                end
                if e ~= "" and string.find(string.lower(ret[2]), string.lower(e), 1, plain) then
                    exception = e
                    func = f
                    local predefined_exception = aic.table.Search(lib.exception, exception)
                    if predefined_exception then
                        exception = predefined_exception
                    end
                    break
                end
            end
            if not func then
                exception = "OtherException"
                func = Except[""]
            end
        end
        if func then
            eret = {
                xpcall(func, function(err)
                    lib.last_exception = "\nerror in " .. exception .. " block:\n " .. err
                        .. "\n========== inner traceback ==========\n"
                        .. debug.traceback()
                        .. "\n=============================="
                    return lib.last_exception
                end, ret[2])
            }
            if eret[1] then
                if Else then
                    Else(unpack(eret, 2))
                end
                if Finally then
                    Finally(unpack(eret, 2))
                end
                return unpack(eret, 2)
            else
                lib.last_exception = eret[2]
                if Finally then
                    Finally(eret[2])
                end
                error(eret[2])
            end
        else
            lib.last_exception = ret[2]
            if Finally then Finally(ret[2]) end
            error("unhandled error: " .. ret[2])
        end
    end
end

---定义一个异常
function lib.DefineException(name, pattern)
    lib.exception[name] = pattern
end

---模拟`Python`中的`raise`语句，当不传入`exception`时将把最后捕获的异常抛出
---@param exception string @要抛出的异常
function lib.Raise(exception)
    if exception then
        error(exception)
    else
        error(lib.last_exception)
    end
end

---模拟`Python`中的`pass`语句，不做任何事
function lib.Pass()
end

---模拟`Python`中的`range`迭代器
---
---使用例：
---```
---for i in range(i, j, intv) do _body_ end
---```
---等同于
---```
---for i = i, j - intv, intv do _body_ end
---```
---@param i number @始位标
---@param j number @末位标
---@param intv number @自增值
---@return fun():number @迭代器函数
---@overload fun(i:number):fun():number
---@overload fun(i:number, j:number):fun():number
function lib.Range(i, j, intv)
    j = j or i
    intv = intv or 1
    if not i or intv == 0 then return end
    i = i - intv --使迭代器的行为与Python中相同
    --闭包函数
    local range_iter = function()
        i = i + intv
        if i < sign(intv) * j then
            return i
        end
    end
    return range_iter
end

---模拟`Python`中的`fstring`
---
---使用例：
---```
--- local t = {name="lua", version="5.3"}
--- x = fstring("{name}-{version}.tar.gz", t)
--- --> x = "lua-5.3.tar.gz"
---```
---@param str string @要处理的fstring
---@param env table @变量所在的环境
function lib.fstring(str, env)
    return string.gsub(str, "{(%w-)}", env or getfenv())
end

---为字符串增加元方法，支持python式操作
function lib.ExtendStringMethod()
    local mt = debug.getmetatable('')
    --字符串索引（注意索引从0开始，支持负数；索引仅支持个位数）
    mt.__index = function(t, k)
        if type(k) == 'number' then
            return string.sub(t, k + 1, k + 1)
        elseif string.find(k, ':') then
            local s, e = string.match(k, '(%d?):(%d?)')
            s, e = (tonumber(s) or 0) + 1, (tonumber(e) or #t - 1) + 1
            return string.sub(t, s, e)
        else
            return string[k]
        end
    end
    --字符串更新
    mt.__add = function(a, b)
        return a .. b
    end
    mt.__mul = function(a, b)
        return string.rep(a, b)
    end
end

---使用例
---@diagnostic disable-next-line
if false then
    lib.ExtendStringMethod()
    Print('a' + 'b') --ab
    Print('a' * 6) --aaaaaa
    Print(('abcdef')[1]) --b
    Print(('abcdef')['1:4']) --bcde
    Print(('abcdef')['1:']) --bcdef
    Print(('abcdef')[':'])--abcdef
end

