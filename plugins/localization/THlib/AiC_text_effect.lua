---@diagnostic disable-next-line: empty-block

---文字效果可以在所有对话中使用，只需在传入文本中按以下语法输入即可
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
---九、以下为目前大部分可用文字效果：
---
---<color color>text<color>
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
---<wait time>text</wait>
---在显示text的每个字符时等待time帧
