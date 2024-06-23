stage_init = stage.New('init', true, true)
function stage_init:init()
    New(menu.menuObj)
    menu.resetMenu()
    local menu_player_select = menu.simpleMenu.create('player_select', "Select Player")
    for i, v in ipairs(player_list) do
        menu_player_select:addItem({
            name = player_list[i][1],
            func = function()
                lstg.var.player_name = player_list[i][2]
                lstg.var.rep_player = player_list[i][3]
                task.New(stage_init, function()
                    menu.rawFlyOut()
                    task.Wait(30)
                    New(mask_fader, 'close')
                    task.Wait(30)
                    stage.group.PracticeStart(_debug_stage_name)
                end)
            end
        })
    end
    New(mask_fader, 'open')
    menu.flyIn(menu_player_select)
end

function stage_init:render()
    ui.DrawMenuBG()
end
