function! Commented_n() abort
    set opfunc=Toggle_comment_normal
    return 'g@'
endfunction

function! Commented_nl() abort
	set opfunc=Toggle_comment_normal
	return 'g@$'
endfunction

function! Toggle_comment_normal(type)
	execute "lua require('commented').toggle_comment('n')"
endfunction
