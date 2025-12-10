-- @ScriptType: ModuleScript
local ClientObjectTypes = require(game:GetService("ReplicatedStorage").Types.ClientObjectTypes)

--inherited class
local ClientObject = require(script.Parent)
local LinearBullet = {}

type self = ClientObjectTypes.LinearBullet
export type LinearBullet = self & {
	
}

function LinearBullet.new(info: self)
	local self = ClientObject.new(info) :: LinearBullet
	
	return self
end

return LinearBullet
