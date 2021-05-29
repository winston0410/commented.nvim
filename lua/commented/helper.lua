local function map(table, callback)
    local newTable = {}
    for index, value in ipairs(table) do
        newTable[index] = callback(value, index)
    end
    return newTable
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
    print('check results', results)
    return results
end

local helper = {map = map, escape_symbols = escape_symbols}

return helper
