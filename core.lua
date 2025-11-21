-- Compiled with roblox-ts v3.0.0
local _HitChance = getgenv().HitChance
local _wallcheck = getgenv().wallcheck
local _TargetParts = getgenv().TargetParts
local _radius = getgenv().radius
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Bin
do
	Bin = setmetatable({}, {
		__tostring = function()
			return "Bin"
		end,
	})
	Bin.__index = Bin
	function Bin.new(...)
		local self = setmetatable({}, Bin)
		return self:constructor(...) or self
	end
	function Bin:constructor()
	end
	function Bin:add(item)
		local node = {
			item = item,
		}
		if self.head == nil then
			self.head = node
		end
		if self.tail then
			self.tail.next = node
		end
		self.tail = node
		return item
	end
	function Bin:batch(...)
		local args = { ... }
		for _, item in args do
			local node = {
				item = item,
			}
			if self.head == nil then
				self.head = node
			end
			if self.tail then
				self.tail.next = node
			end
			self.tail = node
		end
		return args
	end
	function Bin:destroy()
		while self.head do
			local item = self.head.item
			if type(item) == "function" then
				item()
			elseif typeof(item) == "RBXScriptConnection" then
				item:Disconnect()
			elseif type(item) == "thread" then
				task.cancel(item)
			elseif item.destroy ~= nil then
				item:destroy()
			elseif item.Destroy ~= nil then
				item:Destroy()
			end
			self.head = self.head.next
		end
	end
	function Bin:isEmpty()
		return self.head == nil
	end
end
local BaseComponent
do
	BaseComponent = setmetatable({}, {
		__tostring = function()
			return "BaseComponent"
		end,
	})
	BaseComponent.__index = BaseComponent
	function BaseComponent.new(...)
		local self = setmetatable({}, BaseComponent)
		return self:constructor(...) or self
	end
	function BaseComponent:constructor(instance)
		self.instance = instance
		self.bin = Bin.new()
	end
	function BaseComponent:destroy()
		self.bin:destroy()
	end
end
local RigComponent
do
	local super = BaseComponent
	RigComponent = setmetatable({}, {
		__tostring = function()
			return "RigComponent"
		end,
		__index = super,
	})
	RigComponent.__index = RigComponent
	function RigComponent.new(...)
		local self = setmetatable({}, RigComponent)
		return self:constructor(...) or self
	end
	function RigComponent:constructor(instance)
		super.constructor(self, instance)
		local root = instance:WaitForChild("HumanoidRootPart")
		if root == nil then
			error("Root part not found")
		end
		local head = instance:WaitForChild("Head")
		if head == nil then
			error("Head not found")
		end
		local humanoid = instance:WaitForChild("Humanoid")
		if humanoid == nil then
			error("Humanoid not found")
		end
		self.root = root
		self.head = head
		self.humanoid = humanoid
		local bin = self.bin
		bin:batch(humanoid.Died:Connect(function()
			return self:destroy()
		end), instance.Destroying:Connect(function()
			return self:destroy()
		end))
	end
end
local CharacterComponent
do
	local super = RigComponent
	CharacterComponent = setmetatable({}, {
		__tostring = function()
			return "CharacterComponent"
		end,
		__index = super,
	})
	CharacterComponent.__index = CharacterComponent
	function CharacterComponent.new(...)
		local self = setmetatable({}, CharacterComponent)
		return self:constructor(...) or self
	end
	function CharacterComponent:constructor(instance)
		super.constructor(self, instance)
	end
	CharacterComponent.active = {}
end
local PlayerComponent
do
	local super = BaseComponent
	PlayerComponent = setmetatable({}, {
		__tostring = function()
			return "PlayerComponent"
		end,
		__index = super,
	})
	PlayerComponent.__index = PlayerComponent
	function PlayerComponent.new(...)
		local self = setmetatable({}, PlayerComponent)
		return self:constructor(...) or self
	end
	function PlayerComponent:constructor(instance)
		super.constructor(self, instance)
		self.name = self.instance.Name
		local character = instance.Character
		if character then
			task.spawn(function()
				return self:onCharacterAdded(character)
			end)
		end
		local bin = self.bin
		bin:batch(instance.CharacterAdded:Connect(function(character)
			return self:onCharacterAdded(character)
		end), instance.CharacterRemoving:Connect(function()
			return self:onCharacterRemoving()
		end))
		bin:add(function()
			local _active = PlayerComponent.active
			local _instance = instance
			-- ▼ Map.delete ▼
			local _valueExisted = _active[_instance] ~= nil
			_active[_instance] = nil
			-- ▲ Map.delete ▲
			return _valueExisted
		end)
		local _active = PlayerComponent.active
		local _instance = instance
		local _self = self
		_active[_instance] = _self
	end
	function PlayerComponent:onCharacterAdded(character)
		local _result = self.character
		if _result ~= nil then
			_result:destroy()
		end
		self.character = CharacterComponent.new(character)
	end
	function PlayerComponent:onCharacterRemoving()
		local _result = self.character
		if _result ~= nil then
			_result:destroy()
		end
		self.character = nil
	end
	function PlayerComponent:getName()
		return self.name
	end
	function PlayerComponent:getCharacter()
		return self.character
	end
	PlayerComponent.active = {}
end
local ComponentController = {}
do
	local _container = ComponentController
	local rayParams
	local onPlayerAdded = function(instance)
		PlayerComponent.new(instance)
	end
	local getRandomPart = function(character)
		-- ▼ ReadonlyArray.map ▼
		local _newValue = table.create(#_TargetParts)
		local _callback = function(partName)
			return character.instance:FindFirstChild(partName)
		end
		for _k, _v in _TargetParts do
			_newValue[_k] = _callback(_v, _k - 1, _TargetParts)
		end
		-- ▲ ReadonlyArray.map ▲
		-- ▼ ReadonlyArray.filter ▼
		local _newValue_1 = {}
		local _callback_1 = function(part)
			return part ~= nil
		end
		local _length = 0
		for _k, _v in _newValue do
			if _callback_1(_v, _k - 1, _newValue) == true then
				_length += 1
				_newValue_1[_length] = _v
			end
		end
		-- ▲ ReadonlyArray.filter ▲
		local availableParts = _newValue_1
		if #availableParts == 0 then
			return nil
		end
		local randomIndex = Random.new():NextInteger(0, #availableParts - 1)
		return availableParts[randomIndex + 1]
	end
	local function getTarget()
		local list = PlayerComponent.active
		local viewportSize = Camera.ViewportSize
		local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
		local bestTarget
		local bestPart
		local weight = -math.huge
		-- ▼ ReadonlyMap.forEach ▼
		local _callback = function(component)
			local character = component:getCharacter()
			if character == nil then
				return nil
			end
			local targetPart = getRandomPart(character)
			if targetPart == nil then
				return nil
			end
			local position = character.root.Position
			local viewportPoint = Camera:WorldToViewportPoint(position)
			if viewportPoint.Z < 0 then
				return nil
			end
			if _wallcheck then
				local origin = Camera.CFrame.Position
				rayParams.FilterDescendantsInstances = { character.instance, LocalPlayer.Character }
				local result = Workspace:Raycast(origin, position - origin, rayParams)
				if result then
					return nil
				end
			end
			local screenDistance = (Vector2.new(viewportPoint.X, viewportPoint.Y) - screenCenter).Magnitude
			if screenDistance > _radius then
				return nil
			end
			local prio = 1e3 - screenDistance
			if prio > weight then
				bestTarget = character
				bestPart = targetPart
				weight = prio
			end
		end
		for _k, _v in list do
			_callback(_v, _k, list)
		end
		-- ▲ ReadonlyMap.forEach ▲
		return bestTarget, bestPart
	end
	_container.getTarget = getTarget
	local function __init()
		local _exp = Players:GetPlayers()
		-- ▼ ReadonlyArray.forEach ▼
		local _callback = function(instance)
			return instance ~= LocalPlayer and task.spawn(onPlayerAdded, instance)
		end
		for _k, _v in _exp do
			_callback(_v, _k - 1, _exp)
		end
		-- ▲ ReadonlyArray.forEach ▲
		Players.PlayerAdded:Connect(onPlayerAdded)
		Players.PlayerRemoving:Connect(function(instance)
			local _active = PlayerComponent.active
			local _instance = instance
			local _result = _active[_instance]
			if _result ~= nil then
				_result = _result:destroy()
			end
			return _result
		end)
		rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		rayParams.IgnoreWater = true
	end
	_container.__init = __init
end
local RangeController = {}
do
	local _container = RangeController
	local target
	local canManipulate = false
	local calculateChance = function(Percentage)
		Percentage = math.floor(Percentage)
		local random = Random.new()
		local chance = math.floor(random:NextNumber(0, 1) * 100) / 100
		return chance <= Percentage / 100
	end
	local getTarget = ComponentController.getTarget
	local function __init()
		RunService.Heartbeat:Connect(function()
			canManipulate = calculateChance(_HitChance)
		end)
		local __namecall
		__namecall = hookmetamethod(game, "__namecall", function(self, ...)
			local args = { ... }
			local method = getnamecallmethod()
			local scriptcaller = debug.getinfo(3)
			local _condition = scriptcaller
			if _condition then
				_condition = (string.match(scriptcaller.source, "ActiveCast"))
				if _condition ~= 0 and _condition == _condition and _condition ~= "" and _condition then
					_condition = method == "Raycast"
				end
			end
			if _condition ~= 0 and _condition == _condition and _condition ~= "" and _condition then
				local target = { getTarget() }
				if target[1] and canManipulate then
					local _position = target[2].Position
					local _arg0 = args[2]
					local newDir = (_position - _arg0).Unit * 1000
					args[2] = newDir
				end
			end
			return __namecall(self, unpack(args))
		end)
	end
	_container.__init = __init
end
local VisualsController = {}
do
	local _container = VisualsController
	local circle = Drawing.new("Circle")
	circle.Filled = false
	circle.NumSides = 15
	circle.Thickness = 2
	circle.Visible = true
	circle.Color = Color3.new(1, 1, 1)
	local function __init()
		RunService.RenderStepped:Connect(function()
			if circle then
				local viewportSize = Camera.ViewportSize
				local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
				circle.Radius = _radius
				circle.Position = Vector2.new(screenCenter.X, screenCenter.Y)
			end
		end)
	end
	_container.__init = __init
end
local CameraController = {}
do
	local _container = CameraController
	local function __init()
		Camera = Workspace.CurrentCamera
		Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			Camera = Workspace.CurrentCamera or Camera
		end)
	end
	_container.__init = __init
end
ComponentController.__init()
RangeController.__init()
VisualsController.__init()
CameraController.__init()
return nil
