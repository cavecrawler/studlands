-- @ScriptType: ModuleScript
--#!strict
--[[
Caster module for handling raycasts, shapecasts, and overlap calls.

Added as part of Desert Part 2
]]

--Constants
local PLAYERS = game:GetService("Players")

--typing of Caster module implementation since you can't directly set types in tables :eyeroll:
export type CasterImplementation = {
	Overlap: (
		overlapParams: OverlapParams?,
		shape: "Rectangle" & "Sphere" & BasePart,
		cFrame: CFrame?,
		size: Vector3?,
		inverseHitbox: boolean?,
		inverseHitboxAllowedPlayers: {Player}?
	) -> {[Player]: {Humanoid: Humanoid}}
	,
	Shapecast: (
		raycastParams: RaycastParams?,
		shape: "Rectangle" & "Sphere" & "Cylinder" & BasePart,
		cFrame: CFrame?,
		length: number,
		pierceCount: number?,
		inverseHitbox: boolean?,
		inverseHitboxAllowedPlayers: {Player}?
	) -> {Players: {Player?}, RaycastResult: RaycastResult}
	,
	GetTargetablePlayers: (
	) -> {TargetablePlayers: {Player?}, TargetableCharacterParts: {BasePart?}}
}
--private functions

--public functions

local Caster: CasterImplementation = {}

Caster.GetTargetablePlayers = function()
	local Return = {}
	Return.TargetablePlayers = {}
	Return.TargetableCharacterParts = {}
	
	for i,_Player in pairs(PLAYERS:GetChildren()) do
		if _Player:GetAttribute("Untargetable") == true then
			continue
		end
		
		table.insert(Return.TargetablePlayers, _Player)
		
		if _Player.Character ~= nil then
			local _Humanoid: Humanoid = _Player.Character:FindFirstChildOfClass("Humanoid")
			if _Humanoid then
				if _Humanoid.Health > 0 then
					for i,_Part in pairs(_Player.Character:GetChildren()) do
						if _Part.Name ~= "HumanoidRootPart" then
							table.insert(Return.TargetableCharacterParts, _Part)
						end
					end
				end
			end
		end
	end
	
	return Return
end

Caster.Overlap = function(
	overlapParams: OverlapParams?,
	shape: "Rectangle" & "Sphere" & BasePart,
	cFrame: CFrame?,
	size: Vector3?,
	inverseHitbox: boolean?,
	inverseHitboxAllowedPlayers: {Player}?
)
	--error handling
	do
		if not cFrame then
			if shape then
				if not shape:IsA("BasePart") then
					error("param cFrame must be defined if using non-BasePart shape!")
				end
			end
		end
		
		if not size then
			if shape then
				if not shape:IsA("BasePart") then
					error("param size must be defined if using non-BasePart shape!")
				end
			end
		end

		if shape == "Sphere" then
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
	local HitPlayers = {}
	
	if not overlapParams then
		overlapParams = OverlapParams.new()
		overlapParams.FilterDescendantsInstances = Caster.GetTargetablePlayers().TargetableCharacterParts
		overlapParams.FilterType = Enum.RaycastFilterType.Include
	end
	
	if inverseHitbox == true then
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
	elseif shape == "Sphere" then
		HitParts = workspace:GetPartBoundsInRadius(cFrame.Position, size.X/2, overlapParams)
	else --basepart
		if not cFrame then
			cFrame = shape.CFrame
		end
		
		if size then
			shape.Size = size
		end
		
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
	raycastParams: RaycastParams,
	shape: "Rectangle" & "Sphere" & "Cylinder" & BasePart,
	cFrame: CFrame,
	size: Vector3?,
	length: number,
	pierceCount: number?,
	inverseHitbox: boolean?,
	inverseHitboxAllowedPlayers: {Player}?
)
	--error handling
	do
		if not cFrame then
			if not shape:IsA("BasePart") then
				error("param cFrame must be defined if using non-BasePart shape!")
			end
		end
		
		if not size then
			if not shape:IsA("BasePart") then
				error("param size must be defined if using non-BasePart shape!")
			end
		end
		
		if shape == "Cylinder" and size.X ~= size.Z then
			error("X & Z axes of param size must be equal when using Cylinder shape!")
		end
		
		if shape == "Sphere" then
			if size.X ~= size.Y then
				error("All axes of param size must be equal when using Sphere shape!")
			elseif size.X ~= size.Z then
				error("All axes of param size must be equal when using Sphere shape!")
			end
		end
		
		if length <= 0 then
			error("param length must be a positive, nonzero number!")
		end
		
		if inverseHitbox == true and not inverseHitboxAllowedPlayers then
			error("Must have table of players as param inverseHitboxAllowedPlayers when param inverseHitbox is true!")
		end
	end
	
	--logic
	do
		
	end
end

return Caster
