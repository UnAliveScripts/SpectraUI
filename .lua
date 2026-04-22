--[[
    GlassUI - Roblox UI Library
    Inspired by iOS / visionOS glass design (from Figma)
    Supports: PC + Mobile, Xeno / Delta / any executor, auto-detects environment

    Usage (single-file):
        local GlassUI = loadstring(game:HttpGet("https://your-host/UILibrary.lua"))()

    Or as ModuleScript:
        local GlassUI = require(path.to.UILibrary)

    Author: built from Figma spec. MIT-style, free to use.
]]

local GlassUI = {}
GlassUI.__index = GlassUI
GlassUI.Version = "1.0.0"

-- =========================================================================
-- SERVICES
-- =========================================================================
local function getService(name)
    local s = game:GetService(name)
    return (cloneref and cloneref(s)) or s
end

local TweenService      = getService("TweenService")
local UserInputService  = getService("UserInputService")
local RunService        = getService("RunService")
local Players           = getService("Players")
local CoreGui           = getService("CoreGui")
local Lighting          = getService("Lighting")
local HttpService       = getService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

-- =========================================================================
-- ENVIRONMENT DETECTION
-- =========================================================================
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IS_STUDIO = RunService:IsStudio()

-- Safely parent ScreenGui: tries executor hooks first, falls back to CoreGui/PlayerGui
local function safeParentGui(gui)
    -- gethui (xeno, solara, wave, etc.)
    local ok = pcall(function()
        if gethui then gui.Parent = gethui() return end
    end)
    if ok and gui.Parent then return end

    -- syn.protect_gui (synapse) + CoreGui
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
            gui.Parent = CoreGui
        end
    end)
    if gui.Parent then return end

    -- protect_gui (delta)
    pcall(function()
        if protect_gui then
            protect_gui(gui)
            gui.Parent = CoreGui
        end
    end)
    if gui.Parent then return end

    -- CoreGui direct
    local success = pcall(function() gui.Parent = CoreGui end)
    if success and gui.Parent then return end

    -- Fallback PlayerGui (Studio / low-permission executors)
    if LocalPlayer then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- =========================================================================
-- THEME
-- =========================================================================
local DefaultTheme = {
    -- Window base
    WindowStroke       = Color3.fromRGB(255, 255, 255),
    WindowStrokeAlpha  = 0.85,
    Background         = Color3.fromRGB(30, 30, 32),
    BackgroundAlpha    = 0.25, -- glass

    -- Panels & cards
    Panel              = Color3.fromRGB(255, 255, 255),
    PanelAlpha         = 0.92,  -- very transparent white = frosted glass
    PanelStroke        = Color3.fromRGB(255, 255, 255),
    PanelStrokeAlpha   = 0.85,

    Card               = Color3.fromRGB(255, 255, 255),
    CardAlpha          = 0.93,
    CardStroke         = Color3.fromRGB(255, 255, 255),
    CardStrokeAlpha    = 0.82,

    -- Text
    Text               = Color3.fromRGB(255, 255, 255),
    SubText            = Color3.fromRGB(210, 210, 215),
    Muted              = Color3.fromRGB(170, 170, 175),

    -- Accents
    Accent             = Color3.fromRGB(10, 132, 255),     -- iOS blue
    AccentText         = Color3.fromRGB(255, 255, 255),

    -- Interactive
    ToggleOff          = Color3.fromRGB(120, 120, 125),
    ToggleOffAlpha     = 0.7,
    Slot               = Color3.fromRGB(255, 255, 255),
    SlotAlpha          = 0.88,

    Hover              = Color3.fromRGB(255, 255, 255),
    HoverAlpha         = 0.9,
}

GlassUI.Themes = {
    Default = DefaultTheme,
    Midnight = setmetatable({
        Background = Color3.fromRGB(10, 10, 15),
        BackgroundAlpha = 0.15,
        Accent = Color3.fromRGB(138, 99, 210),
    }, {__index = DefaultTheme}),
    Ocean = setmetatable({
        Accent = Color3.fromRGB(0, 200, 220),
    }, {__index = DefaultTheme}),
    Sunset = setmetatable({
        Accent = Color3.fromRGB(255, 120, 80),
    }, {__index = DefaultTheme}),
}

-- =========================================================================
-- HELPERS
-- =========================================================================
local function new(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, c in ipairs(children or {}) do
        c.Parent = inst
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function corner(radius, parent)
    return new("UICorner", { CornerRadius = UDim.new(0, radius or 12), Parent = parent })
end

local function stroke(color, alpha, thickness, parent)
    return new("UIStroke", {
        Color = color or Color3.fromRGB(255,255,255),
        Transparency = alpha or 0.8,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(all, parent)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, all),
        PaddingBottom = UDim.new(0, all),
        PaddingLeft = UDim.new(0, all),
        PaddingRight = UDim.new(0, all),
        Parent = parent,
    })
end

local function tween(obj, time, props, style, dir)
    local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- Draggable frame (handle to move target)
local function makeDraggable(handle, target)
    local dragging, dragInput, startPos, startMouse
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startMouse = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - startMouse
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- =========================================================================
-- ICONS (Lucide-style via Roblox Icon Library)
-- Fallback: simple unicode if nothing given
-- =========================================================================
local ICON_CACHE = {}
local function getIcon(name)
    if not name or name == "" then return nil end
    if tostring(name):match("^rbxassetid://") then return name end
    if ICON_CACHE[name] then return ICON_CACHE[name] end

    -- Built-in name -> assetId mapping (Roblox system icons / emoji style)
    local MAP = {
        ["power"]    = "rbxassetid://10734898355",
        ["user"]     = "rbxassetid://10747374166",
        ["eye"]      = "rbxassetid://10709810948",
        ["palette"]  = "rbxassetid://10734905643",
        ["settings"] = "rbxassetid://10734950309",
        ["login"]    = "rbxassetid://10734933937",
        ["save"]     = "rbxassetid://10734923542",
        ["search"]   = "rbxassetid://10734924532",
        ["bolt"]     = "rbxassetid://10723424505",
        ["cube"]     = "rbxassetid://10709790644",
        ["arrow"]    = "rbxassetid://10709769377",
        ["focus"]    = "rbxassetid://10734887744",
        ["home"]     = "rbxassetid://10723434215",
        ["star"]     = "rbxassetid://10734898355",
    }
    local id = MAP[tostring(name):lower()]
    if id then ICON_CACHE[name] = id; return id end
    return nil
end

-- =========================================================================
-- NOTIFICATIONS
-- =========================================================================
local NotifStack
local function ensureNotifStack(theme)
    if NotifStack and NotifStack.Parent then return NotifStack end
    local gui = new("ScreenGui", {
        Name = "GlassUI_Notifications",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    safeParentGui(gui)
    NotifStack = new("Frame", {
        Name = "Stack",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 320, 1, -40),
        Position = UDim2.new(1, -340, 0, 20),
        Parent = gui,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = NotifStack,
    })
    return NotifStack
end

function GlassUI:Notify(opts)
    opts = opts or {}
    local theme = self._theme or DefaultTheme
    local stack = ensureNotifStack(theme)

    local typeColors = {
        success = Color3.fromRGB(52, 199, 89),
        error   = Color3.fromRGB(255, 69, 58),
        warning = Color3.fromRGB(255, 159, 10),
        info    = theme.Accent,
    }
    local accent = typeColors[tostring(opts.Type or "info"):lower()] or theme.Accent

    local card = new("Frame", {
        BackgroundColor3 = theme.Panel,
        BackgroundTransparency = theme.PanelAlpha - 0.05,
        Size = UDim2.new(1, 0, 0, 70),
        Position = UDim2.new(1, 20, 0, 0),
    })
    corner(14, card)
    stroke(theme.PanelStroke, theme.PanelStrokeAlpha, 1, card)

    -- colored accent stripe on the left
    new("Frame", {
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, -16),
        Position = UDim2.new(0, 6, 0, 8),
        Parent = card,
    }).Name = "Stripe"
    local stripe = card.Stripe
    corner(2, stripe)

    local title = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 10),
        Size = UDim2.new(1, -32, 0, 20),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = opts.Title or "Notification",
        Parent = card,
    })
    local content = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0, 32),
        Size = UDim2.new(1, -32, 1, -42),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = theme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Text = opts.Content or "",
        Parent = card,
    })

    card.Parent = stack
    tween(card, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(opts.Duration or 4, function()
        tween(card, 0.25, { Position = UDim2.new(1, 20, 0, 0), BackgroundTransparency = 1 })
        for _, d in ipairs(card:GetDescendants()) do
            if d:IsA("TextLabel") then tween(d, 0.25, { TextTransparency = 1 }) end
        end
        task.wait(0.3)
        card:Destroy()
    end)
end

-- =========================================================================
-- WINDOW
-- =========================================================================
function GlassUI:CreateWindow(opts)
    opts = opts or {}
    local theme = opts.Theme
    if type(theme) == "string" then theme = GlassUI.Themes[theme] or DefaultTheme end
    if type(theme) == "table" then
        theme = setmetatable(theme, {__index = DefaultTheme})
    else
        theme = DefaultTheme
    end

    local window = setmetatable({
        _theme = theme,
        _tabs = {},
        _activeTab = nil,
        _activeSubtab = nil,
        _flags = {},          -- flag -> { get=fn, set=fn }
        _configName = opts.ConfigName or (opts.Name or "GlassUI") .. "Config",
        _configFolder = opts.ConfigFolder or "GlassUI/Configs",
    }, GlassUI)
    self._theme = theme

    -- Sizing (responsive)
    local WIN_SIZE = opts.Size or UDim2.fromOffset(IS_MOBILE and 640 or 920, IS_MOBILE and 420 or 620)

    -- Blur effect
    local blur = new("BlurEffect", { Size = 0, Name = "GlassUIBlur", Parent = Lighting })
    window._blur = blur

    -- ScreenGui
    local gui = new("ScreenGui", {
        Name = "GlassUI_" .. (opts.Name or "Window"),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    safeParentGui(gui)
    window._gui = gui

    -- Root window frame (glass container)
    local root = new("Frame", {
        Name = "Root",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = WIN_SIZE,
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = theme.BackgroundAlpha,
        Parent = gui,
    })
    corner(22, root)
    stroke(theme.WindowStroke, theme.WindowStrokeAlpha, 1, root)
    window._root = root

    -- Gradient for subtle depth
    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(180,180,190)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.85),
            NumberSequenceKeypoint.new(1, 0.95),
        }),
        Rotation = 135,
        Parent = root,
    })

    -- Entry animation + blur ramp
    root.Size = UDim2.fromOffset(0, 0)
    tween(root, 0.45, { Size = WIN_SIZE }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tween(blur, 0.45, { Size = 18 })

    -- ================== SIDEBAR ==================
    local sidebar = new("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 64, 1, -24),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = theme.Panel,
        BackgroundTransparency = theme.PanelAlpha,
        Parent = root,
    })
    corner(18, sidebar)
    stroke(theme.PanelStroke, theme.PanelStrokeAlpha, 1, sidebar)

    local sidebarTop = new("Frame", {
        Name = "Top",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.new(0, 0, 0, 8),
        Parent = sidebar,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sidebarTop,
    })

    local sidebarBottom = new("Frame", {
        Name = "Bottom",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 52),
        Position = UDim2.new(0, 0, 1, -52),
        Parent = sidebar,
    })

    -- Power / close button at bottom
    local closeBtn = new("TextButton", {
        Name = "Close",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = theme.Panel,
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Text = "",
        Parent = sidebarBottom,
    })
    corner(12, closeBtn)
    local pwrIcon = new("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(22, 22),
        BackgroundTransparency = 1,
        ImageColor3 = theme.Text,
        Image = getIcon("power") or "",
        Parent = closeBtn,
    })
    if not pwrIcon.Image or pwrIcon.Image == "" then
        pwrIcon:Destroy()
        new("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            Text = "⏻",
            TextColor3 = theme.Text,
            Parent = closeBtn,
        })
    end
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, 0.15, { BackgroundTransparency = 0.85 })
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, 0.15, { BackgroundTransparency = 1 })
    end)
    closeBtn.MouseButton1Click:Connect(function()
        window:Destroy()
    end)

    window._sidebarTop = sidebarTop

    -- ================== CONTENT AREA ==================
    local content = new("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -88, 1, -24),
        Position = UDim2.new(0, 84, 0, 12),
        Parent = root,
    })

    -- Top bar with subtabs, search, save, profile
    local topBar = new("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 52),
        Parent = content,
    })
    makeDraggable(topBar, root)

    -- Title / Subtabs on the left
    local subtabHolder = new("Frame", {
        Name = "Subtabs",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        Parent = topBar,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 20),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = subtabHolder,
    })
    window._subtabHolder = subtabHolder

    -- Right side (search, save, profile)
    local rightBar = new("Frame", {
        Name = "Right",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -6, 0, 0),
        Size = UDim2.new(0, 340, 1, 0),
        Parent = topBar,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = rightBar,
    })

    -- Search
    local searchBar = new("Frame", {
        Size = UDim2.new(0, 230, 0, 36),
        BackgroundColor3 = theme.Panel,
        BackgroundTransparency = theme.PanelAlpha - 0.05,
        Parent = rightBar,
    })
    corner(18, searchBar)
    stroke(theme.PanelStroke, theme.PanelStrokeAlpha, 1, searchBar)

    local searchIcon = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 18, 1, 0),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Text = "⌕",
        TextColor3 = theme.Muted,
        Parent = searchBar,
    })
    local searchBox = new("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        PlaceholderText = "Search",
        PlaceholderColor3 = theme.Muted,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Text = "",
        Parent = searchBar,
    })
    window._searchBox = searchBox

    -- Save button
    local saveBtn = new("TextButton", {
        Size = UDim2.fromOffset(36, 36),
        BackgroundColor3 = theme.Panel,
        BackgroundTransparency = theme.PanelAlpha - 0.05,
        AutoButtonColor = false,
        Text = "",
        Parent = rightBar,
    })
    corner(10, saveBtn)
    stroke(theme.PanelStroke, theme.PanelStrokeAlpha, 1, saveBtn)
    new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Text = "⎙",
        TextColor3 = theme.Text,
        Parent = saveBtn,
    })
    saveBtn.MouseButton1Click:Connect(function()
        local ok = window:SaveConfig()
        if opts.OnSave then opts.OnSave() end
        if ok then
            window:Notify({ Title = "Saved", Content = "Configuration saved.", Duration = 2, Type = "success" })
        else
            window:Notify({ Title = "Save failed", Content = "Filesystem unavailable.", Duration = 3, Type = "warning" })
        end
    end)

    -- Profile
    local profile = new("ImageLabel", {
        Size = UDim2.fromOffset(40, 40),
        BackgroundColor3 = theme.Accent,
        Image = opts.Avatar or "rbxasset://textures/ui/GuiImagePlaceholder.png",
        ScaleType = Enum.ScaleType.Crop,
        Parent = rightBar,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = profile })

    -- ================== TAB PAGES CONTAINER ==================
    local pageArea = new("Frame", {
        Name = "Pages",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -56),
        Position = UDim2.new(0, 0, 0, 56),
        Parent = content,
    })
    window._pageArea = pageArea

    -- Keybind to toggle visibility (desktop)
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
    local visible = true
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey then
            visible = not visible
            if visible then
                gui.Enabled = true
                tween(root, 0.3, { Size = WIN_SIZE })
                tween(blur, 0.3, { Size = 18 })
            else
                tween(root, 0.25, { Size = UDim2.fromOffset(0, 0) })
                tween(blur, 0.25, { Size = 0 })
                task.delay(0.3, function() if not visible then gui.Enabled = false end end)
            end
        end
    end)

    -- Search filter
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if window._activeSubtab then
            window:_filterActive(searchBox.Text:lower())
        end
    end)

    return window
end

-- =========================================================================
-- TAB (sidebar button + container of subtabs)
-- =========================================================================
function GlassUI:CreateTab(opts)
    opts = opts or {}
    local theme = self._theme

    -- Sidebar button
    local btn = new("TextButton", {
        Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = theme.Panel,
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Text = "",
        Parent = self._sidebarTop,
    })
    corner(12, btn)
    local btnStroke = stroke(theme.PanelStroke, 1, 1, btn)

    local icon
    local iconId = getIcon(opts.Icon)
    if iconId then
        icon = new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(22, 22),
            BackgroundTransparency = 1,
            ImageColor3 = theme.Text,
            Image = iconId,
            Parent = btn,
        })
    else
        icon = new("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            Text = (opts.Name or "T"):sub(1,1):upper(),
            TextColor3 = theme.Text,
            Parent = btn,
        })
    end

    -- Tab page (container)
    local page = new("Frame", {
        Name = "TabPage_" .. (opts.Name or "Tab"),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Parent = self._pageArea,
    })

    local tab = {
        _window = self,
        _btn = btn,
        _page = page,
        _subtabs = {},
        Name = opts.Name or "Tab",
    }

    local function activate()
        for _, t in ipairs(self._tabs) do
            t._page.Visible = false
            tween(t._btn, 0.15, { BackgroundTransparency = 1 })
            if t._btn:FindFirstChild("UIStroke") then
                tween(t._btn.UIStroke, 0.15, { Transparency = 1 })
            end
        end
        page.Visible = true
        tween(btn, 0.15, { BackgroundTransparency = theme.PanelAlpha - 0.1 })
        if btnStroke then tween(btnStroke, 0.15, { Transparency = theme.PanelStrokeAlpha }) end
        self._activeTab = tab
        if #tab._subtabs > 0 then
            tab._subtabs[1]:_activate()
        end
    end
    btn.MouseButton1Click:Connect(activate)

    -- Tooltip
    local tip = new("Frame", {
        BackgroundColor3 = theme.Panel,
        BackgroundTransparency = theme.PanelAlpha - 0.2,
        Size = UDim2.fromOffset(0, 28),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(1, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Visible = false,
        ZIndex = 50,
        Parent = btn,
    })
    corner(8, tip); stroke(theme.PanelStroke, theme.PanelStrokeAlpha, 1, tip)
    new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamMedium, TextSize = 12,
        Text = "  " .. (opts.Name or "") .. "  ",
        TextColor3 = theme.Text,
        ZIndex = 51,
        Parent = tip,
    })

    btn.MouseEnter:Connect(function()
        if self._activeTab ~= tab then tween(btn, 0.15, { BackgroundTransparency = 0.85 }) end
        tip.Visible = true
    end)
    btn.MouseLeave:Connect(function()
        if self._activeTab ~= tab then tween(btn, 0.15, { BackgroundTransparency = 1 }) end
        tip.Visible = false
    end)

    table.insert(self._tabs, tab)

    -- auto-activate first tab
    if #self._tabs == 1 then
        task.defer(activate)
    end

    -- ===================================================================
    -- SUBTAB CREATION
    -- ===================================================================
    function tab:CreateSubTab(name)
        local st = {}
        st._tab = self
        st._name = name or "Subtab"

        -- Subtab label (clickable in topbar when this tab is active)
        local label = new("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = Enum.Font.GothamBold,
            TextSize = 22,
            Text = st._name,
            TextColor3 = theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Visible = false,
            Parent = self._window._subtabHolder,
        })
        st._label = label

        -- Subtab page (scrolls contents)
        local sub = new("ScrollingFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.Accent,
            BorderSizePixel = 0,
            Visible = false,
            Parent = self._page,
        })
        st._frame = sub

        -- Grid/row container (3 columns of sections)
        local layout = new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 14),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Wraps = true,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = sub,
        })
        padding(6, sub)

        -- Columns (like Figma: left column stacks cards, middle column stacks group, right column stacks modules)
        local function makeColumn(width)
            local col = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, width, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = sub,
            })
            new("UIListLayout", {
                Padding = UDim.new(0, 14),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = col,
            })
            return col
        end
        -- Responsive widths: 3 columns summing ~ pageArea width
        local W = 260
        st._colLeft  = makeColumn(W)
        st._colMid   = makeColumn(W)
        st._colRight = makeColumn(W)

        function st:_activate()
            for _, other in ipairs(self._tab._subtabs) do
                other._frame.Visible = false
                tween(other._label, 0.15, { TextColor3 = theme.Muted })
            end
            self._frame.Visible = true
            self._tab._window._activeSubtab = self
            tween(self._label, 0.15, { TextColor3 = theme.Text })
        end

        label.MouseButton1Click:Connect(function() st:_activate() end)

        table.insert(self._subtabs, st)

        -- ================ COMPONENT BUILDERS ================
        local function addToGroup(container, el) el.Parent = container end

        -- Generic container for middle column (group-like)
        function st:CreateGroup(opts2)
            opts2 = opts2 or {}
            local _window = self._tab._window
            local card = new("Frame", {
                BackgroundColor3 = theme.Panel,
                BackgroundTransparency = theme.PanelAlpha - 0.02,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = self._colMid,
            })
            corner(18, card)
            stroke(theme.PanelStroke, theme.PanelStrokeAlpha, 1, card)
            padding(16, card)
            new("UIListLayout", {
                Padding = UDim.new(0, 12),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = card,
            })

            local g = { _root = card }

            local function row(height)
                local r = new("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, height or 34),
                    Parent = card,
                })
                return r
            end

            local function separator()
                new("Frame", {
                    BackgroundColor3 = theme.PanelStroke,
                    BackgroundTransparency = 0.85,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1),
                    Parent = card,
                })
            end

            function g:AddToggle(o)
                o = o or {}
                local r = row(34)
                local lbl = new("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 16,
                    Text = o.Name or "Toggle",
                    TextColor3 = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = r,
                })
                local t = GlassUI._buildToggle(theme, o.Default, function(v) if o.Callback then o.Callback(v) end end)
                t.AnchorPoint = Vector2.new(1, 0.5)
                t.Position = UDim2.new(1, 0, 0.5, 0)
                t.Parent = r
                local h = { Set = function(_, v) t:SetValue(v) end, Get = function(_) return t:GetValue() end, _row = r, _label = lbl, _name = o.Name }
                if o.Flag then _window._flags[o.Flag] = { get = function() return t:GetValue() end, set = function(v) t:SetValue(v) end } end
                return h
            end

            function g:AddSeparator() separator() end

            function g:AddSlider(o)
                o = o or {}
                local r = row(54)
                local lbl = new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 100, 0, 20),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 16,
                    Text = o.Name or "Slider",
                    TextColor3 = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = r,
                })
                local track = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(1, -120, 0, 28),
                    BackgroundColor3 = theme.ToggleOff,
                    BackgroundTransparency = 0.6,
                    Parent = r,
                })
                corner(14, track)
                local fill = new("Frame", {
                    BackgroundColor3 = theme.Accent,
                    Size = UDim2.new(0, 0, 1, 0),
                    BorderSizePixel = 0,
                    Parent = track,
                })
                corner(14, fill)
                local knob = new("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.fromOffset(22, 22),
                    BackgroundColor3 = theme.Slot,
                    Parent = track,
                })
                new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

                local min, max = o.Min or 0, o.Max or 100
                local val = math.clamp(o.Default or min, min, max)
                local function setVal(v, silent)
                    val = math.clamp(v, min, max)
                    local pct = (val - min) / (max - min)
                    tween(fill, 0.15, { Size = UDim2.new(pct, 0, 1, 0) })
                    tween(knob, 0.15, { Position = UDim2.new(pct, 0, 0.5, 0) })
                    if not silent and o.Callback then o.Callback(val) end
                end
                setVal(val, true)

                local dragging = false
                local function updateFromInput(input)
                    local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    setVal(min + rel * (max - min))
                end
                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateFromInput(input)
                    end
                end)
                track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch) then
                        updateFromInput(input)
                    end
                end)

                if o.Flag then _window._flags[o.Flag] = { get = function() return val end, set = function(v) setVal(v) end } end
                return {
                    Set = function(_, v) setVal(v) end,
                    Get = function(_) return val end,
                    _row = r, _label = lbl, _name = o.Name,
                }
            end

            function g:AddButton(o)
                o = o or {}
                local r = row(40)
                local lbl = new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -100, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    TextSize = 16,
                    Text = o.Name or "Button",
                    TextColor3 = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = r,
                })
                local btn2 = new("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(86, 32),
                    BackgroundColor3 = theme.Panel,
                    BackgroundTransparency = 0.7,
                    AutoButtonColor = false,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 14,
                    Text = o.Label or "Action",
                    TextColor3 = theme.Text,
                    Parent = r,
                })
                corner(10, btn2)
                stroke(theme.PanelStroke, theme.PanelStrokeAlpha, 1, btn2)
                btn2.MouseEnter:Connect(function() tween(btn2, 0.15, { BackgroundTransparency = 0.5 }) end)
                btn2.MouseLeave:Connect(function() tween(btn2, 0.15, { BackgroundTransparency = 0.7 }) end)
                btn2.MouseButton1Click:Connect(function()
                    tween(btn2, 0.08, { Size = UDim2.fromOffset(82, 30) })
                    task.delay(0.1, function() tween(btn2, 0.12, { Size = UDim2.fromOffset(86, 32) }) end)
                    if o.Callback then o.Callback() end
                end)
                return { _row = r, _label = lbl, _name = o.Name }
            end

            function g:AddInput(o)
                o = o or {}
                local r = row(40)
                local lbl = new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -160, 1, 0),
                    Font = Enum.Font.GothamMedium, TextSize = 16,
                    Text = o.Name or "Input",
                    TextColor3 = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = r,
                })
                local box = new("TextBox", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(150, 32),
                    BackgroundColor3 = theme.Panel,
                    BackgroundTransparency = 0.7,
                    Font = Enum.Font.Gotham, TextSize = 14,
                    PlaceholderText = o.Placeholder or "...",
                    PlaceholderColor3 = theme.Muted,
                    TextColor3 = theme.Text,
                    Text = o.Default or "",
                    ClearTextOnFocus = false,
                    Parent = r,
                })
                corner(10, box)
                stroke(theme.PanelStroke, theme.PanelStrokeAlpha, 1, box)
                box.FocusLost:Connect(function(enter)
                    if o.Callback then o.Callback(box.Text, enter) end
                end)
                return { _row = r, _label = lbl, _name = o.Name }
            end

            function g:AddDropdown(o)
                o = o or {}
                local r = row(40)
                local lbl = new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -160, 1, 0),
                    Font = Enum.Font.GothamMedium, TextSize = 16,
                    Text = o.Name or "Dropdown",
                    TextColor3 = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = r,
                })
                local selected = o.Default or (o.Options and o.Options[1]) or ""
                local ddBtn = new("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(150, 32),
                    BackgroundColor3 = theme.Panel,
                    BackgroundTransparency = 0.7,
                    AutoButtonColor = false,
                    Font = Enum.Font.GothamMedium, TextSize = 13,
                    Text = tostring(selected) .. "  ▾",
                    TextColor3 = theme.Text,
                    Parent = r,
                })
                corner(10, ddBtn)
                stroke(theme.PanelStroke, theme.PanelStrokeAlpha, 1, ddBtn)

                local list = new("Frame", {
                    Visible = false,
                    BackgroundColor3 = theme.Panel,
                    BackgroundTransparency = theme.PanelAlpha - 0.1,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 6),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ZIndex = 10,
                    Parent = ddBtn,
                })
                corner(10, list)
                stroke(theme.PanelStroke, theme.PanelStrokeAlpha, 1, list)
                new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
                padding(6, list)

                local function rebuild()
                    for _, c in ipairs(list:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    for _, opt in ipairs(o.Options or {}) do
                        local optBtn = new("TextButton", {
                            Size = UDim2.new(1, 0, 0, 28),
                            BackgroundColor3 = theme.Panel,
                            BackgroundTransparency = 1,
                            AutoButtonColor = false,
                            Font = Enum.Font.Gotham, TextSize = 13,
                            Text = "  " .. tostring(opt),
                            TextColor3 = theme.Text,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 11,
                            Parent = list,
                        })
                        corner(8, optBtn)
                        optBtn.MouseEnter:Connect(function() tween(optBtn, 0.1, { BackgroundTransparency = 0.85 }) end)
                        optBtn.MouseLeave:Connect(function() tween(optBtn, 0.1, { BackgroundTransparency = 1 }) end)
                        optBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            ddBtn.Text = tostring(opt) .. "  ▾"
                            list.Visible = false
                            if o.Callback then o.Callback(opt) end
                        end)
                    end
                end
                rebuild()
                ddBtn.MouseButton1Click:Connect(function() list.Visible = not list.Visible end)

                return {
                    Set = function(_, v) selected = v; ddBtn.Text = tostring(v) .. "  ▾" end,
                    Refresh = function(_, newOpts) o.Options = newOpts; rebuild() end,
                    _row = r, _label = lbl, _name = o.Name,
                }
            end

            function g:AddParagraph(title, body)
                local r = row(52)
                new("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.GothamBold, TextSize = 15,
                    TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
                    Text = title or "", Parent = r,
                })
                new("TextLabel", {
                    BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 1, -22),
                    Font = Enum.Font.Gotham, TextSize = 13,
                    TextColor3 = theme.SubText,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    TextWrapped = true,
                    Text = body or "", Parent = r,
                })
            end

            function g:AddLabel(text)
                local r = row(22)
                local lbl = new("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamMedium, TextSize = 14,
                    TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
                    Text = text or "", Parent = r,
                })
                return { Set = function(_, t) lbl.Text = tostring(t) end, _row = r }
            end

            function g:AddSection(title)
                local r = row(28)
                new("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(0.5, -8, 1, 0),
                    Font = Enum.Font.GothamBold, TextSize = 12,
                    TextColor3 = theme.Muted, TextXAlignment = Enum.TextXAlignment.Left,
                    Text = tostring(title or ""):upper(), Parent = r,
                })
                new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0.5, -8, 0, 1),
                    BackgroundColor3 = theme.PanelStroke, BackgroundTransparency = 0.85,
                    BorderSizePixel = 0, Parent = r,
                })
            end

            function g:AddKeybind(o)
                o = o or {}
                local r = row(36)
                local lbl = new("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, -110, 1, 0),
                    Font = Enum.Font.GothamMedium, TextSize = 16,
                    Text = o.Name or "Keybind", TextColor3 = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = r,
                })
                local key = o.Default or Enum.KeyCode.Unknown
                local listening = false
                local btn2 = new("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(100, 30),
                    BackgroundColor3 = theme.Panel, BackgroundTransparency = 0.7,
                    AutoButtonColor = false,
                    Font = Enum.Font.GothamMedium, TextSize = 13,
                    Text = key.Name or "None", TextColor3 = theme.Text,
                    Parent = r,
                })
                corner(10, btn2); stroke(theme.PanelStroke, theme.PanelStrokeAlpha, 1, btn2)
                btn2.MouseButton1Click:Connect(function()
                    listening = true
                    btn2.Text = "..."
                    tween(btn2, 0.15, { BackgroundTransparency = 0.4 })
                end)
                UserInputService.InputBegan:Connect(function(input, gp)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        key = input.KeyCode
                        btn2.Text = key.Name
                        listening = false
                        tween(btn2, 0.15, { BackgroundTransparency = 0.7 })
                        if o.ChangedCallback then o.ChangedCallback(key) end
                    elseif not listening and not gp and input.KeyCode == key and o.Callback then
                        o.Callback()
                    end
                end)
                if o.Flag then _window._flags[o.Flag] = {
                    get = function() return key.Name end,
                    set = function(v) if type(v) == "string" and Enum.KeyCode[v] then key = Enum.KeyCode[v]; btn2.Text = v end end,
                } end
                return {
                    Set = function(_, v) if Enum.KeyCode[v] then key = Enum.KeyCode[v]; btn2.Text = v end end,
                    Get = function(_) return key end, _row = r, _name = o.Name,
                }
            end

            function g:AddColorPicker(o)
                o = o or {}
                local r = row(36)
                local lbl = new("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamMedium, TextSize = 16,
                    Text = o.Name or "Color", TextColor3 = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = r,
                })
                local color = o.Default or Color3.fromRGB(255, 120, 80)
                local swatch = new("TextButton", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(40, 24),
                    BackgroundColor3 = color,
                    Text = "", AutoButtonColor = false, Parent = r,
                })
                corner(8, swatch); stroke(theme.PanelStroke, 0.7, 1, swatch)

                local panel = new("Frame", {
                    Visible = false, ZIndex = 20,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 1, 6),
                    Size = UDim2.fromOffset(220, 180),
                    BackgroundColor3 = theme.Panel,
                    BackgroundTransparency = theme.PanelAlpha - 0.1,
                    Parent = swatch,
                })
                corner(12, panel); stroke(theme.PanelStroke, theme.PanelStrokeAlpha, 1, panel)
                padding(10, panel)

                -- SV area
                local sv = new("ImageLabel", {
                    Size = UDim2.new(1, 0, 0, 120),
                    BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                    Image = "rbxassetid://4155801252", -- white->black gradient overlay trick; fallback solid
                    ZIndex = 21, Parent = panel,
                })
                corner(8, sv)
                local svKnob = new("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Size = UDim2.fromOffset(10, 10),
                    BackgroundTransparency = 1, BorderSizePixel = 0,
                    ZIndex = 23, Parent = sv,
                })
                new("UICorner", { CornerRadius = UDim.new(1,0), Parent = svKnob })
                stroke(Color3.fromRGB(255,255,255), 0, 2, svKnob)

                -- Hue slider
                local hue = new("Frame", {
                    Position = UDim2.new(0, 0, 0, 128),
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 0, ZIndex = 21, Parent = panel,
                })
                corner(8, hue)
                local grad = Instance.new("UIGradient")
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, Color3.fromHSV(0, 1, 1)),
                    ColorSequenceKeypoint.new(0.16, Color3.fromHSV(1/6, 1, 1)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromHSV(2/6, 1, 1)),
                    ColorSequenceKeypoint.new(0.50, Color3.fromHSV(3/6, 1, 1)),
                    ColorSequenceKeypoint.new(0.66, Color3.fromHSV(4/6, 1, 1)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromHSV(5/6, 1, 1)),
                    ColorSequenceKeypoint.new(1.00, Color3.fromHSV(1, 1, 1)),
                })
                grad.Parent = hue
                local hueKnob = new("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.fromOffset(6, 20),
                    BackgroundColor3 = Color3.new(1,1,1),
                    ZIndex = 22, Parent = hue,
                })
                corner(3, hueKnob)

                local h, s, v = 0, 1, 1
                local function apply()
                    local c = Color3.fromHSV(h, s, v)
                    color = c
                    swatch.BackgroundColor3 = c
                    sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    svKnob.Position = UDim2.new(s, 0, 1 - v, 0)
                    hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
                    if o.Callback then o.Callback(c) end
                end
                -- Initial
                do local hh, ss, vv = Color3.toHSV(color); h, s, v = hh, ss, vv; apply() end

                local svDrag, hueDrag = false, false
                sv.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        svDrag = true
                    end
                end)
                sv.InputEnded:Connect(function() svDrag = false end)
                hue.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        hueDrag = true
                    end
                end)
                hue.InputEnded:Connect(function() hueDrag = false end)
                UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
                    if svDrag then
                        s = math.clamp((inp.Position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
                        v = 1 - math.clamp((inp.Position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
                        apply()
                    elseif hueDrag then
                        h = math.clamp((inp.Position.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 1)
                        apply()
                    end
                end)

                swatch.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

                if o.Flag then _window._flags[o.Flag] = {
                    get = function() return { color.R, color.G, color.B } end,
                    set = function(t) if type(t) == "table" and #t == 3 then color = Color3.new(t[1], t[2], t[3]); local hh, ss, vv = Color3.toHSV(color); h,s,v = hh,ss,vv; apply() end end,
                } end
                return {
                    Set = function(_, c) color = c; local hh, ss, vv = Color3.toHSV(c); h,s,v = hh,ss,vv; apply() end,
                    Get = function(_) return color end, _row = r, _name = o.Name,
                }
            end

            return g
        end

        -- "Thing" tile card (small tile with optional inner toggle + title)
        function st:CreateCard(o)
            o = o or {}
            local card = new("Frame", {
                BackgroundColor3 = theme.Card,
                BackgroundTransparency = theme.CardAlpha - 0.02,
                Size = UDim2.new(1, 0, 0, o.Size == "large" and 260 or 120),
                Parent = self._colLeft,
            })
            corner(18, card)
            stroke(theme.CardStroke, theme.CardStrokeAlpha, 1, card)

            -- top row: icon + toggle
            local topR = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -24, 0, 34),
                Position = UDim2.new(0, 12, 0, 12),
                Parent = card,
            })
            local icn = new("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(24, 24),
                ImageColor3 = theme.Text,
                Image = getIcon(o.Icon) or "",
                Parent = topR,
            })
            if icn.Image == "" then
                icn:Destroy()
                new("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(24, 24),
                    Font = Enum.Font.GothamBold, TextSize = 18,
                    Text = (o.Icon == "bolt" and "⚡") or "◆",
                    TextColor3 = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = topR,
                })
            end
            local togg = GlassUI._buildToggle(theme, o.Default, function(v) if o.Callback then o.Callback(v) end end)
            togg.AnchorPoint = Vector2.new(1, 0.5)
            togg.Position = UDim2.new(1, 0, 0.5, 0)
            togg.Parent = topR

            -- title at bottom-left
            local title = new("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 14, 1, -32),
                Size = UDim2.new(1, -28, 0, 24),
                Font = Enum.Font.GothamMedium, TextSize = 16,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = o.Title or "Card",
                Parent = card,
            })

            return {
                Set = function(_, v) togg:SetValue(v) end,
                _card = card, _title = title, _name = o.Title,
            }
        end

        -- Module card (title + desc + toggle + row of icon "Actions")
        function st:CreateModule(o)
            o = o or {}
            local card = new("Frame", {
                BackgroundColor3 = theme.Card,
                BackgroundTransparency = theme.CardAlpha - 0.02,
                Size = UDim2.new(1, 0, 0, 196),
                Parent = self._colRight,
            })
            corner(18, card)
            stroke(theme.CardStroke, theme.CardStrokeAlpha, 1, card)

            -- title
            local title = new("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 14),
                Size = UDim2.new(1, -70, 0, 22),
                Font = Enum.Font.GothamBold, TextSize = 17,
                TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = o.Title or "Module",
                Parent = card,
            })
            local desc = new("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 36),
                Size = UDim2.new(1, -32, 0, 20),
                Font = Enum.Font.Gotham, TextSize = 13,
                TextColor3 = theme.Muted,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = o.Description or "",
                Parent = card,
            })
            local togg = GlassUI._buildToggle(theme, o.Default, function(v) if o.Callback then o.Callback(v) end end)
            togg.AnchorPoint = Vector2.new(1, 0)
            togg.Position = UDim2.new(1, -14, 0, 16)
            togg.Parent = card

            local actionsLbl = new("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 16, 0, 76),
                Size = UDim2.new(1, -32, 0, 18),
                Font = Enum.Font.GothamMedium, TextSize = 13,
                TextColor3 = theme.Muted,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Actions",
                Parent = card,
            })

            local actionsRow = new("Frame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 100),
                Size = UDim2.new(1, -24, 0, 86),
                Parent = card,
            })
            new("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 8),
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                Parent = actionsRow,
            })

            local buttons = {}
            local function addAction(a, idx)
                local holder = new("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(52, 86),
                    Parent = actionsRow,
                })
                local b = new("TextButton", {
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Size = UDim2.fromOffset(52, 52),
                    BackgroundColor3 = theme.Slot,
                    BackgroundTransparency = 0.7,
                    AutoButtonColor = false,
                    Text = "",
                    Parent = holder,
                })
                new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = b })
                stroke(theme.PanelStroke, 0.9, 1, b)
                local ic = new("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.fromOffset(22, 22),
                    BackgroundTransparency = 1,
                    ImageColor3 = theme.Text,
                    Image = getIcon(a.Icon or "cube") or "",
                    Parent = b,
                })
                if ic.Image == "" then
                    ic:Destroy()
                    new("TextLabel", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = UDim2.fromOffset(24, 24),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold, TextSize = 16,
                        Text = "◈", TextColor3 = theme.Text, Parent = b,
                    })
                end
                new("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 58),
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham, TextSize = 12,
                    TextColor3 = theme.Text,
                    Text = a.Name or ("Action " .. idx),
                    Parent = holder,
                })

                local function setSelected(sel)
                    if sel then
                        tween(b, 0.15, { BackgroundColor3 = theme.Slot, BackgroundTransparency = 0.05 })
                        tween(ic, 0.15, { ImageColor3 = Color3.fromRGB(0,0,0) })
                    else
                        tween(b, 0.15, { BackgroundColor3 = theme.Slot, BackgroundTransparency = 0.7 })
                        tween(ic, 0.15, { ImageColor3 = theme.Text })
                    end
                end

                b.MouseEnter:Connect(function()
                    tween(b, 0.12, { Size = UDim2.fromOffset(56, 56) })
                end)
                b.MouseLeave:Connect(function()
                    tween(b, 0.12, { Size = UDim2.fromOffset(52, 52) })
                end)
                b.MouseButton1Click:Connect(function()
                    for _, other in ipairs(buttons) do other.setSelected(false) end
                    setSelected(true)
                    if a.Callback then a.Callback() end
                end)

                buttons[#buttons+1] = { btn = b, setSelected = setSelected, name = a.Name }
            end

            for i, a in ipairs(o.Actions or {}) do addAction(a, i) end

            -- Default selected
            if o.DefaultAction and buttons[o.DefaultAction] then
                buttons[o.DefaultAction].setSelected(true)
            end

            return {
                Set = function(_, v) togg:SetValue(v) end,
                AddAction = function(_, a) addAction(a, #buttons + 1) end,
                _card = card, _title = title, _desc = desc, _name = o.Title,
            }
        end

        -- Auto-activate first subtab
        if #self._subtabs == 1 then
            task.defer(function() st:_activate() end)
        end

        return st
    end

    return tab
end

-- =========================================================================
-- TOGGLE COMPONENT FACTORY
-- =========================================================================
function GlassUI._buildToggle(theme, default, callback)
    local frame = new("Frame", {
        Size = UDim2.fromOffset(44, 26),
        BackgroundColor3 = theme.ToggleOff,
        BackgroundTransparency = theme.ToggleOffAlpha,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = frame })
    stroke(theme.PanelStroke, 0.85, 1, frame)

    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = theme.Slot,
        BackgroundTransparency = 0.05,
        Parent = frame,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

    local btn = new("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })

    local val = default and true or false
    local function apply(animate)
        if val then
            tween(frame, 0.2, { BackgroundColor3 = theme.Accent, BackgroundTransparency = 0.1 })
            tween(knob, 0.2, { Position = UDim2.new(1, -23, 0.5, 0) }, Enum.EasingStyle.Back)
        else
            tween(frame, 0.2, { BackgroundColor3 = theme.ToggleOff, BackgroundTransparency = theme.ToggleOffAlpha })
            tween(knob, 0.2, { Position = UDim2.new(0, 3, 0.5, 0) }, Enum.EasingStyle.Back)
        end
    end
    apply(false)

    btn.MouseButton1Click:Connect(function()
        val = not val
        apply(true)
        if callback then callback(val) end
    end)

    function frame:SetValue(v)
        val = v and true or false
        apply(true)
        if callback then callback(val) end
    end
    function frame:GetValue() return val end

    return frame
end

-- =========================================================================
-- SEARCH FILTER
-- =========================================================================
function GlassUI:_filterActive(q)
    local st = self._activeSubtab
    if not st then return end
    local cols = { st._colLeft, st._colMid, st._colRight }
    for _, col in ipairs(cols) do
        for _, c in ipairs(col:GetChildren()) do
            if c:IsA("Frame") then
                local visible = true
                if q and q ~= "" then
                    local txt = ""
                    for _, d in ipairs(c:GetDescendants()) do
                        if d:IsA("TextLabel") or d:IsA("TextButton") then
                            txt = txt .. " " .. tostring(d.Text):lower()
                        end
                    end
                    visible = txt:find(q, 1, true) ~= nil
                end
                c.Visible = visible
            end
        end
    end
end

-- =========================================================================
-- DESTROY
-- =========================================================================
function GlassUI:Destroy()
    if self._blur then
        tween(self._blur, 0.25, { Size = 0 })
        task.delay(0.3, function() if self._blur then self._blur:Destroy() end end)
    end
    if self._root then
        tween(self._root, 0.25, { Size = UDim2.fromOffset(0, 0) })
    end
    task.delay(0.35, function()
        if self._gui then self._gui:Destroy() end
    end)
end

-- =========================================================================
-- THEME UPDATE (live)
-- =========================================================================
function GlassUI:SetTheme(t)
    if type(t) == "string" then t = GlassUI.Themes[t] end
    if type(t) ~= "table" then return end
    -- Merge and reload: for simplicity, only accents can be live-tweened
    for k, v in pairs(t) do self._theme[k] = v end
    -- Re-tint visible scroll bars etc.
    for _, d in ipairs(self._gui:GetDescendants()) do
        if d:IsA("ScrollingFrame") then d.ScrollBarImageColor3 = self._theme.Accent end
    end
end

-- =========================================================================
-- CONFIG PERSISTENCE (save/load using executor filesystem)
-- =========================================================================
local function _jsonEncode(t) return HttpService:JSONEncode(t) end
local function _jsonDecode(s) local ok, v = pcall(function() return HttpService:JSONDecode(s) end); return ok and v or nil end
local function _fsWrite(path, data)
    if writefile then pcall(writefile, path, data) end
end
local function _fsRead(path)
    if readfile and isfile and isfile(path) then
        local ok, v = pcall(readfile, path)
        if ok then return v end
    end
end
local function _fsMkdir(path)
    if makefolder and isfolder and not isfolder(path) then pcall(makefolder, path) end
end

local function _encodeValue(v)
    if typeof(v) == "Color3" then return { __t = "Color3", v[1] or v.R, v.G, v.B } end
    if typeof(v) == "EnumItem" then return { __t = "Enum", tostring(v) } end
    return v
end
local function _decodeValue(v)
    if type(v) == "table" and v.__t == "Color3" then return Color3.new(v[1], v[2], v[3]) end
    return v
end

function GlassUI:SaveConfig(name)
    name = name or self._configName
    if not writefile then return false, "no filesystem" end
    _fsMkdir(self._configFolder)
    local data = {}
    for flag, ref in pairs(self._flags or {}) do
        local val = ref.get()
        data[flag] = _encodeValue(val)
    end
    local full = self._configFolder .. "/" .. name .. ".json"
    _fsWrite(full, _jsonEncode(data))
    return true
end

function GlassUI:LoadConfig(name)
    name = name or self._configName
    local full = self._configFolder .. "/" .. name .. ".json"
    local raw = _fsRead(full)
    if not raw then return false, "no config" end
    local data = _jsonDecode(raw)
    if not data then return false, "decode error" end
    for flag, val in pairs(data) do
        local ref = self._flags[flag]
        if ref and ref.set then
            pcall(ref.set, _decodeValue(val))
        end
    end
    return true
end

function GlassUI:RegisterFlag(name, getter, setter)
    self._flags[name] = { get = getter, set = setter }
end

-- =========================================================================
-- RETURN
-- =========================================================================
return GlassUI
