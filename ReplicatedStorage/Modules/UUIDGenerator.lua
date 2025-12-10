-- @ScriptType: ModuleScript
--Initial variables
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")

--Initialize class
UUIDGenerator = {}
UUIDGenerator.__index = UUIDGenerator

UUIDGenerators = {} --Container for all UUIDGenerator objects
--Base classes
local function UUIDGeneratorBase()
	return {
		Name = "";
		UUIDS = {}
	}
end

--Functions
function UUIDGenerator:CreateUUID()
	local _UUID = nil
	while not _UUID do
		local _TestUUID = HttpService:GenerateGUID(false)
		if self.UUIDS[_TestUUID] == nil then
			_UUID = _TestUUID
		end
	end
	self.UUIDS[_UUID] = true
	return _UUID
end

function UUIDGenerator:DisposeUUID(idToDispose: string)
	if self.UUIDS[idToDispose] then
		self.UUIDS[idToDispose] = nil
	else
		error("UUID to dispose "..idToDispose.." does not exist in UUIDGenerator "..self.Name,2)
	end
end

--Constructor
function UUIDGenerator.new(name: string)
	if not UUIDGenerators[name] then
		local _UUIDGenerator = UUIDGeneratorBase()
		_UUIDGenerator.Name = name
		_UUIDGenerator = setmetatable(_UUIDGenerator,UUIDGenerator)
		return _UUIDGenerator
	else
		error("UUID generator with name "..name.." already exists",2)
	end
end

return UUIDGenerator