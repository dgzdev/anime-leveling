local FlashStrike = {}

function FlashStrike.Test(...) end

function FlashStrike.Start() end

function FlashStrike.Caller(RenderData)
	local Effect = RenderData.effect

	if FlashStrike[Effect] then
		FlashStrike[Effect](RenderData)
	else
		print("Effect not found")
	end
end

return FlashStrike
