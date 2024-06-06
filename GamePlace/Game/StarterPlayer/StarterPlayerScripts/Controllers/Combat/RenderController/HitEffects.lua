local HitEffects = {}

-- padrão saindo sangue
function HitEffects.Default()
    
end

function HitEffects.Caller(RenderData)
	if HitEffects[RenderData.effect] then
		task.spawn(HitEffects[RenderData.effect], RenderData)
	else
		error("Render not found!")
	end
end

return HitEffects
