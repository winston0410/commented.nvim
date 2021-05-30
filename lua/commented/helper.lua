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

local function escape_symbols(symbols)
    local results = symbols:gsub(target_symbols, replacement_table)
    return results
end

local helper = {map = map, escape_symbols = escape_symbols}

return helper
