local helper = require("commented.helper")
local opts = {
	comment_padding = " ",
	keybindings = { n = "<leader>c", v = "<leader>c", nl = "<leader>cc" },
	set_keybindings = true,
	prefer_block_comment = false, -- Set it to true to automatically use block comment when multiple lines are selected
	inline_cms = {
		hjson = { inline = "//%s" },
		mysql = { inline = "#%s" },
		jproperties = { inline = "!%s" },
		terraform = { inline = "//%s" },
		service = { inline = ";%s" },
		dosini = { inline = "#%s" },
	},
	block_cms = {
		wast = { block = "(;%s;)" },
		asciidoc = { block = "////%s////" },
		imba = { block = "###%s###" },
		bicep = { block = "/*%s*/" },
		yang = { block = "/*%s*/" },
		solidity = { block = "/*%s*/" },
		typescriptreact = { block = "/*%s*/" },
		javascriptreact = { block = "/*%s*/" },
		javascript = { block = "/*%s*/" },
		typescript = { block = "/*%s*/" },
		mint = { block = "/*%s*/" },
		jsonc = { block = "/*%s*/" },
		sql = { block = "/*%s*/" },
		mysql = { block = "/*%s*/" },
		lua = { block = "--[[%s--]]" },
		teal = { block = "--[[%s--]]" },
		rust = { block = "/*%s*/" },
		kotlin = { block = "/*%s*/" },
		java = { block = "/*%s*/" },
		groovy = { block = "/*%s*/" },
		go = { block = "/*%s*/" },
		php = { block = "/*%s*/" },
		c = { block = "/*%s*/", throw_away_block = "#if 0%s#endif" },
		cpp = { block = "/*%s*/", throw_away_block = "#if 0%s#endif" },
		vala = { block = "/*%s*/" },
		genie = { block = "/*%s*/" },
		cs = { block = "/*%s*/" },
		fs = { block = "(*%s*)" },
		julia = { block = "#=%s=#" },
		hjson = { block = "/*%s*/" },
		dhall = { block = "{-%s-}" },
		lean = { block = "/-%s-/" },
		wren = { block = "/*%s*/" },
		pug = { unbuffered = "//-%s", block = "//-%s//" },
		haml = { unbuffered = "-#" },
		haxe = { block = "/**%s**/" },
		rjson = { block = "/*%s*/" },
		jison = { block = "/*%s*/" },
		terraform = { block = "/*%s*/" },
		d = { block = "/*%s*/", alt_block = "/+%s+/" },
		yuck = { block = "#|%s|#" },
		racket = { block = "#|%s|#" },
		pony = { block = "/*%s*/" },
		reason = { block = "/*%s*/" },
		rescript = { block = "/*%s*/" },
	},
	-- commentstring used for commenting
	lang_options = {},
	ex_mode_cmd = "Comment",
	left_align_comment = false,
	hooks = {},
}

local leading_space = "^%s*"
local space_only = leading_space .. "$"

local function commenting_lines(fn_opts)
	local start_symbol, end_symbol = fn_opts.symbols[1], fn_opts.symbols[2]

	local commented_lines = helper.map(function(line, index)
		-- local pattern = opts.left_align_comment and leading_space or "([^%s])"
		-- ([^%s*])
		-- Make this a global option?
		local pattern = "([^%s])"
		local commented_line = line:gsub(pattern, (index == 1 and start_symbol ..fn_opts.prefix or start_symbol) .. opts.comment_padding .. "%1", 1)
		if end_symbol ~= "" then
			commented_line = commented_line .. opts.comment_padding .. end_symbol
		end

		return commented_line
	end, fn_opts.lines)

	vim.api.nvim_buf_set_lines(0, fn_opts.start_line, fn_opts.end_line, false, commented_lines)
end

local function clear_lines_symbols(lines, target_symbols)
	local index = 1
	return vim.tbl_map(function(line)
		if line:match(space_only) then
			return line
		end
		local start_symbol, end_symbol = unpack(target_symbols[index])
		local pattern = opts.left_align_comment and opts.comment_padding or "%s*"
		local cleaned_line = line:gsub(start_symbol .. pattern, "", 1)
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

local function toggle_inline_comment(fn_opts)
	local should_comment = false
	local uncomment_symbols, filetype = {}, vim.o.filetype
	local cms = vim.api.nvim_buf_get_option(0, "commentstring")
	-- exit early if no cms defined
	if cms == "" then
		vim.api.nvim_err_writeln("Commented.nvim: No commentstring defined for this filetype.")
		return
	end
	local alt_cms = opts.inline_cms[filetype] or {}
	local comment_patterns = vim.tbl_extend("force", { cms = cms }, alt_cms or {})

	for _, line in ipairs(fn_opts.lines) do
		if not line:match(space_only) then
			local matched = has_matching_pattern(line, comment_patterns, uncomment_symbols)
			if not matched then
				should_comment = true
				break
			end
		end
	end

	if should_comment then
		local cms_to_use = (opts.lang_options[filetype] or {}).inline and opts.lang_options[filetype].inline or cms
		commenting_lines({
			lines = fn_opts.lines,
			start_line = fn_opts.start_line,
			end_line = fn_opts.end_line,
			prefix = fn_opts.prefix,
			symbols = {
				helper.escape_symbols(helper.get_comment_wrap(cms_to_use)),
			},
		})
	else
		uncommenting_lines(fn_opts.lines, fn_opts.start_line, fn_opts.end_line, uncomment_symbols)
	end
end

local function toggle_block_comment(lines, start_line, end_line, block_symbols, should_comment, insert_newlines)
	if should_comment then
		lines[1] = lines[1]:gsub("([^%s])", block_symbols[1][1] .. opts.comment_padding .. "%1", 1)

		if insert_newlines then
			local str = lines[1]
			i, j = string.find(str, block_symbols[1][1] .. opts.comment_padding)
			lines[1] = string.sub(str, i, j - #opts.comment_padding)
			table.insert(lines, 2, string.sub(str, 0, i - 1) .. string.sub(str, j + #opts.comment_padding, #str))
		end

		lines[#lines] = lines[#lines]:gsub("%s*$", "%1" .. opts.comment_padding .. block_symbols[2][2], 1)

		if insert_newlines then
			local str = lines[#lines]
			i, j = string.find(str, block_symbols[2][2])
			lines[#lines] = string.sub(str, 0, i - #opts.comment_padding - 1)
			table.insert(lines, #lines + 1, string.sub(str, i, j))
		end

		vim.api.nvim_buf_set_lines(0, start_line, end_line, false, lines)
	else
		lines[1], lines[#lines] = unpack(clear_lines_symbols({ lines[1], lines[#lines] }, block_symbols))
		-- If we have empty lines, we inserted newlines so delete them
		if #lines[1] == 0 and #lines[#lines] == 0 then
			table.remove(lines, 1)
			table.remove(lines, #lines)
		end
		vim.api.nvim_buf_set_lines(0, start_line, end_line, false, lines)
	end
end

local function has_symbol(prefix, suffix)
	return function(str, symbol)
		return str:match(prefix .. symbol .. suffix)
	end
end

local has_start_symbol = has_symbol("^%s*", "")
local has_end_symbol = has_symbol("", "%s*$")

local function toggle_comment(mode, comment_prefix, line1, line2)
	local start_line, end_line = helper.get_lines(mode, line1, line2)
	local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
	local is_block, should_comment, insert_newlines = false, true, false
	local block_symbols = nil
	local filetype = vim.o.filetype

	if type(opts.hooks.before_comment) == "function" then
		opts.hooks.before_comment()
	end

	if opts.block_cms[filetype] then
		if #lines > 1 then
			local comment_patterns = opts.block_cms[filetype]
			if not comment_patterns then
				return
			end

			local first_line, last_line = lines[1], lines[#lines]
			for _, pattern in pairs(comment_patterns) do
				local start_symbol, end_symbol = helper.escape_symbols(helper.get_comment_wrap(pattern))
				if
					has_start_symbol(first_line, start_symbol)
					and not has_end_symbol(first_line, end_symbol)
					and not has_start_symbol(last_line, start_symbol)
					and has_end_symbol(last_line, end_symbol)
				then
					block_symbols = { { start_symbol, "" }, { "", end_symbol } }
					is_block, should_comment = true, false
					break
				end
			end

			if
				opts.prefer_block_comment
				or opts.lang_options[filetype] and (opts.lang_options[filetype] or {}).prefer_block_comment
			then
				-- Decide what block symbol to use
				local start_symbol, end_symbol
				if opts.lang_options[filetype] and (opts.lang_options[filetype].cms or {}).block then
					start_symbol, end_symbol = helper.escape_symbols(
						helper.get_comment_wrap(opts.lang_options[filetype].cms.block)
					)
					if opts.lang_options[filetype].insert_newlines then
						insert_newlines = true
					end
				else
					start_symbol, end_symbol = helper.escape_symbols(
						helper.get_comment_wrap(opts.block_cms[filetype].block)
					)
				end
				block_symbols = { { start_symbol, "" }, { "", end_symbol } }
				is_block = true
			end
		end
	end

	if is_block then
		toggle_block_comment(lines, start_line, end_line, block_symbols, should_comment, insert_newlines)
	else
		toggle_inline_comment({ lines = lines, start_line = start_line, end_line = end_line, prefix = comment_prefix })
	end
end

local function opfunc(prefix)
	return function()
		toggle_comment("n", prefix)
	end
end

local function commented(prefix)
	prefix = prefix or ""
	_G.commented = opfunc(prefix)
	vim.api.nvim_set_option("opfunc", "v:lua.commented")
	return "g@"
	--  Return the string for evaluation, so that we don't need to feed key
	--  vim.api.nvim_feedkeys('g@', 'n')
end

local function commented_line(prefix)
	prefix = prefix or ""
	_G.commented = opfunc(prefix)
	vim.api.nvim_set_option("opfunc", "v:lua.commented")
	return "g@$"
end

local function setup(user_opts)
	opts = vim.tbl_deep_extend("force", opts, user_opts or {})
    -- NOTE: For backward compatibility
    opts.keybindings.x = opts.keybindings.v
	opts.inline_cms = vim.tbl_deep_extend("force", opts.inline_cms, opts.block_cms)
	local supported_modes = { "n", "x" }
	if opts.set_keybindings then
		for _, mode in ipairs(supported_modes) do
			vim.api.nvim_set_keymap(mode, opts.keybindings[mode], "v:lua.require'commented'.commented()", {
				expr = true,
				silent = true,
				noremap = true,
			})
		end
		vim.api.nvim_set_keymap(
			"n",
			opts.keybindings.nl,
			"v:lua.require'commented'.commented_line()",
			{ expr = true, silent = true, noremap = true }
		)
	end

	if opts.ex_mode_cmd then
		vim.api.nvim_exec(
			"command! -range "
				.. opts.ex_mode_cmd
				.. " lua require('commented').toggle_comment('c', '', <line1>, <line2>)",
			true
		)
	end
end

return { setup = setup, toggle_comment = toggle_comment, commented = commented, commented_line = commented_line }
