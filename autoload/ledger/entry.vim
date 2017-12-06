" vim:ts=2:sw=2:sts=2:foldmethod=marker

function! ledger#entry#get_date_str(l)
  let l = ledger#nav#entry_line(a:l)
  let line = getline(l)
  return matchstr(line, '^\S*')
endfunction

function! ledger#entry#set_date_str(l, newdate)
  let l = ledger#nav#entry_line(a:l)
  let line = getline(l)
  let line = substitute(line, '^\S*', a:newdate, '')
  call setline(l, line)
endfunction

function! s:isfirst(l)
  return match(getline(a:l), '^\d') == 0
endf

function! s:isintr(l)
  return match(getline(a:l), '^\s') == 0
endf

function! ledger#entry#field()
  if ! exists('a:1') || a:1 == '.'
    let l = line('.')
  else
    let l = a:1
  endif
  if ! exists('a:2') || a:2 == '.'
    let c = col('.')
  else
    let c = a:2
  endif
  let line = getline(l)
  if s:isfirst(l)
    let spcpos = match(line, '\s')
    if spcpos == -1
      return ['date', line]
    endif
    if c <= spcpos
      return ['date', line[0:spcpos-1]]
    endif
    let flagpos = match(line, '^\S\+\s\+\zs[!\*]')
    if flagpos != -1 && c <= flagpos+1
      return ['flag', line[flagpos]]
    endif
    let codestartpos = match(line, '(')
    let codeendpos = match(line, '(.*\zs)')
    if flagpos < codestartpos && codestartpos < codeendpos && c <= codeendpos+1
      return ['code', line[codestartpos+1:codeendpos-1]]
    endif
    let commentpos = match(line, '\s*\zs', max([spcpos, flagpos+1, codeendpos+1]))
    return ['comment', line[commentpos:]]
  endif
  if s:isintr(l)
    let indentpos = match(line, '\s*\zs')
    if indentpos == -1 || c <= indentpos
      return ['', '']
    endif
    let splitpos = match(line, '^\s\+\S.\{-}  \zs')
    if splitpos == -1
      return ['account', line[indentpos:]]
    endif
    if c <= splitpos-1
      return ['account', line[indentpos:splitpos-3]]
    endif
    return ['amount', line[splitpos:]]
  endif
  return ['', '']
endfunction


