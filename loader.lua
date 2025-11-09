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
    return [=[
        print("hii")
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/RelkzzRebranded/BloodDebtIsGay/refs/heads/main/core.lua"))()
    ]=]
end
if CheckFFlagValue("DebugRunParallelLuaOnMainThread", true) then
    loadstring(LoadScript())()
else
    run_parallel(availableActors()[1], LoadScript())
end
