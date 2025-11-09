local run = run_on_actor or run_on_thread
local availableActors = getactors or getactorthreads

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
	local radius = getgenv().radius or 300

	local targetPartsString = ""
	for i, part in ipairs(TargetParts) do
		if i > 1 then
			targetPartsString = targetPartsString .. ', '
		end
		targetPartsString = targetPartsString .. '"' .. part .. '"'
	end
	local code = string.format([=[
		 getgenv().HitChance = %d
         getgenv().wallcheck = %s
         getgenv().TargetParts = { %s }
         getgenv().radius = %d
        print("hii", getgenv().HitChance, getgenv().wallcheck, getgenv().TargetParts, getgenv().radius)
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/RelkzzRebranded/BloodDebtIsGay/refs/heads/main/core.lua"))()
    ]=], HitChance, tostring(wallcheck), targetPartsString, radius)
    return code
end
if CheckFFlagValue("DebugRunParallelLuaOnMainThread", true) then
    loadstring(LoadScript())()
else
    run(availableActors()[1], LoadScript())
end
