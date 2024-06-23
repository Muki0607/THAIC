achi = { list = {}, checklist = {} }

for i = 1, 16 do
    LoadImageFromFile('achi_eff_' .. i, "weekend/achi/" .. i .. ".png")
end
LoadImageFromFile('achi_eff_back', "weekend/achi/back.png")

achi.show = {}
function achi.ShowAdd(name)
    table.insert(achi.show, {
        name = name,
        timer = 0
    })
end
function achi.ShowFrame()
    local show = achi.show
    if #show > 0 then
        if show[1].timer == 0 then
            Print("[Achievement] Get Achievement : " .. show[1].name)
            PlaySound("bonus2")
        end
        show[1].timer = show[1].timer + 1
        if show[1].timer > 300 then
            table.remove(show, 1)
        end
    end
end
function achi.ShowRender(x, y)
    local show = achi.show
    if #show > 0 then
        local a = show[1]
        local name, timer = a.name, a.timer
        local dx, dy = 0, 0
        local alpha
        local scale
        local index
        if timer <= 60 then
            scale = max(0, min(timer / 59, 1))
            index = int(timer / 60 * 15) + 1
            alpha = max(0, min(timer / 59, 1)) * 255
        elseif timer <= 60 + 180 then
            scale = 1
            index = 16
            alpha = 255
        else
            scale = max(0, min((300 - timer) / 59, 1))
            index = int((300 - timer) / 60 * 15) + 1
            alpha = max(0, min((300 - timer) / 59, 1)) * 255
        end
        Render("achi_eff_" .. index, x, y, timer * 4.5, 0.5)
        Render("achi_eff_back", x, y, -timer / 3, scale / 2)
        RenderTTF("dialog", "完成成就",
                x + dx - 70, x + dx + 70, y + dy + 5, y + dy + 5,
                Color(alpha, 255, 255, 255), "bottom", "center")
        RenderTTF("dialog", name,
                x + dx - 70, x + dx + 70, y + dy - 25, y + dy - 25,
                Color(alpha, 255, 255, 255), "bottom", "center")
    end
end

---添加一个成就
---@param name string @Achievement name
---@param get_info string @Obtain conditions
---@param achi_info string @Achievement introduction
---@param hide string @Achievement is hide
function achi.add(name, get_info, achi_info, hide)
    assert(achi.checklist[name] == nil, string.format("Achievement %q has been existed.", name))
    achi.checklist[name] = false
    table.insert(achi.list, {
        name = name,
        get_info = get_info,
        achi_info = achi_info,
        hide = hide
    })
end

---刷新成就状态
function achi.refresh()
    if scoredata.achi == nil then
        scoredata.achi = {}
    end
    for i = 1, #achi.list do
        local a = achi.list[i]
        if scoredata.achi[a.name] then
            achi.checklist[a.name] = scoredata.achi[a.name]
        end
    end
end

---成就全开
function achi.allget()
    for _, a in pairs(achi.list) do
        achi.get(a.name)
    end
end

---重置所有成就
function achi.reset()
    achi.show = {}
    scoredata.achi = {}
    achi.checklist = {}
    for _, a in pairs(achi.list) do
        achi.checklist[a.name] = false
    end
end

---取得一个成就   
---@param name string @Achievement name
function achi.get(name)
    if ext.replay.IsReplay() then
        return
    end
    assert(achi.checklist[name] ~= nil,
        string.format("Achievement %q is not existed.", name))
    achi.checklist[name] = true
    if scoredata.achi == nil then
        scoredata.achi = {}
    end
    if not (scoredata.achi[name]) then
        scoredata.achi[name] = true
        achi.ShowAdd(name)
        --New(achi_obj, name)
    end
end

---获取成就表信息
---@return number, number, string
function achi.info()
    local count = 0
    local count1 = 0
    local count2 = 0
    local get = 0
    local get1 = 0
    local get2 = 0
    achi.refresh()
    for _, a in pairs(achi.list) do
        count = count + 1
        if a.hide then
            count2 = count2 + 1
        else
            count1 = count1 + 1
        end
        if achi.checklist[a.name] then
            get = get + 1
            if a.hide then
                get2 = get2 + 1
            else
                get1 = get1 + 1
            end
        end
    end
    local rate, rate1, rate2
    if count <= 0 then
        rate = "N/A"
    else
        rate = string.format("%.2f%%", (get / count) * 100)
    end
    if count1 <= 0 then
        rate1 = "N/A"
    else
        rate1 = string.format("%.2f%%", (get1 / count1) * 100)
    end
    if count2 <= 0 then
        rate2 = "N/A"
    else
        rate2 = string.format("%.2f%%", (get2 / count2) * 100)
    end
    return count, get, rate, count1, get1, rate1, count2, get2, rate2
end