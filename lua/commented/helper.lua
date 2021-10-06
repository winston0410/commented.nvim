local target_symbols = "[%^%$%(%)%%%.%[%]%*%+%-%?]"

local replacement_table = {
	["^"] = "%^",
	["$"] = "%$",
	["("] = "%(",
	[")"] = "%)",
	["%"] = "%%",
	["."] = "%.",
	["["] = "%[",
	["]"] = "%]",
	["*"] = "%*",
	["+"] = "%+",
	["-"] = "%-",
	["?"] = "%?",
}

local function escape_symbols(...)
	local temp = {}
	for _, symbol in ipairs({ ... }) do
		local escaped = symbol:gsub(target_symbols, replacement_table):gsub("%s+", "")
		table.insert(temp, escaped)
	end
	return unpack(temp)
end

local function get_lines(mode, line1, line2)
	local start_line, end_line
	if mode == "n" or mode == "v" then
		start_line, end_line = vim.api.nvim_buf_get_mark(0, "[")[1] - 1, vim.api.nvim_buf_get_mark(0, "]")[1]
	else
		start_line, end_line = tonumber(line1) - 1, tonumber(line2)
	end

	return start_line, end_line
end

local function get_comment_wrap(cs)
	if cs:find("%%s") then
		return cs:match("^(.*)%%s"), cs:match("^.*%%s(.*)")
	end
	return nil
end

-- NOTE: vim.tbl_map doesn't provide an index in callback
local function map(callback, list)
    local updated = {}
	for index, item in ipairs(list) do
        updated[index] = callback(item, index)
	end
    return updated
end

return {
	get_lines = get_lines,
	get_comment_wrap = get_comment_wrap,
	escape_symbols = escape_symbols,
    map = map
}

