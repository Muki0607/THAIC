---=================================================
---Chinese Pinyin Input Method v1.01a by Muki
---汉语拼音输入法 v1.01a by Muki
---=================================================

---版本更新记录
---v1.00a
---初始版本
---v1.01a
---移动至plugins文件夹，为公开发布做准备

--仿搜狗输入法制作的LuaSTG输入法，主题为Sharp编辑器
--由于是对外开放的库，所有使用到的梦摇篮函数都会放到私有部分而非直接引用
---@class aic.IME.private @私有部分
local private = {}
---@class IME @拼音输入支持库
local lib = {}
if aic then --梦摇篮库存在时加入梦摇篮全家桶
    aic.IME = lib
    aic.IME.private = private --此时私有部分可调用
else --否则导出至全局
    IME = lib
end
local DrawText = DrawText or private.DrawText --准备文字渲染函数（在梦摇篮中这个是全局函数）

-----------------------------
---资源
local dir = 'THlib/IME/'
local res = {
    IME_cursor_normal = "IME_cursor_normal.png",
    IME_cursor_input = "IME_cursor_input.png",
    IME_sharp_icon = "IME_sharp_icon.png",
    IME_sharp_chinese = "IME_sharp_chinese.png",
    IME_sharp_english = "IME_sharp_english.png",
    IME_sharp_upper = "IME_sharp_upper.png",
    IME_sharp_chinese_punction = "IME_sharp_chinese_punction.png",
    IME_sharp_english_punction = "IME_sharp_english_punction.png",
    IME_sharp_whole = "IME_sharp_whole.png",
    IME_sharp_half = "IME_sharp_half.png"
}

for k, v in pairs(res) do
    if lstg.FileManager.FileExist(dir .. v, true) then
        LoadImageFromFile(k, dir .. v)
    else
        error("输入法图片资源丢失。")
    end
end

if CheckRes('img', 'IME_cursor_normal') then
    SetImageCenter('IME_cursor_normal', 0, 0)
end
if CheckRes('img', 'IME_cursor_input') then
    SetImageCenter('IME_cursor_input', 0, 0)
end

Include(dir .. 'IME_pinyin_data.lua')

---拼音与字母对照表
---@type table<string, string>
lib.comp_pinyin = {
    ['ā'] = 'a', ['á'] = 'a', ['ǎ'] = 'a', ['à'] = 'a',
    ['ē'] = 'e', ['é'] = 'e', ['ě'] = 'e', ['è'] = 'e', ['ê'] = 'e', 
    ['ī'] = 'i', ['í'] = 'i', ['ǐ'] = 'i', ['ì'] = 'i',
    ['ō'] = 'o', ['ó'] = 'o', ['ǒ'] = 'o', ['ò'] = 'o',
    ['ū'] = 'u', ['ú'] = 'u', ['ǔ'] = 'u', ['ù'] = 'u',
    --为方便识别统一u和ü
    --['ǖ'] = 'v', ['ǘ'] = 'v', ['ǚ'] = 'v', ['ǜ'] = 'v', ['ü'] = 'v',
    ['ǖ'] = 'u', ['ǘ'] = 'u', ['ǚ'] = 'u', ['ǜ'] = 'u', ['ü'] = 'u',
    ['ń'] = 'n', ['ň'] = 'n', [''] = 'n', [''] = 'm',
}

---全角与半角对照表
---@type table<string, string>
lib.comp_whole = {
    [' '] = '　',

    ['~'] = '～', ['`'] = '｀', ['!'] = '！', ['@'] = '＠', ['#'] = '＃',
    ['$'] = '＄', ['%'] = '％', ['^'] = '＾', ['&'] = '＆', ['*'] = '＊',
    ['('] = '（', [')'] = '）', ['-'] = '－', ['_'] = '＿', ['+'] = '＋',
    ['='] = '＝', ['{'] = '｛', ['['] = '［', ['}'] = '｝', [']'] = '］',
    ['|'] = '｜', ['\\'] = '＼', [':'] = '：', [';'] = '；', ['\"'] = '＂',
    ['\''] = '＇', ['<'] = '＜', [','] = '，', ['>'] = '＞', ['.'] = '．',
    ['?'] = '？', ['/'] = '／',

    ['0'] = '０', ['1'] = '１', ['2'] = '２', ['3'] = '３', ['4'] = '４',
    ['5'] = '５', ['6'] = '６', ['7'] = '７', ['8'] = '８', ['9'] = '９',

    ['A'] = 'Ａ', ['B'] = 'Ｂ', ['C'] = 'Ｃ', ['D'] = 'Ｄ', ['E'] = 'Ｅ',
    ['F'] = 'Ｆ', ['G'] = 'Ｇ', ['H'] = 'Ｈ', ['I'] = 'Ｉ', ['J'] = 'Ｊ',
    ['K'] = 'Ｋ', ['L'] = 'Ｌ', ['M'] = 'Ｍ', ['N'] = 'Ｎ', ['O'] = 'Ｏ',
    ['P'] = 'Ｐ', ['Q'] = 'Ｑ', ['R'] = 'Ｒ', ['S'] = 'Ｓ', ['T'] = 'Ｔ',
    ['U'] = 'Ｕ', ['V'] = 'Ｖ', ['w'] = 'Ｗ', ['X'] = 'Ｘ', ['Y'] = 'Ｙ',
    ['Z'] = 'Ｚ',

    ['a'] = 'ａ', ['b'] = 'ｂ', ['c'] = 'ｃ', ['d'] = 'ｄ', ['e'] = 'ｅ',
    ['f'] = 'ｆ', ['g'] = 'ｇ', ['h'] = 'ｈ', ['i'] = 'ｉ', ['j'] = 'ｊ',
    ['k'] = 'ｋ', ['l'] = 'ｌ', ['m'] = 'ｍ', ['n'] = 'ｎ', ['o'] = 'ｏ',
    ['p'] = 'ｐ', ['q'] = 'ｑ', ['r'] = 'ｒ', ['s'] = 'ｓ', ['t'] = 'ｔ',
    ['u'] = 'ｕ', ['v'] = 'ｖ', ['w'] = 'ｗ', ['x'] = 'ｘ', ['y'] = 'ｙ',
    ['z'] = 'ｚ',  
}

---中文与英文符号对照表（不含右引号）
---@type table<string, string>
lib.comp_punction = {
    ['!'] = '！', ['$'] = '￥', ['^'] = '……', ['('] = '（', [')'] = ')', 
    ['_'] = '——', ['['] = '【', [']'] = '】', [':'] = '：', [';'] = '；', 
    ['\"'] = '“', ['\''] = '‘', ['<'] = '《', [','] = '，', ['>'] = '》',
    ['.'] = '。', ['?'] = '？', ['/'] = '、'
}

---声母表（不含zh、ch、sh）
---@type table<number, string>
lib.initials = { 'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'w', 'x', 'y', 'z' }

---韵母表
---@type table<number, string>
lib.finals = { 'a', 'e', 'i', 'o', 'u', --[['v',]] 'ai', 'ao', 'an', 'ei', 'en', 'er', 'ie', 'iu', 'in', 'ou', 'ue', 'ui', 'uo', 'un',
    'ang', 'eng', 'ing', 'iao', 'ian', 'ong', 'uan', 'iang', 'iong', }

---可以单独成字的韵母表
---@type table<number, string>
lib.indep_finals = { 'a', 'e', 'o', 'ai', 'ao', 'an', 'ei', 'en', 'er', 'ou', 'ang', 'eng' }

---初始化函数
function lib.Initialize()
    local default_pinyin = lib.pinyin_data
    assert(default_pinyin ~= nil, "输入法数据文件丢失。")
    --匹配模版，获取unicode、拼音和汉字
    local pattern = "U%+....: (.-)  # (.-)"
    local p, c
    for k, v in ipairs(default_pinyin) do
        p, c = string.match(v, pattern)
        --将拼音数据去音调化
        p = private.Detonalizate(p)
        --载入拼音-汉字对应关系
        for _, v in ipairs(p) do
            if private.Data[v] == nil then --如果没有该拼音则新建
                private.Data[v] = { c }
            else --如果已有该拼音则加入
                table.insert(private.Data[v], c)
            end
        end
        --使用载入汉字的顺序初始化优先级
        --乘以0.0001是为了让初始优先级足够小，可以被输入改变
        private.Priority[c] = k * 0.0001
    end
    --重写GetInput，确保获取键位的函数可用
    if not aic then
        local old = GetInput
        function GetInput()
            old()
            private.GetKeyboardInput()
        end
    end
end

---获取输出
---@param concat boolean @是否连接
---@return table|string @输出表
function lib.GetOutput(concat)
    if concat then return table.concat(private.Output) end
    return private.Output
end

---打开输入法
function lib.InputMethodOn()
    lib.InputMethod = New(private.InputMethod)
    lib.cursor = New(private.cursor, 'IME_cursor_normal')
end

---关闭输入法
function lib.InputMethodOff()
    for _, v in ipairs({ lib.InputMethod, lib.cursor }) do
        if IsValid(v) then
            Del(v)
        end
    end
end

---获取输入法状态
---@return string @输入法状态
function lib.InputMethodStatus()
    if IsValid(lib.InputMethod) then
        if IsValid(lib.InputFrame) then
            return 'inputing'
        else
            return 'normal'
        end
    else
        return 'dead'
    end
end

---新建一个输入框
function lib.NewInputFrame(x, y)
    local mx, my = private.GetMousePosition
    x, y = x or mx, y or my
    lib.InputFrame = lib.InputMethod:NewInputFrame(x, y)
end

-----------------------------
---私有部分

---额外按键状态
---@type table<number, boolean>
private.KeyState = {}
---@type table<number, boolean>
private.KeyStatePre = {}

---处理后的拼音数据表
---@type table<string, string>
private.Data = {}

---优先级表
---@type table<string, number>
private.Priority = {}

---词典
---@type table<string, string>
private.Dictionary = {
    shili = '示例',
    luastg = 'LuaSTG',
}

---拼音纠错表
---@type table<string, string>
private.Correct = {
    gn = 'ng',
    mg = 'ng',
    iou = 'iu',
    uei = 'ui',
    uen = 'un'
}

---输出表
---@type table<number, string>
private.Output = {}

---控制是否开启拼音纠错的标志
---@type boolean
private.CorrectSign = false

---单引号标志，用于判断中文模式下左右引号输入
---@type boolean
private.QuoteSign1 = false

---双引号标志，用于判断中文模式下左右引号输入
---@type boolean
private.QuoteSign2 = false

---输入框
private.InputFrame = Class(object)

function private.InputFrame:init(IME, x, y, l)
    self.x = x
    self.y = y
    self.layer = _infinite - 1
    self.bound = false
    self.real_pos1 = 1 --真实输入位置，等同于小写字母部分长度，只有这部分会被输入法识别
    self.pos1 = 1 --当前输入位置，即光标位置，如shuru|此时self.pos1 = 6
    self.pos2 = 1 --文字选择位置
    self.wait = 30 --当前操作冷却
    self.t = 8 --默认操作冷却
    self.l = min((l or 5), 9) --一页显示的选项数
    self.d = 20 --字间距
    self.h = 20 --UI高度的一半
    self.w = (self.d * self.l + 10) / 2 --UI宽度的一半
    self.IME = IME --所属输入法
    self.upper = false --是否开启大写锁定
    self.input = {} --已输入字符，将被用于输入法识别
    self.choice = {} --可供选择的字符，输入法识别的结果
    self.mx, self.my = private.GetMousePosition() --鼠标位置
    self.lastmx, self.lastmy = self.mx, self.my --上一帧鼠标位置
    
    ---检测鼠标是否位于文字上
    function self.CheckPos(pos)
        return private.IsInRect(self.mx, self.my, self.x + (2 * pos - 1) * self.d, self.x + (2 * pos + 1) * self.d, self.y - self.h, self.y)
    end

    ---获取鼠标本帧位移
    function self.GetDelta()
        return self.mx - self.lastmx, self.my - self.lastmy
    end

    ---选择文字
    function self.Select(pos)
        if pos then
            ---将识别部分替换为文字
            --将字符表连接成字符串
            local input = table.concat(self.input)
            --截取识别部分（没用上）
            --local l = string.sub(input, 1, self.real_pos1 - 1)
            --截取未识别部分
            --local r = string.match(input, l .. '(.+)') --这样写如果遇到输入百分号就惨了
            local r = string.sub(input, self.real_pos1)
            --连接文字与未识别部分
            self.input = private.HandleString(self.choice[pos] .. r)

            --记录新词汇
            if private.GetCharCount(self.choice[pos]) > 1 then
                if private.Dictionary[input] then
                    table.insert(private.Dictionary[input], self.choice[pos])
                else
                    private.Dictionary[input] = { self.choice[pos] }
                end
            end
        end

        --更新优先级
        for _, v in ipairs(self.input) do
            --只有优先级表里有的（就是汉字）才会记录优先级
            if private.priority[v] then
                private.priority[v] = min(5, private.priority[v] + 0.5)
            end
        end

        for _, v in ipairs(self.input) do
            table.insert(private.Output, v)
        end

        --清空输入与选择
        self.input = {}
        self.choice = {}
        --光标归位
        self.real_pos1 = 1
        self.pos1 = 1
        self.pos2 = 1
    end

    function self.Match(input)
        --将v换成u，方便识别
        input = string.gsub(input, 'v', 'u')
        --拼音纠错
        if private.CorrectSign then
            private.Change(input, private.Correct)
        end
        --向拼音中加入拼音分隔符号'
        input = private.SepPinyin(input)
        --以'为分隔符分割拼音
        local t = private.Seperate(input, '\'') or { input }
        --要返回的选择表
        local ret = {}
        for _, v in ipairs(t) do
            if private.Data[v] then --有匹配时返回匹配
                ret = private.Connect(ret, private.Data[v])
            else --无匹配时尝试补充
                local flag
                for _, i in ipairs(lib.initials) do
                    flag = string.find(v, i)
                    if flag then break end
                end
                if flag then
                    --缺少韵母，尝试补充韵母
                    for _, i in ipairs(lib.finals) do
                        if private.Data[v .. i] then
                            ret = private.Connect(ret, private.Data[v .. i])
                        end
                    end
                else
                    --缺少声母，尝试补充声母
                    for _, i in ipairs(lib.initials) do
                        if private.Data[i .. v] then
                            ret = private.Connect(ret, private.Data[i .. v])
                        end
                    end
                end
            end
        end
        --按优先级排序
        local function priority_comp(a, b)
            private.Priority[a] = private.Priority[a] or 0
            private.Priority[b] = private.Priority[b] or 0
            return private.Priority[a] > private.Priority[b]
        end
        table.sort(ret, priority_comp)
        --加入词典里匹配的词（目前词语只支持全拼匹配）
        if private.Dictionary[table.concat(t)] then
            private.Connect(private.Dictionary[table.concat(t)], ret)
        end
        return ret
    end
end

function private.InputFrame:frame()
    self.lastmx, self.lastmy = self.mx, self.my
    self.mx, self.my = private.GetMousePosition()
    self.upper = self.IME.upper
    self.wait = max(0, self.wait - 1)
    if self.wait <= 0 then
        --获取输入字符
        local input = private.GetLastChar()
        --获取输入按键
        local lastkey = GetLastKey()
        --键盘
        local K = lstg.Input.Keyboard
        if self.upper then --英文大写输入
            if input then
                self.wait = self.t
                --大写转换
                input = private.ReverseCap(input)
                --全角转换
                if not self.IME.half then
                    input = private.Change(input, lib.comp_whole)
                end
                table.insert(private.Output, input)
            end
        elseif self.IME.Chinese then --中文输入
            if input == '\n' then --按下Enter键时将所有已输入字符上屏
                self.wait = self.t
                self.Select()
            elseif input == ' ' then --数字键或空格键选择文字
                self.wait = self.t
                self.Select(self.pos2)
            elseif tonumber(input) ~= nil then
                self.wait = self.t
                self.Select(input)
            elseif input then --追加输入
                self.wait = self.t
                --转中文符号，处于汉字选择状态时对拼音分割符号'特殊处理
                if not (input == '\'' and next(self.choice)) then
                    input = private.Change(input, lib.comp_punction)
                    --对引号特殊处理
                    if input == '‘' then
                        if private.QuoteSign1 then
                            input = '’'
                        else
                            input = '‘'
                        end
                        private.QuoteSign1 = not private.QuoteSign1
                    end
                    if input == '“' then
                        if private.QuoteSign2 then
                            input = '”'
                        else
                            input = '“'
                        end
                        private.QuoteSign2 = not private.QuoteSign2
                    end
                end
                --全角转换
                if not self.IME.half then
                    input = private.Change(input, lib.comp_whole)
                end
                --不处于汉字选择状态时非拼音符号直接上屏
                if not (string.find(input, '%l') and next(self.choice)) then
                    table.insert(private.Output, input)
                    return
                end
                table.insert(self.input, input, self.pos1)
                self.choice[1] = self.choice[1] .. input
                self.pos1 = self.pos1 + 1
                --当且仅当输入小写字母且已有输入全为小写字母时才移动光标并更新匹配
                if string.find(input, '%l') and ({ string.gsub(self.input, '%l', '') })[2] == #self.input then
                    self.real_pos1 = self.real_pos1 + 1
                    self.choice = self.Match(self.input)
                end
            end
            if next(self.choice) then
                --方向键更改选择
                if lastkey == K.Left or lastkey == K.Up then
                    self.wait = self.t
                    if self.pos1 > 1 and self.real_pos1 == self.pos1 then
                        self.pos1 = self.pos1 - 1
                    elseif self.pos2 > self.l * (self.page - 1) + 1 then
                        self.pos2 = self.pos2 - 1
                    else
                        self.pos2 = self.pos2 - 1
                        self.page = self.page - 1
                    end
                elseif lastkey == K.Right or lastkey == K.Down then
                    self.wait = self.t
                    if self.pos1 < private.GetCharCount(self.input) then
                        self.pos1 = self.pos1 + 1
                    elseif self.pos2 < min(self.l * self.page, #self.choice) then
                        self.pos2 = self.pos2 + 1
                    else
                        self.pos2 = self.pos2 + 1
                        self.page = self.page + 1
                    end
                elseif lastkey == K.Minus or lastkey == K.Comma then ---+键或<>键翻页
                    local pos2 = self.pos2
                    self.pos2 = max(self.pos2 - self.l, 1)
                    if self.pos2 - pos2 <= -self.l then
                        self.page = self.page - 1
                    end
                elseif lastkey == K.Plus or lastkey == K.Period then
                    local pos2 = self.pos2
                    self.pos2 = min(self.pos2 + self.l, #self.choice)
                    if self.pos2 - pos2 >= self.l then
                        self.page = self.page + 1
                    end
                end
            end
        else --英文输入
            if input then
                self.wait = self.t
                --全角转换
                if not self.IME.half then
                    input = private.Change(input, lib.comp_whole)
                end
                table.insert(private.Output, input)
            end
        end
    end
end

function private.InputFrame:render()
    --不处于文字选择状态时不渲染UI
    if not next(self.choice) then return end
    SetViewMode('ui')
    --UI背景
    SetImageState('white', '', Color(255, 231, 231, 231))
    RenderRect('white', self.x, self.x + self.w * 2, self.y - self.h * 2, self.y)
    --分隔线
    SetImageState('white', '', Color(255, 64, 64, 64))
    RenderRect('white', self.x, self.x + self.w * 2, self.y - self.h, self.y - self.h - 2)
    --已输入字符
    local input_left, input_right = private.Slice(self.input, 1, self.pos1), private.Slice(self.input, self.pos1, -1)
    local input = table.concat(input_left) .. '|' .. table.concat(input_right)
    DrawText('sc_pr', input, self.x + 2, self.y - 2, 0.75)
    if next(self.choice) then
        local choice = ''
        for k, v in ipairs(private.Slice(self.choice, (self.page - 1) * self.l + 1, (self.page - 1) * self.l + 5)) do
            choice = choice .. k .. ' ' .. v .. '　'
        end
        DrawText('sc_pr', choice, self.x + 2, self.y - self.h - 2, 0.75)
    end
    SetViewMode('world')
end

---输入法
private.InputMethod = Class(object)

function private.InputMethod:init(x, y)
    self.x = x or 20
    self.y = y or 20
    self.layer = _infinite - 1
    self.bound = false
    self.d = 20
    self.r = 20
    self.wait = 30 --当前操作冷却
    self.t = 12 --默认操作冷却
    self.upper = false --是否开启大写锁定
    self.chinese = true --是否处于中文输入状态
    self.half = true --是否处于半角状态
    self.chinese_punction = true --是否处于中文标点状态
    self.mx, self.my = private.GetMousePosition() --鼠标位置
    self.lastmx, self.lastmy = self.mx, self.my --上一帧鼠标位置

    ---检测鼠标是否位于按键上
    function self.CheckPos(pos)
        local dx = self.d * 3 / 4
        return private.IsInRect(self.mx, self.my, self.x + dx + self.d * (pos - 1), self.x + dx + self.d * pos,
            self.y - self.d / 2, self.y + self.d / 2)
    end
    
    ---获取鼠标本帧位移
    function self.GetDelta()
        return self.mx - self.lastmx, self.my - self.lastmy
    end

    ---新建一个输入框
    function self:NewInputFrame(x, y, l)
        return New(private.InputFrame, self, x, y, l)
    end
end

function private.InputMethod:frame()
    self.lastmx, self.lastmy = self.mx, self.my
    self.mx, self.my = private.GetMousePosition()
    self.wait = max(0, self.wait - 1)
    if self.wait <= 0 then
        local K = lstg.Input.Keyboard
        --切换大写锁定开启/关闭
        if private.KeyIsPressed(K.CapsLock) then
            if self.upper then
                self.chinese_punction = self.chinese_punction_pre
            else
                self.chinese_punction_pre = self.chinese_punction
                self.chinese_punction = false
            end
            self.upper = not self.upper
        end
        --切换中英文输入
        if private.KeyIsReleased(K.LeftShift) or private.KeyIsReleased(K.RightShift) then
            self.chinese, self.chinese_punction = not self.chinese, not self.chinese
        end
        --切换中英文标点
        if (private.KeyIsDown(K.LeftShift) or private.KeyIsDown(K.RightShift)) and private.KeyIsDown(K.Period) then
            self.chinese_punction = not self.chinese_punction
        end
        --切换全角/半角
        if (private.KeyIsDown(K.LeftShift) or private.KeyIsDown(K.RightShift)) and private.KeyIsDown(K.Space) then
            self.half = not self.half
        end
        for k, v in ipairs({ 'chinese', 'half', 'chinese_punction' }) do
            if self.CheckPos(k) and private.GetLastClick() == 'left' then
                self.wait = self.t
                self[v] = not self[v]
            end
        end
    end
    if private.GetLastClick() == 'left' then
        if self.CheckPos(0) or self.moving then
            local dx, dy = self.GetDelta()
            self.x = self.x + dx
            self.y = self.y + dy
            self.moving = true
        end
    else
        self.moving = false
    end
end

function private.InputMethod:render()
    DrawText('main_font_en', 'upper:' .. tostring(self.upper) .. '\nchinese:' .. tostring(self.chinese)
        .. '\nhalf:' .. tostring(self.half) .. '\nchinese_punction:' .. tostring(self.chinese_punction), -100, 0)
    SetViewMode('ui')
    Render('IME_sharp_icon', self.x, self.y, 0, 0.5)
    local dx = self.d * 3 / 4
    if self.upper then
        RenderRect('IME_sharp_upper', self.x + dx, self.x + dx + self.d,
            self.y - self.d / 2, self.y + self.d / 2)
    else
        if self.chinese then
            RenderRect('IME_sharp_chinese', self.x + dx, self.x + dx + self.d,
                self.y - self.d / 2, self.y + self.d / 2)
        else
            RenderRect('IME_sharp_english', self.x + dx, self.x + dx + self.d,
                self.y - self.d / 2, self.y + self.d / 2)
        end
    end
    if self.half then
        RenderRect('IME_sharp_half', self.x + dx + self.d, self.x + dx + self.d * 2,
            self.y - self.d / 2, self.y + self.d / 2)
    else
        RenderRect('IME_sharp_whole', self.x + dx + self.d, self.x + dx + self.d * 2,
            self.y - self.d / 2, self.y + self.d / 2)
    end
    if self.chinese_punction then
        RenderRect('IME_sharp_chinese_punction', self.x + dx + self.d * 2, self.x + dx + self.d * 3,
            self.y - self.d / 2, self.y + self.d / 2)
    else
        RenderRect('IME_sharp_english_punction', self.x + dx + self.d * 2, self.x + dx + self.d * 3,
            self.y - self.d / 2, self.y + self.d / 2)
    end
    for i = 1, 3 do
        if self.CheckPos(i) then
            SetImageState('white', '', Color(100, 150, 150, 150))
            RenderRect('white', self.x + dx + self.d * (i - 1), self.x + dx + self.d * i,
                self.y - self.d / 2, self.y + self.d / 2)
        end
    end
    SetViewMode('world')
end

private.cursor = Class(object)

function private.cursor:init(img)
    self.img = img or 'img_void'
    self.bound = false
    self.layer = _infinite
    self.x, self.y = private.GetMousePosition()
end

function private.cursor:frame()
    self.x, self.y = private.GetMousePosition()
end

function private.cursor:render()
    SetViewMode('ui')
    Render(self.img, self.x, self.y, 0, 0.5)
    SetViewMode('world')
end

---去音调化与多读音分割
---@param pinyin string
---@return string[]
function private.Detonalizate(pinyin)
    local p = private.HandleString(pinyin)
    for k, v in ipairs(p) do
        p[k] = lib.comp_pinyin[v] or v
    end
    p = table.concat(p)
    if string.find(p, ',') then
        local pattern = '(.+)'
        local _, n = string.gsub(p, ',', '')
        for _ = 1, n do
            pattern = pattern .. ',(.+)'
        end
        return { string.match(p, pattern) }
    else
        return { p }
    end
end

---为拼音添加分隔符
---@param pinyin string @要处理的拼音
function private.SepPinyin(pinyin)
    --首先查找是否有声母
    local st, st2 = {}, {}
    for _, v in ipairs(lib.initials) do
        local s = string.find(pinyin, v)
        if s then
            table.insert(st, s)
        end
    end

    --如果不在第一位则在声母前面加分隔符
    for _, v in ipairs(st) do
        --对也可以作为韵母的n、g与r，以及可以组成声母的h特殊处理
        local flag
        local i = string.sub(pinyin, v, v)
        if i == 'n' then
            local j = string.sub(pinyin, v - 1, v - 1)
            if j == 'a' or j == 'e' or j == 'i' or j == 'o' or j == 'u' then
                flag = true
            end
        elseif i == 'g' then
            if string.sub(pinyin, v - 1, v - 1) == 'n' then
                flag = true
            end
        elseif i == 'r' then
            if string.sub(pinyin, v - 1, v - 1) == 'e' then
                flag = true
            end
        elseif i == 'h' then
            local j = string.sub(pinyin, v - 1, v - 1)
            if j == 'z' or j == 'c' or j == 's' then
                flag = true
            end
        end
        if v ~= 1 and not flag then
            pinyin = string.sub(pinyin, 1, v - 1) .. '\'' .. string.sub(pinyin, v)
        end
    end

    --再查找前面没有声母的韵母
    for _, v in ipairs(lib.finals) do
        local s = string.find(pinyin, v)
        if s then
            if not private.Search(st, s - 1) then
                table.insert(st2, s)
            end
        end
    end

    --如果前面没有声母则加分割符
    for _, v in ipairs(st2) do
        if v ~= 1 then
            pinyin = string.sub(pinyin, 1, v - 1) .. '\'' .. string.sub(pinyin, v)
        end
    end
end

---摘自sp.string
---将字符串处理成字符表
---@param str string
---@return table
function private.HandleString(str)
    local st = {}
    for utfChar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(st, utfChar)
    end
    return st
end

---摘自sp.string
---获取字符串的字符数
---@param str string
---@return number
function private.GetCharCount(str)
    return sp.string(str):GetCharCount()
end

---摘自东方梦摇篮string扩展库
---获取字符串中符合模式的匹配数量
---@param str string @要获取的字符串
---@param pattern string @匹配模式
---@return number @匹配数量
function private.Count(str, pattern)
    local _, ret = string.gsub(str, pattern, '')
    return ret
end

---摘自东方梦摇篮string扩展库
---与table.concat对应，使用指定分隔符将字符串分割并装入表中，分隔符将被删去
---如果没有匹配则返回**nil**
---@param str string 要分割的字符串
---@param sep string 分隔符，可以是模式串
---@return table @字符串表
function private.Seperate(str, sep)
    sep = sep or ' '
    local ret = {}
    for s, e in string.gmatch(str, '()' .. sep .. '()') do
        table.insert(ret, string.sub(str, s, e))
    end
    if next(ret) then return ret end
end

---摘自东方梦摇篮string扩展库
---置换字符串中的字符
---@param str string @要置换的字符串
---@param comp table<string, string> @字符对照表，原字符为键，新字符为值
---@param rev boolean @是否反转参数，原字符为值，新字符为键
function private.Change(str, comp, rev)
    local ret = private.HandleString(str)
    if rev then
        --相比交换键与值，Search也只需要一次遍历，但操作相对较少
        --comp = private.Exchange(comp) end
        for k, v in ipairs(ret) do
            ret[k] = private.Search(comp, v)
        end
    else
        --做完发现已经有函数可以做到了……
        return string.gsub(str, '[%z\1-\127\194-\244][\128-\191]*', comp)
    end
    return table.concat(ret)
end

---摘自东方梦摇篮杂项库
---返回`i`与`j`对应的索引（与`string.sub`的规则相同）
---@param i number @始位标
---@param j number @末位标
---@param len number @总长度
---@overload fun(i:number, len:number):number
function private.GetPos(i, j, len)
    i = i or 1
    if not len then
        if i < 0 then i = j + 1 + i end
        i = min(i, j)
        return i
    else
        j = j or len
        if i < 0 then i = len + 1 + i end
        if j < 0 then j = len + 1 + j end
        j = min(j, len)
        if j >= i then return i, j end
    end
end

---摘自东方梦摇篮table扩展库
---获取表的切片
---@param t table @要获取切片的table
---@param i number @始位标
---@param j number @末位标
---@param deep boolean @是否复制元表
---@return table @返回的切片
function private.Slice(t, i, j, deep)
    i, j = private.GetPos(i, j, #t)
    if not i then return end
    local ret = { unpack(t, i, j) }
    if deep then
        setmetatable(ret, getmetatable(t))
    end
    return ret
end

---摘自东方梦摇篮table扩展库
---连接两个表，即将t2的元素接在t1后面
---@param t1 table @要连接的table1
---@param t2 table @要连接的table2
---@return table @连接后的t1
function private.Connect(t1, t2)
    local len = #t1
    for _, v in ipairs(t2) do
        len = len + 1
        t1[len] = v
    end
    return t1
end

---摘自东方梦摇篮table扩展库
---寻找表中特定元素，返回对应的索引
---若有多个相同元素则可指定返回第几个，此时使用ipairs，只搜索数组部分元素
---若无指定元素则返回nil，因此也可用于判断表中是否有指定元素
---@param t table @要寻找的table
---@param value any @元素的值
---@param num number @将返回第num个value对应的索引
---@return any @返回的索引
function private.Search(t, value, num)
    local iterator
    if num then
        iterator = ipairs
    else
        iterator = pairs
    end
    num = num or 1
    local n = 0
    for k, v in iterator(t) do
        if v == value then
            n = n + 1
            if n == num then return k end
        end
    end
end

---摘自东方梦摇篮数学库
---检查坐标是否在矩形内
---@param x number @x坐标
---@param y number @y坐标
---@param l number @左边界
---@param r number @右边界
---@param b number @下边界
---@param t number @上边界
---@return boolean
---@overload fun(x:number, y:number, l:table):boolean
function private.IsInRect(x, y, l, r, b, t)
    if type(l) == "table" then
        return x > l.x and x < (l.x + l.width) and y > (l.y - (l.height or l.width)) and y < l.y
    else
        return x > l and x < r and y > b and y < t
    end
end

---摘自东方梦摇篮输入
---获取字符输入
---@return string @输入的字符
function private.GetLastChar()
    local K = lstg.Input.Keyboard
    local shift = GetKeyState(K.LeftShift) or GetKeyState(K.RightShift)
    if GetKeyState(K.Space) then
        return ' '
    end
    if GetKeyState(K.Tab) then
        return '\t'
    end
    if GetKeyState(K.Enter) then
        return '\n'
    end
    for i = K.NumPad0, K.NumPad9 do
        if GetKeyState(i) then
            return i - K.NumPad0
        end
    end
    for i = K.Multiply, K.Divide do
        if GetKeyState(i) then
            local k = i - K.Multiply + 1
            return ({ '*', '+', '\n', '-', '.', '/' })[k]
        end
    end
    if GetKeyState(K.NumPadEnter) then
        return '\n'
    end
    if shift then
        for i = K.D0, K.D9 do
            if GetKeyState(i) then
                local k = i - K.D0 + 1
                return ({ ')', '!', '@', '#', '$', '%', '^', '&', '*', '(' })[k]
            end
        end
        for i = K.A, K.Z do
            if GetKeyState(i) then
                return aic.table.Search(K, i)
            end
        end
        for i = K.Semicolon, K.Tilde do
            if GetKeyState(i) then
                local k = i - K.Semicolon + 1
                return ({ ':', '+', '<', '_', '?', '~' })[k]
            end
        end
        for i = K.OpenBrackets, K.Quotes do
            if GetKeyState(i) then
                local k = i - K.OpenBrackets + 1
                return ({ '{', '|', '}', '\"' })[k]
            end
        end
    else
        for i = K.D0, K.D9 do
            if GetKeyState(i) then
                return i - K.D0
            end
        end
        for i = K.A, K.Z do
            if GetKeyState(i) then
                return string.lower(aic.table.Search(i))
            end
        end
        for i = K.Semicolon, K.Tilde do
            if GetKeyState(i) then
                local k = i - K.Semicolon + 1
                return ({ ';', '=', ',', '-', '.', '/', '`' })[k]
            end
        end
        for i = K.OpenBrackets, K.Quotes do
            if GetKeyState(i) then
                local k = i - K.OpenBrackets + 1
                return ({ '[', '\\', ']', '\'' })[k]
            end
        end
    end
end

---@alias MouseState '"none"' | '"left"' | '"middle"' | '"right"' | '"X1"' | '"X2"'

---摘自东方梦摇篮输入
---获取鼠标输入
function private.GetMouseInput()
    for k, v in pairs({ left = 0, middle = 1, right = 2, X1 = 3, X2 = 4 }) do
        lib.MouseStatePre[k] = lib.MouseState[k]
        --lib.MousePosPre = lib.MousePos
        lib.MouseState[k] = GetMouseState(v)
        --lib.MousePos = { lib.GetMousePosition() }
    end
end

---摘自东方梦摇篮输入
---获取最后鼠标状态
---@return MouseState @鼠标按键
function private.GetLastClick()
    local state = { left = 0, middle = 1, right = 2, X1 = 3, X2 = 4 }
    for k, v in pairs(state) do
        if GetMouseState(v) then
            return k
        end
    end
    return "none"
end

---摘自东方梦摇篮输入
--改自getMousePositionToUI
---获取当前鼠标位置，可指定坐标系
---转world系时根据鼠标位置会存在一定误差，最大可能达到25单位距离左右
---@param viewmode viewmode @转换后坐标系
---@return number, number
function private.GetMousePosition(viewmode)
    viewmode = viewmode or 'ui'
    local x, y = GetMousePosition()
    -- 转换到 UI 视口
    x = x - screen.dx
    y = y - screen.dy
    --转换一次
    x = x / screen.scale
    y = y / screen.scale
    --不知道为什么到world要转二次……
    if viewmode == 'world' then
        x = x / screen.scale
        y = y / screen.scale
    end
    -- UI系转其他系
    return private.PosTrans(x, y, 'ui', viewmode)
end

---摘自东方梦摇篮输入
---反转字符串大小写
---@param str string 要反转的字符串
---@return string 反转后的字符串
function private.ReverseCap(str)
    local ret = sp.string(str):HandleString()
    for k, v in ipairs(ret) do
        if string.fing(v, '%l') then
            ret[k] = string.upper(v)
        else
            ret[k] = string.lower(v)
        end
    end
    return table.concat(ret)
end

---摘自东方梦摇篮输入
---获取额外键盘输入，是下面两个函数的基础
function private.GetKeyboardInput()
    for _, v in pairs(KEY) do
        private.KeyStatePre[v] = private.KeyState[v]
        private.KeyState[v] = GetKeyState(v)
    end
end

---摘自Linput.lua
---是否按下
function private.KeyIsDown(key)
    if aic then return aic.input.KeyState[key] end
    return private.KeyState[key]
end

---摘自Linput.lua
---是否在当前帧按下
function private.KeyIsPressed(key)
    if aic then return aic.input.KeyState[key] and (not aic.input.KeyStatePre[key]) end
    return private.KeyState[key] and (not private.KeyStatePre[key])
end

---摘自旧版Linput.lua
---
---判定某个键盘按键是否在当前帧被释放
---@param key number @keycode
---@return boolean @是否在当前帧被释放
function private.KeyIsReleased(key)
    if aic then return aic.input.KeyStatePre[key] and (not aic.input.KeyState[key]) end
    return private.KeyStatePre[key] and (not private.KeyState[key])
end

---摘自东方梦摇篮UI
---通用文字渲染，带描边
---
---'paragraph'等效于同时取'left'、'top'和'wordbreak'
---
---'centerpoint' 等效于同时取'center'、'vcenter'和'noclip'
---@param font string @字体
---@param text string @渲染文字
---@param x number @x坐标
---@param y number @y坐标
---@param s number @缩放比例
---@param co1 lstg.Color @文字颜色
---@param co2 lstg.Color @描边颜色
---@vararg align @对齐方式
function private.DrawText(font, text, x, y, s, co1, co2, ...)
    font = font or "main_font_zh2"
    s = s or 1
    co1 = co1 or Color(255, 255, 255, 255)
    local alpha = co1:ARGB()
    co2 = co2 or Color(alpha, 0, 0, 0)
    local _x, _y
    if CheckRes('fnt', font) then
        SetFontState(font, '', co2)
        for i = 0, 8 do
            _x = x + sqrt(2) * cos(i * 45)
            _y = y + sqrt(2) * sin(i * 45)
            RenderText(font, text, _x, _y, s, ...)
        end
        SetFontState(font, '', co1)
        RenderText(font, text, x, y, s, ...)
    else
        for i = 0, 8 do
            _x = x + sqrt(2) * cos(i * 45)
            _y = y + sqrt(2) * sin(i * 45)
            RenderTTF2(font, text, _x, _x, _y, _y, s, co2, ...)
        end
        RenderTTF2(font, text, x, x, y, y, s, co1, ...)
    end
end

---from RT基础教程，坐标系转换
---@param x number @原x坐标
---@param y number @原y坐标
---@param from viewmode @原坐标系
---@param to viewmode @转换后坐标系
---@return number, number @转换后x，y坐标
function private.PosTrans(x, y, from, to)
    ---检查输入合法性, 非必要
    if from ~= "world" and from ~= "ui" and from ~= "uv" then
        error 'Invalid viewmode.'
    end
    if to ~= "world" and to ~= "ui" and to ~= "uv" then
        error 'Invalid viewmode.'
    end
    ---无需转换
    if from == to then
        return x, y
    end
    ---转换至 ui 系
    if to == "ui" then
        if from == "world" then
            return WorldToUI(x, y)
        else -- from == "uv"
            return
                x / screen.hScale,
                screen.height - y / screen.vScale
        end
    end
    ---由 ui 系转换
    if from == "ui" then
        if to == "world" then
            local w = lstg.world
            return
                w.l + (w.r - w.l) * (x - w.scrl) / (w.r - w.scrl),
                w.b + (w.t - w.b) * (y - w.scrb) / (w.t - w.scrb)
        else -- to == "uv"
            return
                x * screen.hScale,
                (screen.height - y) * screen.vScale
        end
    end
    ---其他情况
    x, y = private.PosTrans(x, y, from, "ui")
    return private.PosTrans(x, y, "ui", to)
end

lib.Initialize()

return lib
