-- @ScriptType: ModuleScript
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local AttackTypes = require(ReplicatedStorage.Types.AttackTypes)
local ReplicatedModules = ReplicatedStorage.Modules
local ServerModules = game:GetService("ServerScriptService").Modules

local TempRemotes = ReplicatedStorage.ClientRemotes.TempRemotes

--inherited class
local Attack = require(script.Parent)

local Bullet = {}

type self = AttackTypes.Bullet
export type Bullet = self & {
	Destroy: (self: Bullet) -> nil,
	UpdateProperties: (self: Bullet, info: {[string]: any}) -> nil
}
--public functions
function Bullet.UpdateProperties(self: Bullet, info: {[string]: any})
	for i,v in pairs(info) do
		self[i] = v
	end
	
	if info.CFrame then
		self.SkipClientUpdateTick = true
	end
	
	self.DealtDamageRemote:FireAllClients(self)
end
--destructor
function Bullet.Destroy(self: Bullet)
	self.DealtDamageRemote:Destroy()
	self.DealtDamageRemoteConnection:Disconnect()
	
	Attack.Destroy(self)
end
--constructor
function Bullet.new(info: AttackTypes.Bullet): Bullet
	local self = Attack.new(info) :: Attack.Attack & Bullet
	--assign functions
	self.Destroy = Bullet.Destroy
	self.UpdateProperties = Bullet.UpdateProperties
	
	--assign defaults
	self.PierceCount = self.PierceCount or math.huge
	self.SkipClientUpdateTick = false
	self.DealtDamageRemote = Instance.new("RemoteEvent", TempRemotes)
	self.DealtDamageRemote.Name = self.UUID
	self.DealtDamageRemoteConnection = self.DealtDamageRemote.OnServerEvent:Connect(function(player)
		if self.PierceCount > 0 then
			print(player)
			self.PierceCount -= 1
		else
			self:Destroy()
		end
	end)
	
	local self = self :: Bullet
	
	return self
end

return Bullet
