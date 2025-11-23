-- @ScriptType: ModuleScript
--!strict
--[[
Caster module for handling raycasts, shapecasts, and overlap calls.

Added as part of Desert Part 2

                                                                                                                                 rgb was here!?!1/1
]]

--Constants
local PLAYERS = game:GetService("Players")

local CASTVISUALS = require(script.CastVisuals)

--private functions

--public functions

local Caster = {}

Caster.GetTargetablePlayers = function(): 
	{
		TargetablePlayers: {Player?},
		TargetableCharacterParts: {
			[Model]: {BasePart?}
		}
	}
	
	local Return = {
		TargetablePlayers = {},
		TargetableCharacterParts = {}
	}

	for i,_Player in pairs(PLAYERS:GetChildren()) do
		if _Player:GetAttribute("Untargetable") == true then
			continue
		end

		if _Player.Character ~= nil then
			local _Humanoid: Humanoid = _Player.Character:FindFirstChildOfClass("Humanoid")
			if _Humanoid then
				if _Humanoid.Health > 0 then
					table.insert(Return.TargetablePlayers, _Player)
					Return.TargetableCharacterParts[_Player.Character] = {}
					
					for i,_Part in pairs(_Player.Character:GetChildren()) do
						if _Part.Name ~= "HumanoidRootPart" and _Part:IsA("BasePart") then
							table.insert(Return.TargetableCharacterParts[_Player.Character], _Part)
						end
					end
				end
			end
		end
	end

	return Return
end

Caster.DebugMarker = function(cf: CFrame): BasePart
	local Marker = Instance.new("Part", workspace)
	Marker.Anchored = true
	Marker.Size = Vector3.new(0.5,0.5,0.5)
	Marker.Color = Color3.new(1,0,0)
	Marker.CastShadow = false
	Marker.CanCollide = false
	Marker.CanTouch = false
	Marker.CanQuery = false
	Marker.CFrame = cf
	game:GetService("TweenService"):Create(Marker, TweenInfo.new(1), {Transparency = 1}):Play()
	game:GetService("Debris"):AddItem(Marker, 1)
	return Marker
end

Caster.Overlap = function(
	overlapParams: OverlapParams?,
	shape: "Rectangle" | "Sphere" | BasePart,
	cFrame: CFrame?,
	size: Vector3?,
	inverseHitbox: boolean?,
	inverseHitboxAllowedPlayers: {Player}?
): {[Player]: {Humanoid: Humanoid}}
	--error handling
	do
		if not cFrame then
			if shape ~= "Rectangle" and shape ~= "Sphere" then
				error("param cFrame must be defined if using non-BasePart shape!")
			end
		end

		if not size then
			if shape ~= "Rectangle" and shape ~= "Sphere" then
				error("param size must be defined if using non-BasePart shape!")
			end
		elseif shape == "Sphere" then
			if size.X ~= size.Y then
				error("All axes of param size must be equal when using Sphere shape!")
			elseif size.X ~= size.Z then
				error("All axes of param size must be equal when using Sphere shape!")
			end
		end

		if inverseHitbox == true and not inverseHitboxAllowedPlayers then
			error("Must have table of players as param inverseHitboxAllowedPlayers when param inverseHitbox is true!")
		end
	end

	--logic
	local HitParts = {}
	local HitPlayers: {[Player]: {Humanoid: Humanoid}} = {}

	if not overlapParams then
		local _TargetableCharacterParts = Caster.GetTargetablePlayers().TargetableCharacterParts
		local _FilterDescendantsInstances = {}
		for i,_PartTable in pairs(_TargetableCharacterParts) do
			for i,_Part in pairs(_PartTable) do
				table.insert(_FilterDescendantsInstances, _Part)
			end
		end
		
		overlapParams = OverlapParams.new()
		overlapParams.FilterDescendantsInstances = _FilterDescendantsInstances
		overlapParams.FilterType = Enum.RaycastFilterType.Include
	end

	if inverseHitbox == true and inverseHitboxAllowedPlayers then
		for i, _Player in pairs(inverseHitboxAllowedPlayers) do
			if _Player then
				if _Player.Character ~= nil then
					local _Humanoid = _Player.Character:FindFirstChildOfClass("Humanoid")
					if _Humanoid then
						if _Humanoid.Health > 0 then
							HitPlayers[_Player] = {Humanoid = _Humanoid}
						end
					end
				end
			end
		end
	end

	if shape == "Rectangle" then
		HitParts = workspace:GetPartBoundsInBox(cFrame, size, overlapParams)
	elseif shape == "Sphere" and cFrame and size then
		HitParts = workspace:GetPartBoundsInRadius(cFrame.Position, size.X/2, overlapParams)
	else--basepart
		local cFrame: CFrame = cFrame or shape.CFrame
		local size: Vector3 = size or shape.Size
		
		shape.Size = size
		shape.CFrame = cFrame


		HitParts = workspace:GetPartsInPart(shape, overlapParams)
	end

	for i,_Part in pairs(HitParts) do
		local _Player = game.Players:GetPlayerFromCharacter(_Part.Parent)
		local _Humanoid = _Part.Parent:FindFirstChildOfClass("Humanoid")

		if _Player and _Humanoid then
			if HitPlayers[_Player] and not inverseHitbox then
				continue
			elseif _Humanoid.Health > 0 then
				if not inverseHitbox then
					HitPlayers[_Player] = {Humanoid = _Humanoid}
				else
					HitPlayers[_Player] = nil
				end
			end
		end
	end

	return HitPlayers
end

Caster.Shapecast = function(
	raycastParams: RaycastParams?,
	shape: "Rectangle" | "Sphere" | "Cylinder" | BasePart,
	cFrame: CFrame?,
	size: Vector3?,
	length: number,
	pierceCount: number?,
	inverseHitbox: boolean?,
	hitboxAllowedPlayers: {Player}?,
	DEBUG: boolean?
): {Players: {[Player?]: Humanoid}, RaycastResult: RaycastResult?, Endpoint: Vector3}
	do
		if not cFrame then
			if shape ~= "Rectangle" and shape ~= "Sphere" and shape ~= "Cylinder" then
				error("param cFrame must be defined if using non-BasePart shape!")
			end
		end

		if not size then
			if shape ~= "Rectangle" and shape ~= "Sphere" and shape ~= "Cylinder" then
				error("param size must be defined if using non-BasePart shape!")
			end
		elseif shape == "Cylinder" and size.X ~= size.Z then
			error("X & Z axes of param size must be equal when using Cylinder shape!")
		elseif shape == "Sphere" then
			if size.X ~= size.Y then
				error("All axes of param size must be equal when using Sphere shape!")
			elseif size.X ~= size.Z then
				error("All axes of param size must be equal when using Sphere shape!")
			end
		end

		if length <= 0 then
			error("param length must be a positive, nonzero number!")
		end

		if inverseHitbox == true and not hitboxAllowedPlayers then
			error("Must have table of players as param HitboxAllowedPlayers when param inverseHitbox is true!")
		end
	end

	--logic
	local Return: {Players: {[Player?]: Humanoid}, RaycastResult: RaycastResult?, Endpoint: Vector3} = {
		Players = {},
		RaycastResult = nil,
		Endpoint = Vector3.new()
	}
	local TargetablePlayersAndParts = Caster.GetTargetablePlayers()
	local RaycastResult: RaycastResult?
	
	do
		local _SetRaycastParamDefaults = not raycastParams
		
		local pierceCount = pierceCount or math.huge
		local hitboxAllowedPlayers = hitboxAllowedPlayers or game.Players:GetChildren()
		local raycastParams = raycastParams or RaycastParams.new()
		local cFrame = if typeof(shape) == "Instance" then shape.CFrame else cFrame
		
		if _SetRaycastParamDefaults then
			raycastParams.FilterType = Enum.RaycastFilterType.Include
		end
		
		for i,_Player in pairs(hitboxAllowedPlayers) do
			hitboxAllowedPlayers[_Player] = _Player
			if type(i) == "number" then
				hitboxAllowedPlayers[i] = nil
			end
		end
		
		if inverseHitbox then
			for i,_Player in pairs(hitboxAllowedPlayers) do
				if _Player.Character then
					local _Humanoid = _Player.Character:FindFirstChildOfClass("Humanoid")
					if _Humanoid then
						if _Humanoid.Health > 0 then
							Return.Players[_Player] = _Humanoid
						end
					end
				end
			end
		end
		
		local _CastEnded = false
		
		while _CastEnded == false or pierceCount < 0 do
			pierceCount -= 1
			
			local _RaycastParams = RaycastParams.new()
			_RaycastParams.FilterType = raycastParams.FilterType
			_RaycastParams.IgnoreWater = raycastParams.IgnoreWater
			_RaycastParams.CollisionGroup = raycastParams.CollisionGroup
			_RaycastParams.RespectCanCollide = raycastParams.RespectCanCollide
			_RaycastParams.BruteForceAllSlow = raycastParams.BruteForceAllSlow
			
			local _FilterDescendantsInstances = {}
			
			for i, _Player in pairs(hitboxAllowedPlayers) do
				if _Player.Character and not Return.Players[_Player] then
					if TargetablePlayersAndParts.TargetableCharacterParts[_Player.Character] then
						for i,_Part in pairs(TargetablePlayersAndParts.TargetableCharacterParts[_Player.Character]) do
							table.insert(_FilterDescendantsInstances, _Part)
						end
					end
				end
			end
			
			for i, _Instance in pairs(raycastParams.FilterDescendantsInstances) do
				if typeof(_Instance) == "Instance" then
					table.insert(_FilterDescendantsInstances, _Instance)
				end
			end
			
			_RaycastParams.FilterDescendantsInstances = _FilterDescendantsInstances
			
			if shape == "Rectangle" and cFrame and size then
				local _Direction = CFrame.new(cFrame.Position):ToObjectSpace(cFrame * CFrame.new(0,0,-length-(size.Z/2)))
				local _DPos = _Direction.Position
				
				RaycastResult = workspace:Blockcast(cFrame * CFrame.new(0,0,size.Z/2) , size, _DPos, _RaycastParams)
				
				if DEBUG then
					local _debug = CASTVISUALS.new(Color3.new(1,0,0), workspace)

					_debug:Blockcast(cFrame * CFrame.new(0,0,size.Z/2) , size, _DPos, _RaycastParams)
					task.spawn(function()
						task.wait(0.5)
						_debug:Hide()
					end)
					Caster.DebugMarker((cFrame * CFrame.new(0,0,size.Z/2)))
					Caster.DebugMarker(CFrame.new(_DPos))
				end
			elseif (shape == "Sphere" or shape == "Cylinder") and cFrame and size then
				local _Direction = CFrame.new(cFrame.Position):ToObjectSpace(cFrame * CFrame.new(0,0,-length-(size.Z/2)))
				local _DPos = _Direction.Position
				
				RaycastResult = workspace:Spherecast((cFrame * CFrame.new(0,0,size.Z/2)).Position, size.Z/2, _DPos, _RaycastParams)
				
				if shape == "Cylinder" and RaycastResult then
					local _Distance = cFrame:ToObjectSpace(CFrame.new(RaycastResult.Position))
					if _Distance.Z < -length then
						RaycastResult = nil
					end
				end
				
				if DEBUG then
					local _debug = CASTVISUALS.new(Color3.new(1,0,0), workspace)
					
					_debug:SphereCast((cFrame * CFrame.new(0,0,size.Z/2)).Position, size.Z/2, _DPos, _RaycastParams)
					task.spawn(function()
						task.wait(0.5)
						_debug:Hide()
					end)
					Caster.DebugMarker((cFrame * CFrame.new(0,0,size.Z/2)))
					Caster.DebugMarker(CFrame.new(_DPos))
				end
			else
				RaycastResult = workspace:Shapecast(shape, cFrame.LookVector * length, _RaycastParams)
			end
			
			local _Part: BasePart
			
			if RaycastResult then
				if RaycastResult.Instance then
					if RaycastResult.Instance:IsA("BasePart") then
						_Part = RaycastResult.Instance
					end
				end
			else
				_CastEnded = true
				Return.Endpoint = (cFrame * CFrame.new(0,0,-length)).Position
				break
			end
			
			if _Part then
				local _Player = game.Players:GetPlayerFromCharacter(_Part.Parent)
				local _Humanoid = _Part.Parent:FindFirstChildOfClass("Humanoid")

				if _Player and _Humanoid then
					if Return.Players[_Player] and not inverseHitbox then
						continue
					elseif _Humanoid.Health > 0 then
						hitboxAllowedPlayers[_Player] = nil
						
						if not inverseHitbox then
							Return.Players[_Player] = _Humanoid
						else
							Return.Players[_Player] = nil
						end
					else
						_CastEnded = true
						Return.Endpoint = RaycastResult.Position
						break
					end
				else
					_CastEnded = true
					Return.Endpoint = RaycastResult.Position
					break
				end
			end
		end
	end
	
	Return.RaycastResult = RaycastResult
	return Return
end

return Caster
