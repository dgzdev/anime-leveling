local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DamageIndicator = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("DamageIndication"))
DamageIndicator.BindToAllNPCs()