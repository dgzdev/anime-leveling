local Utils = {}

function Utils.Map<T, K>(array: { T }, mapping: (T) -> K)
	local result = {}
	for i, obj in array do
		result[i] = mapping(obj)
	end
	return result
end

function Utils.Filter<T>(array: { T }, predicate: (T) -> boolean)
	local result = {}
	for _, obj in array do
		if predicate(obj) then
			result[#result + 1] = obj
		end
	end
	return result
end

return Utils
