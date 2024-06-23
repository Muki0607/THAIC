---积累的一些奇怪但能跑的写法，以及一些冷知识
---@diagnostic disable-next-line: empty-block
if false then

    ---以面向对象方式调用string库函数
    do
        --通用语法：
        ---@type string
        local str = 'nothing...'
        str:func()
        --使用例：
        Print(str:len()) --10
        Print(str:sub(1, 3)) --not
    end

    ---一次性获取gmatch返回的捕获
    ---对其他迭代器不适用
    do
        --通用语法：
        local s1, s2, s3 = string.gmatch(s, pattern)()
        --使用例：
        local y, m, d = string.gmatch('2024/01/31', '(%d+)/(%d+)/(%d+)')()
        Print(y, m, d) --2024    01    31
    end

    ---一次性调用多个对象方法
    do
        --通用语法：
        local class = { init = function(self) return self end, f1 = function(self) return self end, f2 = function(self) return self end }
        class:init()
            :f1()
            :f2()
        --使用例：
        local obj = plus.Class()
        function obj:init(x, y)
            self.x = x
            self.y = y
            return self
        end
        function obj:setv(v, rot)
            self.vx = v * cos(rot)
            self.vy = v * sin(rot)
            return self
        end
        function obj:seta(a, rot)
            self.ax = a * cos(rot)
            self.ay = a * sin(rot)
            return self
        end
        local my_obj = obj(0, 0)
            :setv(0, 0)
            :seta(0, 0)
    end

    ---全局变量与环境中变量等价
    do
        global = 1
        --等价于：
        getfenv().global = 1
        --（不知道为什么EmmyLua把global标成紫色，这明明不是关键字）
        --（好吧好像是因为EmmyLua的全局变量标识是这个）
    end

    ---创造函数/表后立马调用
    do
        --通用语法：
        (function() --[[body]] end)()
        local value = ({ key = 'value' })['key']
        --示例：
        Print((function() return 'meanlingless' end)()) --meanlingless
        Print(({ nothingness = 'meanlingless' })['nothingness']) --meanlingless
    end

    ---在赋值和调用时使用and、or和not
    do
        --使用例：
        Print(true and 1) --1
        Print(false and 1) --false
        Print(true or 1) --true
        Print(false or 1) --1
        Print(not 1) --false
        Print(not not 1) --true
        (Print or print)(1) --1
        local life = (lstg.nextvar or lstg.var).lifeleft
        --注意，以下写法可能导致歧义：
        a = b + c
            (Print or print)(1)
        --它可以被理解为：
        a = b + c(Print or print)(1)
        --也可以被理解为：
        a = b + c; (Print or print)(1)
        --Lua默认采用第一种解释。要使用第二种解释，应该这样写：
        a = b + c
        ; (Print or print)(1)
    end

    ---中断代码块
    do
        --通用语法：
        do
            --code1
            do return end
            --code2
        end
        --或者：
        do
            --code1
            if conditon then return end
            --code2
        end
        --示例：
        local a = 1
        do
            Print(a)
            if a > 0 then return end
            Print(a + 1)
        end
        --只会打印1
    end

    --用双中括号表示字符串时，将会忽略紧接的换行符，且不处理转义字符
    do
        local s1, s2 = '', [[
]]
        Print(s1 == s2) --true
    end

    --for循环与while循环的等价形式
    do
        --以下代码
        for var1, var2, --[[...,]] varn in iterator() do
            do something() end
        end
        --等价于:
        do
            local f, s, var = iterator()
            while true do
                local var1, var2, --[[···,]] varn = f(s, var)
                if var1 == nil then break end
                var = var1
                do something() end
            end
        end        
    end

    --不会在require时执行的弹幕
    do
        if not ({ ... })[1] then
            Print('not required')
        end
    end

    --比较一系列数字类型的参数是否全部相等
    do
        function all_eq(...) return math.min(...) == math.max(...) end
    end

    --lua5.4的新功能：常量变量和待关闭变量
    --常量变量，初始化后不能赋值，可以提高运行效率
    local CONSTANT <const> = 'constant variable'
    --待关闭变量，当变量超出范围（生命周期结束）时调用其__close元方法；待关闭变量初始化后同样不能赋值
    local to_be_closed_var <close> = setmetatable({}, { __close = function(t, err) end })
end
