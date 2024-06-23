---@diagnostic disable: invisible

--menu系统的定义

---@alias menu.menuObject.callBack fun(self:menu.menuObject)
---@alias menu.menuObject.item {name:string, func:menu.menuObject.callBack}
---@type table<string, menu.menuObject>
menu = {}
menu.menuList = {}
menu.menuStack = {}

local defaultFadeFunc = {}

function defaultFadeFunc:FadeIn()
    self.x = screen.width * 0.5
    self.locked = true
    for i = 0, 14 do
        self.alpha = i / 14
        task.Wait()
    end
    self.locked = false
end

function defaultFadeFunc:FadeOut()
    self.x = screen.width * 0.5
    self.locked = true
    local old_alpha = self.alpha or 1
    for i = 14, 0, -1 do
        self.alpha = min(i / 14, old_alpha)
        task.Wait()
    end
end

---@param menuObject menu.menuObject
function menu.menuStack:Push(menuObject)
    table.insert(self, menuObject)
end

---@return menu.menuObject|nil
function menu.menuStack:Pop()
    if #self > 0 then
        local m = table.remove(self)
        return m
    end
end

---@return menu.menuObject|nil
function menu.menuStack:Top()
    if #self > 0 then
        return self[#self]
    else
        return nil
    end
end

function menu.menuStack:IsEmpty()
    return #self == 0
end

function menu.menuStack:Clear()
    while #self > 0 do
        menu.menuStack:Pop()
    end
end


---添加菜单
---@param menuName string
---@param menuObject menu.menuObject
function menu.addMenu(menuName, menuObject)
    if not menu.menuList[menuName] then
        menu.menuList[menuName] = menuObject
    end
end

---获取菜单
---@param menuName string
---@return menu.menuObject
function menu.getMenu(menuName)
    return menu.menuList[menuName]
end

---飞入某个菜单
---@param menuName string
---@overload fun(menuObject:menu.menuObject)
function menu.flyIn(menuName)
    New(tasker, function()
        if menu.menuStack:Top() then
            menu.menuStack:Top():flyOutFunc()
        end
        if type(menuName) == "string" then
            menu.menuStack:Push(menu.menuList[menuName])
            menu.getMenu(menuName):flyInFunc()
        else
            menu.menuStack:Push(menuName)
            menuName:flyInFunc()
        end
    end)
end

---飞出当前菜单
function menu.flyOut()
    New(tasker, function()
        menu.menuStack:Pop():flyOutFunc()
        if (not menu.menuStack:IsEmpty()) then
            menu.menuStack:Top():flyInFunc()
        end
    end)
end

---只展示特效的飞入菜单
---@param menuName string
---@overload fun(menuObject:menu.menuObject)
function menu.rawFlyIn(menuName)
    if type(menuName) == "string" then
        menu.getMenu(menuName):flyInFunc()
    else
        menuName:flyInFunc()
    end
end

---只展示特效的飞出当前菜单
function menu.rawFlyOut()
    if (menu.menuStack:IsEmpty()) then return end
    menu.menuStack:Top():flyOutFunc()
end

---@class menu.menuObject
menu.menuObject = plus.Class()


function menu.menuObject:init(name)
    self.exitFunc = function(self) end
    --
    self.name = name
    ---@type menu.menuObject.item[]
    self.item = {}
    self.itemIndex = 1
    self.itemCount = 0
    self.pos = 1
    ---@private
    self.flyInFunc = defaultFadeFunc.FadeIn
    ---@private
    self.flyOutFunc = defaultFadeFunc.FadeOut
    self.locked = true
    --
    self.timer = 0
end

function menu.menuObject:frame()
    self.timer = self.timer + 1
    task.Do(self)
    if not self:isActive() then
        return
    end
end

function menu.menuObject:render()
    if not self:isActive() then
        return
    end
end

---创建菜单obj
---@param name string 菜单名称
---@return menu.menuObject
function menu.menuObject.create(name)
    local menuObject = menu.menuObject(name)
    menu.addMenu(name, menuObject)
    return menuObject
end

---向菜单添加选项
---@param item menu.menuObject.item
function menu.menuObject:addItem(item)
    if (item.name == "exit") then
        self.exitFunc = item.func
    else
        table.insert(self.item, item)
        self.itemCount = self.itemCount + 1
    end
end

---向菜单添加多个选项
---@param itemList menu.menuObject.item[]
function menu.menuObject:addAllItem(itemList)
    for _, value in pairs(itemList) do
        menu.menuObject:addItem(value)
    end
end

---检测菜单是否激活
---@return boolean
function menu.menuObject:isActive()
    --Print(self.name .. " isActive:" .. tostring(self == menu.menuStack:Top() and not self.locked)
    return self == menu.menuStack:Top() and not self.locked
end

---设置飞入事件
---@param func fun(self:menu.menuObject)
function menu.menuObject:seyOnflyIn(func)
    self.flyInFunc = func
end

---设置飞出事件
---@param func fun(self:menu.menuObject)
function menu.menuObject:setOnflyOut(func)
    self.flyOutFunc = func
end

function menu.menuObject:getItemPosition()
    return self.pos
end

menu.menuObj = Class(object)

function menu.menuObj:init()

end

function menu.menuObj:frame()
    for key, value in pairs(menu.menuList) do
        value:frame()
        --Print(value.name)
    end
end

function menu.menuObj:render()
    SetViewMode('ui')
    for key, value in pairs(menu.menuList) do
        value:render()
    end
    SetViewMode('world')
end

function menu.resetMenu()
    menu.menuStack:Clear()
    menu.menuList = {}
end

Include "THlib/UI/newmenu/menus.lua"