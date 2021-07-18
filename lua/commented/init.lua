local helper = require("commented.helper")
local opts = {
	comment_padding = " ",
	keybindings = { n = "<leader>c", v = "<leader>c", nl = "<leader>cc" },
	set_keybindings = true,
	alt_cms = {
		typescriptreact = { block = "/*%s*/" },
		javascriptreact = { block = "/*%s*/" },
		javascript = { block = "/*%s*/" },
		typescript = { block = "/*%s*/" },
		sql = { inline = "--%s", block = "/*%s*/" },
		lua = { block = "--[[%s--]]" },
		teal = { block = "--[[%s--]]" },
		rust = { block = "/*%s*/" },
		kotlin = { block = "/*%s*/" },
		java = { block = "/*%s*/" },
		go = { block = "/*%s*/" },
		nix = { inline = "#%s" },
		cpp = { inline = "//%s" },
		fennel = { inline = ";;%s" },
		elixir = { inline = "#%s" },
		hjson = { block = "/*%s*/", jsInline = "//%s" },
		dhall = { block = "{-%s-}" },
		lean = { block = "/-%s-/" },
		wren = { block = "/*%s*/" },
		pug = { unbuffered = "//-%s", block = "//-%s//" },
		haml = { unbuffered = "-#" },
		haxe = { block = "/**%s**/" },
		-- sh = {block = ": '%s'"},
	},
	cms_to_use = {},
	ex_mode_cmd = "Comment",
	-- replace_patterns = {
		-- nunjucks = { { "{{", "}}" }, { "{%", "%}" } },
	-- },
}

local function commenting_lines(lines, start_line, end_line, start_symbol, end_symbol)
	local commented_lines = vim.tbl_map(function(line)
		local commented_line = line:gsub("([^%s])", start_symbol .. opts.comment_padding .. "%1", 1)
		if end_symbol ~= "" then
			commented_line = commented_line .. opts.comment_padding .. end_symbol
		end

		return commented_line
	end, lines)

	vim.api.nvim_buf_set_lines(0, start_line, end_line, false, commented_lines)
end

local function clear_lines_symbols(lines, target_symbols)
	local index = 1
	return vim.tbl_map(function(line)
		if line == "" then
			return line
		end
		local start_symbol, end_symbol = unpack(target_symbols[index])
		local cleaned_line = line:gsub(start_symbol .. "%s*", "", 1)
		if end_symbol ~= "" then
			cleaned_line = cleaned_line:gsub("%s*" .. end_symbol, "")
		end
		index = index + 1
		return cleaned_line
	end, lines)
end

local function uncommenting_lines(lines, start_line, end_line, uncomment_symbols)
	vim.api.nvim_buf_set_lines(0, start_line, end_line, false, clear_lines_symbols(lines, uncomment_symbols))
end

local function has_matching_pattern(line, comment_patterns, uncomment_symbols)
	local matched = false
	for _, pattern in pairs(comment_patterns) do
		local escaped_start_symbol, escaped_end_symbol = helper.escape_symbols(helper.get_comment_wrap(pattern))
		local escaped_pattern = "^%s*" .. escaped_start_symbol .. ".*" .. escaped_end_symbol
		if line:match(escaped_pattern) then
			table.insert(uncomment_symbols, { escaped_start_symbol, escaped_end_symbol })
			matched = true
			break
		end
	end
	return matched
end

local function toggle_comment(mode, line1, line2)
	local start_line, end_line = helper.get_lines(mode, line1, line2)
	local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
	local should_comment = false
	local filetype, cms = vim.o.filetype, vim.api.nvim_buf_get_option(0, "commentstring")

	local comment_start_symbol, comment_end_symbol = helper.get_comment_wrap(cms)
	local uncomment_symbols = {}
	-- For template engine
	-- local replace_symbols = {}

	local alt_cms = opts.alt_cms[filetype] or {}

	local comment_patterns = vim.tbl_extend("force", { cms = cms }, alt_cms or {})
	-- For template engine
	-- local replace_patterns = opts.replace_patterns[filetype]

	for _, line in ipairs(lines) do
		if line ~= "" then
			local matched = has_matching_pattern(line, comment_patterns, uncomment_symbols)
			if not matched then
				should_comment = true
				break
			end
		end
	end

	if should_comment then
		local comment_string_to_use = opts.cms_to_use[filetype] or "cms"

		if comment_string_to_use ~= "cms" then
			comment_start_symbol, comment_end_symbol = helper.get_comment_wrap(alt_cms[comment_string_to_use])
		end

		commenting_lines(lines, start_line, end_line, comment_start_symbol, comment_end_symbol)
	else
		uncommenting_lines(lines, start_line, end_line, uncomment_symbols)
	end
end

local function setup(user_opts)
	opts = vim.tbl_deep_extend("force", opts, user_opts or {})
	local supported_modes = { "n", "v" }
	if opts.set_keybindings then
		for _, mode in ipairs(supported_modes) do
			vim.api.nvim_set_keymap(mode, opts.keybindings[mode], "Commented_n()", {
				expr = true,
				silent = true,
				noremap = true,
			})
		end
	end

	vim.api.nvim_set_keymap("n", opts.keybindings.nl, "Commented_nl()", { expr = true, silent = true, noremap = true })

	if opts.ex_mode_cmd then
		vim.api.nvim_exec(
			"command! -range " .. opts.ex_mode_cmd .. " lua require('commented').toggle_comment('c', <line1>, <line2>)",
			true
		)
	end
end

return { setup = setup, toggle_comment = toggle_comment }
