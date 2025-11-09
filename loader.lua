local run_parallel = run_on_thread or run_on_actor
local availableActors = getactorthreads or getactors

local function CheckFFlagValue(Name, Value)
	local Success, Result = pcall(getfflag, Name)
	if not Success then
		return false
	end

	if typeof(Result) == "boolean" then
		return Result
	end

	if typeof(Result) == "string" then
		return Result == tostring(Value)
	end

	return false
end
local function LoadScript()
	local HitChance = getgenv().HitChance or 100
    local wallcheck = getgenv().wallcheck or false
    local TargetParts = getgenv().TargetParts or {"Head"}
    local radius = getgenv().radius or 100
    return string.format([=[
		 getgenv().HitChance = %d
         getgenv().wallcheck = %s
         getgenv().TargetParts = { %s }
         getgenv().radius = %d
        print("hii", HitChance, wallcheck, TargetParts, radius)
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/RelkzzRebranded/BloodDebtIsGay/refs/heads/main/core.lua"))()
    ]=], HitChance, tostring(wallcheck), table.concat(TargetParts, '", "'), radius)
end
if CheckFFlagValue("DebugRunParallelLuaOnMainThread", true) then
    loadstring(LoadScript())()
else
    run_parallel(availableActors()[1], LoadScript())
end
