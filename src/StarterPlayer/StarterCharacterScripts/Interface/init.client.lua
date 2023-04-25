local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ======================================================================
-- // Modules
-- ======================================================================
local Interactions = require(script:WaitForChild("Interactions"))

local DamageIndicator = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DamageIndication"))
DamageIndicator.BindToAllNPCs()

Interactions:Start()
