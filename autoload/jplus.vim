scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! jplus#getchar()
	let c = getchar()
	if type(c) == type(0)
		return nr2char(c)
	endif
	if c !~ '[[:print:]]'
		return 0
	endif
endfunction


let s:counfig = {
\	"ignore_pattern" : '.*',
\	"match_pattern"  : '.*',
\	"firstline" : 0,
\	"lastline" : 0,
\	"delimiter" : "",
\}


function! s:join(config)
	let ignore =  a:config.ignore_pattern
	let match_pattern = a:config.match_pattern
	let c = a:config.delimiter
	let start = a:config.firstline
	let lastline = a:config.lastline
	let end = lastline + (start == lastline)

	let next = join(map(filter(map(getline(start + 1, end), 'matchstr(v:val, match_pattern)'), 'len(v:val) && !(ignore != "" && (v:val =~ ignore))'), 'matchstr(v:val, ''^\s*\zs.*'')'), c)
	if next == ""
		let line = matchstr(getline(start), match_pattern)
	else
		let line = matchstr(getline(start), match_pattern) . c . next
	endif
	call setline(start, line)

	if start+1 <= end
		silent execute start+1 . ',' . end 'delete _'
	endif
	normal! -1
endfunction



let g:jplus#configs = get(g:, "jplus#configs", {})

function! jplus#config(filetype, ...)
	let base = get(a:, 1, {})
	return extend(
\		extend(get(g:jplus#configs, "_", {}), get(g:jplus#configs, a:filetype, {}))
\	, base)
endfunction


function! jplus#join(config) range
	let config = extend({
\		"firstline" : a:firstline,
\		"lastline"  : a:lastline,
\		"ignore_pattern" : '',
\		"match_pattern"  : '.*',
\	}, a:config)
	call s:join(config)
endfunction


function! jplus#mapexpr_join(...)
	let g:jplus_tmp_config = get(a:, 1, {})
	return ":call jplus#join(g:jplus_tmp_c, g:jplus_tmp_config)\<CR>"
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
