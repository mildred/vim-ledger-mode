" vim:ts=2:sw=2:sts=2:foldmethod=marker

let g:ledger_mode = ''
let g:ledger_mode_show_balance = 0

function! ledger#mode#toggle()
  augroup ledger_mode
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
    nunmap <buffer> <
    nunmap <buffer> >
    nunmap <buffer> <leader>i
    nunmap <buffer> <leader>b
    nunmap <buffer> ==
    iunmap <buffer> <Tab>
    iunmap <buffer> <CR>
    iunmap <buffer> <C-b>
  else
    let g:ledger_mode = 'LEDGER'
    nnoremap <buffer> <Esc> :call ledger#mode#toggle()<CR>
    nnoremap <buffer> ^ :call ledger#nav#entry_begin()<CR>
    nnoremap <buffer> $ :call ledger#nav#entry_end()<CR>
    nnoremap <buffer> { :call ledger#nav#entry_prev()<CR>
    nnoremap <buffer> } :call ledger#nav#entry_next()<CR>
    nnoremap <buffer> o :call ledger#mode#append_entry()<CR>
    nnoremap <buffer> O :call ledger#mode#append_before_entry()<CR>
    nnoremap <buffer> tt :call ledger#mode#toggle_date()<CR>
    nnoremap <buffer> < :call ledger#mode#date_incr(-1)<CR>
    nnoremap <buffer> > :call ledger#mode#date_incr(1)<CR>
    nnoremap <buffer> <leader>i :echo ledger#entry#field()<CR>
    nnoremap <buffer> <leader>b :echo ledger#mode#balance_all()<CR>
    nnoremap <buffer> == :call ledger#mode#clean_line()<CR>
    inoremap <buffer> <Tab> <C-x><C-o>
    inoremap <expr><buffer> <CR> (pumvisible() ? " " : "")."<C-O>:call ledger#mode#next_field()<CR>"
    inoremap <buffer> <C-b> <C-O>:call ledger#mode#balance_all_cached()<CR>
    if g:ledger_mode_show_balance
      autocmd CursorMoved  * :echo ledger#mode#balance_all_cached()
      autocmd CursorMovedI * :echo ledger#mode#balance_all_cached()
    endif
  endif
  augroup END
endfunction

function! ledger#mode#toggle_date()
  let l = line('.')
  let prevdate = ledger#entry#get_date_str(ledger#nav#entry_prev_line(l))
  let olddate = ledger#entry#get_date_str(l)
  let today = strftime('%Y-%m-%d')
  if olddate != prevdate
    let b:ledger_mode_date_mode = 'prev'
    call ledger#entry#set_date_str(l, prevdate)
  elseif olddate != today
    let b:ledger_mode_date_mode = 'today'
    call ledger#entry#set_date_str(l, today)
  endif
endfunction

function! ledger#mode#adjust_date(date, offset)
python << EOF
import vim
import datetime

result = datetime.datetime.strptime(vim.eval("a:date"), "%Y-%m-%d") + \
        datetime.timedelta(days=int(vim.eval("a:offset")))
vim.command("let l:result = '" + result.strftime("%Y-%m-%d") + "'")
EOF
return result
endfunction

function! ledger#mode#date_incr(days)
  let l = line('.')
  let olddate = ledger#entry#get_date_str(l)
  let newdate = ledger#mode#adjust_date(olddate, a:days)
  call ledger#entry#set_date_str(l, newdate)
endf

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

let g:ledger_mode_balance_all_cache_n = -1
let g:ledger_mode_balance_all_cache_txt = ''
function! ledger#mode#balance_all_cached()
  let n = ledger#entry#number()
  if g:ledger_mode_balance_all_cache_n != n
    let g:ledger_mode_balance_all_cache_n = n
    let g:ledger_mode_balance_all_cache_txt = ledger#mode#balance_all()
  endif
  return g:ledger_mode_balance_all_cache_txt
endfunction

let g:ledger_mode_balance_all_show_all_limit = 5
function! ledger#mode#balance_all()
  let n = ledger#entry#number()
  let accounts = ledger#entry#account_names()
  let last = ledger#nav#entry_line_last()+1
  let args = ""
  let more = ''
  if g:ledger_mode_balance_all_show_all_limit < 0 || len(accounts) > g:ledger_mode_balance_all_show_all_limit
    for acc in accounts
      let args = args . ' ' . shellescape(acc)
    endfor
    let more = '...'
  endif
  let res = "#" . n . " " . system('ledger -f - --head '.n.' -F "| %a: %t " --no-color --no-pager balance --no-total'.args, join(getline(1, last), "\n")) . more
  if g:ledger_mode_balance_all_cache_n == n
    let g:ledger_mode_balance_all_cache_txt = res
  endif
  return res
endf

function! ledger#mode#balance()
  let n = ledger#entry#number()
  let account_name = ledger#entry#account_name()
  let last = ledger#nav#entry_line_last()+1
  return "#" . n . " " . system('ledger -f - --head '.n.' -F "%a: %t " --no-color --no-pager balance --no-total '.shellescape(account_name), join(getline(1, last), "\n"))
endf

function! ledger#mode#insert_current_balance()
  let n = ledger#entry#number()
  let account_name = ledger#entry#account_name()
  let last = ledger#nav#entry_line_last()+1
  let balance = system('ledger -f - --no-color --no-pager balance', join(getline(1, last), "\n"))
  let balance = split("; ".substitute(substitute(balance, "\n$", "", ""), "\n", "\n; ", "g")."\n\n", "\n")
  call append(last, balance)
  call cursor(last + len(balance), 1)
endf

function! ledger#mode#clean_line()
  if ledger#entry#isintr()
    let line = getline('.')
    let amount = substitute(line, '^\s*\S.\{-}  \D*\(\d\+\.\?\d*\).*', '\1', '')
    let dotpos = match(amount, '\.\zs')
    if dotpos == -1
      let amount = amount . '.0'
    elseif dotpos == len(amount)
      let amount = amount . '0'
    endif
    let line = substitute(line, '\(^\s*\S.\{-}  \D*\)\@<=\(\d\+\.\?\d*\)', amount, '')

    call setline('.', line)
    call ledger#align_commodity()
    let line = getline('.')
    let line = substitute(line, "\s*$", "", "")
    call setline('.', line)
  endif
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
      call ledger#align_commodity()
    endif
  elseif type == 'amount' || type == 'comment'
    if type == 'amount'
      let line = substitute(line, "\s*", "", "")
      "let line = substitute(line, '\(^\s*\S.\{-}  \D*\)\@<=\(\d\+\)\(\.\?\)', '\2.', '')
      let amount = substitute(line, '^\s*\S.\{-}  \D*\(\d\+\.\?\d*\).*', '\1', '')
      let dotpos = match(amount, '\.\zs')
      if dotpos == -1
        let amount = amount . '.0'
      elseif dotpos == len(amount)
        let amount = amount . '0'
      endif
      let line = substitute(line, '\(^\s*\S.\{-}  \D*\)\@<=\(\d\+\.\?\d*\)', amount, '')
      call setline('.', line)
      call ledger#align_commodity()
      let line = getline('.')
    endif
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
