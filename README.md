vim-ledger-mode
===============

This vim plugin is to be used along with
[vim-ledger](http://github.com/ledger/vim-ledger) and add a special ledger mode
with special keybindings.

Keybindings
-----------

To enter ledger mode, in normal mode, type `<leader>l`. You are then in ledger
normal mode.

### Normal Ledger Mode ###

- `<Esc>` escapes the ledger mode back to normal mode
- `{` and `}` navigates to the previous / next transaction
- `^` and `$` navigates to the first / last line of the current transaction
- 'o' opens up a transaction below the current one and goes to ledger insert
  mode

TODO:

- `O` to open a transaction before the current one
- `tt` to toggle the current transaction between the current date and the date of
  the previous transaction
- `tr` to toggle the reconciled status
- `<S-Tab>` and `<Tab>` to go to the previous / next field (transaction comment,
  account, amount)
- `B`, `W` goes to the previous / next field
- `E` goes to the end of the current field

### Insert Ledger Mode ###

TODO:

- `<Tab>` autocompletes account
- `<CR>` goes to the next field
    - in a transaction comment, creates a line to type an account
    - if you are in an account line, but the line is empty, creates the next
      transaction
    - if you have typed an account name, goes to type the amount
    - if you typed the amount, goes to type the next account

Lightline integration
---------------------

To display the ledger mode, you can use the `g:ledger_mode` variable that
contains either an empty string or `LEDGER`. You can integrate it with lightline
by adding this function to your vimrc:

    function! Lightline_mode() abort
      let res = lightline#mode()
      if exists('g:ledger_mode') && len(g:ledger_mode)
        let res .= ' ' . g:ledger_mode
      end
      return res
    endfunction

You also have to use this function for the mode widget in lightline:

    let g:lightline = {
      ...
    \ 'component': {
    \   'mode': '%{Lightline_mode()}',
      	...
    \ },
    \ }
