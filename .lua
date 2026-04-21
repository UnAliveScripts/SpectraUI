-- ============================================================
--  SpectraGlass UI Library  |  v2.0.0
--  Glassmorphism frosted-white Roblox UI library
--  Faithful recreation of the Figma JSON design system:
--
--  Layout:   1072×722 window, horizontal sidebar (100px) + content area
--  Sidebar:  white/15% glass pill, 60×60 icon buttons, 20px corner radius
--  Content:  top header (subtabs + search + profile), 3-column card grid
--  Cards:    white/15% glass, 25px radius, gradient angular border stroke
--  Toggles:  40×25 pill, accent blue (#24B0FF) = ON, white/15% = OFF
--  Sliders:  150×25 pill track, accent fill, 21×21 white thumb
--  Buttons:  pill shape white/15% glass with text label
--  IconBtns: 45×45 circle, white/15% or white solid for "active"
--  Colors:   all white text, semi-transparent fills, NO dark backgrounds
-- ============================================================

local SpectraGlass = {}
SpectraGlass.__index = SpectraGlass

-- ─── Services ─────────────────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ─── Design Tokens (from Figma JSON) ─────────────────────
local T = {
    -- Glass fills
    GlassWhite15    = { Color = Color3.fromRGB(255,255,255), Alpha = 0.15 }, -- sidebar, cards
    GlassBlack20    = { Color = Color3.fromRGB(0,0,0),       Alpha = 0.20 }, -- window bg
    GlassBlack15    = { Color = Color3.fromRGB(0,0,0),       Alpha = 0.15 }, -- search, icon btns inactive
    GlassWhite100   = { Color = Color3.fromRGB(255,255,255), Alpha = 1.00 }, -- active icon btn

    -- Accent (toggle ON, slider fill)  rgb(36, 176, 255)
    Accent          = Color3.fromRGB(36, 176, 255),

    -- Text
    TextPrimary     = Color3.fromRGB(255, 255, 255),
    TextSecondary   = Color3.fromRGB(208, 208, 208),  -- #D0D0D0 from figma
    TextDim         = Color3.fromRGB(200, 200, 200),  -- 50% white subtab

    -- Divider
    Divider         = Color3.fromRGB(255, 255, 255),  -- white 15% opacity

    -- Radii (from Figma)
    RadiusWindow    = 30,
    RadiusSidebar   = 25,
    RadiusSidebarBtn= 20,
    RadiusCard      = 25,
    RadiusToggle    = 30,
    RadiusSlider    = 100,
    RadiusSearch    = 50,
    RadiusButton    = 50,
    RadiusIconBtn   = 100,
}

-- ─── Tween Helper ─────────────────────────────────────────
local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

-- ─── Corner ───────────────────────────────────────────────
local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
end

-- ─── Draggable ────────────────────────────────────────────
local function Draggable(frame, handle)
    handle = handle or frame
    local drag, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; ds = i.Position; sp = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

-- ─── Glass Frame Helper ───────────────────────────────────
-- Creates a Frame with white/15% fill (the signature glass look)
local function GlassFrame(parent, size, pos, radius, fillAlpha, fillColor)
    fillColor = fillColor or Color3.fromRGB(255,255,255)
    fillAlpha = fillAlpha or 0.15
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = fillColor
    f.BackgroundTransparency = 1 - fillAlpha
    f.BorderSizePixel = 0
    f.Parent = parent
    if radius then Corner(f, radius) end
    return f
end

-- ─── UIListLayout Helper ──────────────────────────────────
local function ListLayout(parent, dir, halign, valign, pad)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment = valign or Enum.VerticalAlignment.Top
    l.Padding = UDim.new(0, pad or 0)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function Pad(p, top, right, bottom, left)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, top    or 0)
    u.PaddingRight  = UDim.new(0, right  or 0)
    u.PaddingBottom = UDim.new(0, bottom or 0)
    u.PaddingLeft   = UDim.new(0, left   or 0)
    u.Parent = p
end

local function Label(parent, text, size, weight, color, xalign, pos, lsize)
    local l = Instance.new("TextLabel")
    l.Size = lsize or UDim2.new(1,0,0,size+4)
    l.Position = pos or UDim2.new(0,0,0,0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = (weight and weight >= 600) and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextSize = size or 14
    l.TextColor3 = color or T.TextPrimary
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.Parent = parent
    return l
end

-- ══════════════════════════════════════════════════════════
--  SpectraGlass.new(title)
--  Creates the main window: 820×520 (scaled from 1072×722)
-- ══════════════════════════════════════════════════════════
function SpectraGlass.new(title)
    local self = setmetatable({}, SpectraGlass)
    self._tabs      = {}
    self._activeTab = nil

    -- ── ScreenGui ─────────────────────────────────────────
    local SG = Instance.new("ScreenGui")
    SG.Name           = "SpectraGlassUI"
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SG.ResetOnSpawn   = false
    SG.IgnoreGuiInset = true
    SG.Parent         = PlayerGui

    -- ── Window (black/20% glass, 30px radius) ─────────────
    local Win = Instance.new("Frame")
    Win.Name              = "Window"
    Win.Size              = UDim2.new(0, 820, 0, 520)
    Win.Position          = UDim2.new(0.5, -410, 0.5, -260)
    Win.BackgroundColor3  = Color3.fromRGB(0,0,0)
    Win.BackgroundTransparency = 0.80  -- 20% fill
    Win.BorderSizePixel   = 0
    Win.ClipsDescendants  = true
    Win.Parent            = SG
    Corner(Win, T.RadiusWindow)

    -- Subtle drop shadow card
    local Shadow = Instance.new("Frame")
    Shadow.Size = UDim2.new(1,30,1,30)
    Shadow.Position = UDim2.new(0,-15,0,-10)
    Shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Shadow.BackgroundTransparency = 0.75
    Shadow.BorderSizePixel = 0
    Shadow.ZIndex = 0
    Shadow.Parent = Win
    Corner(Shadow, T.RadiusWindow + 4)

    -- Window border (white gradient-angular look → approximate with white stroke)
    local WinStroke = Instance.new("UIStroke")
    WinStroke.Color = Color3.fromRGB(255,255,255)
    WinStroke.Thickness = 1
    WinStroke.Transparency = 0.55  -- ~45% white
    WinStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    WinStroke.Parent = Win

    -- ── Sidebar (white/15%, 25px radius, 100px wide) ──────
    -- From JSON: Sidebar x=20,y=20 width=100 height=682, padded 20px all sides
    -- Scaled: width=76, height proportional, we use full height with 20px margin sim
    local SidebarOuter = Instance.new("Frame")
    SidebarOuter.Size            = UDim2.new(0, 76, 1, -20)
    SidebarOuter.Position        = UDim2.new(0, 10, 0, 10)
    SidebarOuter.BackgroundColor3 = Color3.fromRGB(255,255,255)
    SidebarOuter.BackgroundTransparency = 0.85  -- 15% white
    SidebarOuter.BorderSizePixel = 0
    SidebarOuter.Parent          = Win
    Corner(SidebarOuter, T.RadiusSidebar)
    local SBStroke = Instance.new("UIStroke")
    SBStroke.Color = Color3.fromRGB(255,255,255)
    SBStroke.Thickness = 1
    SBStroke.Transparency = 0.75
    SBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SBStroke.Parent = SidebarOuter

    -- Sidebar inner layout: SPACE_BETWEEN top and bottom groups
    -- Top group: tab buttons stacked vertically, gap 5
    local SidebarTop = Instance.new("Frame")
    SidebarTop.Size              = UDim2.new(1, 0, 0, 0)
    SidebarTop.AutomaticSize     = Enum.AutomaticSize.Y
    SidebarTop.Position          = UDim2.new(0, 0, 0, 15)
    SidebarTop.BackgroundTransparency = 1
    SidebarTop.Parent            = SidebarOuter
    Pad(SidebarTop, 0, 8, 0, 8)
    ListLayout(SidebarTop, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 5)

    -- Sidebar bottom: power/exit button
    local SidebarBot = Instance.new("Frame")
    SidebarBot.Size              = UDim2.new(1, 0, 0, 60)
    SidebarBot.Position          = UDim2.new(0, 0, 1, -70)
    SidebarBot.BackgroundTransparency = 1
    SidebarBot.Parent            = SidebarOuter
    Pad(SidebarBot, 0, 8, 0, 8)
    ListLayout(SidebarBot, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, 0)

    -- Power/close sidebar btn
    local PowerBtn = Instance.new("TextButton")
    PowerBtn.Size              = UDim2.new(0, 46, 0, 46)
    PowerBtn.BackgroundColor3  = Color3.fromRGB(0,0,0)
    PowerBtn.BackgroundTransparency = 0.85
    PowerBtn.Text              = "⏻"
    PowerBtn.TextColor3        = T.TextSecondary
    PowerBtn.Font              = Enum.Font.Gotham
    PowerBtn.TextSize          = 16
    PowerBtn.BorderSizePixel   = 0
    PowerBtn.AutoButtonColor   = false
    PowerBtn.Parent            = SidebarBot
    Corner(PowerBtn, T.RadiusSidebarBtn)

    PowerBtn.MouseButton1Click:Connect(function()
        Tween(Win, {Size = UDim2.new(0,820,0,0), BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        SG:Destroy()
    end)

    -- ── Content Area (right of sidebar) ───────────────────
    local ContentArea = Instance.new("Frame")
    ContentArea.Name              = "Content"
    ContentArea.Size              = UDim2.new(1, -96, 1, -20)
    ContentArea.Position          = UDim2.new(0, 96, 0, 10)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent            = Win
    ListLayout(ContentArea, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, 15)

    -- ── Top Bar: subtabs (left) + search + config + avatar (right) ──
    local TopBar = Instance.new("Frame")
    TopBar.Name             = "TopBar"
    TopBar.Size             = UDim2.new(1, 0, 0, 60)
    TopBar.BackgroundTransparency = 1
    TopBar.LayoutOrder      = 0
    TopBar.Parent           = ContentArea

    -- Subtab container (left side, horizontal)
    local SubtabHolder = Instance.new("Frame")
    SubtabHolder.Size             = UDim2.new(0, 0, 1, 0)
    SubtabHolder.AutomaticSize    = Enum.AutomaticSize.X
    SubtabHolder.Position         = UDim2.new(0, 8, 0, 0)
    SubtabHolder.BackgroundTransparency = 1
    SubtabHolder.Parent           = TopBar
    local SubtabLayout = Instance.new("UIListLayout")
    SubtabLayout.FillDirection        = Enum.FillDirection.Horizontal
    SubtabLayout.HorizontalAlignment  = Enum.HorizontalAlignment.Left
    SubtabLayout.VerticalAlignment    = Enum.VerticalAlignment.Center
    SubtabLayout.Padding              = UDim.new(0, 40)
    SubtabLayout.Parent               = SubtabHolder
    Pad(SubtabHolder, 10, 10, 10, 10)

    -- Right controls (search + config + avatar)
    local RightBar = Instance.new("Frame")
    RightBar.Size             = UDim2.new(0, 0, 1, 0)
    RightBar.AutomaticSize    = Enum.AutomaticSize.X
    RightBar.Position         = UDim2.new(1, -280, 0, 7)
    RightBar.BackgroundTransparency = 1
    RightBar.Parent           = TopBar
    local RightLayout = Instance.new("UIListLayout")
    RightLayout.FillDirection       = Enum.FillDirection.Horizontal
    RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    RightLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
    RightLayout.Padding             = UDim.new(0, 10)
    RightLayout.Parent              = RightBar

    -- Search bar (200×45, pill, black/15%)
    local SearchBar = Instance.new("Frame")
    SearchBar.Size             = UDim2.new(0, 190, 0, 40)
    SearchBar.BackgroundColor3 = Color3.fromRGB(0,0,0)
    SearchBar.BackgroundTransparency = 0.85
    SearchBar.BorderSizePixel  = 0
    SearchBar.Parent           = RightBar
    Corner(SearchBar, T.RadiusSearch)

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size              = UDim2.new(1, -36, 1, 0)
    SearchBox.Position          = UDim2.new(0, 34, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text              = ""
    SearchBox.PlaceholderText   = "Search"
    SearchBox.Font              = Enum.Font.Gotham
    SearchBox.TextSize          = 14
    SearchBox.TextColor3        = T.TextPrimary
    SearchBox.PlaceholderColor3 = Color3.fromRGB(255,255,255)
    SearchBox.TextXAlignment    = Enum.TextXAlignment.Left
    SearchBox.BorderSizePixel   = 0
    SearchBox.ClearTextOnFocus  = false
    SearchBox.Parent            = SearchBar

    local SearchIcon = Instance.new("TextLabel")
    SearchIcon.Size             = UDim2.new(0, 16, 0, 16)
    SearchIcon.Position         = UDim2.new(0, 13, 0.5, -8)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Text             = "⌕"
    SearchIcon.Font             = Enum.Font.Gotham
    SearchIcon.TextSize         = 16
    SearchIcon.TextColor3       = T.TextSecondary
    SearchIcon.Parent           = SearchBar

    -- Config button (45×45 pill, black/15%)
    local ConfigBtn = Instance.new("TextButton")
    ConfigBtn.Size             = UDim2.new(0, 40, 0, 40)
    ConfigBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    ConfigBtn.BackgroundTransparency = 0.85
    ConfigBtn.Text             = "📄"
    ConfigBtn.Font             = Enum.Font.Gotham
    ConfigBtn.TextSize         = 14
    ConfigBtn.TextColor3       = T.TextSecondary
    ConfigBtn.BorderSizePixel  = 0
    ConfigBtn.AutoButtonColor  = false
    ConfigBtn.Parent           = RightBar
    Corner(ConfigBtn, T.RadiusSearch)

    -- Avatar circle (45×45, white solid pill)
    local Avatar = Instance.new("Frame")
    Avatar.Size             = UDim2.new(0, 40, 0, 40)
    Avatar.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
    Avatar.BorderSizePixel  = 0
    Avatar.Parent           = RightBar
    Corner(Avatar, T.RadiusSearch)
    local AvaLbl = Instance.new("TextLabel")
    AvaLbl.Size             = UDim2.new(1,0,1,0)
    AvaLbl.BackgroundTransparency = 1
    AvaLbl.Text             = "👤"
    AvaLbl.Font             = Enum.Font.Gotham
    AvaLbl.TextSize         = 16
    AvaLbl.TextColor3       = Color3.fromRGB(255,255,255)
    AvaLbl.Parent           = Avatar

    -- ── Pages container (below top bar) ───────────────────
    local PagesHolder = Instance.new("Frame")
    PagesHolder.Name              = "Pages"
    PagesHolder.Size              = UDim2.new(1, 0, 1, -80)
    PagesHolder.Position          = UDim2.new(0, 0, 0, 75)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.Parent            = ContentArea
    PagesHolder.LayoutOrder       = 1

    -- Make draggable from TopBar
    Draggable(Win, TopBar)

    -- Entrance animation
    Win.Size = UDim2.new(0, 820, 0, 0)
    Win.BackgroundTransparency = 1
    Tween(Win, {Size = UDim2.new(0,820,0,520), BackgroundTransparency = 0.80}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- Store refs
    self._sg            = SG
    self._win           = Win
    self._sidebarTop    = SidebarTop
    self._subtabHolder  = SubtabHolder
    self._pages         = PagesHolder
    self._searchBox     = SearchBox

    return self
end

-- ══════════════════════════════════════════════════════════
--  :AddTab(name, icon)
--  Adds a sidebar icon button + subtab label + page
-- ══════════════════════════════════════════════════════════
function SpectraGlass:AddTab(name, icon)
    icon = icon or "◈"
    local idx = #self._tabs + 1

    -- Sidebar icon button (60×60, black/15%, 20px radius)
    local SBtn = Instance.new("TextButton")
    SBtn.Name              = "STab_"..name
    SBtn.Size              = UDim2.new(0, 46, 0, 46)
    SBtn.BackgroundColor3  = Color3.fromRGB(0,0,0)
    SBtn.BackgroundTransparency = 0.85
    SBtn.Text              = icon
    SBtn.Font              = Enum.Font.Gotham
    SBtn.TextSize          = 18
    SBtn.TextColor3        = Color3.fromRGB(255,255,255)
    SBtn.BorderSizePixel   = 0
    SBtn.AutoButtonColor   = false
    SBtn.LayoutOrder       = idx
    SBtn.Parent            = self._sidebarTop
    Corner(SBtn, T.RadiusSidebarBtn)

    -- Subtab label in top bar
    local SubLabel = Instance.new("TextButton")
    SubLabel.Name              = "Sub_"..name
    SubLabel.Size              = UDim2.new(0, 0, 1, 0)
    SubLabel.AutomaticSize     = Enum.AutomaticSize.X
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text              = name
    SubLabel.Font              = Enum.Font.GothamBold
    SubLabel.TextSize          = 18
    SubLabel.TextColor3        = Color3.fromRGB(255,255,255)
    SubLabel.TextTransparency  = 0.5  -- dim by default
    SubLabel.BorderSizePixel   = 0
    SubLabel.AutoButtonColor   = false
    SubLabel.LayoutOrder       = idx
    SubLabel.Parent            = self._subtabHolder

    -- Page (full content area)
    local Page = Instance.new("ScrollingFrame")
    Page.Name                   = "Page_"..name
    Page.Size                   = UDim2.new(1,0,1,0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel        = 0
    Page.ScrollBarThickness     = 3
    Page.ScrollBarImageColor3   = Color3.fromRGB(255,255,255)
    Page.CanvasSize             = UDim2.new(0,0,0,0)
    Page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    Page.ElasticBehavior        = Enum.ElasticBehavior.Never
    Page.Visible                = false
    Page.Parent                 = self._pages

    -- 3-column grid layout for cards
    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize               = UDim2.new(0, 220, 0, 0)
    Grid.CellPadding            = UDim2.new(0, 12, 0, 12)
    Grid.HorizontalAlignment    = Enum.HorizontalAlignment.Left
    Grid.VerticalAlignment      = Enum.VerticalAlignment.Top
    Grid.FillDirection          = Enum.FillDirection.Horizontal
    Grid.SortOrder              = Enum.SortOrder.LayoutOrder
    Grid.Parent                 = Page
    Pad(Page, 0, 8, 8, 0)

    local Tab = {
        _name      = name,
        _page      = Page,
        _grid      = Grid,
        _sideBtn   = SBtn,
        _subLabel  = SubLabel,
        _lib       = self,
        _cardOrder = 0,
    }

    local function Activate()
        if self._activeTab then
            local p = self._activeTab
            Tween(p._sideBtn, {BackgroundTransparency = 0.85, TextColor3 = Color3.fromRGB(200,200,200)}, 0.18)
            p._subLabel.TextTransparency = 0.5
            p._page.Visible = false
        end
        self._activeTab = Tab
        -- Active sidebar btn: white solid fill (matches Figma "active" = white bg)
        Tween(SBtn, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(255,255,255), TextColor3 = Color3.fromRGB(30,30,30)}, 0.18)
        SubLabel.TextTransparency = 0
        Page.Visible = true
    end

    SBtn.MouseButton1Click:Connect(Activate)
    SubLabel.MouseButton1Click:Connect(Activate)

    SBtn.MouseEnter:Connect(function()
        if self._activeTab ~= Tab then
            Tween(SBtn, {BackgroundTransparency = 0.70}, 0.12)
        end
    end)
    SBtn.MouseLeave:Connect(function()
        if self._activeTab ~= Tab then
            Tween(SBtn, {BackgroundTransparency = 0.85}, 0.12)
        end
    end)

    if #self._tabs == 0 then task.defer(Activate) end
    table.insert(self._tabs, Tab)
    return Tab
end

-- ══════════════════════════════════════════════════════════
--  Internal: GlassCard  (white/15%, 25px radius, border stroke)
--  Returns the card frame + inner layout frame
-- ══════════════════════════════════════════════════════════
local function MakeCard(parent, title, subtitle, order)
    -- Card outer: white/15% glass
    local Card = Instance.new("Frame")
    Card.Name                 = "Card_"..tostring(order)
    Card.Size                 = UDim2.new(1, 0, 0, 0)  -- grid controls width; height auto
    Card.AutomaticSize        = Enum.AutomaticSize.Y
    Card.BackgroundColor3     = Color3.fromRGB(255,255,255)
    Card.BackgroundTransparency = 0.85
    Card.BorderSizePixel      = 0
    Card.LayoutOrder          = order
    Card.Parent               = parent
    Corner(Card, T.RadiusCard)

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color              = Color3.fromRGB(255,255,255)
    CardStroke.Thickness          = 1
    CardStroke.Transparency       = 0.75
    CardStroke.ApplyStrokeMode    = Enum.ApplyStrokeMode.Border
    CardStroke.Parent             = Card

    -- Inner layout
    local Inner = Instance.new("Frame")
    Inner.Size                = UDim2.new(1, 0, 1, 0)
    Inner.AutomaticSize       = Enum.AutomaticSize.Y
    Inner.BackgroundTransparency = 1
    Inner.Parent              = Card
    Pad(Inner, 15, 15, 15, 15)
    ListLayout(Inner, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, 10)

    -- Optional title + subtitle header
    if title then
        local Header = Instance.new("Frame")
        Header.Size             = UDim2.new(1, 0, 0, 0)
        Header.AutomaticSize    = Enum.AutomaticSize.Y
        Header.BackgroundTransparency = 1
        Header.LayoutOrder      = 0
        Header.Parent           = Inner
        ListLayout(Header, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, 3)

        Label(Header, title, 15, 600, T.TextPrimary, Enum.TextXAlignment.Left)
        if subtitle then
            Label(Header, subtitle, 11, 400, T.TextSecondary, Enum.TextXAlignment.Left)
        end
    end

    return Card, Inner
end

-- ══════════════════════════════════════════════════════════
--  Tab:AddCard(config)
--  Adds a glass card to the grid. Returns {card, inner}
--  config = { Title, Subtitle }
-- ══════════════════════════════════════════════════════════
function SpectraGlass:AddCard(tab, config)
    config = config or {}
    tab._cardOrder = tab._cardOrder + 1
    local Card, Inner = MakeCard(tab._page, config.Title, config.Subtitle, tab._cardOrder)
    return { _card = Card, _inner = Inner, _order = 0 }
end

-- ══════════════════════════════════════════════════════════
--  Internal: Row wrapper inside a card
-- ══════════════════════════════════════════════════════════
local function MakeRow(parent, order)
    local Row = Instance.new("Frame")
    Row.Size             = UDim2.new(1, 0, 0, 0)
    Row.AutomaticSize    = Enum.AutomaticSize.Y
    Row.BackgroundTransparency = 1
    Row.LayoutOrder      = order
    Row.Parent           = parent
    ListLayout(Row, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, 3)

    -- Content row (horizontal: label left, control right)
    local Content = Instance.new("Frame")
    Content.Size             = UDim2.new(1, 0, 0, 42)
    Content.BackgroundTransparency = 1
    Content.LayoutOrder      = 0
    Content.Parent           = Row
    Corner(Content, 10)

    local LeftF = Instance.new("Frame")
    LeftF.Size             = UDim2.new(1, -56, 1, 0)
    LeftF.BackgroundTransparency = 1
    LeftF.Parent           = Content
    Pad(LeftF, 10, 0, 10, 10)

    local RightF = Instance.new("Frame")
    RightF.Size             = UDim2.new(0, 50, 1, 0)
    RightF.Position         = UDim2.new(1, -50, 0, 0)
    RightF.BackgroundTransparency = 1
    RightF.Parent           = Content
    Pad(RightF, 10, 8, 10, 0)

    -- Thin white divider below
    local Div = Instance.new("Frame")
    Div.Size             = UDim2.new(1, 0, 0, 1)
    Div.BackgroundColor3 = T.Divider
    Div.BackgroundTransparency = 0.85
    Div.BorderSizePixel  = 0
    Div.LayoutOrder      = 1
    Div.Parent           = Row

    return Row, LeftF, RightF, Div
end

-- ══════════════════════════════════════════════════════════
--  Card:AddToggle
-- ══════════════════════════════════════════════════════════
function SpectraGlass:AddToggle(card, config)
    config = config or {}
    local lbl      = config.Label    or "Toggle"
    local default  = config.Default  or false
    local callback = config.Callback or function() end

    card._order = card._order + 1
    local Row, LeftF, RightF = MakeRow(card._inner, card._order)

    -- Label
    Label(LeftF, lbl, 14, 500, T.TextPrimary, Enum.TextXAlignment.Left, nil, UDim2.new(1,0,1,0))

    -- Toggle pill (40×25, radius 30)
    local Track = Instance.new("Frame")
    Track.Size             = UDim2.new(0, 40, 0, 22)
    Track.Position         = UDim2.new(0, 0, 0.5, -11)
    Track.BackgroundColor3 = default and T.Accent or Color3.fromRGB(255,255,255)
    Track.BackgroundTransparency = default and 0 or 0.85
    Track.BorderSizePixel  = 0
    Track.Parent           = RightF
    Corner(Track, T.RadiusToggle)

    local TrkStroke = Instance.new("UIStroke")
    TrkStroke.Color = Color3.fromRGB(255,255,255)
    TrkStroke.Thickness = 1
    TrkStroke.Transparency = 0.75
    TrkStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    TrkStroke.Parent = Track

    local Knob = Instance.new("Frame")
    Knob.Size             = UDim2.new(0, 18, 0, 18)
    Knob.Position         = default and UDim2.new(0, 20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Knob.BorderSizePixel  = 0
    Knob.ZIndex           = 2
    Knob.Parent           = Track
    Corner(Knob, 100)

    local value = default

    local ClickBtn = Instance.new("TextButton")
    ClickBtn.Size              = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text              = ""
    ClickBtn.ZIndex            = 5
    ClickBtn.Parent            = Row

    local function SetToggle(v)
        value = v
        if v then
            Tween(Track, {BackgroundColor3 = T.Accent, BackgroundTransparency = 0}, 0.18)
            Tween(Knob,  {Position = UDim2.new(0, 20, 0.5, -9)}, 0.18)
        else
            Tween(Track, {BackgroundColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 0.85}, 0.18)
            Tween(Knob,  {Position = UDim2.new(0, 2, 0.5, -9)}, 0.18)
        end
        callback(v)
    end

    ClickBtn.MouseButton1Click:Connect(function() SetToggle(not value) end)

    local obj = {}
    function obj:Set(v) SetToggle(v) end
    function obj:Get() return value end
    return obj
end

-- ══════════════════════════════════════════════════════════
--  Card:AddSlider
-- ══════════════════════════════════════════════════════════
function SpectraGlass:AddSlider(card, config)
    config = config or {}
    local lbl      = config.Label    or "Slider"
    local min      = config.Min      or 0
    local max      = config.Max      or 100
    local default  = config.Default  or min
    local suffix   = config.Suffix   or ""
    local callback = config.Callback or function() end

    card._order = card._order + 1
    local _, LeftF, RightF = MakeRow(card._inner, card._order)

    Label(LeftF, lbl, 14, 500, T.TextPrimary, Enum.TextXAlignment.Left, nil, UDim2.new(1,0,1,0))

    -- Slider track: 150×25 pill, white/15%
    local SliderOuter = Instance.new("Frame")
    SliderOuter.Size              = UDim2.new(0, 140, 0, 22)
    SliderOuter.Position          = UDim2.new(0, 0, 0.5, -11)
    SliderOuter.BackgroundColor3  = Color3.fromRGB(255,255,255)
    SliderOuter.BackgroundTransparency = 0.85
    SliderOuter.BorderSizePixel   = 0
    SliderOuter.ClipsDescendants  = true
    SliderOuter.Parent            = RightF
    Corner(SliderOuter, T.RadiusSlider)

    local SliderStroke = Instance.new("UIStroke")
    SliderStroke.Color = Color3.fromRGB(255,255,255)
    SliderStroke.Thickness = 1
    SliderStroke.Transparency = 0.75
    SliderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SliderStroke.Parent = SliderOuter

    -- Fill (accent blue)
    local pct0 = (default - min) / (max - min)
    local Fill = Instance.new("Frame")
    Fill.Size             = UDim2.new(pct0, 0, 1, 0)
    Fill.BackgroundColor3 = T.Accent
    Fill.BackgroundTransparency = 0
    Fill.BorderSizePixel  = 0
    Fill.ZIndex           = 2
    Fill.Parent           = SliderOuter
    Corner(Fill, T.RadiusSlider)

    -- Thumb (21×21 white circle)
    local Thumb = Instance.new("Frame")
    Thumb.Size             = UDim2.new(0, 18, 0, 18)
    Thumb.Position         = UDim2.new(pct0, -9, 0.5, -9)
    Thumb.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Thumb.BorderSizePixel  = 0
    Thumb.ZIndex           = 3
    Thumb.Parent           = SliderOuter
    Corner(Thumb, 100)

    -- Value label
    local ValLbl = Label(card._inner, tostring(default)..suffix, 11, 400, T.TextSecondary, Enum.TextXAlignment.Right)
    ValLbl.LayoutOrder = card._order
    ValLbl.Size = UDim2.new(0, 140, 0, 14)

    local value    = default
    local dragging = false

    local function SetSlider(v)
        v = math.clamp(math.floor(v + 0.5), min, max)
        value = v
        local p = (v - min) / (max - min)
        Fill.Size     = UDim2.new(p, 0, 1, 0)
        Thumb.Position = UDim2.new(p, -9, 0.5, -9)
        ValLbl.Text   = tostring(v)..suffix
        callback(v)
    end

    SliderOuter.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local rel = math.clamp((Mouse.X - SliderOuter.AbsolutePosition.X) / SliderOuter.AbsoluteSize.X, 0, 1)
            SetSlider(min + rel*(max-min))
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((Mouse.X - SliderOuter.AbsolutePosition.X) / SliderOuter.AbsoluteSize.X, 0, 1)
            SetSlider(min + rel*(max-min))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local obj = {}
    function obj:Set(v) SetSlider(v) end
    function obj:Get() return value end
    return obj
end

-- ══════════════════════════════════════════════════════════
--  Card:AddButton  (pill shaped, white/15% glass, text label)
-- ══════════════════════════════════════════════════════════
function SpectraGlass:AddButton(card, config)
    config = config or {}
    local lbl      = config.Label    or "Button"
    local action   = config.Action   or "Action"
    local callback = config.Callback or function() end

    card._order = card._order + 1
    local _, LeftF, RightF = MakeRow(card._inner, card._order)

    Label(LeftF, lbl, 14, 500, T.TextPrimary, Enum.TextXAlignment.Left, nil, UDim2.new(1,0,1,0))

    -- Pill button (white/15%, pill shape)
    local Btn = Instance.new("TextButton")
    Btn.Size              = UDim2.new(0, 0, 0, 30)
    Btn.AutomaticSize     = Enum.AutomaticSize.X
    Btn.Position          = UDim2.new(0, 0, 0.5, -15)
    Btn.BackgroundColor3  = Color3.fromRGB(255,255,255)
    Btn.BackgroundTransparency = 0.85
    Btn.Text              = action
    Btn.Font              = Enum.Font.Gotham
    Btn.TextSize          = 13
    Btn.TextColor3        = T.TextPrimary
    Btn.BorderSizePixel   = 0
    Btn.AutoButtonColor   = false
    Btn.Parent            = RightF
    Corner(Btn, T.RadiusButton)
    Pad(Btn, 0, 14, 0, 14)

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(255,255,255)
    BtnStroke.Thickness = 1
    BtnStroke.Transparency = 0.75
    BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    BtnStroke.Parent = Btn

    Btn.MouseEnter:Connect(function()
        Tween(Btn, {BackgroundTransparency = 0.60}, 0.12)
    end)
    Btn.MouseLeave:Connect(function()
        Tween(Btn, {BackgroundTransparency = 0.85}, 0.12)
    end)
    Btn.MouseButton1Down:Connect(function()
        Tween(Btn, {BackgroundTransparency = 0.40}, 0.08)
    end)
    Btn.MouseButton1Up:Connect(function()
        Tween(Btn, {BackgroundTransparency = 0.60}, 0.08)
    end)
    Btn.MouseButton1Click:Connect(callback)

    local obj = {}
    function obj:SetLabel(t) Btn.Text = t end
    return obj
end

-- ══════════════════════════════════════════════════════════
--  Card:AddIconButtonGroup  (row of circle icon buttons)
--  Matches the Figma "HStack of ToggleButtons" pattern:
--  45×45 circles, icon + label below, one can be "active" (white solid)
-- ══════════════════════════════════════════════════════════
function SpectraGlass:AddIconButtonGroup(card, config)
    config = config or {}
    local sectionLabel = config.SectionLabel or "Actions"
    local buttons      = config.Buttons      or {}  -- {Icon, Label, Callback, Active}
    local callback     = config.OnChange     or function() end

    card._order = card._order + 1

    -- Section label row
    local SecLbl = Label(card._inner, sectionLabel, 11, 500, T.TextSecondary, Enum.TextXAlignment.Left)
    SecLbl.LayoutOrder = card._order

    card._order = card._order + 1

    -- HStack of icon buttons
    local HStack = Instance.new("Frame")
    HStack.Name             = "IconBtnGroup"
    HStack.Size             = UDim2.new(1, 0, 0, 66)
    HStack.BackgroundTransparency = 1
    HStack.LayoutOrder      = card._order
    HStack.Parent           = card._inner

    local HLayout = Instance.new("UIListLayout")
    HLayout.FillDirection       = Enum.FillDirection.Horizontal
    HLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    HLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
    HLayout.Padding             = UDim.new(0, 0)
    HLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    HLayout.Parent              = HStack

    -- Equal spacing: fill width
    local EqualSpacer = Instance.new("UIListLayout")
    EqualSpacer:Destroy()  -- we'll use manual spacing

    local btnRefs = {}
    local activeIdx = nil
    local totalW = #buttons > 0 and (1/#buttons) or 0

    for i, btnCfg in ipairs(buttons) do
        local isActive = btnCfg.Active == true
        if isActive then activeIdx = i end

        -- Container (ToggleButton vertical stack: circle + label)
        local Container = Instance.new("Frame")
        Container.Size              = UDim2.new(totalW, 0, 1, 0)
        Container.BackgroundTransparency = 1
        Container.LayoutOrder       = i
        Container.ClipsDescendants  = false
        Container.Parent            = HStack
        ListLayout(Container, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center, 5)

        -- Circle button (45×45, radius 100)
        local Circ = Instance.new("TextButton")
        Circ.Size              = UDim2.new(0, 45, 0, 45)
        Circ.BackgroundColor3  = isActive and Color3.fromRGB(255,255,255) or Color3.fromRGB(255,255,255)
        Circ.BackgroundTransparency = isActive and 0 or 0.85
        Circ.Text              = btnCfg.Icon or "◈"
        Circ.Font              = Enum.Font.Gotham
        Circ.TextSize          = 16
        Circ.TextColor3        = isActive and Color3.fromRGB(30,30,30) or T.TextPrimary
        Circ.BorderSizePixel   = 0
        Circ.AutoButtonColor   = false
        Circ.Parent            = Container
        Corner(Circ, T.RadiusIconBtn)

        local CircStroke = Instance.new("UIStroke")
        CircStroke.Color = Color3.fromRGB(255,255,255)
        CircStroke.Thickness = 1
        CircStroke.Transparency = isActive and 0.55 or 0.75
        CircStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        CircStroke.Parent = Circ

        -- Small label below
        local BtnLbl = Instance.new("TextLabel")
        BtnLbl.Size              = UDim2.new(1, 0, 0, 16)
        BtnLbl.BackgroundTransparency = 1
        BtnLbl.Text              = btnCfg.Label or ""
        BtnLbl.Font              = Enum.Font.Gotham
        BtnLbl.TextSize          = 12
        BtnLbl.TextColor3        = T.TextPrimary
        BtnLbl.TextXAlignment    = Enum.TextXAlignment.Center
        BtnLbl.Parent            = Container

        table.insert(btnRefs, { circ = Circ, stroke = CircStroke, lbl = BtnLbl })

        local capturedI = i
        Circ.MouseButton1Click:Connect(function()
            -- Deactivate all
            for j, ref in ipairs(btnRefs) do
                if j == capturedI then
                    Tween(ref.circ, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(30,30,30)}, 0.15)
                else
                    Tween(ref.circ, {BackgroundTransparency = 0.85, TextColor3 = T.TextPrimary}, 0.15)
                end
            end
            activeIdx = capturedI
            if btnCfg.Callback then btnCfg.Callback() end
            callback(capturedI, btnCfg.Label)
        end)

        Circ.MouseEnter:Connect(function()
            if activeIdx ~= capturedI then
                Tween(Circ, {BackgroundTransparency = 0.65}, 0.10)
            end
        end)
        Circ.MouseLeave:Connect(function()
            if activeIdx ~= capturedI then
                Tween(Circ, {BackgroundTransparency = 0.85}, 0.10)
            end
        end)
    end

    return { _hstack = HStack }
end

-- ══════════════════════════════════════════════════════════
--  Card:AddMiniCards  (2-column mini card grid inside a card)
--  Each mini card: 127×127, white/15%, icon + toggle + label
-- ══════════════════════════════════════════════════════════
function SpectraGlass:AddMiniCards(card, miniConfigs)
    card._order = card._order + 1

    local Grid = Instance.new("Frame")
    Grid.Name             = "MiniCardGrid"
    Grid.Size             = UDim2.new(1, 0, 0, 0)
    Grid.AutomaticSize    = Enum.AutomaticSize.Y
    Grid.BackgroundTransparency = 1
    Grid.LayoutOrder      = card._order
    Grid.Parent           = card._inner

    local GridLayout = Instance.new("UIGridLayout")
    GridLayout.CellSize         = UDim2.new(0.48, -4, 0, 110)
    GridLayout.CellPadding      = UDim2.new(0.04, 0, 0, 10)
    GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    GridLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
    GridLayout.FillDirection    = Enum.FillDirection.Horizontal
    GridLayout.SortOrder        = Enum.SortOrder.LayoutOrder
    GridLayout.Parent           = Grid

    local miniObjs = {}

    for i, cfg in ipairs(miniConfigs) do
        -- Mini card: white/15%, 25px radius
        local MiniCard = Instance.new("Frame")
        MiniCard.Name                = "Mini_"..i
        MiniCard.BackgroundColor3    = Color3.fromRGB(255,255,255)
        MiniCard.BackgroundTransparency = 0.85
        MiniCard.BorderSizePixel     = 0
        MiniCard.LayoutOrder         = i
        MiniCard.Parent              = Grid
        Corner(MiniCard, T.RadiusCard)

        local MiniStroke = Instance.new("UIStroke")
        MiniStroke.Color = Color3.fromRGB(255,255,255)
        MiniStroke.Thickness = 1
        MiniStroke.Transparency = 0.75
        MiniStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        MiniStroke.Parent = MiniCard

        -- Inner: space-between (icon+toggle top, label bottom)
        local MiniInner = Instance.new("Frame")
        MiniInner.Size              = UDim2.new(1, 0, 1, 0)
        MiniInner.BackgroundTransparency = 1
        MiniInner.Parent            = MiniCard
        Pad(MiniInner, 14, 14, 14, 14)

        -- Top row: icon left, toggle right
        local TopRow = Instance.new("Frame")
        TopRow.Size             = UDim2.new(1, 0, 0, 24)
        TopRow.BackgroundTransparency = 1
        TopRow.Parent           = MiniInner

        -- Icon
        local IconLbl = Instance.new("TextLabel")
        IconLbl.Size            = UDim2.new(0, 22, 0, 22)
        IconLbl.BackgroundTransparency = 1
        IconLbl.Text            = cfg.Icon or "◈"
        IconLbl.Font            = Enum.Font.Gotham
        IconLbl.TextSize        = 16
        IconLbl.TextColor3      = T.TextPrimary
        IconLbl.Parent          = TopRow

        -- Mini toggle
        local default = cfg.Default or false
        local MiniTrack = Instance.new("Frame")
        MiniTrack.Size             = UDim2.new(0, 36, 0, 22)
        MiniTrack.Position         = UDim2.new(1, -36, 0, 1)
        MiniTrack.BackgroundColor3 = default and T.Accent or Color3.fromRGB(255,255,255)
        MiniTrack.BackgroundTransparency = default and 0 or 0.85
        MiniTrack.BorderSizePixel  = 0
        MiniTrack.Parent           = TopRow
        Corner(MiniTrack, T.RadiusToggle)

        local MiniKnob = Instance.new("Frame")
        MiniKnob.Size             = UDim2.new(0, 16, 0, 16)
        MiniKnob.Position         = default and UDim2.new(0, 18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        MiniKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        MiniKnob.BackgroundTransparency = 0
        MiniKnob.BorderSizePixel  = 0
        MiniKnob.ZIndex           = 2
        MiniKnob.Parent           = MiniTrack
        Corner(MiniKnob, 100)

        -- Label bottom
        local NameLbl = Instance.new("TextLabel")
        NameLbl.Size             = UDim2.new(1, 0, 0, 18)
        NameLbl.Position         = UDim2.new(0, 0, 1, -24)
        NameLbl.BackgroundTransparency = 1
        NameLbl.Text             = cfg.Label or "Item"
        NameLbl.Font             = Enum.Font.GothamBold
        NameLbl.TextSize         = 14
        NameLbl.TextColor3       = T.TextPrimary
        NameLbl.TextXAlignment   = Enum.TextXAlignment.Left
        NameLbl.Parent           = MiniInner

        -- Click toggle
        local val = default
        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size              = UDim2.new(1,0,1,0)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text              = ""
        ClickBtn.ZIndex            = 5
        ClickBtn.Parent            = MiniCard

        local function SetMini(v)
            val = v
            if v then
                Tween(MiniTrack, {BackgroundColor3 = T.Accent, BackgroundTransparency = 0}, 0.18)
                Tween(MiniKnob, {Position = UDim2.new(0, 18, 0.5, -8)}, 0.18)
            else
                Tween(MiniTrack, {BackgroundColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 0.85}, 0.18)
                Tween(MiniKnob, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.18)
            end
            if cfg.Callback then cfg.Callback(v) end
        end

        ClickBtn.MouseButton1Click:Connect(function() SetMini(not val) end)

        local miniObj = {}
        function miniObj:Set(v) SetMini(v) end
        function miniObj:Get() return val end
        table.insert(miniObjs, miniObj)
    end

    return miniObjs
end

-- ══════════════════════════════════════════════════════════
--  Card:AddLabel / AddDivider
-- ══════════════════════════════════════════════════════════
function SpectraGlass:AddLabel(card, text, style)
    card._order = card._order + 1
    local color = style == "secondary" and T.TextSecondary or T.TextPrimary
    local size  = style == "small" and 11 or 14
    local weight = style == "bold" and 600 or 400
    local lbl = Label(card._inner, text, size, weight, color)
    lbl.LayoutOrder = card._order
    return lbl
end

function SpectraGlass:AddDivider(card)
    card._order = card._order + 1
    local Div = Instance.new("Frame")
    Div.Size             = UDim2.new(1, 0, 0, 1)
    Div.BackgroundColor3 = T.Divider
    Div.BackgroundTransparency = 0.85
    Div.BorderSizePixel  = 0
    Div.LayoutOrder      = card._order
    Div.Parent           = card._inner
end

-- ══════════════════════════════════════════════════════════
--  :Notify(config)  –  frosted glass toast (top-right)
-- ══════════════════════════════════════════════════════════
function SpectraGlass:Notify(config)
    config = config or {}
    local title    = config.Title    or "Notification"
    local desc     = config.Description or ""
    local duration = config.Duration or 3

    local Toast = Instance.new("Frame")
    Toast.Size             = UDim2.new(0, 260, 0, desc ~= "" and 62 or 42)
    Toast.Position         = UDim2.new(1, 300, 1, -80)
    Toast.AnchorPoint      = Vector2.new(1, 1)
    Toast.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Toast.BackgroundTransparency = 0.80
    Toast.BorderSizePixel  = 0
    Toast.ZIndex           = 20
    Toast.Parent           = self._sg
    Corner(Toast, 20)

    local ToastStroke = Instance.new("UIStroke")
    ToastStroke.Color = Color3.fromRGB(255,255,255)
    ToastStroke.Thickness = 1
    ToastStroke.Transparency = 0.55
    ToastStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ToastStroke.Parent = Toast

    -- Accent bar left
    local Bar = Instance.new("Frame")
    Bar.Size             = UDim2.new(0, 3, 0.7, 0)
    Bar.Position         = UDim2.new(0, 12, 0.15, 0)
    Bar.BackgroundColor3 = T.Accent
    Bar.BorderSizePixel  = 0
    Bar.ZIndex           = 21
    Bar.Parent           = Toast
    Corner(Bar, 2)

    local TLbl = Label(Toast, title, 13, 600, T.TextPrimary, Enum.TextXAlignment.Left, UDim2.new(0, 22, 0, desc ~= "" and 8 or 12), UDim2.new(1, -30, 0, 18))
    TLbl.ZIndex = 21

    if desc ~= "" then
        local DLbl = Label(Toast, desc, 11, 400, T.TextSecondary, Enum.TextXAlignment.Left, UDim2.new(0, 22, 0, 28), UDim2.new(1, -30, 0, 26))
        DLbl.ZIndex = 21
    end

    -- Slide in
    Toast.Position = UDim2.new(1, 300, 1, -80)
    Tween(Toast, {Position = UDim2.new(1, -16, 1, -80)}, 0.35, Enum.EasingStyle.Back)

    task.delay(duration, function()
        Tween(Toast, {Position = UDim2.new(1, 300, 1, -80)}, 0.28)
        task.wait(0.28)
        Toast:Destroy()
    end)
end

-- ══════════════════════════════════════════════════════════
--  :Destroy()
-- ══════════════════════════════════════════════════════════
function SpectraGlass:Destroy()
    if self._sg then self._sg:Destroy() end
end

-- ══════════════════════════════════════════════════════════
--  EXAMPLE USAGE  –  mirrors the Figma layout exactly
-- ══════════════════════════════════════════════════════════
do
    local lib = SpectraGlass.new("Spectra")

    -- ── TAB 1 (matches sidebar item 1 — arrow/script icon) ──
    local t1 = lib:AddTab("Subtab 1", "→")

    -- Column 1: Mini card grid (Thing 1, Thing 2 style)
    local col1card = lib:AddCard(t1, {})
    lib:AddMiniCards(col1card, {
        { Icon = "✈", Label = "Thing 1", Default = true,  Callback = function(v) print("Thing1:", v) end },
        { Icon = "⬡", Label = "Thing 2", Default = false, Callback = function(v) print("Thing2:", v) end },
    })
    -- Large card below (Thing 3, full width)
    lib:AddDivider(col1card)
    lib:AddToggle(col1card, {
        Label    = "Thing 3",
        Default  = false,
        Callback = function(v) print("Thing3:", v) end
    })

    -- Column 2 card: toggle + slider + button rows
    local col2card = lib:AddCard(t1, {})
    lib:AddToggle(col2card, {
        Label    = "Toggle",
        Default  = true,
        Callback = function(v) print("Toggle:", v) end
    })
    lib:AddSlider(col2card, {
        Label    = "Slider",
        Min      = 0,
        Max      = 100,
        Default  = 75,
        Suffix   = "%",
        Callback = function(v) print("Slider:", v) end
    })
    lib:AddButton(col2card, {
        Label    = "Button",
        Action   = "Action",
        Callback = function() print("Button clicked") end
    })

    -- Column 3 card: Module One (title + subtitle + toggle + icon button group)
    local col3a = lib:AddCard(t1, { Title = "Module One", Subtitle = "Lorem ipsum nibh quisque" })
    lib:AddToggle(col3a, {
        Label    = "Enable",
        Default  = true,
        Callback = function(v) print("Module One:", v) end
    })
    lib:AddLabel(col3a, "Actions", "secondary")
    lib:AddIconButtonGroup(col3a, {
        SectionLabel = "",
        Buttons = {
            { Icon = "⬡", Label = "One",   Active = false, Callback = function() print("Btn One") end },
            { Icon = "⬡", Label = "Two",   Active = true,  Callback = function() print("Btn Two") end },
            { Icon = "⬡", Label = "Three", Active = false, Callback = function() print("Btn Three") end },
            { Icon = "⬡", Label = "Four",  Active = false, Callback = function() print("Btn Four") end },
        },
        OnChange = function(idx, lbl) print("Selected:", lbl) end
    })

    -- Column 3 second card: Module Two
    local col3b = lib:AddCard(t1, { Title = "Module Two", Subtitle = "Lorem ipsum nibh quisque" })
    lib:AddToggle(col3b, {
        Label    = "Enable",
        Default  = false,
        Callback = function(v) print("Module Two:", v) end
    })
    lib:AddLabel(col3b, "Actions", "secondary")
    lib:AddIconButtonGroup(col3b, {
        SectionLabel = "",
        Buttons = {
            { Icon = "⬡", Label = "One",   Active = false, Callback = function() print("M2 One") end },
            { Icon = "⬡", Label = "Two",   Active = false, Callback = function() print("M2 Two") end },
            { Icon = "⬡", Label = "Three", Active = false, Callback = function() print("M2 Three") end },
            { Icon = "⬡", Label = "Four",  Active = true,  Callback = function() print("M2 Four") end },
        },
    })

    -- ── TAB 2 ─────────────────────────────────────────────
    local t2 = lib:AddTab("Subtab 2", "👤")
    local c2a = lib:AddCard(t2, { Title = "Player", Subtitle = "Character settings" })
    lib:AddToggle(c2a, { Label = "God Mode",      Default = false, Callback = function(v) print("GodMode:", v) end })
    lib:AddToggle(c2a, { Label = "Infinite Jump", Default = false, Callback = function(v) print("IJ:", v) end })
    lib:AddSlider(c2a, { Label = "Walk Speed", Min = 1, Max = 200, Default = 16, Callback = function(v) print("Speed:", v) end })
    lib:AddSlider(c2a, { Label = "Jump Power", Min = 1, Max = 500, Default = 50, Callback = function(v) print("Jump:", v) end })

    local c2b = lib:AddCard(t2, { Title = "Teleport" })
    lib:AddButton(c2b, { Label = "To Spawn",  Action = "Go", Callback = function() print("TP Spawn") end })
    lib:AddButton(c2b, { Label = "To Player", Action = "Go", Callback = function() print("TP Player") end })

    -- ── TAB 3 ─────────────────────────────────────────────
    local t3 = lib:AddTab("Visual", "◈")
    local c3a = lib:AddCard(t3, { Title = "Lighting" })
    lib:AddToggle(c3a, { Label = "Fullbright", Default = false, Callback = function(v) game:GetService("Lighting").Brightness = v and 3 or 1 end })
    lib:AddToggle(c3a, { Label = "No Fog",     Default = false, Callback = function(v) game:GetService("Lighting").FogEnd = v and 1e6 or 100000 end })
    lib:AddSlider(c3a, { Label = "FOV", Min = 30, Max = 120, Default = 70, Suffix = "°", Callback = function(v) workspace.CurrentCamera.FieldOfView = v end })

    -- ── TAB 4 (settings / power) ──────────────────────────
    local t4 = lib:AddTab("Settings", "⚙")
    local c4a = lib:AddCard(t4, { Title = "About" })
    lib:AddLabel(c4a, "SpectraGlass UI  v2.0", "bold")
    lib:AddLabel(c4a, "Frosted glass Roblox UI library.", "secondary")
    lib:AddDivider(c4a)
    lib:AddButton(c4a, { Label = "Test Notification", Action = "Send", Callback = function()
        lib:Notify({ Title = "SpectraGlass", Description = "Frosted glass notification.", Duration = 3 })
    end })
    lib:AddButton(c4a, { Label = "Close UI", Action = "Exit", Callback = function()
        lib:Notify({ Title = "Closing...", Duration = 1 })
        task.delay(1.2, function() lib:Destroy() end)
    end })

    -- Welcome
    task.delay(0.5, function()
        lib:Notify({ Title = "SpectraGlass Loaded", Description = "Frosted glass UI ready.", Duration = 4 })
    end)
end

return SpectraGlass
