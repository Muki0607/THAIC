---=====================================
---THAIC String v1.00a
---东方梦摇篮 string扩展库 v1.00a
---=====================================

---版本更新记录
---v1.00a
---初始版本

---@class aic.string @东方梦摇篮string扩展库
aic.string = {}
local lib = aic.string

---置换字符串中的字符
---@param str string @要置换的字符串
---@param comp table<string, string> @字符对照表，原字符为键，新字符为值
function lib.Change(str, comp)
    local ret = private.HandleString(str)
    for k, v in ipairs(ret) do
        if comp[v] then
            ret[k] = comp[v]
        end
    end
    return table.concat(ret)
end

---摘自sp.string
---将字符串处理成字符表
---@param str string @要获取的字符串
---@return table @字符表
function lib.HandleString(str)
    local st = {}
    for utfChar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(st, utfChar)
    end
    return st
end

---摘自sp.string
---获取字符串的字符数
---@param str string @要获取的字符串
---@return number @字符数
function lib.GetCharCount(str)
    --return sp.string(str):GetCharCount()
    return #lib.HandleString(str)
end

---摘自sp.string
---获取占位长度
---@param str string @要获取的字符串
---@return number
function lib.GetLength(str)
    local sTable = lib.HandleString(str)
    local len = 0
    local charLen = 0
    for i = 1, #sTable do
        local utfCharLen = string.len(sTable[i])
        if utfCharLen > 1 then
            charLen = 2
        else
            charLen = 1
        end
        len = len + charLen
    end
    return len
end

---摘自sp.string
---按字符数截取字符串
---@param str string @要截取的字符串
---@param index number @始位标
---@param toindex number @末位标
---@return string @截取的字符串
function lib.Sub(str, index, toindex)
    index = index or 1
    if index < 0 then
        index = lib.GetLength(str) + index + 1
    end
    toindex = toindex or index
    if toindex < 0 then
        toindex = lib.GetLength(str) + toindex + 1
    end
    local length = (toindex - index) + 1
    local sTable = lib.HandleString(str)
    local s = {}
    for n = index, index + (length - 1) do
        if sTable[n] then
            table.insert(s, sTable[n])
        else
            table.insert(s, " ")
        end
    end
    return table.concat(s, "")
end

---获取按字符反转字符串
---@param str string @要反转的字符串
---@return string @反转后的字符串
function lib.GetReverse(str)
    local sTable = lib.HandleString(str)
    local s = {}
    for i = #sTable, 1, -1 do
        table.insert(s, sTable[i])
    end
    return table.concat(s, "")
end

---获取字符串中符合模式的匹配数量
---@param str string @要获取的字符串
---@param pattern string @匹配模式
---@return number @匹配数量
function lib.Count(str, pattern)
    local _, ret = string.gsub(str, pattern, '')
    return ret
end

---过滤掉字符串中符合模式的匹配
---@param str string @要过滤的字符串
---@param pattern string @匹配模式
---@return string @过滤后的字符串
function lib.Filter(str, pattern)
    local ret = string.gsub(str, pattern, '')
    return ret
end

---与table.concat对应，使用指定分隔符将字符串分割并装入表中，分隔符将被删去
---如果没有匹配则返回**nil**
---@param str string 要分割的字符串
---@param sep string 分隔符，可以是模式串
---@return table @字符串表
function lib.Seperate(str, sep)
    sep = sep or ' '
    local ret = {}
    for s, e in string.gmatch(str, '()' .. sep .. '()') do
        table.insert(ret, string.sub(str, s, e))
    end
    if next(ret) then return ret end
end
