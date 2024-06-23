--------------------------------------------------------------------------------
--- LuaSTG Sub 游戏对象管理器 未公开API
--- 璀境石
--- tested by Muki
--------------------------------------------------------------------------------

---本文档中所有函数均为根据实际使用得到的结果做出的猜测，不保证准确

---@diagnostic disable: missing-return

--------------------------------------------------------------------------------
--- 游戏对象管理器

---关于特殊Object：
---0：UI
---1:player
---2:grazer
---32768:内部Object，没有任何属性，甚至没有[1]基类与[2]objid，只存在于lstg.ObjTable()中

--- 推测为某种迭代器函数，但与lstg.ObjList.Next不同，不关注碰撞组
---
--- 下列代码可迭代所有obj：
---```
--- >for i, o in NextObject, -1, 0 do
--- >    Print(i, o)
--- >end
---```
---@param flag number 该函数只关注这个number的正负，大于等于0时行为均相同，小于0时行为均相同
---@param objid number 返回对应objid的obj
---@return number, lstg.GameObject number:可能为-1或另一个objid（大概率为objid+1，但也可能不是），当下一个obj不存在时为-1；但flag为正数时也有部分有下一个obj的情况返回-1。 lstg.GameObject:对应objid的obj
function lstg.NextObject(flag, objid)
end

--- 返回存储所有游戏对象的表，对应索引为objid + 1；
--- 删除该表中元素会导致与该游戏对象断开连接，导致错误
---@return lstg.GameObject[]
function lstg.ObjTable()
end


--------------------------------------------------------------------------------
--- 游戏对象

--- 重置指定游戏对象，效果未知，unit不是表时会炸游戏，是表但不是obj时会报错
---@param unit lstg.GameObject
function lstg.ResetObject(unit)
end
