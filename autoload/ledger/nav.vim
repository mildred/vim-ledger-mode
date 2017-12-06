" vim:ts=2:sw=2:sts=2:foldmethod=marker

function! s:isfirst(l)
  return match(getline(a:l), '^\d') == 0
endf

function! s:isintr(l)
  return match(getline(a:l), '^\s') == 0
endf

function! ledger#nav#entry_prev_line(...)
  if ! exists('a:1') || a:1 == '.'
    let l = line('.')
  else
    let l = a:1
  endif
  if l == 1
    return l
  endif
  let oldl = l
  while ! s:isfirst(l) && l > 1
    let l = l - 1
  endwhile
  let l = l - 1
  while ! s:isfirst(l) && l > 1
    let l = l - 1
  endwhile
  if ! s:isfirst(l)
    let l = ledger#nav#entry_line(oldl)
  endif
  return l
endf

function! ledger#nav#entry_prev()
  call cursor(ledger#nav#entry_prev_line(), 1)
endf

function! ledger#nav#entry_next_line(...)
  if ! exists('a:1') || a:1 == '.'
    let l = line('.')
  else
    let l = a:1
  endif
  if l == line('$')
    return l
  endif
  let oldl = l
  let l = l + 1
  while ! s:isfirst(l) && l < line('$')
    let l = l + 1
  endwhile
  if ! s:isfirst(l)
    let l = ledger#nav#entry_line(oldl)
  endif
  return l
endf

function! ledger#nav#entry_next()
  call cursor(ledger#nav#entry_next_line(), 1)
endf

function! ledger#nav#entry_line(...)
  if ! exists('a:1') || a:1 == '.'
    let l = line('.')
  else
    let l = a:1
  endif
  while ! s:isfirst(l) && l > 1
    let l = l - 1
  endwhile
  if ! s:isfirst(l)
    while ! s:isfirst(l) && l < line('$')
      let l = l + 1
    endwhile
  endif
  return l
endf

function! ledger#nav#entry_line_last(...)
  if ! exists('a:1') || a:1 == '.'
    let l = line('.')
  else
    let l = a:1
  endif
  let l = ledger#nav#entry_line(l)
  while l < line('$') && s:isintr(l+1)
    let l = l + 1
  endwhile
  return l
endf

function! ledger#nav#entry_begin()
  call cursor(ledger#nav#entry_line(), 1)
endf

function! ledger#nav#entry_end()
  call cursor(ledger#nav#entry_line_last(), 1)
endf
