" vim:ts=2:sw=2:sts=2:foldmethod=marker

function s:isfirst(l)
  return match(getline(a:l), '^\d') == 0
endf

function s:isintr(l)
  return match(getline(a:l), '^\s') == 0
endf

function ledger#nav#entry_prev()
  if line('.') == 1
    return
  endif
  let l = line('.')
  while ! s:isfirst('.') && line('.') > 1
    call cursor(line('.')-1, 1)
  endwhile
  call cursor(line('.')-1, 1)
  while ! s:isfirst('.') && line('.') > 1
    call cursor(line('.')-1, 1)
  endwhile
  if ! s:isfirst('.')
    call cursor(l, 1)
    call ledger#nav#entry_reposition()
  endif
endf

function ledger#nav#entry_next()
  if line('.') == line('$')
    return
  endif
  let l = line('.')
  call cursor(line('.')+1, 1)
  while ! s:isfirst('.') && line('.') < line('$')
    call cursor(line('.')+1, 1)
  endwhile
  if ! s:isfirst('.')
    call cursor(l, 1)
    call ledger#nav#entry_reposition()
  endif
endf

function ledger#nav#entry_reposition()
  while ! s:isfirst('.') && line('.') > 1
    call cursor(line('.')-1, 1)
  endwhile
  if ! s:isfirst('.')
    while ! s:isfirst('.') && line('.') < line('$')
      call cursor(line('.')+1, 1)
    endwhile
  endif
endf

function ledger#nav#entry_begin()
  call ledger#nav#entry_reposition()
endf

function ledger#nav#entry_end()
  if ! s:isfirst('.') && ! s:isintr('.')
    call ledger#nav#entry_reposition()
  endif
  while line('.') < line('$') && s:isintr(line('.')+1)
    call cursor(line('.')+1, 1)
  endwhile
endf
