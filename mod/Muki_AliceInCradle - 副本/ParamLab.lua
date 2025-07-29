if not DG then DG = {} end

local ParamLab = {}
ParamLab.__index = ParamLab

---新建调参表
---@param txtname any 数据文档导出地址，默认地址 mod/windmillLab.txt
function DG.NewParamList(txtname)
    local w = {}
    w.txtname = txtname or 'mod/ParamOutput.txt'
    w.edit_list = {}
    w.Edit = ParamLab.Edit
    w.NewParam = ParamLab.NewParam
    w.Output = ParamLab.Output
    return w
end

---编辑模式界面obj
local param_editor = Class(object)
function param_editor:init(w)
    self.x,self.y = -53,0
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.list = w
    self.mode = 'display'
    self.pointer = 1
    self.speed = 13/60
    self.x0,self.y0 = player.x,player.y
end
function param_editor:frame()
    local w = self.list
    if self.mode == 'display' then
        self.x0,self.y0 = player.x,player.y
        player.dialog = false
        player.colli = true
        if KeyIsPressed 'special' then self.mode = 'edit' end
    elseif self.mode == 'edit' then
        player.x,player.y = self.x0,self.y0
        player.dialog = true
        player.colli = false

        local len = #w.edit_list
        if KeyIsDown 'up' then
            self.pointer = self.pointer - self.speed
        elseif KeyIsDown 'down' then
            self.pointer = self.pointer + self.speed
        else
            local int_p = int(self.pointer)
            if abs(self.pointer-int_p)>0.5 then int_p = int_p+1 end
            self.pointer = self.pointer*0.85 + int_p*0.15

            local list = w.edit_list[int_p]
            local increment,i=0,0
            if KeyIsPressed 'left' or (PLabKeyDown and KeyIsDown 'left') then i = -1 end
            if KeyIsPressed 'right' or (PLabKeyDown and KeyIsDown 'right') then i = 1 end
            if list[3] == 'int' or list[3] == 'float' then
                increment = list[5] or 0
                if KeyIsDown 'shoot' then increment = increment*10 end
                if KeyIsDown 'slow' then increment = increment/10 end
                if list[3] == 'int' then
                    increment = int(increment)
                    if increment == 0 then increment = 1 end
                end
            else
                increment = 1
            end
            if list[3] == 'bool' then
                if KeyIsPressed 'left' or KeyIsPressed 'right' then
                    w[list[1]] = not w[list[1]]
                end
            elseif list[3] == 'float' or list[3] == 'int' then
                w[list[1]] = w[list[1]] + increment*i
                if list[6] and w[list[1]] < list[6] then w[list[1]] = list[6] end
                if list[7] and w[list[1]] > list[7] then w[list[1]] = list[7] end
            elseif list[3] == 'blend' then
                w['i__'..list[1]] = (w['i__'..list[1]]+increment*i) % DG.blend[0]
                w[list[1]] = DG.blend[w['i__'..list[1]]+1]
            else
                w['i__'..list[1]] = (w['i__'..list[1]]+increment*i) % DG[list[3]][0]
                w[list[1]] = _G[DG[list[3]][w['i__'..list[1]]+1]]
            end
        end
        if self.pointer<1 then self.pointer=1
        elseif self.pointer>len then self.pointer=len end
        if KeyIsPressed 'spell' then w:Output() PlaySound('cardget',0.3,self.x/256) end
        if KeyIsPressed 'special' then self.mode = 'display' end
    end
end
function param_editor:render()
    if self.mode == 'display' then
        local text = '当前为非编辑模式, 按 c 进入编辑模式'
        RenderTTF('sc_name',text,0,0,-224,0,Color(160,255,255,255),'centerpoint')
    else
        SetImageState('white','',Color(160,0,0,0))
        RenderRect('white',-224,224,-256,256)
        SetImageState('white','',Color(255,255,255,255))
        local w = self.list
        local x = 180
        local dy = 20
        local int_p = int(self.pointer)
        if abs(self.pointer-int_p)>0.5 then int_p = int_p+1 end
        for i,list in ipairs(w.edit_list) do
            local co = Color(150,255,255,255)
            if i == int_p then co = Color(255,255,255,255) end
            RenderTTF('sc_name',list[2] or list[1],-x,-x,self.y-dy*(i-self.pointer),self.y-dy*(i-self.pointer),co,'left')
            if list[3] == 'int' or list[3] == 'float' or list[3] == 'bool' then
                RenderTTF('sc_name',tostring(w[list[1]]),x,x,self.y-dy*(i-self.pointer),self.y-dy*(i-self.pointer),co,'right')
            else
                RenderTTF('sc_name',DG[list[3]][w['i__'..list[1]]+1],x,x,self.y-dy*(i-self.pointer),self.y-dy*(i-self.pointer),co,'right')
            end
        end
    end
end

---启用编辑模式
function ParamLab:Edit()
    New(param_editor,self)
end

---给调参表添加可调参数
function ParamLab:NewParam(name,display,template,default,increment,minimum,maximum)
    template = template or 'float'
    if template == 'float' then
        default = default or 0
        increment = increment or 1
        self[name] = default
    elseif template == 'int' then
        default = int(default or 1)
        increment = int(increment or 1)
        minimum = int(minimum or 1)
        self[name] = default
    elseif template == 'bool' then
        default = false
        self[name] = default
    elseif template == 'argb' then
        template = 'int'
        default = default or 255
        increment = increment or 10
        minimum = minimum or 0
        maximum = maximum or 255
        self[name] = default
    elseif template == 'blend' then
        default = 0
        self['i__'..name] = 0
        self[name] = DG[template][1]
    else
        default = 0
        self['i__'..name] = 0
        self[name] = _G[DG[template][1]]
    end
    table.insert(self.edit_list,{name,display,template,default,increment,minimum,maximum})
end

---导出参数表
function ParamLab:Output()
    local output = ''
    for _,list in ipairs(self.edit_list) do
        -- list = {name,display,template,default,increment,minimum,maximum}
        if list[3] == 'float' or list[3] == 'int' or list[3] == 'bool' then
            if type(list[1]) == "number" then
                output = output .. '\t[' .. list[1] .. '] = ' .. tostring(self[list[1]]) .. ',\t-- ' .. tostring(list[2]) .. '\n'
            else
                output = output .. '\t' .. list[1] .. ' = ' .. tostring(self[list[1]]) .. ',\t-- ' .. tostring(list[2]) .. '\n'
            end
        else --if list[3] == 'color' or list[3] == 'style' or list[3] == 'style_dark' then
            if type(list[1]) == "number" then
                output = output .. '\t[' .. list[1] .. '] = ' .. DG[list[3]][self['i__'..list[1]]+1] .. ',\t-- ' .. tostring(list[2]) .. '\n'
            else
                output = output .. '\t' .. list[1] .. ' = ' .. DG[list[3]][self['i__'..list[1]]+1] .. ',\t-- ' .. tostring(list[2]) .. '\n'
            end
        end
    end
    output = '{\n' .. output .. '}'

    local param_file = io.open(self.txtname,'w')
    io.output(param_file)
    io.write(output)
    io.close(param_file)
end

DG.color = {
    'COLOR_RED', 'COLOR_DEEP_RED', 'COLOR_PURPLE', 'COLOR_DEEP_PURPLE',
    'COLOR_BLUE', 'COLOR_DEEP_BLUE', 'COLOR_ROYAL_BLUE', 'COLOR_CYAN',
    'COLOR_GREEN', 'COLOR_DEEP_GREEN', 'COLOR_CHARTREUSE', 'COLOR_YELLOW',
    'COLOR_GOLDEN_YELLOW', 'COLOR_ORANGE', 'COLOR_DEEP_GRAY', 'COLOR_GRAY',
}
DG.color[0] = #DG.color

DG.blend = {
    'mul+alpha', 'mul+add', 'mul+rev', 'mul+sub', 'add+alpha', 'add+add',
    'add+rev', 'add+sub', 'alpha+bal', 'mul+min', 'mul+max', 'mul+mul',
    'mul+screen', 'add+min', 'add+max', 'add+mul', 'add+screen', 'one'
}
DG.blend[0] = #DG.blend

DG.style = {
    'arrow_big', 'arrow_mid', 'arrow_small', 'gun_bullet', 'butterfly', 'square',
    'ball_small', 'ball_mid', 'ball_mid_c', 'ball_big', 'ball_huge', 'ball_light',
    'star_small', 'star_big', 'grain_a', 'grain_b', 'grain_c', 'kite', 'knife', 'knife_b',
    'water_drop', 'mildew', 'ellipse', 'heart', 'money', 'music', 'silence',
    'water_drop_dark', 'ball_huge_dark', 'ball_light_dark'
}
DG.style[0] = #DG.style

DG.style_dark = {
    'arrow_big', 'arrow_mid', 'arrow_small', 'gun_bullet', 'butterfly', 'square',
    'ball_small', 'ball_mid', 'ball_mid_c', 'ball_big', 
    'star_small', 'star_big', 'grain_a', 'grain_b', 'grain_c', 'kite', 'knife', 'knife_b',
    'mildew', 'ellipse', 'heart', 'money', 'music', 'silence',
    'water_drop_dark', 'ball_huge_dark', 'ball_light_dark'
}
DG.style_dark[0] = #DG.style_dark