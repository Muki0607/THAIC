---=====================================
---THAIC Debug v1.00a
---东方梦摇篮Debug v1.00a
---=====================================

---版本更新记录
---v1.00a
---初始版本

---@class aic.res @东方梦摇篮Debug
aic.debug = {}
local lib = aic.debug


--有一种暴力的美（
---解析环境或表或特定变量的所有信息
---@param env any @要解析的环境或表或特定变量
---@param unpack boolean @是否递归调用获取表中所有表的信息，默认为true
---@param maxlevel number @最大递归层数，也是最深能查找的表的层数，默认为10
---@param Cfilter boolean @是否过滤掉C函数，默认为true
---@param classfilter boolean @是否过滤掉class，默认为true
---@param string boolean @是否打印string类型的名称与值，默认为true
---@param number boolean @是否打印number类型的名称与值，默认为true
---@param boolean boolean @是否打印boolean类型的名称与值，默认为true
---@param other boolean @是否打印其他类型的名称与类型，默认为true
---@param tablename string @递归调用时传入，当前获取的表的名称
---@param level number @递归调用时传入，当前递归调用层级，用于确定缩进
---@return string @所有信息！
function lib.GetAllInfo(env, unpack, maxlevel, Cfilter, classfilter, string, number, boolean, other, tablename, level)
    --递归调用层级
    level = level or 0
    --Print(level)
    --最大递归层数（其实基本上递归到5层就是极限了）
    maxlevel = maxlevel or 10
    --防止栈溢出
    if level >= maxlevel then return '' end
    --改变默认值
    if unpack == nil then unpack = true end
    if Cfilter == nil then Cfilter = true end
    if classfilter == nil then classfilter = true end
    if string == nil then string = true end
    if number == nil then number = true end
    if boolean == nil then boolean = true end
    if other == nil then other = true end
    --要获取的表或环境
    env = env or getfenv()
    --解包环境时不能解包表
    if env == getfenv() or env == _G then unpack = false end
    --解析单个变量时将其临时包装为表
    if type(env) ~= 'table' then env = { env }
    end
    --存储函数信息的表
    local func = {}
    --函数信息类型
    local infoname = {
        ['定义起始行'] = 'linedefined',
        ['定义结束行'] = 'lastlinedefined',
        ['是否接受变长参数'] = 'isvararg',
        ['源代码路径'] = 'source',
        ['函数类型（C或Lua）'] = 'what',
        ['形参数量'] = 'nparams',
        ['上值数量'] = 'nups',
    }
    --函数信息类型的键表，用于保证函数信息按顺序输出
    --当然写个有序字典也可以解决这个问题
    local setvaluetable = setvaluetable or aic.table.SetValueTable
    local infoname_kt = setvaluetable({
        '定义起始行', '定义结束行', '是否接受变长参数', '源代码路径',
        '函数类型（C或Lua）', '形参数量', '上值数量' }, infoname)
    ---@type string
    ---因为string已经作为形参名，这里使用面向对象的方式调用string的函数
    local tab = '\t'
    local indent = tab:rep(level)
    --所有信息
    local allinfo = ''
    if not tablename then allinfo = '以下是给定变量的所有信息：\n' end
    for k, v in pairs(env) do
        if type(v) == 'string' then
            if string then
                allinfo = allinfo .. '\n' .. indent .. '字符串' .. k .. '的值是：' .. tostring(v) .. '\n'
            end
        elseif type(v) == 'number' then
            if number then
                allinfo = allinfo .. '\n' .. indent .. '数字' .. k .. '的值是：' .. tostring(v) .. '\n'
            end
        elseif type(v) == 'boolean' then
            if boolean then
                allinfo = allinfo .. '\n' .. indent .. '布尔值' .. k .. '的值是：' .. tostring(v) .. '\n'
            end
        elseif type(v) == 'table' and unpack and v ~= env and not (v.is_class and classfilter) then
            allinfo = allinfo .. '\n' .. indent .. '以下是表' .. k .. '的所有信息：\n\n'
                .. lib.GetAllInfo(v, unpack, maxlevel - 1, Cfilter, classfilter,
                    string, number, boolean, other, k, level + 1)
        elseif type(v) == 'function' and not (Cfilter and debug.getinfo(v).what == 'C') then
            func[k] = debug.getinfo(v)
            local info = func[k]
            info.params = {}
            for i = 1, info.nparams do
                local name = debug.getlocal(v, i)
                table.insert(info.params, name)
            end
            info.ups = {}
            for i = 1, info.nups do
                local name, value = debug.getupvalue(v, i)
                info.ups[name] = value
            end
        else
            if other then
                if type(v) == 'table' and v.is_class then
                    allinfo = allinfo .. indent .. k .. '的类型是：' .. 'class' .. '\n'
                elseif type(v) == 'function' then
                    allinfo = allinfo .. indent .. k .. '的类型是：' .. 'Cfunction' .. '\n'
                else
                    allinfo = allinfo .. indent .. k .. '的类型是：' .. type(v) .. '\n'
                    allinfo = allinfo .. indent .. k .. '的值是：' .. tostring(v) .. '\n'
                end
            end
        end
    end
    for k1, v1 in pairs(func) do
        local info = '\n' .. indent .. '以下是函数' .. k1 .. '的信息：' .. indent .. '\t'
        --[=[
        for i = 1, infoname_kt('len') do
            info = info .. '\n\t' .. indent .. infoname_kt('get', i) .. ':' .. tostring(v1[infoname_kt[i]])
        end
        --]=]
        for k, v in ipairs(infoname_kt) do
            info = info .. '\n\t' .. indent .. k .. ':' .. tostring(v1[v])
        end
        if v1.nparams > 0 then
            info = info .. '\n\t' .. indent .. '形参名称：' .. table.concat(v1.params, ', ')
        end
        if v1.nups > 0 then
            info = info .. '\n\t' .. indent .. '上值名称与值：'
            for k3, v3 in pairs(v1.ups) do
                info = info .. k3 .. ' = ' .. tostring(v3) .. ' '
            end
        end
        allinfo = allinfo .. info .. '\n'
    end
    if tablename then
        allinfo = allinfo .. '\n' .. tab:rep(level - 1) .. '表' .. tablename .. '的所有信息已经打印完毕。\n'
    else
        allinfo = allinfo .. '\n' .. '给定表' .. '的所有信息已经打印完毕。\n'
    end
    return allinfo
end

---尚未制作完成的命令行窗口
lib.Shell = Class(object)

function lib.Shell:init(x, y)
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + _infinite
    self.bound = false
    self.state = 'normal'
    self.hist1 = {}
    self.hist2 = {}
    self.input = {}
    self.cursor = 0
    self.x = x or screen.width / 8
    self.y = y or screen.height * 7 / 8
    self.a = 200
    self.b = 800
    self.wait = 30
    self.t = 8
    self.lastchar = ''
    self.indent = 0
    self.tmpinput = ''
end

function lib.Shell:frame()
    self.wait = max(self.wait - 1, -self.t)
    if self.wait < 1 then
        if self.state == 'normal' then
            player.lock = true
            if aic.input.KeyIsPressed(KEY.ENTER) then
                self.wait = self.t
                self.state = 'input'
            end
            if aic.input.KeyIsPressed(KEY.ALT) then
                self.wait = self.t
                self.state = 'hide'
            end
        elseif self.state == 'hide' then
            player.lock = false
            if aic.input.KeyIsPressed(KEY.ENTER) then
                self.wait = self.t
                self.state = 'normal'
            end
        elseif self.state == 'input' then
            player.lock = true
            if aic.input.KeyIsDown(KEY.ALT) then
                self.wait = self.t
                self.state = 'normal'
            end
            ---@type string
            local lastchar = aic.input.GetLastChar()
            if lastchar ~= '' and lastchar ~= self.lastchar then --防止重复输入
                self.wait = self.t / 2
                table.insert(self.input, lastchar)
                self.cursor = self.cursor + lastchar:len()
                self.lastchar = lastchar
            end
            if self.wait <= -self.t then
                self.lastchar = ''
            end
            if aic.input.KeyIsDown(KEY.BACKSPACE) then
                self.wait = self.t
                if self.cursor >= 1 then
                    table.remove(self.input, self.cursor)
                    self.cursor = self.cursor - 1
                end
            end
            if aic.input.KeyIsDown(KEY.DELETE) then
                self.wait = self.t
                if self.cursor < #self.input then
                    table.remove(self.input, self.cursor + 1)
                end
            end
            if aic.input.KeyIsDown(KEY.HOME) then
                self.wait = self.t
                self.cursor = 0
            end
            if aic.input.KeyIsDown(KEY.END) then
                self.wait = self.t
                self.cursor = #self.input
            end
            if aic.input.KeyIsDown(KEY.ENTER) then
                self.wait = self.t
                local indent = string.rep('    ', self.indent)
                local err
                local ret = {
                    TryExcept(function()
                            err = false
                            local input = table.concat(self.input)
                            if input ~= '' then
                                if string.find(input, 'end') then
                                    if self.indent > 0 then
                                        self.indent = self.indent - 1
                                        input = self.tmpinput .. 'end'
                                        if self.indent > 1 then
                                            self.tmpinput = self.tmpinput .. indent .. 'end'
                                        else
                                            self.tmpinput = ''
                                            return tostring(aic.func.execute(input))
                                        end
                                    else
                                        table.insert(self.hist2, "Unexpected end!")
                                    end
                                elseif string.find(input, 'if') or string.find(input, 'else') or string.find(input, 'do') or string.find(input, 'function') then --多行代码起始
                                    self.tmpinput = self.tmpinput .. indent .. input
                                    self.indent = self.indent + 1
                                elseif self.indent > 0 then
                                    self.tmpinput = self.tmpinput .. indent .. input
                                elseif string.find(input, '%b()') or string.find(input, 'local ') or (string.find(input, '=') and not string.find(input, '%p=')) then --通常的单行代码
                                    return tostring(aic.func.execute(input))
                                else --表达式求值
                                    return tostring(aic.func.eval(input))
                                end
                            else
                                return ''
                            end
                        end,
                        {[''] = function()
                            err = true
                            return "\n========== cmd traceback ==========\n" .. debug.traceback()
                        end})
                }
                if err then
                    --table.insert(self.hist2, "Exception occured!")
                else
                    if #ret == 1 then
                        table.insert(self.hist2, tostring(unpack(ret)))
                    elseif #ret > 1 then
                        table.insert(self.hist2, aic.table.ToString(ret))
                    end
                end
                local input = table.concat(self.input)
                if string.find(input, 'end') then
                    input = string.sub(indent, 5, -1) .. input
                else
                    input = indent .. input
                end
                table.insert(self.hist1, input)
                self.cursor = 0
                self.input = {}
            end
            if KeyIsDown('left') then
                self.wait = self.t
                self.cursor = max(self.cursor - 1, 0)
            elseif KeyIsDown('right') then
                self.wait = self.t
                self.cursor = min(self.cursor + 1, #self.input)
            end
        end
    end
end

function lib.Shell:render()
    SetViewMode('ui')
    local x, y = self.x + 2, self.y - 2
    if self.state ~= "hide" then
        SetImageState('white', '', color(COLOR_BLACK, 175))
        RenderRect('white', self.x, self.x + self.a * 2, self.y, self.y - self.b)
    end
    DrawText('consola', "AiC_Debug_Shell " .. "state:" .. self.state, x, y + 30, 0.8, nil, nil, 'left')
    DrawText('consola', "Input History", x, y + 15, 0.8, nil, nil, 'left')
    DrawText('consola', "Result History", x + self.a, y + 15, 0.8, nil, nil, 'left')
    if self.state ~= "hide" then
        --输入历史
        local cur = self.cursor
        local input = table.concat(self.input)
        local input_left, input_right = string.rep('    ', self.indent) .. string.sub(input, 1, cur), string.sub(input, cur + 1, -1)
        if self.indent == 0 then input_left = '>>> ' .. input_left end
        if string.find(input, 'end') then input_left = string.sub(input_left, 5, -1) end
        local cursor
        if self.timer % 60 < 30 then
            cursor = '|'
        else
            cursor = ' '
        end
        input = input_left .. cursor .. input_right
        DrawText('consola', table.concat(self.hist1)
            .. input, x, y, 0.5, nil, nil, 'left')
        --结果历史
        DrawText('consola', table.concat(self.hist2, '\n'), x + self.a, y, 0.5, nil, nil, 'left')
    end
    SetViewMode('world')
end
