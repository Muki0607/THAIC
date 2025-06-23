---=====================================
---THAIC Pointdevice Mode v1.00a
---东方梦摇篮 完美无缺模式 v1.00a
---=====================================

---版本更新记录
---v1.00a
---初始版本
---v1.01a
---修复了lib.StageFinishSave中文件打开模式为ab导致读录像失败的问题（应为ab+）
---修复了重开关卡时lib.stage_index未清零导致路径错误的问题（需在第一次使用lib.Save前手动调用lib.InitFunc）
---修复了replay中重复调用lib.InitFunc、lib.StageFinishSave和lib.GameFinishSave的问题
---更改了lib.Load中重放音乐的位置，使得调用Load不会再向lib.MusicRecord中写入记录，提高效率
---目前版本可保证单关无Load时replay正常（只是这样有什么用啊（恼））

----------------------------------------
--[[
说明：本库用于模拟TH15中的完美无缺模式，
基本原理是借助写replay系统将按键输入存储至临时录像，
并在读档时开启读replay系统输入按键，
以实现以同一状态回到同一位置的目的。
简单来说就是立刻重开游戏，切到replay模式，
瞬间快放个几万帧再切回普通模式。
由于这个操作会打断写replay，
在每面结束时需要调用lib.StageFinishSave，
最后一面结束（游戏结束）时需要调用lib.GameFinishSave，
这样才能将临时录像中的按键记录回输至replayWriter，生成完整录像。
当然如果本来就不想要回放也可以不这么做……
]]
----------------------------------------
---以下这段是boss帧函数的修正，需要手动覆盖原帧函数
---如果有能在进游戏后再修正的方法的话请告诉我，我马上把它塞到InitFunc里
---非常申必的是不覆盖的话读档时下面调用dmgt的时候会报invalid object
---我知道肯定又跟元表有关，但搞不明白
---@diagnostic disable-next-line: empty-block
if false then
    function boss:frame()
        if not IsValid(self) then return end
        self._bosssys:frame() --boss系统帧逻辑
        self._wisys:frame()   --行走图系统帧逻辑
        --发现会有很多问题，还是不加这个细节了
        --[[
        for _, o in ObjList(GROUP_ITEM) do --拾取道具
            if o.is_power or o.is_power_red then
                if Dist(self, o) < 48 then
                    if o.attract < 3 then
                        o.attract = max(o.attract, 3)
                        o.target = self
                    end
                end
            end
        end
        --]]
        ---THAIC Added
        if not IsValid(self) then return end
        --受击闪烁
        if self.dmgt then
            self.dmgt = max(0, self.dmgt - 1)
        end
    end
end
----------------------------------------

---@class aic.pmode @东方梦摇篮完美无缺模式
aic.pmode = {}
local lib = aic.pmode

---临时录像文件路径（不包含关卡索引与后缀名）
---@type string
lib.tmprep_path = nil

---临时录像文件帧数
---@type number
lib.tmprep_count = 0

---临时录像stage索引
---@type number
lib.stage_index = 0

---加载标志
---@type boolean
lib.LoadingSign = false

---初始化标志
---@type boolean
lib.InitializedSign = false

---音乐播放位置记录表
---@type table
lib.MusicRecord = {}

---初始化函数。
---虽然lib.Save会自动调用，但如果不重开游戏第二次Save时就不会Init，
---因此请务必在第一次Save前手动调用该函数。
function lib.InitFunc()
    --在Load重开关卡时不再重复执行InitFunc
    if lib.LoadingSign then return end
    --重置变量
    lib.tmprep_path = nil
    lib.tmprep_count = 0
    lib.stage_index = 0
    lib.MusicRecord = {}
    --创建临时录像文件夹
    local dir = lstg.LocalUserData.GetReplayDirectory() .. "/" .. setting.mod .. "/temp_replay"
    if lstg.FileManager.DirectoryExist(dir) then
        lib.ClearTempRep(dir)
    end
    lstg.FileManager.CreateDirectory(dir)

    ---修改PlayMusic，使其执行时返回已经历帧数，便于确认音乐播放位置
    --存储旧函数
    local ref = PlayMusic
    --重定义函数
    function PlayMusic(bgmname, volume, position)
        --调用旧函数
        ref(bgmname, volume, position)
        --若在读档中则取消存储
        if lib.LoadingSign then return end
        --存储信息
        position = position or 0
        local info = { ext.slowTicker, bgmname, volume, position }
        --检查是否有名字与播放位置均一致的记录，没有则记录
        for _, v in pairs(lib.MusicRecord) do
            if v[1] == info[1] and v[2] == info[2] and v[4] == info[4] then
                return
            end
        end
        table.insert(lib.MusicRecord, info)
    end

    lib.InitializedSign = true
end

---获取现在正在播放的bgm与播放信息，
---默认同时只有一首bgm播放。
---有时缓时可能会出问题。
---@return string, number, number
function lib.GetCurrentBGM()
    local time, key = 0
    --找到离当前时间最近的记录
    for k, v in pairs(lib.MusicRecord) do
        if v[1] > time then
            key = k
            time = v[1]
        end
    end
    local info = lib.MusicRecord[key]
    if not info then return end
    return info[2], info[3], info[4] + (ext.slowTicker - info[1]) / 60 --原播放位置加上已播放时间
end

---获取临时录像文件路径（不包含关卡索引与后缀名）
---@return string @临时录像文件路径（不包含关卡索引与后缀名）
function lib.GetTempRepPath()
    return (lstg.LocalUserData.GetReplayDirectory() .. "/"
        .. setting.mod .. "/temp_replay/" .. lstg.var.stage_name
        .. '@' .. lstg.var.rep_player)
end

---清空临时录像
---@param path string @临时录像文件路径（不包含关卡索引与后缀名）
---@param player string @要清空的录像的自机，为nil时直接删除整个文件夹
function lib.ClearTempRep(path, player)
    path = path or lib.GetTempRepPath()
    path = string.match(path, ".+/temp_replay")
    if player then
        local filelist = lstg.FileManager.EnumFiles(path, 'tmprep')
        for _, v in ipairs(filelist) do
            if string.match(v[1], player) then
                os.remove(path .. "/" .. v[1])
            end
        end
    else
        lstg.FileManager.RemoveDirectory(path)
    end
end

---第四版Save，分stage存储临时录像，适用于多stage
---@param path string @临时录像文件路径（不包含关卡索引与后缀名）
function lib.Save(path)
    --保证当前版本开replay起码不会报错
    if ext.replay.IsReplay() then return end
    --[[
    if not lib.InitializedSign then
        lib.InitFunc()
    end
    ]]
    --在Load重开关卡时不再重复执行Save
    if lib.LoadingSign then return end
    --获取路径
    path = path or lib.GetTempRepPath()
    if path ~= lib.tmprep_path then
        lib.stage_index = lib.stage_index + 1
        lib.tmprep_count = 0
        lib.tmprep_path = path
    end
    --补齐文件名
    local filepath = path .. "_" .. lib.stage_index .. ".tmprep"
    --打开临时录像
    local tmprep = plus.FileStream(filepath, "ab")
    --写入帧数据
    replayWriter:CopyToFileStream(tmprep)
    --关闭临时录像
    tmprep:Close()
    --统计已保存帧数
    local count = replayWriter:GetCount()
    lib.tmprep_count = lib.tmprep_count + count
    --可以在这里写其他逻辑（例：章节结算）
    --[[
    lstg.var.minpower = lstg.var.power - 100
    local bonus = lstg.var.score + lstg.tmpvar.chapter.graze * lstg.tmpvar.chapter.clear_percent * 50
    lstg.var.score = lstg.var.score + bonus
    if bonus >= 1000000 then
        PlaySound("bonus", 0.5)
        if PointdeviceMode then
            if lstg.var.bombchip < 5 then
                lstg.var.bombchip = lstg.var.bombchip + 1
            else
                lstg.var.bombchip = 0
                lstg.var.bomb = lstg.var.bomb + 1
            end
        else
            if lstg.var.chip < 3 then
                lstg.var.chip = lstg.var.chip + 1
            else
                lstg.var.chip = 0
                lstg.var.lifeleft = lstg.var.lifeleft + 1
            end
        end
    end
    ]]
    --或许更好的方式是写一个结算的obj
    --New(chapter_result, lstg.var.score + lstg.tmpvar.chapter.graze * lstg.tmpvar.chapter.clear_percent * 50)
end

---第四版Load，支持重新进入游戏时断点重开
---还是太容易炸了，不太能实用
---@param path string @临时录像文件路径（不包含关卡索引与后缀名）
function lib.Load(path)
    --读档标志，防止读档时重复调用一些函数
    lib.LoadingSign = true
    --获取路径
    path = path or lib.GetTempRepPath()
    assert(path ~= nil, "invalid temporary replay path.")
    --补齐文件名
    path = path .. "_" .. lib.stage_index .. ".tmprep"
    --获取关卡名
    local stagename = string.match(path, ".+/.+/.+/(.+)@.+")
    --Print(stagename)
    assert(stagename ~= nil, "invalid temporary replay path.")
    --重开关卡
    --stage.Restart()
    stage.Set(stagename, "save")
    --关闭写录像
    replayWriter = nil
    --开启读录像
    replayReader = plus.ReplayFrameReader(path, 0, lib.tmprep_count)
    --跳过已保存帧数
    for _ = 1, lib.tmprep_count do
        --FrameFunc()
        aic.ext.DoFrameEx()
        --DoFrameEx()
    end
    --关闭读录像
    replayReader:Close()
    replayReader = nil
    --重新播放音乐以确保位置准确
    _stop_music()
    local bgmname, volume, position = lib.GetCurrentBGM()
    if bgmname then
        PlayMusic(bgmname, volume, position)
    end
    --取消读档标志
    lib.LoadingSign = false
    --可以在这里写Restart动画和其他逻辑（例：火力减少）
    --lstg.var.power = max(lstg.var.power - 1, lstg.var.minpower)
    --lstg.var.retry_count = lstg.var.retry_count + 1
    --history+1
    if not ext.replay.IsReplay() and _boss then
        if scoredata.spell_card_hist == nil then
            scoredata.spell_card_hist = {}
        end
        local hist = scoredata.spell_card_hist
        local diff = GetDiff()
        local name = _boss.current_card.name
        local player = lstg.var.player_name
        --hist[diff][name][player][2] = hist[diff][name][player][2] + 1 --暂时没分难度，先不加history
    end
    --开启写录像
    replayWriter = plus.ReplayFrameWriter()
    --由于当前尚未处理好rep问题，暂且不保存rep
    aic.menu.last_replay = nil
    --取消无敌
end

---结束本关存档，务必在本关所有必要按键输入结束后（比如转场前一帧）再执行。
---如果是最后一关请执行lib.GameFinishSave，无需执行本函数。
---不执行本函数将导致炸replay。
---执行本函数后本面后续按键输入将在replay中被忽略。
---@param path string @临时录像文件路径（不包含关卡索引与后缀名）
function lib.StageFinishSave(path)
    --保证当前版本开replay起码不会报错
    if ext.replay.IsReplay() then return end
    --获取路径
    path = path or lib.GetTempRepPath()
    assert(path ~= nil, "invalid temporary replay path.")
    --最后保存，完成当前关卡临时录像
    lib.Save(path)
    --补齐文件名
    path = path .. "_" .. lib.stage_index .. ".tmprep"
    --当前关卡全部按键输入
    local byte_array = {}
    --打开临时录像
    local tmprep = plus.FileStream(path, "ab+")
    --读取按键输入
    for _ = 1, tmprep:GetSize() do
        table.insert(byte_array, tmprep:ReadByte())
    end
    --[[
    local byte = 0
    while byte do
        byte = tmprep:ReadByte()
        table.insert(byte_array, byte)
    end
    ]]
    --打开二进制写
    local w = plus.BinaryWriter(tmprep)
    --写入临时录像完成标志
    w:WriteString("TMPREPFIN", false)
    --关闭二进制写
    w:Close()
    --重启写录像
    replayWriter = nil
    replayWriter = plus.ReplayFrameWriter()
    --写入当前关卡全部按键输入
    replayWriter:Write(byte_array)
    --打印当前关卡完成信息
    Log(2,
        "[pmode] Temporary replay of stage " .. lib.stage_index .. ": " .. lstg.var.stage_name .. " has been finished.")
end

---结束全关存档，务必在最后一关所有必要按键输入结束后（比如转场前一帧）再执行。
---执行本函数前不需要再执行lib.StageFinishSave。
---不执行本函数将导致炸replay。
---执行本函数后所有后续按键输入将在replay中被忽略。
---调用此函数后不可再调用任何存读取函数。
---@param path string @临时录像文件路径（不包含关卡索引与后缀名）
function lib.GameFinishSave(path)
    --保证当前版本开replay起码不会报错
    if ext.replay.IsReplay() then return end
    --获取路径
    path = path or lib.GetTempRepPath()
    assert(path ~= nil, "invalid temporary replay path.")
    --最后保存，完成当前关卡临时录像
    lib.StageFinishSave(path)
    --获取文件夹路径
    path = string.match(path, ".+/temp_replay")
    --全部按键输入
    local byte_array = {}
    --获取全部临时录像文件
    local filelist = lstg.FileManager.EnumFiles(path, 'tmprep')
    --按关卡索引顺序逐一写入按键输入
    local stage_index = 1
    while stage_index <= lib.stage_index do
        for _, v in ipairs(filelist) do
            --当关卡索引匹配时写入按键输入
            if string.match(v[1], '@' .. lstg.var.rep_player .. "_" .. stage_index .. ".tmprep") then
                --打开临时录像
                local tmprep = plus.FileStream(v[1], "rb")
                --打开二进制读
                local r = plus.BinaryReader(tmprep)
                --检查临时录像是否完成
                local len = string.len("TMPREPFIN")
                tmprep:Seek(-len, "end")
                local tail = r:ReadString(len)
                --Print(tail)
                assert(tail == "TMPREPFIN", "Temporary replay of stage " .. stage_index .. " is not finished.")
                --计算帧数据长度，同时将读取位置移至起始处
                len = tmprep:GetSize() - len
                --读取按键输入
                for _ = 1, len do
                    table.insert(byte_array, tmprep:ReadByte())
                end
                --[[
                local n = 0
                while byte <= tmprep:GetSize() - len do
                    byte = tmprep:ReadByte()
                    table.insert(byte_array, byte)
                    n = n + 1
                end
                ]]
                --关闭二进制读
                r:Close()
            end
        end
        stage_index = stage_index + 1
    end
    --重启写录像
    replayWriter = nil
    replayWriter = plus.ReplayFrameWriter()
    --写入当前关卡全部按键输入
    replayWriter:Write(byte_array)
    --清除临时录像（就目前而言还是全清吧）
    --lib.ClearTempRep(path, lstg.var.rep_player)
    lib.ClearTempRep(path)
    --打印回放整合完成信息
    Log(2, "[pmode] Temporary replay of all stages has been combined.")
end
