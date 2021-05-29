local helper = require("commented.helper")

local function comment_line(lines, start_line, end_line, start_symbol, end_symbol)
    local commented_lines = helper.map(lines, function(line)
        return start_symbol .. line .. end_symbol
    end)

    vim.api.nvim_buf_set_lines(0, start_line, end_line, false, commented_lines)
end

local function uncomment_line(lines, start_line, end_line, start_symbol, end_symbol)
	local uncommented_lines = helper.map(lines, function(line)
		return line:gsub("%-%-", "")
	end)

	print('check values', uncommented_lines)

	vim.api.nvim_buf_set_lines(0, start_line, end_line, false, uncommented_lines)
end


local opts = {}

local support_modes = {"n", "v", "x"}

local function get_comment_wrap()
    local cs = vim.api.nvim_buf_get_option(0, 'commentstring')
    if cs:find('%%s') then
        return cs:match('^(.*)%%s'), cs:match('^.*%%s(.*)')
    else
        print('unsupported')
        return nil
    end
end

local function toggle_comment()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local count = vim.v.count == 0 and 0 or vim.v.count - 1
    local start_line, end_line = current_line - 1, current_line + count
    local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
    local shouldComment = false

    local comment_start_symbol, comment_end_symbol = get_comment_wrap()

	local pattern = helper.escape_symbols(comment_start_symbol) .. "[^%s*]" .. helper.escape_symbols(comment_end_symbol)

	print('check pattern', pattern)

    for _, line in ipairs(lines) do
        print('line match?', string.match(line, pattern))
        if not line:match(pattern) then
            print('should comment lines')
            shouldComment = true
            break
        end
    end

    if shouldComment then
        comment_line(lines, start_line, end_line, comment_start_symbol, comment_end_symbol)
    else
        uncomment_line(lines, start_line, end_line, comment_start_symbol, comment_end_symbol)
    end

    -- print('check commented lines', vim.inspect(commented_lines))
end

local function setup()
    vim.api.nvim_set_keymap('n', '<leader>/',
                            "<cmd>lua require('commented').toggle_comment()<cr>",
                            {silent = true, noremap = true})
end

return {setup = setup, toggle_comment = toggle_comment}
