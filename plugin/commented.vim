function! Toggle_comment_normal(...)
	execute "lua require('commented').toggle_comment('n')"
endfunction
