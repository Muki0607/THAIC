---=====================================
---THAIC LuaSDL Support v1.00a
---东方梦摇篮LuaSDL支持库 v1.00a
---=====================================

---本函数库部分代码使用Deepseek生成

---版本更新记录
---v1.00a
---初始版本

---@class aic.sdl @东方梦摇篮RPG支持库
aic.sdl = {}
local lib = aic.sdl

local ffi = require("ffi")
local bit = require("bit")

---@class cdata
---@class Window:cdata SDL_Window*
---@class Renderer:cdata SDL_Renderer*
---@class Rect:cdata SDL_Rect*
---@class Surface:cdata SDL_Surface*
---@class Texture:cdata SDL_Texture*
---@class Event:cdata SDL_Event*

-- 定义 SDL 函数和结构
ffi.cdef [[
    /* 完整的基本类型定义 */
    typedef int8_t   Sint8;
    typedef uint8_t  Uint8;
    typedef int16_t  Sint16;
    typedef uint16_t Uint16;
    typedef int32_t  Sint32;
    typedef uint32_t Uint32;
    typedef int64_t  Sint64;
    typedef uint64_t Uint64;
    
    /* 其他类型 */
    typedef uint32_t SDL_bool;
    typedef uint32_t SDL_Keycode;
    typedef uint32_t SDL_Scancode;

     /* 显示模式结构 */
    typedef struct {
        Uint32 format;
        int w;
        int h;
        int refresh_rate;
        void* driverdata;
    } SDL_DisplayMode;
    
    /* 事件结构 */
    typedef struct {
        Uint32 type;
        Uint32 timestamp;
    } SDL_CommonEvent;
    
    typedef struct {
        Uint32 type;
        Uint32 timestamp;
        Uint32 windowID;
        Uint8 event;
        Uint8 padding1;
        Uint8 padding2;
        Uint8 padding3;
        Sint32 data1;
        Sint32 data2;
    } SDL_WindowEvent;

    /* 键盘事件 */
    typedef struct {
        Uint32 scancode;
        Sint32 sym;
        Uint16 mod;
        Uint32 unused;
    } SDL_Keysym;

    typedef struct {
        Uint32 type;
        Uint32 timestamp;
        Uint32 windowID;
        Uint8 state;
        Uint8 repeat;
        Uint8 padding2;
        Uint8 padding3;
        SDL_Keysym keysym;
    } SDL_KeyboardEvent;

    /* 鼠标事件 */
    typedef struct {
        Uint32 type;
        Uint32 timestamp;
        Uint32 windowID;
        Uint32 which;
        Uint32 state;
        Sint32 x;
        Sint32 y;
        Sint32 xrel;
        Sint32 yrel;
    } SDL_MouseMotionEvent;
    
    typedef struct {
        Uint32 type;
        Uint32 timestamp;
        Uint32 windowID;
        Uint32 which;
        Uint8 button;
        Uint8 state;
        Uint8 clicks;
        Uint8 padding1;
        Sint32 x;
        Sint32 y;
    } SDL_MouseButtonEvent;
    
    typedef union {
        Uint32 type;
        SDL_CommonEvent common;
        SDL_WindowEvent window;
        SDL_KeyboardEvent key;
        SDL_MouseMotionEvent motion;
        SDL_MouseButtonEvent button;
        Uint8 padding[56];
    } SDL_Event;

    /* 窗口系统信息 */
    typedef struct SDL_SysWMinfo {
        struct {
            Uint32 major;
            Uint32 minor;
            Uint32 patch;
        } version;
        union {
            struct {
                void* window;  /* HWND */
                void* hdc;
                void* hinstance;
            } win;
            struct {
                void* display;
                void* window;
            } x11;
            struct {
                void* window;
            } cocoa;
            struct {
                void* window;
            } uikit;
        } info;
    } SDL_SysWMinfo;
    
    /* 基础函数声明 */
    int SDL_Init(Uint32 flags);
    const char* SDL_GetError(void);
    void SDL_Quit(void);
    void SDL_Delay(Uint32 ms);
    Uint32 SDL_GetTicks(void);

    /* 窗口管理 */
    typedef struct SDL_Window SDL_Window;
    SDL_Window* SDL_CreateWindow(const char* title, int x, int y, int w, int h, Uint32 flags);
    void SDL_DestroyWindow(SDL_Window* window);
    int SDL_PollEvent(SDL_Event* event);
    void SDL_GetWindowSize(SDL_Window* window, int* w, int* h);
    int SDL_GetWindowDisplayIndex(SDL_Window* window);
    int SDL_GetWindowWMInfo(SDL_Window* window, SDL_SysWMinfo* info);
    SDL_DisplayMode* SDL_GetDisplayMode(int x,SDL_DisplayMode* mode);


    /* 渲染器相关 */
    typedef struct SDL_Renderer SDL_Renderer;
    typedef struct SDL_Texture SDL_Texture;
    typedef struct SDL_Rect {
        int x, y;
        int w, h;
    } SDL_Rect;

    SDL_Renderer* SDL_CreateRenderer(SDL_Window* window, int index, Uint32 flags);
    void SDL_DestroyRenderer(SDL_Renderer* renderer);
    int SDL_SetRenderDrawColor(SDL_Renderer* renderer, Uint8 r, Uint8 g, Uint8 b, Uint8 a);
    int SDL_RenderClear(SDL_Renderer* renderer);
    int SDL_RenderDrawPoint(SDL_Renderer* renderer, int x, int y);
    int SDL_RenderDrawLine(SDL_Renderer* renderer, int x1, int y1, int x2, int y2);
    int SDL_RenderDrawRect(SDL_Renderer* renderer, const SDL_Rect* rect);
    int SDL_RenderFillRect(SDL_Renderer* renderer, const SDL_Rect* rect);
    void SDL_RenderPresent(SDL_Renderer* renderer);

    /* 表面与纹理 */
    typedef struct SDL_Surface SDL_Surface;
    SDL_Surface* SDL_LoadBMP(const char* file);
    SDL_Texture* SDL_CreateTextureFromSurface(SDL_Renderer* renderer, SDL_Surface* surface);
    void SDL_FreeSurface(SDL_Surface* surface);
    int SDL_QueryTexture(SDL_Texture* texture, Uint32* format, int* access, int* w, int* h);
    int SDL_RenderCopy(SDL_Renderer* renderer, SDL_Texture* texture, const SDL_Rect* srcrect, const SDL_Rect* dstrect);
    void SDL_DestroyTexture(SDL_Texture* texture);

    /* 其他功能 */
    Uint32 SDL_GetTicks(void);
    void SDL_GetWindowSize(SDL_Window* window, int* w, int* h);
    const char* SDL_GetKeyName(SDL_Keycode key);
    
]]

-- 加载 SDL2.dll
SDL2 = ffi.load("SDL2")

---SDL常量

-- 窗口
SDL_INIT_VIDEO = 0x00000020
SDL_WINDOWPOS_CENTERED = 0x2FFF0000
SDL_WINDOW_SHOWN = 0x00000004  
SDL_WINDOW_BORDERLESS = 0x00000010
SDL_WINDOW_FULLSCREEN_DESKTOP = 0x00001001
SDL_WINDOW_HIDDEN = 0x00000008

-- 渲染器标志
SDL_RENDERER_SOFTWARE     = 0x00000001
SDL_RENDERER_ACCELERATED  = 0x00000002
SDL_RENDERER_PRESENTVSYNC = 0x00000004

-- 事件类型
SDL_QUIT = 0x100
SDL_WINDOWEVENT = 0x200
SDL_WINDOWEVENT_CLOSE = 0x8
SDL_KEYDOWN      = 0x300
SDL_KEYUP        = 0x301
SDL_MOUSEMOTION  = 0x400
SDL_MOUSEBUTTONDOWN = 0x401
SDL_MOUSEBUTTONUP   = 0x402
SDL_MOUSEWHEEL      = 0x403  -- 新增鼠标滚轮事件

-- 鼠标滚轮方向
SDL_MOUSEWHEEL_NORMAL = 0
SDL_MOUSEWHEEL_FLIPPED = 1

-- 渲染器标志
SDL_RENDERER_SOFTWARE     = 0x00000001
SDL_RENDERER_ACCELERATED  = 0x00000002
SDL_RENDERER_PRESENTVSYNC = 0x00000004

-- 混合模式
SDL_BLENDMODE_NONE = 0x00000000
SDL_BLENDMODE_BLEND = 0x00000001
SDL_BLENDMODE_ADD = 0x00000002
SDL_BLENDMODE_MOD = 0x00000004

-- 键盘按键状态
SDL_PRESSED  = 1
SDL_RELEASED = 0

-- 鼠标按钮
SDL_BUTTON_LEFT   = 1
SDL_BUTTON_MIDDLE = 2
SDL_BUTTON_RIGHT  = 3
SDL_BUTTON_X1     = 4
SDL_BUTTON_X2     = 5

-- 光标显示状态
SDL_CURSOR_SHOW = 1
SDL_CURSOR_HIDE = 0

-- 临时参数
lib.WS_EX_LAYERED = 0x00080000
lib.LWA_COLORKEY = 0x00000001
lib.GWL_EXSTYLE = -20
lib.Running_Flag = false

---SDL初始化
function lib.Init()
    assert(SDL2.SDL_Init(SDL_INIT_VIDEO) == 0, ffi.string(SDL2.SDL_GetError()))
    Log(2, "[SDL] Initialized successfully.")
end
-- function lib.Init()
--     assert(SDL2.SDL_Init(SDL_INIT_VIDEO) == 0, ffi.string(SDL2.SDL_GetError()))
--     Log(2, string.format("[SDL] Current Version: SDL %d.%d.%d",
--         SDL.VERSION_MAJOR, SDL.VERSION_MINOR, SDL.VERSION_PATCH))
-- end

---创建窗口
---@param title string @窗口标题
---@param w number @窗口宽
---@param h number @窗口高
---@return Window
function lib.CreateWindow(title, w, h)
    w = w or 800
    h = h or 600
    local window = SDL2.SDL_CreateWindow(title, SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED, w, h, SDL_WINDOW_SHOWN)

    if window == nil then
        error('[SDL] ' .. ffi.string(SDL2.SDL_GetError()))
    end
    Log(2, '[SDL] Window ' .. title .. ' is created successfully.')
    Log(2, "Creating event task...")-- 调试日志
    lib.Maintask = New(tasker, function()
        Log(2, "Event task started")-- 调试日志
        -- 事件循环
        lib.Event = ffi.new("SDL_Event")
        lib.Running_Flag = true
        local event = lib.Event
        local keyname, button, mousex, mousey
        while SDL2.SDL_PollEvent(event) ~= 0 do
            if event.type == SDL_QUIT then
                lib.Running_Flag = false
            elseif event.type == SDL_WINDOWEVENT then
                if event.window.event == SDL_WINDOWEVENT_CLOSE then
                    lib.Running_Flag = false
                end
            elseif event.type == SDL_KEYDOWN then
                keyname = SDL2.SDL_GetKeyName(event.key.keysym.sym)
            elseif event.type == SDL_MOUSEBUTTONDOWN then
                button = event.button.button  -- 按钮ID (SDL_BUTTON_*)
                mousex, mousey = event.button.x, event.button.y
            end
            task.Wait()
        end
    end)
    return window
end

-- local test_task = New(tasker, function()
--     Log(2, "Test task is running")
--     task.Wait(60)
--     Log(2, "Test task completed")
-- end)

---@param window Window
---@return number, number
function lib.GetWindowSize(window)
    local w, h = ffi.new('int[1]'), ffi.new('int[1]')
    SDL2.SDL_GetWindowSize(window, w, h)
    return w[0], h[0]
    
end

---设置窗口标题
---@param window Window @窗口对象
---@param title string @新标题
function lib.SetWindowTitle(window, title)
    SDL2.SDL_SetWindowTitle(window, title)
end

---显示窗口
---@param window Window @窗口对象
function lib.ShowWindow(window)
    SDL2.SDL_ShowWindow(window)
end

---隐藏窗口
---@param window Window @窗口对象
function lib.HideWindow(window)
    SDL2.SDL_HideWindow(window)
end

---最大化窗口
---@param window Window @窗口对象
function lib.MaximizeWindow(window)
    SDL2.SDL_MaximizeWindow(window)
end

---最小化窗口
---@param window Window @窗口对象
function lib.MinimizeWindow(window)
    SDL2.SDL_MinimizeWindow(window)
end

---恢复窗口
---@param window Window @窗口对象
function lib.RestoreWindow(window)
    SDL2.SDL_RestoreWindow(window)
end

---等待一定时间，由于原函数单位为毫秒，会存在一定误差
---如果可以请尽量使用LuaSTG的task.Wait函数
---@param t number @等待时间，默认单位为帧
---@param is_ms boolean @是否使用毫秒为单位
function lib.Wait(t, is_ms)
    if is_ms then
        t = t or 1000 / 60
        SDL2.SDL_Delay(t)
    else
        t = t or 1
        SDL2.SDL_Delay(t * 1000 / 60)
    end
end

---@param window Window @窗口对象
---@param index number @索引，为-1时自动选择
---@param flags number 
---@return Renderer
function lib.CreateRenderer(window, index, flags)
    local renderer = SDL2.SDL_CreateRenderer(window, index, flags)
    if renderer == nil then
        error('[SDL] ' .. ffi.string(SDL2.SDL_GetError()))
    end
    return renderer
end


---设置渲染器逻辑尺寸
---@param renderer Renderer @渲染器对象
---@param w number @逻辑宽度
---@param h number @逻辑高度
function lib.RenderSetLogicalSize(renderer, w, h)
    assert(SDL2.SDL_RenderSetLogicalSize(renderer, w, h) == 0, 
        ffi.string(SDL2.SDL_GetError()))
end

---设置渲染器缩放
---@param renderer Renderer @渲染器对象
---@param scaleX number @X轴缩放
---@param scaleY number @Y轴缩放
function lib.RenderSetScale(renderer, scaleX, scaleY)
    assert(SDL2.SDL_RenderSetScale(renderer, scaleX, scaleY) == 0, 
        ffi.string(SDL2.SDL_GetError()))
end

---获取渲染器缩放
---@param renderer Renderer @渲染器对象
---@return number, number @X轴缩放, Y轴缩放
function lib.RenderGetScale(renderer)
    local scaleX, scaleY = ffi.new('float[1]'), ffi.new('float[1]')
    SDL2.SDL_RenderGetScale(renderer, scaleX, scaleY)
    return scaleX[0], scaleY[0]
end

---设置纹理颜色调制
---@param texture Texture @纹理对象
---@param r number @红色分量 (0-255)
---@param g number @绿色分量 (0-255)
---@param b number @蓝色分量 (0-255)
function lib.SetTextureColorMod(texture, r, g, b)
    assert(SDL2.SDL_SetTextureColorMod(texture, r, g, b) == 0, 
        ffi.string(SDL2.SDL_GetError()))
end

---设置纹理透明度
---@param texture Texture @纹理对象
---@param alpha number @透明度 (0-255)
function lib.SetTextureAlphaMod(texture, alpha)
    assert(SDL2.SDL_SetTextureAlphaMod(texture, alpha) == 0, 
        ffi.string(SDL2.SDL_GetError()))
end

---设置纹理混合模式
---@param texture Texture @纹理对象
---@param blendMode number @混合模式常量
function lib.SetTextureBlendMode(texture, blendMode)
    assert(SDL2.SDL_SetTextureBlendMode(texture, blendMode) == 0, 
        ffi.string(SDL2.SDL_GetError()))
end

---@param renderer Renderer
---@param a number
---@param r number
---@param g number
---@param b number
function lib.SetRenderDrawColor(renderer, a, r, g, b)
    SDL2.SDL_SetRenderDrawColor(renderer, r, g, b, a)
end

function lib.RenderClear(renderer)
    assert(SDL2.SDL_RenderClear(renderer) == 0, 
        ffi.string(SDL2.SDL_GetError()))
end

---@param x number
---@param y number
---@param w number
---@param h number
---@return Rect
function lib.CreateRect(x, y, w, h)
    local param = {}
    param.x = x
    param.y = y
    param.w = w
    param.h = h
    local rect = ffi.new('SDL_Rect', param)
    if rect == nil then
        error('[SDL] ' .. ffi.string(SDL2.SDL_GetError()))
    end
    return rect
end

---@param renderer Renderer
---@param rect Rect
function lib.RenderDrawRect(renderer, rect)
    SDL2.SDL_RenderDrawRect(renderer, rect)
end

---@param renderer Renderer
---@param rect Rect
---@overload fun(render:Renderer)
function lib.RenderFillRect(renderer, rect)
    SDL2.SDL_RenderFillRect(renderer, rect)
end

---@param renderer Renderer
function lib.RenderPresent(renderer)
    SDL2.SDL_RenderPresent(renderer)
end

---设置渲染剪裁区域
---@param renderer Renderer @渲染器对象
---@param rect Rect|nil @剪裁区域，nil表示取消剪裁
function lib.RenderSetClipRect(renderer, rect)
    if rect then
        SDL2.SDL_RenderSetClipRect(renderer, rect)
    else
        -- 传递NULL指针取消剪裁
        SDL2.SDL_RenderSetClipRect(renderer, nil)
    end
end

---获取渲染剪裁区域
---@param renderer Renderer @渲染器对象
---@return Rect @剪裁区域
function lib.RenderGetClipRect(renderer)
    local rect = ffi.new('SDL_Rect')
    SDL2.SDL_RenderGetClipRect(renderer, rect)
    return rect
end

---@param file string
---@return Surface
function lib.LoadBMP(file)
    local surface = SDL2.SDL_LoadBMP(file)
    if surface == nil then
        error('[SDL] ' .. ffi.string(SDL2.SDL_GetError()))
    end
    return surface
end

---表面复制
---@param src Surface @源表面
---@param srcrect Rect|nil @源区域
---@param dst Surface @目标表面
---@param dstrect Rect|nil @目标区域
function lib.BlitSurface(src, srcrect, dst, dstrect)
    assert(SDL2.SDL_BlitSurface(src, srcrect, dst, dstrect) == 0, 
        ffi.string(SDL2.SDL_GetError()))
end

---填充表面区域
---@param surface Surface @表面对象
---@param rect Rect|nil @填充区域，nil表示整个表面
---@param color number @颜色值 (RGBA格式)
function lib.FillRect(surface, rect, color)
    assert(SDL2.SDL_FillRect(surface, rect, color) == 0, 
        ffi.string(SDL2.SDL_GetError()))
end


---@param renderer Renderer
---@param surface Surface
---@return Texture
function lib.CreateTextureFromSurface(renderer, surface)
    local texture = SDL2.SDL_CreateTextureFromSurface(renderer, surface)
    if texture == nil then
        error('[SDL] ' .. ffi.string(SDL2.SDL_GetError()))
    end
    return texture
end

---@param surface Surface
function lib.FreeSurface(surface)
    SDL2.SDL_FreeSurface(surface)
end

---@param renderer Renderer
---@param texture Texture
---@param srcrect Rect
---@param dstrect Rect
function lib.RenderCopy(renderer, texture, srcrect, dstrect)
    if srcrect and dstrect then
        SDL2.SDL_RenderCopy(renderer, texture, srcrect, dstrect)
    elseif srcrect then
        SDL2.SDL_RenderCopy(renderer, texture, srcrect, nil)
    elseif dstrect then
        SDL2.SDL_RenderCopy(renderer, texture, nil, dstrect)
    else
        SDL2.SDL_RenderCopy(renderer, texture, nil, nil)
    end
end

---@param texture Texture
function lib.QueryTexture(texture)
    local format, access, width, height =
        ffi.new('Uint32[1]'), ffi.new('int[1]'), ffi.new('int[1]'), ffi.new('int[1]')
    SDL2.SDL_QueryTexture(texture, format, access, width, height)
    return format[0], access[0], width[0], height[0]
end

---获取键盘状态
---@return table @键盘状态表
function lib.GetKeyboardState()
    local numkeys = ffi.new("int[1]")
    local state = SDL2.SDL_GetKeyboardState(numkeys)
    local keystate = {}
    
    for i = 0, numkeys[0] - 1 do
        keystate[i] = state[i] ~= 0
    end
    
    return keystate, numkeys[0]
end

---获取鼠标状态
---@return number, number, number @按钮状态, X坐标, Y坐标
function lib.GetMouseState()
    local x, y = ffi.new('int[1]'), ffi.new('int[1]')
    local state = SDL2.SDL_GetMouseState(x, y)
    return state, x[0], y[0]
end

---获取相对鼠标状态
---@return number, number, number @按钮状态, X相对移动, Y相对移动
function lib.GetRelativeMouseState()
    local x, y = ffi.new('int[1]'), ffi.new('int[1]')
    local state = SDL2.SDL_GetRelativeMouseState(x, y)
    return state, x[0], y[0]
end

---设置鼠标位置
---@param window Window @窗口对象
---@param x number @X坐标
---@param y number @Y坐标
function lib.WarpMouseInWindow(window, x, y)
    SDL2.SDL_WarpMouseInWindow(window, x, y)
end

---显示或隐藏光标
---@param toggle number @SDL_CURSOR_SHOW 或 SDL_CURSOR_HIDE
---@return number @之前的显示状态
function lib.ShowCursor(toggle)
    return SDL2.SDL_ShowCursor(toggle)
end

---启用或禁用鼠标捕获
---@param enabled boolean @是否启用
function lib.CaptureMouse(enabled)
    local sdl_bool = enabled and 1 or 0
    assert(SDL2.SDL_CaptureMouse(sdl_bool) == 0, 
        ffi.string(SDL2.SDL_GetError()))
end

---设置SDL提示
---@param name string @提示名称
---@param value string @提示值
---@return boolean @是否设置成功
function lib.SetHint(name, value)
    return SDL2.SDL_SetHint(name, value) == 1
end

---@param renderer Renderer
function lib.DestroyRenderer(renderer)
    SDL2.SDL_DestroyRenderer(renderer)
end


---@param texture Texture
function lib.DestroyTexture(texture)
    SDL2.SDL_DestroyTexture(texture)
end

---@param window Window @窗口对象
function lib.DestroyWindow(window)
    SDL2.SDL_DestroyWindow(window)
end

function lib.Quit()
    SDL2.SDL_Quit()
    Log(2, "[SDL] SDL shutdown successfully.")
end


---创建全屏无边框透明窗口
---@param title string @窗口标题
---@param transparent_color number @透明色 (0xRRGGBB 格式)
---@return Window, Renderer
function lib.CreateTransparentWindow(title, transparent_color)
    -- 设置窗口标志：无边框 + 全屏桌面

    local flags = bit.bor(SDL_WINDOW_BORDERLESS, SDL_WINDOW_FULLSCREEN_DESKTOP)

    Log(2, "[SDL] test_for_existence")
    -- 获取屏幕尺寸
    local mode

    if SDL2.SDL_GetDisplayMode(0, mode) == 0 then
        -- 获取屏幕宽高
        local w, h = mode.w, mode.h
        Log(2, string.format("[SDL] Desktop mode: %dx%d", w, h))
    else
        error('Failed to get desktop display mode: ' .. ffi.string(SDL2.SDL_GetError()))
    end
    
    -- 创建窗口
    local window = SDL2.SDL_CreateWindow(title, 
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 
        mode.w, mode.h, flags)
    
    if window == nil then
        error('CreateWindow failed: ' .. ffi.string(SDL2.SDL_GetError()))
    end
    
    Log(2, string.format('[SDL] Created transparent window: %dx%d', w, h))
    
    -- 设置窗口透明
    if ffi.os == "Windows" then
        lib.SetWindowTransparent(window, transparent_color)
    else
        Log(1, "[SDL] Transparency only supported on Windows")
    end
    
    -- 创建渲染器（必须使用软件渲染器）
    local renderer = lib.CreateRenderer(window, -1, SDL_RENDERER_SOFTWARE)
    
    -- 初始化运行标志
    lib.Running_Flag = true
    
    -- 设置透明色（用于后续渲染）
    lib.TransparentColor = transparent_color
    
    return window, renderer
end

---设置窗口透明（Windows平台）
---@param window Window @窗口对象
---@param color_key number @透明色 (0xRRGGBB 格式)
function lib.SetWindowTransparent(window, color_key)
    if ffi.os ~= "Windows" then return end
    
    local wmInfo = ffi.new("SDL_SysWMinfo")
    wmInfo.version = {
        major = 2,
        minor = 0,
        patch = 16
    }
    
    if SDL2.SDL_GetWindowWMInfo(window, wmInfo) ~= 0 then
        local hwnd = wmInfo.info.win.window
        
        -- 获取当前扩展样式
        local ex_style = ffi.C.GetWindowLongA(hwnd, lib.GWL_EXSTYLE)
        
        -- 添加分层窗口属性
        ffi.C.SetWindowLongA(hwnd, lib.GWL_EXSTYLE, bit.bor(ex_style, lib.WS_EX_LAYERED))
        
        -- 设置透明色
        ffi.C.SetLayeredWindowAttributes(hwnd, color_key, 0, lib.LWA_COLORKEY)
        
        Log(2, "[SDL] Window transparency set with color key: 0x" .. string.format("%06X", color_key))
    else
        Log(1, "[SDL] Failed to get window handle for transparency")
    end
end

---创建渲染器（针对透明窗口优化）
---@param window Window @窗口对象
---@param index number @索引，为-1时自动选择
---@param flags number 
---@return Renderer
function lib.CreateRenderer(window, index, flags)
    index = index or -1
    flags = flags or SDL_RENDERER_SOFTWARE
    
    local renderer = SDL2.SDL_CreateRenderer(window, index, flags)
    
    if renderer == nil then
        error('CreateRenderer failed: ' .. ffi.string(SDL2.SDL_GetError()))
    end
    
    -- 禁用混合模式（重要！）
    ffi.C.SDL_SetRenderDrawBlendMode(renderer, 0)  -- SDL_BLENDMODE_NONE
    
    Log(2, "[SDL] Renderer created for transparent window")
    return renderer
end

---设置渲染颜色（支持透明色检查）
---@param renderer Renderer
---@param r number
---@param g number
---@param b number
---@param a number
function lib.SetRenderDrawColor(renderer, a, r, g, b)
    -- 避免使用透明色
    if lib.TransparentColor then
        local color = bit.bor(bit.lshift(r, 16), bit.lshift(g, 8), b)
        if color == lib.TransparentColor then
            Log(3, "Warning: Using transparent color for drawing")
        end
    end
    
    SDL2.SDL_SetRenderDrawColor(renderer, r, g, b, a)
end

---清屏（使用透明色）
---@param renderer Renderer
function lib.ClearWithTransparent(renderer)
    if not lib.TransparentColor then return end
    
    -- 提取透明色的RGB分量
    local r = bit.band(bit.rshift(lib.TransparentColor, 16), 0xFF)
    local g = bit.band(bit.rshift(lib.TransparentColor, 8), 0xFF)
    local b = bit.band(lib.TransparentColor, 0xFF)
    
    SDL2.SDL_SetRenderDrawColor(renderer, r, g, b, 255)
    SDL2.SDL_RenderClear(renderer)
end