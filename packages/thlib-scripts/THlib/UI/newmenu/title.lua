---THAIC Arranged
if _debug.new_title then
    stage_init = stage.New('init', true, true)
    function stage_init:init()
        New(mask_fader, 'open')
    end

    function stage_init:frame()
        if self.timer >= 30 then
            stage.Set('menu', 'none')
        end
    end

    function stage_init:render()
        ui.DrawMenuBG()
    end

    MusicRecord("menu", 'THlib/music/Muki_AiC_bgm1.ogg', 7090800 / 44100, 3351600 / 44100)
    --MusicRecord("menu", 'THlib/music/luastg 0.08.540 - 1.27.800.ogg', 87.8, 79.26)
    MusicRecord("spellcard", 'THlib/music/spellcard.ogg', 75, 0xc36e80 / 44100 / 4)
    ---bgm淡入
    ---@param bgm_name string
    ---@param time integer
    local function bgm_smooth_in(bgm_name, time)
        for i = 1, time do
            SetBGMVolume(bgm_name, i / time)
            task.Wait()
        end
    end

    ---bgm淡出
    ---@param bgm_name string
    ---@param time integer
    local function bgm_smooth_out(bgm_name, time)
        for i = 1, time do
            SetBGMVolume(bgm_name, 1 - i / time)
            task.Wait()
        end
    end


    stage_menu = stage.New('menu', false, true)

    function stage_menu:init()
        New(menu.menuObj)
        menu.resetMenu()
        -- 定义一些用于菜单的变量
        local menu_title, menu_player_select, menu_difficulty_select, menu_difficulty_select_pr, menu_replay_loader, menu_replay_saver, menu_items, menu_sc_pr
        local menu_practice

        -- 记录入口名称的变量
        local entrance_name = ""

        -- 检查是否为标题标志第一次出现
        if _title_flag == nil then
            _title_flag = true
        else
            -- 如果不是第一次出现标题标志，执行一个淡入效果
            New(mask_fader, 'open')
        end

        -- 定义退出游戏的函数
        local function ExitGame()
            task.New(stage_menu, function()
                menu.rawFlyOut()
            end)
            -- 创建一个新任务，在菜单阶段执行背景音乐平滑淡出
            task.New(stage_menu, function()
                bgm_smooth_out("menu", 59)
            end)

            -- 创建一个新任务，在菜单阶段等待60帧后退出游戏
            task.New(stage_menu, function()
                task.Wait(60)
                stage.QuitGame()
            end)
        end

        -- 创建标题菜单对象
        menu_title = menu.simpleMenu.create("menu_title", "")

        -- 添加“开始游戏”选项
        menu_title:addItem({
            name = 'Start Game',
            func = function(self)
                practice = nil
                menu.flyIn(menu_difficulty_select)
            end
        })

        -- 如果允许练习，添加“关卡练习”选项
        if _allow_practice then
            menu_title:addItem({
                name = 'Stage Practice',
                func = function(self)
                    practice = 'stage'
                    menu.flyIn(menu_difficulty_select_pr)
                end
            })
        end

        -- 如果允许符卡练习，添加“符卡练习”选项
        if _allow_sc_practice then
            menu_title:addItem({
                name = 'Spell Practice',
                func = function(self)
                    practice = 'spell'
                    menu.flyIn(menu_sc_pr)
                end
            })
        end

        -- 添加“查看重放”选项
        menu_title:addItem({
            name = 'View Replay',
            func = function(self)
                menu_replay_loader:Refresh()
                menu.flyIn(menu_replay_loader)
            end
        })

        -- 添加“退出游戏”选项，并关联退出游戏函数
        menu_title:addItem({ name = 'Exit Game', func = ExitGame })

        -- 添加“退出”选项，根据当前光标位置执行退出游戏或移动光标
        menu_title:addItem({
            name = 'exit',
            func = function(self)
                if self:getItemPosition() == self.itemCount then
                    ExitGame()
                else
                    self.pos = self.itemCount
                end
            end
        }) -- 创建难度选择菜单对象
        menu_difficulty_select = menu.simpleMenu.create("menu_difficulty_select", "Select Difficulty")

        -- 遍历关卡组，为每个非“Spell Practice”组添加选项
        for _, name in ipairs(stage.groups) do
            if name ~= 'Spell Practice' then
                menu_difficulty_select:addItem({
                    name = name,
                    func = function(self)
                        -- 设置分数数据的难度选择，并记录入口名称
                        scoredata.difficulty_select = self.pos
                        entrance_name = name
                        -- 跳转到玩家选择菜单
                        menu.flyIn(menu_player_select)
                    end
                })
            end
        end

        -- 添加“退出”选项，用于返回上一级菜单
        menu_difficulty_select:addItem({
            name = 'exit',
            func = function(self)
                menu.flyOut()
            end
        })

        -- 设置难度选择菜单的初始位置为上一次选择的难度或默认为1
        menu_difficulty_select.pos = scoredata.difficulty_select or 1

        ---- 创建玩家选择菜单对象
        menu_player_select = menu.simpleMenu.create("menu_player_select", "Select Player")

        -- 遍历玩家列表，为每个玩家添加选项
        for i, v in ipairs(player_list) do
            menu_player_select:addItem({
                name = player_list[i][1],
                func = function(self)
                    -- 记录玩家选择的位置
                    scoredata.player_select = i

                    -- 设置游戏变量中的玩家名称和重放玩家
                    lstg.var.player_name = player_list[i][2]
                    lstg.var.rep_player = player_list[i][3]

                    -- 创建新任务，在菜单阶段执行背景音乐平滑淡出
                    task.New(stage_menu, function()
                        bgm_smooth_out("menu", 59)
                    end)

                    -- 创建新任务，在菜单阶段等待一段时间后执行以下操作
                    task.New(stage_menu, function()
                        task.Wait(30)

                        -- 创建一个新的蒙版淡出效果
                        New(mask_fader, 'close')

                        -- 等待一段时间
                        task.Wait(30)

                        -- 根据练习类型执行不同的操作
                        if practice == 'stage' then
                            -- 关卡练习
                            stage.group.PracticeStart(entrance_name)
                        elseif practice == 'spell' then
                            -- 符卡练习
                            stage.IsSCpractice = true -- 判定进入符卡练习的 flag，由 OLC 添加
                            stage.group.PracticeStart('Spell Practice@Spell Practice')
                        else
                            -- 普通关卡开始
                            stage.group.Start(stage.groups[entrance_name])
                        end
                    end)
                end
            })
        end

        -- 添加“退出”选项，用于返回上一级菜单
        menu_player_select:addItem({
            name = 'exit',
            func = function(self)
                menu.flyOut()
            end
        })

        -- 设置玩家选择菜单的初始位置为上一次选择的玩家或默认为1
        menu_player_select.pos = scoredata.player_select or 1
        --
        -- 创建关卡练习模式中的难度选择菜单对象
        menu_difficulty_select_pr = menu.simpleMenu.create("menu_difficulty_select_pr", "Select Difficulty")

        -- 遍历关卡组，为每个允许练习的组添加选项
        for i, sg in ipairs(stage.groups) do
            if stage.groups[sg].allow_practice then
                menu_difficulty_select_pr:addItem({
                    name = sg,
                    func = function()
                        -- 进入相应的关卡练习菜单
                        menu.flyIn(string.format("menu_practice_%s", sg))
                    end
                })
            end
        end

        -- 添加“退出”选项，用于返回上一级菜单
        menu_difficulty_select_pr:addItem({
            name = 'exit',
            func = function(self)
                menu.flyOut()
            end
        })


        --
        -- 遍历关卡组
        for _, sg in ipairs(stage.groups) do
            -- 检查关卡组是否允许练习
            if stage.groups[sg].allow_practice then
                -- 创建关卡练习菜单对象
                menu_practice = menu.simpleMenu.create(string.format("menu_practice_%s", sg), "Select Stage")

                -- 遍历关卡组中的关卡
                for _, s in ipairs(stage.groups[sg]) do
                    -- 检查关卡是否允许练习
                    if stage.stages[s].allow_practice then
                        menu_practice:addItem({
                            name = string.match(s, "^[%w_][%w_ ]*"),
                            func = function()
                                -- 进入玩家选择菜单
                                menu.flyIn(menu_player_select)
                                entrance_name = s
                            end
                        })
                    end
                end
                menu_practice:addItem({
                    name = 'exit',
                    func = function(self)
                        menu.flyOut()
                    end
                })
                --[[
                menu_practice[sg].stage_name = {}
                for _, s in ipairs(stage.groups[sg]) do
                    if stage.stages[s].allow_practice then
                        table.insert(menu_practice[sg].stage_name, s)
                    end
                end
                ]]
            end
        end

        --
        -- 创建符卡练习模式中的符卡选择菜单对象
        menu_sc_pr = menu.ScprMenu.create(function(index)
            -- 检查是否存在符卡索引
            if index then
                -- 设置全局变量中的符卡索引
                lstg.var.sc_index = index
                -- 进入玩家选择菜单
                menu.flyIn(menu_player_select)
            else
                -- 退出符卡选择菜单
                menu.flyOut()
            end
        end)


        --
        -- 创建重放加载菜单对象
        menu_replay_loader = menu.replayLoaderMenu.create(function(filename, stageName)
            -- 获取重放文件名和关卡名

            -- 检查是否存在重放文件名
            if not filename then
                -- 退出重放加载菜单
                menu.flyOut()
            else
                -- 创建新任务，在菜单阶段执行背景音乐平滑淡出
                task.New(stage_menu, function()
                    bgm_smooth_out("menu", 59)
                end)

                -- 创建新任务，在菜单阶段等待一段时间后执行以下操作
                task.New(stage_menu, function()
                    -- 调用原始的菜单退出函数
                    menu.rawFlyOut()
                    task.Wait(30)

                    -- 创建一个新的蒙版淡出效果
                    New(mask_fader, 'close')
                    task.Wait(30)

                    -- 在控制台打印重放文件名和关卡名
                    Print(filename, stageName)

                    -- 设置进入重放模式的标志
                    stage.IsReplay = true -- 判定进入 rep 播放的 flag，由 OLC 添加

                    -- 调用引擎的设置函数，加载指定的重放文件和关卡
                    stage.Set(stageName, 'load', filename)
                end)
            end
        end)


        -- 定义任务函数，用于初始化菜单
        local task_menu_init = function()
            menu.flyIn(menu_title)
        end

        -- 定义任务函数，用于初始化符卡选择菜单
        local sc_init = function(self)
            -- 由 OLC 添加的符卡初始化函数
            self.pos = lstg.var.sc_index
            self.page = int(lstg.var.sc_index / ui.menu.sc_pr_line_per_page)
            self.pos_changed = ui.menu.shake_time
        end
        -- 进入菜单的处理
        if stage.IsReplay then
            -- 如果是 rep 播放，返回 rep 菜单
            menu.menuStack:Push(menu_title)
            stage.IsReplay = nil
            menu_replay_loader:Refresh()
            menu.flyIn(menu_replay_loader)
        elseif stage.IsSCpractice then
            -- 如果是符卡练习，返回符卡练习菜单
            stage.IsSCpractice = nil

            menu.menuStack:Push(menu_title)
            -- 检查是否有保存 rep 的需求
            if self.save_replay then
                menu.menuStack:Push(menu_sc_pr)
                -- 创建 rep 保存菜单
                menu_replay_saver = menu.replaySaverMenu.create(self.save_replay, self.finish,
                    function(self)
                        -- 返回符卡练习菜单并初始化符卡选择菜单
                        menu.flyOut()
                        sc_init(menu_sc_pr)
                    end)
                -- 进入 rep 保存菜单
                menu.flyIn(menu_replay_saver)
            else
                -- 直接返回符卡练习菜单并初始化符卡选择菜单
                menu.flyIn(menu_sc_pr)
                sc_init(menu_sc_pr)
            end
        else
            -- 正常返回菜单
            if self.save_replay then
                -- 如果有保存 rep 的需求，创建 rep 保存菜单
                menu_replay_saver = menu.replaySaverMenu.create(self.save_replay, self.finish,
                    function()
                        -- 退出菜单，并在一定时间后重新初始化菜单
                        menu.flyOut()
                        task.New(stage_menu, function()
                            task.Wait(30)
                            task.New(stage_menu, task_menu_init)
                        end)
                    end)
                -- 进入 rep 保存菜单
                menu.flyIn(menu_replay_saver)
            else
                -- 如果没有保存 rep 的需求，直接初始化菜单
                task.New(stage_menu, task_menu_init)
            end
        end


        task.New(self, function()
            --延迟几帧加载bgm避免奇怪的黑块问题--然并乱，草死
            task.Wait(1)
            LoadMusicRecord("menu")
            PlayMusic('menu')
        end)

        menu_list = { menu_title, menu_player_select, menu_difficulty_select, menu_replay_loader, menu_replay_saver,
            menu_items, menu_sc_pr, menu_network, menu_player_select2, menu_player_select1, menu_playercount } --设置菜单对象表
    end

    function stage_menu:render()
        ui.DrawMenuBG()
        for i = 1, #menu.menuStack do
            SetFontState("menu", "", Color(255, 255, 255, 255))
            RenderText("menu", menu.menuStack[i].name, 0, -180 + i * 30, 0.5, "centerpoint")
        end
    end
end
