local function map(table, callback)
	local newTable = {}
	for index, value in ipairs(table) do
		newTable[index] = callback(value, index)
	end
	return newTable
end

local helper = { map = map }

return helper
