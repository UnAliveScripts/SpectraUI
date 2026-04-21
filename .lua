-- ============================================================
--  Spectra UI Library  |  v1.0.0
--  A sleek, glassmorphism-inspired Roblox UI library
--  Supports: Windows, Tabs, Toggles, Sliders, Buttons,
--             Dropdowns, Text Inputs, Labels, Dividers
-- ============================================================

local Spectra = {}
Spectra.__index = Spectra

-- ─── Services ─────────────────────────────────────────────
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")

local LocalPlayer  = Players.LocalPlayer
local Mouse        = LocalPlayer:GetMouse()
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

-- ─── Theme ────────────────────────────────────────────────
local Theme = {
    -- Backgrounds
    Background       = Color3.fromRGB(18, 18, 22),
    BackgroundSecond = Color3.fromRGB(24, 24, 30),
    Surface          = Color3.fromRGB(30, 30, 38),
    SurfaceHover     = Color3.fromRGB(38, 38, 48),
    SurfaceActive    = Color3.fromRGB(44, 44, 56),

    -- Sidebar
    Sidebar          = Color3.fromRGB(14, 14, 18),
    SidebarIcon      = Color3.fromRGB(120, 120, 140),
    SidebarIconActive= Color3.fromRGB(255, 255, 255),

    -- Accent (blue)
    Accent           = Color3.fromRGB(80, 160, 255),
    AccentDark       = Color3.fromRGB(50, 110, 200),
    AccentGlow       = Color3.fromRGB(40, 100, 200),

    -- Text
    TextPrimary      = Color3.fromRGB(230, 230, 240),
    TextSecondary    = Color3.fromRGB(140, 140, 160),
    TextDisabled     = Color3.fromRGB(80, 80, 100),

    -- Toggle
    ToggleOff        = Color3.fromRGB(50, 50, 64),
    ToggleOn         = Color3.fromRGB(80, 160, 255),
    ToggleKnob       = Color3.fromRGB(255, 255, 255),

    -- Slider
    SliderTrack      = Color3.fromRGB(40, 40, 52),
    SliderFill       = Color3.fromRGB(80, 160, 255),
    SliderKnob       = Color3.fromRGB(255, 255, 255),

    -- Borders
    Border           = Color3.fromRGB(45, 45, 60),
    BorderLight      = Color3.fromRGB(60, 60, 80),

    -- Scrollbar
    Scrollbar        = Color3.fromRGB(55, 55, 72),

    -- Misc
    Shadow           = Color3.fromRGB(0, 0, 0),
    Separator        = Color3.fromRGB(40, 40, 52),
}

-- ─── Tween Helper ─────────────────────────────────────────
local function Tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ─── Make Draggable ───────────────────────────────────────
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos = false, nil, nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ─── Corner Helper ────────────────────────────────────────
local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function Padding(parent, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 8)
    p.PaddingRight  = UDim.new(0, right  or 8)
    p.PaddingBottom = UDim.new(0, bottom or 8)
    p.PaddingLeft   = UDim.new(0, left   or 8)
    p.Parent = parent
    return p
end

-- ─── Icons (TextLabel Unicode) ────────────────────────────
local Icons = {
    Home     = "⌂",
    Settings = "⚙",
    Player   = "👤",
    World    = "🌐",
    Script   = "{}",
    Visual   = "◈",
    Misc     = "⋯",
    Close    = "✕",
    Minimize = "−",
    Search   = "⌕",
}

-- ══════════════════════════════════════════════════════════
--  Spectra.new  –  Create a new library window
-- ══════════════════════════════════════════════════════════
function Spectra.new(title, subtitle)
    title    = title    or "Spectra"
    subtitle = subtitle or "v1.0"

    local self = setmetatable({}, Spectra)
    self._tabs      = {}
    self._activeTab = nil

    -- ── ScreenGui ────────────────────────────────────────
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name             = "SpectraUI"
    ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn     = false
    ScreenGui.IgnoreGuiInset   = true
    ScreenGui.Parent           = PlayerGui

    -- ── Main Window ──────────────────────────────────────
    local Window = Instance.new("Frame")
    Window.Name            = "Window"
    Window.Size            = UDim2.new(0, 820, 0, 520)
    Window.Position        = UDim2.new(0.5, -410, 0.5, -260)
    Window.BackgroundColor3 = Theme.Background
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.Parent          = ScreenGui
    Corner(Window, 12)
    Stroke(Window, Theme.Border, 1)

    -- Drop shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Position = UDim2.new(0, -20, 0, -10)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.ZIndex = 0
    Shadow.Parent = Window

    -- ── Sidebar ──────────────────────────────────────────
    local Sidebar = Instance.new("Frame")
    Sidebar.Name            = "Sidebar"
    Sidebar.Size            = UDim2.new(0, 54, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex          = 2
    Sidebar.Parent          = Window

    -- Sidebar right border
    local SidebarBorder = Instance.new("Frame")
    SidebarBorder.Size             = UDim2.new(0, 1, 1, 0)
    SidebarBorder.Position         = UDim2.new(1, -1, 0, 0)
    SidebarBorder.BackgroundColor3 = Theme.Border
    SidebarBorder.BorderSizePixel  = 0
    SidebarBorder.Parent           = Sidebar

    -- Sidebar icon list
    local SidebarList = Instance.new("Frame")
    SidebarList.Name              = "List"
    SidebarList.Size              = UDim2.new(1, 0, 1, 0)
    SidebarList.BackgroundTransparency = 1
    SidebarList.Parent            = Sidebar

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
    SidebarLayout.Padding             = UDim.new(0, 4)
    SidebarLayout.Parent              = SidebarList
    Padding(SidebarList, 12, 0, 12, 0)

    -- Logo dot at top
    local LogoDot = Instance.new("Frame")
    LogoDot.Size            = UDim2.new(0, 26, 0, 26)
    LogoDot.BackgroundColor3 = Theme.Accent
    LogoDot.BorderSizePixel = 0
    LogoDot.LayoutOrder    = 0
    LogoDot.Parent         = SidebarList
    Corner(LogoDot, 8)
    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Size                 = UDim2.new(1, 0, 1, 0)
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Text                 = "S"
    LogoLabel.Font                 = Enum.Font.GothamBold
    LogoLabel.TextSize             = 13
    LogoLabel.TextColor3           = Color3.fromRGB(255,255,255)
    LogoLabel.Parent               = LogoDot

    local SidebarSpacer = Instance.new("Frame")
    SidebarSpacer.Size            = UDim2.new(0, 32, 0, 12)
    SidebarSpacer.BackgroundTransparency = 1
    SidebarSpacer.LayoutOrder     = 1
    SidebarSpacer.Parent          = SidebarList

    -- ── Content Area ─────────────────────────────────────
    local ContentArea = Instance.new("Frame")
    ContentArea.Name            = "ContentArea"
    ContentArea.Size            = UDim2.new(1, -54, 1, 0)
    ContentArea.Position        = UDim2.new(0, 54, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent          = Window

    -- Header
    local Header = Instance.new("Frame")
    Header.Name            = "Header"
    Header.Size            = UDim2.new(1, 0, 0, 52)
    Header.BackgroundColor3 = Theme.Background
    Header.BorderSizePixel = 0
    Header.Parent          = ContentArea

    -- Header bottom border
    local HeaderBorder = Instance.new("Frame")
    HeaderBorder.Size             = UDim2.new(1, 0, 0, 1)
    HeaderBorder.Position         = UDim2.new(0, 0, 1, -1)
    HeaderBorder.BackgroundColor3 = Theme.Border
    HeaderBorder.BorderSizePixel  = 0
    HeaderBorder.Parent           = Header

    -- Title text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name            = "Title"
    TitleLabel.Size            = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position        = UDim2.new(0, 16, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text            = title
    TitleLabel.Font            = Enum.Font.GothamBold
    TitleLabel.TextSize        = 15
    TitleLabel.TextColor3      = Theme.TextPrimary
    TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
    TitleLabel.Parent          = Header

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Name              = "Subtitle"
    SubLabel.Size              = UDim2.new(0, 200, 0, 16)
    SubLabel.Position          = UDim2.new(0, 16, 1, -18)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text              = subtitle
    SubLabel.Font              = Enum.Font.Gotham
    SubLabel.TextSize          = 11
    SubLabel.TextColor3        = Theme.TextSecondary
    SubLabel.TextXAlignment    = Enum.TextXAlignment.Left
    SubLabel.Parent            = Header

    -- Tab bar (inside header, right side of title)
    local TabBar = Instance.new("Frame")
    TabBar.Name              = "TabBar"
    TabBar.Size              = UDim2.new(0, 340, 0, 30)
    TabBar.Position          = UDim2.new(0, 200, 0.5, -15)
    TabBar.BackgroundColor3  = Theme.Surface
    TabBar.BorderSizePixel   = 0
    TabBar.Parent            = Header
    Corner(TabBar, 8)
    Stroke(TabBar, Theme.Border, 1)

    local TabBarLayout = Instance.new("UIListLayout")
    TabBarLayout.FillDirection        = Enum.FillDirection.Horizontal
    TabBarLayout.HorizontalAlignment  = Enum.HorizontalAlignment.Left
    TabBarLayout.VerticalAlignment    = Enum.VerticalAlignment.Center
    TabBarLayout.Padding              = UDim.new(0, 2)
    TabBarLayout.Parent               = TabBar
    Padding(TabBar, 3, 3, 3, 3)

    -- Window controls (top right)
    local Controls = Instance.new("Frame")
    Controls.Name              = "Controls"
    Controls.Size              = UDim2.new(0, 60, 0, 28)
    Controls.Position          = UDim2.new(1, -68, 0.5, -14)
    Controls.BackgroundTransparency = 1
    Controls.Parent            = Header

    local CtrlLayout = Instance.new("UIListLayout")
    CtrlLayout.FillDirection       = Enum.FillDirection.Horizontal
    CtrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    CtrlLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
    CtrlLayout.Padding             = UDim.new(0, 6)
    CtrlLayout.Parent              = Controls

    local function MakeCtrlBtn(icon, color)
        local btn = Instance.new("TextButton")
        btn.Size               = UDim2.new(0, 24, 0, 24)
        btn.BackgroundColor3   = color or Theme.Surface
        btn.Text               = icon
        btn.Font               = Enum.Font.GothamBold
        btn.TextSize           = 10
        btn.TextColor3         = Theme.TextSecondary
        btn.BorderSizePixel    = 0
        btn.AutoButtonColor    = false
        btn.Parent             = Controls
        Corner(btn, 6)
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = Theme.SurfaceHover}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = color or Theme.Surface}, 0.15)
        end)
        return btn
    end

    local CloseBtn    = MakeCtrlBtn(Icons.Close)
    local MinimizeBtn = MakeCtrlBtn(Icons.Minimize)

    -- Minimize
    local minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetSize = minimized
            and UDim2.new(0, 820, 0, 52)
            or  UDim2.new(0, 820, 0, 520)
        Tween(Window, {Size = targetSize}, 0.3, Enum.EasingStyle.Quart)
    end)

    -- Close
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Window, {Size = UDim2.new(0, 820, 0, 0)}, 0.25, Enum.EasingStyle.Quart)
        task.wait(0.25)
        ScreenGui:Destroy()
    end)

    -- ── Scroll / Content frame ────────────────────────────
    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Name                  = "ContentScroll"
    ContentScroll.Size                  = UDim2.new(1, 0, 1, -52)
    ContentScroll.Position              = UDim2.new(0, 0, 0, 52)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.BorderSizePixel       = 0
    ContentScroll.ScrollBarThickness    = 3
    ContentScroll.ScrollBarImageColor3  = Theme.Scrollbar
    ContentScroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
    ContentScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    ContentScroll.ElasticBehavior       = Enum.ElasticBehavior.Never
    ContentScroll.Parent                = ContentArea

    -- Pages holder (each tab has a page Frame)
    local Pages = Instance.new("Frame")
    Pages.Name                  = "Pages"
    Pages.Size                  = UDim2.new(1, 0, 1, 0)
    Pages.BackgroundTransparency = 1
    Pages.Parent                = ContentScroll

    -- Make window draggable from header
    MakeDraggable(Window, Header)

    -- Entrance animation
    Window.Size = UDim2.new(0, 820, 0, 0)
    Window.BackgroundTransparency = 1
    Tween(Window, {
        Size = UDim2.new(0, 820, 0, 520),
        BackgroundTransparency = 0
    }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Store refs
    self._gui        = ScreenGui
    self._window     = Window
    self._sidebar    = SidebarList
    self._tabBar     = TabBar
    self._pages      = Pages
    self._tabBarLayout = TabBarLayout
    self._sidebarLayout = SidebarLayout

    return self
end

-- ══════════════════════════════════════════════════════════
--  Spectra:AddTab  –  Create a new tab
-- ══════════════════════════════════════════════════════════
function Spectra:AddTab(name, icon)
    icon = icon or "◈"
    local tabIndex = #self._tabs + 1

    -- ── Sidebar icon button ───────────────────────────────
    local SidebarBtn = Instance.new("TextButton")
    SidebarBtn.Name              = name
    SidebarBtn.Size              = UDim2.new(0, 36, 0, 36)
    SidebarBtn.BackgroundColor3  = Theme.Sidebar
    SidebarBtn.Text              = icon
    SidebarBtn.Font              = Enum.Font.Gotham
    SidebarBtn.TextSize          = 16
    SidebarBtn.TextColor3        = Theme.SidebarIcon
    SidebarBtn.BorderSizePixel   = 0
    SidebarBtn.AutoButtonColor   = false
    SidebarBtn.LayoutOrder       = tabIndex + 1
    SidebarBtn.Parent            = self._sidebar
    Corner(SidebarBtn, 8)

    -- Tooltip
    local Tooltip = Instance.new("TextLabel")
    Tooltip.Name              = "Tooltip"
    Tooltip.Size              = UDim2.new(0, 0, 0, 24)
    Tooltip.AutomaticSize     = Enum.AutomaticSize.X
    Tooltip.Position          = UDim2.new(1, 8, 0.5, -12)
    Tooltip.BackgroundColor3  = Theme.SurfaceActive
    Tooltip.TextColor3        = Theme.TextPrimary
    Tooltip.Text              = "  " .. name .. "  "
    Tooltip.Font              = Enum.Font.Gotham
    Tooltip.TextSize          = 11
    Tooltip.BorderSizePixel   = 0
    Tooltip.Visible           = false
    Tooltip.ZIndex            = 10
    Tooltip.Parent            = SidebarBtn
    Corner(Tooltip, 5)
    Stroke(Tooltip, Theme.Border, 1)

    SidebarBtn.MouseEnter:Connect(function()
        Tooltip.Visible = true
        Tween(SidebarBtn, {BackgroundColor3 = Theme.SurfaceHover}, 0.15)
        Tween(SidebarBtn, {TextColor3 = Theme.TextPrimary}, 0.15)
    end)
    SidebarBtn.MouseLeave:Connect(function()
        Tooltip.Visible = false
        if self._activeTab and self._activeTab._sidebarBtn == SidebarBtn then return end
        Tween(SidebarBtn, {BackgroundColor3 = Theme.Sidebar}, 0.15)
        Tween(SidebarBtn, {TextColor3 = Theme.SidebarIcon}, 0.15)
    end)

    -- ── Tab pill in header ────────────────────────────────
    local TabPill = Instance.new("TextButton")
    TabPill.Name             = name
    TabPill.Size             = UDim2.new(0, 0, 1, 0)
    TabPill.AutomaticSize    = Enum.AutomaticSize.X
    TabPill.BackgroundColor3 = Theme.Surface
    TabPill.BackgroundTransparency = 1
    TabPill.Text             = name
    TabPill.Font             = Enum.Font.Gotham
    TabPill.TextSize         = 12
    TabPill.TextColor3       = Theme.TextSecondary
    TabPill.BorderSizePixel  = 0
    TabPill.AutoButtonColor  = false
    TabPill.Parent           = self._tabBar
    Corner(TabPill, 6)
    Padding(TabPill, 0, 10, 0, 10)

    -- ── Page (content frame) ─────────────────────────────
    local Page = Instance.new("Frame")
    Page.Name                  = name
    Page.Size                  = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible               = false
    Page.Parent                = self._pages
    Padding(Page, 16, 16, 16, 16)

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.FillDirection       = Enum.FillDirection.Vertical
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    PageLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
    PageLayout.Padding             = UDim.new(0, 8)
    PageLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    PageLayout.Parent              = Page

    -- Tab object
    local Tab = {
        _name       = name,
        _page       = Page,
        _layout     = PageLayout,
        _sidebarBtn = SidebarBtn,
        _tabPill    = TabPill,
        _lib        = self,
        _order      = 0,
    }

    -- Activate function
    local function Activate()
        -- Deactivate previous
        if self._activeTab then
            local prev = self._activeTab
            Tween(prev._sidebarBtn, {BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.SidebarIcon}, 0.2)
            Tween(prev._tabPill, {BackgroundColor3 = Theme.Surface, BackgroundTransparency = 1, TextColor3 = Theme.TextSecondary}, 0.2)
            prev._page.Visible = false
        end
        -- Activate this
        self._activeTab = Tab
        Tween(SidebarBtn, {BackgroundColor3 = Theme.AccentDark, TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
        Tween(TabPill, {BackgroundColor3 = Theme.SurfaceActive, BackgroundTransparency = 0, TextColor3 = Theme.TextPrimary}, 0.2)
        Page.Visible = true
    end

    SidebarBtn.MouseButton1Click:Connect(Activate)
    TabPill.MouseButton1Click:Connect(Activate)

    -- Auto-activate first tab
    if #self._tabs == 0 then
        task.defer(Activate)
    end

    table.insert(self._tabs, Tab)
    return Tab
end

-- ══════════════════════════════════════════════════════════
--  Internal: Section container
-- ══════════════════════════════════════════════════════════
local function MakeSection(parent, layout)
    local Section = Instance.new("Frame")
    Section.Name              = "Section"
    Section.Size              = UDim2.new(1, 0, 0, 0)
    Section.AutomaticSize     = Enum.AutomaticSize.Y
    Section.BackgroundColor3  = Theme.Surface
    Section.BorderSizePixel   = 0
    Section.LayoutOrder       = layout or 0
    Section.Parent            = parent
    Corner(Section, 10)
    Stroke(Section, Theme.Border, 1)
    Padding(Section, 12, 14, 12, 14)

    local SectionLayout = Instance.new("UIListLayout")
    SectionLayout.FillDirection       = Enum.FillDirection.Vertical
    SectionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    SectionLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
    SectionLayout.Padding             = UDim.new(0, 10)
    SectionLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    SectionLayout.Parent              = Section

    return Section, SectionLayout
end

-- ══════════════════════════════════════════════════════════
--  Tab:AddSection
-- ══════════════════════════════════════════════════════════
function Spectra:AddSection(tab, title)
    tab._order = tab._order + 1

    local Section, SectionLayout = MakeSection(tab._page, tab._order)

    if title and title ~= "" then
        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Name              = "SectionTitle"
        TitleLbl.Size              = UDim2.new(1, 0, 0, 18)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text              = title
        TitleLbl.Font              = Enum.Font.GothamBold
        TitleLbl.TextSize          = 11
        TitleLbl.TextColor3        = Theme.TextSecondary
        TitleLbl.TextXAlignment    = Enum.TextXAlignment.Left
        TitleLbl.LayoutOrder       = 0
        TitleLbl.Parent            = Section

        local Divider = Instance.new("Frame")
        Divider.Size            = UDim2.new(1, 0, 0, 1)
        Divider.BackgroundColor3 = Theme.Separator
        Divider.BorderSizePixel = 0
        Divider.LayoutOrder     = 1
        Divider.Parent          = Section
    end

    local SectionObj = {
        _frame  = Section,
        _layout = SectionLayout,
        _order  = 1,
    }

    return SectionObj
end

-- ══════════════════════════════════════════════════════════
--  Section:AddToggle
-- ══════════════════════════════════════════════════════════
function Spectra:AddToggle(section, config)
    config = config or {}
    local label    = config.Label   or "Toggle"
    local desc     = config.Description or ""
    local default  = config.Default or false
    local callback = config.Callback or function() end

    section._order = section._order + 1

    local Row = Instance.new("Frame")
    Row.Name            = "Toggle_" .. label
    Row.Size            = UDim2.new(1, 0, 0, desc ~= "" and 44 or 30)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder     = section._order
    Row.Parent          = section._frame

    local RowLayout = Instance.new("UIListLayout")
    RowLayout.FillDirection       = Enum.FillDirection.Horizontal
    RowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    RowLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
    RowLayout.Parent              = Row

    -- Label side
    local LabelFrame = Instance.new("Frame")
    LabelFrame.Size             = UDim2.new(1, -52, 1, 0)
    LabelFrame.BackgroundTransparency = 1
    LabelFrame.Parent           = Row

    local LabelTxt = Instance.new("TextLabel")
    LabelTxt.Size              = UDim2.new(1, 0, 0, 18)
    LabelTxt.BackgroundTransparency = 1
    LabelTxt.Text              = label
    LabelTxt.Font              = Enum.Font.Gotham
    LabelTxt.TextSize          = 13
    LabelTxt.TextColor3        = Theme.TextPrimary
    LabelTxt.TextXAlignment    = Enum.TextXAlignment.Left
    LabelTxt.Parent            = LabelFrame

    if desc ~= "" then
        local DescTxt = Instance.new("TextLabel")
        DescTxt.Size              = UDim2.new(1, 0, 0, 14)
        DescTxt.Position          = UDim2.new(0, 0, 0, 20)
        DescTxt.BackgroundTransparency = 1
        DescTxt.Text              = desc
        DescTxt.Font              = Enum.Font.Gotham
        DescTxt.TextSize          = 11
        DescTxt.TextColor3        = Theme.TextSecondary
        DescTxt.TextXAlignment    = Enum.TextXAlignment.Left
        DescTxt.Parent            = LabelFrame
    end

    -- Toggle track
    local Track = Instance.new("Frame")
    Track.Name            = "Track"
    Track.Size            = UDim2.new(0, 40, 0, 22)
    Track.BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff
    Track.BorderSizePixel = 0
    Track.Parent          = Row
    Corner(Track, 11)
    Stroke(Track, Theme.Border, 1)

    local Knob = Instance.new("Frame")
    Knob.Name            = "Knob"
    Knob.Size            = UDim2.new(0, 16, 0, 16)
    Knob.Position        = default and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Theme.ToggleKnob
    Knob.BorderSizePixel = 0
    Knob.ZIndex          = 2
    Knob.Parent          = Track
    Corner(Knob, 8)

    local value = default

    local function SetToggle(v, animate)
        value = v
        local knobPos  = v and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        local trackCol = v and Theme.ToggleOn or Theme.ToggleOff
        if animate ~= false then
            Tween(Knob,  {Position = knobPos},   0.2)
            Tween(Track, {BackgroundColor3 = trackCol}, 0.2)
        else
            Knob.Position        = knobPos
            Track.BackgroundColor3 = trackCol
        end
        callback(v)
    end

    -- Click area over the whole row
    local ClickArea = Instance.new("TextButton")
    ClickArea.Size              = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text              = ""
    ClickArea.ZIndex            = 3
    ClickArea.Parent            = Row
    ClickArea.MouseButton1Click:Connect(function()
        SetToggle(not value)
    end)

    local ToggleObj = {}
    function ToggleObj:Set(v) SetToggle(v) end
    function ToggleObj:Get() return value end
    return ToggleObj
end

-- ══════════════════════════════════════════════════════════
--  Section:AddSlider
-- ══════════════════════════════════════════════════════════
function Spectra:AddSlider(section, config)
    config = config or {}
    local label    = config.Label   or "Slider"
    local desc     = config.Description or ""
    local min      = config.Min     or 0
    local max      = config.Max     or 100
    local default  = config.Default or min
    local suffix   = config.Suffix  or ""
    local callback = config.Callback or function() end

    section._order = section._order + 1

    local Row = Instance.new("Frame")
    Row.Name            = "Slider_" .. label
    Row.Size            = UDim2.new(1, 0, 0, desc ~= "" and 54 or 44)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder     = section._order
    Row.Parent          = section._frame

    -- Label row
    local LabelTxt = Instance.new("TextLabel")
    LabelTxt.Size              = UDim2.new(1, -60, 0, 16)
    LabelTxt.BackgroundTransparency = 1
    LabelTxt.Text              = label
    LabelTxt.Font              = Enum.Font.Gotham
    LabelTxt.TextSize          = 13
    LabelTxt.TextColor3        = Theme.TextPrimary
    LabelTxt.TextXAlignment    = Enum.TextXAlignment.Left
    LabelTxt.Parent            = Row

    local ValueTxt = Instance.new("TextLabel")
    ValueTxt.Size              = UDim2.new(0, 55, 0, 16)
    ValueTxt.Position          = UDim2.new(1, -55, 0, 0)
    ValueTxt.BackgroundTransparency = 1
    ValueTxt.Text              = tostring(default) .. suffix
    ValueTxt.Font              = Enum.Font.GothamBold
    ValueTxt.TextSize          = 12
    ValueTxt.TextColor3        = Theme.Accent
    ValueTxt.TextXAlignment    = Enum.TextXAlignment.Right
    ValueTxt.Parent            = Row

    if desc ~= "" then
        local DescTxt = Instance.new("TextLabel")
        DescTxt.Size              = UDim2.new(1, 0, 0, 12)
        DescTxt.Position          = UDim2.new(0, 0, 0, 18)
        DescTxt.BackgroundTransparency = 1
        DescTxt.Text              = desc
        DescTxt.Font              = Enum.Font.Gotham
        DescTxt.TextSize          = 10
        DescTxt.TextColor3        = Theme.TextSecondary
        DescTxt.TextXAlignment    = Enum.TextXAlignment.Left
        DescTxt.Parent            = Row
    end

    local trackY = desc ~= "" and 36 or 26

    -- Track
    local Track = Instance.new("Frame")
    Track.Name            = "Track"
    Track.Size            = UDim2.new(1, 0, 0, 6)
    Track.Position        = UDim2.new(0, 0, 0, trackY)
    Track.BackgroundColor3 = Theme.SliderTrack
    Track.BorderSizePixel = 0
    Track.Parent          = Row
    Corner(Track, 3)

    local Fill = Instance.new("Frame")
    Fill.Name            = "Fill"
    Fill.Size            = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Theme.SliderFill
    Fill.BorderSizePixel = 0
    Fill.ZIndex          = 2
    Fill.Parent          = Track
    Corner(Fill, 3)

    local Knob = Instance.new("Frame")
    Knob.Name            = "Knob"
    Knob.Size            = UDim2.new(0, 14, 0, 14)
    Knob.Position        = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    Knob.BackgroundColor3 = Theme.SliderKnob
    Knob.BorderSizePixel = 0
    Knob.ZIndex          = 3
    Knob.Parent          = Track
    Corner(Knob, 7)
    Stroke(Knob, Theme.AccentDark, 2)

    local value = default
    local dragging = false

    local function SetSlider(v)
        v = math.clamp(math.floor(v + 0.5), min, max)
        value = v
        local pct = (v - min) / (max - min)
        Fill.Size     = UDim2.new(pct, 0, 1, 0)
        Knob.Position = UDim2.new(pct, -7, 0.5, -7)
        ValueTxt.Text = tostring(v) .. suffix
        callback(v)
    end

    local function UpdateFromMouse()
        local absPos  = Track.AbsolutePosition.X
        local absSize = Track.AbsoluteSize.X
        local rel = math.clamp((Mouse.X - absPos) / absSize, 0, 1)
        SetSlider(min + rel * (max - min))
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateFromMouse()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateFromMouse()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local SliderObj = {}
    function SliderObj:Set(v) SetSlider(v) end
    function SliderObj:Get() return value end
    return SliderObj
end

-- ══════════════════════════════════════════════════════════
--  Section:AddButton
-- ══════════════════════════════════════════════════════════
function Spectra:AddButton(section, config)
    config = config or {}
    local label    = config.Label    or "Button"
    local desc     = config.Description or ""
    local callback = config.Callback or function() end

    section._order = section._order + 1

    local Row = Instance.new("Frame")
    Row.Name            = "Button_" .. label
    Row.Size            = UDim2.new(1, 0, 0, 36)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder     = section._order
    Row.Parent          = section._frame

    local Btn = Instance.new("TextButton")
    Btn.Name            = "Btn"
    Btn.Size            = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Theme.SurfaceActive
    Btn.Text            = label
    Btn.Font            = Enum.Font.GothamBold
    Btn.TextSize        = 13
    Btn.TextColor3      = Theme.TextPrimary
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Parent          = Row
    Corner(Btn, 8)
    Stroke(Btn, Theme.Border, 1)

    Btn.MouseEnter:Connect(function()
        Tween(Btn, {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(255,255,255)}, 0.15)
    end)
    Btn.MouseLeave:Connect(function()
        Tween(Btn, {BackgroundColor3 = Theme.SurfaceActive, TextColor3 = Theme.TextPrimary}, 0.15)
    end)
    Btn.MouseButton1Down:Connect(function()
        Tween(Btn, {BackgroundColor3 = Theme.AccentDark}, 0.1)
    end)
    Btn.MouseButton1Up:Connect(function()
        Tween(Btn, {BackgroundColor3 = Theme.Accent}, 0.1)
    end)
    Btn.MouseButton1Click:Connect(callback)

    local BtnObj = {}
    function BtnObj:SetLabel(t) Btn.Text = t end
    return BtnObj
end

-- ══════════════════════════════════════════════════════════
--  Section:AddDropdown
-- ══════════════════════════════════════════════════════════
function Spectra:AddDropdown(section, config)
    config = config or {}
    local label    = config.Label   or "Dropdown"
    local options  = config.Options or {}
    local default  = config.Default or (options[1] or "Select")
    local callback = config.Callback or function() end

    section._order = section._order + 1

    local Wrapper = Instance.new("Frame")
    Wrapper.Name            = "Dropdown_" .. label
    Wrapper.Size            = UDim2.new(1, 0, 0, 58)
    Wrapper.BackgroundTransparency = 1
    Wrapper.ClipsDescendants = false
    Wrapper.LayoutOrder     = section._order
    Wrapper.Parent          = section._frame

    local LabelTxt = Instance.new("TextLabel")
    LabelTxt.Size              = UDim2.new(1, 0, 0, 16)
    LabelTxt.BackgroundTransparency = 1
    LabelTxt.Text              = label
    LabelTxt.Font              = Enum.Font.Gotham
    LabelTxt.TextSize          = 13
    LabelTxt.TextColor3        = Theme.TextPrimary
    LabelTxt.TextXAlignment    = Enum.TextXAlignment.Left
    LabelTxt.Parent            = Wrapper

    local SelBtn = Instance.new("TextButton")
    SelBtn.Name            = "Select"
    SelBtn.Size            = UDim2.new(1, 0, 0, 34)
    SelBtn.Position        = UDim2.new(0, 0, 0, 20)
    SelBtn.BackgroundColor3 = Theme.SurfaceActive
    SelBtn.Text            = default .. "  ▾"
    SelBtn.Font            = Enum.Font.Gotham
    SelBtn.TextSize        = 12
    SelBtn.TextColor3      = Theme.TextPrimary
    SelBtn.TextXAlignment  = Enum.TextXAlignment.Left
    SelBtn.BorderSizePixel = 0
    SelBtn.AutoButtonColor = false
    SelBtn.ZIndex          = 5
    SelBtn.Parent          = Wrapper
    Corner(SelBtn, 8)
    Stroke(SelBtn, Theme.Border, 1)
    Padding(SelBtn, 0, 10, 0, 10)

    local DropMenu = Instance.new("Frame")
    DropMenu.Name            = "Menu"
    DropMenu.Size            = UDim2.new(1, 0, 0, 0)
    DropMenu.Position        = UDim2.new(0, 0, 0, 58)
    DropMenu.BackgroundColor3 = Theme.SurfaceActive
    DropMenu.BorderSizePixel = 0
    DropMenu.ClipsDescendants = true
    DropMenu.Visible         = false
    DropMenu.ZIndex          = 10
    DropMenu.Parent          = Wrapper
    Corner(DropMenu, 8)
    Stroke(DropMenu, Theme.Border, 1)

    local MenuLayout = Instance.new("UIListLayout")
    MenuLayout.FillDirection       = Enum.FillDirection.Vertical
    MenuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    MenuLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    MenuLayout.Parent              = DropMenu
    Padding(DropMenu, 4, 0, 4, 0)

    local open     = false
    local selected = default
    local menuHeight = (#options * 30) + 8

    local function CloseMenu()
        open = false
        Tween(DropMenu, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
        task.delay(0.2, function() DropMenu.Visible = false end)
    end

    for i, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Name            = "Opt_" .. opt
        OptBtn.Size            = UDim2.new(1, 0, 0, 30)
        OptBtn.BackgroundColor3 = Theme.SurfaceActive
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text            = opt
        OptBtn.Font            = Enum.Font.Gotham
        OptBtn.TextSize        = 12
        OptBtn.TextColor3      = opt == selected and Theme.Accent or Theme.TextPrimary
        OptBtn.TextXAlignment  = Enum.TextXAlignment.Left
        OptBtn.BorderSizePixel = 0
        OptBtn.AutoButtonColor = false
        OptBtn.ZIndex          = 11
        OptBtn.LayoutOrder     = i
        OptBtn.Parent          = DropMenu
        Padding(OptBtn, 0, 10, 0, 10)

        OptBtn.MouseEnter:Connect(function()
            Tween(OptBtn, {BackgroundTransparency = 0, BackgroundColor3 = Theme.SurfaceHover}, 0.1)
        end)
        OptBtn.MouseLeave:Connect(function()
            Tween(OptBtn, {BackgroundTransparency = 1}, 0.1)
        end)
        OptBtn.MouseButton1Click:Connect(function()
            selected = opt
            SelBtn.Text = opt .. "  ▾"
            -- Update all option colors
            for _, child in ipairs(DropMenu:GetChildren()) do
                if child:IsA("TextButton") then
                    child.TextColor3 = child.Name == "Opt_" .. opt
                        and Theme.Accent or Theme.TextPrimary
                end
            end
            callback(opt)
            CloseMenu()
        end)
    end

    SelBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            DropMenu.Visible = true
            DropMenu.Size    = UDim2.new(1, 0, 0, 0)
            Tween(DropMenu, {Size = UDim2.new(1, 0, 0, menuHeight)}, 0.2, Enum.EasingStyle.Back)
            Wrapper.Size = UDim2.new(1, 0, 0, 58 + menuHeight + 4)
        else
            CloseMenu()
            Wrapper.Size = UDim2.new(1, 0, 0, 58)
        end
    end)

    local DropObj = {}
    function DropObj:Set(v)
        selected = v
        SelBtn.Text = v .. "  ▾"
        callback(v)
    end
    function DropObj:Get() return selected end
    return DropObj
end

-- ══════════════════════════════════════════════════════════
--  Section:AddInput  –  Text box
-- ══════════════════════════════════════════════════════════
function Spectra:AddInput(section, config)
    config = config or {}
    local label       = config.Label       or "Input"
    local placeholder = config.Placeholder or "Type here..."
    local callback    = config.Callback    or function() end

    section._order = section._order + 1

    local Row = Instance.new("Frame")
    Row.Name            = "Input_" .. label
    Row.Size            = UDim2.new(1, 0, 0, 56)
    Row.BackgroundTransparency = 1
    Row.LayoutOrder     = section._order
    Row.Parent          = section._frame

    local LabelTxt = Instance.new("TextLabel")
    LabelTxt.Size              = UDim2.new(1, 0, 0, 16)
    LabelTxt.BackgroundTransparency = 1
    LabelTxt.Text              = label
    LabelTxt.Font              = Enum.Font.Gotham
    LabelTxt.TextSize          = 13
    LabelTxt.TextColor3        = Theme.TextPrimary
    LabelTxt.TextXAlignment    = Enum.TextXAlignment.Left
    LabelTxt.Parent            = Row

    local InputBox = Instance.new("TextBox")
    InputBox.Name              = "InputBox"
    InputBox.Size              = UDim2.new(1, 0, 0, 32)
    InputBox.Position          = UDim2.new(0, 0, 0, 22)
    InputBox.BackgroundColor3  = Theme.SurfaceActive
    InputBox.Text              = ""
    InputBox.PlaceholderText   = placeholder
    InputBox.Font              = Enum.Font.Gotham
    InputBox.TextSize          = 12
    InputBox.TextColor3        = Theme.TextPrimary
    InputBox.PlaceholderColor3 = Theme.TextDisabled
    InputBox.TextXAlignment    = Enum.TextXAlignment.Left
    InputBox.BorderSizePixel   = 0
    InputBox.ClearTextOnFocus  = false
    InputBox.Parent            = Row
    Corner(InputBox, 8)
    Stroke(InputBox, Theme.Border, 1)
    Padding(InputBox, 0, 10, 0, 10)

    InputBox.Focused:Connect(function()
        Tween(InputBox, {BackgroundColor3 = Theme.SurfaceHover}, 0.15)
        -- Stroke color change via re-stroke (workaround)
    end)
    InputBox.FocusLost:Connect(function(enter)
        Tween(InputBox, {BackgroundColor3 = Theme.SurfaceActive}, 0.15)
        if enter then callback(InputBox.Text) end
    end)
    InputBox:GetPropertyChangedSignal("Text"):Connect(function()
        callback(InputBox.Text)
    end)

    local InputObj = {}
    function InputObj:Set(v) InputBox.Text = v end
    function InputObj:Get() return InputBox.Text end
    return InputObj
end

-- ══════════════════════════════════════════════════════════
--  Section:AddLabel
-- ══════════════════════════════════════════════════════════
function Spectra:AddLabel(section, text, style)
    section._order = section._order + 1

    local Lbl = Instance.new("TextLabel")
    Lbl.Name              = "Label"
    Lbl.Size              = UDim2.new(1, 0, 0, 20)
    Lbl.BackgroundTransparency = 1
    Lbl.Text              = text or ""
    Lbl.Font              = style == "bold" and Enum.Font.GothamBold or Enum.Font.Gotham
    Lbl.TextSize          = style == "small" and 11 or 13
    Lbl.TextColor3        = style == "accent" and Theme.Accent
                            or style == "secondary" and Theme.TextSecondary
                            or Theme.TextPrimary
    Lbl.TextXAlignment    = Enum.TextXAlignment.Left
    Lbl.LayoutOrder       = section._order
    Lbl.Parent            = section._frame

    local LblObj = {}
    function LblObj:Set(t) Lbl.Text = t end
    return LblObj
end

-- ══════════════════════════════════════════════════════════
--  Section:AddDivider
-- ══════════════════════════════════════════════════════════
function Spectra:AddDivider(section)
    section._order = section._order + 1

    local Div = Instance.new("Frame")
    Div.Name            = "Divider"
    Div.Size            = UDim2.new(1, 0, 0, 1)
    Div.BackgroundColor3 = Theme.Separator
    Div.BorderSizePixel = 0
    Div.LayoutOrder     = section._order
    Div.Parent          = section._frame
end

-- ══════════════════════════════════════════════════════════
--  Notify  –  Toast notification
-- ══════════════════════════════════════════════════════════
function Spectra:Notify(config)
    config = config or {}
    local title   = config.Title   or "Notification"
    local desc    = config.Description or ""
    local duration = config.Duration or 3

    local Toast = Instance.new("Frame")
    Toast.Name            = "Toast"
    Toast.Size            = UDim2.new(0, 280, 0, desc ~= "" and 64 or 44)
    Toast.Position        = UDim2.new(1, 10, 1, -80)
    Toast.AnchorPoint     = Vector2.new(1, 1)
    Toast.BackgroundColor3 = Theme.SurfaceActive
    Toast.BorderSizePixel = 0
    Toast.ZIndex          = 20
    Toast.Parent          = self._gui
    Corner(Toast, 10)
    Stroke(Toast, Theme.Accent, 1)
    Padding(Toast, 10, 14, 10, 14)

    local AccentBar = Instance.new("Frame")
    AccentBar.Size            = UDim2.new(0, 3, 1, -16)
    AccentBar.Position        = UDim2.new(0, 0, 0, 8)
    AccentBar.BackgroundColor3 = Theme.Accent
    AccentBar.BorderSizePixel = 0
    AccentBar.ZIndex          = 21
    AccentBar.Parent          = Toast
    Corner(AccentBar, 2)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size              = UDim2.new(1, -10, 0, 18)
    TitleLbl.Position          = UDim2.new(0, 10, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text              = title
    TitleLbl.Font              = Enum.Font.GothamBold
    TitleLbl.TextSize          = 13
    TitleLbl.TextColor3        = Theme.TextPrimary
    TitleLbl.TextXAlignment    = Enum.TextXAlignment.Left
    TitleLbl.ZIndex            = 21
    TitleLbl.Parent            = Toast

    if desc ~= "" then
        local DescLbl = Instance.new("TextLabel")
        DescLbl.Size              = UDim2.new(1, -10, 0, 28)
        DescLbl.Position          = UDim2.new(0, 10, 0, 20)
        DescLbl.BackgroundTransparency = 1
        DescLbl.Text              = desc
        DescLbl.Font              = Enum.Font.Gotham
        DescLbl.TextSize          = 11
        DescLbl.TextColor3        = Theme.TextSecondary
        DescLbl.TextXAlignment    = Enum.TextXAlignment.Left
        DescLbl.TextWrapped       = true
        DescLbl.ZIndex            = 21
        DescLbl.Parent            = Toast
    end

    -- Slide in
    Toast.Position = UDim2.new(1, 300, 1, -80)
    Tween(Toast, {Position = UDim2.new(1, -16, 1, -80)}, 0.35, Enum.EasingStyle.Back)

    task.delay(duration, function()
        Tween(Toast, {Position = UDim2.new(1, 300, 1, -80)}, 0.3, Enum.EasingStyle.Quart)
        task.wait(0.3)
        Toast:Destroy()
    end)
end

-- ══════════════════════════════════════════════════════════
--  Destroy
-- ══════════════════════════════════════════════════════════
function Spectra:Destroy()
    if self._gui then self._gui:Destroy() end
end

-- ══════════════════════════════════════════════════════════
--  EXAMPLE USAGE  (remove or comment out in production)
-- ══════════════════════════════════════════════════════════
do
    local lib = Spectra.new("Spectra", "Free Plan")

    -- ── Tab 1: Player ──────────────────────────────────────
    local playerTab = lib:AddTab("Player", "👤")
    local sec1 = lib:AddSection(playerTab, "MOVEMENT")

    lib:AddToggle(sec1, {
        Label       = "Speed Boost",
        Description = "Increases walk speed significantly",
        Default     = false,
        Callback    = function(v)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = v and 32 or 16
            end
        end
    })

    lib:AddSlider(sec1, {
        Label    = "Walk Speed",
        Min      = 1,
        Max      = 100,
        Default  = 16,
        Suffix   = " stud/s",
        Callback = function(v)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = v
            end
        end
    })

    lib:AddSlider(sec1, {
        Label    = "Jump Power",
        Min      = 1,
        Max      = 200,
        Default  = 50,
        Callback = function(v)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.JumpPower = v
            end
        end
    })

    lib:AddDivider(sec1)

    lib:AddToggle(sec1, {
        Label   = "Infinite Jump",
        Default = false,
        Callback = function(v)
            -- Implement via UserInputService jump detection
        end
    })

    local sec2 = lib:AddSection(playerTab, "APPEARANCE")

    lib:AddDropdown(sec2, {
        Label    = "Character Style",
        Options  = {"Default", "Blocky", "Rthro", "Slim"},
        Default  = "Default",
        Callback = function(v) print("Style:", v) end
    })

    lib:AddToggle(sec2, {
        Label   = "Noclip",
        Default = false,
        Callback = function(v) print("Noclip:", v) end
    })

    -- ── Tab 2: World ───────────────────────────────────────
    local worldTab = lib:AddTab("World", "🌐")
    local sec3 = lib:AddSection(worldTab, "RENDERING")

    lib:AddSlider(sec3, {
        Label    = "Field of View",
        Min      = 10,
        Max      = 120,
        Default  = 70,
        Callback = function(v)
            workspace.CurrentCamera.FieldOfView = v
        end
    })

    lib:AddToggle(sec3, {
        Label       = "Fullbright",
        Description = "Sets ambient lighting to maximum",
        Default     = false,
        Callback    = function(v)
            game:GetService("Lighting").Brightness = v and 2 or 1
        end
    })

    lib:AddSlider(sec3, {
        Label    = "Time of Day",
        Min      = 0,
        Max      = 24,
        Default  = 14,
        Callback = function(v)
            game:GetService("Lighting").TimeOfDay = string.format("%02d:00:00", v)
        end
    })

    -- ── Tab 3: Visual ──────────────────────────────────────
    local visualTab = lib:AddTab("Visual", "◈")
    local sec4 = lib:AddSection(visualTab, "ESP")

    lib:AddToggle(sec4, {
        Label   = "Player ESP",
        Default = false,
        Callback = function(v) print("Player ESP:", v) end
    })

    lib:AddToggle(sec4, {
        Label   = "Name Tags",
        Default = true,
        Callback = function(v) print("Name Tags:", v) end
    })

    lib:AddToggle(sec4, {
        Label   = "Health Bars",
        Default = true,
        Callback = function(v) print("Health Bars:", v) end
    })

    lib:AddDivider(sec4)

    lib:AddDropdown(sec4, {
        Label    = "ESP Color Mode",
        Options  = {"Team Color", "Health Based", "Distance Based", "Custom"},
        Default  = "Team Color",
        Callback = function(v) print("ESP Mode:", v) end
    })

    -- ── Tab 4: Settings ────────────────────────────────────
    local settingsTab = lib:AddTab("Settings", "⚙")
    local sec5 = lib:AddSection(settingsTab, "INTERFACE")

    lib:AddDropdown(sec5, {
        Label    = "UI Scale",
        Options  = {"Small", "Normal", "Large"},
        Default  = "Normal",
        Callback = function(v) print("Scale:", v) end
    })

    lib:AddToggle(sec5, {
        Label   = "Compact Mode",
        Default = false,
        Callback = function(v) print("Compact:", v) end
    })

    lib:AddDivider(sec5)

    local sec6 = lib:AddSection(settingsTab, "KEYBINDS")
    lib:AddInput(sec6, {
        Label       = "Toggle UI Key",
        Placeholder = "e.g. RightShift",
        Callback    = function(v) print("Toggle key set to:", v) end
    })

    local sec7 = lib:AddSection(settingsTab, "ABOUT")
    lib:AddLabel(sec7, "Spectra UI Library  •  v1.0.0", "bold")
    lib:AddLabel(sec7, "A modern, lightweight Roblox UI library.", "secondary")

    local sec8 = lib:AddSection(settingsTab, "ACTIONS")
    lib:AddButton(sec8, {
        Label    = "Show Welcome Notification",
        Callback = function()
            lib:Notify({
                Title       = "Welcome to Spectra",
                Description = "Your modern Roblox UI library is ready.",
                Duration    = 4
            })
        end
    })

    lib:AddButton(sec8, {
        Label    = "Reset All Settings",
        Callback = function()
            lib:Notify({
                Title    = "Settings Reset",
                Duration = 2
            })
        end
    })

    -- Welcome notification on load
    task.delay(0.5, function()
        lib:Notify({
            Title       = "Spectra Loaded",
            Description = "Use the sidebar to navigate tabs.",
            Duration    = 4
        })
    end)
end

return Spectra
