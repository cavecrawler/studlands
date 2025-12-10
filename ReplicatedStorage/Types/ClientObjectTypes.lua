-- @ScriptType: ModuleScript
local ReflectionService = game:GetService("ReflectionService")

local AttackTypes = require(script.Parent.AttackTypes)

export type ClientObject = {
	UUID: string,
	CreatedTick: number,
	LastUpdatedTick: number, 
	SkipClientUpdateTick: boolean
}

export type LinearBullet = ClientObject & AttackTypes.LinearBullet

export type Vector3Bullet = ClientObject & AttackTypes.Vector3Bullet

return nil