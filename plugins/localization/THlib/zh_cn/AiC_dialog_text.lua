---=====================================
---THAIC Localization Dialog
---东方梦摇篮本土化 对话
---=====================================

--[[
For translaters:
This is the dialog file of THAIC.
Only the contents in `text` need to be translated. Change other code can lead to error.
The code in `<>` is text effect. To change text effect, see `AiC_text_effect.lua`.
给翻译者：
这是东方梦摇篮的对话文件。
只有`text`中的内容需要被翻译。更改其他代码可能引发错误。
`<>`中的代码是文字效果。要更改文字效果，参见`AiC_text_effect.lua`。
--]]

---There may be 'a little' error in multi-text-effect,
---but I believe that you can solve it(Please try to change range and extend for serveral times,you can do it lol).
---多文字效果的范围可能有一点“小”错误，
---不过我相信你们可以解决的www（多调几次范围和extend，总能试出来的）

local lib = aic.l10n.dialog

---战斗前对话
---Dialog before battle
lib.dialog1 = {
    pos = 'right',
    canskip = false,
    t = 120,
    hscale = 0.5,
    vscale = 0.5,
    vol = 1,
    name = '诺艾儿·柯涅尔',
    snd = "se:Muki_AiC_dialog_Noel",
    img = {
        "image:Muki_AiC_Noel_face_default",
        "image:Muki_AiC_Noel_face_default",
        "image:Muki_AiC_Noel_face_fight"
    },
    text = {
        '呼……好累……\n呼……',
        '呼……\n等一下，那个是……\n难道说你就是<Color {255,255,0,0}>厨圣</Color>？',
        '终于找到你了！\n之前对我做了那么多<Color {255,255,0,0}>过分的事情</Color>……',
        '<shake 3>这次我可不会坐以待毙了！ </shake>'
    }
}

---伊夏入场对话
---Ixia entering dialog
lib.dialog2 = {
    pos = 'right',
    canskip = false,
    t = 120,
    hscale = 0.5,
    vscale = 0.5,
    vol = 1,
    name = {
        '伊夏·波利斯塔切尔',
        '伊夏·波利斯塔切尔',
        '诺艾儿·柯涅尔',
        '诺艾儿·柯涅尔',
        '伊夏·波利斯塔切尔',
    },
    snd = {
        "se:Muki_AiC_dialog_Ixia",
        "se:Muki_AiC_dialog_Ixia",
        "se:Muki_AiC_dialog_Noel",
        "se:Muki_AiC_dialog_Noel",
        "se:Muki_AiC_dialog_Ixia"
    },
    img = {
        "image:Muki_AiC_Ixia_face_surprise",
        "image:Muki_AiC_Ixia_face_notworryyou",
        "image:Muki_AiC_Noel_face_smile3",
        "image:Muki_AiC_Noel_face_normal",
        "image:Muki_AiC_Ixia_face_angry",
        "image:Muki_AiC_Ixia_face_default"
    },
    text = {
        '<shake 3>诺艾儿·柯涅尔！</shake>总算找到你了！\n真是担心死……',
        '不，我才没有<Color {255,255,0,0}>很担心你！</Color>',
        '……谢谢你，伊夏同学。',
        '不过，\n你还没从那次<Color {255,255,0,0}></Color 3><uppertext 森林领主>大</uppertext>型魔物的袭击中恢复过来吧……',
        '绝对没问题！就让我来帮你解决它吧！',
        '就是你这家伙一直在欺负诺艾儿吧？\n<shake 3>我绝对不会放过你的！ </shake>'
    },
    num = { 1, 1, 2, 2, 1 }
}

---普莉姆拉入场对话
---Primula entering dialog
lib.dialog3 = {
    pos = 'right',
    canskip = false,
    t = 120,
    hscale = { 0.6, 0.6, 0.6, 0.6, 0.6, 0.5, 0.5 },
    vscale = { 0.6, 0.6, 0.6, 0.6, 0.6, 0.5, 0.5 },
    vol = 1,
    name = {
        '普莉姆拉',
        '普莉姆拉',
        '诺艾儿·柯涅尔',
        '普莉姆拉',
        '普莉姆拉',
        '伊夏·波利斯塔切尔',
        '诺艾儿·柯涅尔',
    },
    snd = {
        "se:Muki_AiC_dialog_Primula",
        "se:Muki_AiC_dialog_Primula",
        "se:Muki_AiC_dialog_Noel",
        "se:Muki_AiC_dialog_Primula",
        "se:Muki_AiC_dialog_Primula",
        "se:Muki_AiC_dialog_Ixia",
        "se:Muki_AiC_dialog_Noel",
    },
    img = {
        "image:Muki_AiC_Primula_face_fight",
        "image:Muki_AiC_Primula_face_fight",
        "image:Muki_AiC_Noel_face_understand",
        "image:Muki_AiC_Primula_face_fight",
        "image:Muki_AiC_Primula_face_fight",
        "image:Muki_AiC_Ixia_face_notworryyou",
        "image:Muki_AiC_Noel_face_thinking",
    },
    text = {
        '诺艾儿！\n怎么可以独自一人来挑战这种<Color {255,255,0,0}></Color 3><uppertext 厨圣>大</uppertext>型魔物呢！',
        '还有伊夏！\n你们先撤退，这里老师来想办法！',
        '可是老师……\n您不是不能战斗吗？',
        '「只要能打中它就行了！」\n<Color {255,255,0,255}>那位女士</Color>是这么说的……',
        '如果是这样的话，\n老师对自己的准头还是有信心的！',
        '<scale 0.75>诺艾儿……就这样丢下老师也不好……\n我们先躲起来观察情况吧。</scale>',
        '<scale 0.75>嗯。</scale>',
    },
    num = { 1, 1, 2, 1, 1, 3, 2 }
}

---获取魔法前对话
---Dialog before getting magic
lib.dialog4 = {
    pos = 'right',
    canskip = false,
    t = 120,
    hscale = { 0.6, 0.5, 0.6, 0.5, 0.6 },
    vscale = { 0.6, 0.5, 0.6, 0.5, 0.6 },
    vol = 1,
    name = {
        '普莉姆拉',
        '伊夏·波利斯塔切尔',
        '普莉姆拉',
        '诺艾儿·柯涅尔',
        '普莉姆拉'
    },
    snd = {
        "se:Muki_AiC_dialog_Primula",
        "se:Muki_AiC_dialog_Ixia",
        "se:Muki_AiC_dialog_Primula",
        "se:Muki_AiC_dialog_Noel",
        "se:Muki_AiC_dialog_Primula",
        "se:Muki_AiC_dialog_Primula",
        "se:Muki_AiC_dialog_Primula",
        "se:Muki_AiC_dialog_Primula",
        "se:Muki_AiC_dialog_Noel"
    },
    img = {
        "image:Muki_AiC_Primula_face_fight",
        "image:Muki_AiC_Ixia_face_surprise",
        "image:Muki_AiC_Primula_face_surprise",
        "image:Muki_AiC_Noel_face_lose",
        "image:Muki_AiC_Primula_face_teach3",
        "image:Muki_AiC_Primula_face_teach",
        "image:Muki_AiC_Primula_face_teach2",
        "image:Muki_AiC_Primula_face_memory",
    },
    text = {
        '不行……\n这个区域的空气中的<uppertext MP></uppertext 1><Color {255,170,160,247}>魔</Color>力基本消耗完了……',
        '老师！您还好吗？',
        '<shake 3>诺艾儿和伊夏？</shake>\n我不是叫你们赶紧走吗？',
        '我们没法把您丢在这里不管……',
        '算了……\n我还有最后一招。',
        '刚才路上有一位女士给了我这个……\n似乎是<Color {255,255,0,0}>非官方魔法认证装置。</Color>',
        '它的认证手续没有那么复杂，\n但同时也只能提供<Color {255,255,0,0}>临时认证</Color>。',
        '不过用来完成这场战斗应该是足够了……\n诺艾儿同学，现在只能靠你了。\n我先带伊夏同学到安全的地方。',
    }
}

---获取魔法后对话
---Dialog after getting magic
lib.dialog5 = {
    pos = 'right',
    canskip = false,
    t = 120,
    hscale = 0.5,
    vscale = 0.5,
    vol = 1,
    name = '诺艾儿·柯涅尔',
    snd = "se:Muki_AiC_dialog_Noel",
    img = {
        "image:Muki_AiC_Noel_face_embarassed",
        "image:Muki_AiC_Noel_face_lose",
        "image:Muki_AiC_Noel_face_lose2",
    },
    text = {
        '这……这是什么东西？\n好……好厉害……',
        '感觉被灌输了很多<uppertext 符卡></uppertext 1><Color {255,255,0,0}>记</Color>忆……',
        '不过没时间犹豫了……\n我必须要保护老师和伊夏同学！'
    }
}

---圣光爆发前对话
---Dialog before burst
lib.dialog6 = {
    pos = 'right',
    canskip = false,
    t = 120,
    hscale = 0.5,
    vscale = 0.5,
    vol = 1,
    name = '诺艾儿·柯涅尔',
    snd = "se:Muki_AiC_dialog_Noel",
    img = {
        "image:Muki_AiC_Noel_face_lose",
        "image:Muki_AiC_Noel_face_lose",
        "image:Muki_AiC_Noel_face_fight"
    },
    text = {
        '<shake 3>老师……\n伊夏同学……</shake>',
        '<shake 3>难道……结局已经无法改变了吗……</shake>',
        '<shake 5>不……\n就算我死了也没关系，\n但我绝对不能让老师和伊夏遭到你的毒手！</shake>'
    }
}

---最终阶段前对话
---Dialog before last phase
lib.dialog7 = {
    pos = 'right',
    canskip = false,
    t = 120,
    hscale = 0.5,
    vscale = 0.5,
    vol = 1,
    name = {
        '诺艾儿·柯涅尔',
        '？？？',
        '？？？',
        '？？？',
        '诺艾儿·柯涅尔',
        '诺艾儿·柯涅尔',
        '诺艾儿·柯涅尔',
        '？？？？？？',
    },
    snd = {
        "se:Muki_AiC_dialog_Noel",
        'plst00',
        'plst00',
        'plst00',
        "se:Muki_AiC_dialog_Noel",
        "se:Muki_AiC_dialog_Noel",
        "se:Muki_AiC_dialog_Noel",
        'plst00',
    },
    img = {
        "image:Muki_AiC_Noel_face_lose",
        "image:Muki_AiC_Yukari_face_default",
        "image:Muki_AiC_Yukari_face_fight",
        "image:Muki_AiC_Yukari_face_smile",
        "image:Muki_AiC_Noel_face_default",
        "image:Muki_AiC_Noel_face_default",
        "image:Muki_AiC_Noel_face_fight",
        "image:Muki_AiC_Okina_face_default",
    },
    text = {
        '……',
        '<Color {255,255,0,255}>真是执着的少女呢\n不过你还没有领悟到弹幕的精髓啊</Color>',
        '<Color {255,255,0,255}>就再给你一次机会吧\n用我的力量</Color>',
        '<Color {255,255,0,255}>事情变得有趣起来了呢</Color>',
        '诶？\n身上的伤……突然不疼了……',
        '虽然不知道您是谁，\n但我十分感谢……',
        '我<scale 1.25></scale7><color 0xFFFF0000></color7><Uppertext {学园的才女,0,5}>诺艾儿·柯涅尔</Uppertext>，<wait 30>\n</wait>发誓将战斗至最后一刻！',
        '<Color {255,255,255,0}>哎呀，这样可就不公平了</Color>',
        '<Color {255,255,255,0}>屏幕那边那个，\n你就用我的力量吧</Color>',
        ---秘仪之力获取动画
        ---Power of Secret Ceremony Getting Animation
    },
    num = { 1, 2, 2, 2, 1, 1, 1, 3 }
}

---LSC对话
---Dialog of Last spellcard
lib.dialog8 = {
    pos = 'right',
    canskip = false,
    t = 120,
    hscale = 0.3,
    vscale = 0.3,
    vol = 1,
    name = '诺艾儿·柯涅尔',
    snd = "se:Muki_AiC_dialog_Noel",
    img = "image:Muki_AiC_Noel_face_final",
    text = {
        ---LSC开始前
        ---Before last spellcard
        '……',
        '说实话，我对<color 0xFFFF0000>你</color>如何能面不改色地\n做出这些事情多少有点好奇。',
        '<color 0xFFFF0000>你</color>难道从来没有想过我的感受吗？\n还是说<color 0xFFFF0000>你</color>color 0xFFFF00FF>以此为乐？</color>',
        '那些都无所谓了。\n现在，我要直接对你发起挑战。',
        ---「Reality Reverse　—10%—」
        '<color 0xFFFF0000>“可怜即可爱”</color>，是吗？\n<color 0xFFFF0000>你</color>是抱持着这样的心态来折磨我的吗？',
        '在你找上我之前，\n又有多少个<color 0xFFFF0000>天真无知</color>的<color 0xFFFF0000>少女</color>因为你饱受折磨？',
        '<shake 3></shake 7><color 0xFFFF0000>给我下地狱吧。</color>',
        ---「Reality Reverse　—25%—」
        '<color 0xFFFF0000>你</color>觉得打败我就会结束这一切吗？\n那可太便宜<color 0xFFFF0000>你</color>了。',
        '即使我和她们会忘记这一切，\n<color 0xFFFF0000>你</color>却不会忘记。',
        '希望<color 0xFFFF0000>你</color>关掉<color 0xFFFF0000>游戏</color>后\n今天晚上能带着这些话安心入睡。',
        ---「Reality Reverse　—50%—」
        '是时候进行最后的对决了。',
        '<scale 1.5></scale 13><color 0xFFFF0000>「逆转现实与幻想的境界」！</color>',
        ---「Reality Reverse　—80%—」
        ---交换自机与Boss
        ---Exchange the player and boss
    },
}

---战斗结束后对话（仅在非LSC线出现）
---Dialog after battle (Only appear in non-LSC line)
lib.dialog9 = {
    pos = 'right',
    canskip = false,
    t = 120,
    hscale = 0.5,
    vscale = 0.5,
    vol = 1,
    name = '梅法·格里亚德',
    snd = "se:Muki_AiC_dialog_Mepha",
    img = {
        "image:Muki_AiC_Mepha_face_smile",
        "image:Muki_AiC_Mepha_face_smile",
        "image:Muki_AiC_Mepha_face_default",
        "image:Muki_AiC_Mepha_face_default",
        "image:Muki_AiC_Mepha_face_fight"
    },
    text = {
        '刚才不知怎的突然就来到这里了……\n不过看来是来对了呢。',
        '诺艾儿·柯涅尔，\n贝尔米特国立大学所属，\nⅢ级士官候补生……\n我没记错吧？',
        '真是相当精彩的战斗……\n你已经做得足够好了。',
        '我向你保证，\n你和你的朋友一定能安全到家。',
        '……你是什么<color 0xFFFF0000>魔物</color>呢？\n抱歉，我看不出来。',
        '不过有一点可以确定……\n我会让你吃到苦头的，你这<color 0xFFFF0000>畜生</color>。'
    }
}
