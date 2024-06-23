---=====================================
---THAIC Localization Dialog
---东方梦摇篮本土化 对话
---=====================================

--[=[
For translaters:
This is the UI text file of THAIC.
It includes all text in UI and menus (not images).
Only the contents in `""` and `[[]]` need to be translated. Change other code can lead to error.
The code in `<>` is text effect. To change text effect, see `AiC_text_effect.lua`.
给翻译者：
这是东方梦摇篮的UI文本文件。
它包括所有UI和菜单中的文字（非图片）。
只有`""`和`[[]]`中的内容需要被翻译。更改其他代码可能引发错误。
`<>`中的代码是文字效果。要更改文字效果，参见`AiC_text_effect.lua`。
--]=]

local lib = aic.l10n.ui
---音乐室文本
---Music room text
lib.music_room = {
    title = {
        "梦境彼方 摇篮仙境",
        "Wonderland of 0 & 1",
        "Star Chaser",
        "Star Rider",
        "/*死鱼眼_日照不足_往返跑部*/",
        "正午时分的妖精宴会",
        "G.H.O.S.T",
        "缥缈之风　～ Assassinatroid",
        "魔法使的祭典　～ Starry Forest",
        "森林中的未知际遇",
        "纯白之花",
        "守护之光",
        "超越空想的Stella",
        "即使已然无力回天",
        "于乐园中仰望繁星　～ Alice In Gensokyo",
        "失色的星之梦　～ Reality or Fantasy?",
        "森之意志",
        "宁静的夏夜",
        "Above Star",
        "梦醒之时",
        --以下是DLC曲目
        "DOORS_OF_MYSTERIES",
        "BACK_DANCERS",
        "INDESCRIBABLE",
        "DEEP_INTO_THE_WONDERLAND",
        "ALTERNATIVE",
        "THE_YAKUMO",
        "EYE_OF_LAPLACE",
        "LAST_DANCE",
        "VIOLET_NIGHT",
        "乐园与群星与永远之梦"
        
    },
    comment = {
        [[
            原曲：An-fillnote - タイトル
            出处：ひなゆあ/桥野水叶 - 《AliceInCradle》

            　标题画面的主题曲。

            　十分令人安心的旋律，即使没有听过也是一样。
            　※注：由于部分日语特有汉字无法显示，部分曲目与作曲者名称使用中文。
        ]],
        [[
            原曲：ginkiha - Extra stage
            出处：くろば·U - 《Star Shooter!》

            　零面道中的主题曲。

            　虽然是第一关却已经这么激烈了呢。
            　毕竟这原本是用于EX面的曲子哦。
        ]],
        [[
            原曲：ginkiha - Star Chaser! 
            出处：くろば·U - 《Star Chaser!》
            
            　本田 珠辉的主题曲。
            
            　追寻着星辰般的感觉。
            　感觉就像看见珠辉在跑跑跳跳一样呢。
        ]],
        [[
            原曲：ginkiha - The Star Hill

            　本田 珠辉的Last Spellcard主题曲。
            
            　前一首曲子的Hardcore Remix。
            　仿佛飞到群星之上俯瞰银河的感觉。
        ]],
        [[
            原曲：ginkiha - 通常ボス
            出处：くろば·U - 《Star Shooter!》
            
            　SNS部的少女们的主题曲。
            
            　让人想问“认真的吗？”的曲子。
            　虽然珠辉自己的曲子非常正常，
            　但是四个人凑到一起就变成这样，究竟是什么原因呢。
        ]],
        [[
            原曲：上海爱丽丝幻乐团 - 真夜中のフェアリ一ダンス
            出处：上海爱丽丝幻乐团 - 《妖精大战争 　～ 东方三月精》
            
            　一面道中的主题曲。
            
            　这次的时间从午夜变为了正午，情绪变得更加激昂。
            　因为是在森林中，应该不会很热吧？
            　带着前往宴会的心情全速前进吧。
        ]],
        [[
            原曲：AliceSoft - 濡羽色GUSTYWIND
            出处：AliceSoft - 《多娜多娜 一起来干坏事吧》
            
            　爱丽丝的主题曲。
            
            　虽然轻快，但是很有战斗的感觉。
            　旋律令人捉摸不透，就像爱丽丝随时可能出现在你的背后。
            　她使用的同样也不是自己的能力。
        ]],
        [[
            原曲：AliceSoft - Breakthru>>>
            出处：AliceSoft - 《多娜多娜 一起来干坏事吧》
            
            　爱丽丝的Last Spellcard主题曲。
            
            　纯粹的强敌感。
            　一刻都不能掉以轻心，否则就将被一枪毙命。
        ]],
        [[
            原曲：上海爱丽丝幻乐团 - 魔法使的忧郁
            出处：上海爱丽丝幻乐团 - 《The Grimoire of Marisa》附带CD
            
            　EX面道中的主题曲。
            
            　因为还在魔法森林，所以还在幻想乡境内。
            　理所当然地用了幻想乡的曲子。
        ]],
        [[
            原曲：ginkiha - 纺ぐ者の森(Battle)
            出处：ひなゆあ/桥野水叶 - 《AliceInCradle》
            
            　诺艾儿·柯涅尔的一阶段主题曲。
            
            　节奏十分轻快，因为诺艾儿这时还并未意识到对手有多强大。
            　听着这首曲子，就仿佛能看见笨拙地挥动着法杖的诺艾儿呢。
            　闻起来像散落的魔力。
        ]],
        [[
            原曲：ginkiha - イクシャ·ポリスタキア
            出处：ひなゆあ/桥野水叶 - 《AliceInCradle》
            
            　伊夏·波利斯塔切尔的主题曲。
            
            　慌慌张张的感觉。
            　伊夏还未从与森主的战斗中恢复，
            　即便如此，她也想为诺艾儿争取一点时间。
        ]],
        [[
            原曲：Feryquitous - は一ちゃん
            出处：くろば·U - 《Star Shooter!》
            
            　普莉姆拉的主题曲。
            
            　气氛突然变得紧张。
            　普莉姆拉身为兽人难以使用魔法战斗……
            　即便如此，她也想为诺艾儿争取一点时间。
        ]],
        [[
            原曲：Feryquitous - Unknown wisdom
            出处：くろば·U - 《Star Liner!》
            
            　诺艾儿·柯涅尔的二阶段主题曲。
            
            　诺艾儿开始全力以赴，因为背后有她要守护的人。
            　从这里开始，或许能看到诺艾儿曾见过的攻击。
            　是时候将它们如数奉还了。
        ]],
        [[
            原曲：An-fillnote - 森のヌシ
            出处：ひなゆあ/桥野水叶 - 《AliceInCradle》
            
            　圣光爆发的主题曲。
            
            　连续使用圣光爆发会对施法者的精神造成极大的损伤。
            　但诺艾儿已经没有余暇去思考后果了。
            　强烈的晕眩感撕裂着她的理智。
            　晕厥概率：412%
        ]],
        [[
            原曲：森のヌシ - 东方风Remix
            出处：BV1f8411P7fG
            
            　诺艾儿·柯涅尔的最终阶段主题曲。
            
            　极其具有幻想乡风味的曲子。
            　借助幻想的境界之力与秘匿的背后之力，最后与眼前的敌人一战吧。
            　弹幕的奥义，正是这梦幻泡影般的美丽。
            　幻想乡，又何尝不是幻想的摇篮呢。
        ]],
        [[
            原曲：Feryquitous - The Amplifier

            　诺艾儿·柯涅尔的Last Spellcard主题曲。
            
            　对诺艾儿来说，她所生活的世界无疑就是现实；
            　而对于我们来说，她的世界不过是摇篮中的幻想。
            　但是，我们真的有资格定义什么是现实吗？
            　这个问题的答案，想必各位都已了然于心。
        ]],
        [[
            原曲：watson - 森之记忆
            出处：ひなゆあ/桥野水叶 - 《AliceInCradle》
            
            　结局A的主题曲。
            
            　让人十分有安心感的曲子。
            　接下来就交给她吧。
            　「所以，请自豪地挺起胸膛吧，少女」
        ]],
        [[
            原曲：ginkiha - Title
            出处：くろば·U - 《Star Chaser!》
            
            　结局B的主题曲。
            
            　大家都回到了日常的生活。
            　但是，也许对于两个人来说，有什么发生了改变……
            　闻起来像大吉岭。
            
        ]],
        [[
            原曲：ginkiha - Staff
            出处：くろば·U - 《Star Chaser!》
            
            　Staff画面的主题曲。
            
            　在那星空之上，才是故事真正开始的地方。
            　未来的路还很长，请陪诺艾儿和爱丽丝一起走下去吧。
            　愿能再相见。
        ]],
        [[
            原曲：上海爱丽丝幻乐团 - Player Score
            出处：上海爱丽丝幻乐团 - 《东方风神录　～ Mountain of Faith》
            
            　满身疮痍的主题曲。
            
            　这次又是在哪里醒来呢？
            　小心不要太沉溺于梦境。
        ]],
        --以下是DLC曲目
        [[
            原曲：上海爱丽丝幻乐团 - 禁断之门对面，是此世还是彼世
            出处：上海爱丽丝幻乐团 - 《东方天空璋 　～ Hidden Star in Four Seasons》
            
            　七面的主题曲。
            
            　无数的门在空中闪耀着。
            　而在前方，是一片未知的紫色空间……
        ]],
        [[
            原曲：上海爱丽丝幻乐团 - Crazy Back Dancers
            出处：上海爱丽丝幻乐团 - 《东方天空璋 　～ Hidden Star in Four Seasons》
            
            　丁礼田 舞 & 尔子田 里乃的主题曲。
            
            　狂气的BGM配上狂气的弹幕。
            　不要被她们的舞蹈所迷惑，专心躲避弹幕吧。
        ]],
        [[
            原曲：上海爱丽丝幻乐团 - 秘神摩多罗　～ Hidden Star in All Seasons. & 被隐匿的四季
            出处：上海爱丽丝幻乐团 - 《东方天空璋 　～ Hidden Star in Four Seasons》
            
            　摩多罗 隐岐奈的Last Spellcard主题曲。
            
            　「见之！　闻之！　语之！
            　　秘神真正的魔力将成为你的障碍！」
        ]],
        [[
            原曲：上海爱丽丝幻乐团 - 妖妖跋扈 　～ Who done it!
            出处：上海爱丽丝幻乐团 - 《东方妖妖梦 　～ Perfect Cherry Blossom》
            
            　八面的主题曲。
            
            　高速前进的同时又高速后退着，
            　给人以这种感觉的空间中这样的曲子。
            　欢迎来到隙间。
        ]],
        [[
            25.ALTERNATIVE
            原曲：上海爱丽丝幻乐团 - 二つの世界
            出处：上海爱丽丝幻乐团 - 《东方三月精 　～ Strange and Bright Nature Deity.》附属CD

            　八云 紫的一阶段主题曲。

            　并非现世的空间中，并非现世的弹幕。
            　在不稳定区域通行时，请务必小心。
        ]],
        [[
            原曲：上海爱丽丝幻乐团 - Necro-Fantasia
            出处：上海爱丽丝幻乐团 - 《东方妖妖梦 　～ Perfect Cherry Blossom》
            
            　八云 紫的表阶段主题曲。
            
            　当你凝视屏幕的时候……最好小心背后。
            　你应该已经知道，这层界线对她来说形同虚设。
        ]],
        [[
            原曲：上海爱丽丝幻乐团 - 夜幕降临 　～ Evening Star
            出处：上海爱丽丝幻乐团 - 《东方萃梦想　～ Immaterial and Missing Power》
            
            　八云 紫的里阶段主题曲。
        ]],
        [[
            原曲：上海爱丽丝幻乐团 - 凭坐处于梦与现实之间　～ Necro-Fantasia
            出处：上海爱丽丝幻乐团 - 《东方凭依华　～ Antinomy of Common Flowers》
            
            　八云 紫的Last Spellcard主题曲。
            
            　最后的一战。
            　在超越极限的弹幕中起舞吧。
        ]],
        [[
            原曲：上海爱丽丝幻乐团 - 毕竟就算不是夜晚也有鬼怪
            出处：上海爱丽丝幻乐团 - 《七夕坂梦幻能　～ Taboo Japan Disentanglement》
            
            　Phantasm结局的主题曲。
            
            　「无论这个世界是梦境还是现实
            　　还请务必不要忘记一件事
            　　不要忘却禁忌
            　　因为在这个世上，没有地方不存在鬼怪」
        ]],
        [[
            原曲：An-fillnote - City of Grace
            出处：ひなゆあ/橋野みずは - 《AliceInCradle》

            　标题画面的主题曲（新）。

            　如同幻想乡般，群星笼罩的摇篮。
            　永远之梦，与现实也并无二致。
        ]]
        
    },
    warn1 =
    [[
        ＊＊　选择的音乐尚未在游戏进行的过程中播放过　＊＊

        　　　　　　音乐的评论可能会造成剧透，
        　　　　　　　即使那样也要播放吗？
    
        　　　　想现在播放的话，请再次按下确定键。
        不想现在播放的话，请选择其它已开启的音乐进行欣赏。
    ]],
    warn2 =
    [[
        ＊＊　选择的音乐已经在游戏进行的过程中播放过　＊＊

        　　　　　音乐的评论可能会造成流向的改变，
        　　　　　　　即使那样也要播放吗？
        
        　　　　想现在播放的话，请再次按下确定键。
        不想现在播放的话，请选择其它已开启的音乐进行欣赏。
    ]],
    --[=[
        This is chararacter source of comment of 22.EYE OF LAPLACE.
        THAIC will randomly choose characters in it to generate music comment.
        You can add or delete characters in it as you like.
        这是EYE OF LAPLACE的评论的字符来源。
        梦摇篮会随机抽取其中的字符生成音乐评论。
        你可以随意增删其中的字符。
    --]=]
    warn3 = {
        "a", "b", "c", "d", "e", "f", "g", "h", "i",
        "j", "k", "l", "m", "n", "o", "p", "q", "r",
        "s", "t", "u", "v", "w", "x", "y", "z",
    }
}
