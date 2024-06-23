--------------------------------------------------------------------------------
--- LuaSTG Sub 资源管理 未公开API
--- 璀境石
--- tested by Muki
--------------------------------------------------------------------------------

---本文档中所有函数均为根据实际使用得到的结果做出的猜测，不保证准确

---@diagnostic disable: missing-return

--------------------------------------------------------------------------------
--- 纹理和渲染目标

--- 设置纹理混合前透明度状态，state为true时纹理将变为白底
---@param texture_name string
---@param state boolean
function lstg.SetTexturePreMulAlphaState(texture_name, state)
end
