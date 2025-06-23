---=====================================
---THAIC Function v1.01a
---东方梦摇篮 function扩展库 v1.01a
---=====================================

---版本更新记录
---v1.00a
---初始版本
---v1.01a
---为将分句函数转化为普通函数的函数增加了sep参数，可以在连接函数时添加函数

---整个库里充斥着超级奇怪的语法，不用在意，能跑就行

---@class aic.table @东方梦摇篮function扩展库
aic.func = {}
local lib = aic.func

---继承函数
---@param old function @旧函数
---@param new function @新函数
---@param param string @需要的参数列
---@param pos string | '"before"' | '"after"' @插入位置
function lib.Super(old, new, param, pos)
    --没有传入参数列时手动获取（好谔谔的写法）
    param = param or (function()
        local params = {}
        for i = 1, debug.getinfo(old).nparams do
            local name = debug.getlocal(old, i)
            table.insert(params, name)
        end
        return table.concat(params, ', ')
    end)()
    local ret
    if pos == "before" then
        ret = "return function(" .. param .. ") new(" .. param .. ") old(" .. param .. ") " .. "end"
    else
        ret = "return function(" .. param .. ") old(" .. param .. ") new(" .. param .. ") " .. "end"
    end
    return load(ret)
end

---对表达式求值
---@param exp string @表达式
---@return any
function lib.eval(exp)
    return load('return ' .. exp)()
end

---执行代码
---@param code string @代码
---@return any
function lib.execute(code)
    return load(code)()
end

---@alias AdvancedRepeat.vartype VAR_INCREMENT | VAR_LINEAR | VAR_SINUSOIDAL_INTERPOLATION | VAR_SINUSOIDAL_MOVEMENT | VAR_CUSTOM | VAR_REBOUNDING | VAR_SINUSOIDAL_OSCILLATION

---@alias AdvancedRepeat.vardef { vartype:number, ...:any }

VAR_INCREMENT = 1
VAR_LINEAR = 2
VAR_SINUSOIDAL_INTERPOLATION = 3
VAR_SINUSOIDAL_MOVEMENT = 4
VAR_CUSTOM = 5
VAR_REBOUNDING = 6
VAR_SINUSOIDAL_OSCILLATION = 7
SINE_ACCEL = 1
SINE_DECEL = 2
SINE_ACC_DEC = 3

---仿Sharp高级循环
---
---定义参数时需要传入`{vartype, ...}`，其中vartype是`VAR_INCREMENT`，`VAR_LINEAR`，
---`VAR_SINUSOIDAL_INTERPOLATION`，`VAR_SINUSOIDAL_MOVEMENT`，
---`VAR_CUSTOM，VAR_REBOUNDING`，`VAR_SINUSOIDAL_OSCILLATION`中的一个，
---剩余参数按编辑器顺序传入
---
---函数将返回一个迭代器，按顺序返回定义的参数
---@param times number @循环次数
---@vararg AdvancedRepeat.vardef
function lib.AdvancedRepeat(times, ...)
    local arg = { ... }
    local variable = {}
    --_w_variable
    local _w_var = {}
    --variable init
    for _, v in ipairs(arg) do
        if v[1] == VAR_INCREMENT or v[1] == VAR_LINEAR or v[1] == VAR_SINUSOIDAL_INTERPOLATION or v[1] == VAR_CUSTOM or v[1] == VAR_REBOUNDING then
            table.insert(variable, v[2])
        elseif v[1] == VAR_CUSTOM then
            local _beg_var = v[2]
            local _end_var = v[3]
            local _func_var = v[5]
            table.insert(variable, (_end_var - _beg_var) * _func_var(0) + _beg_var)
        elseif v[1] == VAR_SINUSOIDAL_MOVEMENT or VAR_SINUSOIDAL_OSCILLATION then
            local _h_var = (v[4] - (v[3])) / 2
            local _t_var = (v[4] + (v[3])) / 2
            table.insert(variable, _h_var * sin(v[2]) + _t_var)
        else
            error('invalid vartype.')
        end
    end
    --repeat counter
    local i = 0
    local function AdvancedRepeat_iterator()
        
        for k, v in ipairs(arg) do

            local t = times
            --precisely
            if v[4] then t = t - 1 end

            if v[1] == VAR_INCREMENT then
                local _d_var = v[2]
                variable[k] = variable[k] + _d_var
            elseif v[1] == VAR_LINEAR then
                local _beg_var = v[2]
                local _end_var = v[3]
                local _d_var = (_end_var - _beg_var) / t
                local _d_w_var = 1 / t
                if v[5] == MOVE_NORMAL then
                    variable[k] = variable[k] + _d_var
                elseif v[5] == MOVE_ACCEL then
                    _w_var[k] = 0
                    _w_var[k] = _w_var[k] + _d_w_var
                    variable[k] = (_end_var - _beg_var) * _w_var[k] ^ 2 + _beg_var
                elseif v[5] == MOVE_DECEL then
                    _w_var[k] = _w_var[k] + _d_w_var
                    variable[k] = (_beg_var - _end_var) * (_w_var[k] - 1) ^ 2 + _end_var
                elseif v[5] == MOVE_ACC_DEC then
                    _w_var[k] = _w_var[k] + _d_w_var
                    if _w_var[k] < 0.5 then
                        variable[k] = 2 * (_end_var - _beg_var) * _w_var[k] ^ 2 + _beg_var
                    else
                        variable[k] = (_end_var - _beg_var) * (-2 * _w_var[k] ^ 2 + 4 * _w_var[k] - 1) + _beg_var 
                    end
                else
                    error('invalid move mode.')
                end
            elseif v[1] == VAR_SINUSOIDAL_INTERPOLATION then
                local _beg_var = v[2]
                local _end_var = v[3]
                local _d_w_var = 90 / t
                if v[5] == SINE_ACCEL then
                    _w_var[k] = _w_var[k] or -90
                    _w_var[k] = _w_var[k] + _d_w_var
                    variable[k] = (_end_var - _beg_var) * sin(_w_var[k]) + (_end_var)
                elseif v[5] == SINE_DECEL then
                    _w_var[k] = _w_var[k] or 0
                    _w_var[k] = _w_var[k] + _d_w_var
                    variable[k] = (_end_var - _beg_var) * sin(_w_var[k]) + (_beg_var)
                elseif v[5] == SINE_ACC_DEC then
                    _w_var[k] = _w_var[k] or -90
                    _d_w_var = 180 / t
                    _w_var[k] = _w_var[k] + _d_w_var
                    variable[k] = (_end_var - _beg_var) / 2 * sin(_w_var[k]) + ((_end_var + _beg_var) / 2)
                else
                    error('invalid sine mode.')
                end
            elseif v[1] == VAR_SINUSOIDAL_MOVEMENT then
                local _h_var = (v[4] - (v[3])) / 2
                local _t_var = (v[4] + (v[3])) / 2
                local _d_w_var = v[5] * 360 / t
                _w_var[k] = _w_var[k] or v[2]
                _w_var[k] = _w_var[k] + _d_w_var
                variable[k] = _h_var * sin(_w_var[k]) + _t_var
            elseif v[1] == VAR_CUSTOM then
                local _beg_var = v[2]
                local _end_var = v[3]
                local _func_var = v[5]
                local _d_w_var = 1 / t
                _w_var[k] = _w_var[k] or 0
                _w_var[k] = _w_var[k] + _d_w_var
                variable[k] = (_end_var - _beg_var) * _func_var(_w_var[k]) + _beg_var
            elseif v[1] == VAR_REBOUNDING then
                local _n_var = v[2] + v[3]
                variable[k] = -variable[k] + _n_var
            elseif v[1] == VAR_SINUSOIDAL_OSCILLATION then
                local _h_var = (v[4] - (v[3])) / 2
                local _t_var = (v[4] + (v[3])) / 2
                local _d_w_var = v[5]
                _w_var[k] = _w_var[k] or v[2]
                _w_var[k] = _w_var[k] + _d_w_var
                variable[k] = _h_var * sin(_w_var[k]) + _t_var
            else
                error('invalid vartype.')
            end
        end
        i = i + 1
        if i <= times then
            return unpack(variable)
        end
    end
    return AdvancedRepeat_iterator
end

---使用例
---@diagnostic disable-next-line: empty-block
if false then
    for var0, var1, var2 in lib.AdvancedRepeat(100,
        { VAR_LINEAR, 0, 360, false, MOVE_NORMAL },
        { VAR_CUSTOM, 0, 1, true, function(x) return x ^ 2 end },
        { VAR_REBOUNDING, 1, -1 }) do
        Print(var0, var1, var2)
    end
end

---@class function_ex : table @分句函数
lib.function_ex = {}
local fex = lib.function_ex

--这个东西主要是用来实现Dialog对象化，不过目前还没开始做
---定义一个分句函数对象
---@param code table|string @主体函数
---@return function_ex @分句函数对象
function lib.Define(code)
    local ret = {}
    local mt = {
        data = { code = {}, param = {}, default = {} },
        __index = fex,
        __newindex = function(f, k, v)
            local data = getmetatable(f).data
            if type(k) == 'number' then
                if type(v) == 'string' then
                    data.code[k] = load(v)
                else
                    data.code[k] = v
                end
                f:reload()
            end
        end,
        __concat = function(f1, f2)
            local data1 = getmetatable(f1).data
            local data2 = getmetatable(f2).data
            return lib.Define {
                param = data1.param,
                default = data1.default,
                func = aic.table.Connect(data1.code, data2.code)
            }
        end,
        __call = function(f, ...)
            return getmetatable(f).data.func(...)
        end
    }
    setmetatable(ret, mt)
    local data = mt.data
    if type(code) == 'string' then --处理只传入语句列，且语句列为字符串的情况
        return lib.Define { code }
    elseif type(code) == 'table' then
        --处理只传入语句列的情况
        if code[1] then
            data.code = code[1]
            data.param = {}
        end
        --处理参数列为字符串的情况
        if type(code.param) == "string" then
            --获取逗号数量
            --local _, n = string.gsub(code.param, ',', '')
            local n = aic.string.Count(data.code, ',')
            --生成模式字符串
            local pattern = "(.+)" .. string.rep(",%s?(.+)", n)
            --选出参数列，同时兼容a,b与a, b的写法
            data.param = { string.match(code.param, pattern) }
        end
        --处理语句列为字符串的情况
        if type(data.code) == "string" then
            --获取逗号数量
            --local _, n = string.gsub(data.code, ',', '')
            local n = aic.string.Count(data.code, ',')
            --生成模式字符串
            local pattern = "(.+)" .. string.rep(";%s?(.+)", n)
            --选出语句列，支持换行
            data.code = { string.match(data.code, pattern) }
        end
        --检查参数是否合法
        assert(type(data.param) == 'table' and type(data.code) == 'table', InvalidArgument)
        --执行重载，初始化整句函数
        ret:reload()
        return ret
    end
end

--这什么谔谔写法
---调用函数
---@param i number @始位标
---@param j number @末位标
---@vararg any @传入的参数
---@return any
function fex:call(i, j, ...)
    local data = getmetatable(self).data
    ---如果整句调用则使用提前存储的函数，提高效率
    if not i then return data.func(...) end
    local default = ""
    if data.default then
        for k, v in ipairs(data.default) do
            default = default .. data.param[k] .. "=" .. data.param[k] .. " or " .. v .. ";"
        end
    end
    local func = "return function(" .. table.concat(data.param, ',') .. ") "
        .. default .. table.concat(data.code, ";", i, j) .. " end"
    ---这玩意看起来可能是这样的：
    ---function(param1, param2) param1=param1 or default1;param2=param2 or default2;func1;func2 end
    ---很不好看，但是能跑
    --Print(func)
    --要理清load的逻辑可不是一件容易的事
    return load(func)()(...)
end

---重载整句函数
function fex:reload()
    local data = getmetatable(self).data
    local default = ""
    if data.default then
        for k, v in ipairs(data.default) do
            default = default .. data.param[k] .. "=" .. data.param[k] .. " or " .. v .. ";"
        end
    end
    local func = "return function(" .. table.concat(data.param, ',') .. ") "
        .. default .. table.concat(data.code, ";") .. " end"
    data.func = load(func)()
end

---移除函数中特定位置的语句并以函数形式返回
---@param pos number @语句位置
function fex:remove(pos)
    local data = getmetatable(self).data
    local ret = table.remove(data.code, pos)
    self:reload()
    return load(ret)
end

---向函数中特定位置插入语句
---@param func string @插入的函数
---@param pos number @语句位置
---@overload fun(func:function)
function fex:insert(func, pos)
    local data = getmetatable(self).data
    if pos then
        table.insert(data.code, pos, func)
    else
        table.insert(data.code, func)
    end
    self:reload()
end

---获取函数的切片（同样也是分句函数）
---@param i number @始位标
---@param j number @末位标
---@return function_ex @函数的切片
function fex:slice(i, j)
    local data = getmetatable(self).data
    i, j = getpos(i, j, #data.code)
    if not i then return end
    return lib.Define {
        param = data.param,
        default = data.default,
        func = aic.table.Slice(data.code, i, j)
    }
end

---将函数保存为可以使用`load`加载的代码块
---@param i number @始位标
---@param j number @末位标
---@param sep string @分隔函数
---@return string @string类型的函数
function fex:save(i, j, sep)
    local data = getmetatable(self).data
    i, j = getpos(i, j, #data.code)
    if not i then return end
    sep = sep or ";"
    return table.concat(data.code, sep, i, j)
end

---返回完整的函数（普通function）
---@param i number @始位标
---@param j number @末位标
---@param sep string @分隔函数
---@return function @function类型的函数
function fex:connect(i, j, sep)
    local data = getmetatable(self).data
    if not i then return data.func end
    return load(self:save(i, j, sep))
end

---以函数本身作为主体函数创建协程，对应`coroutine.create`
---@param i number @始位标
---@param j number @末位标
---@param sep string @分隔函数
---@return thread @协程
function fex:co(i, j, sep)
    return coroutine.create(self:connect(i, j, sep))
end

---以函数本身作为主体函数创建协程，对应`coroutine.wrap`
---@param i number @始位标
---@param j number @末位标
---@param sep string @分隔函数
---@return function @协程的恢复函数
function fex:wrap(i, j, sep)
    return coroutine.wrap(self:connect(i, j, sep))
end

---以函数本身作为主体函数创建task或tasker
---@param target lstg.GameObject @task目标
---@param i number @始位标
---@param j number @末位标
---@param sep string @分隔函数
---@return thread|lstg.GameObject @task|tasker
---@overload fun(i:number, j:number):thread
function fex:task(target, i, j, sep)
    if type(target) == 'number' then
        return New(tasker, self:connect(i, j, sep))
    else
        return task.New(target, self:connect(i, j, sep))
    end
end

---使用例
---@diagnostic disable-next-line: empty-block
if false then
    local func1 = aic.func.Define {
        param = "param1, param2, ...", --或{ "param1", "param2", "..." }
        default = { 1, 1 },
        func = {
            "local a = 1",
            "Print(param1, param2)"
        }
    }
    local func2 = aic.func.Define [[
        local a = 2;
        do
            Print("这是一个代码块")
            Print(a)
        end;
        Print("也可以将多个语句合为一句，只用一个分号")
        Print(a+1);
    ]]
    func1(0) --0, 1
    func2() --这是一个代码块,2,也可以将多个语句合为一句，只用一个分号,3
end
