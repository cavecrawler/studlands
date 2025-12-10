-- @ScriptType: ModuleScript
--!strict
local ClientObjectTypes = require(game:GetService("ReplicatedStorage").Types.ClientObjectTypes)

local ClientObject = {}

type self = ClientObjectTypes.ClientObject
export type ClientObject = self & {
	
}

ClientObject.ClientObjects = {} --container for all ClientObjects

function ClientObject.new(info: self): ClientObject
	if ClientObject.ClientObjects[info.UUID] then
		error("ClientObject with UUID "..info.UUID.." already exists!")
	end
	
	local self = {}
	
	for i,v in pairs(info) do
		self[i] = v
	end
	
	ClientObject.ClientObjects = self.UUID
	
	local self = self :: ClientObject
	return self
end

return ClientObject
