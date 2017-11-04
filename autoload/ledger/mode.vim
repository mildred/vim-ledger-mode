" vim:ts=2:sw=2:sts=2:foldmethod=marker

let g:ledger_mode = ''

function! ledger#mode#toggle()
  if len(g:ledger_mode)
    let g:ledger_mode = ''
    nunmap <buffer> <Esc>
    nunmap <buffer> o
    nunmap <buffer> {
    nunmap <buffer> }
    nunmap <buffer> ^
    nunmap <buffer> $
  else
    let g:ledger_mode = 'LEDGER'
    nnoremap <buffer> <Esc> :call ledger#toggle_mode()<CR>
    nnoremap <buffer> o :call ledger#append_entry()<CR>
    nnoremap <buffer> ^ :call ledger#nav#entry_begin()<CR>
    nnoremap <buffer> $ :call ledger#nav#entry_end()<CR>
    nnoremap <buffer> { :call ledger#nav#entry_prev()<CR>
    nnoremap <buffer> } :call ledger#nav#entry_next()<CR>
  endif
endfunction

function! ledger#mode#append_entry()
  call ledger#nav#entry_end()
  call append('.', ['', strftime('%Y/%m/%d').' ', '  from  0', '  to  0'])
  call ledger#nav#entry_next()
  call cursor('.', col('$'))
  startinsert!
endfunction

