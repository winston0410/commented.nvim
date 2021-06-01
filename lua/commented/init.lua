local helper = require("commented.helper")
local opts = {
    comment_padding = " ",
    keybindings = {n = "<leader>c", v = "<leader>c"},
    set_keybindings = true
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

local function uncommenting_lines(lines, start_line, end_line, start_symbol,
                                  end_symbol)
    local uncommented_lines = helper.map(lines, function(line)
        local uncommented_line = line:gsub(start_symbol .. opts.comment_padding,
                                           "", 1)
        if end_symbol ~= "" then
            uncommented_line = uncommented_line:gsub(
                                   opts.comment_padding .. end_symbol, "")
        end
        return uncommented_line
    end)

    vim.api
        .nvim_buf_set_lines(0, start_line, end_line, false, uncommented_lines)
end

local function get_comment_wrap()
    local cs = vim.api.nvim_buf_get_option(0, 'commentstring')
    if cs:find('%%s') then
        return cs:match('^(.*)%%s'), cs:match('^.*%%s(.*)')
    else
        return nil
    end
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

local function toggle_comment(mode)
    local start_line, end_line = get_lines(mode)
    local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
    local shouldComment = false

    local comment_start_symbol, comment_end_symbol = get_comment_wrap()
    local escaped_start_symbol, escaped_end_symbol =
        helper.escape_symbols(comment_start_symbol),
        helper.escape_symbols(comment_end_symbol)

    local pattern = escaped_start_symbol .. ".*" .. escaped_end_symbol

    for _, line in ipairs(lines) do
        if line ~= "" then
            if not line:match(pattern) then
                shouldComment = true
                break
            end
        end
    end

    if shouldComment then
        commenting_lines(lines, start_line, end_line, comment_start_symbol,
                         comment_end_symbol)
    else
        uncommenting_lines(lines, start_line, end_line, escaped_start_symbol,
                           escaped_end_symbol)
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
