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

function! ledger#entry#number(...)
  if ! exists('a:1') || a:1 == '.'
    let l = line('.')
  else
    let l = a:1
  endif
  let li = 0
  let num = 0
  while li <= l
    if match(getline(li), '^\d') == 0
      let num = num + 1
    endif
    let li = li + 1
  endwhile
  return num
endfunction

function! ledger#entry#account_names(...)
  if ! exists('a:1') || a:1 == '.'
    let l = line('.')
  else
    let l = a:1
  endif
  let last = ledger#nav#entry_line_last(l)
  let l = ledger#nav#entry_line(l)+1
  let res = []
  while l <= last
    let n = ledger#entry#account_name(l)
    if n != ""
      let res += [n]
    endif
    let l = l + 1
  endwhile
  return res
endfunction

function! ledger#entry#account_name(...)
  if ! exists('a:1') || a:1 == '.'
    let l = line('.')
  else
    let l = a:1
  endif
  let line = getline(l)
  let first = match(line, '\S')
  let last = match(line, '  ', first)
  if first < 1
    return ""
  elseif last == -1
    return line[first:]
  else
    return line[first:last-1]
  endif
endfunction

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


