-- @ScriptType: ModuleScript
--!strict
local MotionSolver = {}

function MotionSolver.DisplacementFromMotion(s0: number, v0: number, a: number, t: number, minSpeed: number?, maxSpeed: number?): number
	local v0 = v0 or 0 :: number
	local a = a or 0 :: number
	local minSpeed = minSpeed or -math.huge :: number
	local maxSpeed = maxSpeed or math.huge :: number
	
	local maxSpeed = if a < 0 then minSpeed else maxSpeed
	
	local _tMax = if a > 0 and maxSpeed then (maxSpeed - v0)/a
		elseif a < 0 and minSpeed then (minSpeed - v0)/a
		else math.huge
	print(_tMax)
	local _s = if t > _tMax then s0 + maxSpeed*(t - _tMax) + v0*_tMax + 0.5*a*_tMax*_tMax
		else s0 + v0*t + 0.5*a*t*t
	
	return _s
end

function MotionSolver.DisplacementFromMotionCFrame(s0: CFrame, v0: Vector3, a: Vector3, t: number, minSpeed: Vector3?, maxSpeed: Vector3?): CFrame
	local x = MotionSolver.DisplacementFromMotion(s0.X, v0.X, a.X, t, minSpeed and minSpeed.X, maxSpeed and maxSpeed.X)
	local y = MotionSolver.DisplacementFromMotion(s0.Y, v0.Y, a.Y, t, minSpeed and minSpeed.Y, maxSpeed and maxSpeed.Y)
	local z = MotionSolver.DisplacementFromMotion(s0.Z, v0.Z, a.Z, t, minSpeed and minSpeed.Z, maxSpeed and maxSpeed.Z)
	
	return CFrame.new(x,y,z)
end

return MotionSolver
