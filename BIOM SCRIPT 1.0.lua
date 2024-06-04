--아래의 모든 스크립트는 원작자 BIOM에게있고 저작권또한 BIOM에게있습니다.
--디스코드 : BIOM #3393
--라이브러리
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("BIOM SCRIPT HUB", "Ocean")

--MAIN 스크롤
local MAIN = Window:NewTab("MAIN")
local Section = MAIN:NewSection("BIOM SCRIPT")
--속도추가
Section:NewSlider("SPEED", "SPEED UP", 500, 0, function(s) -- 500 (MaxValue) | 0 (MinValue)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

--점프추가
Section:NewSlider("JUMP", "JUMP UP", 500, 0, function(j) -- 500 (MaxValue) | 0 (MinValue)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = j
end)

--에임봇
_G.aimbot = false
local camera = game.Workspace.CurrentCamera
local localplayer = game:GetService("Players").LocalPlayer

Section:NewToggle("AIM BOT", "AIM BOT", function(state)
    if _G.aimbot == false then
		_G.aimbot = true
		function closestplayer()
			local dist = math.huge -- math.huge means a really large number, 1M+.
			local target = nil --- nil means no value
			for i,v in pairs (game:GetService("Players"):GetPlayers()) do
				if v ~= localplayer then
					if v.Character and v.Character:FindFirstChild("Head") and _G.aimbot and v.Character.Humanoid.Health > 0 then --- creating the checks
						local magnitude = (v.Character.Head.Position - localplayer.Character.Head.Position).magnitude
						if magnitude < dist then
							dist = magnitude
							target = v
						end

					end
				end
			end
			return target
		end

	else
		_G.aimbot = false
	end
end)

local settings = {
	keybind = Enum.UserInputType.MouseButton2
}

local UIS = game:GetService("UserInputService")
local aiming = false 

UIS.InputBegan:Connect(function(inp)
	if inp.UserInputType == settings.keybind then
		aiming = true
	end
end)

UIS.InputEnded:Connect(function(inp)
	if inp.UserInputType == settings.keybind then 
		aiming = false
	end
end)

game:GetService("RunService").RenderStepped:Connect(function()
	if aiming then
		camera.CFrame = CFrame.new(camera.CFrame.Position,closestplayer().Character.Head.Position) 
	end
end)

--플레이어 텔러포트
Section:NewTextBox("PLAYER TP", "PLAYER NAME IS HERE", function(NAME)
    local Victim = NAME
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[Victim].Character.HumanoidRootPart.CFrame
end)

--ESP
Section:NewButton("ESP", "PLAYER ESP", function()
	_G.WRDESPEnabled = nil 
	_G.WRDESPBoxes = nil 
	_G.WRDESPTeamColors = nil 
	_G.WRDESPTracers = nil --Displays lines leading to other players (Defaults to false)
	_G.WRDESPNames = nil --Displays the names of the players within the ESP box (Defaults to true)

	--Dont edit below

	--Only ever load the script once
	if not _G.WRDESPLoaded then    
		----[[ First- Load Kiriot ESP Library ]]----

		--Settings--
		local ESP = {
			Enabled = false,
			Boxes = true,
			BoxShift = CFrame.new(0,-1.5,0),
			BoxSize = Vector3.new(4,6,0),
			Color = Color3.fromRGB(255, 170, 0),
			FaceCamera = false,
			Names = true,
			TeamColor = true,
			Thickness = 2,
			AttachShift = 1,
			TeamMates = true,
			Players = true,

			Objects = setmetatable({}, {__mode="kv"}),
			Overrides = {}
		}

		--Declarations--
		local cam = workspace.CurrentCamera
		local plrs = game:GetService("Players")
		local plr = plrs.LocalPlayer
		local mouse = plr:GetMouse()

		local V3new = Vector3.new
		local WorldToViewportPoint = cam.WorldToViewportPoint

		--Functions--
		local function Draw(obj, props)
			local new = Drawing.new(obj)

			props = props or {}
			for i,v in pairs(props) do
				new[i] = v
			end
			return new
		end

		function ESP:GetTeam(p)
			local ov = self.Overrides.GetTeam
			if ov then
				return ov(p)
			end

			return p and p.Team
		end

		function ESP:IsTeamMate(p)
			local ov = self.Overrides.IsTeamMate
			if ov then
				return ov(p)
			end

			return self:GetTeam(p) == self:GetTeam(plr)
		end

		function ESP:GetColor(obj)
			local ov = self.Overrides.GetColor
			if ov then
				return ov(obj)
			end
			local p = self:GetPlrFromChar(obj)
			return p and self.TeamColor and p.Team and p.Team.TeamColor.Color or self.Color
		end

		function ESP:GetPlrFromChar(char)
			local ov = self.Overrides.GetPlrFromChar
			if ov then
				return ov(char)
			end

			return plrs:GetPlayerFromCharacter(char)
		end

		function ESP:Toggle(bool)
			self.Enabled = bool
			if not bool then
				for i,v in pairs(self.Objects) do
					if v.Type == "Box" then --fov circle etc
						if v.Temporary then
							v:Remove()
						else
							for i,v in pairs(v.Components) do
								v.Visible = false
							end
						end
					end
				end
			end
		end

		function ESP:GetBox(obj)
			return self.Objects[obj]
		end

		function ESP:AddObjectListener(parent, options)
			local function NewListener(c)
				if type(options.Type) == "string" and c:IsA(options.Type) or options.Type == nil then
					if type(options.Name) == "string" and c.Name == options.Name or options.Name == nil then
						if not options.Validator or options.Validator(c) then
							local box = ESP:Add(c, {
								PrimaryPart = type(options.PrimaryPart) == "string" and c:WaitForChild(options.PrimaryPart) or type(options.PrimaryPart) == "function" and options.PrimaryPart(c),
								Color = type(options.Color) == "function" and options.Color(c) or options.Color,
								ColorDynamic = options.ColorDynamic,
								Name = type(options.CustomName) == "function" and options.CustomName(c) or options.CustomName,
								IsEnabled = options.IsEnabled,
								RenderInNil = options.RenderInNil
							})
							--TODO: add a better way of passing options
							if options.OnAdded then
								coroutine.wrap(options.OnAdded)(box)
							end
						end
					end
				end
			end

			if options.Recursive then
				parent.DescendantAdded:Connect(NewListener)
				for i,v in pairs(parent:GetDescendants()) do
					coroutine.wrap(NewListener)(v)
				end
			else
				parent.ChildAdded:Connect(NewListener)
				for i,v in pairs(parent:GetChildren()) do
					coroutine.wrap(NewListener)(v)
				end
			end
		end

		local boxBase = {}
		boxBase.__index = boxBase

		function boxBase:Remove()
			ESP.Objects[self.Object] = nil
			for i,v in pairs(self.Components) do
				v.Visible = false
				v:Remove()
				self.Components[i] = nil
			end
		end

		function boxBase:Update()
			if not self.PrimaryPart then
				--warn("not supposed to print", self.Object)
				return self:Remove()
			end

			local color
			if ESP.Highlighted == self.Object then
				color = ESP.HighlightColor
			else
				color = self.Color or self.ColorDynamic and self:ColorDynamic() or ESP:GetColor(self.Object) or ESP.Color
			end

			local allow = true
			if ESP.Overrides.UpdateAllow and not ESP.Overrides.UpdateAllow(self) then
				allow = false
			end
			if self.Player and not ESP.TeamMates and ESP:IsTeamMate(self.Player) then
				allow = false
			end
			if self.Player and not ESP.Players then
				allow = false
			end
			if self.IsEnabled and (type(self.IsEnabled) == "string" and not ESP[self.IsEnabled] or type(self.IsEnabled) == "function" and not self:IsEnabled()) then
				allow = false
			end
			if not workspace:IsAncestorOf(self.PrimaryPart) and not self.RenderInNil then
				allow = false
			end

			if not allow then
				for i,v in pairs(self.Components) do
					v.Visible = false
				end
				return
			end

			if ESP.Highlighted == self.Object then
				color = ESP.HighlightColor
			end

			--calculations--
			local cf = self.PrimaryPart.CFrame
			if ESP.FaceCamera then
				cf = CFrame.new(cf.p, cam.CFrame.p)
			end
			local size = self.Size
			local locs = {
				TopLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,size.Y/2,0),
				TopRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,size.Y/2,0),
				BottomLeft = cf * ESP.BoxShift * CFrame.new(size.X/2,-size.Y/2,0),
				BottomRight = cf * ESP.BoxShift * CFrame.new(-size.X/2,-size.Y/2,0),
				TagPos = cf * ESP.BoxShift * CFrame.new(0,size.Y/2,0),
				Torso = cf * ESP.BoxShift
			}

			if ESP.Boxes then
				local TopLeft, Vis1 = WorldToViewportPoint(cam, locs.TopLeft.p)
				local TopRight, Vis2 = WorldToViewportPoint(cam, locs.TopRight.p)
				local BottomLeft, Vis3 = WorldToViewportPoint(cam, locs.BottomLeft.p)
				local BottomRight, Vis4 = WorldToViewportPoint(cam, locs.BottomRight.p)

				if self.Components.Quad then
					if Vis1 or Vis2 or Vis3 or Vis4 then
						self.Components.Quad.Visible = true
						self.Components.Quad.PointA = Vector2.new(TopRight.X, TopRight.Y)
						self.Components.Quad.PointB = Vector2.new(TopLeft.X, TopLeft.Y)
						self.Components.Quad.PointC = Vector2.new(BottomLeft.X, BottomLeft.Y)
						self.Components.Quad.PointD = Vector2.new(BottomRight.X, BottomRight.Y)
						self.Components.Quad.Color = color
					else
						self.Components.Quad.Visible = false
					end
				end
			else
				self.Components.Quad.Visible = false
			end

			if ESP.Names then
				local TagPos, Vis5 = WorldToViewportPoint(cam, locs.TagPos.p)

				if Vis5 then
					self.Components.Name.Visible = true
					self.Components.Name.Position = Vector2.new(TagPos.X, TagPos.Y)
					self.Components.Name.Text = self.Name
					self.Components.Name.Color = color

					self.Components.Distance.Visible = true
					self.Components.Distance.Position = Vector2.new(TagPos.X, TagPos.Y + 14)
					self.Components.Distance.Text = math.floor((cam.CFrame.p - cf.p).magnitude) .."m away"
					self.Components.Distance.Color = color
				else
					self.Components.Name.Visible = false
					self.Components.Distance.Visible = false
				end
			else
				self.Components.Name.Visible = false
				self.Components.Distance.Visible = false
			end

			if ESP.Tracers then
				local TorsoPos, Vis6 = WorldToViewportPoint(cam, locs.Torso.p)

				if Vis6 then
					self.Components.Tracer.Visible = true
					self.Components.Tracer.From = Vector2.new(TorsoPos.X, TorsoPos.Y)
					self.Components.Tracer.To = Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/ESP.AttachShift)
					self.Components.Tracer.Color = color
				else
					self.Components.Tracer.Visible = false
				end
			else
				self.Components.Tracer.Visible = false
			end
		end

		function ESP:Add(obj, options)
			if not obj.Parent and not options.RenderInNil then
				return warn(obj, "has no parent")
			end

			local box = setmetatable({
				Name = options.Name or obj.Name,
				Type = "Box",
				Color = options.Color --[[or self:GetColor(obj)]],
				Size = options.Size or self.BoxSize,
				Object = obj,
				Player = options.Player or plrs:GetPlayerFromCharacter(obj),
				PrimaryPart = options.PrimaryPart or obj.ClassName == "Model" and (obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")) or obj:IsA("BasePart") and obj,
				Components = {},
				IsEnabled = options.IsEnabled,
				Temporary = options.Temporary,
				ColorDynamic = options.ColorDynamic,
				RenderInNil = options.RenderInNil
			}, boxBase)

			if self:GetBox(obj) then
				self:GetBox(obj):Remove()
			end

			box.Components["Quad"] = Draw("Quad", {
				Thickness = self.Thickness,
				Color = color,
				Transparency = 1,
				Filled = false,
				Visible = self.Enabled and self.Boxes
			})
			box.Components["Name"] = Draw("Text", {
				Text = box.Name,
				Color = box.Color,
				Center = true,
				Outline = true,
				Size = 19,
				Visible = self.Enabled and self.Names
			})
			box.Components["Distance"] = Draw("Text", {
				Color = box.Color,
				Center = true,
				Outline = true,
				Size = 19,
				Visible = self.Enabled and self.Names
			})

			box.Components["Tracer"] = Draw("Line", {
				Thickness = ESP.Thickness,
				Color = box.Color,
				Transparency = 1,
				Visible = self.Enabled and self.Tracers
			})
			self.Objects[obj] = box

			obj.AncestryChanged:Connect(function(_, parent)
				if parent == nil and ESP.AutoRemove ~= false then
					box:Remove()
				end
			end)
			obj:GetPropertyChangedSignal("Parent"):Connect(function()
				if obj.Parent == nil and ESP.AutoRemove ~= false then
					box:Remove()
				end
			end)

			local hum = obj:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.Died:Connect(function()
					if ESP.AutoRemove ~= false then
						box:Remove()
					end
				end)
			end

			return box
		end

		local function CharAdded(char)
			local p = plrs:GetPlayerFromCharacter(char)
			if not char:FindFirstChild("HumanoidRootPart") then
				local ev
				ev = char.ChildAdded:Connect(function(c)
					if c.Name == "HumanoidRootPart" then
						ev:Disconnect()
						ESP:Add(char, {
							Name = p.Name,
							Player = p,
							PrimaryPart = c
						})
					end
				end)
			else
				ESP:Add(char, {
					Name = p.Name,
					Player = p,
					PrimaryPart = char.HumanoidRootPart
				})
			end
		end
		local function PlayerAdded(p)
			p.CharacterAdded:Connect(CharAdded)
			if p.Character then
				coroutine.wrap(CharAdded)(p.Character)
			end
		end
		plrs.PlayerAdded:Connect(PlayerAdded)
		for i,v in pairs(plrs:GetPlayers()) do
			if v ~= plr then
				PlayerAdded(v)
			end
		end

		game:GetService("RunService").RenderStepped:Connect(function()
			cam = workspace.CurrentCamera
			for i,v in (ESP.Enabled and pairs or ipairs)(ESP.Objects) do
				if v.Update then
					local s,e = pcall(v.Update, v)
					if not s then warn("[EU]", e, v.Object:GetFullName()) end
				end
			end
		end)


		if _G.WRDESPEnabled == nil then _G.WRDESPEnabled = true end
		if _G.WRDESPBoxes == nil then _G.WRDESPBoxes = true end
		if _G.WRDESPTeamColors == nil then _G.WRDESPTeamColors = true end
		if _G.WRDESPTracers == nil then _G.WRDESPTracers = false end
		if _G.WRDESPNames == nil then _G.WRDESPNames = true end


		while wait(.1) do
			ESP:Toggle(_G.WRDESPEnabled or false)
			ESP.Boxes = _G.WRDESPBoxes or false
			ESP.TeamColors = _G.WRDESPTeamColors or false
			ESP.Tracers = _G.WRDESPTracers or false
			ESP.Names = _G.WRDESPNames or false
		end

		_G.WRDESPLoaded = true
	end
end)

--FLY
Section:NewButton("FLY", "KEY=F", function()
    repeat wait() 
	until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:findFirstChild("Head") and game.Players.LocalPlayer.Character:findFirstChild("Humanoid") 
	local mouse = game.Players.LocalPlayer:GetMouse() 
	repeat wait() until mouse
	local plr = game.Players.LocalPlayer 
	local torso = plr.Character.Head 
	local flying = false
	local deb = true 
	local ctrl = {f = 0, b = 0, l = 0, r = 0} 
	local lastctrl = {f = 0, b = 0, l = 0, r = 0} 
	local maxspeed = 400 
	local speed = 5000 

	function Fly()
		local bg = Instance.new("BodyGyro", torso) 
		bg.P = 9e4 
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) 
		bg.cframe = torso.CFrame 
		local bv = Instance.new("BodyVelocity", torso) 
		bv.velocity = Vector3.new(0,0.1,0) 
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9) 
		repeat wait() 
			plr.Character.Humanoid.PlatformStand = true 
			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then 
				speed = speed+.5+(speed/maxspeed) 
				if speed > maxspeed then 
					speed = maxspeed 
				end 
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then 
				speed = speed-1 
				if speed < 0 then 
					speed = 0 
				end 
			end 
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then 
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed 
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r} 
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then 
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed 
			else 
				bv.velocity = Vector3.new(0,0.1,0) 
			end 
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0) 
		until not flying 
		ctrl = {f = 0, b = 0, l = 0, r = 0} 
		lastctrl = {f = 0, b = 0, l = 0, r = 0} 
		speed = 0 
		bg:Destroy() 
		bv:Destroy() 
		plr.Character.Humanoid.PlatformStand = false 
	end 
	mouse.KeyDown:connect(function(key) 
		if key:lower() == "f" then 
			if flying then flying = false 
			else 
				flying = true 
				Fly() 
			end 
		elseif key:lower() == "w" then 
			ctrl.f = 1 
		elseif key:lower() == "s" then 
			ctrl.b = -1 
		elseif key:lower() == "a" then 
			ctrl.l = -1 
		elseif key:lower() == "d" then 
			ctrl.r = 1 
		end 
	end) 
	mouse.KeyUp:connect(function(key) 
		if key:lower() == "w" then 
			ctrl.f = 0 
		elseif key:lower() == "s" then 
			ctrl.b = 0 
		elseif key:lower() == "a" then 
			ctrl.l = 0 
		elseif key:lower() == "d" then 
			ctrl.r = 0 
		end 
	end)
end)

--FLY CAR
Section:NewButton("FLY CAR", "KEY=Z", function()
	local hint = Instance.new("Hint",game.Players.LocalPlayer.PlayerGui)
	hint.Name = game.JobId
	repeat wait()
	until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:findFirstChild("Torso") and game.Players.LocalPlayer.Character:findFirstChild("Humanoid")
	local mouse = game.Players.LocalPlayer:GetMouse()
	repeat wait() until mouse
	local plr = game.Players.LocalPlayer
	local torso = plr.Character.Torso
	local flying = true
	local deb = true
	local ctrl = {f = 0, b = 0, l = 0, r = 0}
	local lastctrl = {f = 0, b = 0, l = 0, r = 0}
	local maxspeed = 500
	local speed = 0

	function Fly()
		local bg = Instance.new("BodyGyro", torso)
		bg.P = 9e4
		bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.cframe = torso.CFrame
		local bv = Instance.new("BodyVelocity", torso)
		bv.velocity = Vector3.new(0,0.1,0)
		bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
		repeat wait()
			plr.Character.Humanoid.PlatformStand = false
			if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
				speed = speed+125.0+(speed/maxspeed)
				if speed > maxspeed then
					speed = maxspeed
				end
			elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
				speed = speed-250
				if speed < 0 then
					speed = 0
				end
			end
			if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
				lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
			elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
				bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed
			else
				bv.velocity = Vector3.new(0,0.1,0)
			end
			bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0)
		until not flying
		ctrl = {f = 0, b = 0, l = 0, r = 0}
		lastctrl = {f = 0, b = 0, l = 0, r = 0}
		speed = 0
		bg:Destroy()
		bv:Destroy()
		plr.Character.Humanoid.PlatformStand = false
	end
	mouse.KeyDown:connect(function(key)
		if key:lower() == "z" then
			if flying then flying = false
			else
				flying = true
				Fly()
			end
		elseif key:lower() == "w" then
			ctrl.f = 1
		elseif key:lower() == "s" then
			ctrl.b = -1
		elseif key:lower() == "a" then
			ctrl.l = -1
		elseif key:lower() == "d" then
			ctrl.r = 1
		end
	end)
	mouse.KeyUp:connect(function(key)
		if key:lower() == "w" then
			ctrl.f = 0
		elseif key:lower() == "s" then
			ctrl.b = 0
		elseif key:lower() == "a" then
			ctrl.l = 0
		elseif key:lower() == "d" then
			ctrl.r = 0
		end
		wait(5)
		hint:Destroy()
	end)
	Fly()
end)

local lp = game:GetService("Players").LocalPlayer

local function gplr(String)
	local Found = {}
	local strl = String:lower()
	if strl == "all" then
		for i,v in pairs(game:GetService("Players"):GetPlayers()) do
			table.insert(Found,v)
		end
	elseif strl == "others" then
		for i,v in pairs(game:GetService("Players"):GetPlayers()) do
			if v.Name ~= lp.Name then
				table.insert(Found,v)
			end
		end 
	elseif strl == "me" then
		for i,v in pairs(game:GetService("Players"):GetPlayers()) do
			if v.Name == lp.Name then
				table.insert(Found,v)
			end
		end 
	else
		for i,v in pairs(game:GetService("Players"):GetPlayers()) do
			if v.Name:lower():sub(1, #String) == String:lower() then
				table.insert(Found,v)
			end
		end 
	end
	return Found 
end

--NOCLIP
Section:NewButton("NOCLIP", "NOCLIP", function()
	local Noclip = nil
	local Clip = nil

	function noclip()
		Clip = false
		local function Nocl()
			if Clip == false and game.Players.LocalPlayer.Character ~= nil then
				for _,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
					if v:IsA('BasePart') and v.CanCollide and v.Name ~= floatName then
						v.CanCollide = false
					end
				end
			end
			wait(0.21) -- basic optimization
		end
		Noclip = game:GetService('RunService').Stepped:Connect(Nocl)
	end

	function clip()
		if Noclip then Noclip:Disconnect() end
		Clip = true
	end

	noclip() 
end)

--INF JUMP
Section:NewButton("INF JUMP", "INF JUMP", function()
    local Player = game:GetService'Players'.LocalPlayer;
local UIS = game:GetService'UserInputService';
 
_G.JumpHeight = 50;
 
function Action(Object, Function) if Object ~= nil then Function(Object); end end
 
UIS.InputBegan:connect(function(UserInput)
    if UserInput.UserInputType == Enum.UserInputType.Keyboard and UserInput.KeyCode == Enum.KeyCode.Space then
        Action(Player.Character.Humanoid, function(self)
            if self:GetState() == Enum.HumanoidStateType.Jumping or self:GetState() == Enum.HumanoidStateType.Freefall then
                Action(self.Parent.HumanoidRootPart, function(self)
                    self.Velocity = Vector3.new(0, _G.JumpHeight, 0);
                end)
            end
        end)
    end
end)
end)

--TOOLS
local MAIN = Window:NewTab("TOOLS")
local Section = MAIN:NewSection("TOOLS")

--BTOOL
Section:NewButton("BTOOL", "BTOOLS", function()
	a = Instance.new("HopperBin", game.Players.LocalPlayer.Backpack)
	a.BinType = 2
	b = Instance.new("HopperBin", game.Players.LocalPlayer.Backpack)
	b.BinType = 3
	c = Instance.new("HopperBin", game.Players.LocalPlayer.Backpack)
	c.BinType = 4
end)

--TP TOOL
Section:NewButton("TP TOOL", "BIOM TP TOOL", function()
	mouse = game.Players.LocalPlayer:GetMouse()
	tool = Instance.new("Tool")
	tool.RequiresHandle = false
	tool.Name = "BIOM TP TOOL"
	tool.Activated:connect(function()
		local pos = mouse.Hit+Vector3.new(0,2.5,0)
		pos = CFrame.new(pos.X,pos.Y,pos.Z)
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = pos
	end)
	tool.Parent = game.Players.LocalPlayer.Backpack
end)

--F3X
Section:NewButton("F3X", "GET F3X", function()
    loadstring(game:GetObjects("rbxassetid://6695644299")[1].Source)()
end)

--OTHER
local MAIN = Window:NewTab("OTHER")
local Section = MAIN:NewSection("OP SCRIPT")

--DEX V4
Section:NewButton("DEX V4", "DEX V4", function()
    loadstring(game:HttpGet('https://ithinkimandrew.site/scripts/tools/dark-dex.lua'))()
end)

--INFINITEYIELD ADMINS
Section:NewButton("INFINITEYIELD ADMINS", "GET ADMIN", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

--CMD
Section:NewButton("CMD", "OPEN CMD", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source", true))()
end)

--SIMPLE SPY
Section:NewButton("SIMPLE SPY", "SIMPLE SPY", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))()
end)

--GAME SCRIPTS
local Section = MAIN:NewSection("GAMES SCRIPT")

--PRISON LIFE
Section:NewButton("PRISON LIFE(TIGER ADMINS)", "TIGER ADMINS", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/H17S32/Tiger_Admin/main/Script'))()
end)

--BUILD A BOAT FOR TREASURE
Section:NewButton("BUILD A BOAT FOR TREASURE(BIOM SCRIPT)", "BY.BIOM SCRIPT", function()
    while 1 do
        wait(0.5)
    local rootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
    rootPart.CFrame = game:GetService("Workspace").BoatStages.NormalStages.CaveStage1.DarknessPart.CFrame
        wait(0.5)
    rootPart.CFrame = game:GetService("Workspace").BoatStages.NormalStages.CaveStage2.DarknessPart.CFrame
        wait(0.5)
    rootPart.CFrame = game:GetService("Workspace").BoatStages.NormalStages.CaveStage3.DarknessPart.CFrame
        wait(0.5)
    rootPart.CFrame = game:GetService("Workspace").BoatStages.NormalStages.CaveStage4.DarknessPart.CFrame
        wait(0.5)
    rootPart.CFrame = game:GetService("Workspace").BoatStages.NormalStages.CaveStage5.DarknessPart.CFrame
        wait(0.5)
    rootPart.CFrame = game:GetService("Workspace").BoatStages.NormalStages.CaveStage6.DarknessPart.CFrame
        wait(0.5)
    rootPart.CFrame = game:GetService("Workspace").BoatStages.NormalStages.CaveStage7.DarknessPart.CFrame
        wait(0.5)
    rootPart.CFrame = game:GetService("Workspace").BoatStages.NormalStages.CaveStage8.DarknessPart.CFrame
        wait(0.5)
    rootPart.CFrame = game:GetService("Workspace").BoatStages.NormalStages.CaveStage9.DarknessPart.CFrame
        wait(0.5)
    rootPart.CFrame = game:GetService("Workspace").BoatStages.NormalStages.CaveStage10.DarknessPart.CFrame
        wait(0.5)
    rootPart.CFrame = game:GetService("Workspace").BoatStages.NormalStages.TheEnd.GoldenChest.Trigger.CFrame
        wait(20)
    end
end)

--SETTING
local MAIN = Window:NewTab("SETTING")
local Section = MAIN:NewSection("GAME")

--REJOIN
Section:NewButton("REJOIN", "REJOIN GAME", function()
	local TeleportService = game:GetService("TeleportService")
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	local Rejoin = coroutine.create(function()
		local Success, ErrorMessage = pcall(function()
			TeleportService:Teleport(game.PlaceId, LocalPlayer)
		end)

		if ErrorMessage and not Success then
			warn(ErrorMessage)
		end
	end)

	coroutine.resume(Rejoin)
end)

--GUI SETTING
local Section = MAIN:NewSection("UI SETTING")

--KEYBINDINFO
Section:NewKeybind("KEYBINDTEXT", "KEYBINDINFO", Enum.KeyCode.Semicolon, function()
	Library:ToggleUI()
end)

--discord
Section:NewLabel("DISCORD:BIOM #3393")
