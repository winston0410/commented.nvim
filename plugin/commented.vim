function! Commented_normal() abort
    set opfunc=Toggle_comment_normal
    return 'g@'
endfunction

function! Commented_visual() abort
    set opfunc=Toggle_comment_virtual
    return 'g@'
endfunction

function! Toggle_comment_normal()
	execute "lua require('commented').toggle_comment('n')"
endfunction

function! Toggle_comment_virtual()
	execute "lua require('commented').toggle_comment('v')"
endfunction
