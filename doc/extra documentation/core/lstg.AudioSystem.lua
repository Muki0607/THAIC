--------------------------------------------------------------------------------
--- LuaSTG Sub 音频命令 未公开API
--- 璀境石
--- tested by Muki
--------------------------------------------------------------------------------

---本文档中所有函数均为根据实际使用得到的结果做出的猜测，不保证准确

---@diagnostic disable: missing-return


--------------------------------------------------------------------------------
--- 音效

--- 获取全局音效音量
---@return number
function lstg.GetSEVolume()
end

--- 设置音效播放速率
---@param sndname string
---@param speed number
function lstg.SetSESpeed(sndname, speed)
end

--- 获取音效播放速率
---@param sndname string
---@return number
function lstg.GetSESpeed(sndname)
end

--------------------------------------------------------------------------------
--- 音乐

---设置BGM循环节，参考lstg.LoadMusic
---@param loopend number @循环区间的结束位置(秒)
---@param looplength number @循环区间的长度(秒)
function lstg.SetBGMLoop(bgmname, loopend, looplength)
end

--- 获取BGM播放速率
---@param bgmname string
---@return number
function lstg.GetBGMSpeed(bgmname)
end

--- 设置BGM播放速率
---@param bgmname string
---@param speed number
function lstg.SetBGMSpeed(bgmname, speed)
end

--- 获取全局音乐音量
---@return number
function lstg.GetBGMVolume()
end

--- 获取BGM的FFT，目前调用时返回一个包含256个0的表，用途未知
---@param bgmname string
---@return number[]
function lstg.GetMusicFFT(bgmname)
end
