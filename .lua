--// MACLIB UI FRAMEWORK v2.0 - FULL-FLEDGED LIBRARY
--// Glassmorphism dashboard with comprehensive component suite
--// All customization centralized in the Config table

local MacLib = {
	Version = "2.0.0",
	Theme = "Dark",
	GetService = function(service)
		return cloneref and cloneref(game:GetService(service)) or game:GetService(service)
	end
}

--// SERVICES
local TweenService = MacLib.GetService("TweenService")
local RunService = MacLib.GetService("RunService")
local Players = MacLib.GetService("Players")
local Lighting = MacLib.GetService("Lighting")
local HttpService = MacLib.GetService("HttpService")
local ContentProvider = MacLib.GetService("ContentProvider")
local UserInputService = MacLib.GetService("UserInputService")
local TextService = MacLib.GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// ============================================================
--// CONFIG - EDIT THIS TO CUSTOMIZE EVERYTHING
--// ============================================================
local Config = {
	Window = {
		Size = UDim2.fromOffset(900, 600),
		MinSize = Vector2.new(600, 400),
		AcrylicBlur = true,
		BaseColor = Color3.fromRGB(22, 22, 22),
		BaseTransparency = 0.05,
		CornerRadius = 24,
		Title = "MacLib",
	},
	Sidebar = {
		Width = 60,
		IconSize = 20,
		IconSpacing = 20,
		TopPadding = 20,
		BottomPadding = 16,
		Margin = 14,
		BackgroundColor = Color3.fromRGB(45, 45, 45),
		BackgroundTransparency = 0.15,
		CornerRadius = 20,
		SelectionColor = Color3.fromRGB(255, 255, 255),
		SelectionTransparency = 0.88,
		SelectionSize = 34,
		SelectionCorner = 10,
	},
	Card = {
		FrontColor = Color3.fromRGB(255, 255, 255),
		FrontTransparency = 0.62,
		BackColor = Color3.fromRGB(255, 255, 255),
		BackTransparency = 0.78,
		BackOffset = 3,
		CornerRadius = 16,
		SmallHeight = 100,
		TallHeight = 200,
		SettingsHeight = 108,
		Padding = 14,
		RowSpacing = 10,
		ColSpacing = 10,
	},
	Toggle = {
		Width = 36,
		Height = 20,
		KnobSize = 16,
		OnColor = Color3.fromRGB(0, 170, 255),
		OffColor = Color3.fromRGB(120, 120, 120),
	},
	Slider = {
		Height = 20,
		TrackHeight = 20,
		KnobSize = 16,
		TrackColor = Color3.fromRGB(75, 75, 75),
		FillColor = Color3.fromRGB(0, 170, 255),
	},
	Dropdown = {
		Height = 28,
		MaxItems = 5,
		BackgroundColor = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.85,
		CornerRadius = 8,
	},
	TextBox = {
		Height = 28,
		BackgroundColor = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.85,
		CornerRadius = 8,
	},
	Button = {
		Height = 28,
		BackgroundColor = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.78,
		CornerRadius = 7,
	},
	ColorPicker = {
		Size = 160,
		CornerRadius = 12,
	},
	Notification = {
		Width = 280,
		Height = 72,
		Duration = 3,
		CornerRadius = 12,
		BackgroundColor = Color3.fromRGB(35, 35, 35),
		BackgroundTransparency = 0.1,
	},
	Text = {
		Font = "rbxassetid://12187365364",
		TitleSize = 12,
		SubtitleSize = 11,
		Color = Color3.fromRGB(255, 255, 255),
		DimColor = Color3.fromRGB(175, 175, 175),
		ErrorColor = Color3.fromRGB(255, 80, 80),
		SuccessColor = Color3.fromRGB(80, 255, 120),
		WarningColor = Color3.fromRGB(255, 200, 80),
	},
}

--// ASSETS
local Icons = {
	aperture = "rbxassetid://7733666258",
	user = "rbxassetid://7743875962",
	eye = "rbxassetid://7733774602",
	clock = "rbxassetid://7733734848",
	settings = "rbxassetid://7734053495",
	power = "rbxassetid://7734042493",
	search = "rbxassetid://7734052925",
	box = "rbxassetid://7733917120",
	zap = "rbxassetid://7733798747",
	file = "rbxassetid://7733789088",
	crosshair = "rbxassetid://7733798419",
	chevron_down = "rbxassetid://7733717447",
	chevron_right = "rbxassetid://7733717420",
	check = "rbxassetid://7733715400",
	plus = "rbxassetid://7734040507",
	minus = "rbxassetid://7733954760",
	trash = "rbxassetid://7733954760",
	copy = "rbxassetid://7733917120",
	refresh = "rbxassetid://7734040507",
	lock = "rbxassetid://7733955740",
	unlock = "rbxassetid://7733955740",
	key = "rbxassetid://7733955740",
	palette = "rbxassetid://7733955740",
	save = "rbxassetid://7734053495",
	info = "rbxassetid://7733774602",
	alert = "rbxassetid://7733666258",
	alert_circle = "rbxassetid://7733666258",
	x = "rbxassetid://7734053495",
}

--// UTILITIES
local function Tween(instance, info, props)
	TweenService:Create(instance, info, props):Play()
end

local function GetGui()
	local newGui = Instance.new("ScreenGui")
	newGui.ScreenInsets = Enum.ScreenInsets.None
	newGui.ResetOnSpawn = false
	newGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	newGui.DisplayOrder = 2147483647
	local parent = RunService:IsStudio()
		and LocalPlayer:FindFirstChild("PlayerGui")
		or (gethui and gethui())
		or (cloneref and cloneref(MacLib.GetService("CoreGui")) or MacLib.GetService("CoreGui"))
	newGui.Parent = parent
	return newGui
end

local function GetTextBounds(text, font, size)
	return TextService:GetTextSize(text, size, font, Vector2.new(9999, 9999))
end

local function DeepCopy(tbl)
	local copy = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			copy[k] = DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

--// NOTIFICATION SYSTEM
local NotificationQueue = {}
local NotificationActive = false

local function ShowNotification(NotificationData)
	local notifGui = Instance.new("ScreenGui")
	notifGui.Name = "MacLibNotifications"
	notifGui.ScreenInsets = Enum.ScreenInsets.None
	notifGui.ResetOnSpawn = false
	notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	notifGui.DisplayOrder = 2147483646
	local parent = RunService:IsStudio()
		and LocalPlayer:FindFirstChild("PlayerGui")
		or (gethui and gethui())
		or (cloneref and cloneref(MacLib.GetService("CoreGui")) or MacLib.GetService("CoreGui"))
	notifGui.Parent = parent

	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Config.Notification.BackgroundColor
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromOffset(Config.Notification.Width, Config.Notification.Height)
	frame.Position = UDim2.new(1, 20, 1, -Config.Notification.Height - 20)
	frame.AnchorPoint = Vector2.new(1, 1)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, Config.Notification.CornerRadius)
	corner.Parent = frame

	local icon = Instance.new("ImageLabel")
	icon.Image = NotificationData.Icon or Icons.info
	icon.ImageColor3 = NotificationData.IconColor or Config.Text.Color
	icon.ImageTransparency = 0.2
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.fromOffset(24, 24)
	icon.Position = UDim2.new(0, 14, 0.5, -12)
	icon.Parent = frame

	local title = Instance.new("TextLabel")
	title.FontFace = Font.new(Config.Text.Font, Enum.FontWeight.SemiBold)
	title.Text = NotificationData.Title or "Notification"
	title.TextColor3 = Config.Text.Color
	title.TextSize = 13
	title.TextTransparency = 0.1
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 48, 0, 12)
	title.Size = UDim2.new(1, -62, 0, 18)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local message = Instance.new("TextLabel")
	message.FontFace = Font.new(Config.Text.Font)
	message.Text = NotificationData.Message or ""
	message.TextColor3 = Config.Text.DimColor
	message.TextSize = 11
	message.TextTransparency = 0.2
	message.BackgroundTransparency = 1
	message.Position = UDim2.new(0, 48, 0, 32)
	message.Size = UDim2.new(1, -62, 0, 28)
	message.TextXAlignment = Enum.TextXAlignment.Left
	message.TextWrapped = true
	message.Parent = frame

	local progress = Instance.new("Frame")
	progress.BackgroundColor3 = NotificationData.IconColor or Config.Toggle.OnColor
	progress.BackgroundTransparency = 0.3
	progress.BorderSizePixel = 0
	progress.Size = UDim2.new(1, 0, 0, 2)
	progress.Position = UDim2.new(0, 0, 1, -2)
	progress.Parent = frame

	frame.Parent = notifGui

	-- Animate in
	Tween(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		BackgroundTransparency = Config.Notification.BackgroundTransparency,
		Position = UDim2.new(1, -20, 1, -Config.Notification.Height - 20)
	})

	-- Progress bar animation
	Tween(progress, TweenInfo.new(NotificationData.Duration or Config.Notification.Duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 0, 2)
	})

	task.delay(NotificationData.Duration or Config.Notification.Duration, function()
		Tween(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
			Position = UDim2.new(1, 20, 1, -Config.Notification.Height - 20)
		})
		task.wait(0.3)
		notifGui:Destroy()
	end)
end

function MacLib:Notify(Data)
	ShowNotification(Data)
end

--// WINDOW
function MacLib:Window(Settings)
	local WindowFunctions = {}
	local acrylicBlur = Settings.AcrylicBlur ~= false
	local macLib = GetGui()

	--// BASE
	local base = Instance.new("Frame")
	base.Name = "Base"
	base.AnchorPoint = Vector2.new(0.5, 0.5)
	base.BackgroundColor3 = Config.Window.BaseColor
	base.BackgroundTransparency = Config.Window.BaseTransparency
	base.BorderSizePixel = 0
	base.Position = UDim2.fromScale(0.5, 0.5)
	base.Size = Settings.Size or Config.Window.Size
	base.ClipsDescendants = true

	local baseCorner = Instance.new("UICorner")
	baseCorner.CornerRadius = UDim.new(0, Config.Window.CornerRadius)
	baseCorner.Parent = base

	--// SIDEBAR
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.BackgroundColor3 = Config.Sidebar.BackgroundColor
	sidebar.BackgroundTransparency = Config.Sidebar.BackgroundTransparency
	sidebar.BorderSizePixel = 0
	sidebar.Size = UDim2.new(0, Config.Sidebar.Width, 1, -Config.Sidebar.Margin * 2)
	sidebar.Position = UDim2.new(0, Config.Sidebar.Margin, 0, Config.Sidebar.Margin)

	local sidebarCorner = Instance.new("UICorner")
	sidebarCorner.CornerRadius = UDim.new(0, Config.Sidebar.CornerRadius)
	sidebarCorner.Parent = sidebar

	-- Top icons area
	local topIcons = Instance.new("Frame")
	topIcons.Name = "TopIcons"
	topIcons.BackgroundTransparency = 1
	topIcons.Size = UDim2.new(1, 0, 1, -52)
	topIcons.Position = UDim2.new(0, 0, 0, 0)

	local topLayout = Instance.new("UIListLayout")
	topLayout.Padding = UDim.new(0, Config.Sidebar.IconSpacing)
	topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	topLayout.SortOrder = Enum.SortOrder.LayoutOrder
	topLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	topLayout.Parent = topIcons

	local topPad = Instance.new("UIPadding")
	topPad.PaddingTop = UDim.new(0, Config.Sidebar.TopPadding)
	topPad.Parent = topIcons

	topIcons.Parent = sidebar

	-- Bottom power area
	local bottomArea = Instance.new("Frame")
	bottomArea.Name = "BottomArea"
	bottomArea.BackgroundTransparency = 1
	bottomArea.Size = UDim2.new(1, 0, 0, 40)
	bottomArea.Position = UDim2.new(0, 0, 1, -40 - Config.Sidebar.BottomPadding)
	bottomArea.Parent = sidebar

	sidebar.Parent = base

	--// CONTENT
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Position = UDim2.new(0, Config.Sidebar.Width + Config.Sidebar.Margin + 14, 0, 0)
	content.Size = UDim2.new(1, -(Config.Sidebar.Width + Config.Sidebar.Margin * 2 + 14), 1, 0)

	--// TOPBAR
	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.BackgroundTransparency = 1
	topbar.Size = UDim2.new(1, 0, 0, 52)

	local topLeft = Instance.new("Frame")
	topLeft.BackgroundTransparency = 1
	topLeft.Size = UDim2.new(0, 300, 1, 0)
	topLeft.Parent = topbar

	local topLeftLayout = Instance.new("UIListLayout")
	topLeftLayout.FillDirection = Enum.FillDirection.Horizontal
	topLeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
	topLeftLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	topLeftLayout.Padding = UDim.new(0, 22)
	topLeftLayout.Parent = topLeft

	Instance.new("UIPadding", topLeft).PaddingLeft = UDim.new(0, 0)

	local topRight = Instance.new("Frame")
	topRight.BackgroundTransparency = 1
	topRight.AnchorPoint = Vector2.new(1, 0.5)
	topRight.Position = UDim2.new(1, -18, 0.5, 0)
	topRight.Size = UDim2.new(0, 220, 1, 0)
	topRight.Parent = topbar

	local topRightLayout = Instance.new("UIListLayout")
	topRightLayout.FillDirection = Enum.FillDirection.Horizontal
	topRightLayout.SortOrder = Enum.SortOrder.LayoutOrder
	topRightLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	topRightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	topRightLayout.Padding = UDim.new(0, 10)
	topRightLayout.Parent = topRight

	local searchFrame = Instance.new("Frame")
	searchFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	searchFrame.BackgroundTransparency = 0.9
	searchFrame.BorderSizePixel = 0
	searchFrame.Size = UDim2.fromOffset(150, 28)

	local searchCorner = Instance.new("UICorner")
	searchCorner.CornerRadius = UDim.new(0, 8)
	searchCorner.Parent = searchFrame

	local searchIcon = Instance.new("ImageLabel")
	searchIcon.Image = Icons.search
	searchIcon.ImageTransparency = 0.4
	searchIcon.BackgroundTransparency = 1
	searchIcon.Size = UDim2.fromOffset(12, 12)
	searchIcon.Position = UDim2.new(0, 8, 0.5, -6)
	searchIcon.Parent = searchFrame

	local searchBox = Instance.new("TextBox")
	searchBox.FontFace = Font.new(Config.Text.Font)
	searchBox.PlaceholderText = "Search"
	searchBox.PlaceholderColor3 = Color3.fromRGB(160, 160, 160)
	searchBox.Text = ""
	searchBox.TextColor3 = Config.Text.Color
	searchBox.TextSize = 11
	searchBox.TextTransparency = 0.25
	searchBox.BackgroundTransparency = 1
	searchBox.Position = UDim2.new(0, 26, 0, 0)
	searchBox.Size = UDim2.new(1, -34, 1, 0)
	searchBox.Parent = searchFrame

	searchFrame.Parent = topRight

	local docIcon = Instance.new("ImageLabel")
	docIcon.Image = Icons.file
	docIcon.ImageTransparency = 0.35
	docIcon.BackgroundTransparency = 1
	docIcon.Size = UDim2.fromOffset(18, 18)
	docIcon.Parent = topRight

	local avatar = Instance.new("ImageLabel")
	avatar.BackgroundTransparency = 1
	avatar.Size = UDim2.fromOffset(28, 28)
	local userId = LocalPlayer.UserId
	local thumbType = Enum.ThumbnailType.AvatarBust
	local thumbSize = Enum.ThumbnailSize.Size48x48
	local headshotImage, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
	avatar.Image = isReady and headshotImage or "rbxassetid://0"

	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(1, 0)
	avatarCorner.Parent = avatar

	avatar.Parent = topRight

	topbar.Parent = content

	--// CONTENT FRAME
	local contentFrame = Instance.new("Frame")
	contentFrame.BackgroundTransparency = 1
	contentFrame.Position = UDim2.new(0, 0, 0, 52)
	contentFrame.Size = UDim2.new(1, 0, 1, -52)

	local contentPad = Instance.new("UIPadding")
	contentPad.PaddingLeft = UDim.new(0, 0)
	contentPad.PaddingRight = UDim.new(0, 18)
	contentPad.PaddingTop = UDim.new(0, 10)
	contentPad.PaddingBottom = UDim.new(0, 18)
	contentPad.Parent = contentFrame

	contentFrame.Parent = content
	content.Parent = base
	base.Parent = macLib

	--// ACRYLIC BLUR
	if acrylicBlur then
		local HS = HttpService
		local camera = workspace.CurrentCamera
		local MTREL = "Glass"
		local wedgeguid = HS:GenerateGUID(true)

		local DepthOfField
		for _, v in pairs(Lighting:GetChildren()) do
			if v:IsA("DepthOfFieldEffect") and v:HasTag(".") then
				DepthOfField = v; break
			end
		end
		if not DepthOfField then
			DepthOfField = Instance.new('DepthOfFieldEffect')
			DepthOfField.FarIntensity = 0
			DepthOfField.FocusDistance = 51.6
			DepthOfField.InFocusRadius = 50
			DepthOfField.NearIntensity = 1
			DepthOfField.Name = HS:GenerateGUID(true)
			DepthOfField:AddTag(".")
		end

		local blurFrame = Instance.new('Frame')
		blurFrame.Parent = base
		blurFrame.Size = UDim2.new(0.97, 0, 0.97, 0)
		blurFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		blurFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		blurFrame.BackgroundTransparency = 1
		blurFrame.Name = HS:GenerateGUID(true)

		do
			local function IsNotNaN(x) return x == x end
			local continue = IsNotNaN(camera:ScreenPointToRay(0, 0).Origin.x)
			while not continue do
				RunService.RenderStepped:Wait()
				continue = IsNotNaN(camera:ScreenPointToRay(0, 0).Origin.x)
			end
		end

		local DrawQuad; do
			local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
			local sz = 0.2
			local function DrawTriangle(v1, v2, v3, p0, p1)
				local s1 = (v1 - v2).magnitude
				local s2 = (v2 - v3).magnitude
				local s3 = (v3 - v1).magnitude
				local smax = max(s1, s2, s3)
				local A, B, C
				if s1 == smax then A, B, C = v1, v2, v3
				elseif s2 == smax then A, B, C = v2, v3, v1
				else A, B, C = v3, v1, v2 end

				local para = ((B - A).x * (C - A).x + (B - A).y * (C - A).y + (B - A).z * (C - A).z) / (A - B).magnitude
				local perp = sqrt((C - A).magnitude ^ 2 - para * para)
				local dif_para = (A - B).magnitude - para

				local st = CFrame.new(B, A)
				local za = CFrame.Angles(pi / 2, 0, 0)
				local cf0 = st
				local Top_Look = (cf0 * za).lookVector
				local Mid_Point = A + CFrame.new(A, B).lookVector * para
				local Needed_Look = CFrame.new(Mid_Point, C).lookVector
				local dot = Top_Look.x * Needed_Look.x + Top_Look.y * Needed_Look.y + Top_Look.z * Needed_Look.z
				local ac = CFrame.Angles(0, 0, acos(dot))

				cf0 = cf0 * ac
				if ((cf0 * za).lookVector - Needed_Look).magnitude > 0.01 then
					cf0 = cf0 * CFrame.Angles(0, 0, -2 * acos(dot))
				end
				cf0 = cf0 * CFrame.new(0, perp / 2, -(dif_para + para / 2))

				local cf1 = st * ac * CFrame.Angles(0, pi, 0)
				if ((cf1 * za).lookVector - Needed_Look).magnitude > 0.01 then
					cf1 = cf1 * CFrame.Angles(0, 0, 2 * acos(dot))
				end
				cf1 = cf1 * CFrame.new(0, perp / 2, dif_para / 2)

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
				p0[wedgeguid].Scale = Vector3.new(0, perp / sz, para / sz)
				p0.CFrame = cf0

				if not p1 then p1 = p0:clone() end
				p1[wedgeguid].Scale = Vector3.new(0, perp / sz, dif_para / sz)
				p1.CFrame = cf1
				return p0, p1
			end

			function DrawQuad(v1, v2, v3, v4, parts)
				parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
				parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
			end
		end

		local parts = {}
		local parents = {}
		do
			local function add(child)
				if child:IsA'GuiObject' then
					parents[#parents + 1] = child
					add(child.Parent)
				end
			end
			add(blurFrame)
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
			if not IsVisible(blurFrame) then
				for _, pt in pairs(parts) do pt.Parent = nil end
				DepthOfField.Enabled = false
				return
			end
			if not DepthOfField.Parent then DepthOfField.Parent = Lighting end
			DepthOfField.Enabled = true
			local properties = { Transparency = 0.98; BrickColor = BrickColor.new('Institutional white'); }
			local zIndex = 1 - 0.05 * blurFrame.ZIndex

			local tl, br = blurFrame.AbsolutePosition, blurFrame.AbsolutePosition + blurFrame.AbsoluteSize
			local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
			do
				local rot = 0
				for _, v in ipairs(parents) do rot = rot + v.Rotation end
				if rot ~= 0 and rot % 180 ~= 0 then
					local mid = tl:lerp(br, 0.5)
					local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))
					local function rotVec(v)
						return Vector2.new(c * (v.x - mid.x) - s * (v.y - mid.y), s * (v.x - mid.x) + c * (v.y - mid.y)) + mid
					end
					tl, tr, bl, br = rotVec(tl), rotVec(tr), rotVec(bl), rotVec(br)
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
				for _, pt in pairs(parts) do pt.Parent = camera end
				for propName, propValue in pairs(properties) do
					for _, pt in pairs(parts) do pt[propName] = propValue end
				end
			end
		end

		UpdateOrientation(true)
		RunService.RenderStepped:Connect(UpdateOrientation)
	end

	--// TABS
	local currentTab = nil
	local Tabs = {}

	function WindowFunctions:Tab(Settings)
		local TabFunctions = {}
		local isPower = Settings.IsPower

		-- Selection background (rounded square behind icon)
		local selectBg = Instance.new("Frame")
		selectBg.Name = "SelectBg"
		selectBg.BackgroundColor3 = Config.Sidebar.SelectionColor
		selectBg.BackgroundTransparency = 1
		selectBg.BorderSizePixel = 0
		selectBg.Size = UDim2.fromOffset(Config.Sidebar.SelectionSize, Config.Sidebar.SelectionSize)
		selectBg.ZIndex = 1

		local selectCorner = Instance.new("UICorner")
		selectCorner.CornerRadius = UDim.new(0, Config.Sidebar.SelectionCorner)
		selectCorner.Parent = selectBg

		-- Icon
		local iconBtn = Instance.new("ImageButton")
		iconBtn.Name = Settings.Name or "Tab"
		iconBtn.Image = Settings.Icon or Icons.aperture
		iconBtn.ImageTransparency = 0.5
		iconBtn.BackgroundTransparency = 1
		iconBtn.BorderSizePixel = 0
		iconBtn.Size = UDim2.fromOffset(Config.Sidebar.IconSize, Config.Sidebar.IconSize)
		iconBtn.ZIndex = 2
		iconBtn.AutoButtonColor = false

		if isPower then
			selectBg.Parent = bottomArea
			selectBg.Position = UDim2.new(0.5, -Config.Sidebar.SelectionSize / 2, 0.5, -Config.Sidebar.SelectionSize / 2)
			iconBtn.Parent = bottomArea
			iconBtn.Position = UDim2.new(0.5, -Config.Sidebar.IconSize / 2, 0.5, -Config.Sidebar.IconSize / 2)
		else
			local slot = Instance.new("Frame")
			slot.Name = (Settings.Name or "Tab") .. "Slot"
			slot.BackgroundTransparency = 1
			slot.Size = UDim2.fromOffset(Config.Sidebar.SelectionSize, Config.Sidebar.SelectionSize)
			slot.LayoutOrder = Settings.LayoutOrder or 1
			slot.Parent = topIcons

			selectBg.AnchorPoint = Vector2.new(0.5, 0.5)
			selectBg.Position = UDim2.fromScale(0.5, 0.5)
			selectBg.Parent = slot

			iconBtn.AnchorPoint = Vector2.new(0.5, 0.5)
			iconBtn.Position = UDim2.fromScale(0.5, 0.5)
			iconBtn.Parent = slot
		end

		-- Tab content frame
		local tabContent = Instance.new("Frame")
		tabContent.Name = Settings.Name .. "Content"
		tabContent.BackgroundTransparency = 1
		tabContent.Size = UDim2.fromScale(1, 1)
		tabContent.Visible = false

		local colLayout = Instance.new("UIListLayout")
		colLayout.FillDirection = Enum.FillDirection.Horizontal
		colLayout.SortOrder = Enum.SortOrder.LayoutOrder
		colLayout.Padding = UDim.new(0, Config.Card.ColSpacing)
		colLayout.Parent = tabContent

		-- Helper to build a column with vertical list of rows
		local function MakeColumn(name, order)
			local col = Instance.new("Frame")
			col.Name = name
			col.BackgroundTransparency = 1
			col.Size = UDim2.new(0.333, -math.ceil(Config.Card.ColSpacing * 2 / 3), 1, 0)
			col.LayoutOrder = order
			local l = Instance.new("UIListLayout")
			l.Padding = UDim.new(0, Config.Card.RowSpacing)
			l.SortOrder = Enum.SortOrder.LayoutOrder
			l.Parent = col
			col.Parent = tabContent
			return col
		end

		local left = MakeColumn("Left", 1)
		local mid = MakeColumn("Middle", 2)
		local right = MakeColumn("Right", 3)

		tabContent.Parent = contentFrame

		-- Tab switching
		local function selectTab()
			if currentTab then
				currentTab.content.Visible = false
				currentTab.icon.ImageTransparency = 0.5
				Tween(currentTab.selectBg, TweenInfo.new(0.15), { BackgroundTransparency = 1 })
			end
			currentTab = { content = tabContent, icon = iconBtn, selectBg = selectBg }
			tabContent.Visible = true
			iconBtn.ImageTransparency = 0.1
			Tween(selectBg, TweenInfo.new(0.15), { BackgroundTransparency = Config.Sidebar.SelectionTransparency })
		end

		iconBtn.MouseButton1Click:Connect(selectTab)
		if not currentTab and not isPower then selectTab() end

		-- Subtabs
		local SubtabButtons = {}
		if Settings.Subtabs then
			for i, subtabName in ipairs(Settings.Subtabs) do
				local st = Instance.new("TextButton")
				st.FontFace = Font.new(Config.Text.Font, i == 1 and Enum.FontWeight.SemiBold or Enum.FontWeight.Medium)
				st.Text = subtabName
				st.TextColor3 = Config.Text.Color
				st.TextSize = 14
				st.TextTransparency = i == 1 and 0.1 or 0.5
				st.BackgroundTransparency = 1
				st.BorderSizePixel = 0
				st.Size = UDim2.fromOffset(80, 28)
				st.AutoButtonColor = false
				st.Parent = topLeft
				SubtabButtons[subtabName] = st

				st.MouseButton1Click:Connect(function()
					for _, btn in pairs(SubtabButtons) do
						Tween(btn, TweenInfo.new(0.15), { TextTransparency = 0.5 })
						btn.FontFace = Font.new(Config.Text.Font, Enum.FontWeight.Medium)
					end
					Tween(st, TweenInfo.new(0.15), { TextTransparency = 0.1 })
					st.FontFace = Font.new(Config.Text.Font, Enum.FontWeight.SemiBold)
					if Settings.SubtabCallback then
						Settings.SubtabCallback(subtabName)
					end
				end)
			end
		end

		--// ============================================================
		--// COMPONENTS
		--// ============================================================
		function TabFunctions:Section(Settings)
			local SectionFunctions = {}
			local side = Settings.Side or "Left"
			local parent = side == "Left" and left or side == "Middle" and mid or right

			-- Internal: creates a layered card (front + back offset for depth)
			local function CreateLayeredCard(name, heightOrSize)
				local container = Instance.new("Frame")
				container.Name = name .. "Container"
				container.BackgroundTransparency = 1
				if typeof(heightOrSize) == "UDim2" then
					container.Size = heightOrSize
				else
					container.Size = UDim2.new(1, 0, 0, heightOrSize)
				end

				-- Back layer (shadow/depth)
				local back = Instance.new("Frame")
				back.Name = "Back"
				back.BackgroundColor3 = Config.Card.BackColor
				back.BackgroundTransparency = Config.Card.BackTransparency
				back.BorderSizePixel = 0
				back.Size = UDim2.new(1, 0, 1, 0)
				back.Position = UDim2.new(0, Config.Card.BackOffset, 0, Config.Card.BackOffset)
				local backCorner = Instance.new("UICorner")
				backCorner.CornerRadius = UDim.new(0, Config.Card.CornerRadius)
				backCorner.Parent = back
				back.Parent = container

				-- Front layer
				local card = Instance.new("Frame")
				card.Name = name
				card.BackgroundColor3 = Config.Card.FrontColor
				card.BackgroundTransparency = Config.Card.FrontTransparency
				card.BorderSizePixel = 0
				card.Size = UDim2.new(1, 0, 1, 0)
				local cardCorner = Instance.new("UICorner")
				cardCorner.CornerRadius = UDim.new(0, Config.Card.CornerRadius)
				cardCorner.Parent = card
				card.Parent = container

				return container, card
			end

			-- Internal: toggle builder
			local function CreateToggle(parent, default, callback, pos)
				local track = Instance.new("Frame")
				track.BackgroundColor3 = default and Config.Toggle.OnColor or Config.Toggle.OffColor
				track.BackgroundTransparency = 0.1
				track.BorderSizePixel = 0
				track.Size = UDim2.fromOffset(Config.Toggle.Width, Config.Toggle.Height)
				track.Position = pos or UDim2.new(1, -Config.Toggle.Width - 12, 0, 12)
				local trackCorner = Instance.new("UICorner")
				trackCorner.CornerRadius = UDim.new(1, 0)
				trackCorner.Parent = track
				track.Parent = parent

				local knob = Instance.new("Frame")
				knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				knob.BorderSizePixel = 0
				knob.Size = UDim2.fromOffset(Config.Toggle.KnobSize, Config.Toggle.KnobSize)
				knob.Position = default
					and UDim2.new(1, -Config.Toggle.KnobSize - 2, 0.5, -Config.Toggle.KnobSize / 2)
					or UDim2.new(0, 2, 0.5, -Config.Toggle.KnobSize / 2)
				local knobCorner = Instance.new("UICorner")
				knobCorner.CornerRadius = UDim.new(1, 0)
				knobCorner.Parent = knob
				knob.Parent = track

				local toggled = default
				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						toggled = not toggled
						Tween(track, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
							BackgroundColor3 = toggled and Config.Toggle.OnColor or Config.Toggle.OffColor
						})
						Tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
							Position = toggled
								and UDim2.new(1, -Config.Toggle.KnobSize - 2, 0.5, -Config.Toggle.KnobSize / 2)
								or UDim2.new(0, 2, 0.5, -Config.Toggle.KnobSize / 2)
						})
						if callback then callback(toggled) end
					end
				end)

				local ToggleFunctions = {}
				function ToggleFunctions:Set(value)
					toggled = value
					Tween(track, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
						BackgroundColor3 = toggled and Config.Toggle.OnColor or Config.Toggle.OffColor
					})
					Tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
						Position = toggled
							and UDim2.new(1, -Config.Toggle.KnobSize - 2, 0.5, -Config.Toggle.KnobSize / 2)
							or UDim2.new(0, 2, 0.5, -Config.Toggle.KnobSize / 2)
					})
					if callback then callback(toggled) end
				end
				function ToggleFunctions:Get()
					return toggled
				end

				return ToggleFunctions, track
			end

			-- Internal: fill a small card (icon top-left, toggle top-right, title bottom-left)
			local function PopulateSmallCard(card, Settings)
				local icon = Instance.new("ImageLabel")
				icon.Image = Settings.Icon or Icons.zap
				icon.ImageTransparency = 0.2
				icon.BackgroundTransparency = 1
				icon.Size = UDim2.fromOffset(18, 18)
				icon.Position = UDim2.new(0, 14, 0, 12)
				icon.Parent = card

				if Settings.Toggle ~= nil then
					CreateToggle(card, Settings.Toggle, Settings.Callback,
						UDim2.new(1, -Config.Toggle.Width - 12, 0, 12))
				end

				local title = Instance.new("TextLabel")
				title.FontFace = Font.new(Config.Text.Font, Enum.FontWeight.Medium)
				title.Text = Settings.Title or "Enabled"
				title.TextColor3 = Config.Text.Color
				title.TextSize = Config.Text.TitleSize
				title.TextTransparency = 0.15
				title.BackgroundTransparency = 1
				title.Position = UDim2.new(0, 14, 1, -26)
				title.Size = UDim2.new(1, -28, 0, 20)
				title.TextXAlignment = Enum.TextXAlignment.Left
				title.Parent = card
			end

			--// PUBLIC: Row
			function SectionFunctions:Row(Opts)
				Opts = Opts or {}
				local rowHeight = Opts.Height or Config.Card.SmallHeight
				local row = Instance.new("Frame")
				row.Name = "Row"
				row.BackgroundTransparency = 1
				row.Size = UDim2.new(1, 0, 0, rowHeight)
				local rl = Instance.new("UIListLayout")
				rl.FillDirection = Enum.FillDirection.Horizontal
				rl.SortOrder = Enum.SortOrder.LayoutOrder
				rl.Padding = UDim.new(0, Config.Card.RowSpacing)
				rl.Parent = row
				row.Parent = parent

				local RowFunctions = {}
				local cardCount = 0

				local function relayout()
					local kids = {}
					for _, c in ipairs(row:GetChildren()) do
						if c:IsA("Frame") then table.insert(kids, c) end
					end
					local n = #kids
					if n == 0 then return end
					for _, c in ipairs(kids) do
						c.Size = UDim2.new(1 / n, -math.ceil(Config.Card.RowSpacing * (n - 1) / n), 1, 0)
					end
				end

				function RowFunctions:SmallCard(Settings)
					cardCount = cardCount + 1
					local container, card = CreateLayeredCard(Settings.Title or ("SmallCard" .. cardCount),
						UDim2.new(0.5, -Config.Card.RowSpacing / 2, 1, 0))
					container.LayoutOrder = cardCount
					PopulateSmallCard(card, Settings)
					container.Parent = row
					relayout()
					return container
				end

				return RowFunctions
			end

			--// PUBLIC: SmallCard
			function SectionFunctions:SmallCard(Settings)
				local container, card = CreateLayeredCard(Settings.Title or "SmallCard", Config.Card.SmallHeight)
				PopulateSmallCard(card, Settings)
				container.Parent = parent
				return container
			end

			--// PUBLIC: TallCard
			function SectionFunctions:TallCard(Settings)
				local container, card = CreateLayeredCard(Settings.Title or "TallCard", Config.Card.TallHeight)

				local icon = Instance.new("ImageLabel")
				icon.Image = Settings.Icon or Icons.zap
				icon.ImageTransparency = 0.2
				icon.BackgroundTransparency = 1
				icon.Size = UDim2.fromOffset(18, 18)
				icon.Position = UDim2.new(0, 14, 0, 12)
				icon.Parent = card

				if Settings.Toggle ~= nil then
					CreateToggle(card, Settings.Toggle, Settings.Callback,
						UDim2.new(1, -Config.Toggle.Width - 12, 0, 12))
				end

				local title = Instance.new("TextLabel")
				title.FontFace = Font.new(Config.Text.Font, Enum.FontWeight.Medium)
				title.Text = Settings.Title or "Enabled"
				title.TextColor3 = Config.Text.Color
				title.TextSize = Config.Text.TitleSize
				title.TextTransparency = 0.15
				title.BackgroundTransparency = 1
				title.Position = UDim2.new(0, 14, 1, -26)
				title.Size = UDim2.new(1, -28, 0, 20)
				title.TextXAlignment = Enum.TextXAlignment.Left
				title.Parent = card

				container.Parent = parent
				return container
			end

			--// PUBLIC: SettingsCard (toggle row + slider row + optional button row)
			function SectionFunctions:SettingsCard(Settings)
				local rowsCount = 0
				if Settings.Toggle then rowsCount = rowsCount + 1 end
				if Settings.Slider  then rowsCount = rowsCount + 1 end
				if Settings.Button  then rowsCount = rowsCount + 1 end
				if Settings.Dropdown then rowsCount = rowsCount + 1 end
				if Settings.TextBox then rowsCount = rowsCount + 1 end
				if Settings.Keybind then rowsCount = rowsCount + 1 end

				local rowH = Config.Toggle.Height
				local dynamicHeight = Config.Card.Padding * 2 + rowH * rowsCount + 10 * math.max(0, rowsCount - 1)

				local container, card = CreateLayeredCard("SettingsCard", dynamicHeight)

				local cardPad = Instance.new("UIPadding")
				cardPad.PaddingLeft  = UDim.new(0, Config.Card.Padding)
				cardPad.PaddingRight = UDim.new(0, Config.Card.Padding)
				cardPad.PaddingTop   = UDim.new(0, Config.Card.Padding)
				cardPad.PaddingBottom = UDim.new(0, Config.Card.Padding)
				cardPad.Parent = card

				local cardLayout = Instance.new("UIListLayout")
				cardLayout.Padding = UDim.new(0, 10)
				cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
				cardLayout.Parent = card

				local CardFunctions = {}
				local layoutOrder = 0

				-- Toggle row
				if Settings.Toggle then
					layoutOrder = layoutOrder + 1
					local row = Instance.new("Frame")
					row.BackgroundTransparency = 1
					row.Size = UDim2.new(1, 0, 0, rowH)
					row.LayoutOrder = layoutOrder

					local name = Instance.new("TextLabel")
					name.FontFace = Font.new(Config.Text.Font)
					name.Text = Settings.Toggle.Name or "Enabled"
					name.TextColor3 = Config.Text.Color
					name.TextSize = Config.Text.TitleSize
					name.TextTransparency = 0.15
					name.BackgroundTransparency = 1
					name.Size = UDim2.new(1, -50, 1, 0)
					name.TextXAlignment = Enum.TextXAlignment.Left
					name.Parent = row

					local toggleFuncs = CreateToggle(row, Settings.Toggle.Default, Settings.Toggle.Callback,
						UDim2.new(1, -Config.Toggle.Width, 0.5, -rowH / 2))
					row.Parent = card

					CardFunctions.Toggle = toggleFuncs
				end

				-- Slider row
				if Settings.Slider then
					layoutOrder = layoutOrder + 1
					local row = Instance.new("Frame")
					row.BackgroundTransparency = 1
					row.Size = UDim2.new(1, 0, 0, rowH)
					row.LayoutOrder = layoutOrder

					local name = Instance.new("TextLabel")
					name.FontFace = Font.new(Config.Text.Font)
					name.Text = Settings.Slider.Name or "Smoothing"
					name.TextColor3 = Config.Text.Color
					name.TextSize = Config.Text.TitleSize
					name.TextTransparency = 0.15
					name.BackgroundTransparency = 1
					name.Size = UDim2.new(0, 80, 1, 0)
					name.TextXAlignment = Enum.TextXAlignment.Left
					name.Parent = row

					local sliderWidth = 120
					local track = Instance.new("Frame")
					track.BackgroundColor3 = Config.Slider.TrackColor
					track.BackgroundTransparency = 0.2
					track.BorderSizePixel = 0
					track.Position = UDim2.new(1, -sliderWidth, 0.5, -Config.Slider.TrackHeight / 2)
					track.Size = UDim2.fromOffset(sliderWidth, Config.Slider.TrackHeight)
					local trackCorner = Instance.new("UICorner")
					trackCorner.CornerRadius = UDim.new(1, 0)
					trackCorner.Parent = track
					track.Parent = row

					local defVal = (Settings.Slider.Default or 60) / (Settings.Slider.Max or 100)
					local fill = Instance.new("Frame")
					fill.BackgroundColor3 = Config.Slider.FillColor
					fill.BackgroundTransparency = 0.1
					fill.BorderSizePixel = 0
					fill.Size = UDim2.new(defVal, 0, 1, 0)
					local fillCorner = Instance.new("UICorner")
					fillCorner.CornerRadius = UDim.new(1, 0)
					fillCorner.Parent = fill
					fill.Parent = track

					local knob = Instance.new("Frame")
					knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					knob.BorderSizePixel = 0
					knob.Size = UDim2.fromOffset(Config.Slider.KnobSize, Config.Slider.KnobSize)
					knob.Position = UDim2.new(defVal, -Config.Slider.KnobSize / 2, 0.5, -Config.Slider.KnobSize / 2)
					local knobCorner = Instance.new("UICorner")
					knobCorner.CornerRadius = UDim.new(1, 0)
					knobCorner.Parent = knob
					knob.Parent = track

					local valueLabel = Instance.new("TextLabel")
					valueLabel.FontFace = Font.new(Config.Text.Font)
					valueLabel.Text = tostring(Settings.Slider.Default or 60)
					valueLabel.TextColor3 = Config.Text.DimColor
					valueLabel.TextSize = 10
					valueLabel.TextTransparency = 0.3
					valueLabel.BackgroundTransparency = 1
					valueLabel.Size = UDim2.new(0, 30, 1, 0)
					valueLabel.Position = UDim2.new(1, -sliderWidth - 35, 0, 0)
					valueLabel.TextXAlignment = Enum.TextXAlignment.Right
					valueLabel.Parent = row

					local sliderDragging = false
					local function setFromX(x)
						local abs = track.AbsolutePosition.X
						local size = track.AbsoluteSize.X
						local alpha = math.clamp((x - abs) / size, 0, 1)
						fill.Size = UDim2.new(alpha, 0, 1, 0)
						knob.Position = UDim2.new(alpha, -Config.Slider.KnobSize / 2, 0.5, -Config.Slider.KnobSize / 2)
						local min = Settings.Slider.Min or 0
						local max = Settings.Slider.Max or 100
						local val = math.floor(min + (max - min) * alpha)
						valueLabel.Text = tostring(val)
						if Settings.Slider.Callback then
							Settings.Slider.Callback(val)
						end
					end
					track.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							sliderDragging = true
							setFromX(input.Position.X)
						end
					end)
					UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							sliderDragging = false
						end
					end)
					UserInputService.InputChanged:Connect(function(input)
						if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
							setFromX(input.Position.X)
						end
					end)

					CardFunctions.Slider = {
						Set = function(value)
							local min = Settings.Slider.Min or 0
							local max = Settings.Slider.Max or 100
							local alpha = math.clamp((value - min) / (max - min), 0, 1)
							fill.Size = UDim2.new(alpha, 0, 1, 0)
							knob.Position = UDim2.new(alpha, -Config.Slider.KnobSize / 2, 0.5, -Config.Slider.KnobSize / 2)
							valueLabel.Text = tostring(value)
							if Settings.Slider.Callback then Settings.Slider.Callback(value) end
						end,
						Get = function()
							local min = Settings.Slider.Min or 0
							local max = Settings.Slider.Max or 100
							local alpha = fill.Size.X.Scale
							return math.floor(min + (max - min) * alpha)
						end
					}

					row.Parent = card
				end

				-- Button row
				if Settings.Button then
					layoutOrder = layoutOrder + 1
					local row = Instance.new("Frame")
					row.BackgroundTransparency = 1
					row.Size = UDim2.new(1, 0, 0, rowH)
					row.LayoutOrder = layoutOrder

					local name = Instance.new("TextLabel")
					name.FontFace = Font.new(Config.Text.Font)
					name.Text = Settings.Button.Name or "Button"
					name.TextColor3 = Config.Text.Color
					name.TextSize = Config.Text.TitleSize
					name.TextTransparency = 0.15
					name.BackgroundTransparency = 1
					name.Size = UDim2.new(0, 80, 1, 0)
					name.TextXAlignment = Enum.TextXAlignment.Left
					name.Parent = row

					local btnW = 60
					local btn = Instance.new("TextButton")
					btn.FontFace = Font.new(Config.Text.Font, Enum.FontWeight.Medium)
					btn.Text = Settings.Button.Label or "Action"
					btn.TextColor3 = Config.Text.Color
					btn.TextSize = Config.Text.TitleSize
					btn.TextTransparency = 0.1
					btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					btn.BackgroundTransparency = 0.78
					btn.BorderSizePixel = 0
					btn.Size = UDim2.fromOffset(btnW, rowH)
					btn.Position = UDim2.new(1, -btnW, 0, 0)
					btn.AutoButtonColor = false

					local btnCorner = Instance.new("UICorner")
					btnCorner.CornerRadius = UDim.new(0, 7)
					btnCorner.Parent = btn

					btn.MouseEnter:Connect(function()
						Tween(btn, TweenInfo.new(0.1), { BackgroundTransparency = 0.65 })
					end)
					btn.MouseLeave:Connect(function()
						Tween(btn, TweenInfo.new(0.1), { BackgroundTransparency = 0.78 })
					end)
					btn.MouseButton1Down:Connect(function()
						Tween(btn, TweenInfo.new(0.07), { BackgroundTransparency = 0.5 })
					end)
					btn.MouseButton1Click:Connect(function()
						Tween(btn, TweenInfo.new(0.1), { BackgroundTransparency = 0.78 })
						if Settings.Button.Callback then Settings.Button.Callback() end
					end)

					btn.Parent = row
					row.Parent = card
				end

				-- Dropdown row
				if Settings.Dropdown then
					layoutOrder = layoutOrder + 1
					local row = Instance.new("Frame")
					row.BackgroundTransparency = 1
					row.Size = UDim2.new(1, 0, 0, rowH)
					row.LayoutOrder = layoutOrder

					local name = Instance.new("TextLabel")
					name.FontFace = Font.new(Config.Text.Font)
					name.Text = Settings.Dropdown.Name or "Dropdown"
					name.TextColor3 = Config.Text.Color
					name.TextSize = Config.Text.TitleSize
					name.TextTransparency = 0.15
					name.BackgroundTransparency = 1
					name.Size = UDim2.new(0, 80, 1, 0)
					name.TextXAlignment = Enum.TextXAlignment.Left
					name.Parent = row

					local dropdownW = 120
					local dropdown = Instance.new("TextButton")
					dropdown.FontFace = Font.new(Config.Text.Font)
					dropdown.Text = Settings.Dropdown.Default or "Select..."
					dropdown.TextColor3 = Config.Text.Color
					dropdown.TextSize = 11
					dropdown.TextTransparency = 0.2
					dropdown.BackgroundColor3 = Config.Dropdown.BackgroundColor
					dropdown.BackgroundTransparency = Config.Dropdown.BackgroundTransparency
					dropdown.BorderSizePixel = 0
					dropdown.Size = UDim2.fromOffset(dropdownW, rowH)
					dropdown.Position = UDim2.new(1, -dropdownW, 0, 0)
					dropdown.AutoButtonColor = false

					local ddCorner = Instance.new("UICorner")
					ddCorner.CornerRadius = UDim.new(0, Config.Dropdown.CornerRadius)
					ddCorner.Parent = dropdown

					local ddIcon = Instance.new("ImageLabel")
					ddIcon.Image = Icons.chevron_down
					ddIcon.ImageTransparency = 0.3
					ddIcon.BackgroundTransparency = 1
					ddIcon.Size = UDim2.fromOffset(12, 12)
					ddIcon.Position = UDim2.new(1, -18, 0.5, -6)
					ddIcon.Parent = dropdown

					local isOpen = false
					local selected = Settings.Dropdown.Default

					local dropdownMenu = Instance.new("Frame")
					dropdownMenu.BackgroundColor3 = Config.Window.BaseColor
					dropdownMenu.BackgroundTransparency = 0.05
					dropdownMenu.BorderSizePixel = 0
					dropdownMenu.Size = UDim2.fromOffset(dropdownW, 0)
					dropdownMenu.Position = UDim2.new(1, -dropdownW, 0, rowH + 4)
					dropdownMenu.Visible = false
					dropdownMenu.ZIndex = 10

					local menuCorner = Instance.new("UICorner")
					menuCorner.CornerRadius = UDim.new(0, 8)
					menuCorner.Parent = dropdownMenu

					local menuLayout = Instance.new("UIListLayout")
					menuLayout.Padding = UDim.new(0, 2)
					menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
					menuLayout.Parent = dropdownMenu

					local menuPad = Instance.new("UIPadding")
					menuPad.PaddingTop = UDim.new(0, 4)
					menuPad.PaddingBottom = UDim.new(0, 4)
					menuPad.Parent = dropdownMenu

					for i, option in ipairs(Settings.Dropdown.Options or {}) do
						local optBtn = Instance.new("TextButton")
						optBtn.FontFace = Font.new(Config.Text.Font)
						optBtn.Text = option
						optBtn.TextColor3 = Config.Text.Color
						optBtn.TextSize = 11
						optBtn.TextTransparency = 0.2
						optBtn.BackgroundTransparency = 1
						optBtn.Size = UDim2.new(1, 0, 0, 24)
						optBtn.AutoButtonColor = false
						optBtn.Parent = dropdownMenu

						optBtn.MouseEnter:Connect(function()
							Tween(optBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0.9 })
						end)
						optBtn.MouseLeave:Connect(function()
							Tween(optBtn, TweenInfo.new(0.1), { BackgroundTransparency = 1 })
						end)
						optBtn.MouseButton1Click:Connect(function()
							selected = option
							dropdown.Text = option
							isOpen = false
							Tween(dropdownMenu, TweenInfo.new(0.2), { Size = UDim2.fromOffset(dropdownW, 0) })
							task.wait(0.2)
							dropdownMenu.Visible = false
							if Settings.Dropdown.Callback then Settings.Dropdown.Callback(option) end
						end)
					end

					dropdownMenu.Parent = row

					dropdown.MouseButton1Click:Connect(function()
						isOpen = not isOpen
						if isOpen then
							dropdownMenu.Visible = true
							local itemCount = math.min(#(Settings.Dropdown.Options or {}), Config.Dropdown.MaxItems)
							Tween(dropdownMenu, TweenInfo.new(0.2), { Size = UDim2.fromOffset(dropdownW, itemCount * 26 + 8) })
						else
							Tween(dropdownMenu, TweenInfo.new(0.2), { Size = UDim2.fromOffset(dropdownW, 0) })
							task.wait(0.2)
							dropdownMenu.Visible = false
						end
					end)

					CardFunctions.Dropdown = {
						Set = function(value)
							selected = value
							dropdown.Text = value
							if Settings.Dropdown.Callback then Settings.Dropdown.Callback(value) end
						end,
						Get = function() return selected end
					}

					row.Parent = card
				end

				-- TextBox row
				if Settings.TextBox then
					layoutOrder = layoutOrder + 1
					local row = Instance.new("Frame")
					row.BackgroundTransparency = 1
					row.Size = UDim2.new(1, 0, 0, rowH)
					row.LayoutOrder = layoutOrder

					local name = Instance.new("TextLabel")
					name.FontFace = Font.new(Config.Text.Font)
					name.Text = Settings.TextBox.Name or "Input"
					name.TextColor3 = Config.Text.Color
					name.TextSize = Config.Text.TitleSize
					name.TextTransparency = 0.15
					name.BackgroundTransparency = 1
					name.Size = UDim2.new(0, 80, 1, 0)
					name.TextXAlignment = Enum.TextXAlignment.Left
					name.Parent = row

					local tbW = 120
					local textBox = Instance.new("TextBox")
					textBox.FontFace = Font.new(Config.Text.Font)
					textBox.Text = Settings.TextBox.Default or ""
					textBox.PlaceholderText = Settings.TextBox.Placeholder or "Type..."
					textBox.PlaceholderColor3 = Color3.fromRGB(160, 160, 160)
					textBox.TextColor3 = Config.Text.Color
					textBox.TextSize = 11
					textBox.TextTransparency = 0.2
					textBox.BackgroundColor3 = Config.TextBox.BackgroundColor
					textBox.BackgroundTransparency = Config.TextBox.BackgroundTransparency
					textBox.BorderSizePixel = 0
					textBox.Size = UDim2.fromOffset(tbW, rowH)
					textBox.Position = UDim2.new(1, -tbW, 0, 0)
					textBox.ClearTextOnFocus = false

					local tbCorner = Instance.new("UICorner")
					tbCorner.CornerRadius = UDim.new(0, Config.TextBox.CornerRadius)
					tbCorner.Parent = textBox

					textBox.FocusLost:Connect(function(enterPressed)
						if Settings.TextBox.Callback then
							Settings.TextBox.Callback(textBox.Text, enterPressed)
						end
					end)

					CardFunctions.TextBox = {
						Set = function(value)
							textBox.Text = value
							if Settings.TextBox.Callback then Settings.TextBox.Callback(value, false) end
						end,
						Get = function() return textBox.Text end
					}

					textBox.Parent = row
					row.Parent = card
				end

				-- Keybind row
				if Settings.Keybind then
					layoutOrder = layoutOrder + 1
					local row = Instance.new("Frame")
					row.BackgroundTransparency = 1
					row.Size = UDim2.new(1, 0, 0, rowH)
					row.LayoutOrder = layoutOrder

					local name = Instance.new("TextLabel")
					name.FontFace = Font.new(Config.Text.Font)
					name.Text = Settings.Keybind.Name or "Keybind"
					name.TextColor3 = Config.Text.Color
					name.TextSize = Config.Text.TitleSize
					name.TextTransparency = 0.15
					name.BackgroundTransparency = 1
					name.Size = UDim2.new(0, 80, 1, 0)
					name.TextXAlignment = Enum.TextXAlignment.Left
					name.Parent = row

					local kbW = 80
					local keybindBtn = Instance.new("TextButton")
					keybindBtn.FontFace = Font.new(Config.Text.Font, Enum.FontWeight.Medium)
					keybindBtn.Text = Settings.Keybind.Default and tostring(Settings.Keybind.Default):gsub("Enum.KeyCode.", "") or "None"
					keybindBtn.TextColor3 = Config.Text.Color
					keybindBtn.TextSize = 10
					keybindBtn.TextTransparency = 0.2
					keybindBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					keybindBtn.BackgroundTransparency = 0.85
					keybindBtn.BorderSizePixel = 0
					keybindBtn.Size = UDim2.fromOffset(kbW, rowH)
					keybindBtn.Position = UDim2.new(1, -kbW, 0, 0)
					keybindBtn.AutoButtonColor = false

					local kbCorner = Instance.new("UICorner")
					kbCorner.CornerRadius = UDim.new(0, 6)
					kbCorner.Parent = keybindBtn

					local listening = false
					local currentKey = Settings.Keybind.Default

					keybindBtn.MouseButton1Click:Connect(function()
						listening = true
						keybindBtn.Text = "..."
					end)

					UserInputService.InputBegan:Connect(function(input, gameProcessed)
						if listening and not gameProcessed then
							if input.UserInputType == Enum.UserInputType.Keyboard then
								currentKey = input.KeyCode
								keybindBtn.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
								listening = false
								if Settings.Keybind.Callback then
									Settings.Keybind.Callback(input.KeyCode)
								end
							end
						elseif currentKey and input.KeyCode == currentKey and not gameProcessed then
							if Settings.Keybind.Callback then
								Settings.Keybind.Callback(currentKey)
							end
						end
					end)

					CardFunctions.Keybind = {
						Set = function(key)
							currentKey = key
							keybindBtn.Text = tostring(key):gsub("Enum.KeyCode.", "")
						end,
						Get = function() return currentKey end
					}

					keybindBtn.Parent = row
					row.Parent = card
				end

				container.Parent = parent
				return CardFunctions
			end

			--// PUBLIC: ModuleCard
			function SectionFunctions:ModuleCard(Settings)
				local cardH = Settings.Height or 160

				local container, card = CreateLayeredCard(Settings.Title or "ModuleCard", cardH)

				local titleLabel = Instance.new("TextLabel")
				titleLabel.FontFace = Font.new(Config.Text.Font, Enum.FontWeight.SemiBold)
				titleLabel.Text = Settings.Title or "Module"
				titleLabel.TextColor3 = Config.Text.Color
				titleLabel.TextSize = 13
				titleLabel.TextTransparency = 0.05
				titleLabel.BackgroundTransparency = 1
				titleLabel.Position = UDim2.new(0, 14, 0, 13)
				titleLabel.Size = UDim2.new(1, -(Config.Toggle.Width + 26), 0, 16)
				titleLabel.TextXAlignment = Enum.TextXAlignment.Left
				titleLabel.Parent = card

				local subtitleLabel = Instance.new("TextLabel")
				subtitleLabel.FontFace = Font.new(Config.Text.Font)
				subtitleLabel.Text = Settings.Subtitle or ""
				subtitleLabel.TextColor3 = Config.Text.DimColor
				subtitleLabel.TextSize = 10
				subtitleLabel.TextTransparency = 0.25
				subtitleLabel.BackgroundTransparency = 1
				subtitleLabel.Position = UDim2.new(0, 14, 0, 31)
				subtitleLabel.Size = UDim2.new(1, -(Config.Toggle.Width + 26), 0, 13)
				subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
				subtitleLabel.Parent = card

				if Settings.Toggle ~= nil then
					CreateToggle(card, Settings.Toggle, Settings.Callback,
						UDim2.new(1, -Config.Toggle.Width - 14, 0, 13))
				end

				if Settings.Actions and #Settings.Actions > 0 then
					local actLabel = Instance.new("TextLabel")
					actLabel.FontFace = Font.new(Config.Text.Font)
					actLabel.Text = "Actions"
					actLabel.TextColor3 = Config.Text.DimColor
					actLabel.TextSize = 10
					actLabel.TextTransparency = 0.3
					actLabel.BackgroundTransparency = 1
					actLabel.Position = UDim2.new(0, 14, 0, 54)
					actLabel.Size = UDim2.new(1, -28, 0, 12)
					actLabel.TextXAlignment = Enum.TextXAlignment.Left
					actLabel.Parent = card

					local actRow = Instance.new("Frame")
					actRow.BackgroundTransparency = 1
					actRow.Position = UDim2.new(0, 10, 0, 70)
					actRow.Size = UDim2.new(1, -20, 0, 54)
					actRow.Parent = card

					local actLayout = Instance.new("UIListLayout")
					actLayout.FillDirection = Enum.FillDirection.Horizontal
					actLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
					actLayout.VerticalAlignment = Enum.VerticalAlignment.Top
					actLayout.SortOrder = Enum.SortOrder.LayoutOrder
					actLayout.Padding = UDim.new(0, 6)
					actLayout.Parent = actRow

					for i, action in ipairs(Settings.Actions) do
						local slot = Instance.new("Frame")
						slot.BackgroundTransparency = 1
						slot.Size = UDim2.fromOffset(40, 54)
						slot.LayoutOrder = i
						slot.Parent = actRow

						local circle = Instance.new("ImageButton")
						circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
						circle.BackgroundTransparency = 0.82
						circle.BorderSizePixel = 0
						circle.Size = UDim2.fromOffset(36, 36)
						circle.AnchorPoint = Vector2.new(0.5, 0)
						circle.Position = UDim2.new(0.5, 0, 0, 0)
						circle.AutoButtonColor = false
						local circCorner = Instance.new("UICorner")
						circCorner.CornerRadius = UDim.new(1, 0)
						circCorner.Parent = circle

						local circIcon = Instance.new("ImageLabel")
						circIcon.Image = action.Icon or Icons.zap
						circIcon.ImageTransparency = 0.2
						circIcon.BackgroundTransparency = 1
						circIcon.Size = UDim2.fromOffset(16, 16)
						circIcon.AnchorPoint = Vector2.new(0.5, 0.5)
						circIcon.Position = UDim2.fromScale(0.5, 0.5)
						circIcon.Parent = circle

						circle.MouseEnter:Connect(function()
							Tween(circle, TweenInfo.new(0.1), { BackgroundTransparency = 0.68 })
						end)
						circle.MouseLeave:Connect(function()
							Tween(circle, TweenInfo.new(0.1), { BackgroundTransparency = 0.82 })
						end)
						circle.MouseButton1Down:Connect(function()
							Tween(circle, TweenInfo.new(0.07), { BackgroundTransparency = 0.55 })
						end)
						circle.MouseButton1Click:Connect(function()
							Tween(circle, TweenInfo.new(0.1), { BackgroundTransparency = 0.82 })
							if action.Callback then action.Callback() end
						end)

						circle.Parent = slot

						local lblText = Instance.new("TextLabel")
						lblText.FontFace = Font.new(Config.Text.Font)
						lblText.Text = action.Name or ""
						lblText.TextColor3 = Config.Text.DimColor
						lblText.TextSize = 9
						lblText.TextTransparency = 0.2
						lblText.BackgroundTransparency = 1
						lblText.Size = UDim2.new(1, 0, 0, 14)
						lblText.Position = UDim2.new(0, 0, 0, 38)
						lblText.TextXAlignment = Enum.TextXAlignment.Center
						lblText.Parent = slot
					end
				end

				container.Parent = parent
				return container
			end

			--// PUBLIC: ColorPickerCard
			function SectionFunctions:ColorPickerCard(Settings)
				local container, card = CreateLayeredCard(Settings.Title or "ColorPicker", 180)

				local titleLabel = Instance.new("TextLabel")
				titleLabel.FontFace = Font.new(Config.Text.Font, Enum.FontWeight.Medium)
				titleLabel.Text = Settings.Title or "Color"
				titleLabel.TextColor3 = Config.Text.Color
				titleLabel.TextSize = 12
				titleLabel.TextTransparency = 0.15
				titleLabel.BackgroundTransparency = 1
				titleLabel.Position = UDim2.new(0, 14, 0, 12)
				titleLabel.Size = UDim2.new(1, -28, 0, 18)
				titleLabel.TextXAlignment = Enum.TextXAlignment.Left
				titleLabel.Parent = card

				local pickerSize = Config.ColorPicker.Size
				local pickerFrame = Instance.new("Frame")
				pickerFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				pickerFrame.BackgroundTransparency = 0.9
				pickerFrame.BorderSizePixel = 0
				pickerFrame.Size = UDim2.fromOffset(pickerSize, 100)
				pickerFrame.Position = UDim2.new(0.5, -pickerSize/2, 0, 38)
				pickerFrame.Parent = card

				local pickerCorner = Instance.new("UICorner")
				pickerCorner.CornerRadius = UDim.new(0, 8)
				pickerCorner.Parent = pickerFrame

				-- Saturation/Value square
				local svFrame = Instance.new("Frame")
				svFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				svFrame.BorderSizePixel = 0
				svFrame.Size = UDim2.new(1, -20, 1, -20)
				svFrame.Position = UDim2.new(0, 10, 0, 10)
				svFrame.Parent = pickerFrame

				local svGradient = Instance.new("UIGradient")
				svGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
				})
				svGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1)
				})
				svGradient.Parent = svFrame

				local svDark = Instance.new("Frame")
				svDark.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				svDark.BorderSizePixel = 0
				svDark.Size = UDim2.fromScale(1, 1)
				svDark.Parent = svFrame

				local svDarkGradient = Instance.new("UIGradient")
				svDarkGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
				})
				svDarkGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 0)
				})
				svDarkGradient.Rotation = 90
				svDarkGradient.Parent = svDark

				-- Hue slider
				local hueFrame = Instance.new("Frame")
				hueFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				hueFrame.BorderSizePixel = 0
				hueFrame.Size = UDim2.new(1, -20, 0, 12)
				hueFrame.Position = UDim2.new(0, 10, 1, -14)
				hueFrame.Parent = pickerFrame

				local hueGradient = Instance.new("UIGradient")
				hueGradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
					ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
					ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
				})
				hueGradient.Parent = hueFrame

				local hueCorner = Instance.new("UICorner")
				hueCorner.CornerRadius = UDim.new(0, 4)
				hueCorner.Parent = hueFrame

				-- Preview
				local preview = Instance.new("Frame")
				preview.BackgroundColor3 = Settings.Default or Color3.fromRGB(0, 170, 255)
				preview.BorderSizePixel = 0
				preview.Size = UDim2.fromOffset(24, 24)
				preview.Position = UDim2.new(1, -38, 0, 8)
				preview.Parent = card

				local previewCorner = Instance.new("UICorner")
				previewCorner.CornerRadius = UDim.new(0, 6)
				previewCorner.Parent = preview

				local currentHue = 0
				local currentSat = 1
				local currentVal = 1

				local function updateColor()
					local color = Color3.fromHSV(currentHue, currentSat, currentVal)
					preview.BackgroundColor3 = color
					svFrame.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
					if Settings.Callback then Settings.Callback(color) end
				end

				-- Simple click handlers for hue and sv
				hueFrame.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local abs = hueFrame.AbsolutePosition.X
						local size = hueFrame.AbsoluteSize.X
						currentHue = math.clamp((input.Position.X - abs) / size, 0, 1)
						updateColor()
					end
				end)

				svFrame.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local absX = svFrame.AbsolutePosition.X
						local absY = svFrame.AbsolutePosition.Y
						local sizeX = svFrame.AbsoluteSize.X
						local sizeY = svFrame.AbsoluteSize.Y
						currentSat = math.clamp((input.Position.X - absX) / sizeX, 0, 1)
						currentVal = 1 - math.clamp((input.Position.Y - absY) / sizeY, 0, 1)
						updateColor()
					end
				end)

				container.Parent = parent

				return {
					Set = function(color)
						local h, s, v = color:ToHSV()
						currentHue, currentSat, currentVal = h, s, v
						preview.BackgroundColor3 = color
						svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
						if Settings.Callback then Settings.Callback(color) end
					end,
					Get = function()
						return Color3.fromHSV(currentHue, currentSat, currentVal)
					end
				}
			end

			--// PUBLIC: LabelCard
			function SectionFunctions:LabelCard(Settings)
				local container, card = CreateLayeredCard(Settings.Title or "Label", 60)

				local label = Instance.new("TextLabel")
				label.FontFace = Font.new(Config.Text.Font)
				label.Text = Settings.Text or "Label"
				label.TextColor3 = Settings.Color or Config.Text.Color
				label.TextSize = Settings.Size or 12
				label.TextTransparency = 0.15
				label.BackgroundTransparency = 1
				label.Position = UDim2.new(0, 14, 0, 0)
				label.Size = UDim2.new(1, -28, 1, 0)
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.TextWrapped = true
				label.Parent = card

				container.Parent = parent

				return {
					Set = function(text)
						label.Text = text
					end,
					Get = function()
						return label.Text
					end
				}
			end

			--// PUBLIC: Divider
			function SectionFunctions:Divider()
				local div = Instance.new("Frame")
				div.Name = "Divider"
				div.BackgroundColor3 = Config.Text.DimColor
				div.BackgroundTransparency = 0.8
				div.BorderSizePixel = 0
				div.Size = UDim2.new(1, 0, 0, 1)
				div.Parent = parent
			end

			return SectionFunctions
		end

		return TabFunctions
	end

	--// DRAGGING (via topbar)
	local dragging = false
	local dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	local dragBar = Instance.new("TextButton")
	dragBar.Name = "DragBar"
	dragBar.Text = ""
	dragBar.AutoButtonColor = false
	dragBar.BackgroundTransparency = 1
	dragBar.BorderSizePixel = 0
	dragBar.Size = UDim2.new(1, -260, 1, 0)
	dragBar.Position = UDim2.new(0, 240, 0, 0)
	dragBar.ZIndex = 0
	dragBar.Parent = topbar

	dragBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = base.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	dragBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then update(input) end
	end)

	--// PRELOAD
	local assetList = {}
	for _, v in pairs(Icons) do table.insert(assetList, v) end
	ContentProvider:PreloadAsync(assetList)
	macLib.Enabled = true

	return WindowFunctions
end

--// ============================================================
--// DEMO / EXAMPLE USAGE
--// ============================================================
--[[
local Window = MacLib:Window({
	Title = "Dashboard",
	Size = Config.Window.Size,
	AcrylicBlur = Config.Window.AcrylicBlur,
})

-- Sidebar icons
local MainTab     = Window:Tab({ Name = "Main",     Icon = Icons.aperture, LayoutOrder = 1, Subtabs = {"Subtab 1", "Subtab 2"} })
local UserTab     = Window:Tab({ Name = "User",     Icon = Icons.user,     LayoutOrder = 2 })
local EyeTab      = Window:Tab({ Name = "Eye",      Icon = Icons.eye,      LayoutOrder = 3 })
local ClockTab    = Window:Tab({ Name = "Clock",    Icon = Icons.clock,    LayoutOrder = 4 })
local SettingsTab = Window:Tab({ Name = "Settings", Icon = Icons.settings, LayoutOrder = 5 })
local PowerTab    = Window:Tab({ Name = "Power",    Icon = Icons.power,    LayoutOrder = 6, IsPower = true })

-- Three column sections
local Left   = MainTab:Section({ Side = "Left"   })
local Middle = MainTab:Section({ Side = "Middle" })
local Right  = MainTab:Section({ Side = "Right"  })

-- Left Column
local LeftTopRow = Left:Row()
LeftTopRow:SmallCard({
	Title    = "Thing 1",
	Icon     = Icons.crosshair,
	Toggle   = true,
	Callback = function(v) print("Thing 1:", v) end,
})
LeftTopRow:SmallCard({
	Title    = "Thing 2",
	Icon     = Icons.box,
	Toggle   = false,
	Callback = function(v) print("Thing 2:", v) end,
})

Left:TallCard({
	Title    = "Thing 3",
	Icon     = Icons.zap,
	Toggle   = false,
	Callback = function(v) print("Thing 3:", v) end,
})

-- Middle Column
local settingsFuncs = Middle:SettingsCard({
	Toggle = {
		Name     = "Toggle",
		Default  = true,
		Callback = function(v) print("Toggle:", v) end,
	},
	Slider = {
		Name     = "Slider",
		Default  = 60,
		Min      = 0,
		Max      = 100,
		Callback = function(v) print("Slider:", v) end,
	},
	Button = {
		Name     = "Button",
		Label    = "Action",
		Callback = function() print("Action clicked") end,
	},
	Dropdown = {
		Name     = "Mode",
		Default  = "Option 1",
		Options  = {"Option 1", "Option 2", "Option 3"},
		Callback = function(v) print("Dropdown:", v) end,
	},
	TextBox = {
		Name      = "Input",
		Default   = "",
		Placeholder = "Enter text...",
		Callback  = function(text, enter) print("TextBox:", text, enter) end,
	},
	Keybind = {
		Name     = "Keybind",
		Default  = Enum.KeyCode.LeftShift,
		Callback = function(key) print("Keybind:", key) end,
	},
})

-- Right Column
Right:ModuleCard({
	Title    = "Module One",
	Subtitle = "Lorem ipsum nibh susciue",
	Toggle   = true,
	Callback = function(v) print("Module One:", v) end,
	Actions  = {
		{ Name = "One",   Icon = Icons.aperture, Callback = function() print("One")   end },
		{ Name = "Two",   Icon = Icons.box,      Callback = function() print("Two")   end },
		{ Name = "Three", Icon = Icons.zap,      Callback = function() print("Three") end },
		{ Name = "Four",  Icon = Icons.eye,      Callback = function() print("Four")  end },
	},
})

Right:ModuleCard({
	Title    = "Module Two",
	Subtitle = "Lorem ipsum nibh susciue",
	Toggle   = false,
	Callback = function(v) print("Module Two:", v) end,
	Actions  = {
		{ Name = "One",   Icon = Icons.aperture, Callback = function() print("One")   end },
		{ Name = "Two",   Icon = Icons.box,      Callback = function() print("Two")   end },
		{ Name = "Three", Icon = Icons.zap,      Callback = function() print("Three") end },
		{ Name = "Four",  Icon = Icons.eye,      Callback = function() print("Four")  end },
	},
})

-- Notifications
MacLib:Notify({
	Title = "Welcome",
	Message = "MacLib UI Framework loaded successfully!",
	Icon = Icons.check,
	IconColor = Config.Text.SuccessColor,
	Duration = 4
})
--]]

return MacLib
