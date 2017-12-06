" vim:ts=2:sw=2:sts=2:foldmethod=marker

let g:ledger_mode = ''

function! ledger#mode#toggle()
  if len(g:ledger_mode)
    let g:ledger_mode = ''
    nunmap <buffer> <Esc>
    nunmap <buffer> {
    nunmap <buffer> }
    nunmap <buffer> ^
    nunmap <buffer> $
    nunmap <buffer> o
    nunmap <buffer> O
    nunmap <buffer> tt
    nunmap <buffer> <leader>i
    iunmap <buffer> <Tab>
    iunmap <buffer> <CR>
  else
    let g:ledger_mode = 'LEDGER'
    nnoremap <buffer> <Esc> :call ledger#toggle_mode()<CR>
    nnoremap <buffer> ^ :call ledger#nav#entry_begin()<CR>
    nnoremap <buffer> $ :call ledger#nav#entry_end()<CR>
    nnoremap <buffer> { :call ledger#nav#entry_prev()<CR>
    nnoremap <buffer> } :call ledger#nav#entry_next()<CR>
    nnoremap <buffer> o :call ledger#mode#append_entry()<CR>
    nnoremap <buffer> O :call ledger#mode#append_before_entry()<CR>
    nnoremap <buffer> tt :call ledger#mode#toggle_date()<CR>
    nnoremap <buffer> <leader>i :echo ledger#entry#field()<CR>
    inoremap <buffer> <Tab> <C-x><C-o>
    inoremap <buffer> <CR> <C-O>:call ledger#mode#next_field()<CR>
  endif
endfunction

function! ledger#mode#toggle_date()
  let l = line('.')
  let prevdate = ledger#entry#get_date_str(ledger#nav#entry_prev_line(l))
  let olddate = ledger#entry#get_date_str(l)
  let today = strftime('%Y/%m/%d')
  if olddate != prevdate
    let b:ledger_mode_date_mode = 'prev'
    call ledger#entry#set_date_str(l, prevdate)
  elseif olddate != today
    let b:ledger_mode_date_mode = 'today'
    call ledger#entry#set_date_str(l, today)
  endif
endfunction

function! ledger#mode#append_before_entry()
  call ledger#nav#entry_begin()
  if exists('b:ledger_mode_date_mode') && b:ledger_mode_date_mode == 'today'
    let date = strftime('%Y/%m/%d')
  else
    let date = ledger#entry#get_date_str(line('.'))
  endif
  call append(line('.')-1, [date, ''])
  call ledger#nav#entry_prev()
  call cursor('.', col('$'))
  startinsert!
endfunction

function! ledger#mode#append_entry()
  call ledger#nav#entry_end()
  if exists('b:ledger_mode_date_mode') && b:ledger_mode_date_mode == 'today'
    let date = strftime('%Y/%m/%d')
  else
    let date = ledger#entry#get_date_str(line('.'))
  endif
  call append('.', ['', date])
  call ledger#nav#entry_next()
  call cursor('.', col('$'))
  startinsert!
endfunction

function! ledger#mode#next_field()
  let [type, data] = ledger#entry#field()
  let c = col('.')
  let line = getline('.')
  if type == '' || (type == 'account' && data == '')
    call setline('.', substitute(line, '\s*$', '', ''))
    if getline('.') == ''
      execute line 'delete _'
    endif
    call ledger#mode#append_entry()
  elseif type == 'date'
    let pos = match(line, '(.\{-}\zs)')
    let spc = match(line, '\s\+\zs')
    if pos != -1
      call cursor('.', pos+1)
    elseif spc != -1
      call setline('.', line[0:spc-1].'() '.line[spc:])
      call cursor('.', spc+2)
    else
      call setline('.', line.' ()')
      call cursor('.', col('$')-1)
      echo 'line='.line
    endif
  elseif type == 'code' && data == ''
    call setline('.', substitute(line, '^.\{-}\s*\zs()\s*', '', ''))
    call cursor('.', col('$'))
  elseif type == 'code'
    call cursor('.', col('$'))
  elseif type == 'account'
    let sep = match(line, '\s*\S.\{-}  \+\zs')
    if sep != -1
      call cursor('.', col('$'))
    else
      call setline('.', line.'  ')
      call cursor('.', col('$'))
    endif
  elseif type == 'amount' || type == 'comment'
    call setline('.', substitute(line, '\s*$', '', ''))
    call append('.', '  ')
    call cursor(line('.')+1, 0)
    call cursor('.', col('$'))
  else
    call setline('.', substitute(line, '\s*$', '', ''))
    call append('.', '')
    call cursor(line('.')+1, 0)
  end
endfunction
