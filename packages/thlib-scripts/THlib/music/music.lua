---THAIC Added
--======================================
--THlib music
--======================================

--家乡的小曲
MusicRecord("spellcard", 'THlib/music/spellcard.ogg', 75, 0xc36e80 / 44100 / 4)

--体验版曲目
--[[
local loop = {
    { 7090800 / 44100, 3351600 / 44100 },--标题曲
    { 10161735 / 44100, 10129347 / 44100 },--道中
    { 9665425 / 44100, 8230116 / 44100 },--1阶段
    { 4748315 / 44100, 4188471 / 44100 },--普莉姆拉
    { 1073161 / 44100, 1073161 / 44100 },--3阶段
    { 2307596 / 44100, 1072541 / 44100 },--圣光爆发
    --{ 1234435 / 44100, 1234435 / 44100 },--圣光爆发2（已与上一首合并）
    { 8521462 / 44100, 7236214 / 44100 },--4阶段
    { 11514798 / 44100, 11514798 / 44100 },--终符，The Amplifier - Feryquitous
    { 2666887 / 44100, 2666887 / 44100 },--结局A对话
    { 1919810, 114514 },--结局B对话（暂缺）
    { 3920064 / 44100, 3920064 / 44100 },--staff曲
    { 7188765 / 44100, 3352354 / 44100 },--标题曲完整版
    { 34.834, 27.54 },--疮痍曲
}
--]]

--正式版曲目
--
local loop = {
    [0] = { 87.8, 79.26 },--LuaSTG原版标题曲
    {  7090800 / 44100,  3351600 / 44100 },--标题曲
    {  5627141 / 44100,  5152698 / 44100 },--零面道中
    {  9550008 / 44100,  5754492 / 44100 },--本田 珠辉，3795516 ~ 9550008
    {  5669866 / 44100,  4429092 / 44100 },--本田 珠辉LSC，1240774 ~ 5669866
    {  5303071 / 44100,  4680511 / 44100 },--SNS部四人，622560 ~ 5303071
    {  6029406 / 44100,  3948016 / 44100 },--一面道中，2081390 ~ 6029406
    {  7314610 / 44100,  3675823 / 44100 },--爱丽丝，3638787 ~ 7314610
    {  7603236 / 44100,  3804944 / 44100 },--爱丽丝LSC，3798292 ~ 7603236
    { 10161735 / 44100, 10129347 / 44100 },--EX面道中
    {  9665425 / 44100,  8230116 / 44100 },--诺艾尔一阶段
    {  1935539 / 44100,  1935539 / 44100 },--伊夏，0 ~ 1935539
    {  4748315 / 44100,  4188471 / 44100 },--普莉姆拉
    {  1073161 / 44100,  1073161 / 44100 },--诺艾尔二阶段
    {  2307595 / 44100,  1072541 / 44100 },--圣光爆发
    {  8521462 / 44100,  7236214 / 44100 },--诺艾尔最终阶段，1285248 ~ 8521462
    { 11512311 / 44100, 11512311 / 44100 },--诺艾尔LSC
    {  2666887 / 44100,  2666887 / 44100 },--结局A对话
    {},--结局B对话（暂缺）
    {  3920064 / 44100,  3920064 / 44100 },--staff曲
    {           34.834,            27.54 },--疮痍曲
    --以下为DLC曲目
    {  9435446 / 44100,  8877280 / 44100 },--七面道中，558166 ~ 9435446
    { 10586563 / 44100, 10220754 / 44100 },--舞&里乃，365809 ~ 10586563
    { 24850724 / 44100, 13929860 / 44100 },--摩多罗豪华版，10920864 ~ 24850724
    { 10766429 / 44100,  5063850 / 44100 },--八面道中5702579 ~ 10766429
    {  8460706 / 44100,  5119318 / 44100 },--紫一阶段
    { 16543380 / 44100, 10282404 / 44100 },--紫二阶段，6260976 ~ 16543380
    {  8752268 / 44100,  3734780 / 44100 },--紫三阶段，5017488 ~ 8752268
    {  6922836 / 44100,  5869848 / 44100 },--紫LSC，1052988 ~ 922836
    { 10051623 / 44100,  5538531 / 44100 },--PH结局曲，4213092 ~ 10051623
    {  7144062 / 44100,  4190282 / 44100 },--标题曲（新），2953780 ~ 7144062
}   
--]]

--[[
曲目名单： 
1.梦境彼方 摇篮仙境
2.Wonderland of 0 & 1
3.Star Chaser
4.Star Rider
5./*死鱼眼_日照不足_往返跑部*/
6.正午时分的妖精宴会
7.G.H.O.S.T
8.缥缈之风　～ Assassinatroid
9.魔法使的祭典　～ Starry Forest
10.森林中的未知际遇
11.纯白之花
12.守护之光
13.超越空想的Stella
14.即使已然无力回天
15.于乐园中仰望繁星　～ Alice In Gensokyo
16.失色的星之梦　～ Reality or Fantasy?
17.森之意志
18.宁静的夏夜
19.Above Star
20.梦醒之时
◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈
--以下是DLC曲目
◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈◈
21.DOORS_OF_MYSTERIES
22.BACK_DANCERS
23.INDESCRIBABLE
24.DEEP_INTO_WONDERLAND
25.ALTERNATIVE
26.THE_YAKUMO
27.EYE_OF_LAPLACE
28.LAST_DANCE
29.VIOLET_NIGHT
30.乐园与群星与永远之梦
--]]

for i = 0, 30 do
    if aic.DLC or i <= 20 or _debug._debug then
        MusicRecord("aic_bgm" .. i, "THlib/music/Muki_AiC_bgm" .. i .. ".ogg", loop[i][1], loop[i][2])
    end
end

bgm_volume = {}
