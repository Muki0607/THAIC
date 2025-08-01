---=====================================
---东方梦摇篮 debug功能控制
---THAIC Debug Function Control
---=====================================

---以下功能为本游戏的debug功能，开启后不保证游戏稳定运行
---true为开启，false为关闭
---请不要改动true和false以外的字符，否则可能导致游戏报错

_debug = {
    _debug = true, --启用debug功能，该项为false则将下列项全部视为false
    debug_tool = true, --F1键开启修改器
    imgui = true, --F3键开启imgui debug工具
    hana_ai = false, --F7键开启HanaAI
    cheat = true, --F12键开启无敌
    collicheck = true, --~键开启判定显示
    skip_opening = false, --跳过开场加载界面（也可按ESC键跳过）
    skip_loading = false, --跳过转场加载界面（也可按S键跳过）
    enhancer_debug = false, --插件选择界面debug，显示光标位置与插件编号
    bgm_debug = false, --bgm名debug，显示所有bgm名
    music_room_debug = false, --音乐室debug，显示相关信息
    old_title = false, --启用lstg旧版title
    new_title = false, --启用lstg新版title（使用菜单栈制作，仍处于调试状态），会覆盖old_title
    full_title = true, --显示完整窗口标题信息（包括FPS，Obj数信息）
    pmode = false, --将珠辉的笔记本替换为正式版的版本（开启完美无缺模式），此模式稳定性未经检验，极容易出错，请谨慎使用
    exception_handler_disabled = true, --关闭异常捕获，方便debug
    l10n_tryexcept_disabled = false,
}
