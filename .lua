--// MacLib Phase 7 - Part 1 of 4
--// Concatenate P1 -> P2 -> P3 -> P4 in order.

--// MACLIB UI – PHASE 7 BUILD
--// Added: Sound FX, TweenSpeed control, Rainbow accents,
--// Background images, Custom cursor, Element highlight flash.
--// Mobile-first additions: Touch hitboxes, subtab dropdowns, long-press menus,
--// virtual keyboard handling, and 32×32 mobile toggle button.
--// Icons are fetched from GitHub; only a tiny fallback table is baked-in.

local MacLib = {
	GetService = function(service)
		return cloneref and cloneref(game:GetService(service)) or game:GetService(service)
	end,
	ConfigData = {},
	Notifications = {},
	NotifyQueue = {},
	Elements = {},
	Themes = {},
	LucideIcons = {},
	ActiveWindow = nil,
	ActiveGui = nil,
	ToggleKey = nil,
	MobileToggle = nil,
	_UIVisible = true,
	Version = "1.0.0",
	CurrentProfile = "Default",
}

local TweenService = MacLib.GetService("TweenService")
local RunService = MacLib.GetService("RunService")
local Players = MacLib.GetService("Players")
local ContentProvider = MacLib.GetService("ContentProvider")
local UserInputService = MacLib.GetService("UserInputService")
local TextService = MacLib.GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = MacLib.GetService("CoreGui")
local SoundService = MacLib.GetService("SoundService")

-- ====================== EXTERNAL ICONS (PRIMARY) ======================
local function GetIcons(url)
	local rawSource = game:HttpGet(url)
	local ok, result = pcall(function()
		return loadstring(rawSource)()
	end)
	if ok and type(result) == "table" then
		return result
	end
	ok, result = pcall(function()
		return loadstring(rawSource .. "\nreturn Icons")()
	end)
	if ok and type(result) == "table" then
		return result
	end
	return {}
end

local Icons = {}
pcall(function()
	Icons = GetIcons("https://raw.githubusercontent.com/UnAliveScripts/icons/refs/heads/main/.lua")
end)

-- Minimal fallback for critical icons only
local FallbackIcons = {
	aperture = "rbxassetid://7733666258",
	user       = "rbxassetid://7743875962",
	eye        = "rbxassetid://7733774602",
	clock      = "rbxassetid://7733734848",
	settings   = "rbxassetid://7734053495",
	power      = "rbxassetid://7734042493",
	search     = "rbxassetid://7734052925",
	box        = "rbxassetid://7733917120",
	flashlight = "rbxassetid://7733798851",
	crosshair  = "rbxassetid://7733765307",
	file       = "rbxassetid://7733789088",
	lock       = "rbxassetid://7733992528",
	grid       = "rbxassetid://7733955179",
	chevron    = "rbxassetid://7733715400",
	check      = "rbxassetid://7733715400",
	x          = "rbxassetid://7733715400",
	globe      = "rbxassetid://7733942656",
	menu       = "rbxassetid://7733955179",
	home       = "rbxassetid://7733774602",
	shield     = "rbxassetid://7733992528",
	sword      = "rbxassetid://7733765307",
	heart      = "rbxassetid://7733774602",
	star       = "rbxassetid://7733942656",
	bell       = "rbxassetid://7733734848",
	trash      = "rbxassetid://7734042493",
	edit       = "rbxassetid://7733789088",
	copy       = "rbxassetid://7733917120",
	download   = "rbxassetid://7733798851",
	upload     = "rbxassetid://7733798851",
	refresh    = "rbxassetid://7733666258",
	play       = "rbxassetid://7733765307",
	pause      = "rbxassetid://7733734848",
	skip       = "rbxassetid://7734052925",
	volume     = "rbxassetid://7733774602",
	mute       = "rbxassetid://7733992528",
	monitor    = "rbxassetid://7733789088",
	smartphone = "rbxassetid://7733917120",
	tablet     = "rbxassetid://7733955179",
	mouse      = "rbxassetid://7743875962",
	keyboard   = "rbxassetid://7734053495",
	gamepad    = "rbxassetid://7733765307",
	target     = "rbxassetid://7733765307",
	anchor     = "rbxassetid://7733666258",
	alert      = "rbxassetid://7733715400",
	award      = "rbxassetid://7733942656",
	bookmark   = "rbxassetid://7733789088",
	calendar   = "rbxassetid://7733734848",
	camera     = "rbxassetid://7733774602",
	code       = "rbxassetid://7733917120",
	compass    = "rbxassetid://7733666258",
	database   = "rbxassetid://7733955179",
	flag_icon  = "rbxassetid://7733942656",
	gift       = "rbxassetid://7733917120",
	hash       = "rbxassetid://7733955179",
	image      = "rbxassetid://7733774602",
	key        = "rbxassetid://7734053495",
	layers     = "rbxassetid://7733917120",
	link       = "rbxassetid://7733789088",
	map        = "rbxassetid://7733942656",
	music      = "rbxassetid://7733734848",
	paperclip  = "rbxassetid://7733789088",
	radio      = "rbxassetid://7734052925",
	save       = "rbxassetid://7733992528",
	share      = "rbxassetid://7733942656",
	tag        = "rbxassetid://7733917120",
	terminal   = "rbxassetid://7733765307",
	tool       = "rbxassetid://7733798851",
	video      = "rbxassetid://7733774602",
	wifi       = "rbxassetid://7734052925",
	wrench     = "rbxassetid://7733798851",
	zoom_in    = "rbxassetid://7734052925",
	zoom_out   = "rbxassetid://7734052925",
	loader     = "rbxassetid://7733666258",
	activity   = "rbxassetid://7733765307",
	airplay    = "rbxassetid://7733666258",
	align_center  = "rbxassetid://7733955179",
	align_justify = "rbxassetid://7733955179",
	align_left    = "rbxassetid://7733955179",
	align_right   = "rbxassetid://7733955179",
	archive    = "rbxassetid://7733917120",
	arrow_down = "rbxassetid://7733715400",
	arrow_left = "rbxassetid://7733715400",
	arrow_right= "rbxassetid://7733715400",
	arrow_up   = "rbxassetid://7733715400",
	at_sign    = "rbxassetid://7733942656",
	battery    = "rbxassetid://7734042493",
	bluetooth  = "rbxassetid://7734053495",
	book       = "rbxassetid://7733789088",
	briefcase  = "rbxassetid://7733917120",
	brush      = "rbxassetid://7733798851",
	bug        = "rbxassetid://7733765307",
	building   = "rbxassetid://7733789088",
	car        = "rbxassetid://7733666258",
	cast       = "rbxassetid://7733942656",
	check_circle = "rbxassetid://7733715400",
	check_square = "rbxassetid://7733715400",
	chrome     = "rbxassetid://7733774602",
	circle     = "rbxassetid://7733666258",
	cloud      = "rbxassetid://7734053495",
	coffee     = "rbxassetid://7733734848",
	command    = "rbxassetid://7734053495",
	cpu        = "rbxassetid://7733765307",
	credit_card= "rbxassetid://7733917120",
	crop       = "rbxassetid://7733765307",
	delete     = "rbxassetid://7734042493",
	disc       = "rbxassetid://7733666258",
	dollar_sign= "rbxassetid://7733917120",
	droplet    = "rbxassetid://7733774602",
	external_link = "rbxassetid://7733789088",
	eye_off    = "rbxassetid://7733992528",
	fast_forward = "rbxassetid://7734052925",
	feather    = "rbxassetid://7733798851",
	figma      = "rbxassetid://7733765307",
	filter     = "rbxassetid://7733955179",
	folder     = "rbxassetid://7733789088",
	framer     = "rbxassetid://7733765307",
	frown      = "rbxassetid://7733774602",
	github     = "rbxassetid://7733917120",
	gitlab     = "rbxassetid://7733789088",
	glasses    = "rbxassetid://7733774602",
	globe_2    = "rbxassetid://7733942656",
	hard_drive = "rbxassetid://7733789088",
	headphones = "rbxassetid://7733774602",
	help_circle= "rbxassetid://7733666258",
	hide       = "rbxassetid://7733992528",
	inbox      = "rbxassetid://7733917120",
	info       = "rbxassetid://7733666258",
	italic     = "rbxassetid://7733789088",
	layout     = "rbxassetid://7733955179",
	life_buoy  = "rbxassetid://7733666258",
	list       = "rbxassetid://7733955179",
	log_in     = "rbxassetid://7733789088",
	log_out    = "rbxassetid://7733789088",
	mail       = "rbxassetid://7733917120",
	map_pin    = "rbxassetid://7733942656",
	maximize   = "rbxassetid://7734052925",
	maximize_2 = "rbxassetid://7734052925",
	meh        = "rbxassetid://7733774602",
	message_circle = "rbxassetid://7733666258",
	message_square = "rbxassetid://7733917120",
	mic        = "rbxassetid://7733774602",
	mic_off    = "rbxassetid://7733992528",
	minimize   = "rbxassetid://7734042493",
	minimize_2 = "rbxassetid://7734042493",
	move       = "rbxassetid://7733765307",
	package    = "rbxassetid://7733917120",
	phone      = "rbxassetid://7733774602",
	pie_chart  = "rbxassetid://7733666258",
	plus       = "rbxassetid://7733715400",
	plus_circle= "rbxassetid://7733666258",
	plus_square= "rbxassetid://7733917120",
	printer    = "rbxassetid://7733789088",
	rewind     = "rbxassetid://7734052925",
	rocket     = "rbxassetid://7733798851",
	scissors   = "rbxassetid://7733765307",
	server     = "rbxassetid://7733955179",
	settings_2 = "rbxassetid://7734053495",
	shopping_bag  = "rbxassetid://7733917120",
	shopping_cart = "rbxassetid://7733917120",
	shuffle    = "rbxassetid://7733765307",
	sidebar    = "rbxassetid://7733955179",
	slack      = "rbxassetid://7733917120",
	slash      = "rbxassetid://7733765307",
	sliders    = "rbxassetid://7734053495",
	smile      = "rbxassetid://7733774602",
	speaker    = "rbxassetid://7733774602",
	square     = "rbxassetid://7733917120",
	stop_circle= "rbxassetid://7734042493",
	sunrise    = "rbxassetid://7733942656",
	sunset     = "rbxassetid://7733942656",
	table_icon = "rbxassetid://7733955179",
	thermometer= "rbxassetid://7733734848",
	thumbs_down= "rbxassetid://7734042493",
	thumbs_up  = "rbxassetid://7734053495",
	toggle_left = "rbxassetid://7734042493",
	toggle_right= "rbxassetid://7734053495",
	trash_2    = "rbxassetid://7734042493",
	trending_down = "rbxassetid://7734042493",
	trending_up= "rbxassetid://7734052925",
	triangle   = "rbxassetid://7733765307",
	truck      = "rbxassetid://7733666258",
	tv         = "rbxassetid://7733789088",
	umbrella   = "rbxassetid://7734053495",
	unlock     = "rbxassetid://7733992528",
	user_check = "rbxassetid://7743875962",
	user_minus = "rbxassetid://7743875962",
	user_plus  = "rbxassetid://7743875962",
	user_x     = "rbxassetid://7743875962",
	users      = "rbxassetid://7743875962",
	voicemail  = "rbxassetid://7733774602",
	watch      = "rbxassetid://7733734848",
	wifi_off   = "rbxassetid://7733992528",
	wind       = "rbxassetid://7733798851",
}

setmetatable(Icons, { __index = FallbackIcons })
setmetatable(MacLib.LucideIcons, { __index = FallbackIcons })

-- Resolve any icon string (GitHub name, Lucide name, fallback name, or rbxassetid)
local function ResolveIcon(icon)
	if not icon then return "" end
	if typeof(icon) == "string" and icon:sub(1, 11) == "rbxassetid://" then
		return icon
	end
	if typeof(icon) == "string" then
		local lower = icon:lower()
		local github = Icons[lower]
		if github then return github end
		local lucide = MacLib.LucideIcons[lower]
		if lucide then return lucide end
		local fallback = FallbackIcons[lower]
		if fallback then return fallback end
	end
	return tostring(icon)
end

-- ====================== THEME PRESETS ======================
MacLib.Themes.Dark = {
	WindowColor = Color3.fromRGB(28, 28, 30),
	WindowTransparency = 0.1,
	SidebarColor = Color3.fromRGB(42, 42, 46),
	SidebarTransparency = 0.15,
	CardFrontColor = Color3.fromRGB(55, 55, 60),
	CardFrontTransparency = 0.3,
	CardBackColor = Color3.fromRGB(32, 32, 36),
	CardBackTransparency = 0.5,
	ToggleOn = Color3.fromRGB(36, 176, 255),
	ToggleOff = Color3.fromRGB(100, 100, 105),
	SliderFill = Color3.fromRGB(36, 176, 255),
	SliderBg = Color3.fromRGB(100, 100, 105),
	ButtonBg = Color3.fromRGB(255, 255, 255),
	ButtonTransparency = 0.88,
	IconBtnActive = Color3.fromRGB(255, 255, 255),
	IconBtnActiveTransparency = 0.15,
	IconBtnInactive = Color3.fromRGB(255, 255, 255),
	IconBtnInactiveTransparency = 0.88,
	TextColor = Color3.fromRGB(255, 255, 255),
	TextDimColor = Color3.fromRGB(170, 170, 175),
	StrokeColor = Color3.fromRGB(255, 255, 255),
	StrokeTransparency = 0.55,
	SelectionColor = Color3.fromRGB(255, 255, 255),
	SelectionTransparency = 0.88,
	SearchBg = Color3.fromRGB(0, 0, 0),
	SearchBgTransparency = 0.8,
	DropdownBg = Color3.fromRGB(40, 40, 44),
	NotificationInfo = Color3.fromRGB(36, 176, 255),
	NotificationSuccess = Color3.fromRGB(50, 220, 100),
	NotificationError = Color3.fromRGB(255, 60, 60),
}

MacLib.Themes.Ocean = {
	WindowColor = Color3.fromRGB(20, 30, 48),
	WindowTransparency = 0.1,
	SidebarColor = Color3.fromRGB(28, 42, 66),
	SidebarTransparency = 0.15,
	CardFrontColor = Color3.fromRGB(40, 58, 90),
	CardFrontTransparency = 0.3,
	CardBackColor = Color3.fromRGB(24, 36, 56),
	CardBackTransparency = 0.5,
	ToggleOn = Color3.fromRGB(0, 200, 255),
	ToggleOff = Color3.fromRGB(80, 100, 130),
	SliderFill = Color3.fromRGB(0, 200, 255),
	SliderBg = Color3.fromRGB(80, 100, 130),
	ButtonBg = Color3.fromRGB(255, 255, 255),
	ButtonTransparency = 0.88,
	IconBtnActive = Color3.fromRGB(255, 255, 255),
	IconBtnActiveTransparency = 0.15,
	IconBtnInactive = Color3.fromRGB(255, 255, 255),
	IconBtnInactiveTransparency = 0.88,
	TextColor = Color3.fromRGB(255, 255, 255),
	TextDimColor = Color3.fromRGB(160, 180, 210),
	StrokeColor = Color3.fromRGB(255, 255, 255),
	StrokeTransparency = 0.55,
	SelectionColor = Color3.fromRGB(255, 255, 255),
	SelectionTransparency = 0.88,
	SearchBg = Color3.fromRGB(0, 0, 0),
	SearchBgTransparency = 0.8,
	DropdownBg = Color3.fromRGB(32, 48, 72),
	NotificationInfo = Color3.fromRGB(0, 200, 255),
	NotificationSuccess = Color3.fromRGB(50, 220, 100),
	NotificationError = Color3.fromRGB(255, 60, 60),
}

MacLib.Themes.Midnight = {
	WindowColor = Color3.fromRGB(18, 18, 28),
	WindowTransparency = 0.1,
	SidebarColor = Color3.fromRGB(30, 30, 45),
	SidebarTransparency = 0.15,
	CardFrontColor = Color3.fromRGB(45, 45, 65),
	CardFrontTransparency = 0.3,
	CardBackColor = Color3.fromRGB(25, 25, 38),
	CardBackTransparency = 0.5,
	ToggleOn = Color3.fromRGB(147, 112, 219),
	ToggleOff = Color3.fromRGB(90, 90, 110),
	SliderFill = Color3.fromRGB(147, 112, 219),
	SliderBg = Color3.fromRGB(90, 90, 110),
	ButtonBg = Color3.fromRGB(255, 255, 255),
	ButtonTransparency = 0.88,
	IconBtnActive = Color3.fromRGB(255, 255, 255),
	IconBtnActiveTransparency = 0.15,
	IconBtnInactive = Color3.fromRGB(255, 255, 255),
	IconBtnInactiveTransparency = 0.88,
	TextColor = Color3.fromRGB(240, 240, 255),
	TextDimColor = Color3.fromRGB(150, 150, 180),
	StrokeColor = Color3.fromRGB(255, 255, 255),
	StrokeTransparency = 0.55,
	SelectionColor = Color3.fromRGB(255, 255, 255),
	SelectionTransparency = 0.88,
	SearchBg = Color3.fromRGB(0, 0, 0),
	SearchBgTransparency = 0.8,
	DropdownBg = Color3.fromRGB(35, 35, 50),
	NotificationInfo = Color3.fromRGB(147, 112, 219),
	NotificationSuccess = Color3.fromRGB(50, 220, 100),
	NotificationError = Color3.fromRGB(255, 60, 60),
}

MacLib.Themes.Synapse = {
	WindowColor = Color3.fromRGB(30, 30, 30),
	WindowTransparency = 0.05,
	SidebarColor = Color3.fromRGB(45, 45, 45),
	SidebarTransparency = 0.1,
	CardFrontColor = Color3.fromRGB(60, 60, 60),
	CardFrontTransparency = 0.2,
	CardBackColor = Color3.fromRGB(35, 35, 35),
	CardBackTransparency = 0.4,
	ToggleOn = Color3.fromRGB(255, 170, 0),
	ToggleOff = Color3.fromRGB(100, 100, 100),
	SliderFill = Color3.fromRGB(255, 170, 0),
	SliderBg = Color3.fromRGB(100, 100, 100),
	ButtonBg = Color3.fromRGB(255, 255, 255),
	ButtonTransparency = 0.9,
	IconBtnActive = Color3.fromRGB(255, 255, 255),
	IconBtnActiveTransparency = 0.15,
	IconBtnInactive = Color3.fromRGB(255, 255, 255),
	IconBtnInactiveTransparency = 0.9,
	TextColor = Color3.fromRGB(255, 255, 255),
	TextDimColor = Color3.fromRGB(180, 180, 180),
	StrokeColor = Color3.fromRGB(255, 255, 255),
	StrokeTransparency = 0.6,
	SelectionColor = Color3.fromRGB(255, 255, 255),
	SelectionTransparency = 0.9,
	SearchBg = Color3.fromRGB(20, 20, 20),
	SearchBgTransparency = 0.7,
	DropdownBg = Color3.fromRGB(45, 45, 45),
	NotificationInfo = Color3.fromRGB(255, 170, 0),
	NotificationSuccess = Color3.fromRGB(50, 220, 100),
	NotificationError = Color3.fromRGB(255, 60, 60),
}

-- ====================== CONFIG ======================
local Config = {
	WindowSize = UDim2.fromOffset(640, 420),
	SidebarWidth = 60,
	IconSize = 18,
	IconSpacing = 4,
	TopbarHeight = 40,
	SubtabFontSize = 15,
	CardCorner = 12,
	ToggleWidth = 34,
	ToggleHeight = 18,
	ToggleKnob = 14,
	SliderWidth = 100,
	SliderHeight = 18,
	SliderKnob = 14,
	ButtonHeight = 28,
	ButtonCorner = 14,
	Font = "rbxassetid://12187365364",
	TitleSize = 13,
	SubSize = 10,
	NormalSize = 12,
	UseBlur = true,
	ColumnWidth = 180,
	ColumnGap = 8,
	RowGap = 8,
	ModuleButtonSize = 32,
	MaxSubtabs = 2,
	ConfigFile = "MacLib_Config.json",
	Sounds = true,
	SoundVolume = 0.5,
	TweenSpeed = 1,
	AutoSave = true,
	MinWindowSize = Vector2.new(400, 300),
	MaxWindowSize = Vector2.new(1200, 800),
}

-- Mobile adjustments
local IsMobile = UserInputService.TouchEnabled
if IsMobile then
	Config.ToggleWidth = 44
	Config.ToggleHeight = 26
	Config.ToggleKnob = 20
	Config.SliderHeight = 32
	Config.SliderKnob = 22
	Config.ModuleButtonSize = 40
	Config.ButtonHeight = 36
	Config.IconSize = 22
end

-- ====================== SOUND SYSTEM ======================
local Sounds = {
	Click = nil,
	Hover = nil,
}

local function InitSounds()
	if Sounds.Click then return end
	Sounds.Click = Instance.new("Sound")
	Sounds.Click.SoundId = "rbxassetid://9113083740"
	Sounds.Click.Volume = Config.SoundVolume
	Sounds.Click.Parent = SoundService

	Sounds.Hover = Instance.new("Sound")
	Sounds.Hover.SoundId = "rbxassetid://9113083741"
	Sounds.Hover.Volume = Config.SoundVolume * 0.3
	Sounds.Hover.Parent = SoundService
end

local function PlaySound(soundName)
	if not Config.Sounds then return end
	InitSounds()
	local sound = Sounds[soundName]
	if sound then
		sound.Volume = (soundName == "Click" and Config.SoundVolume or Config.SoundVolume * 0.3)
		sound:Play()
	end
end

-- ====================== HIGHLIGHT FLASH ======================
local Tween, ThemeElements

local function FlashHighlight(targetInstance)
	if not targetInstance then return end
	local flash = Instance.new("Frame")
	flash.Name = "HighlightFlash"
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.BackgroundColor3 = Color3.fromRGB(255, 235, 59)
	flash.BackgroundTransparency = 0.2
	flash.BorderSizePixel = 0
	flash.ZIndex = 50
	local existingCorner = targetInstance:FindFirstChildOfClass("UICorner")
	if existingCorner then
		local corner = Instance.new("UICorner", flash)
		corner.CornerRadius = existingCorner.CornerRadius
	end
	flash.Parent = targetInstance
	Tween(flash, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {BackgroundTransparency = 1})
	task.delay(0.4, function()
		if flash and flash.Parent then flash:Destroy() end
	end)
end

local CurrentTheme = MacLib.Themes.Dark

-- ====================== RAINBOW ACCENT SYSTEM ======================
MacLib.RainbowMode = false
MacLib.RainbowSpeed = 30 -- seconds per full cycle
MacLib.RainbowConn = nil

local function UpdateRainbow()
	local hue = (tick() / MacLib.RainbowSpeed) % 1
	local rainbowColor = Color3.fromHSV(hue, 0.85, 1)
	for _, data in ipairs(ThemeElements) do
		local obj = data.Object
		if obj and obj.Parent then
			if data.Role == "ToggleOn" then
				obj.BackgroundColor3 = rainbowColor
			elseif data.Role == "SliderFill" then
				obj.BackgroundColor3 = rainbowColor
			elseif data.Role == "IconBtnActive" and obj:GetAttribute("Active") then
				obj.BackgroundColor3 = rainbowColor
			end
		end
	end
end

local function ManageRainbowConnection(enabled)
	if enabled == MacLib.RainbowMode then return end
	MacLib.RainbowMode = enabled
	if enabled then
		if not MacLib.RainbowConn then
			MacLib.RainbowConn = RunService.RenderStepped:Connect(UpdateRainbow)
		end
	else
		if MacLib.RainbowConn then
			MacLib.RainbowConn:Disconnect()
			MacLib.RainbowConn = nil
			ApplyTheme(CurrentTheme)
		end
	end
end


-- ====================== FRAME POOL ======================
local FramePool = {}
local function GetFrame()
	local f = table.remove(FramePool)
	if f then
		f:ClearAllChildren()
		f.BackgroundTransparency = 1
		f.Size = UDim2.new()
		f.Position = UDim2.new()
		return f
	end
	return Instance.new("Frame")
end
local function ReturnFrame(f)
	if #FramePool < 50 then
		for _, child in ipairs(f:GetChildren()) do
			if child:IsA("Frame") and #FramePool < 50 then
				child:ClearAllChildren()
				child.Parent = nil
				table.insert(FramePool, child)
			end
		end
		f:ClearAllChildren()
		f.Parent = nil
		table.insert(FramePool, f)
	else
		f:Destroy()
	end
end

-- ====================== UTILS ======================
Tween = function(inst, info, props)
	local newTime = info.Time * Config.TweenSpeed
	local newInfo = TweenInfo.new(
		newTime,
		info.EasingStyle,
		info.EasingDirection,
		info.RepeatCount,
		info.Reverses,
		info.DelayTime
	)
	TweenService:Create(inst, newInfo, props):Play()
end

ThemeElements = setmetatable({}, {__mode = "v"})

local function CleanupThemeElements(obj)
	for i = #ThemeElements, 1, -1 do
		if ThemeElements[i].Object == obj then
			table.remove(ThemeElements, i)
		end
	end
end

local function GetTextSizeSafe(text, textSize, maxWidth)
	local ok, result = pcall(function()
		return TextService:GetTextSize(text, textSize, Enum.Font.Gotham, Vector2.new(maxWidth or 9999, 9999))
	end)
	if ok then return result end
	return Vector2.new(0, textSize)
end

local function MakeGlass(width, height, searchTags)
	local base = GetFrame()
	base.BackgroundTransparency = 1
	base.Size = UDim2.fromOffset(width, height)
	base:SetAttribute("IsCard", true)
	if searchTags then
		base:SetAttribute("SearchTags", searchTags:lower())
	end

	local back = GetFrame()
	back.BackgroundColor3 = CurrentTheme.CardBackColor
	back.BackgroundTransparency = CurrentTheme.CardBackTransparency
	back.Size = UDim2.new(1,0,1,0)
	back.Position = UDim2.new(0,2,0,2)
	back.BorderSizePixel = 0
	back.ZIndex = 1
	Instance.new("UICorner", back).CornerRadius = UDim.new(0, Config.CardCorner)
	back.Parent = base

	local card = GetFrame()
	card.BackgroundColor3 = CurrentTheme.CardFrontColor
	card.BackgroundTransparency = CurrentTheme.CardFrontTransparency
	card.Size = UDim2.new(1,0,1,0)
	card.BorderSizePixel = 0
	card.ZIndex = 2
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, Config.CardCorner)
	local stroke = Instance.new("UIStroke", card)
	stroke.Color = CurrentTheme.StrokeColor
	stroke.Transparency = CurrentTheme.StrokeTransparency
	stroke.Thickness = 1
	stroke.ZIndex = 3
	card.Parent = base
	return base, card
end

-- ====================== RIPPLE EFFECT SYSTEM ======================
local function CreateRipple(button, x, y)
	local ripple = Instance.new("Frame")
	ripple.Name = "Ripple"
	ripple.BackgroundColor3 = (button:IsA("TextButton") and button.TextColor3) or Color3.new(1, 1, 1)
	ripple.BackgroundTransparency = 0.5
	ripple.BorderSizePixel = 0
	ripple.ZIndex = button.ZIndex + 1

	local buttonSize = button.AbsoluteSize
	local maxDim = math.max(buttonSize.X, buttonSize.Y)
	ripple.Size = UDim2.fromOffset(0, 0)
	ripple.Position = UDim2.fromOffset(x - button.AbsolutePosition.X, y - button.AbsolutePosition.Y)
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)

	local corner = Instance.new("UICorner", ripple)
	corner.CornerRadius = UDim.new(1, 0)

	ripple.Parent = button

	Tween(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(maxDim * 2, maxDim * 2),
		BackgroundTransparency = 1
	})

	task.delay(0.4, function()
		if ripple and ripple.Parent then
			ripple:Destroy()
		end
	end)
end

-- ====================== MOBILE TOUCH HITBOX ======================
local function AddTouchHitbox(target, parent, onActivate, minSize)
	if not IsMobile then return nil end
	minSize = minSize or 32
	local hit = Instance.new("TextButton")
	hit.Name = "TouchHitbox"
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.AutoButtonColor = false
	hit.ZIndex = (target.ZIndex or 1) + 50

	local function refresh()
		if not target.Parent then return end
		local tSize = target.AbsoluteSize
		local tPos = target.AbsolutePosition
		local pPos = parent.AbsolutePosition
		local w = math.max(minSize, tSize.X + 8)
		local h = math.max(minSize, tSize.Y + 8)
		hit.Size = UDim2.fromOffset(w, h)
		hit.Position = UDim2.fromOffset(
			tPos.X - pPos.X - (w - tSize.X)/2,
			tPos.Y - pPos.Y - (h - tSize.Y)/2
		)
	end

	target:GetPropertyChangedSignal("AbsolutePosition"):Connect(refresh)
	target:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
	task.defer(refresh)

	if onActivate then
		hit.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.Touch then
				onActivate(inp)
			end
		end)
	end

	hit.Parent = parent
	return hit
end

-- ====================== BLUR SYSTEM ======================
MacLib.ActiveBlurs = setmetatable({}, {__mode = "v"})
MacLib.BlurUpdateConn = nil

local function GlobalBlurUpdate()
	local i = 1
	while i <= #MacLib.ActiveBlurs do
		local blur = MacLib.ActiveBlurs[i]
		if blur and blur.UpdateOrientation then
			blur:UpdateOrientation(true)
			i = i + 1
		else
			table.remove(MacLib.ActiveBlurs, i)
		end
	end
end

local BlurSystem = {}

function BlurSystem:New(targetFrame)
	local self = {}
	local HS = game:GetService('HttpService')
	local camera = workspace.CurrentCamera
	local MTREL = "Glass"
	local wedgeguid = HS:GenerateGUID(true)
	local root = Instance.new('Folder')
	root.Name = HS:GenerateGUID(true)

	local DepthOfField = MacLib.GlobalDepthOfField
	if not DepthOfField then
		DepthOfField = game:GetService("Lighting"):FindFirstChild("MacLib_DoF")
		if not DepthOfField then
			DepthOfField = Instance.new("DepthOfFieldEffect")
			DepthOfField.Name = "MacLib_DoF"
			DepthOfField.FarIntensity = 0
			DepthOfField.FocusDistance = 51.6
			DepthOfField.InFocusRadius = 50
			DepthOfField.NearIntensity = 1
			DepthOfField.Parent = game:GetService("Lighting")
		end
		MacLib.GlobalDepthOfField = DepthOfField
	end

	do
		local function IsNotNaN(x)
			return x == x
		end
		local continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
		while not continue do
			RunService.RenderStepped:Wait()
			continue = IsNotNaN(camera:ScreenPointToRay(0,0).Origin.x)
		end
	end

	local DrawQuad
	do
		local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
		local sz = 0.2

		local function DrawTriangle(v1, v2, v3, p0, p1)
			local s1 = (v1 - v2).magnitude
			local s2 = (v2 - v3).magnitude
			local s3 = (v3 - v1).magnitude
			local smax = max(s1, s2, s3)
			local A, B, C
			if s1 == smax then
				A, B, C = v1, v2, v3
			elseif s2 == smax then
				A, B, C = v2, v3, v1
			elseif s3 == smax then
				A, B, C = v3, v1, v2
			end

			local para = ( (B-A).x*(C-A).x + (B-A).y*(C-A).y + (B-A).z*(C-A).z ) / (A-B).magnitude
			local perp = sqrt((C-A).magnitude^2 - para*para)
			local dif_para = (A - B).magnitude - para

			local st = CFrame.new(B, A)
			local za = CFrame.Angles(pi/2,0,0)

			local cf0 = st
			local Top_Look = (cf0 * za).lookVector
			local Mid_Point = A + CFrame.new(A, B).lookVector * para
			local Needed_Look = CFrame.new(Mid_Point, C).lookVector
			local dot = Top_Look.x*Needed_Look.x + Top_Look.y*Needed_Look.y + Top_Look.z*Needed_Look.z
			local ac = CFrame.Angles(0, 0, acos(dot))

			cf0 = cf0 * ac
			if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
				cf0 = cf0 * CFrame.Angles(0, 0, -2*acos(dot))
			end
			cf0 = cf0 * CFrame.new(0, perp/2, -(dif_para + para/2))

			local cf1 = st * ac * CFrame.Angles(0, pi, 0)
			if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
				cf1 = cf1 * CFrame.Angles(0, 0, 2*acos(dot))
			end
			cf1 = cf1 * CFrame.new(0, perp/2, dif_para/2)

			if not p0 then
				p0 = Instance.new('Part')
				p0.FormFactor = 'Custom'
				p0.TopSurface = 0
				p0.BottomSurface = 0
				p0.Anchored = true
				p0.CanCollide = false
				p0.CastShadow = false
				p0.Material = MTREL
				p0.Size = Vector3.new(sz, sz, sz)
				p0.Name = HS:GenerateGUID(true)
				local mesh = Instance.new('SpecialMesh', p0)
				mesh.MeshType = 2
				mesh.Name = wedgeguid
			end
			p0[wedgeguid].Scale = Vector3.new(0, perp/sz, para/sz)
			p0.CFrame = cf0

			if not p1 then
				p1 = p0:clone()
			end
			p1[wedgeguid].Scale = Vector3.new(0, perp/sz, dif_para/sz)
			p1.CFrame = cf1

			return p0, p1
		end

		function DrawQuad(v1, v2, v3, v4, parts)
			parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
			parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
		end
	end

	local parts = {}
	local f = Instance.new('Folder', root)
	f.Name = HS:GenerateGUID(true)

	local parents = {}
	do
		local function add(child)
			if child:IsA'GuiObject' then
				parents[#parents + 1] = child
				add(child.Parent)
			end
		end
		add(targetFrame)
	end

	local function IsVisible(instance)
		while instance do
			if instance:IsA("GuiObject") then
				if not instance.Visible then return false end
			elseif instance:IsA("ScreenGui") then
				if not instance.Enabled then return false end
				break
			end
			instance = instance.Parent
		end
		return true
	end

	local function UpdateOrientation(fetchProps)
		if not IsVisible(targetFrame) then
			for _, pt in pairs(parts) do pt.Parent = nil end
			return
		end

		local properties = {
			Transparency = 0.98;
			BrickColor = BrickColor.new('Institutional white');
		}
		local zIndex = 1 - 0.05*targetFrame.ZIndex

		local tl, br = targetFrame.AbsolutePosition, targetFrame.AbsolutePosition + targetFrame.AbsoluteSize
		local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
		do
			local rot = 0;
			for _, v in ipairs(parents) do
				rot = rot + v.Rotation
			end
			if rot ~= 0 and rot%180 ~= 0 then
				local mid = tl:lerp(br, 0.5)
				local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
				tl = Vector2.new(c*(tl.x - mid.x) - s*(tl.y - mid.y), s*(tl.x - mid.x) + c*(tl.y - mid.y)) + mid
				tr = Vector2.new(c*(tr.x - mid.x) - s*(tr.y - mid.y), s*(tr.x - mid.x) + c*(tr.y - mid.y)) + mid
				bl = Vector2.new(c*(bl.x - mid.x) - s*(bl.y - mid.y), s*(bl.x - mid.x) + c*(bl.y - mid.y)) + mid
				br = Vector2.new(c*(br.x - mid.x) - s*(br.y - mid.y), s*(br.x - mid.x) + c*(br.y - mid.y)) + mid
			end
		end
		DrawQuad(
			camera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin, 
			camera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin, 
			camera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin, 
			camera:ScreenPointToRay(br.x, br.y, zIndex).Origin, 
			parts
		)
		if fetchProps then
			for _, pt in pairs(parts) do pt.Parent = f end
			for propName, propValue in pairs(properties) do
				for _, pt in pairs(parts) do pt[propName] = propValue end
			end
		end
	end

	local enabled = false

	function self:Enable()
		if enabled then return end
		enabled = true
		root.Parent = camera
		DepthOfField.Enabled = true
		self:UpdateOrientation(true)
		table.insert(MacLib.ActiveBlurs, self)
		if not MacLib.BlurUpdateConn then
			MacLib.BlurUpdateConn = RunService.RenderStepped:Connect(GlobalBlurUpdate)
		end
	end

	function self:Disable()
		if not enabled then return end
		enabled = false
		root.Parent = nil
		DepthOfField.Enabled = false
		for i = #MacLib.ActiveBlurs, 1, -1 do
			if MacLib.ActiveBlurs[i] == self then
				table.remove(MacLib.ActiveBlurs, i)
				break
			end
		end
		if #MacLib.ActiveBlurs == 0 and MacLib.BlurUpdateConn then
			MacLib.BlurUpdateConn:Disconnect()
			MacLib.BlurUpdateConn = nil
		end
		for _, pt in pairs(parts) do pt.Parent = nil end
	end

	function self:SetState(state)
		if state then self:Enable() else self:Disable() end
	end

	function self:Destroy()
		self:Disable()
		root:Destroy()
	end

	function self:SetIntensity(intensity)
		intensity = math.clamp(intensity, 0, 1)
		if DepthOfField then
			DepthOfField.NearIntensity = intensity
		end
	end

	self.UpdateOrientation = UpdateOrientation
	return self
end


--// MacLib Phase 7 - Part 2 of 4
--// Concatenate P1 -> P2 -> P3 -> P4 in order.

-- ====================== THEME SWITCHER ======================
local function ApplyTheme(theme)
	CurrentTheme = theme
	for _, data in ipairs(ThemeElements) do
		local obj = data.Object
		if obj and obj.Parent then
			if data.Role == "Window" then
				obj.BackgroundColor3 = theme.WindowColor
				obj.BackgroundTransparency = theme.WindowTransparency
			elseif data.Role == "Sidebar" then
				obj.BackgroundColor3 = theme.SidebarColor
				obj.BackgroundTransparency = theme.SidebarTransparency
			elseif data.Role == "CardFront" then
				obj.BackgroundColor3 = theme.CardFrontColor
				obj.BackgroundTransparency = theme.CardFrontTransparency
			elseif data.Role == "CardBack" then
				obj.BackgroundColor3 = theme.CardBackColor
				obj.BackgroundTransparency = theme.CardBackTransparency
			elseif data.Role == "ToggleOn" then
				obj.BackgroundColor3 = theme.ToggleOn
			elseif data.Role == "ToggleOff" then
				obj.BackgroundColor3 = theme.ToggleOff
			elseif data.Role == "SliderFill" then
				obj.BackgroundColor3 = theme.SliderFill
			elseif data.Role == "SliderBg" then
				obj.BackgroundColor3 = theme.SliderBg
			elseif data.Role == "Button" then
				obj.BackgroundColor3 = theme.ButtonBg
				obj.BackgroundTransparency = theme.ButtonTransparency
			elseif data.Role == "IconBtnActive" then
				if obj:GetAttribute("Active") then
					obj.BackgroundColor3 = theme.IconBtnActive
					obj.BackgroundTransparency = theme.IconBtnActiveTransparency
				end
			elseif data.Role == "IconBtnInactive" then
				if not obj:GetAttribute("Active") then
					obj.BackgroundColor3 = theme.IconBtnInactive
					obj.BackgroundTransparency = theme.IconBtnInactiveTransparency
				end
			elseif data.Role == "Text" then
				obj.TextColor3 = theme.TextColor
			elseif data.Role == "TextDim" then
				obj.TextColor3 = theme.TextDimColor
			elseif data.Role == "Stroke" then
				obj.Color = theme.StrokeColor
				obj.Transparency = theme.StrokeTransparency
			elseif data.Role == "SelectionBg" then
				obj.BackgroundColor3 = theme.SelectionColor
				obj.BackgroundTransparency = theme.SelectionTransparency
			elseif data.Role == "SearchBg" then
				obj.BackgroundColor3 = theme.SearchBg
				obj.BackgroundTransparency = theme.SearchBgTransparency
			elseif data.Role == "DropdownBg" then
				obj.BackgroundColor3 = theme.DropdownBg
			end
		end
	end
end

-- ====================== CONFIG SYSTEM ======================
local SaveThread = nil

local function GetConfigFileName(profile)
	return "MacLib_" .. (profile or MacLib.CurrentProfile) .. ".json"
end

local function SaveConfig(force)
	if not Config.AutoSave or not writefile then return end
	if SaveThread then
		pcall(function() task.cancel(SaveThread) end)
		SaveThread = nil
	end
	local function doSave()
		pcall(function()
			writefile(GetConfigFileName(), game:GetService("HttpService"):JSONEncode(MacLib.ConfigData))
		end)
	end
	if force then
		doSave()
	else
		SaveThread = task.delay(2, function()
			SaveThread = nil
			doSave()
		end)
	end
end

local function LoadConfig(profile)
	if not readfile then return {} end
	local ok, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(readfile(GetConfigFileName(profile)))
	end)
	if ok and type(data) == "table" then
		return data
	end
	return {}
end

local function GetConfigValue(id, default, profile)
	local cfg = LoadConfig(profile)
	if cfg[id] ~= nil then return cfg[id] end
	return default
end

local function SetConfigValue(id, value)
	MacLib.ConfigData[id] = value
	SaveConfig()
end

-- ====================== VERSION CHECK ======================
MacLib.ConfigData = LoadConfig(MacLib.CurrentProfile) or {}

function MacLib:CheckVersion(url)
	url = url or ""
	local ok, res = pcall(function()
		return game:HttpGet(url)
	end)
	if ok then
		local remoteVersion = res:match("%d+%.%d+%.%d+") or res:gsub("%s+", "")
		if remoteVersion and remoteVersion ~= "" then
			if remoteVersion ~= self.Version then
				self:Notify({
					Title = "Update Available",
					Message = "Current: " .. self.Version .. " | Latest: " .. remoteVersion,
					Type = "info",
					Duration = 6
				})
			else
				self:Notify({
					Title = "Version Check",
					Message = "You are on the latest version (" .. self.Version .. ")",
					Type = "success",
					Duration = 3
				})
			end
		else
			self:Notify({
				Title = "Version Check",
				Message = "Invalid version format received.",
				Type = "error",
				Duration = 3
			})
		end
	else
		self:Notify({
			Title = "Version Check",
			Message = "Failed to fetch version info.",
			Type = "error",
			Duration = 3
		})
	end
end

-- ====================== TOOLTIP SYSTEM ======================
local TooltipGui, TooltipFrame, TooltipText, TooltipInitialized

local function InitTooltip()
	if TooltipInitialized then return end
	local existing = CoreGui:FindFirstChild("MacLibTooltip")
	if existing then
		TooltipGui = existing
		TooltipFrame = TooltipGui:FindFirstChild("TooltipFrame")
		TooltipText = TooltipFrame and TooltipFrame:FindFirstChild("TooltipText")
		TooltipInitialized = true
		return
	end
	TooltipInitialized = true
	TooltipGui = Instance.new("ScreenGui")
	TooltipGui.Name = "MacLibTooltip"
	TooltipGui.ResetOnSpawn = false
	TooltipGui.DisplayOrder = 2147483647
	TooltipGui.Parent = CoreGui
	MacLib.TooltipGui = TooltipGui

	TooltipFrame = Instance.new("Frame")
	TooltipFrame.BackgroundColor3 = CurrentTheme.DropdownBg
	TooltipFrame.BackgroundTransparency = 0.02
	TooltipFrame.BorderSizePixel = 0
	TooltipFrame.Size = UDim2.fromOffset(200, 30)
	TooltipFrame.Visible = false
	TooltipFrame.ZIndex = 10000
	Instance.new("UICorner", TooltipFrame).CornerRadius = UDim.new(0, 6)
	local tStroke = Instance.new("UIStroke", TooltipFrame)
	tStroke.Color = CurrentTheme.StrokeColor
	tStroke.Transparency = 0.3
	tStroke.Thickness = 1

	TooltipText = Instance.new("TextLabel", TooltipFrame)
	TooltipText.FontFace = Font.new(Config.Font)
	TooltipText.TextColor3 = CurrentTheme.TextColor
	TooltipText.TextSize = 11
	TooltipText.BackgroundTransparency = 1
	TooltipText.Size = UDim2.new(1, -12, 1, -8)
	TooltipText.Position = UDim2.new(0, 6, 0, 4)
	TooltipText.TextXAlignment = Enum.TextXAlignment.Left
	TooltipText.TextYAlignment = Enum.TextYAlignment.Top
	TooltipText.TextWrapped = true
	TooltipText.ZIndex = 10001
end

local function AttachTooltip(targetInstance, text)
	if not text or text == "" then return end
	InitTooltip()
	local delayThread
	local function show()
		delayThread = task.delay(0.5, function()
			if targetInstance and targetInstance.Parent then
				TooltipText.Text = text
				local size = GetTextSizeSafe(text, 11, 280)
				TooltipFrame.Size = UDim2.fromOffset(math.clamp(size.X + 16, 40, 300), math.clamp(size.Y + 10, 22, 400))
				TooltipFrame.Visible = true
				local mousePos = UserInputService:GetMouseLocation()
				TooltipFrame.Position = UDim2.fromOffset(mousePos.X + 16, mousePos.Y + 16)
			end
		end)
	end
	local function hide()
		if delayThread then
			pcall(function() task.cancel(delayThread) end)
			delayThread = nil
		end
		TooltipFrame.Visible = false
	end
	targetInstance.MouseEnter:Connect(show)
	targetInstance.MouseLeave:Connect(hide)
	targetInstance.MouseMoved:Connect(function()
		if TooltipFrame.Visible then
			local mousePos = UserInputService:GetMouseLocation()
			TooltipFrame.Position = UDim2.fromOffset(mousePos.X + 16, mousePos.Y + 16)
		end
	end)
end

-- ====================== NOTIFICATION SYSTEM ======================
local NotifGui, NotifContainer

local function InitNotifications()
	local existing = CoreGui:FindFirstChild("MacLibNotifications")
	if existing then
		NotifGui = existing
		NotifContainer = NotifGui:FindFirstChild("NotifContainer")
		return
	end
	NotifGui = Instance.new("ScreenGui")
	NotifGui.Name = "MacLibNotifications"
	NotifGui.ResetOnSpawn = false
	NotifGui.DisplayOrder = 2147483646
	NotifGui.Parent = CoreGui
	MacLib.NotifGui = NotifGui

	NotifContainer = Instance.new("Frame")
	NotifContainer.BackgroundTransparency = 1
	NotifContainer.Size = UDim2.new(0, 260, 1, -20)
	NotifContainer.Position = UDim2.new(1, -270, 0, 10)
	NotifContainer.Parent = NotifGui
end

function MacLib:Notify(data)
	data = data or {}
	if not NotifContainer then InitNotifications() end

	local notifHeight = data.Buttons and #data.Buttons > 0 and 90 or 60
	local notifBase, notifCard = MakeGlass(250, notifHeight)
	notifBase.Position = UDim2.new(1, 20, 0, 0)
	notifBase.Size = UDim2.fromOffset(250, notifHeight)
	notifBase.Parent = NotifContainer

	local accent = Instance.new("Frame", notifCard)
	accent.Size = UDim2.new(0, 3, 1, 0)
	accent.Position = UDim2.new(0, 0, 0, 0)
	accent.BackgroundColor3 = data.Type == "success" and CurrentTheme.NotificationSuccess
		or data.Type == "error" and CurrentTheme.NotificationError
		or CurrentTheme.NotificationInfo
	accent.BorderSizePixel = 0
	accent.ZIndex = 5
	Instance.new("UICorner", accent).CornerRadius = UDim.new(0, Config.CardCorner)

	local title = Instance.new("TextLabel", notifCard)
	title.Text = data.Title or "Notification"
	title.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
	title.TextColor3 = CurrentTheme.TextColor
	title.TextSize = 13
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 12, 0, 8)
	title.Size = UDim2.new(1, -20, 0, 18)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 5

	local msg = Instance.new("TextLabel", notifCard)
	msg.Text = data.Message or ""
	msg.FontFace = Font.new(Config.Font)
	msg.TextColor3 = CurrentTheme.TextDimColor
	msg.TextSize = 11
	msg.BackgroundTransparency = 1
	msg.Position = UDim2.new(0, 12, 0, 26)
	msg.Size = UDim2.new(1, -20, 0, data.Buttons and 28 or 28)
	msg.TextXAlignment = Enum.TextXAlignment.Left
	msg.TextYAlignment = Enum.TextYAlignment.Top
	msg.TextWrapped = true
	msg.ZIndex = 5

	if data.Buttons and #data.Buttons > 0 then
		local btnRow = Instance.new("Frame", notifCard)
		btnRow.Size = UDim2.new(1, -20, 0, 24)
		btnRow.Position = UDim2.new(0, 10, 1, -30)
		btnRow.BackgroundTransparency = 1
		btnRow.ZIndex = 5

		local btnLayout = Instance.new("UIListLayout", btnRow)
		btnLayout.FillDirection = Enum.FillDirection.Horizontal
		btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		btnLayout.Padding = UDim.new(0, 6)

		for _, btnData in ipairs(data.Buttons) do
			local b = Instance.new("TextButton", btnRow)
			b.Text = btnData[1] or "OK"
			b.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
			b.TextColor3 = CurrentTheme.TextColor
			b.TextSize = 11
			b.BackgroundTransparency = 0.85
			b.BackgroundColor3 = CurrentTheme.ToggleOn
			b.Size = UDim2.fromOffset(50, 22)
			b.AutoButtonColor = false
			b.ZIndex = 6
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

			b.MouseButton1Click:Connect(function(x, y)
				CreateRipple(b, x, y)
				PlaySound("Click")
				if btnData[2] then
					pcall(btnData[2])
				end
				Tween(notifBase, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 20, 0, 0)})
				task.wait(0.4)
				notifBase:Destroy()
			end)
		end
	end

	local progressBar
	if not data.Buttons or #data.Buttons == 0 then
		progressBar = Instance.new("Frame", notifCard)
		progressBar.Name = "ProgressBar"
		progressBar.Size = UDim2.new(1, 0, 0, 2)
		progressBar.Position = UDim2.new(0, 0, 1, -2)
		progressBar.BackgroundColor3 = accent.BackgroundColor3
		progressBar.BorderSizePixel = 0
		progressBar.ZIndex = 6
	end

	Tween(notifBase, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 0, 0, 0)})

	local duration = data.Duration or 3
	if not data.Buttons or #data.Buttons == 0 then
		Tween(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)})
		task.delay(duration, function()
			Tween(notifBase, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 20, 0, 0)})
			task.wait(0.4)
			notifBase:Destroy()
		end)
	end
end function MacLib:LoadingScreen(data)
	data = data or {}
	local gui = Instance.new("ScreenGui")
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 2147483647
	gui.Parent = gethui and gethui() or CoreGui

	local blur = Instance.new("Frame")
	blur.Size = UDim2.new(1,0,1,0)
	blur.BackgroundColor3 = Color3.new(0,0,0)
	blur.BackgroundTransparency = 0.2
	blur.ZIndex = 100
	blur.Parent = gui

	local base, card = MakeGlass(320, 160)
	base.Position = UDim2.fromScale(0.5,0.5)
	base.AnchorPoint = Vector2.new(0.5,0.5)
	base.ZIndex = 101
	base.Parent = gui

	local title = Instance.new("TextLabel", card)
	title.Text = data.Title or "Loading"
	title.FontFace = Font.new(Config.Font, Enum.FontWeight.Bold)
	title.TextColor3 = CurrentTheme.TextColor
	title.TextSize = 20
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1,0,0,30)
	title.Position = UDim2.new(0,0,0,20)
	title.ZIndex = 102

	local subtitle = Instance.new("TextLabel", card)
	subtitle.Text = data.Subtitle or "Please wait..."
	subtitle.FontFace = Font.new(Config.Font)
	subtitle.TextColor3 = CurrentTheme.TextDimColor
	subtitle.TextSize = 13
	subtitle.BackgroundTransparency = 1
	subtitle.Size = UDim2.new(1,0,0,20)
	subtitle.Position = UDim2.new(0,0,0,52)
	subtitle.ZIndex = 102

	local spinner = Instance.new("Frame", card)
	spinner.Size = UDim2.fromOffset(40, 40)
	spinner.Position = UDim2.new(0.5, -20, 0, 85)
	spinner.BackgroundTransparency = 1
	spinner.ZIndex = 102

	local circle = Instance.new("Frame", spinner)
	circle.Size = UDim2.fromOffset(32, 32)
	circle.Position = UDim2.fromOffset(4, 4)
	circle.BackgroundTransparency = 1
	circle.ZIndex = 102
	Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
	local stroke = Instance.new("UIStroke", circle)
	stroke.Color = CurrentTheme.ToggleOn
	stroke.Thickness = 3
	stroke.ZIndex = 103

	Tween(spinner, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})

	local duration = data.Duration or 3
	task.delay(duration, function()
		Tween(base, TweenInfo.new(0.3), {Size = UDim2.fromOffset(320, 0)})
		Tween(blur, TweenInfo.new(0.3), {BackgroundTransparency = 1})
		task.wait(0.3)
		gui:Destroy()
		if data.Callback then
			pcall(data.Callback)
		end
	end)

	return gui
end

-- ====================== GLOBAL UI TOGGLE ======================
function MacLib:BindToggle(keyName)
	self.ToggleKey = keyName or "Insert"
	local uiVisible = true

	local function toggleUI()
		uiVisible = not uiVisible
		self._UIVisible = uiVisible
		if self.ActiveGui then
			self.ActiveGui.Enabled = uiVisible
		end
		if self.MobileToggle then
			self.MobileToggle.Enabled = not uiVisible
		end
	end

	local keyEnum = Enum.KeyCode[self.ToggleKey]
	if keyEnum then
		UserInputService.InputBegan:Connect(function(inp, gpe)
			if not gpe and inp.KeyCode == keyEnum then
				toggleUI()
			end
		end)
	end

	if IsMobile and not self.MobileToggle then
		local mobGui = Instance.new("ScreenGui")
		mobGui.ResetOnSpawn = false
		mobGui.DisplayOrder = 2147483646
		mobGui.Enabled = false
		mobGui.Parent = gethui and gethui() or CoreGui

		local btn = Instance.new("ImageButton")
		btn.Size = UDim2.fromOffset(32, 32)
		btn.Position = UDim2.new(1, -70, 1, -90)
		btn.BackgroundColor3 = CurrentTheme.ToggleOn
		btn.Image = ResolveIcon("menu")
		btn.ImageColor3 = Color3.new(1,1,1)
		btn.ImageTransparency = 0.2
		btn.BackgroundTransparency = 0.2
		btn.ZIndex = 1000
		Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
		local btnStroke = Instance.new("UIStroke", btn)
		btnStroke.Color = Color3.new(1,1,1)
		btnStroke.Transparency = 0.5
		btnStroke.Thickness = 2
		btn.Parent = mobGui

		local md, ms, mp
		btn.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				md = true
				ms = inp.Position
				mp = btn.Position
			end
		end)
		btn.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
				md = false
			end
		end)
		UserInputService.InputChanged:Connect(function(inp)
			if md and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
				local d = inp.Position - ms
				btn.Position = UDim2.new(mp.X.Scale, mp.X.Offset + d.X, mp.Y.Scale, mp.Y.Offset + d.Y)
			end
		end)

		btn.MouseButton1Click:Connect(function()
			PlaySound("Click")
			toggleUI()
		end)

		self.MobileToggle = mobGui
	end
end

-- ====================== KEY SYSTEM ======================
function MacLib:VerifyKey(settings)
	settings = settings or {}
	if not settings.Enabled then return self:Window({Title = settings.Title or "Dashboard"}) end

	local savedKey = ""
	if settings.SaveKey and readfile then
		pcall(function() savedKey = readfile(settings.FileName or "MacLib_Key.txt") end)
	end

	local gui = Instance.new("ScreenGui")
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 2147483647
	gui.Parent = gethui and gethui() or CoreGui

	local blur = Instance.new("Frame")
	blur.Size = UDim2.new(1,0,1,0)
	blur.BackgroundColor3 = Color3.new(0,0,0)
	blur.BackgroundTransparency = 0.3
	blur.ZIndex = 100
	blur.Parent = gui

	local base, card = MakeGlass(300, 220)
	base.Position = UDim2.fromScale(0.5,0.5)
	base.AnchorPoint = Vector2.new(0.5,0.5)
	base.ZIndex = 101
	base.Parent = gui

	local title = Instance.new("TextLabel", card)
	title.Text = settings.Title or "Key System"
	title.FontFace = Font.new(Config.Font, Enum.FontWeight.Bold)
	title.TextColor3 = CurrentTheme.TextColor
	title.TextSize = 18
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1,0,0,30)
	title.Position = UDim2.new(0,0,0,15)
	title.ZIndex = 102

	local box = Instance.new("TextBox", card)
	box.Size = UDim2.new(1,-30,0,32)
	box.Position = UDim2.new(0.5,0,0,60)
	box.AnchorPoint = Vector2.new(0.5,0)
	box.BackgroundColor3 = CurrentTheme.SearchBg
	box.BackgroundTransparency = 0.5
	box.TextColor3 = CurrentTheme.TextColor
	box.PlaceholderText = "Enter Key..."
	box.Text = savedKey
	box.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
	box.TextSize = 13
	box.TextXAlignment = Enum.TextXAlignment.Center
	box.ClearTextOnFocus = false
	box.ZIndex = 102
	Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

	local status = Instance.new("TextLabel", card)
	status.Text = ""
	status.FontFace = Font.new(Config.Font)
	status.TextColor3 = CurrentTheme.NotificationError
	status.TextSize = 11
	status.BackgroundTransparency = 1
	status.Size = UDim2.new(1,0,0,16)
	status.Position = UDim2.new(0,0,0,98)
	status.ZIndex = 102

	local submit = Instance.new("TextButton", card)
	submit.Text = "Submit"
	submit.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
	submit.TextColor3 = Color3.new(1,1,1)
	submit.TextSize = 13
	submit.BackgroundColor3 = CurrentTheme.ToggleOn
	submit.Size = UDim2.new(0.45,0,0,32)
	submit.Position = UDim2.new(0.05,0,1,-48)
	submit.AutoButtonColor = false
	submit.ZIndex = 102
	Instance.new("UICorner", submit).CornerRadius = UDim.new(0,8)

	local getKey = Instance.new("TextButton", card)
	getKey.Text = "Get Key"
	getKey.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
	getKey.TextColor3 = CurrentTheme.TextColor
	getKey.TextSize = 13
	getKey.BackgroundColor3 = CurrentTheme.ButtonBg
	getKey.BackgroundTransparency = CurrentTheme.ButtonTransparency
	getKey.Size = UDim2.new(0.45,0,0,32)
	getKey.Position = UDim2.new(0.5,0,1,-48)
	getKey.AutoButtonColor = false
	getKey.ZIndex = 102
	Instance.new("UICorner", getKey).CornerRadius = UDim.new(0,8)
	local getStroke = Instance.new("UIStroke", getKey)
	getStroke.Color = CurrentTheme.StrokeColor
	getStroke.Transparency = 0.5

	getKey.MouseButton1Click:Connect(function(x, y)
		CreateRipple(getKey, x, y)
		PlaySound("Click")
		if settings.GetKeyLink then
			pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {
				Title = "Key System",
				Text = "Copied link to clipboard!",
				Duration = 3
			}) end)
			if setclipboard then setclipboard(settings.GetKeyLink) end
		end
	end)

	local function validate(key)
		if settings.Key and key == settings.Key then return true end
		if settings.Keys then
			for _, k in ipairs(settings.Keys) do
				if key == k then return true end
			end
		end
		if settings.ValidateURL then
			local ok, res = pcall(function()
				return game:HttpGet(settings.ValidateURL .. key)
			end)
			if ok and (res:find("true") or res:find("valid") or res:find("success")) then
				return true
			end
		end
		return false
	end

	local function success()
		if settings.SaveKey and writefile then
			pcall(function() writefile(settings.FileName or "MacLib_Key.txt", box.Text) end)
		end
		Tween(base, TweenInfo.new(0.3), {Size = UDim2.fromOffset(300,0)})
		Tween(blur, TweenInfo.new(0.3), {BackgroundTransparency = 1})
		task.wait(0.3)
		gui:Destroy()
		MacLib:Notify({Title = "Success", Message = "Key validated! Loading...", Type = "success", Duration = 2})
	end

	submit.MouseButton1Click:Connect(function(x, y)
		CreateRipple(submit, x, y)
		PlaySound("Click")
		if validate(box.Text) then
			success()
		else
			status.Text = "Invalid key!"
			Tween(box, TweenInfo.new(0.1), {BackgroundColor3 = CurrentTheme.NotificationError})
			task.wait(0.1)
			Tween(box, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.SearchBg})
		end
	end)

	if validate(savedKey) and savedKey ~= "" then
		success()
		return self:Window({Title = settings.WindowTitle or "Dashboard"})
	end

	local proxy = {}
	setmetatable(proxy, {
		__index = function(t, k)
			return function() 
				MacLib:Notify({Title = "Waiting", Message = "Please validate your key first.", Type = "error"})
			end
		end
	})

	local realSuccess = success
	success = function()
		realSuccess()
		local win = self:Window({Title = settings.WindowTitle or "Dashboard"})
		for k, v in pairs(win) do proxy[k] = v end
	end

	return proxy
end


--// MacLib Phase 7 - Part 3 of 4
--// Concatenate P1 -> P2 -> P3 -> P4 in order.

-- ====================== MAIN WINDOW ======================
function MacLib:Window(opts)
	opts = opts or {}
	local gui = Instance.new("ScreenGui")
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 2147483647
	gui.Parent = gethui and gethui() or CoreGui
	self.ActiveGui = gui

	if not MacLib.OverlayGui then
		local existing = CoreGui:FindFirstChild("MacLibOverlay")
		if existing then
			MacLib.OverlayGui = existing
		else
			local overlayGui = Instance.new("ScreenGui")
			overlayGui.Name = "MacLibOverlay"
			overlayGui.ResetOnSpawn = false
			overlayGui.DisplayOrder = 2147483645
			overlayGui.Parent = gethui and gethui() or CoreGui
			MacLib.OverlayGui = overlayGui
		end
	end

gui.AncestryChanged:Connect(function(_, parent)
    if parent == nil then
        SaveConfig(true)
        if MacLib.CursorConn then
            pcall(function() MacLib.CursorConn:Disconnect() end)
            MacLib.CursorConn = nil
        end
    end
end)

	local main = Instance.new("Frame")
	main.AnchorPoint = Vector2.new(0.5,0.5)
	main.Position = UDim2.fromScale(0.5,0.5)
	main.Size = Config.WindowSize
	main.BackgroundColor3 = CurrentTheme.WindowColor
	main.BackgroundTransparency = 1
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)
	table.insert(ThemeElements, {Object = main, Role = "Window"})
	main.Parent = gui

	local bgImage = Instance.new("ImageLabel")
	bgImage.Name = "BackgroundImage"
	bgImage.Size = UDim2.new(1, 0, 1, 0)
	bgImage.BackgroundTransparency = 1
	bgImage.Image = ""
	bgImage.ImageTransparency = 0.4
	bgImage.ScaleType = Enum.ScaleType.Crop
	bgImage.ZIndex = 0
	bgImage.Parent = main

	local cursorGui = Instance.new("ScreenGui")
	cursorGui.ResetOnSpawn = false
	cursorGui.DisplayOrder = 2147483647
	cursorGui.Parent = gethui and gethui() or CoreGui

	local customCursor = Instance.new("ImageLabel")
	customCursor.Name = "CustomCursor"
	customCursor.Size = UDim2.fromOffset(24, 24)
	customCursor.BackgroundTransparency = 1
	customCursor.Image = ""
	customCursor.ZIndex = 2147483647
	customCursor.Visible = false
	customCursor.Parent = cursorGui

	MacLib.CursorConn = nil

	local function UpdateCursor()
		if customCursor.Image == "" or not MacLib.CustomCursorEnabled then
			customCursor.Visible = false
			return
		end
		local mousePos = UserInputService:GetMouseLocation()
		customCursor.Position = UDim2.fromOffset(mousePos.X - 12, mousePos.Y - 12)
		local absPos = main.AbsolutePosition
		local absSize = main.AbsoluteSize
		local inside = mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
			and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y
		customCursor.Visible = inside
	end

	local function ManageCursorConnection()
		if MacLib.CustomCursorEnabled and customCursor.Image ~= "" then
			if not MacLib.CursorConn then
				MacLib.CursorConn = RunService.RenderStepped:Connect(UpdateCursor)
			end
		else
			if MacLib.CursorConn then
				MacLib.CursorConn:Disconnect()
				MacLib.CursorConn = nil
			end
			customCursor.Visible = false
		end
	end


	local blurSystem = BlurSystem:New(main)
	local blurEnabled = GetConfigValue("maclib_blur", Config.UseBlur)
	blurSystem:SetState(blurEnabled)

	local targetTransparency = blurEnabled and CurrentTheme.WindowTransparency or 0
	Tween(main, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {BackgroundTransparency = targetTransparency})

	pcall(function()
		local viewport = workspace.CurrentCamera.ViewportSize
		local minDim = math.min(viewport.X, viewport.Y)
		if minDim < 600 then
			local uiScale = Instance.new("UIScale")
			uiScale.Scale = math.clamp(minDim / 680, 0.55, 1)
			uiScale.Parent = main
		end
	end)

	local sidebar = Instance.new("Frame")
	sidebar.BackgroundColor3 = CurrentTheme.SidebarColor
	sidebar.BackgroundTransparency = CurrentTheme.SidebarTransparency
	sidebar.BorderSizePixel = 0
	sidebar.Size = UDim2.new(0, Config.SidebarWidth, 1, -16)
	sidebar.Position = UDim2.new(0,8,0,8)
	Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,14)
	table.insert(ThemeElements, {Object = sidebar, Role = "Sidebar"})
	sidebar.Parent = main

	local topIcons = Instance.new("Frame")
	topIcons.BackgroundTransparency = 1
	topIcons.Size = UDim2.new(1,0,1,-52)
	topIcons.Position = UDim2.new(0,0,0,4)
	local topList = Instance.new("UIListLayout")
	topList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	topList.SortOrder = Enum.SortOrder.LayoutOrder
	topList.Padding = UDim.new(0, Config.IconSpacing)
	topList.Parent = topIcons
	topIcons.Parent = sidebar

	local bottom = Instance.new("Frame")
	bottom.BackgroundTransparency = 1
	bottom.Size = UDim2.new(1,0,0,44)
	bottom.Position = UDim2.new(0,0,1,-46)
	bottom.Parent = sidebar
	local bottomLayout = Instance.new("UIListLayout")
	bottomLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	bottomLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	bottomLayout.Parent = bottom

	local content = Instance.new("Frame")
	content.BackgroundTransparency = 1
	content.Position = UDim2.new(0, Config.SidebarWidth+12, 0, 8)
	content.Size = UDim2.new(1, -(Config.SidebarWidth+20), 1, -16)
	content.Parent = main

	local topbar = Instance.new("Frame")
	topbar.BackgroundTransparency = 1
	topbar.Size = UDim2.new(1,0,0,Config.TopbarHeight)
	topbar.Parent = content

	local subArea = Instance.new("Frame")
	subArea.BackgroundTransparency = 1
	subArea.Size = UDim2.new(1,-180,1,0)
	local subLayout = Instance.new("UIListLayout")
	subLayout.FillDirection = Enum.FillDirection.Horizontal
	subLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	subLayout.Padding = UDim.new(0,20)
	subLayout.Parent = subArea
	subArea.Parent = topbar

	local rightArea = Instance.new("Frame")
	rightArea.BackgroundTransparency = 1
	rightArea.AnchorPoint = Vector2.new(1,0.5)
	rightArea.Position = UDim2.new(1,-4,0.5,0)
	rightArea.Size = UDim2.new(0,170,1,0)
	local rightLayout = Instance.new("UIListLayout")
	rightLayout.FillDirection = Enum.FillDirection.Horizontal
	rightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	rightLayout.Padding = UDim.new(0,6)
	rightLayout.Parent = rightArea
	rightArea.Parent = topbar

	local search = Instance.new("Frame")
	search.Size = UDim2.fromOffset(90,26)
	search.BackgroundColor3 = CurrentTheme.SearchBg
	search.BackgroundTransparency = CurrentTheme.SearchBgTransparency
	search.BorderSizePixel = 0
	Instance.new("UICorner", search).CornerRadius = UDim.new(0,13)
	table.insert(ThemeElements, {Object = search, Role = "SearchBg"})
	local sIcon = Instance.new("ImageLabel", search)
	sIcon.Image = ResolveIcon(Icons.search)
	sIcon.ImageTransparency = 0.5
	sIcon.BackgroundTransparency = 1
	sIcon.Size = UDim2.fromOffset(11,11)
	sIcon.Position = UDim2.new(0,7,0.5,-5)

	local searchBox = Instance.new("TextBox", search)
	searchBox.Size = UDim2.new(1,-24,1,0)
	searchBox.Position = UDim2.new(0,22,0,0)
	searchBox.BackgroundTransparency = 1
	searchBox.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
	searchBox.TextColor3 = CurrentTheme.TextColor
	searchBox.TextSize = 11
	searchBox.TextTransparency = 0.4
	searchBox.Text = "Search"
	searchBox.ClearTextOnFocus = false
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.TextTruncate = Enum.TextTruncate.AtEnd
	table.insert(ThemeElements, {Object = searchBox, Role = "Text"})
	searchBox.Focused:Connect(function()
		if searchBox.Text == "Search" then searchBox.Text = "" end
	end)
	searchBox.FocusLost:Connect(function(enter)
		if searchBox.Text == "" then searchBox.Text = "Search" end
	end)
	search.Parent = rightArea

	local fileBtn = Instance.new("ImageButton", rightArea)
	fileBtn.Size = UDim2.fromOffset(20,20)
	fileBtn.BackgroundTransparency = 1
	fileBtn.Image = ResolveIcon(Icons.file)
	fileBtn.ImageTransparency = 0.4
	fileBtn.AutoButtonColor = false

	local av = Instance.new("ImageLabel", rightArea)
	av.Size = UDim2.fromOffset(24,24)
	av.BackgroundTransparency = 1
	Instance.new("UICorner", av).CornerRadius = UDim.new(1,0)
	local ok, img = pcall(function()
		return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size48x48)
	end)
	av.Image = ok and img or ""

	local contentFrame = Instance.new("Frame")
	contentFrame.BackgroundTransparency = 1
	contentFrame.Position = UDim2.new(0,0,0,Config.TopbarHeight+4)
	contentFrame.Size = UDim2.new(1,0,1,-(Config.TopbarHeight+4))
	contentFrame.Parent = content

	-- Resize Handle
	local resizeHandle = Instance.new("TextButton")
	resizeHandle.Name = "ResizeHandle"
	resizeHandle.Size = UDim2.fromOffset(16, 16)
	resizeHandle.Position = UDim2.new(1, -16, 1, -16)
	resizeHandle.BackgroundColor3 = CurrentTheme.ToggleOn
	resizeHandle.BackgroundTransparency = 0.5
	resizeHandle.Text = ""
	resizeHandle.AutoButtonColor = false
	resizeHandle.ZIndex = 50
	Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0, 4)
	resizeHandle.Parent = main

	local resizing = false
	local startSize, startMousePos
	resizeHandle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			startSize = main.Size
			startMousePos = inp.Position
		end
	end)
	resizeHandle.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			resizing = false
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if resizing and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local delta = inp.Position - startMousePos
			local minW = opts.MinSize and opts.MinSize.X or Config.MinWindowSize.X
			local minH = opts.MinSize and opts.MinSize.Y or Config.MinWindowSize.Y
			local maxW = opts.MaxSize and opts.MaxSize.X or Config.MaxWindowSize.X
			local maxH = opts.MaxSize and opts.MaxSize.Y or Config.MaxWindowSize.Y
			local newW = math.clamp(startSize.X.Offset + delta.X, minW, maxW)
			local newH = math.clamp(startSize.Y.Offset + delta.Y, minH, maxH)
			main.Size = UDim2.fromOffset(newW, newH)
			Config.WindowSize = main.Size
		end
	end)

	-- ====================== VIRTUAL KEYBOARD HANDLING ======================
	local originalPosition = main.Position
	local keyboardOffset = 0
	if IsMobile then
		UserInputService.TextBoxFocused:Connect(function(textbox)
			local viewport = workspace.CurrentCamera.ViewportSize
			local kbHeight = viewport.Y * 0.42
			local textboxBottom = textbox.AbsolutePosition.Y + textbox.AbsoluteSize.Y
			local overlap = textboxBottom - (viewport.Y - kbHeight) + 20
			if overlap > 0 then
				keyboardOffset = overlap
				Tween(main, TweenInfo.new(0.3), {
					Position = UDim2.new(
						originalPosition.X.Scale, originalPosition.X.Offset,
						originalPosition.Y.Scale, originalPosition.Y.Offset - keyboardOffset
					)
				})
			end
		end)
		UserInputService.TextBoxFocusReleased:Connect(function()
			if keyboardOffset > 0 then
				Tween(main, TweenInfo.new(0.3), {Position = originalPosition})
				keyboardOffset = 0
			end
		end)
	end

	local currentTab = nil
	local WindowFunctions = {}

	function WindowFunctions:Notify(data)
		MacLib:Notify(data)
	end

	function WindowFunctions:SaveConfig()
		SaveConfig(true)
	end

	function WindowFunctions:LoadConfig()
		return LoadConfig()
	end

	function WindowFunctions:LoadProfile(profileName)
		if not profileName or profileName == "" then return end
		SaveConfig(true)
		MacLib.CurrentProfile = profileName
		MacLib.ConfigData = LoadConfig(profileName)
		for flag, element in pairs(MacLib.Elements) do
			if element.Set and MacLib.ConfigData[flag] ~= nil then
				pcall(function() element:Set(MacLib.ConfigData[flag]) end)
			end
		end
		self:Notify({
			Title = "Profile Loaded",
			Message = "Switched to profile: " .. profileName,
			Type = "success",
			Duration = 3
		})
		print("[MacLib] Loaded profile:", profileName)
	end

	function WindowFunctions:SaveProfile(profileName)
		if not profileName or profileName == "" then return end
		local oldProfile = MacLib.CurrentProfile
		MacLib.CurrentProfile = profileName
		SaveConfig(true)
		MacLib.CurrentProfile = oldProfile
		self:Notify({
			Title = "Profile Saved",
			Message = "Saved current config to: " .. profileName,
			Type = "success",
			Duration = 3
		})
		print("[MacLib] Saved profile:", profileName)
	end

	function WindowFunctions:GetProfiles()
		local profiles = {}
		if not listfiles then return profiles end
		local ok, files = pcall(listfiles, "")
		if not ok then return profiles end
		for _, file in ipairs(files) do
			local name = file:match("MacLib_(%w+)%.json$")
			if name then
				table.insert(profiles, name)
			end
		end
		return profiles
	end

	function WindowFunctions:DeleteProfile(profileName)
		if not profileName or profileName == MacLib.CurrentProfile then
			self:Notify({Title = "Error", Message = "Cannot delete active profile.", Type = "error"})
			return
		end
		if delfile then
			pcall(function() delfile(GetConfigFileName(profileName)) end)
		end
		self:Notify({
			Title = "Profile Deleted",
			Message = "Removed profile: " .. profileName,
			Type = "info",
			Duration = 3
		})
	end

	function WindowFunctions:ExportConfig()
		local json = game:GetService("HttpService"):JSONEncode(MacLib.ConfigData)
		if setclipboard then
			setclipboard(json)
			self:Notify({
				Title = "Config Exported",
				Message = "JSON copied to clipboard!",
				Type = "success",
				Duration = 3
			})
		else
			self:Notify({
				Title = "Export Failed",
				Message = "setclipboard not available.",
				Type = "error",
				Duration = 3
			})
		end
		return json
	end

	function WindowFunctions:ImportConfig(jsonString)
		local ok, data = pcall(function()
			return game:GetService("HttpService"):JSONDecode(jsonString)
		end)
		if not ok or type(data) ~= "table" then
			self:Notify({
				Title = "Import Failed",
				Message = "Invalid JSON format.",
				Type = "error",
				Duration = 3
			})
			return false
		end
		MacLib.ConfigData = data
		SaveConfig(true)
		for flag, value in pairs(MacLib.ConfigData) do
			local element = MacLib.Elements[flag]
			if element and element.Set then
				pcall(function() element:Set(value) end)
			end
		end
		self:Notify({
			Title = "Config Imported",
			Message = "Settings applied from clipboard.",
			Type = "success",
			Duration = 3
		})
		return true
	end

	function WindowFunctions:ResetConfig()
		if SaveThread then
			pcall(function() task.cancel(SaveThread) end)
			SaveThread = nil
		end
		for flag, element in pairs(MacLib.Elements) do
			if element.Default ~= nil and element.Set then
				pcall(function() element:Set(element.Default) end)
			end
		end
		MacLib.ConfigData = {}
		if delfile then
			pcall(function() delfile(GetConfigFileName()) end)
		end
		SaveConfig(true)
		self:Notify({
			Title = "Config Reset",
			Message = "All settings restored to defaults.",
			Type = "info",
			Duration = 3
		})
		print("[MacLib] Config reset for profile:", MacLib.CurrentProfile)
	end

	function WindowFunctions:SetBlur(enabled)
		blurSystem:SetState(enabled)
		SetConfigValue("maclib_blur", enabled)
		local newTrans = enabled and CurrentTheme.WindowTransparency or 0
		Tween(main, TweenInfo.new(0.3), {BackgroundTransparency = newTrans})
		print("[MacLib] Blur set to:", enabled, "| Window transparency:", newTrans)
	end

	function WindowFunctions:SetTheme(themeName)
		local theme = MacLib.Themes[themeName]
		if not theme then
			warn("[MacLib] Theme '" .. tostring(themeName) .. "' not found.")
			return
		end
		ApplyTheme(theme)
		SetConfigValue("maclib_theme", themeName)
		print("[MacLib] Theme switched to:", themeName)
	end

	function WindowFunctions:SetTransparency(alpha)
		alpha = math.clamp(alpha, 0, 1)
		local baseTrans = CurrentTheme.WindowTransparency
		local newTrans = blurEnabled and (baseTrans + alpha * (1 - baseTrans)) or alpha
		main.BackgroundTransparency = newTrans
		print("[MacLib] Window transparency set to:", newTrans)
	end

	function WindowFunctions:SetBlurIntensity(intensity)
		intensity = math.clamp(intensity, 0, 1)
		blurSystem:SetIntensity(intensity)
		print("[MacLib] Blur intensity set to:", intensity)
	end

	local function UpdateSearch(query)
		query = query:lower()
		if query == "search" then query = "" end
		local activeQuery = query ~= "" and query or nil

		local page = currentTab and currentTab.page
		if not page then return end

		local containers = {}
		local hasSubpages = false
		for _, child in ipairs(page:GetChildren()) do
			if child:IsA("Frame") and child:GetAttribute("IsSubpage") and child.Visible then
				hasSubpages = true
				table.insert(containers, child)
			end
		end
		if not hasSubpages then
			table.insert(containers, page)
		end

		for _, container in ipairs(containers) do
			for _, col in ipairs(container:GetChildren()) do
				if col:IsA("Frame") and col:GetAttribute("IsColumn") then
					local colHasVisible = false
					for _, card in ipairs(col:GetChildren()) do
						if card:IsA("Frame") and card:GetAttribute("IsCard") then
							if not activeQuery then
								card.Visible = true
								colHasVisible = true
							else
								local tags = card:GetAttribute("SearchTags") or ""
								if tags:find(activeQuery, 1, true) then
									card.Visible = true
									colHasVisible = true
								else
									card.Visible = false
								end
							end
						end
					end
					col.Visible = colHasVisible
				end
			end
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local query = searchBox.Text
		if query == "Search" then query = "" end
		UpdateSearch(query)
	end)


--// MacLib Phase 7 - Part 4 of 4
--// Concatenate P1 -> P2 -> P3 -> P4 in order.

	function WindowFunctions:Tab(settings)
		local slot = Instance.new("Frame")
		slot.BackgroundTransparency = 1
		slot.Size = UDim2.fromOffset(40,40)
		slot.LayoutOrder = settings.LayoutOrder or 1
		if settings.IsPower then
			slot.Parent = bottom
		else
			slot.Parent = topIcons
		end

		local selectBg = Instance.new("Frame")
		selectBg.BackgroundColor3 = CurrentTheme.SelectionColor
		selectBg.BackgroundTransparency = 1
		selectBg.BorderSizePixel = 0
		selectBg.Size = UDim2.fromOffset(40,40)
		selectBg.Position = UDim2.fromScale(0.5,0.5)
		selectBg.AnchorPoint = Vector2.new(0.5,0.5)
		Instance.new("UICorner", selectBg).CornerRadius = UDim.new(0,10)
		table.insert(ThemeElements, {Object = selectBg, Role = "SelectionBg"})
		selectBg.Parent = slot

		local btn = Instance.new("ImageButton")
		btn.Image = ResolveIcon(settings.Icon) or ""
		btn.ImageTransparency = 0.5
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.fromOffset(Config.IconSize, Config.IconSize)
		btn.Position = UDim2.fromScale(0.5,0.5)
		btn.AnchorPoint = Vector2.new(0.5,0.5)
		btn.AutoButtonColor = false
		btn.Parent = slot

		local page = Instance.new("Frame")
		page.BackgroundTransparency = 1
		page.Size = UDim2.fromScale(1,1)
		page.Visible = false
		page.Parent = contentFrame

		local subtabData = {}
		local subtabButtons = {}
		local pageLayout = nil

		-- Mobile subtab dropdown
		local subtabDropdownBtn = nil
		local subtabDropdownFrame = nil
		local subtabDropdownList = nil
		local isMobileLayout = false

		local function checkMobile()
			return workspace.CurrentCamera.ViewportSize.X < 500
		end

		local function refreshSubtabVisibility()
			local anyVisible = false
			for _, sd in ipairs(subtabData) do
				if sd.page.Visible then anyVisible = true; break end
			end
			if not anyVisible and #subtabData > 0 then
				subtabData[1].page.Visible = true
				subtabData[1].btn.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
				subtabData[1].btn.TextTransparency = 0.1
			end
		end

		local function updateSubtabLayout()
			local mobile = checkMobile()
			if mobile == isMobileLayout then return end
			isMobileLayout = mobile

			if mobile then
				for _, stb in ipairs(subtabButtons) do
					stb.Visible = false
				end
				if not subtabDropdownBtn then
					subtabDropdownBtn = Instance.new("TextButton", subArea)
					subtabDropdownBtn.Size = UDim2.fromOffset(120, 32)
					subtabDropdownBtn.BackgroundColor3 = CurrentTheme.CardBackColor
					subtabDropdownBtn.BackgroundTransparency = 0.3
					subtabDropdownBtn.TextColor3 = CurrentTheme.TextColor
					subtabDropdownBtn.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
					subtabDropdownBtn.TextSize = 13
					subtabDropdownBtn.AutoButtonColor = false
					subtabDropdownBtn.Text = "Select..."
					subtabDropdownBtn.Visible = false
					Instance.new("UICorner", subtabDropdownBtn).CornerRadius = UDim.new(0, 8)

						subtabDropdownBtn.MouseButton1Click:Connect(function()
							subtabDropdownFrame.Visible = not subtabDropdownFrame.Visible
							if subtabDropdownFrame.Visible then
								buildSubtabDropdown()
							end
						end)

						subtabDropdownFrame = Instance.new("Frame", subArea)
						subtabDropdownFrame.BackgroundColor3 = CurrentTheme.DropdownBg
					subtabDropdownFrame.BackgroundTransparency = 0.02
					subtabDropdownFrame.BorderSizePixel = 0
					subtabDropdownFrame.Size = UDim2.fromOffset(140, 0)
					subtabDropdownFrame.Position = UDim2.fromOffset(0, 34)
					subtabDropdownFrame.Visible = false
					subtabDropdownFrame.ZIndex = 50
					Instance.new("UICorner", subtabDropdownFrame).CornerRadius = UDim.new(0, 8)
					local ddStroke = Instance.new("UIStroke", subtabDropdownFrame)
					ddStroke.Color = CurrentTheme.StrokeColor
					ddStroke.Transparency = 0.4

					subtabDropdownList = Instance.new("UIListLayout", subtabDropdownFrame)
					subtabDropdownList.Padding = UDim.new(0, 0)
				end
				subtabDropdownBtn.Visible = true
			else
				for _, stb in ipairs(subtabButtons) do
					stb.Visible = (currentTab and currentTab.page == page)
				end
				if subtabDropdownBtn then subtabDropdownBtn.Visible = false end
				if subtabDropdownFrame then subtabDropdownFrame.Visible = false end
			end
		end

		local function buildSubtabDropdown()
			if not subtabDropdownFrame then return end
			for _, child in ipairs(subtabDropdownFrame:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end
			for i, data in ipairs(subtabData) do
				local opt = Instance.new("TextButton", subtabDropdownFrame)
				opt.Size = UDim2.new(1, 0, 0, 30)
				opt.BackgroundTransparency = 1
				opt.Text = data.name
				opt.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
				opt.TextColor3 = CurrentTheme.TextColor
				opt.TextSize = 12
				opt.AutoButtonColor = false
				opt.ZIndex = 51

				opt.MouseEnter:Connect(function()
					opt.BackgroundTransparency = 0.85
					opt.BackgroundColor3 = CurrentTheme.SelectionColor
				end)
				opt.MouseLeave:Connect(function()
					opt.BackgroundTransparency = 1
				end)

				opt.MouseButton1Click:Connect(function()
					for _, sd in ipairs(subtabData) do
						sd.page.Visible = false
						sd.btn.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
						sd.btn.TextTransparency = 0.5
					end
					data.page.Visible = true
					data.btn.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
					data.btn.TextTransparency = 0.1
					subtabDropdownFrame.Visible = false
					subtabDropdownBtn.Text = data.name
					local query = searchBox.Text
					if query == "Search" then query = "" end
					UpdateSearch(query)
				end)
			end
			task.defer(function()
				local h = subtabDropdownList.AbsoluteContentSize.Y
				subtabDropdownFrame.Size = UDim2.fromOffset(140, h)
			end)
		end

		local function createSubtab(name)
			if #subtabData >= Config.MaxSubtabs then
				warn("[MacLib] Max " .. Config.MaxSubtabs .. " subtabs allowed.")
				return nil
			end
			if pageLayout then
				pageLayout:Destroy()
				pageLayout = nil
			end

			local txt = Instance.new("TextButton")
			txt.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
			txt.Text = name
			txt.TextColor3 = CurrentTheme.TextColor
			txt.TextSize = Config.SubtabFontSize
			txt.TextTransparency = 0.5
			txt.BackgroundTransparency = 1
			txt.Size = UDim2.fromOffset(65,24)
			txt.AutoButtonColor = false
			txt.Visible = false
			table.insert(ThemeElements, {Object = txt, Role = "Text"})
			txt.Parent = subArea
			table.insert(subtabButtons, txt)

			local subPage = Instance.new("Frame")
			subPage.BackgroundTransparency = 1
			subPage.Size = UDim2.fromScale(1,1)
			subPage.Visible = false
			subPage:SetAttribute("IsSubpage", true)
			subPage.Parent = page

			local subPageLayout = Instance.new("UIListLayout", subPage)
			subPageLayout.FillDirection = Enum.FillDirection.Horizontal
			subPageLayout.Wraps = true
			subPageLayout.Padding = UDim.new(0, Config.ColumnGap)
			subPageLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local data = {btn = txt, page = subPage, name = name}

			txt.MouseButton1Click:Connect(function()
				for _, sd in ipairs(subtabData) do
					sd.page.Visible = false
					sd.btn.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
					sd.btn.TextTransparency = 0.5
				end
				subPage.Visible = true
				txt.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
				txt.TextTransparency = 0.1
				local query = searchBox.Text
				if query == "Search" then query = "" end
				UpdateSearch(query)
			end)

			table.insert(subtabData, data)
			if currentTab and currentTab.page == page then
				txt.Visible = true
			end
			refreshSubtabVisibility()
			buildSubtabDropdown()
			return data
		end

		if settings.Subtabs then
			for _, name in ipairs(settings.Subtabs) do
				createSubtab(name)
			end
		else
			pageLayout = Instance.new("UIListLayout", page)
			pageLayout.FillDirection = Enum.FillDirection.Horizontal
			pageLayout.Wraps = true
			pageLayout.Padding = UDim.new(0, Config.ColumnGap)
			pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		end

		local function select()
			PlaySound("Click")
			if currentTab then
				currentTab.page.Visible = false
				currentTab.btn.ImageTransparency = 0.5
				Tween(currentTab.sel, TweenInfo.new(0.15), {BackgroundTransparency = 1})
				if currentTab.subtabButtons then
					for _, stb in ipairs(currentTab.subtabButtons) do
						stb.Visible = false
					end
				end
			end
			currentTab = {page = page, btn = btn, sel = selectBg, subtabButtons = subtabButtons}
			page.Visible = true
			btn.ImageTransparency = 0.1
			Tween(selectBg, TweenInfo.new(0.15), {BackgroundTransparency = CurrentTheme.SelectionTransparency})
			for _, stb in ipairs(subtabButtons) do
				stb.Visible = true
			end
			updateSubtabLayout()
			local query = searchBox.Text
			if query == "Search" then query = "" end
			UpdateSearch(query)
		end
		btn.MouseButton1Click:Connect(select)
	btn.MouseEnter:Connect(function() PlaySound("Hover") end)
		if not currentTab and not settings.IsPower then select() end

		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateSubtabLayout)

		local TabFunctions = {}

		function TabFunctions:AddSubtab(name)
			return createSubtab(name)
		end

		function TabFunctions:RemoveSubtab(identifier)
			local idx = nil
			if type(identifier) == "number" then
				idx = identifier
			else
				for i, data in ipairs(subtabData) do
					if data.name == identifier then idx = i; break end
				end
			end
			if not idx or not subtabData[idx] then return false end

			local data = subtabData[idx]
			local wasVisible = data.page.Visible

			if wasVisible then
				local switchTo = subtabData[idx + 1] or subtabData[idx - 1]
				if switchTo then
					for _, sd in ipairs(subtabData) do
						sd.page.Visible = false
						sd.btn.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
						sd.btn.TextTransparency = 0.5
					end
					switchTo.page.Visible = true
					switchTo.btn.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
					switchTo.btn.TextTransparency = 0.1
				end
			end

			data.btn:Destroy()
			data.page:Destroy()
			table.remove(subtabData, idx)
			table.remove(subtabButtons, idx)

			if #subtabData == 0 and not pageLayout then
				pageLayout = Instance.new("UIListLayout", page)
				pageLayout.FillDirection = Enum.FillDirection.Horizontal
				pageLayout.Wraps = true
				pageLayout.Padding = UDim.new(0, Config.ColumnGap)
				pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
			end
			buildSubtabDropdown()
			return true
		end

		function TabFunctions:GetSubtabs()
			local names = {}
			for _, data in ipairs(subtabData) do
				table.insert(names, data.name)
			end
			return names
		end

		function TabFunctions:Section(opts)
			opts = opts or {}
			local targetPage
			if #subtabData > 0 then
				local idx = opts.SubtabIndex or 1
				targetPage = subtabData[idx] and subtabData[idx].page or subtabData[1].page
			else
				targetPage = page
			end

			-- ScrollingFrame wrapper for column overflow handling
			local scrollFrame = Instance.new("ScrollingFrame")
			scrollFrame.BackgroundTransparency = 1
			scrollFrame.Size = UDim2.new(0, Config.ColumnWidth, 1, 0)
			scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scrollFrame.ScrollBarThickness = 2
			scrollFrame.ScrollBarImageColor3 = CurrentTheme.ToggleOn
			scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
			scrollFrame.BorderSizePixel = 0
			scrollFrame.Parent = targetPage

			local col = Instance.new("Frame")
			col.BackgroundTransparency = 1
			col.Size = UDim2.fromOffset(Config.ColumnWidth, 0)
			col:SetAttribute("IsColumn", true)
			col.Parent = scrollFrame
			local colList = Instance.new("UIListLayout", col)
			colList.Padding = UDim.new(0, Config.RowGap)
			colList.SortOrder = Enum.SortOrder.LayoutOrder

			local SectionFunctions = {}

			function SectionFunctions:AddHeader(text)
				local header = Instance.new("Frame")
				header.BackgroundTransparency = 1
				header.Size = UDim2.new(1, 0, 0, 22)
				local label = Instance.new("TextLabel", header)
				label.Text = text or "Header"
				label.FontFace = Font.new(Config.Font, Enum.FontWeight.Bold)
				label.TextColor3 = CurrentTheme.TextColor
				label.TextSize = 14
				label.TextTransparency = 0.1
				label.BackgroundTransparency = 1
				label.Size = UDim2.new(1, 0, 1, 0)
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.ZIndex = 10
				table.insert(ThemeElements, {Object = label, Role = "Text"})
				local line = Instance.new("Frame", header)
				line.BackgroundColor3 = CurrentTheme.StrokeColor
				line.BackgroundTransparency = 0.7
				line.BorderSizePixel = 0
				line.Size = UDim2.new(1, 0, 0, 1)
				line.Position = UDim2.new(0, 0, 1, -1)
				line.ZIndex = 10
				header.Parent = col
				
				local element = {
					Instance = header,
					Type = "Header",
					Destroy = function(self)
						CleanupThemeElements(label)
						if header then header:Destroy() end
					end
				}
				return element
			end

			function SectionFunctions:AddParagraph(data)
				data = data or {}
				local base, card = MakeGlass(Config.ColumnWidth, 0)
				local pad = Instance.new("UIPadding", card)
				pad.PaddingLeft = UDim.new(0, 10)
				pad.PaddingRight = UDim.new(0, 10)
				pad.PaddingTop = UDim.new(0, 10)
				pad.PaddingBottom = UDim.new(0, 10)

				local title = Instance.new("TextLabel", card)
				title.Text = data.Title or "Paragraph"
				title.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
				title.TextColor3 = data.TitleColor or CurrentTheme.TextColor
				title.TextSize = 13
				title.TextTransparency = 0.1
				title.BackgroundTransparency = 1
				title.Size = UDim2.new(1, 0, 0, 16)
				title.TextXAlignment = Enum.TextXAlignment.Left
				title.TextWrapped = true
				title.ZIndex = 10
				title.RichText = data.RichText or false
				table.insert(ThemeElements, {Object = title, Role = "Text"})

				local content = Instance.new("TextLabel", card)
				content.Text = data.Content or ""
				content.FontFace = Font.new(Config.Font)
				content.TextColor3 = CurrentTheme.TextDimColor
				content.TextSize = 11
				content.TextTransparency = 0.25
				content.BackgroundTransparency = 1
				content.Position = UDim2.new(0, 0, 0, 18)
				content.Size = UDim2.new(1, 0, 0, 0)
				content.TextXAlignment = Enum.TextXAlignment.Left
				content.TextYAlignment = Enum.TextYAlignment.Top
				content.TextWrapped = true
				content.ZIndex = 10
				content.RichText = data.RichText or false
				table.insert(ThemeElements, {Object = content, Role = "TextDim"})

				local function updateHeight()
					local textSize = GetTextSizeSafe(content.Text, 11, Config.ColumnWidth - 20)
					content.Size = UDim2.new(1, 0, 0, textSize.Y)
					base.Size = UDim2.fromOffset(Config.ColumnWidth, textSize.Y + 36)
				end
				updateHeight()

				base.Parent = col
				local element = {
					Value = data.Content,
					Type = "Paragraph",
					Instance = base,
					Set = function(self, newText)
						content.Text = newText
						self.Value = newText
						updateHeight()
					end,
						Destroy = function(self)
							CleanupThemeElements(title)
							CleanupThemeElements(content)
							ReturnFrame(base)
						end
				}
				if data.Tooltip then AttachTooltip(base, data.Tooltip) end
				return element
			end

			function SectionFunctions:AddBlank(height)
				local frame = Instance.new("Frame")
				frame.BackgroundTransparency = 1
				frame.Size = UDim2.new(1, 0, 0, height or 10)
				frame.Parent = col
				
				local element = {
					Instance = frame,
					Type = "Blank",
					Destroy = function(self)
						if frame then frame:Destroy() end
					end
				}
				return element
			end

			function SectionFunctions:AddImage(settings)
				settings = settings or {}
				local h = settings.Height or 120
				local base, card = MakeGlass(Config.ColumnWidth, h)
				local img = Instance.new("ImageLabel", card)
				img.Size = UDim2.new(1, 0, 1, 0)
				img.Image = settings.Image or ""
				img.BackgroundTransparency = 1
				img.ScaleType = settings.ScaleType or Enum.ScaleType.Crop
				local corner = Instance.new("UICorner", img)
				corner.CornerRadius = UDim.new(0, math.max(0, Config.CardCorner - 4))

				if settings.Overlay then
					local overlay = Instance.new("TextLabel", card)
					overlay.Text = settings.Overlay
					overlay.FontFace = Font.new(Config.Font, Enum.FontWeight.Bold)
					overlay.TextColor3 = Color3.new(1,1,1)
					overlay.TextSize = 14
					overlay.BackgroundTransparency = 1
					overlay.Size = UDim2.new(1, 0, 0, 24)
					overlay.Position = UDim2.new(0, 0, 1, -28)
					overlay.TextXAlignment = Enum.TextXAlignment.Left
					overlay.ZIndex = 5
					local pad = Instance.new("UIPadding", overlay)
					pad.PaddingLeft = UDim.new(0, 10)
					table.insert(ThemeElements, {Object = overlay, Role = "Text"})
				end

				base.Parent = col
				local element = {
					Instance = base,
					SetImage = function(self, url)
						img.Image = url
					end,
					Highlight = function(self)
						FlashHighlight(base)
					end,
						Destroy = function(self)
							CleanupThemeElements(title)
							CleanupThemeElements(content)
							ReturnFrame(base)
						end
				}
				return element
			end

			function SectionFunctions:AddProgressBar(settings)
				settings = settings or {}
				local base, card = MakeGlass(Config.ColumnWidth, settings.Height or 48)
				local pad = Instance.new("UIPadding", card)
				pad.PaddingLeft = UDim.new(0, 10)
				pad.PaddingRight = UDim.new(0, 10)
				pad.PaddingTop = UDim.new(0, 8)
				pad.PaddingBottom = UDim.new(0, 8)

				local text = Instance.new("TextLabel", card)
				text.Text = settings.Text or ""
				text.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
				text.TextColor3 = CurrentTheme.TextColor
				text.TextSize = 12
				text.BackgroundTransparency = 1
				text.Size = UDim2.new(1, 0, 0, 14)
				text.TextXAlignment = Enum.TextXAlignment.Left
				text.ZIndex = 10
				text.RichText = true
				table.insert(ThemeElements, {Object = text, Role = "Text"})

				local track = Instance.new("Frame", card)
				track.Size = UDim2.new(1, 0, 0, settings.BarHeight or 6)
				track.Position = UDim2.new(0, 0, 1, -(settings.BarHeight or 6) - 6)
				track.BackgroundColor3 = CurrentTheme.SliderBg
				track.BorderSizePixel = 0
				track.ZIndex = 5
				Instance.new("UICorner", track).CornerRadius = UDim.new(0, (settings.BarHeight or 6) / 2)
				table.insert(ThemeElements, {Object = track, Role = "SliderBg"})

				local fill = Instance.new("Frame", track)
				fill.Size = UDim2.new(settings.Value or 0, 0, 1, 0)
				fill.BackgroundColor3 = settings.FillColor or CurrentTheme.SliderFill
				fill.BorderSizePixel = 0
				fill.ZIndex = 6
				Instance.new("UICorner", fill).CornerRadius = UDim.new(0, (settings.BarHeight or 6) / 2)
				table.insert(ThemeElements, {Object = fill, Role = "SliderFill"})

				local element = {
					Value = settings.Value or 0,
					Flag = settings.Flag,
					Type = "ProgressBar",
					Default = settings.Value or 0,
					Instance = base
				}
				if settings.Flag then MacLib.Elements[settings.Flag] = element end

				function element:Set(newValue)
					newValue = math.clamp(tonumber(newValue) or 0, 0, 1)
					self.Value = newValue
					Tween(fill, TweenInfo.new(0.3), {Size = UDim2.new(newValue, 0, 1, 0)})
					if settings.Text then
						text.Text = settings.Text:gsub("%%v%%", tostring(math.floor(newValue * 100)))
					end
					if settings.Flag then SetConfigValue(settings.Flag, newValue) end
				end

				function element:Highlight()
					FlashHighlight(base)
				end

				function element:Destroy()
					CleanupThemeElements(text)
					CleanupThemeElements(track)
					CleanupThemeElements(fill)
					ReturnFrame(base)
					if settings.Flag then MacLib.Elements[settings.Flag] = nil end
				end

				base.Parent = col
				return element
			end

			function SectionFunctions:AddCircularProgress(settings)
				settings = settings or {}
				local size = settings.Size or 64
				local base, card = MakeGlass(Config.ColumnWidth, size + 20)

				local container = Instance.new("Frame", card)
				container.Size = UDim2.fromOffset(size, size)
				container.Position = UDim2.new(0.5, 0, 0.5, 0)
				container.AnchorPoint = Vector2.new(0.5, 0.5)
				container.BackgroundTransparency = 1
				container.ZIndex = 5

				local trackColor = settings.TrackColor or CurrentTheme.SliderBg
				local fillColor = settings.FillColor or CurrentTheme.SliderFill

				local track = Instance.new("Frame", container)
				track.Size = UDim2.new(1, 0, 1, 0)
				track.BackgroundColor3 = trackColor
				track.BorderSizePixel = 0
				Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

				local fill = Instance.new("Frame", container)
				fill.Size = UDim2.new(1, 0, 1, 0)
				fill.BackgroundColor3 = fillColor
				fill.BorderSizePixel = 0
				Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
				fill.ZIndex = 2

				local rightMask = Instance.new("Frame", container)
				rightMask.Size = UDim2.new(0.5, 0, 1, 0)
				rightMask.Position = UDim2.new(0.5, 0, 0, 0)
				rightMask.BackgroundTransparency = 1
				rightMask.ClipsDescendants = true
				rightMask.ZIndex = 3

				local rightWiper = Instance.new("Frame", rightMask)
				rightWiper.Size = UDim2.new(2, 0, 1, 0)
				rightWiper.BackgroundColor3 = trackColor
				rightWiper.BorderSizePixel = 0
				rightWiper.AnchorPoint = Vector2.new(0, 0.5)
				rightWiper.Position = UDim2.new(0, 0, 0.5, 0)
				Instance.new("UICorner", rightWiper).CornerRadius = UDim.new(1, 0)

				local leftMask = Instance.new("Frame", container)
				leftMask.Size = UDim2.new(0.5, 0, 1, 0)
				leftMask.BackgroundTransparency = 1
				leftMask.ClipsDescendants = true
				leftMask.ZIndex = 3
				leftMask.Visible = false

				local leftWiper = Instance.new("Frame", leftMask)
				leftWiper.Size = UDim2.new(2, 0, 1, 0)
				leftWiper.BackgroundColor3 = trackColor
				leftWiper.BorderSizePixel = 0
				leftWiper.AnchorPoint = Vector2.new(1, 0.5)
				leftWiper.Position = UDim2.new(1, 0, 0.5, 0)
				Instance.new("UICorner", leftWiper).CornerRadius = UDim.new(1, 0)

				if settings.Ring then
					local hole = Instance.new("Frame", container)
					hole.Size = UDim2.new(1, -(settings.Stroke or 12), 1, -(settings.Stroke or 12))
					hole.Position = UDim2.new(0.5, 0, 0.5, 0)
					hole.AnchorPoint = Vector2.new(0.5, 0.5)
					hole.BackgroundColor3 = trackColor
					hole.BorderSizePixel = 0
					Instance.new("UICorner", hole).CornerRadius = UDim.new(1, 0)
					hole.ZIndex = 4
				end

				local centerText = Instance.new("TextLabel", container)
				centerText.Text = settings.Text or ""
				centerText.FontFace = Font.new(Config.Font, Enum.FontWeight.Bold)
				centerText.TextColor3 = CurrentTheme.TextColor
				centerText.TextSize = 13
				centerText.BackgroundTransparency = 1
				centerText.Size = UDim2.new(1, 0, 1, 0)
				centerText.ZIndex = 5
				centerText.RichText = true

				local element = {
					Value = settings.Value or 0,
					Flag = settings.Flag,
					Type = "CircularProgress",
					Default = settings.Value or 0,
					Instance = base
				}
				if settings.Flag then MacLib.Elements[settings.Flag] = element end

				local function setProgress(p)
					p = math.clamp(p, 0, 1)
					local angle = p * 360
					if angle <= 180 then
						leftMask.Visible = false
						rightMask.Visible = true
						rightWiper.Rotation = angle
					else
						leftMask.Visible = true
						rightMask.Visible = true
						rightWiper.Rotation = 180
						leftWiper.Rotation = angle - 180
					end
					if settings.Text then
						centerText.Text = settings.Text:gsub("%%v%%", tostring(math.floor(p * 100)))
					end
				end

				function element:Set(newValue)
					newValue = math.clamp(tonumber(newValue) or 0, 0, 1)
					self.Value = newValue
					setProgress(newValue)
					if settings.Flag then SetConfigValue(settings.Flag, newValue) end
				end

				function element:Highlight()
					FlashHighlight(base)
				end

				function element:Destroy()
					ReturnFrame(base)
					if settings.Flag then MacLib.Elements[settings.Flag] = nil end
				end

				setProgress(element.Value)
				base.Parent = col
				return element
			end

			function SectionFunctions:AddCodeBlock(settings)
				settings = settings or {}
				local base, card = MakeGlass(Config.ColumnWidth, settings.Height or 60)
				card.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
				card.BackgroundTransparency = 0.1

				local pad = Instance.new("UIPadding", card)
				pad.PaddingLeft = UDim.new(0, 10)
				pad.PaddingRight = UDim.new(0, 10)
				pad.PaddingTop = UDim.new(0, 8)
				pad.PaddingBottom = UDim.new(0, 8)

				local scroll = Instance.new("ScrollingFrame", card)
				scroll.Size = UDim2.new(1, 0, 1, 0)
				scroll.BackgroundTransparency = 1
				scroll.ScrollBarThickness = 2
				scroll.ScrollBarImageColor3 = CurrentTheme.ToggleOn
				scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
				scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

				local label = Instance.new("TextLabel", scroll)
				label.Text = settings.Text or ""
				local ok = pcall(function()
					label.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json")
				end)
				if not ok then
					pcall(function()
						label.FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json")
					end)
				end
				if not ok then
					label.FontFace = Font.new(Config.Font)
				end
				label.TextColor3 = Color3.fromRGB(200, 220, 200)
				label.TextSize = 11
				label.BackgroundTransparency = 1
				label.Size = UDim2.new(1, 0, 0, 0)
				label.AutomaticSize = Enum.AutomaticSize.Y
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextYAlignment = Enum.TextYAlignment.Top
				label.TextWrapped = true
				label.RichText = false

				local element = {
					Value = settings.Text or "",
					Flag = settings.Flag,
					Type = "CodeBlock",
					Default = settings.Text or "",
					Instance = base
				}
				if settings.Flag then MacLib.Elements[settings.Flag] = element end

				function element:Destroy()
					if settings.Flag then MacLib.Elements[settings.Flag] = nil end
					ReturnFrame(base)
				end

				function element:Set(newValue)
					if typeof(newValue) ~= "string" then return end
					label.Text = newValue
					self.Value = newValue
					if settings.Flag then SetConfigValue(settings.Flag, newValue) end
				end

				base.Parent = col
				return element
			end

			function SectionFunctions:AddPlayerList(settings)
				settings = settings or {}
				local base, card = MakeGlass(Config.ColumnWidth, settings.Height or 220)
				local pad = Instance.new("UIPadding", card)
				pad.PaddingLeft = UDim.new(0, 6)
				pad.PaddingRight = UDim.new(0, 6)
				pad.PaddingTop = UDim.new(0, 6)
				pad.PaddingBottom = UDim.new(0, 6)

				local titleLabel
				if settings.Title then
					titleLabel = Instance.new("TextLabel", card)
					titleLabel.Text = settings.Title
					titleLabel.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
					titleLabel.TextColor3 = CurrentTheme.TextColor
					titleLabel.TextSize = 13
					titleLabel.BackgroundTransparency = 1
					titleLabel.Size = UDim2.new(1, 0, 0, 18)
					titleLabel.TextXAlignment = Enum.TextXAlignment.Left
					titleLabel.ZIndex = 10
					table.insert(ThemeElements, {Object = titleLabel, Role = "Text"})
				end

				local scroll = Instance.new("ScrollingFrame", card)
				scroll.Size = UDim2.new(1, 0, 1, -(titleLabel and 24 or 0))
				scroll.Position = UDim2.new(0, 0, 0, titleLabel and 22 or 0)
				scroll.BackgroundTransparency = 1
				scroll.ScrollBarThickness = 2
				scroll.ScrollBarImageColor3 = CurrentTheme.ToggleOn
				scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
				scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

				local listLayout = Instance.new("UIListLayout", scroll)
				listLayout.Padding = UDim.new(0, 2)

				local selectedPlayer = nil
				local playerItems = {}
				local menuFrame = nil

				local function closeMenu()
					if menuFrame then
						menuFrame:Destroy()
						menuFrame = nil
					end
				end

				local function openMenu(plr, pos)
					closeMenu()
					menuFrame = Instance.new("Frame", card)
					menuFrame.Size = UDim2.fromOffset(130, 0)
					menuFrame.Position = UDim2.new(0, pos.X - card.AbsolutePosition.X, 0, pos.Y - card.AbsolutePosition.Y)
					menuFrame.BackgroundColor3 = CurrentTheme.DropdownBg
					menuFrame.BackgroundTransparency = 0.02
					menuFrame.BorderSizePixel = 0
					menuFrame.ZIndex = 50
					Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 6)
					local mStroke = Instance.new("UIStroke", menuFrame)
					mStroke.Color = CurrentTheme.StrokeColor
					mStroke.Transparency = 0.4

					local menuList = Instance.new("UIListLayout", menuFrame)
					menuList.Padding = UDim.new(0, 0)

					local options = settings.MenuItems or {
						{Label = "Copy Username", Callback = function(p) if setclipboard then setclipboard(p.Name) end end},
						{Label = "Copy UserId", Callback = function(p) if setclipboard then setclipboard(tostring(p.UserId)) end end},
					}

					for _, opt in ipairs(options) do
						local btn = Instance.new("TextButton", menuFrame)
						btn.Text = opt.Label
						btn.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
						btn.TextColor3 = CurrentTheme.TextColor
						btn.TextSize = 11
						btn.BackgroundTransparency = 1
						btn.Size = UDim2.new(1, 0, 0, 26)
						btn.AutoButtonColor = false
						btn.ZIndex = 51

						btn.MouseEnter:Connect(function()
							btn.BackgroundTransparency = 0.85
							btn.BackgroundColor3 = CurrentTheme.SelectionColor
						end)
						btn.MouseLeave:Connect(function()
							btn.BackgroundTransparency = 1
						end)
						btn.MouseButton1Click:Connect(function()
							closeMenu()
							if opt.Callback then pcall(function() opt.Callback(plr) end) end
						end)
					end

					task.defer(function()
						local h = menuList.AbsoluteContentSize.Y
						menuFrame.Size = UDim2.fromOffset(130, h)
					end)
				end

				local function selectItem(item, plr)
					for _, other in pairs(playerItems) do
						if other ~= item then
							other.BackgroundTransparency = 1
						end
					end
					item.BackgroundTransparency = 0.85
					item.BackgroundColor3 = CurrentTheme.SelectionColor
					selectedPlayer = plr
				end

				local function addPlayer(plr)
					if playerItems[plr] then return end
					local item = Instance.new("TextButton", scroll)
					item.Size = UDim2.new(1, 0, 0, 32)
					item.BackgroundTransparency = 1
					item.AutoButtonColor = false
					item.Text = ""
					item.ZIndex = 10

					local avatar = Instance.new("ImageLabel", item)
					avatar.Size = UDim2.fromOffset(24, 24)
					avatar.Position = UDim2.new(0, 4, 0.5, -12)
					avatar.BackgroundTransparency = 1
					avatar.ZIndex = 11
					local ok2, thumb = pcall(function()
						return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
					end)
					avatar.Image = ok2 and thumb or ""

					local nameLabel = Instance.new("TextLabel", item)
					nameLabel.Text = plr.DisplayName ~= plr.Name and (plr.DisplayName .. " (@" .. plr.Name .. ")") or plr.Name
					nameLabel.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
					nameLabel.TextColor3 = CurrentTheme.TextColor
					nameLabel.TextSize = 12
					nameLabel.BackgroundTransparency = 1
					nameLabel.Position = UDim2.new(0, 34, 0, 0)
					nameLabel.Size = UDim2.new(1, -40, 1, 0)
					nameLabel.TextXAlignment = Enum.TextXAlignment.Left
					nameLabel.ZIndex = 11
					table.insert(ThemeElements, {Object = nameLabel, Role = "Text"})

					item.MouseButton1Click:Connect(function()
						selectItem(item, plr)
						if settings.SelectCallback then settings.SelectCallback(plr) end
					end)

					item.MouseButton2Click:Connect(function()
						selectItem(item, plr)
						local mousePos = UserInputService:GetMouseLocation()
						openMenu(plr, mousePos)
					end)

					-- Long-press right click for mobile
					if IsMobile then
						local longPressThread
						item.InputBegan:Connect(function(inp)
							if inp.UserInputType == Enum.UserInputType.Touch then
								longPressThread = task.delay(0.5, function()
									selectItem(item, plr)
									openMenu(plr, inp.Position)
								end)
							end
						end)
						item.InputEnded:Connect(function(inp)
							if inp.UserInputType == Enum.UserInputType.Touch and longPressThread then
								pcall(function() task.cancel(longPressThread) end)
								longPressThread = nil
							end
						end)
					end

					playerItems[plr] = item
				end

				for _, plr in ipairs(Players:GetPlayers()) do
					addPlayer(plr)
				end

				local conn1 = Players.PlayerAdded:Connect(addPlayer)
				local conn2 = Players.PlayerRemoving:Connect(function(plr)
					if playerItems[plr] then
						playerItems[plr]:Destroy()
						playerItems[plr] = nil
					end
					if selectedPlayer == plr then selectedPlayer = nil end
				end)

				local menuClickConn = UserInputService.InputBegan:Connect(function(inp, gpe)
					if gpe then return end
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.MouseButton2 or inp.UserInputType == Enum.UserInputType.Touch then
						if menuFrame then
							local mousePos = UserInputService:GetMouseLocation()
							local absPos = menuFrame.AbsolutePosition
							local absSize = menuFrame.AbsoluteSize
							if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
								closeMenu()
							end
						end
					end
				end)

				local element = {
					Value = selectedPlayer,
					Flag = settings.Flag,
					Type = "PlayerList",
					Default = nil,
					_connections = {conn1, conn2, menuClickConn},
					Instance = base
				}

				function element:Set() end
				function element:Destroy()
					for _, c in ipairs(element._connections) do
						if c then pcall(function() c:Disconnect() end) end
					end
					for plr, item in pairs(playerItems) do
						local nl = item:FindFirstChildOfClass("TextLabel")
						if nl then CleanupThemeElements(nl) end
						item:Destroy()
					end
					closeMenu()
					CleanupThemeElements(titleLabel)
					ReturnFrame(base)
					if settings.Flag then MacLib.Elements[settings.Flag] = nil end
				end

				base.Parent = col
				return element
			end

			function SectionFunctions:AddSliderRange(settings)
				settings = settings or {}
				local min = settings.Min or 0
				local max = settings.Max or 100
				local flag = settings.Flag
				local rawDef = settings.Default or {min, max}
				local defLow = math.clamp(rawDef[1] or min, min, max)
				local defHigh = math.clamp(rawDef[2] or max, min, max)
				if defLow > defHigh then defLow, defHigh = defHigh, defLow end
				local increment = settings.Increment or 0
				local suffix = settings.Suffix or ""
				if increment > 0 then
					defLow = math.round(defLow / increment) * increment
					defHigh = math.round(defHigh / increment) * increment
				end

				local base, card = MakeGlass(Config.ColumnWidth, 60)
				local pad = Instance.new("UIPadding", card)
				pad.PaddingLeft = UDim.new(0, 8)
				pad.PaddingRight = UDim.new(0, 8)
				pad.PaddingTop = UDim.new(0, 6)
				pad.PaddingBottom = UDim.new(0, 6)

				local title = Instance.new("TextLabel", card)
				title.Text = settings.Name or "Range"
				title.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
				title.TextColor3 = CurrentTheme.TextColor
				title.TextSize = Config.NormalSize
				title.TextTransparency = 0.2
				title.BackgroundTransparency = 1
				title.Size = UDim2.new(1, -80, 0, 16)
				title.TextXAlignment = Enum.TextXAlignment.Left
				title.ZIndex = 10
				table.insert(ThemeElements, {Object = title, Role = "Text"})

				local valBox = Instance.new("TextLabel", card)
				valBox.Text = tostring(math.floor(defLow)) .. suffix .. " - " .. tostring(math.floor(defHigh)) .. suffix
				valBox.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
				valBox.TextColor3 = CurrentTheme.TextColor
				valBox.TextSize = 11
				valBox.BackgroundColor3 = CurrentTheme.CardBackColor
				valBox.BackgroundTransparency = 0.3
				valBox.BorderSizePixel = 0
				valBox.Size = UDim2.fromOffset(70, 20)
				valBox.Position = UDim2.new(1, -74, 0, 0)
				valBox.TextXAlignment = Enum.TextXAlignment.Center
				valBox.ZIndex = 10
				Instance.new("UICorner", valBox).CornerRadius = UDim.new(0, 5)

				local track = Instance.new("Frame", card)
				track.Size = UDim2.new(1, -10, 0, 4)
				track.Position = UDim2.new(0, 5, 1, -14)
				track.BackgroundColor3 = CurrentTheme.SliderBg
				track.BorderSizePixel = 0
				track.ZIndex = 5
				Instance.new("UICorner", track).CornerRadius = UDim.new(0, 2)
				table.insert(ThemeElements, {Object = track, Role = "SliderBg"})

				local fill = Instance.new("Frame", track)
				fill.Size = UDim2.new((defHigh - defLow) / (max - min), 0, 1, 0)
				fill.Position = UDim2.new((defLow - min) / (max - min), 0, 0, 0)
				fill.BackgroundColor3 = CurrentTheme.SliderFill
				fill.BorderSizePixel = 0
				fill.ZIndex = 6
				Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
				table.insert(ThemeElements, {Object = fill, Role = "SliderFill"})

				local knob1 = Instance.new("Frame", track)
				knob1.Size = UDim2.fromOffset(12, 12)
				knob1.Position = UDim2.new((defLow - min) / (max - min), -6, 0.5, -6)
				knob1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				knob1.BorderSizePixel = 0
				knob1.ZIndex = 7
				Instance.new("UICorner", knob1).CornerRadius = UDim.new(1, 0)

				local knob2 = Instance.new("Frame", track)
				knob2.Size = UDim2.fromOffset(12, 12)
				knob2.Position = UDim2.new((defHigh - min) / (max - min), -6, 0.5, -6)
				knob2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				knob2.BorderSizePixel = 0
				knob2.ZIndex = 7
				Instance.new("UICorner", knob2).CornerRadius = UDim.new(1, 0)

				local dragTarget = nil
				local currentLow, currentHigh = defLow, defHigh

				local function formatVal(val)
					if increment > 0 then
						val = math.round(val / increment) * increment
					end
					return math.clamp(val, min, max)
				end

				local function updateVisual()
					local alphaLow = (currentLow - min) / (max - min)
					local alphaHigh = (currentHigh - min) / (max - min)
					fill.Position = UDim2.new(alphaLow, 0, 0, 0)
					fill.Size = UDim2.new(alphaHigh - alphaLow, 0, 1, 0)
					knob1.Position = UDim2.new(alphaLow, -6, 0.5, -6)
					knob2.Position = UDim2.new(alphaHigh, -6, 0.5, -6)
					valBox.Text = tostring(math.floor(currentLow)) .. suffix .. " - " .. tostring(math.floor(currentHigh)) .. suffix
				end

				local function updateFromInput(x)
					local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					local val = min + (max - min) * rel
					val = formatVal(val)

					if dragTarget == "low" then
						if val > currentHigh then val = currentHigh end
						currentLow = val
					elseif dragTarget == "high" then
						if val < currentLow then val = currentLow end
						currentHigh = val
					end

					updateVisual()
					if settings.Callback then settings.Callback({currentLow, currentHigh}) end
				end

				local conn1 = track.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
						local val = min + (max - min) * rel
						val = formatVal(val)
						local distLow = math.abs(val - currentLow)
						local distHigh = math.abs(val - currentHigh)
						dragTarget = distLow < distHigh and "low" or "high"
						updateFromInput(inp.Position.X)
					end
				end)

				local conn2 = UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						dragTarget = nil
					end
				end)

				local conn3 = UserInputService.InputChanged:Connect(function(inp)
					if dragTarget and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
						updateFromInput(inp.Position.X)
					end
				end)

				-- Mobile touch hitbox for track
				AddTouchHitbox(track, card, function(inp)
					local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					local val = min + (max - min) * rel
					val = formatVal(val)
					local distLow = math.abs(val - currentLow)
					local distHigh = math.abs(val - currentHigh)
					dragTarget = distLow < distHigh and "low" or "high"
					updateFromInput(inp.Position.X)
				end)

				local element = {
					Value = {currentLow, currentHigh},
					Flag = flag,
					Type = "SliderRange",
					Default = rawDef,
					_connections = {conn1, conn2, conn3},
					Instance = track
				}
				if flag then MacLib.Elements[flag] = element end

				function element:Set(newValue)
					if typeof(newValue) ~= "table" or #newValue < 2 then return end
					currentLow = math.clamp(formatVal(newValue[1]), min, max)
					currentHigh = math.clamp(formatVal(newValue[2]), min, max)
					if currentLow > currentHigh then currentLow, currentHigh = currentHigh, currentLow end
					self.Value = {currentLow, currentHigh}
					updateVisual()
					if flag then SetConfigValue(flag, self.Value) end
					if settings.Callback then settings.Callback(self.Value) end
				end

				function element:Destroy()
					for _, c in ipairs(element._connections) do
						if c then pcall(function() c:Disconnect() end) end
					end
					CleanupThemeElements(title)
					CleanupThemeElements(track)
					CleanupThemeElements(fill)
					CleanupThemeElements(knob1)
					CleanupThemeElements(knob2)
					CleanupThemeElements(valBox)
					ReturnFrame(base)
					if flag then MacLib.Elements[flag] = nil end
				end

				base.Parent = col
				return element
			end

			local function makeToggle(parent, arg1, arg2, arg3)
			local settings = {}
			if typeof(arg1) == "table" then
				settings = arg1
			else
				settings.Default = arg1
				settings.Callback = arg2
				settings.Flag = arg3
			end

			local flag = settings.Flag or settings.ConfigId
			local callback = settings.Callback
			local rawDefault = settings.Default
			if typeof(rawDefault) ~= "boolean" then rawDefault = false end
			local default = rawDefault
			if flag and MacLib.ConfigData[flag] ~= nil then
				default = MacLib.ConfigData[flag]
			end

			local track = Instance.new("Frame")
			track.Size = UDim2.fromOffset(Config.ToggleWidth, Config.ToggleHeight)
			track.Position = UDim2.new(1, -Config.ToggleWidth-6, 0.5, -Config.ToggleHeight/2)
			track.BackgroundColor3 = default and CurrentTheme.ToggleOn or CurrentTheme.ToggleOff
			track.BorderSizePixel = 0
			track.ZIndex = 5
			Instance.new("UICorner", track).CornerRadius = UDim.new(0, Config.ToggleHeight/2)

			local trackStroke = Instance.new("UIStroke", track)
			trackStroke.Color = CurrentTheme.StrokeColor
			trackStroke.Transparency = 0.4
			trackStroke.Thickness = 1
			trackStroke.ZIndex = 6
			table.insert(ThemeElements, {Object = trackStroke, Role = "Stroke"})

			local role = default and "ToggleOn" or "ToggleOff"
			table.insert(ThemeElements, {Object = track, Role = role})
			track.Parent = parent

			local knob = Instance.new("Frame", track)
			knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
			knob.Size = UDim2.fromOffset(Config.ToggleKnob, Config.ToggleKnob)
			knob.Position = default and UDim2.new(1, -Config.ToggleKnob-2, 0.5, -Config.ToggleKnob/2)
				or UDim2.new(0,2,0.5, -Config.ToggleKnob/2)
			knob.ZIndex = 7
			Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

			local state = default
			local disabled = false
			local inputConn = nil

			local element = {
				Value = state,
				Flag = flag,
				Type = "Toggle",
				Default = rawDefault,
				Disabled = false,
				_connections = {},
				Instance = track
			}

			if flag then
				MacLib.Elements[flag] = element
			end

			function element:SetEnabled(isEnabled)
				disabled = not isEnabled
				element.Disabled = disabled
				if disabled then
					track.BackgroundTransparency = 0.5
					knob.BackgroundTransparency = 0.5
					if inputConn then
						inputConn:Disconnect()
						inputConn = nil
					end
				else
					track.BackgroundTransparency = 0
					knob.BackgroundTransparency = 0
					if not inputConn then
						inputConn = track.InputBegan:Connect(onInputBegan)
					end
				end
			end

			function element:Set(newValue)
				if typeof(newValue) ~= "boolean" then return end
				if state == newValue then return end
				state = newValue
				element.Value = state
				local newRole = state and "ToggleOn" or "ToggleOff"
				for i, v in ipairs(ThemeElements) do
					if v.Object == track then v.Role = newRole end
				end
				Tween(track, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					BackgroundColor3 = state and CurrentTheme.ToggleOn or CurrentTheme.ToggleOff
				})
				-- Bouncy spring with overshoot: move 2px past target then settle
				local targetPos = state 
					and UDim2.new(1, -Config.ToggleKnob-2, 0.5, -Config.ToggleKnob/2)
					or UDim2.new(0, 2, 0.5, -Config.ToggleKnob/2)
				local overshootPos = state
					and UDim2.new(1, -Config.ToggleKnob-4, 0.5, -Config.ToggleKnob/2)
					or UDim2.new(0, 4, 0.5, -Config.ToggleKnob/2)

				Tween(knob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = overshootPos
				})
				task.delay(0.15, function()
					Tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Position = targetPos
					})
				end)
				if flag then SetConfigValue(flag, state) end
				print("[MacLib] Toggle '" .. tostring(flag or "unnamed") .. "' = " .. tostring(state))
				if callback then callback(state) end
			end

			function element:Highlight()
				FlashHighlight(track)
			end

			function element:Destroy()
				for _, conn in ipairs(element._connections) do
					if conn then pcall(function() conn:Disconnect() end) end
				end
				if inputConn then inputConn:Disconnect() end
				CleanupThemeElements(trackStroke)
				CleanupThemeElements(track)
				CleanupThemeElements(knob)
				if track then track:Destroy() end
				if flag then MacLib.Elements[flag] = nil end
			end

			local function onInputBegan(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
					PlaySound("Click")
					element:Set(not state)
				end
			end

			inputConn = track.InputBegan:Connect(onInputBegan)
			table.insert(element._connections, inputConn)

			track.MouseEnter:Connect(function() PlaySound("Hover") end)
			-- Mobile touch hitbox
			AddTouchHitbox(track, parent, onInputBegan)

			if state ~= settings.Default then
				element:Set(state)
			end

			if settings.Tooltip then AttachTooltip(track, settings.Tooltip) end
			return element
		end
local function makeSlider(parent, settings)
			settings = settings or {}
			local min = settings.Min or 0
			local max = settings.Max or 100
			local flag = settings.Flag or settings.ConfigId
			local rawDef = settings.Default or min
			local def = rawDef
			if flag and MacLib.ConfigData[flag] ~= nil then
				def = MacLib.ConfigData[flag]
			end
			def = math.clamp(def, min, max)
			local increment = settings.Increment or 0
			local suffix = settings.Suffix or ""
			if increment > 0 then
				def = math.round(def / increment) * increment
			end
			local alpha = (def - min) / (max - min)

			local track = Instance.new("Frame")
			track.Size = UDim2.fromOffset(Config.SliderWidth, Config.SliderHeight)
			track.Position = UDim2.new(1, -Config.SliderWidth-6, 0.5, -Config.SliderHeight/2)
			track.BackgroundColor3 = CurrentTheme.SliderBg
			track.BorderSizePixel = 0
			track.ZIndex = 5
			Instance.new("UICorner", track).CornerRadius = UDim.new(0, Config.SliderHeight/2)
			table.insert(ThemeElements, {Object = track, Role = "SliderBg"})
			track.Parent = parent

			local fill = Instance.new("Frame", track)
			fill.Size = UDim2.new(alpha,0,1,0)
			fill.BackgroundColor3 = CurrentTheme.SliderFill
			fill.BorderSizePixel = 0
			fill.ZIndex = 6
			Instance.new("UICorner", fill).CornerRadius = UDim.new(0, Config.SliderHeight/2)
			table.insert(ThemeElements, {Object = fill, Role = "SliderFill"})

			local knob = Instance.new("Frame", track)
			knob.Size = UDim2.fromOffset(Config.SliderKnob, Config.SliderKnob)
			knob.Position = UDim2.new(alpha, -Config.SliderKnob/2, 0.5, -Config.SliderKnob/2)
			knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
			knob.ZIndex = 7
			Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

			-- Drag tooltip showing current value
			local dragTooltip = Instance.new("TextLabel", track)
			dragTooltip.BackgroundColor3 = CurrentTheme.DropdownBg
			dragTooltip.BackgroundTransparency = 0.1
			dragTooltip.BorderSizePixel = 0
			dragTooltip.TextColor3 = CurrentTheme.TextColor
			dragTooltip.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
			dragTooltip.TextSize = 10
			dragTooltip.Text = tostring(math.floor(def)) .. suffix
			dragTooltip.Size = UDim2.fromOffset(40, 18)
			dragTooltip.Position = UDim2.new(alpha, -20, 0, -24)
			dragTooltip.Visible = false
			dragTooltip.ZIndex = 10
			Instance.new("UICorner", dragTooltip).CornerRadius = UDim.new(0, 4)
			local tooltipStroke = Instance.new("UIStroke", dragTooltip)
			tooltipStroke.Color = CurrentTheme.StrokeColor
			tooltipStroke.Transparency = 0.5
			tooltipStroke.Thickness = 1

			local drag = false
			local currentValue = def

			local element = {
				Value = currentValue,
				Flag = flag,
				Type = "Slider",
				Default = rawDef,
				_connections = {},
				Instance = track
			}

			if flag then
				MacLib.Elements[flag] = element
			end

			local function formatValue(val)
				if increment > 0 then
					val = math.round(val / increment) * increment
				end
				return val
			end

			local function displayValue(val)
				if increment > 0 then
					val = math.round(val / increment) * increment
				end
				return tostring(math.floor(val)) .. suffix
			end

			local function updateVisual(rel)
				fill.Size = UDim2.new(rel,0,1,0)
				knob.Position = UDim2.new(rel, -Config.SliderKnob/2, 0.5, -Config.SliderKnob/2)
				dragTooltip.Position = UDim2.new(rel, -20, 0, -24)
				dragTooltip.Text = displayValue(currentValue)
			end

			local function updateFromInput(x)
				local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				updateVisual(rel)
				currentValue = min + (max-min)*rel
				currentValue = formatValue(currentValue)
				element.Value = currentValue
				if flag then SetConfigValue(flag, currentValue) end
				print("[MacLib] Slider '" .. tostring(flag or "unnamed") .. "' = " .. displayValue(currentValue))
				if settings.Callback then settings.Callback(currentValue) end
			end

			local function onInputBegan(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
					PlaySound("Click")
					drag = true
					-- Scale up knob on drag start
					Tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Size = UDim2.fromOffset(Config.SliderKnob + 4, Config.SliderKnob + 4)
					})
					dragTooltip.Visible = true
					updateFromInput(inp.Position.X)
				end
			end

			track.InputBegan:Connect(onInputBegan)
			UserInputService.InputEnded:Connect(function(inp)
				if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
					if drag then
						drag = false
						-- Scale back knob on release
						Tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
							Size = UDim2.fromOffset(Config.SliderKnob, Config.SliderKnob)
						})
						dragTooltip.Visible = false
					end
				end
			end)
			UserInputService.InputChanged:Connect(function(inp)
				if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
					updateFromInput(inp.Position.X)
				end
			end)

			track.MouseEnter:Connect(function() PlaySound("Hover") end)
			-- Mobile touch hitbox
			AddTouchHitbox(track, parent, onInputBegan)

			function element:Set(newValue)
				local num = tonumber(newValue)
				if not num then return end
				num = math.clamp(num, min, max)
				if increment > 0 then
					num = math.round(num / increment) * increment
				end
				if currentValue == num then return end
				currentValue = num
				element.Value = currentValue
				local rel = (num - min) / (max - min)
				updateVisual(rel)
				if flag then SetConfigValue(flag, currentValue) end
				print("[MacLib] Slider '" .. tostring(flag or "unnamed") .. "' = " .. displayValue(currentValue))
				if settings.Callback then settings.Callback(currentValue) end
			end

			function element:Highlight()
				FlashHighlight(track)
			end

			function element:Destroy()
				for _, conn in ipairs(element._connections) do
					if conn then pcall(function() conn:Disconnect() end) end
				end
				CleanupThemeElements(track)
				CleanupThemeElements(fill)
				CleanupThemeElements(knob)
				if track then track:Destroy() end
				if flag then MacLib.Elements[flag] = nil end
			end

			if currentValue ~= (settings.Default or min) then
				element:Set(currentValue)
			end

			if settings.Tooltip then AttachTooltip(track, settings.Tooltip) end
			return element
		end

local function SetupCollapsible(base, card, settings, contentHolder)
				if not settings.Collapsible then return end
				local headerHeight = 28
				local titleText = settings.Title or "Card"
				local originalSize = base.Size
				local expanded = true

				local header = Instance.new("Frame")
				header.Name = "CollapseHeader"
				header.Size = UDim2.new(1, 0, 0, headerHeight)
				header.BackgroundTransparency = 1
				header.ZIndex = 15

				local titleLabel = Instance.new("TextLabel", header)
				titleLabel.Text = titleText
				titleLabel.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
				titleLabel.TextColor3 = CurrentTheme.TextColor
				titleLabel.TextSize = 13
				titleLabel.TextTransparency = 0.1
				titleLabel.BackgroundTransparency = 1
				titleLabel.Size = UDim2.new(1, -30, 1, 0)
				titleLabel.Position = UDim2.new(0, 10, 0, 0)
				titleLabel.TextXAlignment = Enum.TextXAlignment.Left
				titleLabel.ZIndex = 16
				table.insert(ThemeElements, {Object = titleLabel, Role = "Text"})

				local chevron = Instance.new("ImageLabel", header)
				chevron.Name = "Chevron"
				chevron.Image = ResolveIcon(Icons.chevron)
				chevron.ImageColor3 = CurrentTheme.TextColor
				chevron.ImageTransparency = 0.3
				chevron.BackgroundTransparency = 1
				chevron.Size = UDim2.fromOffset(14, 14)
				chevron.Position = UDim2.new(1, -22, 0.5, -7)
				chevron.Rotation = 90
				chevron.ZIndex = 16

				local hitbox = Instance.new("TextButton", header)
				hitbox.Name = "Hitbox"
				hitbox.Size = UDim2.new(1, 0, 1, 0)
				hitbox.BackgroundTransparency = 1
				hitbox.Text = ""
				hitbox.AutoButtonColor = false
				hitbox.ZIndex = 17

				header.Parent = card

				for _, child in ipairs(contentHolder:GetChildren()) do
					if child:IsA("GuiObject") then
						child.Position = child.Position + UDim2.new(0, 0, 0, headerHeight)
					end
				end

				hitbox.MouseButton1Click:Connect(function()
					PlaySound("Click")
					expanded = not expanded
					Tween(chevron, TweenInfo.new(0.2), {Rotation = expanded and 90 or 0})
					if expanded then
						Tween(base, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = originalSize})
						contentHolder.Visible = true
					else
						local collapsedHeight = headerHeight + 8
						Tween(base, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.fromOffset(originalSize.X.Offset, collapsedHeight)})
						task.delay(0.3, function()
							if not expanded then contentHolder.Visible = false end
						end)
					end
				end)
			end

			function SectionFunctions:GroupCard(settings)
				settings = settings or {}
				local cardHeight = settings.Height or 218
				local searchTags = {}
				local base, card = MakeGlass(Config.ColumnWidth, cardHeight)
				local pad = Instance.new("UIPadding", card)
				pad.PaddingLeft = UDim.new(0,6)
				pad.PaddingRight = UDim.new(0,6)
				pad.PaddingTop = UDim.new(0,6)
				pad.PaddingBottom = UDim.new(0,6)
				local wrap = Instance.new("UIListLayout", card)
				wrap.FillDirection = Enum.FillDirection.Horizontal
				wrap.Wraps = true
				wrap.Padding = UDim.new(0,6)
				wrap.SortOrder = Enum.SortOrder.LayoutOrder
				base.Parent = col
				local Group = {}

				if settings.Collapsible then
					SetupCollapsible(base, card, settings, card)
				end

				function Group:AddSmallCard(S)
					local subBase, subCard = MakeGlass(80, 80)
					subBase.Size = UDim2.fromOffset(80,80)

					local top = Instance.new("Frame")
					top.BackgroundTransparency = 1
					top.Size = UDim2.new(1,-6,0,16)
					top.Position = UDim2.fromScale(0.5,0.08)
					top.AnchorPoint = Vector2.new(0.5,0)
					top.ZIndex = 10

					local icon = Instance.new("ImageLabel", top)
					icon.Image = ResolveIcon(S.Icon) or ""
					icon.ImageTransparency = 0.2
					icon.BackgroundTransparency = 1
					icon.Size = UDim2.fromOffset(14,14)
					icon.Position = UDim2.new(0,0,0,0)
					icon.ZIndex = 11

					local toggleElement
					if S.Toggle ~= nil then
						toggleElement = makeToggle(top, {Default = S.Toggle, Callback = S.Callback, Flag = S.Flag, Tooltip = S.Tooltip})
					end
					top.Parent = subCard

					local title = Instance.new("TextLabel", subCard)
					title.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
					title.Text = S.Title or "Thing"
					title.TextColor3 = CurrentTheme.TextColor
					title.TextSize = Config.TitleSize
					title.TextTransparency = 0.15
					title.BackgroundTransparency = 1
					title.Position = UDim2.new(0.5,0,1,-18)
					title.Size = UDim2.new(1,-6,0,14)
					title.TextXAlignment = Enum.TextXAlignment.Center
					title.AnchorPoint = Vector2.new(0.5,0)
					title.ZIndex = 10
					table.insert(ThemeElements, {Object = title, Role = "Text"})
					subBase.Parent = card

					if S.Title then table.insert(searchTags, S.Title) end
					base:SetAttribute("SearchTags", table.concat(searchTags, " "):lower())

					return toggleElement or subBase
				end

				function Group:AddTallCard(S)
					local subBase, subCard = MakeGlass(168, 120)
					subBase.Size = UDim2.fromOffset(168, 120)

					local top = Instance.new("Frame")
					top.BackgroundTransparency = 1
					top.Size = UDim2.new(1,-6,0,16)
					top.Position = UDim2.fromScale(0.5,0.08)
					top.AnchorPoint = Vector2.new(0.5,0)
					top.ZIndex = 10

					local icon = Instance.new("ImageLabel", top)
					icon.Image = ResolveIcon(S.Icon) or ""
					icon.ImageTransparency = 0.2
					icon.BackgroundTransparency = 1
					icon.Size = UDim2.fromOffset(14,14)
					icon.Position = UDim2.new(0,0,0,0)
					icon.ZIndex = 11

					local toggleElement
					if S.Toggle ~= nil then
						toggleElement = makeToggle(top, {Default = S.Toggle, Callback = S.Callback, Flag = S.Flag, Tooltip = S.Tooltip})
					end
					top.Parent = subCard

					local title = Instance.new("TextLabel", subCard)
					title.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
					title.Text = S.Title or "Thing"
					title.TextColor3 = CurrentTheme.TextColor
					title.TextSize = Config.TitleSize
					title.TextTransparency = 0.15
					title.BackgroundTransparency = 1
					title.Position = UDim2.new(0.5,0,1,-18)
					title.Size = UDim2.new(1,-6,0,14)
					title.TextXAlignment = Enum.TextXAlignment.Center
					title.AnchorPoint = Vector2.new(0.5,0)
					title.ZIndex = 10
					table.insert(ThemeElements, {Object = title, Role = "Text"})
					subBase.Parent = card

					if S.Title then table.insert(searchTags, S.Title) end
					base:SetAttribute("SearchTags", table.concat(searchTags, " "):lower())

					return toggleElement or subBase
				end
				return Group
			end

			function SectionFunctions:SettingsCard(settings)
				local searchTags = {}
				local base, card = MakeGlass(Config.ColumnWidth, 120)
				local pad = Instance.new("UIPadding", card)
				pad.PaddingLeft = UDim.new(0,8)
				pad.PaddingRight = UDim.new(0,8)
				pad.PaddingTop = UDim.new(0,8)
				pad.PaddingBottom = UDim.new(0,8)
				local list = Instance.new("UIListLayout", card)
				list.Padding = UDim.new(0,5)
				list.SortOrder = Enum.SortOrder.LayoutOrder

				if settings.Collapsible then
					SetupCollapsible(base, card, settings, card)
				end

				local result = {}

				local function addRow(name, build)
					local row = Instance.new("Frame")
					row.BackgroundTransparency = 1
					row.Size = UDim2.new(1,0,0,26)
					local label = Instance.new("TextLabel", row)
					label.Text = name
					label.FontFace = Font.new(Config.Font)
					label.TextColor3 = CurrentTheme.TextColor
					label.TextSize = Config.NormalSize
					label.TextTransparency = 0.2
					label.BackgroundTransparency = 1
					label.Size = UDim2.new(1,-90,1,0)
					label.TextXAlignment = Enum.TextXAlignment.Left
					label.TextTruncate = Enum.TextTruncate.AtEnd
					label.ZIndex = 10
					table.insert(ThemeElements, {Object = label, Role = "Text"})
					local built = build(row)
					row.Parent = card
					return built
				end

				if settings.Toggle then
					table.insert(searchTags, settings.Toggle.Name or "Toggle")
					result.Toggle = addRow(settings.Toggle.Name or "Toggle", function(r)
						return makeToggle(r, settings.Toggle)
					end)
				end
				if settings.Slider then
					table.insert(searchTags, settings.Slider.Name or "Slider")
					result.Slider = addRow(settings.Slider.Name or "Slider", function(r)
						return makeSlider(r, settings.Slider)
					end)
				end
				if settings.Button then
					table.insert(searchTags, settings.Button.Name or "Button")
					result.Button = addRow(settings.Button.Name or "Button", function(r)
						local b = Instance.new("TextButton", r)
						b.Text = settings.Button.Label or "Action"
						b.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
						b.TextColor3 = CurrentTheme.TextColor
						b.TextSize = 12
						b.AutoButtonColor = false
						b.BackgroundColor3 = CurrentTheme.ButtonBg
						b.BackgroundTransparency = CurrentTheme.ButtonTransparency
						b.Size = UDim2.fromOffset(55, Config.ButtonHeight)
						b.Position = UDim2.new(1,-55,0.5,-Config.ButtonHeight/2)
						b.ZIndex = 10
						Instance.new("UICorner", b).CornerRadius = UDim.new(0, Config.ButtonCorner)
						local stroke = Instance.new("UIStroke", b)
						stroke.Color = CurrentTheme.StrokeColor
						stroke.Transparency = CurrentTheme.StrokeTransparency
						stroke.ZIndex = 11
						table.insert(ThemeElements, {Object = stroke, Role = "Stroke"})
						table.insert(ThemeElements, {Object = b, Role = "Button"})
						table.insert(ThemeElements, {Object = b, Role = "Text"})

						local element = {
							Value = nil,
							Flag = settings.Button.Flag,
							Type = "Button",
							Default = nil,
							_connections = {},
							Instance = b
						}
						if settings.Button.Flag then
							MacLib.Elements[settings.Button.Flag] = element
						end
						function element:Set() end
						function element:Destroy()
							CleanupThemeElements(stroke)
							CleanupThemeElements(b)
							if b then b:Destroy() end
							if element.Flag then MacLib.Elements[element.Flag] = nil end
						end
						if settings.Button.Callback then 
							b.MouseButton1Click:Connect(function(x, y)
								CreateRipple(b, x, y)
								PlaySound("Click")
								print("[MacLib] SettingsButton '" .. tostring(settings.Button.Name or "unnamed") .. "' clicked")
								PlaySound("Click")
								settings.Button.Callback()
							end)
						end
						if settings.Button.Tooltip then AttachTooltip(b, settings.Button.Tooltip) end
						return element
					end)
				end

				base:SetAttribute("SearchTags", table.concat(searchTags, " "):lower())
				base.Parent = col
				return result
			end

			function SectionFunctions:ModuleCard(settings)
				local searchTags = {}
				local base, card = MakeGlass(Config.ColumnWidth, 130)
				local pad = Instance.new("UIPadding", card)
				pad.PaddingLeft = UDim.new(0,8)
				pad.PaddingRight = UDim.new(0,8)
				pad.PaddingTop = UDim.new(0,6)
				pad.PaddingBottom = UDim.new(0,6)
				local vList = Instance.new("UIListLayout", card)
				vList.Padding = UDim.new(0,5)
				vList.SortOrder = Enum.SortOrder.LayoutOrder

				local result = {
					Toggle = nil,
					Buttons = {}
				}

				local top = Instance.new("Frame")
				top.BackgroundTransparency = 1
				top.Size = UDim2.new(1,0,0,32)
				top.ZIndex = 10
				local title = Instance.new("TextLabel", top)
				title.Text = settings.Title or "Module"
				title.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
				title.TextColor3 = CurrentTheme.TextColor
				title.TextSize = Config.TitleSize
				title.TextTransparency = 0.1
				title.BackgroundTransparency = 1
				title.Size = UDim2.new(1,-36,0,14)
				title.ZIndex = 11
				table.insert(ThemeElements, {Object = title, Role = "Text"})
				if settings.Title then table.insert(searchTags, settings.Title) end

				local sub = Instance.new("TextLabel", top)
				sub.Text = settings.Subtitle or "Lorem ipsum"
				sub.FontFace = Font.new(Config.Font)
				sub.TextColor3 = CurrentTheme.TextDimColor
				sub.TextSize = Config.SubSize
				sub.TextTransparency = 0.3
				sub.BackgroundTransparency = 1
				sub.Position = UDim2.new(0,0,0,15)
				sub.Size = UDim2.new(1,0,0,10)
				sub.TextXAlignment = Enum.TextXAlignment.Left
				sub.ZIndex = 11
				table.insert(ThemeElements, {Object = sub, Role = "TextDim"})
				if settings.Subtitle then table.insert(searchTags, settings.Subtitle) end

				if settings.Collapsible then
					local chevron = Instance.new("ImageLabel", top)
					chevron.Name = "Chevron"
					chevron.Image = ResolveIcon(Icons.chevron)
					chevron.ImageColor3 = CurrentTheme.TextColor
					chevron.ImageTransparency = 0.3
					chevron.BackgroundTransparency = 1
					chevron.Size = UDim2.fromOffset(14, 14)
					chevron.Position = UDim2.new(1, -18, 0, 0)
					chevron.Rotation = 90
					chevron.ZIndex = 12

					local hitbox = Instance.new("TextButton", top)
					hitbox.Size = UDim2.new(1, 0, 1, 0)
					hitbox.BackgroundTransparency = 1
					hitbox.Text = ""
					hitbox.AutoButtonColor = false
					hitbox.ZIndex = 13

					local expanded = true
					local originalSize = base.Size
					hitbox.MouseButton1Click:Connect(function()
						PlaySound("Click")
						expanded = not expanded
						Tween(chevron, TweenInfo.new(0.2), {Rotation = expanded and 90 or 0})
						if expanded then
							Tween(base, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = originalSize})
							for _, child in ipairs(card:GetChildren()) do
								if child ~= top and child:IsA("GuiObject") then
									child.Visible = true
								end
							end
						else
							Tween(base, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.fromOffset(Config.ColumnWidth, 40)})
							task.delay(0.3, function()
								if not expanded then
									for _, child in ipairs(card:GetChildren()) do
										if child ~= top and child:IsA("GuiObject") then
											child.Visible = false
										end
									end
								end
							end)
						end
					end)
				end

				if settings.Toggle ~= nil then
					result.Toggle = makeToggle(top, {
						Default = settings.Toggle,
						Callback = settings.ToggleCallback,
						Flag = settings.Flag,
						Tooltip = settings.Tooltip
					})
				end
				top.Parent = card

				local actLabel = Instance.new("TextLabel", card)
				actLabel.Text = "Actions"
				actLabel.FontFace = Font.new(Config.Font)
				actLabel.TextColor3 = CurrentTheme.TextDimColor
				actLabel.TextSize = Config.SubSize
				actLabel.TextTransparency = 0.3
				actLabel.BackgroundTransparency = 1
				actLabel.Size = UDim2.new(1,0,0,12)
				actLabel.ZIndex = 10
				table.insert(ThemeElements, {Object = actLabel, Role = "TextDim"})

				local btnRow = Instance.new("Frame", card)
				btnRow.Size = UDim2.new(1,0,0,36)
				btnRow.BackgroundTransparency = 1
				btnRow.ZIndex = 10

				if settings.Buttons and #settings.Buttons > 0 then
					local n = #settings.Buttons
					for i, bData in ipairs(settings.Buttons) do
						if bData.Label then table.insert(searchTags, bData.Label) end
						local frac = (i - 0.5) / n
						local group = Instance.new("Frame")
						group.BackgroundTransparency = 1
						group.Size = UDim2.fromOffset(Config.ModuleButtonSize, 44)
						group.Position = UDim2.new(frac, 0, 0, 0)
						group.AnchorPoint = Vector2.new(0.5, 0)
						group.ZIndex = 10
						group.Parent = btnRow

						local ib = Instance.new("ImageButton", group)
						ib.Size = UDim2.fromOffset(Config.ModuleButtonSize, Config.ModuleButtonSize)
						ib.Position = UDim2.fromScale(0.5,0)
						ib.AnchorPoint = Vector2.new(0.5,0)
						ib.BackgroundTransparency = 1
						ib.Image = ResolveIcon(bData.Icon) or ""
						ib.AutoButtonColor = false
						ib.ZIndex = 11

						local fill = Instance.new("Frame", ib)
						fill.BackgroundColor3 = bData.Active and CurrentTheme.IconBtnActive or CurrentTheme.IconBtnInactive
						fill.BackgroundTransparency = bData.Active and CurrentTheme.IconBtnActiveTransparency or CurrentTheme.IconBtnInactiveTransparency
						fill.Size = UDim2.new(1,0,1,0)
						fill.BorderSizePixel = 0
						fill:SetAttribute("Active", bData.Active)
						fill.ZIndex = 10
						local role = bData.Active and "IconBtnActive" or "IconBtnInactive"
						table.insert(ThemeElements, {Object = fill, Role = role})
						Instance.new("UICorner", fill).CornerRadius = UDim.new(0, Config.ModuleButtonSize/2)
						local st = Instance.new("UIStroke", fill)
						st.Color = CurrentTheme.StrokeColor
						st.Transparency = CurrentTheme.StrokeTransparency
						st.ZIndex = 12
						table.insert(ThemeElements, {Object = st, Role = "Stroke"})

						local lbl = Instance.new("TextLabel", group)
						lbl.Text = bData.Label
						lbl.FontFace = Font.new(Config.Font)
						lbl.TextColor3 = CurrentTheme.TextColor
						lbl.TextSize = Config.SubSize
						lbl.TextTransparency = 0.2
						lbl.BackgroundTransparency = 1
						lbl.Size = UDim2.new(1,0,0,12)
						lbl.Position = UDim2.new(0.5,0,1,-10)
						lbl.AnchorPoint = Vector2.new(0.5,1)
						lbl.TextXAlignment = Enum.TextXAlignment.Center
						lbl.ZIndex = 11
						table.insert(ThemeElements, {Object = lbl, Role = "Text"})

						local btnElement = {
							Value = bData.Active,
							Flag = bData.Flag,
							Type = "ModuleButton",
							Default = bData.Active,
							_connections = {},
							Instance = ib
						}
						if bData.Flag then
							MacLib.Elements[bData.Flag] = btnElement
						end
						function btnElement:Highlight()
							FlashHighlight(ib)
						end

						function btnElement:Set(newValue)
							if typeof(newValue) ~= "boolean" then return end
							fill:SetAttribute("Active", newValue)
							fill.BackgroundColor3 = newValue and CurrentTheme.IconBtnActive or CurrentTheme.IconBtnInactive
							fill.BackgroundTransparency = newValue and CurrentTheme.IconBtnActiveTransparency or CurrentTheme.IconBtnInactiveTransparency
							for _, v in ipairs(ThemeElements) do
								if v.Object == fill then
									v.Role = newValue and "IconBtnActive" or "IconBtnInactive"
								end
							end
							btnElement.Value = newValue
							print("[MacLib] ModuleButton '" .. tostring(bData.Label or "unnamed") .. "' = " .. tostring(newValue))
							if bData.Callback then bData.Callback(newValue) end
						end
						function btnElement:Destroy()
							CleanupThemeElements(fill)
							CleanupThemeElements(st)
							CleanupThemeElements(lbl)
							CleanupThemeElements(ib)
							if ib then ib:Destroy() end
							if btnElement.Flag then MacLib.Elements[btnElement.Flag] = nil end
						end

						ib.MouseButton1Click:Connect(function()
							PlaySound("Click")
							btnElement:Set(not fill:GetAttribute("Active"))
						end)
						if bData.Tooltip then AttachTooltip(ib, bData.Tooltip) end

						table.insert(result.Buttons, btnElement)
					end
				end

				base:SetAttribute("SearchTags", table.concat(searchTags, " "):lower())
				base.Parent = col
				return result
			end

			function SectionFunctions:ListCard(settings)
				settings = settings or {}
				local targetPage
				if #subtabData > 0 then
					local idx = settings.SubtabIndex or 1
					targetPage = subtabData[idx] and subtabData[idx].page or subtabData[1].page
				else
					targetPage = page
				end

				local base, card = MakeGlass(Config.ColumnWidth, settings.Height or 80)
				local pad = Instance.new("UIPadding", card)
				pad.PaddingLeft = UDim.new(0, 10)
				pad.PaddingRight = UDim.new(0, 10)
				pad.PaddingTop = UDim.new(0, 8)
				pad.PaddingBottom = UDim.new(0, 8)

				local listLayout = Instance.new("UIListLayout", card)
				listLayout.Padding = UDim.new(0, 1)
				listLayout.SortOrder = Enum.SortOrder.LayoutOrder

				local function updateHeight()
					local contentHeight = listLayout.AbsoluteContentSize.Y
					base.Size = UDim2.fromOffset(Config.ColumnWidth, contentHeight + 16)
				end

				if not settings.Height then
					listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateHeight)
					card.ChildAdded:Connect(function() task.defer(updateHeight) end)
				end

				base.Parent = col

				if settings.Collapsible and settings.Title then
					local headerHeight = 28
					local header = Instance.new("Frame")
					header.Name = "CollapseHeader"
					header.Size = UDim2.new(1, 0, 0, headerHeight)
					header.BackgroundTransparency = 1
					header.ZIndex = 15
					header.LayoutOrder = -1

					local titleLabel = Instance.new("TextLabel", header)
					titleLabel.Text = settings.Title
					titleLabel.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
					titleLabel.TextColor3 = CurrentTheme.TextColor
					titleLabel.TextSize = 13
					titleLabel.TextTransparency = 0.1
					titleLabel.BackgroundTransparency = 1
					titleLabel.Size = UDim2.new(1, -30, 1, 0)
					titleLabel.Position = UDim2.new(0, 0, 0, 0)
					titleLabel.TextXAlignment = Enum.TextXAlignment.Left
					titleLabel.ZIndex = 16
					table.insert(ThemeElements, {Object = titleLabel, Role = "Text"})

					local chevron = Instance.new("ImageLabel", header)
					chevron.Image = ResolveIcon(Icons.chevron)
					chevron.ImageColor3 = CurrentTheme.TextColor
					chevron.ImageTransparency = 0.3
					chevron.BackgroundTransparency = 1
					chevron.Size = UDim2.fromOffset(14, 14)
					chevron.Position = UDim2.new(1, -20, 0.5, -7)
					chevron.Rotation = 90
					chevron.ZIndex = 16

					local hitbox = Instance.new("TextButton", header)
					hitbox.Size = UDim2.new(1, 0, 1, 0)
					hitbox.BackgroundTransparency = 1
					hitbox.Text = ""
					hitbox.AutoButtonColor = false
					hitbox.ZIndex = 17

					header.Parent = card

					local expanded = true
					local originalSize = base.Size
					hitbox.MouseButton1Click:Connect(function()
						PlaySound("Click")
						expanded = not expanded
						Tween(chevron, TweenInfo.new(0.2), {Rotation = expanded and 90 or 0})
						if expanded then
							Tween(base, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = originalSize})
							for _, child in ipairs(card:GetChildren()) do
								if child ~= header and child:IsA("GuiObject") and child.Name ~= "UICorner" and child.Name ~= "UIStroke" then
									child.Visible = true
								end
							end
						else
							Tween(base, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.fromOffset(Config.ColumnWidth, headerHeight + 8)})
							task.delay(0.3, function()
								if not expanded then
									for _, child in ipairs(card:GetChildren()) do
										if child ~= header and child:IsA("GuiObject") then
											child.Visible = false
										end
									end
								end
							end)
						end
					end)
				end

				local List = {}
				local layoutOrder = 0
				local listSearchTags = {}
				local function nextOrder()
					layoutOrder = layoutOrder + 1
					return layoutOrder
				end

				local function refreshSearchTags()
					base:SetAttribute("SearchTags", table.concat(listSearchTags, " "):lower())
				end

				local function makeRow(height)
					local row = Instance.new("Frame")
					row.BackgroundTransparency = 1
					row.Size = UDim2.new(1, 0, 0, height or 32)
					row.LayoutOrder = nextOrder()
					return row
				end

				local function makeLabel(parent, text, dim)
					local label = Instance.new("TextLabel", parent)
					label.Text = text or ""
					label.FontFace = Font.new(Config.Font, dim and Enum.FontWeight.Regular or Enum.FontWeight.Medium)
					label.TextColor3 = dim and CurrentTheme.TextDimColor or CurrentTheme.TextColor
					label.TextSize = dim and Config.SubSize or Config.NormalSize
					label.TextTransparency = dim and 0.35 or 0.15
					label.BackgroundTransparency = 1
					label.Size = UDim2.new(1, -90, 1, 0)
					label.TextXAlignment = Enum.TextXAlignment.Left
					label.TextTruncate = Enum.TextTruncate.AtEnd
					label.ZIndex = 10
					label.RichText = true
					table.insert(ThemeElements, {Object = label, Role = dim and "TextDim" or "Text"})
					return label
				end

				function List:AddDivider(text)
					local row = makeRow(text and 24 or 6)
					row.BackgroundTransparency = 1
					local dividerLabel = nil

					if text and text ~= "" then
						local leftLine = Instance.new("Frame", row)
						leftLine.BackgroundColor3 = CurrentTheme.StrokeColor
						leftLine.BackgroundTransparency = 0.7
						leftLine.BorderSizePixel = 0
						leftLine.Size = UDim2.new(0.5, -30, 0, 1)
						leftLine.Position = UDim2.new(0, 0, 0.5, -0.5)
						leftLine.ZIndex = 10

						dividerLabel = Instance.new("TextLabel", row)
						dividerLabel.Text = text
						dividerLabel.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
						dividerLabel.TextColor3 = CurrentTheme.TextDimColor
						dividerLabel.TextSize = 10
						dividerLabel.TextTransparency = 0.4
						dividerLabel.BackgroundTransparency = 1
						dividerLabel.Size = UDim2.fromOffset(60, 14)
						dividerLabel.Position = UDim2.new(0.5, -30, 0.5, -7)
						dividerLabel.TextXAlignment = Enum.TextXAlignment.Center
						dividerLabel.ZIndex = 11
						table.insert(ThemeElements, {Object = dividerLabel, Role = "TextDim"})

						local rightLine = Instance.new("Frame", row)
						rightLine.BackgroundColor3 = CurrentTheme.StrokeColor
						rightLine.BackgroundTransparency = 0.7
						rightLine.BorderSizePixel = 0
						rightLine.Size = UDim2.new(0.5, -30, 0, 1)
						rightLine.Position = UDim2.new(0.5, 30, 0.5, -0.5)
						rightLine.ZIndex = 10
					else
						local line = Instance.new("Frame", row)
						line.BackgroundColor3 = CurrentTheme.StrokeColor
						line.BackgroundTransparency = 0.85
						line.BorderSizePixel = 0
						line.Size = UDim2.new(1, 0, 0, 1)
						line.Position = UDim2.new(0, 0, 0.5, -0.5)
						line.ZIndex = 10
					end

					row.Parent = card
					
					local element = {
						Instance = row,
						Type = "Divider",
						Destroy = function(self)
							CleanupThemeElements(dividerLabel)
							if row then row:Destroy() end
						end
					}
					return element
				end

				function List:AddToggle(data)
					data = data or {}
					local row = makeRow(32)
					makeLabel(row, data.Name)
					local flag = data.Flag or data.ConfigId
					local rawDefault = data.Default
					if typeof(rawDefault) ~= "boolean" then rawDefault = false end
					local saved = flag and MacLib.ConfigData[flag]
					if saved == nil then saved = rawDefault end
					if typeof(saved) ~= "boolean" then saved = false end

					local toggleElement = makeToggle(row, {
						Default = rawDefault,
						Callback = data.Callback,
						Flag = flag,
						Tooltip = data.Tooltip
					})
					row.Parent = card

					if data.Name then table.insert(listSearchTags, data.Name) end
					refreshSearchTags()
					return toggleElement
				end

				function List:AddLockedToggle(data)
					data = data or {}
					local row = makeRow(32)
					makeLabel(row, data.Name)

					local lock = Instance.new("ImageLabel", row)
					lock.Image = ResolveIcon(Icons.lock)
					lock.ImageTransparency = 0.4
					lock.BackgroundTransparency = 1
					lock.Size = UDim2.fromOffset(13, 13)
					lock.Position = UDim2.new(1, -64, 0.5, -6)
					lock.ZIndex = 10

					local track = Instance.new("Frame", row)
					track.Size = UDim2.fromOffset(Config.ToggleWidth, Config.ToggleHeight)
					track.Position = UDim2.new(1, -Config.ToggleWidth-6, 0.5, -Config.ToggleHeight/2)
					track.BackgroundColor3 = CurrentTheme.ToggleOff
					track.BackgroundTransparency = 0.5
					track.BorderSizePixel = 0
					track.ZIndex = 5
					Instance.new("UICorner", track).CornerRadius = UDim.new(0, Config.ToggleHeight/2)

					local knob = Instance.new("Frame", track)
					knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
					knob.BackgroundTransparency = 0.5
					knob.Size = UDim2.fromOffset(Config.ToggleKnob, Config.ToggleKnob)
					knob.Position = UDim2.new(0, 2, 0.5, -Config.ToggleKnob/2)
					knob.ZIndex = 7
					Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

					row.Parent = card

					local element = {
						Value = false,
						Flag = data.Flag,
						Type = "LockedToggle",
						Default = false,
						Instance = row
					}
					if data.Flag then MacLib.Elements[data.Flag] = element end
					function element:Highlight()
						FlashHighlight(row)
					end

					function element:Set() end
					function element:Destroy()
						if row then row:Destroy() end
						if element.Flag then MacLib.Elements[element.Flag] = nil end
					end

					if data.Name then table.insert(listSearchTags, data.Name) end
					refreshSearchTags()
					return element
				end

							function List:AddSlider(data)
				data = data or {}
				local min = data.Min or 0
				local max = data.Max or 100
				local flag = data.Flag or data.ConfigId
				local rawDef = data.Default or min
				local def = flag and MacLib.ConfigData[flag]
				if def == nil then def = rawDef end
				def = math.clamp(def, min, max)
				local increment = data.Increment or 0
				local suffix = data.Suffix or ""
				if increment > 0 then
					def = math.round(def / increment) * increment
				end
				local alpha = (def - min) / (max - min)

				local row = makeRow(32)
				local label = makeLabel(row, data.Name)

				local valBox = Instance.new("TextLabel", row)
				valBox.Text = tostring(math.floor(def)) .. suffix
				valBox.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
				valBox.TextColor3 = CurrentTheme.TextColor
				valBox.TextSize = 11
				valBox.BackgroundColor3 = CurrentTheme.CardBackColor
				valBox.BackgroundTransparency = 0.3
				valBox.BorderSizePixel = 0
				valBox.Size = UDim2.fromOffset(44, 22)
				valBox.Position = UDim2.new(1, -48, 0.5, -11)
				valBox.TextXAlignment = Enum.TextXAlignment.Center
				valBox.ZIndex = 10
				Instance.new("UICorner", valBox).CornerRadius = UDim.new(0, 5)

				local trackWidth = 65
				local track = Instance.new("Frame", row)
				track.Size = UDim2.fromOffset(trackWidth, 4)
				track.Position = UDim2.new(1, -trackWidth-56, 0.5, -2)
				track.BackgroundColor3 = CurrentTheme.SliderBg
				track.BorderSizePixel = 0
				track.ZIndex = 5
				Instance.new("UICorner", track).CornerRadius = UDim.new(0, 2)
				table.insert(ThemeElements, {Object = track, Role = "SliderBg"})

				local fill = Instance.new("Frame", track)
				fill.Size = UDim2.new(alpha, 0, 1, 0)
				fill.BackgroundColor3 = CurrentTheme.SliderFill
				fill.BorderSizePixel = 0
				fill.ZIndex = 6
				Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
				table.insert(ThemeElements, {Object = fill, Role = "SliderFill"})

				local knob = Instance.new("Frame", track)
				knob.Size = UDim2.fromOffset(12, 12)
				knob.Position = UDim2.new(alpha, -6, 0.5, -6)
				knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
				knob.ZIndex = 7
				Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

				-- Drag tooltip
				local dragTooltip = Instance.new("TextLabel", track)
				dragTooltip.BackgroundColor3 = CurrentTheme.DropdownBg
				dragTooltip.BackgroundTransparency = 0.1
				dragTooltip.BorderSizePixel = 0
				dragTooltip.TextColor3 = CurrentTheme.TextColor
				dragTooltip.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
				dragTooltip.TextSize = 9
				dragTooltip.Text = tostring(math.floor(def)) .. suffix
				dragTooltip.Size = UDim2.fromOffset(36, 16)
				dragTooltip.Position = UDim2.new(alpha, -18, 0, -20)
				dragTooltip.Visible = false
				dragTooltip.ZIndex = 10
				Instance.new("UICorner", dragTooltip).CornerRadius = UDim.new(0, 4)

				local drag = false
				local currentValue = def

				local element = {
					Value = currentValue,
					Flag = flag,
					Type = "Slider",
					Default = rawDef,
					_connections = {},
					Instance = track
				}
				if flag then MacLib.Elements[flag] = element end

				local function formatVal(val)
					if increment > 0 then
						val = math.round(val / increment) * increment
					end
					return val
				end

				local function displayVal(val)
					return tostring(math.floor(val)) .. suffix
				end

				local function updateVisual(rel)
					fill.Size = UDim2.new(rel, 0, 1, 0)
					knob.Position = UDim2.new(rel, -6, 0.5, -6)
					dragTooltip.Position = UDim2.new(rel, -18, 0, -20)
					dragTooltip.Text = displayVal(currentValue)
				end

				local function updateFromInput(x)
					local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					updateVisual(rel)
					currentValue = min + (max - min) * rel
					currentValue = formatVal(currentValue)
					element.Value = currentValue
					valBox.Text = displayVal(currentValue)
					if flag then SetConfigValue(flag, currentValue) end
					print("[MacLib] ListSlider '" .. tostring(data.Name or "unnamed") .. "' = " .. displayVal(currentValue))
					if data.Callback then data.Callback(currentValue) end
				end

				local conn1 = track.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						drag = true
						-- Scale up knob on drag start
						Tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
							Size = UDim2.fromOffset(16, 16)
						})
						dragTooltip.Visible = true
						updateFromInput(inp.Position.X)
					end
				end)
				local conn2 = UserInputService.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						if drag then
							drag = false
							-- Scale back knob on release
							Tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
								Size = UDim2.fromOffset(12, 12)
							})
							dragTooltip.Visible = false
						end
					end
				end)
				local conn3 = UserInputService.InputChanged:Connect(function(inp)
					if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
						updateFromInput(inp.Position.X)
					end
				end)
				table.insert(element._connections, conn1)
				table.insert(element._connections, conn2)
				table.insert(element._connections, conn3)

				AddTouchHitbox(track, row, function(inp)
					drag = true
					-- Scale up knob on drag start
					Tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Size = UDim2.fromOffset(16, 16)
					})
					dragTooltip.Visible = true
					updateFromInput(inp.Position.X)
				end)

				function element:Set(newValue)
					local num = tonumber(newValue)
					if not num then return end
					num = math.clamp(num, min, max)
					if increment > 0 then
						num = math.round(num / increment) * increment
					end
					if currentValue == num then return end
					currentValue = num
					element.Value = currentValue
					local rel = (num - min) / (max - min)
					updateVisual(rel)
					valBox.Text = displayVal(num)
					if flag then SetConfigValue(flag, currentValue) end
					print("[MacLib] ListSlider '" .. tostring(data.Name or "unnamed") .. "' = " .. displayVal(currentValue))
					if data.Callback then data.Callback(currentValue) end
				end

				function element:Highlight()
					FlashHighlight(row)
				end

				function element:Destroy()
					for _, conn in ipairs(element._connections) do
						if conn then pcall(function() conn:Disconnect() end) end
					end
					CleanupThemeElements(track)
					CleanupThemeElements(fill)
					CleanupThemeElements(knob)
					CleanupThemeElements(valBox)
					if row then row:Destroy() end
					if flag then MacLib.Elements[flag] = nil end
				end

				if currentValue ~= (data.Default or min) then
					element:Set(currentValue)
				end

				row.Parent = card
				if data.Name then table.insert(listSearchTags, data.Name) end
				refreshSearchTags()
				if data.Tooltip then AttachTooltip(row, data.Tooltip) end
				return element
			end

function List:AddDropdown(data)
					data = data or {}
					local row = makeRow(32)
					local label = makeLabel(row, data.Name .. (data.Value and (" • " .. (typeof(data.Value) == "table" and (#data.Value > 0 and data.Value[1] .. "..." or "") or tostring(data.Value))) or ""))

					local btnBg = Instance.new("Frame", row)
					btnBg.Size = UDim2.fromOffset(32, 32)
					btnBg.Position = UDim2.new(1, -34, 0.5, -16)
					btnBg.BackgroundColor3 = CurrentTheme.CardBackColor
					btnBg.BackgroundTransparency = 0.3
					btnBg.BorderSizePixel = 0
					btnBg.ZIndex = 11
					Instance.new("UICorner", btnBg).CornerRadius = UDim.new(0, 8)

					local btnHit = Instance.new("TextButton", btnBg)
					btnHit.Size = UDim2.new(1, 0, 1, 0)
					btnHit.BackgroundTransparency = 1
					btnHit.Text = ""
					btnHit.AutoButtonColor = false
					btnHit.ZIndex = 13

					local gridIcon = Instance.new("Frame", btnBg)
					gridIcon.Size = UDim2.fromOffset(10, 10)
					gridIcon.Position = UDim2.new(0.5, -5, 0.5, -5)
					gridIcon.BackgroundTransparency = 1
					gridIcon.ZIndex = 12
					for i = 0, 8 do
						local dot = Instance.new("Frame", gridIcon)
						dot.Size = UDim2.fromOffset(2, 2)
						dot.Position = UDim2.new(0, (i % 3) * 3 + 1, 0, math.floor(i / 3) * 3 + 1)
						dot.BackgroundColor3 = CurrentTheme.TextColor
						dot.BackgroundTransparency = 0.3
						dot.BorderSizePixel = 0
						Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
					end

					row.Parent = card

					local flag = data.Flag or data.ConfigId
					local rawDefault
					if data.Multi then
						rawDefault = typeof(data.Value) == "table" and table.clone(data.Value) or (typeof(data.Value) == "string" and {data.Value} or {})
					else
						rawDefault = data.Value or (data.Options and data.Options[1]) or nil
					end

					local optsFrame = Instance.new("Frame")
					optsFrame.Name = "DropdownOpts_" .. tostring(math.random(100000, 999999))
					optsFrame.LayoutOrder = nextOrder()
					optsFrame.BackgroundColor3 = CurrentTheme.DropdownBg
					optsFrame.BackgroundTransparency = 0.02
					optsFrame.BorderSizePixel = 0
					optsFrame.Size = UDim2.fromOffset(180, 0)
					optsFrame.Visible = false
					optsFrame.ZIndex = 20
					Instance.new("UICorner", optsFrame).CornerRadius = UDim.new(0, 8)
					local optsStroke = Instance.new("UIStroke", optsFrame)
					optsStroke.Color = CurrentTheme.StrokeColor
					optsStroke.Transparency = 0.4
					optsStroke.Thickness = 1

					local optsList = Instance.new("UIListLayout", optsFrame)
					optsList.Padding = UDim.new(0, 0)
					optsList.SortOrder = Enum.SortOrder.LayoutOrder

					local searchBox
					if data.Search then
						local searchRow = Instance.new("Frame", optsFrame)
						searchRow.BackgroundTransparency = 1
						searchRow.Size = UDim2.new(1, 0, 0, 28)
						searchRow.LayoutOrder = 0

						local sIcon = Instance.new("ImageLabel", searchRow)
						sIcon.Image = ResolveIcon(Icons.search)
						sIcon.ImageTransparency = 0.5
						sIcon.BackgroundTransparency = 1
						sIcon.Size = UDim2.fromOffset(11, 11)
						sIcon.Position = UDim2.new(0, 8, 0.5, -5)
						sIcon.ZIndex = 21

						searchBox = Instance.new("TextBox", searchRow)
						searchBox.Size = UDim2.new(1, -26, 1, 0)
						searchBox.Position = UDim2.new(0, 24, 0, 0)
						searchBox.BackgroundTransparency = 1
						searchBox.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
						searchBox.TextColor3 = CurrentTheme.TextColor
						searchBox.TextSize = 11
						searchBox.PlaceholderText = "Search..."
						searchBox.Text = ""
						searchBox.TextXAlignment = Enum.TextXAlignment.Left
						searchBox.TextTruncate = Enum.TextTruncate.AtEnd
						searchBox.ZIndex = 21
						table.insert(ThemeElements, {Object = searchBox, Role = "Text"})
					end

					local optionButtons = {}
					local selectedOption
					local selectedOptions = {}

					if data.Multi then
						local initial = data.Value
						if typeof(initial) == "table" then
							selectedOptions = table.clone(initial)
						elseif typeof(initial) == "string" then
							table.insert(selectedOptions, initial)
						end
						if flag and MacLib.ConfigData[flag] ~= nil then
							local saved = MacLib.ConfigData[flag]
							if typeof(saved) == "table" then
								selectedOptions = table.clone(saved)
							end
						end
					else
						selectedOption = data.Value or (data.Options and data.Options[1]) or nil
						if flag and MacLib.ConfigData[flag] ~= nil then
							selectedOption = MacLib.ConfigData[flag]
						end
					end

					local element = {
						Value = data.Multi and selectedOptions or selectedOption,
						Flag = flag,
						Type = data.Multi and "MultiDropdown" or "Dropdown",
						Default = rawDefault,
						_connections = {},
						Instance = row
					}
					if flag then MacLib.Elements[flag] = element end

					local function updateLabel()
						if data.Multi then
							if #selectedOptions == 0 then
								label.Text = data.Name
							elseif #selectedOptions == 1 then
								label.Text = data.Name .. " • " .. selectedOptions[1]
							else
								label.Text = data.Name .. " • " .. #selectedOptions .. " selected"
							end
						else
							label.Text = data.Name .. (selectedOption and (" • " .. selectedOption) or "")
						end
					end

					local function positionOptsFrame()
						if not optsFrame.Parent or optsFrame.Parent == card then return end
						local absPos = btnHit.AbsolutePosition
						local absSize = btnHit.AbsoluteSize
						local viewport = workspace.CurrentCamera.ViewportSize
						local frameWidth = 180
						local frameHeight = optsFrame.AbsoluteSize.Y
						local x = absPos.X + absSize.X - frameWidth
						local y = absPos.Y + absSize.Y + 2
						if x < 4 then x = 4 end
						if x + frameWidth > viewport.X - 4 then x = viewport.X - frameWidth - 4 end
						if y + frameHeight > viewport.Y - 4 then
							y = absPos.Y - frameHeight - 2
						end
						optsFrame.Position = UDim2.fromOffset(x, y)
					end

					local function buildOptions(filter)
						for _, ob in ipairs(optionButtons) do
							ob:Destroy()
						end
						optionButtons = {}

						local startIdx = data.Search and 1 or 0
						for i, opt in ipairs(data.Options or {}) do
							if filter and filter ~= "" then
								if not string.find(opt:lower(), filter:lower()) then continue end
							end
							local optBtn = Instance.new("TextButton", optsFrame)
							optBtn.LayoutOrder = startIdx + i
							if data.Multi then
								local isSelected = table.find(selectedOptions, opt) ~= nil
								optBtn.Text = (isSelected and "☑ " or "☐ ") .. opt
							else
								optBtn.Text = (opt == selectedOption and "✓ " or "    ") .. opt
							end
							optBtn.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
							optBtn.TextColor3 = CurrentTheme.TextColor
							optBtn.TextSize = 12
							optBtn.BackgroundTransparency = 1
							optBtn.Size = UDim2.new(1, 0, 0, 28)
							optBtn.AutoButtonColor = false
							optBtn.ZIndex = 21
							table.insert(ThemeElements, {Object = optBtn, Role = "Text"})

							optBtn.MouseEnter:Connect(function()
								optBtn.BackgroundTransparency = 0.85
								optBtn.BackgroundColor3 = CurrentTheme.SelectionColor
							end)
							optBtn.MouseLeave:Connect(function()
								optBtn.BackgroundTransparency = 1
							end)

							optBtn.MouseButton1Click:Connect(function()
								if data.Multi then
									local idx = table.find(selectedOptions, opt)
									if idx then
										table.remove(selectedOptions, idx)
									else
										table.insert(selectedOptions, opt)
									end
									buildOptions(filter)
									element.Value = selectedOptions
									updateLabel()
									if flag then SetConfigValue(flag, selectedOptions) end
									print("[MacLib] MultiDropdown '" .. tostring(data.Name or "unnamed") .. "' = " .. table.concat(selectedOptions, ", "))
									if data.Callback then data.Callback(selectedOptions) end
								else
									selectedOption = opt
									element.Value = opt
									updateLabel()
									optsFrame.Visible = false
									optsFrame.Parent = card
									updateHeight()
									if flag then SetConfigValue(flag, opt) end
									print("[MacLib] Dropdown '" .. tostring(data.Name or "unnamed") .. "' = " .. tostring(opt))
									if data.Callback then data.Callback(opt) end
								end
							end)

							table.insert(optionButtons, optBtn)
						end

						if data.Multi then
							local clearBtn = Instance.new("TextButton", optsFrame)
							clearBtn.LayoutOrder = 1000
							clearBtn.Text = "Clear All"
							clearBtn.FontFace = Font.new(Config.Font, Enum.FontWeight.SemiBold)
							clearBtn.TextColor3 = CurrentTheme.NotificationError
							clearBtn.TextSize = 12
							clearBtn.BackgroundTransparency = 0.9
							clearBtn.BackgroundColor3 = CurrentTheme.NotificationError
							clearBtn.Size = UDim2.new(1, 0, 0, 28)
							clearBtn.AutoButtonColor = false
							clearBtn.ZIndex = 21
							Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)

							clearBtn.MouseEnter:Connect(function()
								clearBtn.BackgroundTransparency = 0.7
							end)
							clearBtn.MouseLeave:Connect(function()
								clearBtn.BackgroundTransparency = 0.9
							end)

							clearBtn.MouseButton1Click:Connect(function()
								for k in pairs(selectedOptions) do selectedOptions[k] = nil end
								buildOptions(filter)
								element.Value = selectedOptions
								updateLabel()
								if flag then SetConfigValue(flag, selectedOptions) end
								if data.Callback then data.Callback(selectedOptions) end
							end)
							table.insert(optionButtons, clearBtn)
						end

						task.defer(function()
							local h = optsList.AbsoluteContentSize.Y
							optsFrame.Size = UDim2.fromOffset(180, h)
							positionOptsFrame()
						end)
					end

					buildOptions()

					if searchBox then
						searchBox:GetPropertyChangedSignal("Text"):Connect(function()
							buildOptions(searchBox.Text)
						end)
					end

					local open = false
					local conn = btnHit.MouseButton1Click:Connect(function()
						PlaySound("Click")
						open = not open
						if open then
							optsFrame.Parent = MacLib.OverlayGui or card
							optsFrame.Visible = true
							buildOptions(searchBox and searchBox.Text or nil)
							positionOptsFrame()
						else
							optsFrame.Visible = false
							optsFrame.Parent = card
						end
						updateHeight()
					end)
					table.insert(element._connections, conn)

					local closeConn = UserInputService.InputBegan:Connect(function(inp, gpe)
						if gpe then return end
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							if open and optsFrame.Visible then
								local mousePos = UserInputService:GetMouseLocation()
								local absPos = optsFrame.AbsolutePosition
								local absSize = optsFrame.AbsoluteSize
								local btnPos = btnHit.AbsolutePosition
								local btnSize = btnHit.AbsoluteSize
								local inFrame = mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X
									and mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y
								local inBtn = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X
									and mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
								if not inFrame and not inBtn then
									open = false
									optsFrame.Visible = false
									optsFrame.Parent = card
									updateHeight()
								end
							end
						end
					end)
					table.insert(element._connections, closeConn)

					function element:Set(newValue)
						if data.Multi then
							if typeof(newValue) ~= "table" then return end
							selectedOptions = table.clone(newValue)
							element.Value = selectedOptions
							updateLabel()
							optsFrame.Visible = false
							optsFrame.Parent = card
							updateHeight()
							if flag then SetConfigValue(flag, selectedOptions) end
							print("[MacLib] MultiDropdown '" .. tostring(data.Name or "unnamed") .. "' = " .. table.concat(selectedOptions, ", "))
							if data.Callback then data.Callback(selectedOptions) end
						else
							if typeof(newValue) ~= "string" then return end
							local found = false
							for _, opt in ipairs(data.Options or {}) do
								if opt == newValue then found = true; break end
							end
							if not found then return end
							selectedOption = newValue
							element.Value = newValue
							updateLabel()
							optsFrame.Visible = false
							optsFrame.Parent = card
							updateHeight()
							if flag then SetConfigValue(flag, newValue) end
							print("[MacLib] Dropdown '" .. tostring(data.Name or "unnamed") .. "' = " .. tostring(newValue))
							if data.Callback then data.Callback(newValue) end
						end
					end

					function element:Highlight()
						FlashHighlight(row)
					end

					function element:Destroy()
						for _, conn in ipairs(element._connections) do
							if conn then pcall(function() conn:Disconnect() end) end
						end
						for _, ob in ipairs(optionButtons) do
							CleanupThemeElements(ob)
						end
						CleanupThemeElements(label)
						if optsFrame then optsFrame:Destroy() end
						if row then row:Destroy() end
						if flag then MacLib.Elements[flag] = nil end
					end

					if data.Multi then
						if #selectedOptions > 0 or (data.Value and typeof(data.Value) == "table" and #data.Value > 0) then
							element:Set(selectedOptions)
						end
					else
						if selectedOption ~= data.Value then
							element:Set(selectedOption)
						end
					end

					if data.Name then table.insert(listSearchTags, data.Name) end
					for _, opt in ipairs(data.Options or {}) do
						table.insert(listSearchTags, opt)
					end
					refreshSearchTags()
					if data.Tooltip then AttachTooltip(row, data.Tooltip) end
					return element
				end function List:AddTextBox(data)
					data = data or {}
					local row = makeRow(32)
					makeLabel(row, data.Name)

					local box = Instance.new("TextBox", row)
					box.Size = UDim2.fromOffset(90, 26)
					box.Position = UDim2.new(1, -94, 0.5, -13)
					box.BackgroundColor3 = CurrentTheme.CardBackColor
					box.BackgroundTransparency = 0.3
					box.BorderSizePixel = 0
					box.TextColor3 = CurrentTheme.TextColor
					box.PlaceholderText = data.Placeholder or ""
					box.Text = data.Default or ""
					box.TextSize = 11
					box.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
					box.TextXAlignment = Enum.TextXAlignment.Center
					box.TextTruncate = Enum.TextTruncate.AtEnd
					box.ClearTextOnFocus = false
					box.ZIndex = 10
					Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
					table.insert(ThemeElements, {Object = box, Role = "Text"})

					local boxStroke = Instance.new("UIStroke", box)
					boxStroke.Color = CurrentTheme.StrokeColor
					boxStroke.Transparency = 0.5
					boxStroke.Thickness = 1

					local flag = data.Flag or data.ConfigId
					local rawDefault = data.Default or ""
					if flag and MacLib.ConfigData[flag] ~= nil then
						box.Text = tostring(MacLib.ConfigData[flag])
					end

					local element = {
						Value = box.Text,
						Flag = flag,
						Type = "TextBox",
						Default = rawDefault,
						_connections = {},
						Instance = box
					}
					if flag then MacLib.Elements[flag] = element end

					local function shakeBox()
						local basePos = UDim2.new(1, -94, 0.5, -13)
						local left1 = basePos + UDim2.new(0, -3, 0, 0)
						local right1 = basePos + UDim2.new(0, 3, 0, 0)
						local left2 = basePos + UDim2.new(0, -3, 0, 0)

						Tween(box, TweenInfo.new(0.075, Enum.EasingStyle.Quart), {Position = left1})
						Tween(boxStroke, TweenInfo.new(0.075), {Color = Color3.fromRGB(255, 60, 60)})
						task.delay(0.075, function()
							Tween(box, TweenInfo.new(0.075, Enum.EasingStyle.Quart), {Position = right1})
							task.delay(0.075, function()
								Tween(box, TweenInfo.new(0.075, Enum.EasingStyle.Quart), {Position = left2})
								task.delay(0.075, function()
									Tween(box, TweenInfo.new(0.075, Enum.EasingStyle.Quart), {Position = basePos})
									Tween(boxStroke, TweenInfo.new(0.15), {Color = CurrentTheme.StrokeColor})
								end)
							end)
						end)
					end

					local conn = box.FocusLost:Connect(function()
						local valid = true
						if data.Numeric then
							local num = tonumber(box.Text)
							if num == nil then
								valid = false
							else
								if data.Min ~= nil and num < data.Min then valid = false end
								if data.Max ~= nil and num > data.Max then valid = false end
							end
							if not valid then
								shakeBox()
								return
							end
						end
						element.Value = box.Text
						if flag then SetConfigValue(flag, box.Text) end
						print("[MacLib] TextBox '" .. tostring(data.Name or "unnamed") .. "' = " .. tostring(box.Text))
						if data.Callback then data.Callback(box.Text) end
					end)
					table.insert(element._connections, conn)

					function element:Set(newValue)
						if typeof(newValue) ~= "string" then return end
						box.Text = newValue
						element.Value = newValue
						if flag then SetConfigValue(flag, newValue) end
						print("[MacLib] TextBox '" .. tostring(data.Name or "unnamed") .. "' = " .. tostring(newValue))
						if data.Callback then data.Callback(newValue) end
					end

					function element:Highlight()
						FlashHighlight(box)
					end

						function element:Destroy()
							for _, c in ipairs(element._connections) do
								if c then pcall(function() c:Disconnect() end) end
							end
							CleanupThemeElements(label)
							CleanupThemeElements(box)
							if row then row:Destroy() end
							if flag then MacLib.Elements[flag] = nil end
						end

					if box.Text ~= (data.Default or "") then
						element:Set(box.Text)
					end

					row.Parent = card
					if data.Name then table.insert(listSearchTags, data.Name) end
					refreshSearchTags()
					if data.Tooltip then AttachTooltip(row, data.Tooltip) end
					return element
				end function List:AddKeybind(data)
					data = data or {}
					local row = makeRow(32)
					makeLabel(row, data.Name)

					local box = Instance.new("TextButton", row)
					box.Size = UDim2.fromOffset(32, 26)
					box.Position = UDim2.new(1, -36, 0.5, -13)
					box.BackgroundColor3 = CurrentTheme.CardBackColor
					box.BackgroundTransparency = 0.3
					box.BorderSizePixel = 0
					box.TextColor3 = CurrentTheme.TextColor
					box.Text = data.Default or "..."
					box.TextSize = 11
					box.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
					box.AutoButtonColor = false
					box.ZIndex = 10
					Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
					table.insert(ThemeElements, {Object = box, Role = "Text"})

					local flag = data.Flag or data.ConfigId
					local rawDefault = data.Default or "..."
					if flag and MacLib.ConfigData[flag] ~= nil then
						box.Text = tostring(MacLib.ConfigData[flag])
					end

					local element = {
						Value = box.Text,
						Flag = flag,
						Type = "Keybind",
						Default = rawDefault,
						_connections = {},
						Instance = box
					}
					if flag then MacLib.Elements[flag] = element end

					local listening = false
					local conn1 = box.MouseButton1Click:Connect(function()
						PlaySound("Click")
						listening = true
						box.Text = "..."
					end)
					table.insert(element._connections, conn1)

					local conn2 = UserInputService.InputBegan:Connect(function(inp, gpe)
						if listening and not gpe then
							listening = false
							local key = "..."
							if inp.UserInputType == Enum.UserInputType.Keyboard then
								key = inp.KeyCode.Name
							elseif inp.UserInputType == Enum.UserInputType.MouseButton1 then
								key = "MB1"
							elseif inp.UserInputType == Enum.UserInputType.MouseButton2 then
								key = "MB2"
							end
							if key == "Unknown" then key = "..." end
							box.Text = key
							element.Value = key
							if flag then SetConfigValue(flag, key) end
							print("[MacLib] Keybind '" .. tostring(data.Name or "unnamed") .. "' = " .. tostring(key))
							if data.Callback then data.Callback(key) end
						elseif not listening and not gpe then
							local activated = false
							if inp.UserInputType == Enum.UserInputType.Keyboard and box.Text ~= "..." then
								if inp.KeyCode.Name == box.Text then activated = true end
							elseif inp.UserInputType == Enum.UserInputType.MouseButton1 and box.Text == "MB1" then
								activated = true
							elseif inp.UserInputType == Enum.UserInputType.MouseButton2 and box.Text == "MB2" then
								activated = true
							end
							if activated then
								if data.Hold then
									if data.Callback then data.Callback(true) end
								else
									if data.Callback then data.Callback(box.Text) end
								end
							end
						end
					end)
					table.insert(element._connections, conn2)

					if data.Hold then
						local conn3 = UserInputService.InputEnded:Connect(function(inp, gpe)
							if gpe then return end
							local released = false
							if inp.UserInputType == Enum.UserInputType.Keyboard and box.Text ~= "..." then
								if inp.KeyCode.Name == box.Text then released = true end
							elseif inp.UserInputType == Enum.UserInputType.MouseButton1 and box.Text == "MB1" then
								released = true
							elseif inp.UserInputType == Enum.UserInputType.MouseButton2 and box.Text == "MB2" then
								released = true
							end
							if released and data.Callback then
								data.Callback(false)
							end
						end)
						table.insert(element._connections, conn3)
					end

					function element:Set(newValue)
						if typeof(newValue) ~= "string" then return end
						box.Text = newValue
						element.Value = newValue
						if flag then SetConfigValue(flag, newValue) end
						print("[MacLib] Keybind '" .. tostring(data.Name or "unnamed") .. "' = " .. tostring(newValue))
						if data.Callback then data.Callback(newValue) end
					end

					function element:Highlight()
						FlashHighlight(box)
					end

						function element:Destroy()
							for _, c in ipairs(element._connections) do
								if c then pcall(function() c:Disconnect() end) end
							end
							CleanupThemeElements(label)
							CleanupThemeElements(box)
							if row then row:Destroy() end
							if flag then MacLib.Elements[flag] = nil end
						end

					if box.Text ~= (data.Default or "...") then
						element:Set(box.Text)
					end

					row.Parent = card
					if data.Name then table.insert(listSearchTags, data.Name) end
					refreshSearchTags()
					if data.Tooltip then AttachTooltip(row, data.Tooltip) end
					return element
				end

				function List:AddColorPicker(data)
					data = data or {}
					local row = makeRow(32)
					makeLabel(row, data.Name)

					local flag = data.Flag or data.ConfigId
					local rawDefault = data.Default or Color3.fromRGB(255, 0, 0)
					local savedColor = flag and MacLib.ConfigData[flag]
					local currentColor
					if savedColor and typeof(savedColor) == "table" and #savedColor == 3 then
						currentColor = Color3.fromRGB(unpack(savedColor))
					else
						currentColor = rawDefault
					end
					local h, s, v = currentColor:ToHSV()
					h = h * 360

					local preview = Instance.new("TextButton", row)
					preview.Size = UDim2.fromOffset(32, 32)
					preview.Position = UDim2.new(1, -36, 0.5, -16)
					preview.BackgroundColor3 = currentColor
					preview.BorderSizePixel = 0
					preview.Text = ""
					preview.AutoButtonColor = false
					preview.ZIndex = 10
					Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)

					local pickerFrame = Instance.new("Frame", card)
					pickerFrame.LayoutOrder = nextOrder()
					pickerFrame.BackgroundColor3 = CurrentTheme.DropdownBg
					pickerFrame.BackgroundTransparency = 0.02
					pickerFrame.BorderSizePixel = 0
					pickerFrame.Size = UDim2.new(1, 0, 0, 0)
					pickerFrame.Visible = false
					pickerFrame.ZIndex = 20
					Instance.new("UICorner", pickerFrame).CornerRadius = UDim.new(0, 8)
					local pStroke = Instance.new("UIStroke", pickerFrame)
					pStroke.Color = CurrentTheme.StrokeColor
					pStroke.Transparency = 0.4

					local pickerLayout = Instance.new("UIListLayout", pickerFrame)
					pickerLayout.Padding = UDim.new(0, 6)
					pickerLayout.SortOrder = Enum.SortOrder.LayoutOrder

					local topRow = Instance.new("Frame", pickerFrame)
					topRow.BackgroundTransparency = 1
					topRow.Size = UDim2.new(1, 0, 0, 32)
					topRow.LayoutOrder = 0

					local bigPreview = Instance.new("Frame", topRow)
					bigPreview.Size = UDim2.fromOffset(32, 32)
					bigPreview.Position = UDim2.new(0, 0, 0, 0)
					bigPreview.BackgroundColor3 = currentColor
					bigPreview.BorderSizePixel = 0
					bigPreview.ZIndex = 21
					Instance.new("UICorner", bigPreview).CornerRadius = UDim.new(0, 6)

					local hexBox = Instance.new("TextBox", topRow)
					hexBox.Size = UDim2.new(0, 80, 0, 26)
					hexBox.Position = UDim2.new(0, 40, 0, 3)
					hexBox.BackgroundColor3 = CurrentTheme.CardBackColor
					hexBox.BackgroundTransparency = 0.3
					hexBox.BorderSizePixel = 0
					hexBox.TextColor3 = CurrentTheme.TextColor
					hexBox.Text = string.format("#%02X%02X%02X", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
					hexBox.TextSize = 11
					hexBox.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
					hexBox.TextXAlignment = Enum.TextXAlignment.Center
					hexBox.ZIndex = 21
					Instance.new("UICorner", hexBox).CornerRadius = UDim.new(0, 6)

					local svContainer = Instance.new("Frame", pickerFrame)
					svContainer.BackgroundTransparency = 1
					svContainer.Size = UDim2.new(1, 0, 0, 100)
					svContainer.LayoutOrder = 1

					local svBox = Instance.new("Frame", svContainer)
					svBox.Size = UDim2.new(0, 140, 1, 0)
					svBox.Position = UDim2.new(0, 0, 0, 0)
					svBox.BackgroundColor3 = Color3.new(1, 1, 1)
					svBox.BorderSizePixel = 0
					svBox.ZIndex = 21

					local satGradient = Instance.new("UIGradient", svBox)
					satGradient.Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(h / 360, 1, 1))
					}
					satGradient.Rotation = 0

					local valOverlay = Instance.new("Frame", svBox)
					valOverlay.Size = UDim2.new(1, 0, 1, 0)
					valOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
					valOverlay.BorderSizePixel = 0
					valOverlay.ZIndex = 22

					local valGradient = Instance.new("UIGradient", valOverlay)
					valGradient.Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
						ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
					}
					valGradient.Transparency = NumberSequence.new{
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 0)
					}
					valGradient.Rotation = -90

					local svKnob = Instance.new("Frame", svBox)
					svKnob.Size = UDim2.fromOffset(8, 8)
					svKnob.Position = UDim2.new(s, -4, 1 - v, -4)
					svKnob.BackgroundColor3 = Color3.new(1, 1, 1)
					svKnob.BorderSizePixel = 0
					svKnob.ZIndex = 23
					Instance.new("UICorner", svKnob).CornerRadius = UDim.new(1, 0)
					local svKnobStroke = Instance.new("UIStroke", svKnob)
					svKnobStroke.Color = Color3.new(0, 0, 0)
					svKnobStroke.Thickness = 1

					local hueContainer = Instance.new("Frame", pickerFrame)
					hueContainer.BackgroundTransparency = 1
					hueContainer.Size = UDim2.new(1, 0, 0, 16)
					hueContainer.LayoutOrder = 2

					local hueTrack = Instance.new("Frame", hueContainer)
					hueTrack.Size = UDim2.new(1, 0, 0, 12)
					hueTrack.Position = UDim2.new(0, 0, 0.5, -6)
					hueTrack.BorderSizePixel = 0
					hueTrack.ZIndex = 21

					local hueGradient = Instance.new("UIGradient", hueTrack)
					hueGradient.Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
						ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
						ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
						ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
						ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
					}
					Instance.new("UICorner", hueTrack).CornerRadius = UDim.new(0, 6)

					local hueKnob = Instance.new("Frame", hueTrack)
					hueKnob.Size = UDim2.fromOffset(12, 12)
					hueKnob.Position = UDim2.new(h / 360, -6, 0.5, -6)
					hueKnob.BackgroundColor3 = Color3.new(1, 1, 1)
					hueKnob.BorderSizePixel = 0
					hueKnob.ZIndex = 22
					Instance.new("UICorner", hueKnob).CornerRadius = UDim.new(1, 0)
					local hueKnobStroke = Instance.new("UIStroke", hueKnob)
					hueKnobStroke.Color = Color3.new(0, 0, 0)
					hueKnobStroke.Thickness = 1

					local rgbRow = Instance.new("Frame", pickerFrame)
					rgbRow.BackgroundTransparency = 1
					rgbRow.Size = UDim2.new(1, 0, 0, 22)
					rgbRow.LayoutOrder = 3

					local rgbLabels = {}
					for i, name in ipairs({"R", "G", "B"}) do
						local box = Instance.new("TextBox", rgbRow)
						box.Size = UDim2.fromOffset(40, 20)
						box.Position = UDim2.new(0, (i - 1) * 46, 0, 1)
						box.BackgroundColor3 = CurrentTheme.CardBackColor
						box.BackgroundTransparency = 0.3
						box.BorderSizePixel = 0
						box.TextColor3 = CurrentTheme.TextColor
						box.Text = tostring(math.floor(({currentColor.R * 255, currentColor.G * 255, currentColor.B * 255})[i]))
						box.TextSize = 10
						box.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
						box.TextXAlignment = Enum.TextXAlignment.Center
						box.ZIndex = 21
						Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
						table.insert(rgbLabels, box)
					end

					local presetRow = Instance.new("Frame", pickerFrame)
					presetRow.BackgroundTransparency = 1
					presetRow.Size = UDim2.new(1, 0, 0, 28)
					presetRow.LayoutOrder = 4

					local presets = {
						Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255),
						Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255), Color3.fromRGB(0,255,255),
						Color3.fromRGB(255,255,255), Color3.fromRGB(0,0,0), Color3.fromRGB(255,165,0),
					}
					for i, color in ipairs(presets) do
						local swatch = Instance.new("TextButton", presetRow)
						swatch.Text = ""
						swatch.BackgroundColor3 = color
						swatch.Size = UDim2.fromOffset(20, 20)
						swatch.Position = UDim2.new(0, (i - 1) * 24, 0, 4)
						swatch.AutoButtonColor = false
						swatch.ZIndex = 21
						Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 4)
					end

					local element = {
						Value = currentColor,
						Flag = flag,
						Type = "ColorPicker",
						Default = rawDefault,
						_connections = {},
						Instance = preview
					}
					if flag then MacLib.Elements[flag] = element end

					local function updateColor(newColor, fromInput)
						currentColor = newColor
						element.Value = newColor
						preview.BackgroundColor3 = newColor
						bigPreview.BackgroundColor3 = newColor

						local r, g, b = math.floor(newColor.R * 255), math.floor(newColor.G * 255), math.floor(newColor.B * 255)
						if not fromInput then
							hexBox.Text = string.format("#%02X%02X%02X", r, g, b)
							rgbLabels[1].Text = tostring(r)
							rgbLabels[2].Text = tostring(g)
							rgbLabels[3].Text = tostring(b)
						end

						local newH, newS, newV = newColor:ToHSV()
						h, s, v = newH * 360, newS, newV

						satGradient.Color = ColorSequence.new{
							ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
							ColorSequenceKeypoint.new(1, Color3.fromHSV(h / 360, 1, 1))
						}
						svKnob.Position = UDim2.new(s, -4, 1 - v, -4)
						hueKnob.Position = UDim2.new(h / 360, -6, 0.5, -6)

						if flag then SetConfigValue(flag, {r, g, b}) end
						print("[MacLib] ColorPicker '" .. tostring(data.Name or "unnamed") .. "' = " .. tostring(newColor))
						if data.Callback then data.Callback(newColor) end
					end

					local svDragging = false
					table.insert(element._connections, svBox.InputBegan:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							svDragging = true
							local relX = math.clamp((inp.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
							local relY = math.clamp((inp.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
							s = relX
							v = 1 - relY
							updateColor(Color3.fromHSV(h / 360, s, v))
						end
					end))
					table.insert(element._connections, UserInputService.InputEnded:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							svDragging = false
						end
					end))
					table.insert(element._connections, UserInputService.InputChanged:Connect(function(inp)
						if svDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
							local relX = math.clamp((inp.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
							local relY = math.clamp((inp.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
							s = relX
							v = 1 - relY
							updateColor(Color3.fromHSV(h / 360, s, v))
						end
					end))

					local hueDragging = false
					table.insert(element._connections, hueTrack.InputBegan:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							hueDragging = true
							local rel = math.clamp((inp.Position.X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
							h = rel * 360
							updateColor(Color3.fromHSV(h / 360, s, v))
						end
					end))
					table.insert(element._connections, UserInputService.InputEnded:Connect(function(inp)
						if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
							hueDragging = false
						end
					end))
					table.insert(element._connections, UserInputService.InputChanged:Connect(function(inp)
						if hueDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
							local rel = math.clamp((inp.Position.X - hueTrack.AbsolutePosition.X) / hueTrack.AbsoluteSize.X, 0, 1)
							h = rel * 360
							updateColor(Color3.fromHSV(h / 360, s, v))
						end
					end))

					table.insert(element._connections, hexBox.FocusLost:Connect(function()
						local hex = hexBox.Text:gsub("#", "")
						if #hex == 6 then
							local r = tonumber(hex:sub(1, 2), 16) or 0
							local g = tonumber(hex:sub(3, 4), 16) or 0
							local b = tonumber(hex:sub(5, 6), 16) or 0
							updateColor(Color3.fromRGB(r, g, b), true)
						end
					end))

					for i, box in ipairs(rgbLabels) do
						table.insert(element._connections, box.FocusLost:Connect(function()
							local val = math.clamp(tonumber(box.Text) or 0, 0, 255)
							local r, g, b = math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255)
							if i == 1 then r = val elseif i == 2 then g = val else b = val end
							updateColor(Color3.fromRGB(r, g, b), true)
						end))
					end

					for _, swatch in ipairs(presetRow:GetChildren()) do
						if swatch:IsA("TextButton") then
							table.insert(element._connections, swatch.MouseButton1Click:Connect(function()
								updateColor(swatch.BackgroundColor3)
							end))
						end
					end

					local conn = preview.MouseButton1Click:Connect(function()
						PlaySound("Click")
						pickerFrame.Visible = not pickerFrame.Visible
						if pickerFrame.Visible then
							pickerFrame.Size = UDim2.new(1, 0, 0, 220)
						else
							pickerFrame.Size = UDim2.new(1, 0, 0, 0)
						end
						updateHeight()
					end)
					table.insert(element._connections, conn)

					function element:Set(newValue)
						if typeof(newValue) ~= "Color3" then return end
						updateColor(newValue)
					end

					function element:Highlight()
						FlashHighlight(preview)
					end

						function element:Destroy()
							for _, c in ipairs(element._connections) do
								if c then pcall(function() c:Disconnect() end) end
							end
							CleanupThemeElements(label)
							CleanupThemeElements(preview)
							CleanupThemeElements(hexBox)
							for _, box in ipairs(rgbLabels) do
								CleanupThemeElements(box)
							end
							if row then row:Destroy() end
							if pickerFrame then pickerFrame:Destroy() end
							if flag then MacLib.Elements[flag] = nil end
						end

					if currentColor ~= (data.Default or Color3.fromRGB(255,0,0)) then
						element:Set(currentColor)
					end

					row.Parent = card
					if data.Name then table.insert(listSearchTags, data.Name) end
					refreshSearchTags()
					if data.Tooltip then AttachTooltip(row, data.Tooltip) end
					return element
				end

				function List:AddArrow(data)
					data = data or {}
					local row = makeRow(32)
					makeLabel(row, data.Name)

					local arrow = Instance.new("TextLabel", row)
					arrow.Text = "›"
					arrow.FontFace = Font.new(Config.Font, Enum.FontWeight.Regular)
					arrow.TextColor3 = CurrentTheme.TextColor
					arrow.TextSize = 18
					arrow.TextTransparency = 0.3
					arrow.BackgroundTransparency = 1
					arrow.Size = UDim2.fromOffset(14, 14)
					arrow.Position = UDim2.new(1, -22, 0.5, -7)
					arrow.ZIndex = 10

					local hit = Instance.new("TextButton", row)
					hit.Size = UDim2.new(1, 0, 1, 0)
					hit.BackgroundTransparency = 1
					hit.Text = ""
					hit.AutoButtonColor = false
					hit.ZIndex = 11

					local element = {
						Value = nil,
						Flag = data.Flag,
						Type = "Arrow",
						Default = nil,
						_connections = {},
						Instance = row
					}
					if data.Flag then MacLib.Elements[data.Flag] = element end

					local conn = hit.MouseButton1Click:Connect(function(x, y)
						CreateRipple(hit, x, y)
						PlaySound("Click")
						print("[MacLib] Arrow '" .. tostring(data.Name or "unnamed") .. "' clicked")
						if data.Callback then data.Callback() end
					end)
					table.insert(element._connections, conn)

					function element:Highlight()
						FlashHighlight(row)
					end

					function element:Set() end
						function element:Destroy()
							for _, c in ipairs(element._connections) do
								if c then pcall(function() c:Disconnect() end) end
							end
							CleanupThemeElements(label)
							if row then row:Destroy() end
							if element.Flag then MacLib.Elements[element.Flag] = nil end
						end

					row.Parent = card
					if data.Name then table.insert(listSearchTags, data.Name) end
					refreshSearchTags()
					if data.Tooltip then AttachTooltip(row, data.Tooltip) end
					return element
				end

				function List:AddButton(data)
				data = data or {}
				local row = makeRow(32)
				local label = makeLabel(row, data.Name)

				local b = Instance.new("TextButton", row)
				b.Text = data.Label or "Action"
				b.FontFace = Font.new(Config.Font, Enum.FontWeight.Medium)
				b.TextColor3 = CurrentTheme.TextColor
				b.TextSize = 12
				b.AutoButtonColor = false
				b.BackgroundColor3 = CurrentTheme.ButtonBg
				b.BackgroundTransparency = CurrentTheme.ButtonTransparency
				b.Size = UDim2.fromOffset(55, Config.ButtonHeight)
				b.Position = UDim2.new(1, -55, 0.5, -Config.ButtonHeight / 2)
				b.ZIndex = 10
				Instance.new("UICorner", b).CornerRadius = UDim.new(0, Config.ButtonCorner)
				local stroke = Instance.new("UIStroke", b)
				stroke.Color = CurrentTheme.StrokeColor
				stroke.Transparency = CurrentTheme.StrokeTransparency
				stroke.ZIndex = 11
				table.insert(ThemeElements, {Object = stroke, Role = "Stroke"})
				table.insert(ThemeElements, {Object = b, Role = "Button"})
				table.insert(ThemeElements, {Object = b, Role = "Text"})

				local element = {
					Value = nil,
					Flag = data.Flag,
					Type = "Button",
					Default = nil,
					_connections = {},
					Instance = b
				}
				if data.Flag then MacLib.Elements[data.Flag] = element end

				function element:Set() end
				function element:Highlight()
					FlashHighlight(row)
				end
				function element:Destroy()
					for _, c in ipairs(element._connections) do
						if c then pcall(function() c:Disconnect() end) end
					end
					CleanupThemeElements(stroke)
					CleanupThemeElements(b)
					if b then b:Destroy() end
					if row then row:Destroy() end
					if element.Flag then MacLib.Elements[element.Flag] = nil end
				end

				local conn = b.MouseButton1Click:Connect(function(x, y)
					CreateRipple(b, x, y)
					PlaySound("Click")
					print("[MacLib] ListButton '" .. tostring(data.Name or "unnamed") .. "' clicked")
					if data.Callback then data.Callback() end
				end)
				table.insert(element._connections, conn)

				row.Parent = card
				if data.Name then table.insert(listSearchTags, data.Name) end
				if data.Label then table.insert(listSearchTags, data.Label) end
				refreshSearchTags()
				if data.Tooltip then AttachTooltip(row, data.Tooltip) end
				return element
			end

			function List:AddLabel(data)
					data = data or {}
					local row = makeRow(22)
					local label = Instance.new("TextLabel", row)
					label.Text = data.Text or ""
					label.FontFace = Font.new(Config.Font)
					label.TextColor3 = CurrentTheme.TextDimColor
					label.TextSize = Config.SubSize
					label.TextTransparency = 0.35
					label.BackgroundTransparency = 1
					label.Size = UDim2.new(1, 0, 1, 0)
					label.TextXAlignment = Enum.TextXAlignment.Left
					label.TextTruncate = Enum.TextTruncate.AtEnd
					label.ZIndex = 10
					label.RichText = data.RichText or false
					table.insert(ThemeElements, {Object = label, Role = "TextDim"})

					local element = {
						Value = data.Text,
						Flag = data.Flag,
						Type = "Label",
						Default = data.Text,
						Instance = row
					}
					if data.Flag then MacLib.Elements[data.Flag] = element end
					function element:Highlight()
						FlashHighlight(row)
					end

					function element:Set(newValue)
						if typeof(newValue) ~= "string" then return end
						label.Text = newValue
						element.Value = newValue
					end
					function element:Destroy()
						CleanupThemeElements(label)
						if row then row:Destroy() end
						if element.Flag then MacLib.Elements[element.Flag] = nil end
					end

					row.Parent = card
					if data.Text then table.insert(listSearchTags, data.Text) end
					refreshSearchTags()
					return element
				end

				task.defer(updateHeight)
				return List
			end

			return SectionFunctions
		end

		return TabFunctions
	end

	-- Drag with bounds clamping + edge snap
	local dragging, start, startPos
	local snapThreshold = 20

	topbar.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true; start = inp.Position; startPos = main.Position
		end
	end)
	topbar.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			local viewport = workspace.CurrentCamera.ViewportSize
			local absPos = main.AbsolutePosition
			local absSize = main.AbsoluteSize
			local snapped = false
			local targetX = absPos.X
			local targetY = absPos.Y

			if absPos.X <= snapThreshold then
				targetX = 0
				snapped = true
			elseif viewport.X - (absPos.X + absSize.X) <= snapThreshold then
				targetX = viewport.X - absSize.X
				snapped = true
			end

			if absPos.Y <= snapThreshold then
				targetY = 0
				snapped = true
			elseif viewport.Y - (absPos.Y + absSize.Y) <= snapThreshold then
				targetY = viewport.Y - absSize.Y
				snapped = true
			end

			if snapped then
				local newPos = UDim2.new(0, targetX, 0, targetY)
				Tween(main, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {Position = newPos})
				originalPosition = newPos
			else
				originalPosition = main.Position
			end
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local d = inp.Position - start
			local viewport = workspace.CurrentCamera.ViewportSize
			local newX = startPos.X.Offset + d.X
			local newY = startPos.Y.Offset + d.Y
			local minX = -main.Size.X.Offset + 80
			local minY = -main.Size.Y.Offset + 60
			local maxX = viewport.X - 80
			local maxY = viewport.Y - 60
			main.Position = UDim2.new(
				startPos.X.Scale, math.clamp(newX, minX, maxX),
				startPos.Y.Scale, math.clamp(newY, minY, maxY)
			)
		end
	end)

	local assets = {}
	for _,v in pairs(Icons) do
		if type(v) == "string" and string.find(v, "rbxassetid://") then
			table.insert(assets, v)
		end
	end
	ContentProvider:PreloadAsync(assets)
	gui.Enabled = true
	function WindowFunctions:SetBackground(imageId)
		bgImage.Image = imageId or ""
		bgImage.Visible = imageId and imageId ~= ""
	end

	function WindowFunctions:SetRainbowMode(enabled)
		ManageRainbowConnection(enabled)
	end

	function WindowFunctions:SetCustomCursor(imageId)
		MacLib.CustomCursorEnabled = imageId ~= nil and imageId ~= ""
		customCursor.Image = imageId or ""
		ManageCursorConnection()
	end

	function WindowFunctions:SetSoundVolume(volume)
		Config.SoundVolume = math.clamp(volume, 0, 1)
		if Sounds.Click then Sounds.Click.Volume = Config.SoundVolume end
		if Sounds.Hover then Sounds.Hover.Volume = Config.SoundVolume * 0.3 end
	end

	function WindowFunctions:SetTweenSpeed(speed)
		Config.TweenSpeed = math.clamp(speed, 0.01, 5)
	end

	function WindowFunctions:Destroy()
		if MacLib.CursorConn then
			pcall(function() MacLib.CursorConn:Disconnect() end)
			MacLib.CursorConn = nil
		end
		if blurSystem then
			pcall(function() blurSystem:Destroy() end)
		end
		if MacLib.ActiveGui then
			pcall(function() MacLib.ActiveGui:Destroy() end)
			MacLib.ActiveGui = nil
		end
		if cursorGui then
			pcall(function() cursorGui:Destroy() end)
		end
	end

	return WindowFunctions
end

return MacLib
