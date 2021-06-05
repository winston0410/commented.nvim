local function map(table, callback)
    local new_table = {}
    for index, value in ipairs(table) do
        new_table[index] = callback(value, index)
    end
    return new_table
end

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
    ["?"] = "%?"
}

local function escape_symbols(...)
    local temp = {}
    for _, symbol in ipairs({...}) do
        local escaped = symbol:gsub(target_symbols, replacement_table)
        table.insert(temp, escaped)
    end
    return unpack(temp)
end

local function get_lines(mode)
    local start_line, end_line
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    if mode == "n" then
        local count = vim.v.count == 0 and 0 or vim.v.count - 1
        start_line, end_line = current_line - 1, current_line + count
    else
        start_line, end_line = vim.fn.line("v"), current_line
        if start_line > end_line then
            start_line, end_line = end_line, start_line
        end
        start_line = start_line - 1
    end

    return start_line, end_line
end

local function get_comment_wrap(cs)
    if cs:find('%%s') then
        return cs:match('^(.*)%%s'), cs:match('^.*%%s(.*)')
    else
        return nil
    end
end

local helper = {
    get_lines = get_lines,
	get_comment_wrap = get_comment_wrap,
    map = map,
    escape_symbols = escape_symbols
}

return helper
