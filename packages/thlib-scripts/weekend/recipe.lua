do
    local old = FrameFunc
    function FrameFunc()
        local ref = old()
        achi.ShowFrame()
        return ref
    end
end

do
    local old = AfterRender
    function AfterRender()
        old()
        SetViewMode "ui"
        achi.ShowRender(576, 240)
    end
end

if item_bar then
    if item_bar.is_class then
        local old = item_bar.init
        function item_bar:init(...)
            old(self, ...)
            Del(self)
        end
    end
end