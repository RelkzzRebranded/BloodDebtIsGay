local actors = getactors()
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
local function Load()
  return loadstring(game:HttpGet("https://raw.githubusercontent.com/RelkzzRebranded/BloodDebtIsGay/refs/heads/main/core.lua"))()
end
if CheckFFlagValue("DebugRunParallelLuaOnMainThread", true) then
  Load()
else
  run_on_actor(actors[1], Load())
end
