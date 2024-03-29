---
title: Examples
---

# Examples

## Chaining

Chain together multiple Promise-returning functions, and only handle a potential error once. If any function rejects in the chain, execution will jump down to `catch`.

```lua
	doSomething()
		:andThen(doSomethingElse)
		:andThen(doSomethingOtherThanThat)
		:andThen(doSomethingAgain)
		:catch(print)
```

## IsInGroup wrapper

This function demonstrates how to convert a function that yields into a function that returns a Promise. (Assuming you don't want to use [Promise.promisify](/api/Promise#promisify))

```lua
local function isPlayerInGroup(player, groupId)
	return Promise.new(function(resolve)
		resolve(player:IsInGroup(groupId))
	end)
end
```

## TweenService wrapper

This function demonstrates convert a Roblox API that uses events into a function that returns a Promise.

```lua
local function tween(obj, tweenInfo, props)
	return function()
		return Promise.new(function(resolve, reject, onCancel)
			local tween = TweenService:Create(obj, tweenInfo, props)
			
			if onCancel(function()
				tween:Cancel()
			end) then return end
			
			tween.Completed:Connect(resolve)
			tween:Play()
		end)
	end
end
```

## Cancellable animation sequence
The following is an example of an animation sequence which is composable and cancellable. If the sequence is cancelled, the animated part will instantly jump to the end position as if it had played all the way through.

We take advantage of Promise chaining by returning Promises from the `finally` handler functions. Because of this behavior, cancelling the final Promise in the chain will propagate up to the very top and cancel every single Promise you see here.

```lua
local Promise = require(game.ReplicatedStorage.Promise)
local TweenService = game:GetService("TweenService")

local sleep = Promise.promisify(wait)

local function apply(obj, props)
	for key, value in (props) do
		obj[key] = value
	end
end

local function runTween(obj, props)
	return Promise.new(function(resolve, reject, onCancel)
		local tween = TweenService:Create(obj, TweenInfo.new(0.5), props)
		
		if onCancel(function()
			tween:Cancel()
			apply(obj, props)
		end) then return end
		
		tween.Completed:Connect(resolve)
		tween:Play()
	end)
end

local function runAnimation(part, intensity)
	return Promise.resolve()
		:finallyCall(sleep, 1)
		:finallyCall(runTween, part, {
			Reflectance = 1 * intensity
		}):finallyCall(runTween, part, {
			CFrame = CFrame.new(part.Position) *
				CFrame.Angles(0, math.rad(90 * intensity), 0)
		}):finallyCall(runTween, part, {
			Size = (
				Vector3.new(10, 10, 10) * intensity
			) + Vector3.new(1, 1, 1)
		})
end

local animation = Promise.resolve() -- Begin Promise chain
	:finallyCall(runAnimation, workspace.Part, 1)
	:finallyCall(sleep, 1)
	:finallyCall(runAnimation, workspace.Part, 0)
	:catch(warn)

wait(2)
animation:cancel() -- Remove this line to see the full animation
```