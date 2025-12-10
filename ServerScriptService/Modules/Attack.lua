-- @ScriptType: ModuleScript
--!strict
local RunService = game:GetService("RunService")

local AttackTypes = require(game:GetService("ReplicatedStorage").Types.AttackTypes)
local ReplicatedModules = game:GetService("ReplicatedStorage").Modules
local ServerModules = game:GetService("ServerScriptService").Modules

local UUIDGenerator = require(ReplicatedModules.UUIDGenerator).new()

local Attack = {}

type self = AttackTypes.Attack
export type Attack = self & {
	Debug: (self: Attack) -> nil;
	Destroy: (self: any) -> nil
}

--Container for all attacks
Attack.Attacks = {} :: {[string]: Attack}

--Public methods
function Debug(self: self)
	print(self.UUID)
end

--Destructor
function Attack.Destroy(self: self)
	if self.OnExpire then
		self:OnExpire()
	end
	
	UUIDGenerator:DisposeUUID(self.UUID)
	Attack.Attacks[self.UUID] = nil
end

--Constructor

function Attack.new(self: Attack?): Attack
	local self = self or {} :: Attack
	
	--assign functions
	self.Debug = Debug
	self.Destroy = Attack.Destroy
	
	--assign default variables
	self.UUID = UUIDGenerator:CreateUUID()
	self.CreatedTick = workspace:GetServerTimeNow()
	self.Damage = self.Damage or 1
	self.Lifetime = self.Lifetime or 3
	self.CanHit = self.CanHit or true
	self.TargetedPlayers = self.TargetedPlayers or game.Players:GetChildren()
	
	if self.OnStart then
		self:OnStart()
	end
	
	Attack.Attacks[self.UUID] = self
	return self
end

RunService.Stepped:Connect(function(t, dt)
	for _, attack in Attack.Attacks do
		if (workspace:GetServerTimeNow() - attack.CreatedTick) >= attack.Lifetime then
			attack:Destroy()
			continue
		end
		
		if attack.Update then
			attack:Update(dt)
		end
	end
end)

return Attack
