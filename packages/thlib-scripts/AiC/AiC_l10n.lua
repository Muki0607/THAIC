---=====================================
---THAIC Localization v1.00a
---东方梦摇篮本土化 v1.00a
---=====================================

---版本更新记录
---v1.00a
---初始版本

---@class aic.l10n @东方梦摇篮本土化
aic.l10n = {}
local lib = aic.l10n

---localization，简写为l10n（l和n之间有10个字母）。
---直译为"本土化"（不建议译为"本地化"，因为本地这个词往往对应的是远程/在线），
---是包括但不限于文本翻译（往往还涉及到数字/日期/时间的格式调整、民间计量单位的换算等）的一项重要工作。
---————《厨圣的高级修养——Alice in Cradle的localization语法》

---可用的语言
lib.lang = {}
---游戏UI与系统所用文字
aic.l10n.ui = {}
---对话所用文字
aic.l10n.dialog = {}

---初始化语言
---@param formal_name string @正式名称，需要和文件夹名相同
---@param simplified_name string @简化名称（两个大写字母）
---@param full_name string @全名（将会在游戏中显示）
function lib.init(formal_name, simplified_name, full_name)
    lib.lang[formal_name] = { simplified_name, full_name }
end

function lib.load_lang()
    for lang, _ in pairs(lib.lang) do
        for _, file in ipairs({ "AiC_dialog_text.lua", "AiC_ui_text.lua" }) do
            aic.py.TryExcept(function()
                    DoFile("THlib/" .. lang .. "/" .. file)
                end,
                {
                    [""] = function()
                        lstg.MsgBoxWarn("加载语言 " .. lib.lang[lang][2] .. " 时发现文件 " .. file
                            .. " 丢失或出错。\n请检查该文件是否被移动、删除或修改。\n若无法找到文件，请重新下载游戏。\n若文件存在且重启游戏后仍然出现此提示框，请报告作者。")
                    end
                })
        end
    end
end
