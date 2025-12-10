-- @ScriptType: LocalScript
--!strict
local HttpService = game:GetService("HttpService")
local ClientObjectTypes = {
	LinearBullet = require(script.ClientObject.LinearBullet)
}

local ObjectRemote = game:GetService("ReplicatedStorage"):WaitForChild("ClientRemotes"):WaitForChild("ClientObject")

ObjectRemote.OnClientEvent:Connect(function(self: {string: any}, objectType: string)
	if ClientObjectTypes[objectType] then
		local _ClientObject = ClientObjectTypes[objectType].new(self)
		print(_ClientObject)
	else
		error("objectType "..objectType.." does not exist!")
	end
end)