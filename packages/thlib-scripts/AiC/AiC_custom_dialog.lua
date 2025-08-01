---=====================================
---THAIC Custom Dialog v1.20aic by Muki
---东方梦摇篮 自定义对话库 v1.20aic by Muki
---=====================================

---魔改自boss系对话库与sp系对话库，是对原对话库的扩展
---使用本对话库时不一定要在dialog节点下使用，只需task环境即可
---大量使用EmmyLua的格式化，所以如果看到一些奇奇怪怪的换行请不要在意

---版本更新记录
---v1.00a
---初始版本
---v1.00b
---增加了函数：lib:multi_sentence()
---重写lib.dialog_displayer，增加了对对话框修改的支持
---v1.00c
---增加了lib.dialog_displayer的参数
---修正了lib:sentence_ex()的总显示时间，现在它将总是等于t
---v1.01a
---为lib.multi_sentence增加了在对话前后调用指定函数的功能
---v1.01b
---移除了lib.multi_sentence在对话前后调用指定函数的功能
---为lib.multi_sentence增加了指定对话起始位置与结束位置的功能，以方便实现在对话中插入函数
---v1.01c
---字符串截取改为使用spstring的Sub，不会再出现乱码
---v1.02a
---增加了文字效果系统，详见sentence_ex
---v1.02b
---增加了Col，img，sha，pef四个文字效果
---删除了来自spboss但未使用的函数
---扩充了lib.StrToNum的功能，现在其支持随机数生成，方便shader调用
---v1.02c
---增加了未制作完成的函数：lib.MultiGetTextEffect()
---v1.10a
---增加了对boss系dialog的支持，原sp系dialog函数统一改名
---增加了函数：lib.sp_multi_sentence_ex()，效果与lib.sp_multi_sentence()相同，但强制使用sentence_ex
---v1.10b
---增加了sp系对话的参数
---将sp系对话显示器的对话图像系统更换为boss系的character，支持图像编号
---现在sp系对话显示器的layer为LAYER_TOP+9，与boss系对话显示器同步
---v1.10c
---增加了备用spstring库，预防特殊情况
---调整了使用sca与upt文字效果时boss系对话气泡的大小，优化视觉效果
---增加了函数：lib.sp_SetDisplayer()与lib.boss_SetDisplayer()，用于创建对话显示器
---原Pef文字效果改为pef，传入参数列表改为由lib.SetPostEffectParam()提供参数
---增加了函数：lib.SetPostEffectParam()，用于设置pef文字效果的参数列表
---v1.11a
---增加了float系dialog，仍在完善中
---v1.11b
---将所有对话显示器的layer调至LAYER_TOP+10，修复了多角色对话时图层位置错误的问题
---修复了sp系对话显示器超过三行文字时行距错误的问题
---v1.12a
---原float系dialog改名为middle系dialog
---将sp系、boss系、middle系dialog分开至三个不同的库中
---预定添加float系dialog，设计目的为在屏幕任意地方显示无立绘的对话
---v1.20a
---重写GetMultiTextEffect()，实装了多文字效果
---文字效果语法大幅更改，具体见下
---新增自定义文字效果功能
---增加wait文字效果，允许更改文字显示间隔（仅限sentence_ex）
---实装float系dialog
---v1.20aic
---该版本为梦摇篮特供版，没有加载新气泡，因此middle系dialog不可用

---待完成事项：
---完成lib.MultiGetTextEffect()
---修复shader文字效果无法指定范围的问题
---修复middle系气泡两行文字显示位置错误的问题
---修复sha文字效果位置不准确的问题

---@class custom_dialog @自定义对话库
aic.custom_dialog = { list = {} }
local lib = aic.custom_dialog
lib.sp = {}
lib.boss = {}
lib.middle = {}
lib.float = {}

--[[
--加载middle系对话所需的新气泡
if lstg.FileManager.FileExist("dialog_balloon_new.png", true) then
    LoadTexture("dialog_balloon_new", "dialog_balloon_new.png")
    local _head = {
        { 224, 0,   32, 96 },
        { 224, 96,  32, 112 },
        { 224, 448, 32, 128 },
        { 224, 576, 32, 144 }
    }
    --1-2用于单行文字，3-4用于多行文字（2行）
    for i = 1, 4 do
        LoadImage("balloonMiddle" .. i, "dialog_balloon_new",
            _head[i][1], _head[i][2], _head[i][3], _head[i][4])
        SetImageCenter("balloonMiddle" .. i, 0, 0) --这是什么nt写法（恼）
    end
end
]]

sp = sp or {}
sp.string = sp.string or lib.spstring --在无法调用sp.string时启用备用spstring库

---

---执行AiC对话
---@param num number @对话编号
---@param start_pos number @对话开始位置
---@param end_pos number @对话结束位置
function lib:AiCDialog(num, start_pos, end_pos)
    local d = aic.l10n.dialog["dialog" .. num]
    start_pos = start_pos or 1
    end_pos = end_pos or #d.text
    d.name = lib.MakeParamList(d.name, end_pos - start_pos + 1, '')
    lib.sp.SetDisplayer(self, true, 'image:Muki_AiC_dialog_frame', 0.7, 0.25, 0, 20, '', nil, Color(150, 255, 255, 255), nil, Color(255, 85, 76, 74))
    local dialog_name = New(lib.dialog_name, d.name[start_pos])
    for i = start_pos, end_pos do
        dialog_name.name = d.name[i]
        lib.sp.multi_sentence_ex(self, d.img, d.pos, d.text, d.canskip, d.t, d.hscale, d.vscale, d.num, nil, nil, 1, d.snd, d.vol, nil, i, i)
    end
end

lib.dialog_name = Class(object)

function lib.dialog_name:init(name)
    self.x, self.y = -175, -50
    self.layer = LAYER_TOP + 10
    self.name = name
end

function lib.dialog_name:frame()
    if not player.dialog then
        _del(self, false)
    end    
end

function lib.dialog_name:render()
    RenderTTF('dialog', self.name, self.x, self.x, self.y, self.y, Color(255, 230, 227, 219), 'vcenter')
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
---本自定义库附加系统介绍：文字效果

---文字效果可以在本对话库的所有对话函数中使用，只需在传入文本中按以下语法输入即可
---灵感来自AiC的文字效果，语法相近，格式为<flag param>text</flag extend>，其中extend和</flag>都可以省略
---以下是详细语法规则：
---
---一、右边的</flag>可以省略不写，此时文字效果范围持续至本句结尾
---
---二、每句文字效果数量没有限制，将按左括号顺序执行
---多文字效果时右边的</flag>不能省略不写
---由于匹配问题，目前尚不支持文字效果重叠的写法，如<flag1 param1><flag2 param2>text</flag1></flag2>
---要达到这样的效果，可以使用extend，它会使本文字效果范围向右扩展：
---<flag1 param1></flag1 #text><flag2 param2>text</flag2>
---其中#text为text的长度，最大为99。
---
---三、若要在文字效果中使用变量，请使用连接符
---例：'<color ' .. self.co .. '>' .. text .. </color>
---
---四、若传入的参数中有字符串，请直接写出，不需要再加引号
---例：'<sound tan00>text</sound>'
---
---五、若传入的参数多于一个，请将文字效果大写，并将参数放在{}中
---由于内部通过英文逗号数量来判断参数数量，参数内不能含有英文逗号
---例：'<Color {255,255,255,255}>text</Color>'
---
---六、如需使用每帧自动变化的随机数，可以使用以下写法：
---ranF(s~e) 返回s至e范围内的浮点数，相当于ran:Float(s, e)
---ranI(s~e) 返回s至e范围内的整型数，相当于ran:Int(s, e)
---ranS() = 等可能地返回-1或1，相当于ran:Sign()
---请注意，以上写法仅在当前文字效果接受number时可用，否则直接显示原字符
---如果需要使用在传入时固定的随机数，请参见第三条传入
---
---七、因为lstg已经提供了键位相关变量，这里不提供用文字效果实现显示特定键位的功能
---
---八、显示文字时无论是否符合文字效果语法，<>中的字符都会被忽略
---因此请特别留意所有<>是否闭合
---
---九、以下为目前所有可用文字效果：
---
---<color color>text</color>
---将text的颜色设为Color(color)（传入十六进制数）
---
---<Color {alpha,red,green,blue}>text</Color>
---将text的颜色设为Color(alpha, red, green, blue)（传入argb分量）
---
---<font font>text</font>
---修改显示text的字体为fon（注：不会更改字号，请自行注意文字大小）
---
---<uppertext upt>text</uppertext>
---在text上方以小字显示upt，颜色与字体和text相同
---
---<Uppertext {upt,dx,dy}>text</Uppertext>
---在text上方离标准位置dx，dy处以小字显示upt，颜色与字体和text相同
---注意dx和dy不可省略
---
---<scale sca>text</scale>
---将text的缩放比设为sca，并自动设定其位置以居中显示
---
---<sound snd>text</sound>
---在sentence中：修改跳过对话的声音为snd
---在sentence_ex中：修改text显示时的语音为snd
---
---<volume vol>text</volume>
---在sentence中：修改跳过对话的声音的音量为vol
---在sentence_ex中:修改text显示时的语音的音量为vol
---
---<image img>text</image>
---修改text显示时的对话图像为img
---
---<shake sha>text</shake>
---使text显示时附带坐标最大偏移值为sha的颤抖效果（随机xy坐标变化）
---
---<Sinemove {x, y, omiga, theta}>text</Sinemove> --未实装
---使text显示期间对话图像进行正弦移动（也就是左右移动）
---
---<wait time>text</wait>
---在显示text的每个字符时等待time帧
---
---<shader shader_name>text</shader>
---在渲染text时调用指定shader
---使用前需要lib.SetPostEffectParam(paramlist,blend)来设定参数表与混合模式
---如果参数表每帧变化，则需每帧调用该函数
---使用时请注意引擎版本，若为ex+则应传入{paramname1 = param1,...}格式的参数表，若为aex+（sub）则应传入{{float1,float2,float3,float4},...}格式的参数表
---由于一些申必bug，目前shader仅支持全句应用，不可选择应用范围
---
---九、可以使用lib.AddTextEffect来自定义文字效果，具体用法见下。
---注意参数均以字符串形式传入，请自行转换类型。
---
lib.text_effect = {
    wait = { "on_sentence_ex", function(t) safeWait(lib.StrToNum(t)) end }
}

---@alias text_effect_pos '"on_sentence"' | '"on_sentence_ex"' | '"before_shader"' | '"before_render"' |'"after_render"' |'"after_shader"'
---| on_sentence:在sentence被调用时执行（注意sentence_ex和multi_sentence也会调用sentence），不执行结束函数
---| on_sentence_ex:在sentence_ex被调用时执行（注意multi_sentence和multi_sentence_ex也会调用sentence_ex），执行结束函数
---| before_shader:在shader开始前执行，不执行结束函数
---| before_render:在文字渲染前执行，执行结束函数
---| after_shader:在文字渲染后执行，执行结束函数
---| after_shader:在shader结束后执行，不执行结束函数

---增加自定义文字效果
---@param name string @文字效果名称，不能含有</>这三个符号
---@param pos text_effect_pos @文字效果生效位置
---@param start_func function @文字效果开始函数，在对话进行到文字效果开始位置时调用
---@param end_func function @文字效果结束函数，在对话进行到文字效果结束位置时调用
function lib.AddTextEffect(name, pos, start_func, end_func)
    local pos_list = { "on_sentence", "on_sentence_ex", "before_shader", "before_render", "after_render", "after_shader" }
    assert(string.find(name, '[</>]?[^%w%x%z%p%s%c]?') == nil, "invalid text effect name.")
    assert(aic.table.Search(pos_list, pos) ~= nil, "invalid text effect position.")
    lib.text_effect[name] = { pos, start_func, end_func }
end

---移除自定义文字效果
---@param name string @文字效果名称
function lib.RemoveTextEffect(name)
    lib.text_effect[name] = nil
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------
--sp系自定义对话
--sp custom dialog
--风地星风格对话（对话框在画面下方）
--自定义对话库的基础，自由度较高
----------------------------------------

---新建sp系对话显示器，可改变对话框和文字样式
---使用所有对话函数前需要先创建对话显示器，否则按默认配置创建
---可随时重新调用此函数来重设对话显示器
---@param self lstg.GameObject @对话所属的boss
---@param p_dialog boolean 是否将player.dialog设置为true
---@param dialogbox string @对话框图片
---@param dialogbox_hscale number @对话框横向缩放比
---@param dialogbox_vscale number @对话框纵向缩放比
---@param dialogbox_yu number @对话框y坐标偏移值
---@param text_yu number @对话y坐标偏移值
---@param dialogbox_blend string @对话框渲染模式
---@param dialogbox_co1 lstg.Color @对话框颜色1（左）
---@param dialogbox_co2 lstg.Color @对话框颜色2（右）
---@param text_co1 lstg.Color @对话字体颜色1（左）
---@param text_co2 lstg.Color @对话字体颜色2（右）
---@param dialogTTF string @对话字体（TTF）
function lib.sp.SetDisplayer(self, p_dialog, dialogbox, dialogbox_hscale, dialogbox_vscale, dialogbox_yu, text_yu,
                             dialogbox_blend, dialogbox_co1, dialogbox_co2, text_co1, text_co2, text_scale, dialogTTF)
    if IsValid(self.dialog_displayer) then Del(self.dialog_displayer) end
    dialogbox_blend = dialogbox_blend or ''
    dialogbox_co1 = dialogbox_co1
    dialogbox_co2 = dialogbox_co2 or dialogbox_co1
    text_co1 = text_co1 or Color(255, 255, 200, 200)
    text_co2 = text_co2 or Color(255, 200, 200, 255)
    dialogbox = dialogbox or 'dialog_box'
    dialogTTF = dialogTTF or 'dialog'
    dialogbox_hscale = dialogbox_hscale or 1
    dialogbox_vscale = dialogbox_hscale or dialogbox_vscale or 1
    dialogbox_yu = dialogbox_yu or 0
    text_yu = text_yu or 0
    text_scale = text_scale or 1
    p_dialog = p_dialog or true
    self.dialog_displayer = New(lib.sp.dialog_displayer, p_dialog, dialogbox, dialogbox_hscale, dialogbox_vscale,
        dialogbox_yu, text_yu, dialogbox_blend, dialogbox_co1, dialogbox_co2, text_co1, text_co2, text_scale, dialogTTF)
end

----------------------------------------
--sp dialog displayer

---sp对话显示器
lib.sp.dialog_displayer = Class(object)
---@param p_dialog boolean 是否将player.dialog设置为true
---@param dialogbox string @对话框图片
---@param dialogbox_hscale number @对话框横向缩放比
---@param dialogbox_vscale number @对话框纵向缩放比
---@param dialogbox_yu number @对话框y坐标偏移值
---@param text_yu number @对话y坐标偏移值
---@param dialogbox_blend string @对话框渲染模式
---@param dialogbox_co1 lstg.Color @对话框颜色1（左）
---@param dialogbox_co2 lstg.Color @对话框颜色2（右）
---@param text_co1 lstg.Color @对话字体颜色1（左）
---@param text_co2 lstg.Color @对话字体颜色2（右）
---@param dialogTTF string @对话字体（TTF）
function lib.sp.dialog_displayer:init(p_dialog, dialogbox, dialogbox_hscale, dialogbox_vscale, dialogbox_yu, text_yu,
                                      dialogbox_blend, dialogbox_co1, dialogbox_co2, text_co1, text_co2, text_scale,
                                      dialogTTF)
    self.type = 'sp'
    self.layer = LAYER_TOP + 10
    self.char = {}
    self.char[1] = {}
    self.char[-1] = {}
    self._hscale = {}
    self._vscale = {}
    self.t = 16
    self.death = 0
    self.co = 0
    self.blend = dialogbox_blend
    self.dialogbox_co1 = dialogbox_co1
    self.dialogbox_co2 = dialogbox_co2
    self.text_co1 = text_co1
    self.text_co2 = text_co2
    self.jump_dialog = 0
    self.dialogbox = dialogbox
    self.dialogTTF = dialogTTF
    self.dialogbox_hscale = dialogbox_hscale
    self.dialogbox_vscale = dialogbox_vscale
    self.dialogbox_yu = dialogbox_yu
    self.text_yu = text_yu
    self.text_scale = text_scale
    self.ttfdrawer = lib.TTFDrawer('', self)
    self.p_dialog = p_dialog
    if self.p_dialog then
        local players
        if Players then
            players = Players(self)
        else
            players = { player }
        end
        for _, p in pairs(players) do
            p.dialog = true
        end
    end
end

function lib.sp.dialog_displayer:frame()
    task.Do(self)
    if self.t > 0 then
        self.t = self.t - 1
    end
    if self.active and type(self.active) == 'number' then
        self.co = max(min(60, self.co + 1.5 * self.active), -60)
    end
    local players
    local dialog, shoot
    if Players then
        players = Players(self)
    else
        players = { player }
    end
    for _, p in pairs(players) do
        dialog = p.dialog or dialog
        if p.key then
            shoot = p.key["shoot"] or shoot
        else
            shoot = KeyIsDown "shoot" or shoot
        end
    end
    if dialog and self.active then
        if shoot then
            self.jump_dialog = self.jump_dialog + 1
        else
            self.jump_dialog = 0
        end
    end
    if self.text then self.ttfdrawer:set(self.text) end
end

function lib.sp.dialog_displayer:render()
    --[[if self.active and not self.img_upper then
        SetViewMode 'ui'
        if self.char[-self.active] then
            SetImageState(self.char[-self.active], '',
                Color(0xFF404040) + (self.t / 16) * Color(0xFFC0C0C0) - (self.death / 30) * Color(0xFF000000))
            local t = (1 - self.t / 16) ^ 3
            Render(self.char[-self.active], 224 + self.active * (-(1 - 2 * t) * 16 + 128) + self.death * self.active * 12,
                240 - 65 - t * 16 - 25, 0, self._hscale[-self.active], self._vscale[-self.active])
        end
        if self.char[self.active] then
            SetImageState(self.char[self.active], '',
                Color(0xFF404040) + (1 - self.t / 16) * Color(0xFFC0C0C0) - (self.death / 30) * Color(0xFF000000))
            local t = (self.t / 16) ^ 3
            Render(self.char[self.active], 224 + self.active * ((1 - 2 * t) * 16 - 128) - self.death * self.active * 12,
                240 - 65 - t * 16 - 25, 0, self._hscale[self.active], self._vscale[self.active])
        end
        SetViewMode 'world'
    end]]
    if self.text and self.active then
        local kx, ky1, ky2, dx, dx2, dy1, dy2
        kx = 168
        ky1 = -210
        ky2 = -90
        dx = 160
        dx2 = -165
        dy1 = -144 + self.text_yu -- + 4
        dy2 = -126 + self.text_yu -- + 4
        if self.active > 0 then
            if self.dialogbox_co1 then
                SetImageState(self.dialogbox, self.blend, self.dialogbox_co1)
            else
                SetImageState(self.dialogbox, self.blend, Color(225, 195 - self.co, 150, 195 + self.co))
            end
        else
            if self.dialogbox_co2 then
                SetImageState(self.dialogbox, self.blend, self.dialogbox_co2)
            else
                SetImageState(self.dialogbox, self.blend, Color(225, 195 - self.co, 150, 195 + self.co))
            end
        end
        Render(self.dialogbox, 0, -144 + self.dialogbox_yu - self.death * 8, 0, self.dialogbox_hscale,
            self.dialogbox_vscale)
        --搞不懂为什么这里还有一个RenderTTF……也不是描边啊
        --[[RenderTTF(self.dialogTTF, self.text, -dx, dx, dy1 - self.death * 8, dy2 - self.death * 8, Color(0xFF000000),
            'paragraph')]]
        --[[self.ttfdrawer:render(self.dialogTTF,
            -dx + dx2, dx + dx2, dy1 - self.death * 8, dy2 - self.death * 8, 16, 32, 0, 0,
            self.text_scale, Color(0xFF000000), 4)]]
        if self.active > 0 then
            --[[RenderTTF(self.dialogTTF, self.text, -dx, dx, dy1 - self.death * 8, dy2 - self.death * 8, self.text_co1,
                'paragraph')]]
            self.ttfdrawer:render(self.dialogTTF,
                -dx + dx2, dx + dx2, dy1 - self.death * 8, dy2 - self.death * 8, 16, 32, 0, 0,
                self.text_scale, self.text_co1, 4)
        else
            --[[RenderTTF(self.dialogTTF, self.text, -dx, dx, dy1 - self.death * 8, dy2 - self.death * 8, self.text_co2,
                'paragraph')]]
            self.ttfdrawer:render(self.dialogTTF,
                -dx + dx2, dx + dx2, dy1 - self.death * 8, dy2 - self.death * 8, 16, 32, 0, 0,
                self.text_scale, self.text_co2, 4)
        end
        --[[if self.img_upper then
            SetViewMode 'ui'
            if self.char[-self.active] then
                SetImageState(self.char[-self.active], '',
                    Color(0xFF404040) + (self.t / 16) * Color(0xFFC0C0C0) - (self.death / 30) * Color(0xFF000000))
                local t = (1 - self.t / 16) ^ 3
                Render(self.char[-self.active],
                    224 + self.active * (-(1 - 2 * t) * 16 + 128) + self.death * self.active * 12,
                    240 - 65 - t * 16 - 25, 0, self._hscale[-self.active], self._vscale[-self.active])
            end
            if self.char[self.active] then
                SetImageState(self.char[self.active], '',
                    Color(0xFF404040) + (1 - self.t / 16) * Color(0xFFC0C0C0) - (self.death / 30) * Color(0xFF000000))
                local t = (self.t / 16) ^ 3
                Render(self.char[self.active],
                    224 + self.active * ((1 - 2 * t) * 16 - 128) - self.death * self.active * 12,
                    240 - 65 - t * 16 - 25, 0, self._hscale[self.active], self._vscale[self.active])
            end
            SetViewMode 'world'
        end]]
    end
end

function lib.sp.dialog_displayer:del()
    local unit_list = { self.char[-1], self.char[1] }
    for _, list in ipairs(unit_list) do
        for _, unit in pairs(list) do
            if IsValid(unit) then
                Del(unit)
            end
        end
    end
    PreserveObject(self)
    task.New(self, function()
        for i = 1, 30 do
            self.death = i
            task.Wait()
        end
        local players
        if Players then
            players = Players(self)
        else
            players = { player }
        end
        for _, p in pairs(players) do
            p.dialog = false
        end
        RawDel(self)
    end)
end

----------------------------------------
--sp dialog sentence

--最基本的单句对话
---sp对话语句
---@param self lstg.GameObject @对话所属的boss
---@param img string @对话图像
---@param pos string @对话方位
---@param text string|number @对话内容
---@param canskip boolean @是否可跳过
---@param t number @对话时长
---@param hscale number @图像横向缩放比
---@param vscale number @图像纵向缩放比
---@param num string|number @对话图像编号
---@param px number @对话图像x坐标
---@param py number @对话图像y坐标
---@param snd string @对话跳过声音
---@param vol number @对话跳过声音音量
---@param img_upper boolean @对话图像图层是否高于对话框
---@param rawtext string @未处理文字效果的text（由sentence_ex使用）
---@param fulltext string @已处理文字效果但未截取的text（由sentence_ex使用）
function lib.sp.sentence(self, img, pos, text, canskip, t, hscale, vscale, num, px, py, snd, vol, img_upper, rawtext,
                         fulltext)
    if self.dialog_displayer.type ~= 'sp' then
        lib.sp.SetDisplayer(self)
    end
    local master = self.dialog_displayer
    img = img or 'img_void'
    pos = pos or 'right'
    if pos == 'left' or pos == 1 then
        pos = 1
    else
        pos = -1
    end
    text = text or ''
    canskip = canskip or false
    hscale = hscale or 1
    vscale = vscale or hscale or 1
    num = num or 1
    px = px or (230 - pos * 150)
    py = py or 128
    snd = snd or 'plst00'
    vol = vol or 0.35
    img_upper = img_upper or false
    local newtext, flag, param = lib.MultiGetTextEffect(text)
    if not rawtext and flag then
        for k, v in ipairs(flag) do
            if v == 'sound' then snd = param[k] end
            if v == 'volume' then vol = lib.StrToNum(param[k]) end
            if v == 'image' then img = param[k] end
            if v == 'shader' and not lstg.tmpvar.TextEffect_RT_Created then
                CreateRenderTarget('TextEffect_RenderTarget')
                lstg.tmpvar.TextEffect_RT_Created = true
            end
            if lib.text_effect[v] and lib.text_effect[v][1] == 'on_sentence' and lib.text_effect[v][2] then
                lib.text_effect[v][2](param[k])
            end
        end
    end
    master.text = newtext
    master.rawtext = rawtext or text
    master.fulltext = fulltext or newtext
    if master.active ~= pos then
        master.active = pos
        master.t = 16
    end
    --if master.char then master.char[pos] = img end
    if not IsValid(master.char[pos][num]) then
        if img_upper then
            master.char[pos][num] = New(lib.character, img, pos, px, py, vscale, hscale, num)
        else
            master.char[pos][num] = New(lib.character, img, pos, px, py, vscale, hscale, num, LAYER_TOP + 8)
        end
    else
        master.char[pos][num].act = true
        master.char[pos][num].img = img
        master.char[pos][num].x = px
        master.char[pos][num].y = py
        master.char[pos][num].vscale = vscale
        master.char[pos][num].hscale = hscale
        if not img_upper then
            master.char[pos][num].layer = LAYER_TOP + 8
        end
    end
    master._hscale[pos] = hscale or pos
    master._vscale[pos] = vscale or 1
    task.Wait()
    t = t or (60 + #text * 5)
    for _ = 1, t do
        if (KeyIsPressed 'shoot' or master.jump_dialog > 60) and canskip then
            PlaySound(snd, vol, 0, true)
            if master.jump_dialog > 60 then
                master.jump_dialog = 56
            end
            break
        end
        task.Wait()
    end
    task.Wait(2)
    master.char[pos][num].act = false --没有再写stay的必要了，基本用不上
end

----------------------------------------
--sp dialog sentence_ex

--使用字符串截取来逐字显示的对话，支持对话语音（参考UT）
---sp对话语句ex
---@param self lstg.GameObject @对话所属的boss
---@param img string @对话图像
---@param pos string @对话方位
---@param text string|number @对话内容
---@param canskip boolean @是否可跳过
---@param t number @对话时长
---@param hscale number @图像横向缩放比
---@param vscale number @图像纵向缩放比
---@param num string|number @对话图像编号
---@param px number @对话图像x坐标
---@param py number @对话图像y坐标
---@param intv number @每帧显示字符数
---@param snd string @对话语音
---@param vol number @对话语音音量
---@param img_upper boolean @对话图像图层是否高于对话框
function lib.sp.sentence_ex(self, img, pos, text, canskip, t, hscale, vscale, num, px, py, intv, snd, vol, img_upper)
    intv = intv or 1
    hscale = hscale or 1
    vscale = vscale or hscale or 1
    num = num or 1
    px = px or (230 - pos * 150)
    py = py or 128
    snd = snd or 'plst00'
    vol = vol or 0.35
    img_upper = img_upper or false
    local default_img = img
    local default_snd = snd
    local default_vol = vol
    local newtext, flag, param, s, e = lib.MultiGetTextEffect(text)
    --由于spstring把text整理成了table，这玩意和#text还有点区别
    local l = sp.string(newtext):GetCharCount()
    if flag then
        for _, v in ipairs(flag) do
            if v == 'shader' and not lstg.tmpvar.TextEffect_RT_Created then
                CreateRenderTarget('TextEffect_RenderTarget')
                lstg.tmpvar.TextEffect_RT_Created = true
            end
        end
    end
    t = t or (60 + l * 5)
    local dt = 0
    for i = 1, l, intv do
        if (KeyIsPressed 'shoot' or self.dialog_displayer.jump_dialog > 60) and canskip then
            PlaySound(snd, vol, 0, true)
            if self.dialog_displayer.jump_dialog > 60 then
                self.dialog_displayer.jump_dialog = 56
            end
            break
        end
        dt = dt + 1
        if flag then
            for k, v in ipairs(flag) do
                if i > s[k] - intv and i <= e[k] - intv then
                    if v == 'sound' then snd = param[k] end
                    if v == 'volume' then vol = lib.StrToNum(param[k]) end
                    if v == 'image' then img = param[k] end
                    if v == 'Sinemove' then
                        px = px + lib.StrToNum(param[k][1]) * sin(lib.StrToNum(param[k][3] or 5) * self.timer + lib.StrToNum(param[k][4] or 0) - self.timer % 180)
                        py = py + lib.StrToNum(param[k][2] or 0) * sin(lib.StrToNum(param[k][3] or 5) * self.timer + lib.StrToNum(param[k][4] or 0) - self.timer % 180)
                    end
                    if lib.text_effect[v] and lib.text_effect[v][1] == 'on_sentence_ex' and lib.text_effect[v][2] then
                        lib.text_effect[v][2](param[k])
                    end
                elseif i > e[k] - intv then
                    if e[k] < l then img = default_img end
                    snd = default_snd
                    vol = default_vol
                    if lib.text_effect[v] and lib.text_effect[v][1] == 'on_sentence_ex' and lib.text_effect[v][3] then
                        lib.text_effect[v][3](param[k])
                    end
                end
            end
        end
        local text_slice = sp.string(newtext):Sub(1, i)
        lib.sp.sentence(self, img, pos, text_slice, canskip, 1, hscale, vscale, num, px, py, snd, vol, img_upper, text,
            newtext)
        PlaySound(snd, vol, 0, true)
    end
    lib.sp.sentence(self, img, pos, newtext, canskip, t - dt, hscale, vscale, num, px, py, snd, vol, img_upper, text,
        newtext)
end

----------------------------------------
--sp dialog multi_sentence

--多句对话，适用于对话文字量大、需批量管理的场所（指私坑）
--传入intv则使用sentence_ex，否则使用普通sentence
--传参格式化的规则：
--若部分table长度不足，将用table中最后一个值补齐
--若传入非table类，将自动生成长度与text相同、其中每个值都是传入值的table
--若不传参数或传入nil，将自动生成长度与text相同、其中每个值都是默认值的table
--若传入'default'或传入的表中有值为'default'，则自动替换为对应的默认值
---sp批量对话语句
---@param self lstg.GameObject @对话所属的boss
---@param img table|string @对话图像
---@param pos table|string @对话方位，可选'left' | 'right'
---@param text table|string|number @对话内容
---@param canskip table|boolean @是否可跳过
---@param t table|number @对话时长
---@param hscale table|number @图像横向缩放比
---@param vscale table|number @图像纵向缩放比
---@param num table|string|number @对话图像编号
---@param px table|number @对话图像x坐标
---@param py table|number @对话图像y坐标
---@param intv table|number @每帧显示字符数
---@param snd table|string @对话语音
---@param vol table|number @对话语音音量
---@param img_upper table|boolean @对话图像图层是否高于对话框
---@param start_pos number @对话起始位置
---@param end_pos number @对话结束位置
function lib.sp.multi_sentence(self, img, pos, text, canskip, t, hscale, vscale, num, px, py, intv, snd, vol, img_upper,
                               start_pos, end_pos)
    local IsEX
    if intv then IsEX = true end
    if type(text) ~= 'table' then text = { text } end
    local posn
    if pos == 'left' or pos == 1 then
        posn = 1
    else
        posn = -1
    end
    local default_param = { 'img_void', 'right', '', true, 60, 1, 1, 1, (230 - posn * 150), 128, 1, 'plst00', 0.35, false } --默认参数表
    local param = { img, pos, text, canskip, t, hscale, vscale, num, px, py, intv, snd, vol, img_upper }                    --传入参数表
    --格式化参数，确保每个参数都是长度与text相同的表
    start_pos = start_pos or 1
    end_pos = end_pos or #text
    for i = 1, 14 do
        param[i] = lib.MakeParamList(param[i], #text, default_param[i])
    end
    --批量输出对话
    --我也不想这么写，但每个参数都要读取对应的表所以没法直接unpack
    for i = start_pos, end_pos do
        if IsEX then
            lib.sp.sentence_ex(self, param[1][i], param[2][i], param[3][i], param[4][i], param[5][i], param[6][i],
                param[7][i], param[8][i], param[9][i], param[10][i], param[11][i], param[12][i], param[13][i],
                param[14][i])
        else
            lib.sp.sentence(self, param[1][i], param[2][i], param[3][i], param[4][i], param[5][i], param[6][i],
                param[7][i], param[8][i], param[9][i], param[10][i], param[12][i], param[13][i], param[14][i])
        end
    end
end

----------------------------------------
--sp dialog multi_sentence_ex

--效果同上，但强制使用sentence_ex
--用这个的话可以不用传一大堆nil就能用sentence_ex
---sp批量对话语句ex
---@param self lstg.GameObject @对话所属的boss
---@param img table|string @对话图像
---@param pos table|string @对话方位，可选'left' | 'right'
---@param text table|string|number @对话内容
---@param canskip table|boolean @是否可跳过
---@param t table|number @对话时长
---@param hscale table|number @图像横向缩放比
---@param vscale table|number @图像纵向缩放比
---@param num table|string|number @对话图像编号
---@param px table|number @对话图像x坐标
---@param py table|number @对话图像y坐标
---@param intv table|number @每帧显示字符数
---@param snd table|string @对话语音
---@param vol table|number @对话语音音量
---@param img_upper table|boolean @对话图像图层是否高于对话框
---@param start_pos number @对话起始位置
---@param end_pos number @对话结束位置
function lib.sp.multi_sentence_ex(self, img, pos, text, canskip, t, hscale, vscale, num, px, py, intv, snd, vol,
                                  img_upper, start_pos, end_pos)
    if type(text) ~= 'table' then text = { text } end
    local posn
    if pos == 'left' or pos == 1 then
        posn = 1
    else
        posn = -1
    end
    local default_param = { 'img_void', 'right', '', true, 60, 1, 1, 1, (230 - posn * 150), 128, 1, 'plst00', 0.35, false } --默认参数表
    local param = { img, pos, text, canskip, t, hscale, vscale, num, px, py, intv, snd, vol, img_upper }                    --传入参数表
    --格式化参数，确保每个参数都是长度与text相同的表
    start_pos = start_pos or 1
    end_pos = end_pos or #text
    for i = 1, 14 do
        param[i] = lib.MakeParamList(param[i], #text, default_param[i])
    end
    --批量输出对话
    --我也不想这么写，但每个参数都要读取对应的表所以没法直接unpack
    for i = start_pos, end_pos do
        lib.sp.sentence_ex(self, param[1][i], param[2][i], param[3][i], param[4][i], param[5][i], param[6][i],
            param[7][i], param[8][i], param[9][i], param[10][i], param[11][i], param[12][i], param[13][i], param[14][i])
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------
--boss系自定义对话
--boss custom dialog
--神至今风格对话，对话框在人物旁
--自定义对话库的扩充，更加贴近原作
----------------------------------------

---新建boss系对话显示器，可改变对话框和文字样式
---使用所有对话函数前需要先创建对话显示器，否则按默认配置创建
---可随时重新调用此函数来重设对话显示器
---@param self lstg.GameObject @对话所属的boss
---@param p_dialog boolean 是否将player.dialog设置为true
---@param dialogbox_blend string @对话框渲染模式
---@param dialogbox_co1 lstg.Color @对话框颜色1（左）
---@param dialogbox_co2 lstg.Color @对话框颜色2（右）
---@param text_co1 lstg.Color @对话字体颜色1（左）
---@param text_co2 lstg.Color @对话字体颜色2（右）
---@param dialogTTF string @对话字体（TTF）
function lib.boss.SetDisplayer(self, p_dialog, dialogbox_blend, dialogbox_co1, dialogbox_co2, text_co1, text_co2,
                               text_scale, dialogTTF)
    if IsValid(self.dialog_displayer) then Del(self.dialog_displayer) end
    p_dialog = p_dialog or true
    dialogbox_blend = dialogbox_blend or ''
    dialogbox_co1 = dialogbox_co1 or Color(255, 255, 255, 255)
    dialogbox_co2 = dialogbox_co2 or dialogbox_co1
    text_co1 = text_co1 or Color(255, 0, 0, 0)
    text_co2 = text_co2 or text_co1
    text_scale = text_scale or 1
    dialogTTF = dialogTTF or 'balloon_font'
    self.dialog_displayer = New(lib.boss.dialog_displayer, p_dialog, dialogbox_blend, dialogbox_co1, dialogbox_co2,
        text_co1, text_co2, text_scale, dialogTTF)
end

----------------------------------------
--boss dialog displayer
--！警告：未适配宽屏等非传统版面
--理论上只要改改px、py、tx、ty好像适配也没什么问题……不过那不是我该操心的问题了

---boss对话显示器
lib.boss.dialog_displayer = Class(object)
---@param p_dialog boolean 是否将player.dialog设置为true
---@param dialogbox_blend string @对话框渲染模式
---@param dialogbox_co1 lstg.Color @对话框颜色1（左）
---@param dialogbox_co2 lstg.Color @对话框颜色2（右）
---@param text_co1 lstg.Color @对话字体颜色1（左）
---@param text_co2 lstg.Color @对话字体颜色2（右）
---@param dialogTTF string @对话字体（TTF）
function lib.boss.dialog_displayer:init(p_dialog, dialogbox_blend, dialogbox_co1, dialogbox_co2, text_co1, text_co2,
                                        text_scale, dialogTTF)
    self.type = 'boss'
    self.layer = LAYER_TOP + 10
    self.char = {}
    self.char[1] = {}
    self.char[-1] = {}
    self._hscale = {}
    self._vscale = {}
    self.balloon = {}
    self.t = 16
    self.death = 0
    self.co = 0
    self.blend = dialogbox_blend
    self.balloon_co1 = dialogbox_co1
    self.balloon_co2 = dialogbox_co2
    self.text_co1 = text_co1
    self.text_co2 = text_co2
    self.jump_dialog = 0
    self.dialogTTF = dialogTTF
    self.text_scale = text_scale
    self.p_dialog = p_dialog
    self.active = false --active到底是个什么沙雕东西？？？？？？ --大概是sp遗留下来的遗产罢（虚空回答
    if self.p_dialog then
        local players   --说真的现在还有人会用多玩家吗（各种未适配
        if Players then
            players = Players(self)
        else
            players = { player }
        end
        for _, p in pairs(players) do
            p.dialog = true
        end
    end
end

function lib.boss.dialog_displayer:frame()
    task.Do(self)
    if self.t > 0 then
        self.t = self.t - 1
    end
    local players
    local dialog, shoot
    if Players then
        players = Players(self)
    else
        players = { player }
    end
    for _, p in pairs(players) do
        dialog = p.dialog or dialog
        if p.key then
            shoot = p.key["shoot"] or shoot
        else
            shoot = KeyIsDown "shoot" or shoot
        end
    end
    if dialog and self.active == true then
        if shoot then
            self.jump_dialog = self.jump_dialog + 1
        else
            self.jump_dialog = 0
        end
    end
end

function lib.boss.dialog_displayer:render()
end

function lib.boss.dialog_displayer:del()
    local unit_list = { self.char[-1], self.char[1], self.balloon }
    for _, list in ipairs(unit_list) do
        for _, unit in pairs(list) do
            if IsValid(unit) then
                Del(unit)
            end
        end
    end
    task.New(self, function()
        task.Wait(30)
        local players
        if Players then
            players = Players(self)
        else
            players = { player }
        end
        for _, p in pairs(players) do
            p.dialog = false
        end
        RawDel(self)
    end)
end

----------------------------------------
--boss dialog sentence

--因为vscale后面的参数在Sharp的Sentence里已经失传了
--这里我们需要SharpX的Advanced Sentence来解释解释这一大堆参数是干嘛用的（
---boss对话语句气泡
---@param img string @显示图像
---@param pos string @显示方位
---@param text string @文本语句
---@param canskip boolean @是否可跳过
---@param t number @语句时长
---@param hscale number @图像横向缩放比
---@param vscale number @图像纵向缩放比
---@param tpic number @气泡样式 --这个指气泡样式的编号，看到dialog_balloon.png想必就能懂
---@param num string|number @方位图像编号 --这个是立绘图像的图层编号，用于多角色对话（例：虹龙洞5面6面管狐），当前图层立绘显示时其他立绘暗置并稍向右移动
---@param px number @方位图像x坐标 --立绘图像坐标，注意这里是ui系坐标
---@param py number @方位图像y坐标 --同上
---@param tx number @气泡x坐标 --气泡坐标
---@param ty number @气泡y坐标 --同上
---@param tn number @语句保留条数 --本条对话持续显示的时间，如填3则会持续显示至两句对话后
---@param stay boolean @对话后是否保持激活 --若为true则本句对话立绘亮置直至对话结束
---@param snd string @对话跳过声音
---@param vol number @对话跳过声音音量
---@param rawtext string @未处理文字效果的text（由sentence_ex使用）
---@param fulltext string @已处理文字效果但未截取的text（由sentence_ex使用）
---@param balloon_ex boolean @sentence_ex的标志，会影响对balloon.n的处理（由sentence_ex使用）
function lib.boss.sentence(self, img, pos, text, canskip, t, hscale, vscale, tpic, num, px, py, tx, ty, tn, stay, snd,
                           vol, rawtext, fulltext, balloon_ex)
    if pos == "left" or pos == 1 then
        pos = 1
    else
        pos = -1
    end
    num = num or 1
    px = px or (230 - pos * 150)
    py = py or 128
    tx = tx or (230 - pos * 100)
    ty = ty or 230
    tpic, tn = tpic or 1, tn or 1
    hscale, vscale = hscale or pos, vscale or 1
    snd = snd or 'plst00'
    vol = vol or 0.35
    if self.dialog_displayer.type ~= 'boss' then
        lib.boss.SetDisplayer(self)
    end
    local master = self.dialog_displayer
    local newtext, flag, param = lib.MultiGetTextEffect(text)
    if not rawtext and flag then
        for k, v in ipairs(flag) do
            if v == 'sound' then snd = param[k] end
            if v == 'volume' then vol = lib.StrToNum(param[k]) end
            if v == 'image' then img = param[k] end
            if v == 'shader' and not lstg.tmpvar.TextEffect_RT_Created then
                CreateRenderTarget('TextEffect_RenderTarget')
                lstg.tmpvar.TextEffect_RT_Created = true
            end
            if lib.text_effect[v] and lib.text_effect[v][1] == 'on_sentence' and lib.text_effect[v][2] then
                lib.text_effect[v][2](param[k])
            end
        end
    end
    master.text = newtext
    master.rawtext = rawtext or text
    master.fulltext = fulltext or newtext
    master.active = true
    if not IsValid(master.char[pos][num]) then
        master.char[pos][num] = New(lib.character, img, pos, px, py, vscale, hscale, num)
    else
        master.char[pos][num].act = true
        master.char[pos][num].img = img
        master.char[pos][num].x = px
        master.char[pos][num].y = py
        master.char[pos][num].vscale = vscale
        master.char[pos][num].hscale = hscale
    end
    --lastdialogpic = master.char[pos][num]
    task.Wait()
    local balloon_co, text_co
    if pos == 1 then
        balloon_co = master.balloon_co1
        text_co = master.text_co1
    else
        balloon_co = master.balloon_co2
        text_co = master.text_co2
    end
    local balloon = New(lib.balloon, master, tx, ty, pos, 1, tpic, newtext, tn, master.blend, balloon_co, text_co,
        master.text_scale)
    table.insert(master.balloon, balloon)
    --lastsentence = balloon
    t = t or (60 + #text * 5)
    for _ = 1, t do
        if (KeyIsPressed "shoot" or master.jump_dialog > 60) and canskip then
            PlaySound(snd, vol, 0, true)
            if master.jump_dialog > 60 then
                master.jump_dialog = 56
            end
            break
        end
        task.Wait()
    end
    local unit
    local n = table.maxn(master.balloon) or 0
    for i = n, 1, -1 do
        unit = master.balloon[i]
        if IsValid(unit) then
            if balloon_ex then
                unit.n = unit.n - 1 / #fulltext
            else
                unit.n = unit.n - 1
            end
        else
            table.remove(master.balloon, i)
        end
    end
    task.Wait(2)
    master.char[pos][num].act = stay or false
end

----------------------------------------
--boss dialog sentence_ex

--使用字符串截取来逐字显示的对话，支持对话语音（参考UT）
--注意：由于sentence_ex会创建大量sentence，本函数不支持对话滞留（tn）与半透明气泡
---boss对话语句气泡ex
---@param self lstg.GameObject @对话所属的boss
---@param img string @对话图像
---@param pos string @对话方位
---@param text string|number @对话内容
---@param canskip boolean @是否可跳过
---@param t number @对话时长
---@param hscale number @图像横向缩放比
---@param vscale number @图像纵向缩放比
---@param tpic number @气泡样式 --这个指气泡样式的编号，看到dialog_balloon.png想必就能懂
---@param num string|number @方位图像编号 --这个是立绘图像的图层编号，用于多角色对话（例：虹龙洞5面6面管狐），当前图层立绘显示时其他立绘暗置并稍向右移动
---@param px number @方位图像x坐标 --立绘图像坐标，注意这里是ui系坐标
---@param py number @方位图像y坐标 --同上
---@param tx number @气泡x坐标 --气泡坐标
---@param ty number @气泡y坐标 --同上
---@param stay boolean @对话后是否保持激活 --若为true则本句对话立绘亮置直至对话结束
---@param intv number @每帧显示字符数
---@param snd string @对话语音
---@param vol number @对话语音音量
function lib.boss.sentence_ex(self, img, pos, text, canskip, t, hscale, vscale, tpic, num, px, py, tx, ty, stay, intv,
                              snd, vol)
    intv = intv or 1
    hscale = hscale or 1
    vscale = vscale or hscale or 1
    num = num or 1
    px = px or (230 - pos * 150)
    py = py or 128
    tx = tx or (230 - pos * 100)
    ty = ty or 230
    tpic = tpic or 1
    local tn = 1
    stay = stay or false
    snd = snd or 'plst00'
    vol = vol or 0.35
    local default_img = img
    local default_snd = snd
    local default_vol = vol
    local newtext, flag, param, s, e = lib.MultiGetTextEffect(text)
    --由于spstring把text整理成了table，这玩意和#text还有点区别
    local l = sp.string(newtext):GetCharCount()
    if flag then
        for _, v in ipairs(flag) do
            if v == 'shader' and not lstg.tmpvar.TextEffect_RT_Created then
                CreateRenderTarget('TextEffect_RenderTarget')
                lstg.tmpvar.TextEffect_RT_Created = true
            end
        end
    end
    t = t or (60 + l * 5)
    local dt = 0
    for i = 1, l, intv do
        if (KeyIsPressed 'shoot' or self.dialog_displayer.jump_dialog > 60) and canskip then
            PlaySound(snd, vol, 0, true)
            if self.dialog_displayer.jump_dialog > 60 then
                self.dialog_displayer.jump_dialog = 56
            end
            break
        end
        dt = dt + 1
        if flag then
            for k, v in ipairs(flag) do
                if i > s[k] - intv and i <= e[k] - intv then
                    if v == 'sound' then snd = param[k] end
                    if v == 'volume' then vol = lib.StrToNum(param[k]) end
                    if v == 'image' then img = param[k] end
                    if v == 'Sinemove' then
                        px = px + lib.StrToNum(param[k][1]) * sin(lib.StrToNum(param[k][3] or 5) * self.timer + lib.StrToNum(param[k][4] or 0) - self.timer % 180)
                        py = py + lib.StrToNum(param[k][2] or 0) * sin(lib.StrToNum(param[k][3] or 5) * self.timer + lib.StrToNum(param[k][4] or 0) - self.timer % 180)
                    end
                    if lib.text_effect[v] and lib.text_effect[v][1] == 'on_sentence_ex' and lib.text_effect[v][2] then
                        lib.text_effect[v][2](param[k])
                    end
                elseif i > e[k] - intv then
                    if e[k] < l then img = default_img end
                    snd = default_snd
                    vol = default_vol
                    if lib.text_effect[v] and lib.text_effect[v][1] == 'on_sentence_ex' and lib.text_effect[v][3] then
                        lib.text_effect[v][3](param[k])
                    end
                end
            end
        end
        local text_slice = sp.string(newtext):Sub(1, i)
        lib.boss.sentence(self, img, pos, text_slice, canskip, 1, hscale, vscale, tpic, num, px, py, tx, ty, tn, stay,
            snd, vol, text,
            newtext, true)
        PlaySound(snd, vol, 0, true)
    end
    lib.boss.sentence(self, img, pos, newtext, canskip, t - dt, hscale, vscale, tpic, num, px, py, tx, ty, tn, stay, snd,
        vol, text,
        newtext)
end

----------------------------------------
--boss dialog multi_sentence

--多句对话，适用于对话文字量大、需批量管理的场所（指私坑）
--传入intv则使用sentence_ex，否则使用普通sentence
--传参格式化的规则：
--若部分table长度不足，将用table中最后一个值补齐
--若传入非table类，将自动生成长度与text相同、其中每个值都是传入值的table
--若不传参数或传入nil，将自动生成长度与text相同、其中每个值都是默认值的table
--若传入'default'或传入的表中有值为'default'，则自动替换为对应的默认值
---boss批量对话语句
---@param self lstg.GameObject @对话所属的boss
---@param img table|string @对话图像
---@param pos table|string @对话方位，可选'left' | 'right'
---@param text table|string|number @对话内容
---@param canskip table|boolean @是否可跳过
---@param t table|number @对话时长
---@param hscale table|number @图像横向缩放比
---@param vscale table|number @图像纵向缩放比
---@param tpic number @气泡样式 --这个指气泡样式的编号，看到dialog_balloon.png想必就能懂
---@param num table|string|number @对话图像编号
---@param px table|number @对话图像x坐标
---@param py table|number @对话图像y坐标
---@param tx number @气泡x坐标 --气泡坐标
---@param ty number @气泡y坐标 --同上
---@param stay boolean @对话后是否保持激活 --若为true则本句对话立绘亮置直至对话结束
---@param intv table|number @每帧显示字符数
---@param snd table|string @对话语音
---@param vol table|number @对话语音音量
---@param start_pos number @对话起始位置
---@param end_pos number @对话结束位置
function lib.boss.multi_sentence(self, img, pos, text, canskip, t, hscale, vscale, tpic, num, px, py, tx, ty, tn, stay,
                                 intv, snd, vol, start_pos, end_pos)
    local IsEX
    if intv then IsEX = true end
    if type(text) ~= 'table' then text = { text } end
    local posn
    if pos == 'left' or pos == 1 then
        posn = 1
    else
        posn = -1
    end
    local default_param = { 'img_void', 'right', '', true, 60, 1, 1, 1, 1, (230 - posn * 150), 128, (230 - posn * 100),
        230, 1, false, 1, 'plst00', 0.35 }                                                                            --默认参数表
    local param = { img, pos, text, canskip, t, hscale, vscale, num, tpic, px, py, tx, ty, tn, stay, intv, snd, vol } --传入参数表
    --格式化参数，确保每个参数都是长度与text相同的表
    start_pos = start_pos or 1
    end_pos = end_pos or #text
    for i = 1, 18 do --sp的参数已经多得离谱了，然而这里还多4个，我吐了
        param[i] = lib.MakeParamList(param[i], #text, default_param[i])
    end
    --批量输出对话
    --我也不想这么写，但每个参数都要读取对应的表所以没法直接unpack
    for i = start_pos, end_pos do
        if IsEX then
            lib.boss.sentence_ex(self, param[1][i], param[2][i], param[3][i], param[4][i], param[5][i], param[6][i],
                param[7][i], param[8][i], param[9][i], param[10][i], param[11][i], param[12][i], param[13][i],
                param[15][i], param[16][i], param[17][i], param[18][i])
        else
            lib.boss.sentence(self, param[1][i], param[2][i], param[3][i], param[4][i], param[5][i], param[6][i],
                param[7][i], param[8][i], param[9][i], param[10][i], param[11][i], param[12][i], param[13][i],
                param[14][i], param[15][i], param[17][i], param[18][i])
        end
    end
end

----------------------------------------
--boss dialog multi_sentence_ex

--效果同上，但强制使用sentence_ex
--用这个的话可以不用传一大堆nil就能用sentence_ex
---boss批量对话语句ex
---@param self lstg.GameObject @对话所属的boss
---@param img table|string @对话图像
---@param pos table|string @对话方位，可选'left' | 'right'
---@param text table|string|number @对话内容
---@param canskip table|boolean @是否可跳过
---@param t table|number @对话时长
---@param hscale table|number @图像横向缩放比
---@param vscale table|number @图像纵向缩放比
---@param num table|string|number @对话图像编号
---@param tpic number @气泡样式 --这个指气泡样式的编号，看到dialog_balloon.png想必就能懂
---@param px table|number @对话图像x坐标
---@param py table|number @对话图像y坐标
---@param tx number @气泡x坐标 --气泡坐标
---@param ty number @气泡y坐标 --同上
---@param stay boolean @对话后是否保持激活 --若为true则本句对话立绘亮置直至对话结束
---@param intv table|number @每帧显示字符数
---@param snd table|string @对话语音
---@param vol table|number @对话语音音量
---@param img_upper table|boolean @对话图像图层是否高于对话框
---@param start_pos number @对话起始位置
---@param end_pos number @对话结束位置
function lib.boss.multi_sentence_ex(self, img, pos, text, canskip, t, hscale, vscale, tpic, num, px, py, tx, ty, stay,
                                    intv, snd, vol, start_pos, end_pos)
    if type(text) ~= 'table' then text = { text } end
    local posn
    if pos == 'left' or pos == 1 then
        posn = 1
    else
        posn = -1
    end
    local default_param = { 'img_void', 'right', '', true, 60, 1, 1, 1, 1, (230 - posn * 150), 128, (230 - posn * 100),
        230, false, 1, 'plst00', 0.35 }                                                                           --默认参数表
    local param = { img, pos, text, canskip, t, hscale, vscale, num, tpic, px, py, tx, ty, stay, intv, snd, vol } --传入参数表
    --格式化参数，确保每个参数都是长度与text相同的表
    start_pos = start_pos or 1
    end_pos = end_pos or #text
    for i = 1, 17 do
        param[i] = lib.MakeParamList(param[i], #text, default_param[i])
    end
    --批量输出对话
    --我也不想这么写，但每个参数都要读取对应的表所以没法直接unpack
    for i = start_pos, end_pos do
        lib.boss.sentence_ex(self, param[1][i], param[2][i], param[3][i], param[4][i], param[5][i], param[6][i],
            param[7][i], param[8][i], param[9][i], param[10][i], param[11][i], param[12][i], param[13][i], param[14][i],
            param[15][i], param[16][i], param[17][i])
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------
--middle系自定义对话
--middle custom dialog
--鬼以后出现的悬浮对话，对话框在boss正下方
--自定义对话库的扩充，是对boss系对话的补充
----------------------------------------

---新建middle系对话显示器，可改变对话框和文字样式
---使用所有对话函数前需要先创建对话显示器，否则按默认配置创建
---可随时重新调用此函数来重设对话显示器
---@param self lstg.GameObject @对话所属的boss
---@param p_dialog boolean 是否将player.dialog设置为true
---@param dialogbox_blend string @对话框渲染模式
---@param dialogbox_co lstg.Color @对话框颜色
---@param text_co lstg.Color @对话字体颜色
---@param dialogTTF string @对话字体（TTF）
function lib.middle.SetDisplayer(self, p_dialog, dialogbox_blend, dialogbox_co, text_co, text_scale, dialogTTF)
    if IsValid(self.dialog_displayer) then Del(self.dialog_displayer) end
    p_dialog = p_dialog or true
    dialogbox_blend = dialogbox_blend or ''
    dialogbox_co = dialogbox_co or Color(255, 255, 255, 255)
    text_co = text_co or Color(255, 0, 0, 0)
    text_scale = text_scale or 1
    dialogTTF = dialogTTF or 'balloon_font'
    self.dialog_displayer = New(lib.middle.dialog_displayer, p_dialog, dialogbox_blend, dialogbox_co, text_co, text_scale,
        dialogTTF)
end

----------------------------------------
--middle dialog displayer
---middle对话显示器
lib.middle.dialog_displayer = Class(object)
---@param p_dialog boolean 是否将player.dialog设置为true
---@param dialogbox_blend string @对话框渲染模式
---@param dialogbox_co lstg.Color @对话框颜色
---@param text_co lstg.Color @对话字体颜色
---@param dialogTTF string @对话字体（TTF）
function lib.middle.dialog_displayer:init(p_dialog, dialogbox_blend, dialogbox_co, text_co, text_scale, dialogTTF)
    self.type = 'float'
    self.layer = LAYER_TOP + 10
    self.char = {}
    self.char[1] = {}
    self.char[-1] = {}
    self._hscale = {}
    self._vscale = {}
    self.balloon = {}
    self.t = 16
    self.death = 0
    self.co = 0
    self.blend = dialogbox_blend
    self.balloon_co = dialogbox_co
    self.text_co = text_co
    self.jump_dialog = 0
    self.dialogTTF = dialogTTF
    self.text_scale = text_scale
    self.p_dialog = p_dialog
    self.active = false --active到底是个什么沙雕东西？？？？？？ --大概是sp遗留下来的遗产罢（虚空回答
    if self.p_dialog then
        local players   --说真的现在还有人会用多玩家吗（各种未适配
        if Players then
            players = Players(self)
        else
            players = { player }
        end
        for _, p in pairs(players) do
            p.dialog = true
        end
    end
end

function lib.middle.dialog_displayer:frame()
    task.Do(self)
    if self.t > 0 then
        self.t = self.t - 1
    end
    local players
    local dialog, shoot
    if Players then
        players = Players(self)
    else
        players = { player }
    end
    for _, p in pairs(players) do
        dialog = p.dialog or dialog
        if p.key then
            shoot = p.key["shoot"] or shoot
        else
            shoot = KeyIsDown "shoot" or shoot
        end
    end
    if dialog and self.active == true then
        if shoot then
            self.jump_dialog = self.jump_dialog + 1
        else
            self.jump_dialog = 0
        end
    end
end

function lib.middle.dialog_displayer:render()
end

function lib.middle.dialog_displayer:del()
    for _, unit in pairs(self.balloon) do
        if IsValid(unit) then
            Del(unit)
        end
    end
    task.New(self, function()
        task.Wait(30)
        local players
        if Players then
            players = Players(self)
        else
            players = { player }
        end
        for _, p in pairs(players) do
            p.dialog = false
        end
        RawDel(self)
    end)
end

----------------------------------------
--middle dialog sentence

---middle对话语句气泡
---@param text string @文本语句
---@param canskip boolean @是否可跳过
---@param t number @语句时长
---@param tpic number @气泡样式 --这个指气泡样式的编号，看到dialog_balloon.png想必就能懂
---@param tx number @气泡x坐标 --气泡坐标相对boss坐标偏移值
---@param ty number @气泡y坐标 --同上
---@param tn number @语句保留条数 --本条对话持续显示的时间，如填3则会持续显示至两句对话后
---@param snd string @对话跳过声音
---@param vol number @对话跳过声音音量
---@param rawtext string @未处理文字效果的text（由sentence_ex使用）
---@param fulltext string @已处理文字效果但未截取的text（由sentence_ex使用）
---@param balloon_ex boolean @sentence_ex的标志，会影响对balloon.n的处理（由sentence_ex使用）
function lib.middle.sentence(self, text, canskip, t, tpic, tx, ty, tn, snd, vol, rawtext, fulltext, balloon_ex)
    tx = tx or -10
    ty = ty or -25
    tpic, tn = tpic or 1, tn or 1
    snd = snd or 'plst00'
    vol = vol or 0.35
    if self.dialog_displayer.type ~= 'float' then
        lib.middle.SetDisplayer(self)
    end
    local master = self.dialog_displayer
    local newtext, flag, param = lib.MultiGetTextEffect(text)
    if not rawtext and flag then
        for k, v in ipairs(flag) do
            if v == 'sound' then snd = param[k] end
            if v == 'volume' then vol = lib.StrToNum(param[k]) end
            if v == 'shader' and not lstg.tmpvar.TextEffect_RT_Created then
                CreateRenderTarget('TextEffect_RenderTarget')
                lstg.tmpvar.TextEffect_RT_Created = true
            end
            if lib.text_effect[v] and lib.text_effect[v][1] == 'on_sentence' and lib.text_effect[v][2] then
                lib.text_effect[v][2](param[k])
            end
        end
    end
    master.text = newtext
    master.rawtext = rawtext or text
    master.fulltext = fulltext or newtext
    master.active = true
    task.Wait()
    local x, y = lib.PosTrans(self.x + tx, self.y + ty, 'world', 'ui')
    local balloon = New(lib.ballon_middle, master, x, y, 1, tpic, newtext, tn, master.blend, master.balloon_co,
        master.text_co, master.text_scale)
    table.insert(master.balloon, balloon)
    --lastsentence = balloon
    t = t or (60 + #text * 5)
    for _ = 1, t do
        if (KeyIsPressed "shoot" or master.jump_dialog > 60) and canskip then
            PlaySound(snd, vol, 0, true)
            if master.jump_dialog > 60 then
                master.jump_dialog = 56
            end
            break
        end
        task.Wait()
    end
    local unit
    local n = table.maxn(master.balloon) or 0
    for i = n, 1, -1 do
        unit = master.balloon[i]
        if IsValid(unit) then
            if balloon_ex then
                unit.n = unit.n - 1 / #fulltext
            else
                unit.n = unit.n - 1
            end
        else
            table.remove(master.balloon, i)
        end
    end
    task.Wait(2)
end

----------------------------------------
--middle dialog sentence_ex

--使用字符串截取来逐字显示的对话，支持对话语音（参考UT）
--注意：由于sentence_ex会创建大量sentence，本函数不支持对话滞留（tn）与半透明气泡
---middle对话语句气泡ex
---@param self lstg.GameObject @对话所属的boss
---@param text string|number @对话内容
---@param canskip boolean @是否可跳过
---@param t number @对话时长
---@param tpic number @气泡样式 --这个指气泡样式的编号，看到dialog_balloon.png想必就能懂
---@param tx number @气泡x坐标 --气泡坐标相对boss坐标偏移值
---@param ty number @气泡y坐标 --同上
---@param intv number @每帧显示字符数
---@param snd string @对话语音
---@param vol number @对话语音音量
function lib.middle.sentence_ex(self, text, canskip, t, tpic, tx, ty, intv, snd, vol)
    intv = intv or 1
    tx = tx or -10
    ty = ty or -25
    tpic = tpic or 1
    local tn = 1
    snd = snd or 'plst00'
    vol = vol or 0.35
    local default_snd = snd
    local default_vol = vol
    local newtext, flag, param, s, e = lib.MultiGetTextEffect(text)
    --由于spstring把text整理成了table，这玩意和#text还有点区别
    local l = sp.string(newtext):GetCharCount()
    if flag then
        for _, v in ipairs(flag) do
            if v == 'shader' and not lstg.tmpvar.TextEffect_RT_Created then
                CreateRenderTarget('TextEffect_RenderTarget')
                lstg.tmpvar.TextEffect_RT_Created = true
            end
        end
    end
    t = t or (60 + l * 5)
    local dt = 0
    for i = 1, l, intv do
        if (KeyIsPressed 'shoot' or self.dialog_displayer.jump_dialog > 60) and canskip then
            PlaySound(snd, vol, 0, true)
            if self.dialog_displayer.jump_dialog > 60 then
                self.dialog_displayer.jump_dialog = 56
            end
            break
        end
        dt = dt + 1
        if flag then
            for k, v in ipairs(flag) do
                if i > s[k] - intv and i <= e[k] - intv then
                    if v == 'sound' then snd = param[k] end
                    if v == 'volume' then vol = lib.StrToNum(param[k]) end
                    if lib.text_effect[v] and lib.text_effect[v][1] == 'on_sentence_ex' and lib.text_effect[v][2] then
                        lib.text_effect[v][2](param[k])
                    end
                elseif i > e[k] - intv then
                    snd = default_snd
                    vol = default_vol
                    if lib.text_effect[v] and lib.text_effect[v][1] == 'on_sentence_ex' and lib.text_effect[v][3] then
                        lib.text_effect[v][3](param[k])
                    end
                end
            end
        end
        local text_slice = sp.string(newtext):Sub(1, i)
        lib.middle.sentence(self, text_slice, canskip, 1, tpic, tx, ty, tn, snd, vol, text,
            newtext, true)
        PlaySound(snd, vol, 0, true)
    end
    lib.middle.sentence(self, newtext, canskip, t - dt, tpic, tx, ty, tn, snd,
        vol, text, newtext)
end

----------------------------------------
--middle dialog multi_sentence

--多句对话，适用于对话文字量大、需批量管理的场所（指私坑）
--传入intv则使用sentence_ex，否则使用普通sentence
--传参格式化的规则：
--若部分table长度不足，将用table中最后一个值补齐
--若传入非table类，将自动生成长度与text相同、其中每个值都是传入值的table
--若不传参数或传入nil，将自动生成长度与text相同、其中每个值都是默认值的table
--若传入'default'或传入的表中有值为'default'，则自动替换为对应的默认值
---middle批量对话语句
---@param self lstg.GameObject @对话所属的boss
---@param text table|string|number @对话内容
---@param canskip table|boolean @是否可跳过
---@param t table|number @对话时长
---@param tpic number @气泡样式 --这个指气泡样式的编号，看到dialog_balloon.png想必就能懂
---@param tx number @气泡x坐标 --气泡坐标相对boss坐标偏移值
---@param ty number @气泡y坐标 --同上
---@param tn number @语句保留条数 --本条对话持续显示的时间，如填3则会持续显示至两句对话后
---@param intv table|number @每帧显示字符数
---@param snd table|string @对话语音
---@param vol table|number @对话语音音量
---@param start_pos number @对话起始位置
---@param end_pos number @对话结束位置
function lib.middle.multi_sentence(self, text, canskip, t, tpic, tx, ty, tn, intv, snd, vol, start_pos, end_pos)
    local IsEX
    if intv then IsEX = true end
    if type(text) ~= 'table' then text = { text } end
    local default_param = { '', false, 60, 1, -10, -25, 1, 1, 'plst00', 0.35 } --默认参数表
    local param = { text, canskip, t, tpic, tx, ty, tn, intv, snd, vol }       --传入参数表
    --格式化参数，确保每个参数都是长度与text相同的表
    start_pos = start_pos or 1
    end_pos = end_pos or #text
    for i = 1, 10 do --参数终于少一点了
        param[i] = lib.MakeParamList(param[i], #text, default_param[i])
    end
    --批量输出对话
    --我也不想这么写，但每个参数都要读取对应的表所以没法直接unpack
    for i = start_pos, end_pos do
        if IsEX then
            lib.middle.sentence_ex(self, param[1][i], param[2][i], param[3][i], param[4][i], param[5][i], param[6][i],
                param[8][i], param[9][i], param[10][i])
        else
            lib.middle.sentence(self, param[1][i], param[2][i], param[3][i], param[4][i], param[5][i], param[6][i],
                param[7][i], param[9][i], param[10][i])
        end
    end
end

----------------------------------------
--middle dialog multi_sentence_ex

--效果同上，但强制使用sentence_ex
--用这个的话可以不用传一大堆nil就能用sentence_ex
---middle批量对话语句ex
---@param self lstg.GameObject @对话所属的boss
---@param text table|string|number @对话内容
---@param canskip table|boolean @是否可跳过
---@param t table|number @对话时长
---@param tpic number @气泡样式 --这个指气泡样式的编号，看到dialog_balloon.png想必就能懂
---@param tx number @气泡x坐标 --气泡坐标相对boss坐标偏移值
---@param ty number @气泡y坐标 --同上
---@param intv table|number @每帧显示字符数
---@param snd table|string @对话语音
---@param vol table|number @对话语音音量
---@param start_pos number @对话起始位置
---@param end_pos number @对话结束位置
function lib.middle.multi_sentence_ex(self, text, canskip, t, tpic, tx, ty, intv, snd, vol, start_pos, end_pos)
    if type(text) ~= 'table' then text = { text } end
    local default_param = { '', false, 60, 1, -10, -25, 1, 'plst00', 0.35 } --默认参数表
    local param = { text, canskip, t, tpic, tx, ty, intv, snd, vol }        --传入参数表
    --格式化参数，确保每个参数都是长度与text相同的表
    start_pos = start_pos or 1
    end_pos = end_pos or #text
    for i = 1, 9 do
        param[i] = lib.MakeParamList(param[i], #text, default_param[i])
    end
    --批量输出对话
    --我也不想这么写，但每个参数都要读取对应的表所以没法直接unpack
    for i = start_pos, end_pos do
        lib.middle.sentence_ex(self, param[1][i], param[2][i], param[3][i], param[4][i], param[5][i], param[6][i],
            param[7][i], param[8][i], param[9][i])
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------
--float系自定义对话
--float custom dialog
--无立绘、位置不固定的对话，自由度极高
--可以用来复刻实在相爱美的开场对话（不是
----------------------------------------

---新建float系对话显示器，可改变对话框和文字样式
---使用所有对话函数前需要先创建对话显示器，否则按默认配置创建
---可随时重新调用此函数来重设对话显示器
---@param self lstg.GameObject @对话所属的boss
---@param p_dialog boolean 是否将player.dialog设置为true
---@param dialogbox string @对话框图片
---@param dialogbox_hscale number @对话框横向缩放比
---@param dialogbox_vscale number @对话框纵向缩放比
---@param text_yu number @对话y坐标偏移值
---@param dialogbox_blend string @对话框渲染模式
---@param dialogbox_co lstg.Color @对话框颜色
---@param text_co lstg.Color @对话字体颜色
---@param dialogTTF string @对话字体（TTF）
function lib.float.SetDisplayer(self, p_dialog, dialogbox, dialogbox_hscale, dialogbox_vscale, text_yu,
                                dialogbox_blend, dialogbox_co, text_co, text_scale, dialogTTF)
    if IsValid(self.dialog_displayer) then Del(self.dialog_displayer) end
    dialogbox_blend = dialogbox_blend or ''
    dialogbox_co = dialogbox_co
    text_co = text_co or Color(255, 255, 200, 200)
    dialogbox = dialogbox or 'dialog_box'
    dialogTTF = dialogTTF or 'dialog'
    dialogbox_hscale = dialogbox_hscale or 1
    dialogbox_vscale = dialogbox_hscale or dialogbox_vscale or 1
    text_yu = text_yu or 0
    text_scale = text_scale or 1
    p_dialog = p_dialog or true
    self.dialog_displayer = New(lib.float.dialog_displayer, p_dialog, dialogbox, dialogbox_hscale, dialogbox_vscale,
        text_yu, dialogbox_blend, dialogbox_co, text_co, text_scale, dialogTTF)
end

----------------------------------------
--float dialog displayer

--由于不用显示立绘，逻辑简单了很多
---float对话显示器
lib.float.dialog_displayer = Class(object)
---@param p_dialog boolean 是否将player.dialog设置为true
---@param dialogbox string @对话框图片
---@param dialogbox_hscale number @对话框横向缩放比
---@param dialogbox_vscale number @对话框纵向缩放比
---@param text_yu number @对话y坐标偏移值
---@param dialogbox_blend string @对话框渲染模式
---@param dialogbox_co lstg.Color @对话框颜色
---@param text_co lstg.Color @对话字体颜色
---@param dialogTTF string @对话字体（TTF）
function lib.float.dialog_displayer:init(p_dialog, dialogbox, dialogbox_hscale, dialogbox_vscale, text_yu,
                                         dialogbox_blend, dialogbox_co, text_co, text_scale, dialogTTF)
    self.type = 'float'
    self.layer = LAYER_TOP + 10
    self.x = screen.width / 8
    self.y = screen.height / 2
    self.t = 16
    self.death = 0
    self.co = 0
    self.blend = dialogbox_blend
    self.dialogbox_co = dialogbox_co
    self.text_co = text_co
    self.jump_dialog = 0
    self.dialogbox = dialogbox
    self.dialogTTF = dialogTTF
    self.dialogbox_hscale = dialogbox_hscale
    self.dialogbox_vscale = dialogbox_vscale
    self.text_yu = text_yu
    self.text_scale = text_scale
    self.ttfdrawer = lib.TTFDrawer('', self)
    self.p_dialog = p_dialog
    if self.p_dialog then
        local players
        if Players then
            players = Players(self)
        else
            players = { player }
        end
        for _, p in pairs(players) do
            p.dialog = true
        end
    end
end

function lib.float.dialog_displayer:frame()
    task.Do(self)
    if self.t > 0 then
        self.t = self.t - 1
    end
    if self.active and type(self.active) == 'number' then
        self.co = max(min(60, self.co + 1.5 * self.active), -60)
    end
    local players
    local dialog, shoot
    if Players then
        players = Players(self)
    else
        players = { player }
    end
    for _, p in pairs(players) do
        dialog = p.dialog or dialog
        if p and p.key then
            shoot = p.key["shoot"] or shoot
        else
            shoot = KeyIsDown "shoot" or shoot
        end
    end
    if dialog and self.active then
        if shoot then
            self.jump_dialog = self.jump_dialog + 1
        else
            self.jump_dialog = 0
        end
    end
    if self.text then self.ttfdrawer:set(self.text) end
end

function lib.float.dialog_displayer:render()
    SetViewMode('ui')
    if self.text then
        local x, y = self.x, self.y
        local dy = self.text_yu - 10
        if self.dialogbox_co then
            SetImageState(self.dialogbox, self.blend, self.dialogbox_co)
        else
            SetImageState(self.dialogbox, self.blend, Color(225, 195 - self.co, 150, 195 + self.co))
        end
        --修正对话框位置
        local w, h = GetImageSize(self.dialogbox)
        Render(self.dialogbox, x + w / 2, y - h / 2, 0, self.dialogbox_hscale,
            self.dialogbox_vscale)
        self.ttfdrawer:render(self.dialogTTF,
            x, x, y + dy, y + dy, 16, 32, 0, 0,
            self.text_scale, self.text_co, 4)
    end
    SetViewMode('world')
end

function lib.float.dialog_displayer:del()
    PreserveObject(self)
    task.New(self, function()
        for i = 1, 30 do
            self.death = i
            task.Wait()
        end
        local players
        if Players then
            players = Players(self)
        else
            players = { player }
        end
        for _, p in pairs(players) do
            p.dialog = false
        end
        RawDel(self)
    end)
end

----------------------------------------
--float dialog sentence

--最基本的单句对话
---float对话语句
---@param self lstg.GameObject @对话所属的boss
---@param x number @对话框左上角x坐标（ui系）
---@param y number @对话框左上角y坐标（ui系）
---@param text string|number @对话内容
---@param canskip boolean @是否可跳过
---@param t number @对话时长
---@param snd string @对话跳过声音
---@param vol number @对话跳过声音音量
---@param rawtext string @未处理文字效果的text（由sentence_ex使用）
---@param fulltext string @已处理文字效果但未截取的text（由sentence_ex使用）
function lib.float.sentence(self, x, y, text, canskip, t, snd, vol, rawtext, fulltext)
    if self.dialog_displayer.type ~= 'float' then
        lib.float.SetDisplayer(self)
    end
    local master = self.dialog_displayer
    text = text or ''
    canskip = canskip or false
    snd = snd or 'plst00'
    vol = vol or 0.35
    local newtext, flag, param = lib.MultiGetTextEffect(text)
    if not rawtext and flag then
        for k, v in ipairs(flag) do
            if v == 'sound' then snd = param[k] end
            if v == 'volume' then vol = lib.StrToNum(param[k]) end
            if v == 'shader' and not lstg.tmpvar.TextEffect_RT_Created then
                CreateRenderTarget('TextEffect_RenderTarget')
                lstg.tmpvar.TextEffect_RT_Created = true
            end
            if lib.text_effect[v] and lib.text_effect[v][1] == 'on_sentence' and lib.text_effect[v][2] then
                lib.text_effect[v][2](param[k])
            end
        end
    end
    master.text = newtext
    master.rawtext = rawtext or text
    master.fulltext = fulltext or newtext
    master.x, master.y = x, y
    task.Wait()
    t = t or (60 + #text * 5)
    for _ = 1, t do
        if (KeyIsPressed 'shoot' or master.jump_dialog > 60) and canskip then
            PlaySound(snd, vol, 0, true)
            if master.jump_dialog > 60 then
                master.jump_dialog = 56
            end
            break
        end
        task.Wait()
    end
    task.Wait(2)
end

----------------------------------------
--float dialog sentence_ex

--使用字符串截取来逐字显示的对话，支持对话语音（参考UT）
---float对话语句ex
---@param self lstg.GameObject @对话所属的boss
---@param x number @对话框左上角x坐标（ui系）
---@param y number @对话框左上角y坐标（ui系）
---@param text string|number @对话内容
---@param canskip boolean @是否可跳过
---@param t number @对话时长
---@param intv number @每帧显示字符数
---@param snd string @对话语音
---@param vol number @对话语音音量
function lib.float.sentence_ex(self, x, y, text, canskip, t, intv, snd, vol)
    x = x or screen.width / 8
    y = y or screen.height / 2
    intv = intv or 1
    snd = snd or 'plst00'
    vol = vol or 0.35
    local default_snd = snd
    local default_vol = vol
    local newtext, flag, param, s, e = lib.MultiGetTextEffect(text)
    --由于spstring把text整理成了table，这玩意和#text还有点区别
    local l = sp.string(newtext):GetCharCount()
    if flag then
        for _, v in ipairs(flag) do
            if v == 'shader' and not lstg.tmpvar.TextEffect_RT_Created then
                CreateRenderTarget('TextEffect_RenderTarget')
                lstg.tmpvar.TextEffect_RT_Created = true
            end
        end
    end
    t = t or (60 + l * 5)
    local dt = 0
    for i = 1, l, intv do
        if (KeyIsPressed 'shoot' or self.dialog_displayer.jump_dialog > 60) and canskip then
            PlaySound(snd, vol, 0, true)
            if self.dialog_displayer.jump_dialog > 60 then
                self.dialog_displayer.jump_dialog = 56
            end
            break
        end
        dt = dt + 1
        if flag then
            for k, v in ipairs(flag) do
                if i > s[k] - intv and i <= e[k] - intv then
                    if v == 'sound' then snd = param[k] end
                    if v == 'volume' then vol = lib.StrToNum(param[k]) end
                    if lib.text_effect[v] and lib.text_effect[v][1] == 'on_sentence_ex' and lib.text_effect[v][2] then
                        lib.text_effect[v][2](param[k])
                    end
                elseif i > e[k] - intv then
                    snd = default_snd
                    vol = default_vol
                    if lib.text_effect[v] and lib.text_effect[v][1] == 'on_sentence_ex' and lib.text_effect[v][3] then
                        lib.text_effect[v][3](param[k])
                    end
                end
            end
        end
        local text_slice = sp.string(newtext):Sub(1, i)
        lib.float.sentence(self, x, y, text_slice, canskip, 1, snd, vol, text, newtext)
        PlaySound(snd, vol, 0, true)
    end
    lib.float.sentence(self, x, y, newtext, canskip, t - dt, snd, vol, text, newtext)
end

----------------------------------------
--float dialog multi_sentence

--多句对话，适用于对话文字量大、需批量管理的场所（指私坑）
--传入intv则使用sentence_ex，否则使用普通sentence
--传参格式化的规则：
--若部分table长度不足，将用table中最后一个值补齐
--若传入非table类，将自动生成长度与text相同、其中每个值都是传入值的table
--若不传参数或传入nil，将自动生成长度与text相同、其中每个值都是默认值的table
--若传入'default'或传入的表中有值为'default'，则自动替换为对应的默认值
---float批量对话语句
---@param self lstg.GameObject @对话所属的boss
---@param x table|number @对话框左上角x坐标（ui系）
---@param y table|number @对话框左上角y坐标（ui系）
---@param text table|string|number @对话内容
---@param canskip table|boolean @是否可跳过
---@param t table|number @对话时长
---@param intv table|number @每帧显示字符数
---@param snd table|string @对话语音
---@param vol table|number @对话语音音量
---@param start_pos number @对话起始位置
---@param end_pos number @对话结束位置
function lib.float.multi_sentence(self, x, y, text, canskip, t, intv, snd, vol, start_pos, end_pos)
    local IsEX
    if intv then IsEX = true end
    if type(text) ~= 'table' then text = { text } end
    local default_param = { screen.width / 8, screen.height / 2, '', true, 60, 1, 'plst00', 0.35 } --默认参数表
    local param = { x, y, text, canskip, t, intv, snd, vol } --传入参数表
    --格式化参数，确保每个参数都是长度与text相同的表
    start_pos = start_pos or 1
    end_pos = end_pos or #text
    for i = 1, 8 do
        param[i] = lib.MakeParamList(param[i], #text, default_param[i])
    end
    --批量输出对话
    --我也不想这么写，但每个参数都要读取对应的表所以没法直接unpack
    for i = start_pos, end_pos do
        if IsEX then
            lib.float.sentence_ex(self, param[1][i], param[2][i], param[3][i], param[4][i], param[5][i], param[6][i], param[7][i], param[8][i])
        else
            lib.float.sentence(self, param[1][i], param[2][i], param[3][i], param[4][i], param[6][i], param[7][i], param[8][i])
        end
    end
end

----------------------------------------
--float dialog multi_sentence_ex

--效果同上，但强制使用sentence_ex
--用这个的话可以不用传一大堆nil就能用sentence_ex
---float批量对话语句ex
---@param self lstg.GameObject @对话所属的boss
---@param x number @对话框左上角x坐标（ui系）
---@param y number @对话框左上角y坐标（ui系）
---@param text table|string|number @对话内容
---@param canskip table|boolean @是否可跳过
---@param t table|number @对话时长
---@param intv table|number @每帧显示字符数
---@param snd table|string @对话语音
---@param vol table|number @对话语音音量
---@param start_pos number @对话起始位置
---@param end_pos number @对话结束位置
function lib.float.multi_sentence_ex(self, x, y, text, canskip, t, intv, snd, vol, start_pos, end_pos)
    if type(text) ~= 'table' then text = { text } end
    local default_param = { screen.width / 8, screen.height / 2, '', true, 60, 1, 'plst00', 0.35 } --默认参数表
    local param = { x, y, text, canskip, t, intv, snd, vol } --传入参数表
    --格式化参数，确保每个参数都是长度与text相同的表
    start_pos = start_pos or 1
    end_pos = end_pos or #text
    for i = 1, 8 do
        param[i] = lib.MakeParamList(param[i], #text, default_param[i])
    end
    --批量输出对话
    --我也不想这么写，但每个参数都要读取对应的表所以没法直接unpack
    for i = start_pos, end_pos do
        lib.float.sentence_ex(self, param[1][i], param[2][i], param[3][i], param[4][i], param[5][i], param[6][i], param[7][i], param[8][i])
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------
---通用function与class

---文字对齐格式
---当然不习惯的话也可以用RenderTTF的对齐
local align_f = {
    [0] = function(w, h)
        return 0, -h / 2
    end,
    [1] = function(w, h)
        return -w / 2, -h / 2
    end,
    [2] = function(w, h)
        return -w, -h / 2
    end,
    [4] = function(w, h)
        return 0, 0
    end,
    [5] = function(w, h)
        return -w / 2, 0
    end,
    [6] = function(w, h)
        return -w, 0
    end,
    [8] = function(w, h)
        return 0, h / 2
    end,
    [9] = function(w, h)
        return -w / 2, h / 2
    end,
    [10] = function(w, h)
        return -w, h / 2
    end,
}

---从boss_dialog搬过来的TTFDrawer（文字渲染器）
---选择它的原因是由于它是逐字渲染，正好适用文字效果
lib.TTFDrawer = plus.Class()
function lib.TTFDrawer:init(str, master, balloon)
    self.spstring = sp.string(str)
    self.line = self:getLine()
    self.master = master
    self.balloon = balloon
    if balloon then self.b_scale = balloon.balloon_scale end
end

function lib.TTFDrawer:set(str)
    self.spstring:Set(str)
    self.line = self:getLine()
end

function lib.TTFDrawer:getLine()
    local line = 1
    for _, c in ipairs(self.spstring.string) do
        if c == "\n" then
            line = line + 1
        end
    end
    return line
end

function lib.TTFDrawer:render(font, x1, x2, y1, y2, cw, ch, dx, dy, scale, color, align, _align, ...)
    cw, ch = cw * scale / 2, ch * scale / 2
    local s = self.spstring.string
    local w = self.spstring:GetLength() * cw
    local h = ch * self.line
    local _w, _h = align_f[align](w, h)
    local _align = _align or "center"
    local _x1, _x2, _y1, _y2 = x1 + _w, x2 + _w, y1 + _h, y2 + _h
    local line = 0
    local n
    dx, dy = dx / 2, dy / 2
    local text, flag, param, st, e
    if self.master.rawtext then
        text, flag, param, st, e = lib.MultiGetTextEffect(self.master.rawtext)
    end
    local default_font = font
    local default_scale = scale
    local default_color = color
    local count = 0
    ----------------------------------------
    if flag then
        for k, v in ipairs(flag) do
            if lib.text_effect[v] and lib.text_effect[v][1] == 'before_shader' and lib.text_effect[v][2] then
                lib.text_effect[v][2](param[k])
            end
            if v == 'shader' and lstg.tmpvar.TextEffect_RT_Created then
                PushRenderTarget('TextEffect_RenderTarget')
                RenderClear(Color(0, 0, 0, 0))
            end
        end
    end
    ----------------------------------------
    for i = 1, #s do
        count = count + 1
        if flag then
            for k, v in ipairs(flag) do
                if i == st[k] then
                    if v == 'font' then font = param[k] end
                    if v == 'scale' then
                        scale = lib.StrToNum(param[k])
                        if self.balloon then
                            self.balloon.balloon_scale = max(self.b_scale,
                                default_scale + (scale - default_scale) / 2)
                        end
                    end
                    if v == 'color' then color = Color(lib.StrToNum(param[k])) end
                    if v == 'Color' then
                        color = Color(lib.StrToNum(param[k][1]), lib.StrToNum(param[k][2]),
                            lib.StrToNum(param[k][3]), lib.StrToNum(param[k][4]))
                    end
                    if lib.text_effect[v] and lib.text_effect[v][1] == 'before_render' and lib.text_effect[v][2] then
                        lib.text_effect[v][2](param[k])
                    end
                elseif i == e[k] + 1 then
                    ---在没有下一个相同文字效果时才复原
                    if not aic.table.Search(flag, v, false, nil, k + 1) then
                        if v == 'font' then
                            font = default_font
                        end
                        if v == 'scale' then
                            scale = default_scale
                        end
                        if v == 'color' or v == 'Color' then
                            color = default_color
                        end
                        if lib.text_effect[v] and lib.text_effect[v][1] == 'before_render' and lib.text_effect[v][3] then
                            lib.text_effect[v][3](param[k])
                        end
                    end
                end
            end
        end
        ----------------------------------------
        --[[for k, v in ipairs(flag) do
            if v == 'shader' then
                PushRenderTarget('TextEffect_RenderTarget')
                RenderClear(Color(0, 0, 0, 0))
            end
        end]]
        ----------------------------------------
        if s[i] == "\n" then
            line = line + 1
            _x1 = x1 + _w
            _x2 = x2 + _w
            _y1 = y1 + _h - ch * line
            _y2 = y2 + _h - ch * line
        else
            n = #s[i] > 1
            if n then
                _x1 = _x1 + (cw + dx) * scale
                _x2 = _x2 + (cw + dx) * scale
            else
                _x1 = _x1 + (cw / 2 + dx) * scale
                _x2 = _x2 + (cw / 2 + dx) * scale
            end
            _y1 = _y1 + dy
            _y2 = _y2 + dy
            local shax, shay, scay = 0, 0, 0
            if flag then
                for k, v in ipairs(flag) do
                    if v == 'shake' and i >= st[k] and i < e[k] then
                        shax = ran:Float(0, lib.StrToNum(param[k]))
                        shay = ran:Float(0, lib.StrToNum(param[k]))
                    end
                    if v == 'scale' and i >= st[k] and i < e[k] then
                        scay = ch * (scale - default_scale)
                    end
                    if v == 'uppertext' and i == st[k] then
                        --属实是把spstring玩出花来了（要确定中心位置真的不容易）
                        local upx = cw * ((sp.string(sp.string(self.master.fulltext):Sub(st[k], e[k])):GetLength()) / 2 - 1)
                        if not self.balloon then
                            RenderTTF2(font, param[k], _x1 + upx, _x2 + upx, _y1 + scale * 10, _y2 + scale * 10,
                                scale * 0.6, color, 'centerpoint')
                        elseif self.balloon.n == int(self.balloon.n) then
                            RenderTTF2(font, param[k], _x1 + upx, _x2 + upx, _y1 + scale * 5, _y2 + scale * 5,
                                scale * 0.6, color, 'centerpoint')
                        end
                        if self.balloon then self.balloon.balloon_scale = self.b_scale + scale * 5 / ch end
                    end
                    if v == 'Uppertext' and i == st[k] then
                        --属实是把spstring玩出花来了（要确定中心位置真的不容易）
                        local upx = cw * ((sp.string(sp.string(self.master.fulltext):Sub(st[k], e[k])):GetLength()) / 2 - 1)
                        if not self.balloon then
                            RenderTTF2(font, param[k][1], _x1 + upx + lib.StrToNum(param[k][2]), _x2 + upx + lib.StrToNum(param[k][2]),
                                _y1 + scale * 10 + lib.StrToNum(param[k][3]), _y2 + scale * 10 + lib.StrToNum(param[k][3]),
                                scale * 0.6, color, 'centerpoint')
                        elseif self.balloon.n == int(self.balloon.n) then
                            RenderTTF2(font, param[k][1], _x1 + upx + lib.StrToNum(param[k][2]), _x2 + upx + lib.StrToNum(param[k][2]),
                                _y1 + scale * 5 + lib.StrToNum(param[k][3]), _y2 + scale * 5 + lib.StrToNum(param[k][3]),
                                scale * 0.6, color, 'centerpoint')
                        end
                        if self.balloon then self.balloon.balloon_scale = self.b_scale + scale * 5 / ch end
                    end
                end
            end
            RenderTTF2(font, s[i], _x1 + shax, _x2 + shax, _y1 + shay + scay, _y2 + shay + scay, scale, color, _align, ...)
            if n then
                _x1 = _x1 + (cw + dx) * scale
                _x2 = _x2 + (cw + dx) * scale
            else
                _x1 = _x1 + (cw / 2 + dx) * scale
                _x2 = _x2 + (cw / 2 + dx) * scale
            end
            _y1 = _y1 + dy
            _y2 = _y2 + dy
        end
        if flag then
            for k, v in ipairs(flag) do
                --[[
                if v == 'shader' and i >= st[k] and (i >= e[k] or i == #s) then
                    PopRenderTarget()
                    lib.PostEffect('TextEffect_RenderTarget', param[k])
                end]]
                if i == st[k] then
                    if lib.text_effect[v] and lib.text_effect[v][1] == 'after_render' and lib.text_effect[v][2] then
                        lib.text_effect[v][2](param[k])
                    end
                elseif i == e[k] + 1 then
                    if lib.text_effect[v] and lib.text_effect[v][1] == 'after_render' and lib.text_effect[v][3] then
                        lib.text_effect[v][3](param[k])
                    end
                end
            end
        end
    end
    ----------------------------------------
    if flag then
        for k, v in ipairs(flag) do
            if v == 'shader' and lstg.tmpvar.TextEffect_RT_Created then
                PopRenderTarget()
                lib.PostEffect('TextEffect_RenderTarget', param[k])
            end
            if lib.text_effect[v] and lib.text_effect[v][1] == 'after_shader' and lib.text_effect[v][2] then
                lib.text_effect[v][2](param[k])
            end
        end
    end
    ----------------------------------------
end

---对话角色
---改进（不）自EVA（v1.0）
---@class lib.character
lib.character = Class(object)
local character = lib.character
function character:init(img, pos, x, y, vs, hs, num, layer)
    self.layer = layer or LAYER_TOP + 9
    self.default_layer = self.layer
    self.bound = false
    self.pos = pos
    self.x, self.y = x, y
    self.vs = vs or 1
    self.hs = hs or pos
    self.rot = 0
    self.img = img
    self.t = 0
    self.act = true
    self.death = 0
    self.vscale = self.vs
    self.hscale = self.hs
    self.cnm = 0   --为了同时提供上升与下降两种函数式0v0
    self.alpha = 0 --立绘还是透明淡入比较好...
    self.num = num
end

function character:frame()
    task.Do(self)
    local v = 1.25                               --移动速率
    if self.act then
        self.layer = self.default_layer          -- + self.num
        self.t = min(self.t + v, 16)
        self.cnm = sin((self.t) * (90 / 16)) ^ 2 --阿塔拉希no函数式，我爽了你呢
    else
        self.layer = self.default_layer - 1      -- + self.num
        self.t = max(self.t - v, 0)
        self.cnm = sin((self.t) * (90 / 16)) ^ 2
    end
    self.alpha = sin(min(self.timer * (90 / 10), 90))
end

function character:render()
    SetViewMode "ui"
    local move_dis = 32
    local dead_dis = 32
    local x, y = self.x, self.y
    local dc = 80 --下降转暗的颜色值
    local alpha = 255 * self.alpha
    if self.pos == 1 then
        local t = self.cnm --函数式改变
        SetImageState(self.img, "",
            Color(alpha, dc, dc, dc) + t * Color(alpha, 255 - dc, 255 - dc, 255 - dc) -
            (self.death / 30) * Color(0xFF000000))
        local t1 = sin(self.death * 3)
        Render(self.img, x + t * move_dis - dead_dis * t1, y + t * 16 - dead_dis * t1, 0, self.hscale, self.vscale) --self.death*12是什么沙雕，丑死了（
    else
        local t = self.cnm                                                                                          --函数式改变
        SetImageState(self.img, "",
            Color(alpha, dc, dc, dc) + t * Color(alpha, 255 - dc, 255 - dc, 255 - dc) -
            (self.death / 30) * Color(0xFF000000))
        local t1 = sin(self.death * 3)
        Render(self.img, x - t * move_dis + dead_dis * t1, y + t * 16 - dead_dis * t1, 0, self.hscale, self.vscale)
    end
    SetViewMode "world"
end

function character:del()
    PreserveObject(self)
    task.New(self, function()
        for i = 1, 30 do
            self.death = i
            task.Wait()
        end
        RawDel(self)
    end)
end

---boss系对话气泡
---@class lib.balloon
---@return lib.balloon
lib.balloon = Class(object)
local balloon = lib.balloon
function balloon:init(master, x, y, hpos, vpos, pic, text, n, balloon_blend, balloon_co, text_co, text_scale)
    self.layer = LAYER_TOP + 233 --无上至尊（啥
    self.master = master
    self.x, self.y = x, y
    self.bound = false
    self.alpha = 255
    self.blend = balloon_blend
    self.balloon_co = balloon_co
    self.text_co = text_co
    self.scale = text_scale
    self.balloon_scale = self.scale
    self.hpos = hpos
    if self.hpos == 2 then
        self.hpos = -1
    end
    self.vpos = vpos
    if self.vpos == 2 then
        self.vpos = -1
    end
    self.pic = ((pic or 1) - 1) % 4 + 1
    self.text = text
    self.ttfdrawer = lib.TTFDrawer(self.text, self.master, self)
    self.d = string.find(text, string.format("\n"), 1) --本来想给boss系对话扩充一下行数……可是气泡素材似乎只支持两行，这就没办法了
    if self.d then
        self.text1, self.text2 = string.match(text, "^(.+)\n(.+)$")
        if not self.text1 then
            self.text1 = ''
            self.hide = true
        end
        if not self.text2 then
            self.text2 = ''
            self.hide = true
        end --防止sentence_ex的截取导致\n后没东西
        local l1, l2 = sp.string(self.text1):GetLength(), sp.string(self.text2):GetLength()
        self.l = max(l1, l2)
        self.pic = self.pic + 4
    else
        self.l = sp.string(text):GetLength()
    end
    self.l = max(3, self.l)
    self.tx = self.l * 16
    self.n = n or 1
    self.imgs = {
        'balloonHead' .. self.pic,
        'balloonBody' .. self.pic,
        'balloonTail' .. self.pic,
    }
    self.lbs = {} --这玩意为啥没用上……
    local xx = self.x + 7 * self.hpos
    if self.hpos < 0 then
        xx = xx - self.l
    end
    self.n_body = int(max(0, self.l - 3) / 2) + 1
    self.x_target = { 26 * self.hpos }
    xx = self.x_target[1]
    for _ = 1, self.n_body do
        xx = xx + 16 * self.hpos
        table.insert(self.x_target, xx)
    end
end

function balloon:frame()
    --[[local t = min(self.timer, 10)
    self.scale = t / 10]]
    --为了sentence_ex调用，这里放弃了气泡逐渐变大的效果
    self.ttfdrawer:set(self.text)
    if self.n <= 0 then
        Del(self)
    end
end

function balloon:render()
    SetImageState(self.imgs[1], self.blend, self.balloon_co)
    SetImageState(self.imgs[2], self.blend, self.balloon_co)
    SetImageState(self.imgs[3], self.blend, self.balloon_co)
    local x, y = self.x + 8, self.y
    local hscale = self.hpos / 2 * self.balloon_scale
    local vscale = self.vpos / 2 * self.balloon_scale
    SetViewMode "ui"
    Render(self.imgs[1], self.x, self.y, 0, hscale, vscale)
    Render(self.imgs[3], self.x + self.x_target[#self.x_target] * self.balloon_scale, self.y, 0, hscale, vscale)
    for i = 1, self.n_body do
        Render(self.imgs[2], self.x + self.x_target[i] * self.balloon_scale, self.y, 0, hscale, vscale)
    end
    if self.hpos < 0 then
        x = self.x + (self.x_target[self.n_body] - 16) * self.balloon_scale
    end
    if self.vpos > 0 then
        y = y - 22 * self.balloon_scale
    else
        y = y + 40 * self.balloon_scale
    end
    y = y - 25 * (self.balloon_scale - 1) --暴力调参，但有效
    local co = { self.text_co:ARGB() }
    co[1] = min(co[1], self.alpha)
    self.ttfdrawer:render("balloon_font",
        x, x, y, y, 16, 32, 0, 0,
        self.scale, Color(unpack(co)), 4)
    SetViewMode "world"
end

---middle系对话气泡
---@class lib.ballon_middle
---@return lib.ballon_middle
lib.ballon_middle = Class(object)
local ballon_middle = lib.ballon_middle
function ballon_middle:init(master, x, y, vpos, pic, text, n, balloon_blend, balloon_co, text_co, text_scale)
    self.layer = LAYER_TOP + 233 --无上至尊（啥
    self.master = master
    self.x, self.y = x, y
    self.bound = false
    self.alpha = 255
    self.blend = balloon_blend
    self.balloon_co = balloon_co
    self.text_co = text_co
    self.scale = text_scale
    self.balloon_scale = self.scale
    --因为middle系不分左右，所以没有hpos了
    self.vpos = vpos
    if self.vpos == 2 then
        self.vpos = -1
    end
    self.midpic = ((pic or 1) - 1) % 2 + 1
    self.pic = ((pic or 1) - 1) % 4 + 1
    self.text = text
    self.ttfdrawer = lib.TTFDrawer(self.text, self.master, self)
    self.d = string.find(text, string.format("\n"), 1)
    if self.d then
        self.text1, self.text2 = string.match(text, "^(.+)\n(.+)$")
        if not self.text1 then
            self.text1 = ''
            self.hide = true
        end
        if not self.text2 then
            self.text2 = ''
            self.hide = true
        end --防止sentence_ex的截取导致\n后没东西
        local l1, l2 = sp.string(self.text1):GetLength(), sp.string(self.text2):GetLength()
        self.l = max(l1, l2)
        self.midpic = self.midpic + 2
        self.pic = self.pic + 4
    else
        self.l = sp.string(text):GetLength()
    end
    self.l = max(10, self.l) --由于某些奇妙问题，middle气泡在长度小于10时就会出问题
    self.tx = self.l * 16
    self.n = n or 1
    --哦我的上帝啊你绝对找不出来比这更地才的写法
    if (self.pic > 2 and self.pic < 5) or (self.pic > 6 and self.pic < 9) then self.pic = self.pic - 2 end
    self.imgs = {
        'balloonMiddle' .. self.midpic,
        'balloonBody' .. self.pic,
        'balloonTail' .. self.pic,
    }
    self.lbs = {} --这玩意为啥没用上……
    local xx = self.x + 7
    self.n_body = int(max(0, self.l - 3) / 2) + 1
    self.n_left = self.n_body - int(self.n_body / 2)
    self.n_right = self.n_body - self.n_left
    self.x_target = { 26 }
    xx = 26
    for _ = 1, self.n_left do
        xx = xx - 16
        table.insert(self.x_target, 1, xx)
    end
    xx = 26
    for _ = 1, self.n_right do
        xx = xx + 16
        table.insert(self.x_target, xx)
    end
end

function ballon_middle:frame()
    --[[local t = min(self.timer, 10)
    self.scale = t / 10]]
    --为了sentence_ex调用，这里放弃了气泡逐渐变大的效果
    self.ttfdrawer:set(self.text)
    if self.n <= 0 then
        Del(self)
    end
end

function ballon_middle:render()
    SetImageState(self.imgs[1], self.blend, self.balloon_co)
    SetImageState(self.imgs[2], self.blend, self.balloon_co)
    SetImageState(self.imgs[3], self.blend, self.balloon_co)
    local x, y = self.x + 8, self.y
    local hscale = 1 / 2 * self.balloon_scale
    local vscale = self.vpos / 2 * self.balloon_scale
    SetViewMode 'ui'
    for i = 1, self.n_body do
        Render(self.imgs[2], self.x + self.x_target[i] * self.balloon_scale, self.y, 0, hscale, vscale)
    end
    Render(self.imgs[3], self.x + self.x_target[1] * self.balloon_scale, self.y, 0, -hscale, vscale)
    Render(self.imgs[3], self.x + self.x_target[#self.x_target] * self.balloon_scale, self.y, 0, hscale, vscale)
    Render(self.imgs[1], self.x, self.y, 0, hscale, vscale)
    if self.vpos > 0 then
        y = y - 22 * self.balloon_scale
    else
        y = y + 40 * self.balloon_scale
    end
    y = y - 25 * (self.balloon_scale - 1) --暴力调参，但有效
    x = x + 14 * self.balloon_scale       --梅开二度，这次是为了middle气泡的偏差
    y = y - 8 * self.balloon_scale
    if self.d then                        --两行文字的位置还是有问题
        x = x + (4 * self.l - 18) * self.balloon_scale
        y = y - 8 * self.balloon_scale
    end
    local co = { self.text_co:ARGB() }
    co[1] = min(co[1], self.alpha)
    self.ttfdrawer:render("balloon_font",
        x, x, y, y, 16, 32, 0, 0,
        self.scale, Color(unpack(co)), 9, 'centerpoint')
    SetViewMode 'world'
end

-------------------------------------------------------
---from RT基础教程，坐标系转换
---@param x number @原x坐标
---@param y number @原y坐标
---@param from string @原坐标系，可选'world'|'ui'|'uv'
---@param to string @转换后坐标系，可选'world'|'ui'|'uv'
---@return number,number @转换后x，y坐标
function lib.PosTrans(x, y, from, to)
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
    x, y = lib.PosTrans(x, y, from, "ui")
    return lib.PosTrans(x, y, "ui", to)
end

---将string类型的数字转换为number
---用了这么久lua不知道有tonumber这玩意，我是傻逼
---@param str string @要转换的数字（string）
---@return number @转换后的数字（number）
function lib.StrToNum(str)
    ---随机数支持
    if string.match(str, 'ranF') then
        local s, e = string.match(str, 'ranF%((%d+)~(%d+)%)')
        return ran:Float(s, e)
    elseif string.match(str, 'ranI') then
        local s, e = string.match(str, 'ranI%((%d+)~(%d+)%)')
        return ran:Int(s, e)
    elseif string.match(str, 'ranS%(%)') then
        return ran:Sign()
    end
    return tonumber(str)
end

---将非ascii文字转换为下划线，保证string.find获取的索引为字符数位置
---@param str string @要转换的字符串
---@return string @转换后的字符串
function lib.SpstringTrans(str)
    local t, _ = string.gsub(str, '[^%w%x%z%p%s%c]', '#')
    t, _ = string.gsub(t, '###', '_')
    return t
end

---转换string类型的table
---特殊操作：使用/n可以将指定参数转换为数字
---@param param string @转换前的table（string）
---@return table @转换后的table（table）
function lib.UnpackParamList(param)
    local _, n = string.gsub(param, ',', '')
    local pattern = '(.+)'
    if n > 0 then pattern = '{' .. string.rep('(.+),', n) .. '(.+)}' end
    param = { string.match(param, pattern) }
    for k, v in ipairs(param) do
        if string.match(v, '/n.+') then
            param[k] = lib.StrToNum(string.match(v, '/n(.+)'))
        end
    end
    return param
end

---获取文本中文字效果
---需要注意这里返回的参数是string类型，位置是以字符数计算的（无论是ascii字符还是非ascii字符统一按一个计算）
---@param text string @传入的文本
---@return string, string[], string[], number[], number[]@返回删去文字效果后的文本，文字效果类型，参数，文字效果起始与终止位置
function lib.GetTextEffect(text)
    --字符串处理函数
    local match, find = string.match, string.find
    local GetCharCount, Filter, SpstringTrans = aic.string.GetCharCount, aic.string.Filter, lib.SpstringTrans
    --三个匹配串，分别为左侧、左侧参数、右侧
    local p1, p2 = '<%w+ .->', '<(%w+) (.-)>'
    if match(text, p1) then
        local p3 = '</' .. match(text, p2) .. '>'
        --获取文字效果类型和参数
        local flag, param = match(text, p2)
        --检测到flag大写时自动解包参数列表
        if match(flag, '%u') then
            param = lib.UnpackParamList(param)
        end
        --左侧部分
        local l = match(text, p1)
        --右侧部分
        local r = match(text, p3)
        --左侧与右侧始末位置
        local sl, el, sr, er = 0, 0, GetCharCount(text), GetCharCount(text)
        sl, el = find(SpstringTrans(text), p1)
        local temp = Filter(text, p1)
        if r then
            sr, er = find(SpstringTrans(temp), p3)
            text = Filter(temp, r)
        else
            text = temp
        end
        --左侧部分长度
        local len = GetCharCount(l)
        el = el + 1 - len
        --处理没有右侧部分的情况
        if r then
            sr = sr - 1 
        else
            sr = sr - len 
        end
        --兼容多文字效果
        flag = { flag }
        param = { param }
        el = { el }
        sr = { sr }
        return text, flag, param, el, sr
    end
    return text
end

---第二版MultiGetTextEffect，只能处理不重叠的多个文字效果
---如果需要使用重叠的文字效果，需要使用extend，具体写法见开头介绍
---@param text string @传入的文本
---@return string, string[], string[], number[], number[] @返回删去文字效果后的文本，文字效果类型，参数，文字效果起始与终止位置
function lib.MultiGetTextEffect(text)
    --字符串处理函数
    local match, gmatch = string.match, string.gmatch
    local Filter, SpstringTrans = aic.string.Filter, lib.SpstringTrans
    --表处理函数
    local insert = table.insert
    --文字效果，参数，左侧末位标，右侧始位标（这两个组成文字效果生效范围），左侧始位标，右侧始位标（这两个组成整个文字效果处理前范围）
    local temp = { flag = {}, param = {}, el = {}, sr = {}, sl = {}, er = {}, extend = {} }
    --删去文字效果后的文本，文字效果类型，参数，文字效果起始与终止位置
    local ret = { '', {}, {}, {}, {} }
    --预处理传入文本
    local trans_text = SpstringTrans(text)

    --文字效果类型与参数需要在预处理前的文本中寻找
    for flag, param in gmatch(text, '<(%w+) (.-)>') do
        insert(temp.flag, flag)
        if match(flag, '%u') then
            param = lib.UnpackParamList(param)
        end
        insert(temp.param, param)
    end

    --进行匹配（我不打算解释匹配串了，自己看）
    local function search(text)
        for sl, flag, el, content, sr, extend, er in gmatch(text, '()<(%w+) .-()>(.-)()</%2 ?(%d?%d?)()>') do
            insert(temp.sl, sl)
            insert(temp.el, el)
            insert(temp.sr, sr)
            insert(temp.extend, extend)
            --大写时范围有误差
            if match(flag, '%u') then
                er = er - 1
            end
            insert(temp.er, er)
            if match(content, '<(%w+) .->.-</%1>') then
                search(content)
            end
        end
    end
    
    search(trans_text)

    --小于等于一个文字效果时跳回GetTextEffect
    if #temp.sl <= 1 then return lib.GetTextEffect(text) end

    --尝试支持一下最后一个文字效果省略结尾的情况（试了一下应该是问题不大
    local sl, el, sr = match(trans_text, '()<%w+ .-()>.-()', temp.er[#temp.er])
    if sl then
        insert(temp.sl, sl)
        insert(temp.el, el)
        insert(temp.sr, sr)
        insert(temp.er, sr)
    end

    --重点来了，处理文字效果真实位置
    --想得我脑袋爆炸

    --处理文字效果重叠的情况
    for i = 1, #temp.sl do
        --返回值
        local flag, param, s, e = temp.flag[i], temp.param[i], temp.el[i], temp.sr[i]
        local temps, tempe = s, e

        --遍历其他文字效果，如果其他文字效果在s前面则减去对应长度，e同理
        for j = 1, #temp.sl do
            if i ~= j then
                local sl, el, sr, er = temp.sl[j], temp.el[j], temp.sr[j], temp.er[j]
                --左侧长度
                local lenl = el - sl + 1
                --右侧长度
                local lenr = er - sr + 1
                --减去对应长度
                if IsIn(el, 1, temps) then
                    s = s - lenl
                end
                if IsIn(sr, 1, temps) then
                    s = s - lenr
                end
                if IsIn(el, 1, tempe) then
                    e = e - lenl
                end
                if IsIn(sr, 1, tempe) then
                    e = e - lenr
                end
            end
        end

        --处理自身文字效果长度
        local lenl = temp.el[i] - temp.sl[i] + 1
        s = s + 1 - lenl
        --处理没有右侧部分的情况
        if temp.sr[i] == temp.er[i] then
            e = e - 1 
        else
            e = e - lenl
        end
        --加上扩展部分
        e = e + (tonumber(temp.extend[i]) or 0)

        --塞进返回值表里
        insert(ret[2], flag)
        insert(ret[3], param)
        insert(ret[4], s)
        insert(ret[5], e)
    end

    --删去文字效果（注意：只要是写在<>里的文字都会被删！即使没识别成文字效果也是一样！）
    local t = Filter(text, '<.->')
    ret[1] = t

    return unpack(ret)
end

---设置文字效果所需调用shader的参数列表和混合模式
---@param paramlist table 参数列表
---@param blend string 混合模式
function lib.SetPostEffectParam(paramlist, blend)
    lib.shader_paramlist = paramlist
    lib.shader_blend = blend or ''
end

---从极坐标背景工程里薅过来的版本判断
---@return boolean @当前引擎版本是否为LuaSTGSub
function lib.IsLuaSTGSub()
    if lstg.GetVersionName then
        if string.find(lstg.GetVersionName(), "LuaSTG Sub") then
            return true
        end
    else
        return false
    end
end

---文字效果用的shader，会自动判断版本
---@param rendertarget_name string @rendertarget名称
---@param shader_name string @shader名称
function lib.PostEffect(rendertarget_name, shader_name)
    if lib.IsLuaSTGSub() then
        PostEffect(
        -- 着色器资源名称
            shader_name,
            -- 屏幕渲染目标，采样器类型
            rendertarget_name, 6,
            -- 混合模式
            lib.shader_blend,
            -- 浮点参数
            lib.shader_paramlist,
            -- 纹理与采样器类型参数
            {}
        )
    else
        PostEffect(rendertarget_name, shader_name, lib.shader_blend, lib.shader_paramlist)
    end
end

---传参格式化
---
---若`param`长度不足`num`，将用`param[#param]`补齐
---
---若传入非table类型的值，将自动生成长度为`num`、其中每个值都是`param`的table
---
---若`param`为**nil**，将自动生成长度为`num`、其中每个值都是`default_param`的table
---
---若传入`'default'`或传入的表中有值为`'default'`，则自动替换为`default_param`
---@param param any @传入参数
---@param num number @需要参数列长度
---@param default_param any @参数默认值
---@return any[] @格式化后的参数列
function lib.MakeParamList(param, num, default_param)
    if type(param) == 'table' then
        for k, v in ipairs(param) do
            if v == 'default' then param[k] = default_param end
        end
    elseif param == 'default' then
        param = default_param
    end
    if type(param) ~= 'table' then
        if type(param) == 'nil' then
            param = {}
            for _ = 1, num do
                table.insert(param, default_param)
            end
        else
            local temp_param = param
            param = {}
            for _ = 1, num do
                table.insert(param, temp_param)
            end
        end
    elseif #param < num then
        local temp_param = param[#param]
        for _ = 1, num - #param do
            table.insert(param, temp_param)
        end
    end
    return param
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
--备用spstring库，预防特殊情况

---@class sp.string
---@return class
lib.spstring = plus.Class()

---@param str string @要处理的字符串
function lib.spstring:init(str)
    self:Set(str)
end

---获取设置的字符串
---@return string
function lib.spstring:Get()
    return self._string
end

---设置新字符串
---@param str string @要处理的字符串
function lib.spstring:Set(str)
    self._string = str
    self.string = self:HandleString(str)
end

---将字符串按字符整理成表
---@param str string @要处理的字符串
---@return table
function lib.spstring:HandleString(str)
    local st = {}
    for utfChar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(st, utfChar)
    end
    return st
end

---获取字符数
---@return number
function lib.spstring:GetCharCount()
    return #self.string
end

---获取占位长度
---@return number
function lib.spstring:GetLength()
    local sTable = self.string
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

---获取真实长度
---@return number
function lib.spstring:GetCurrentLength()
    return string.len(self._string)
end

---截取字符串
---@param index number @始位标
---@param toindex number @末位标
---@return string
function lib.spstring:Sub(index, toindex)
    index = index or 1
    if index < 0 then
        index = self:GetLength() + index + 1
    end
    toindex = toindex or index
    if toindex < 0 then
        toindex = self:GetLength() + toindex + 1
    end
    local length = (toindex - index) + 1
    local sTable = self.string
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

---获取反转字符串
---@return string
function lib.spstring:GetReverse()
    local sTable = self.string
    local s = {}
    for i = #sTable, 1, -1 do
        table.insert(s, sTable[i])
    end
    return table.concat(s, "")
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------

return lib
