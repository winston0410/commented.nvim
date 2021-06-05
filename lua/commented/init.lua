local helper = require("commented.helper")
local opts = {
    comment_padding = " ",
    keybindings = {n = "<leader>c", v = "<leader>c"},
    set_keybindings = true,
    alt_cms = {javascriptreact = {patterns = {double = '/*%s*/'}}}
}

local function commenting_lines(lines, start_line, end_line, start_symbol,
                                end_symbol)
    local commented_lines = helper.map(lines, function(line)
        local commented_line = line:gsub("([^%s])", start_symbol ..
                                             opts.comment_padding .. "%1", 1)
        if end_symbol ~= "" then
            commented_line = commented_line .. opts.comment_padding ..
                                 end_symbol
        end

        return commented_line
    end)

    vim.api.nvim_buf_set_lines(0, start_line, end_line, false, commented_lines)
end

local function uncommenting_lines(lines, start_line, end_line, uncomment_symbols)
    local uncommented_lines = helper.map(lines, function(line, index)
        local start_symbol, end_symbol = unpack(uncomment_symbols[index])
        local uncommented_line = line:gsub(start_symbol .. "%s*", "", 1)
        if end_symbol ~= "" then
            uncommented_line = uncommented_line:gsub("%s*" .. end_symbol, "")
        end
        return uncommented_line
    end)

    vim.api
        .nvim_buf_set_lines(0, start_line, end_line, false, uncommented_lines)
end

local function has_matching_pattern(line, comment_patterns, uncomment_symbols)
    local matched = false
    for _, pattern in pairs(comment_patterns) do
        local escaped_start_symbol, escaped_end_symbol =
            helper.escape_symbols(helper.get_comment_wrap(pattern))
        local escaped_pattern = escaped_start_symbol .. ".*" ..
                                    escaped_end_symbol
        if line:match(escaped_pattern) then
            table.insert(uncomment_symbols,
                         {escaped_start_symbol, escaped_end_symbol})
            matched = true
            break
        end
    end
    return matched
end

local function toggle_comment(mode)
    local start_line, end_line = helper.get_lines(mode)
    local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
    local should_comment = false
    local filetype, cms = vim.o.filetype,
                          vim.api.nvim_buf_get_option(0, 'commentstring')

    local comment_start_symbol, comment_end_symbol =
        helper.get_comment_wrap(cms)
    local uncomment_symbols = {}

    local alt_cms_opts = opts.alt_cms[filetype] or {}

    local comment_patterns = vim.tbl_extend('force', {cms = cms},
                                            alt_cms_opts.patterns or {})
    for _, line in ipairs(lines) do
        if line ~= "" then
            local matched = has_matching_pattern(line, comment_patterns,
                                                 uncomment_symbols)
            if not matched then
                should_comment = true
                break
            end
        else
            table.insert(uncomment_symbols, {"", ""})
        end
    end

    -- print('check should_comment', should_comment, vim.inspect(uncomment_symbols))

    if should_comment then
        local comment_string_to_use = alt_cms_opts.to_comment or "cms"

        if comment_string_to_use ~= "cms" then
            comment_start_symbol, comment_end_symbol =
                helper.get_comment_wrap(
                    alt_cms_opts.patterns[comment_string_to_use])
        end

        commenting_lines(lines, start_line, end_line, comment_start_symbol,
                         comment_end_symbol)
    else
        uncommenting_lines(lines, start_line, end_line, uncomment_symbols)
    end

    if mode == 'v' then vim.api.nvim_input("<esc>") end

end

local function setup(user_opts)
    opts = vim.tbl_extend('force', opts, user_opts or {})
    local supported_modes = {'n', 'v'}
    if opts.set_keybindings then
        for _, mode in ipairs(supported_modes) do
            vim.api.nvim_set_keymap(mode, opts.keybindings[mode],
                                    "<cmd>lua require('commented').toggle_comment('" ..
                                        mode .. "')<cr>",
                                    {silent = true, noremap = true})
        end
    end
end

return {setup = setup, toggle_comment = toggle_comment}
