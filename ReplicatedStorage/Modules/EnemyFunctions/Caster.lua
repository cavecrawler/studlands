-- @ScriptType: ModuleScript
--#!strict
--[[
Caster module for handling raycasts, shapecasts, and overlap calls.

Added as part of Desert Part 2
]]

--typing of Caster module implementation since you can't directly set types in tables :eyeroll:
export type CasterImplementation = {
	Overlap: (
		overlapParams: OverlapParams,
		shape: "Rectangle" & "Sphere" & BasePart,
		cFrame: CFrame,
		size: Vector3?,
		inverseHitbox: boolean?
	) -> {Players: {Player}}
	,
	Shapecast: (
		raycastParams: RaycastParams,
		shape: "Rectangle" & "Sphere" & "Cylinder" & BasePart,
		cFrame: CFrame,
		length: number,
		pierceCount: number?,
		inverseHitbox: boolean?
	) -> {Players: {Player}, RaycastResult: RaycastResult}
}

local Caster: CasterImplementation = {}

Caster.Overlap = function(
	overlapParams: OverlapParams,
	shape: "Rectangle" & "Sphere" & BasePart,
	cFrame: CFrame,
	size: Vector3?,
	inverseHitbox: boolean?
)
	--error handling
	do
		if not size then
			if not shape:IsA("BasePart") then
				error("param size must be defined if using non-BasePart shape!")
			end
		end

		if shape == "Sphere" then
			if size.X ~= size.Y then
				error("All axes of param size must be equal when using Sphere shape!")
			elseif size.X ~= size.Z then
				error("All axes of param size must be equal when using Sphere shape!")
			end
		end
	end
	
	--logic
	do
		
	end
end

Caster.Shapecast = function(
	raycastParams: RaycastParams,
	shape: "Rectangle" & "Sphere" & "Cylinder" & BasePart,
	cFrame: CFrame,
	size: Vector3?,
	length: number,
	pierceCount: number?,
	inverseHitbox: boolean?
)
	--error handling
	do
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
	end
	
	--logic
	do
		
	end
end

return Caster
