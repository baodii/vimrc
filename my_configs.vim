" highlight IncSearch
hi IncSearch term=reverse ctermfg=16 ctermbg=46 guifg=#000000 guibg=#00f000

" map git blame
nnoremap <leader>s :<C-u>call gitblame#echo()<CR>

" set tab to 2 spaces
set tabstop=2
set shiftwidth=2
set expandtab

" cscope config
source ~/.vim_runtime/my_plugins/cscope_maps.vim

" get file absolute path
command! Fpath echo expand('%:p')
nnoremap <leader>fp :echo expand('%:p')<CR>

" jump to the previous function
nnoremap <silent> [f :call
\ search('\(\(if\\|for\\|while\\|switch\\|catch\)\_s*\)\@64<!(\_[^)]*)\_[^;{}()]*\zs{', "bw")<CR>
" jump to the next function
nnoremap <silent> ]f :call
\ search('\(\(if\\|for\\|while\\|switch\\|catch\)\_s*\)\@64<!(\_[^)]*)\_[^;{}()]*\zs{', "w")<CR>


" set nu and rnu auto toggling
set nu
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" set cursorline
set cursorline
highlight CursorLine cterm=NONE gui=NONE ctermbg=238 guibg=#1E90FF

" set F8 to TagbarToggle
nmap <F8> :TagbarToggle<CR>

" * command not go to next match
" nnoremap * :keepjumps normal! mi*`i<CR>
"

" Remap * in normal mode to search for the word under the cursor without jumping
nnoremap * :let @/ = '\<'.expand('<cword>').'\>'<CR>:echo 'Match ' . searchcount().current . ' of ' . searchcount().total<CR>

" Remap * in visual mode to search for the selected text without jumping
xnoremap * y:let @/ = '\V'.escape(@", '/\')<CR>:echo 'Match ' . searchcount().current . ' of ' . searchcount().total<CR>

" Remap n to show the current match count and total count after moving to the next match
nnoremap n n:echo 'Match ' . searchcount().current . ' of ' . searchcount().total<CR>

" Remap N to show the current match count and total count after moving to the previous match
nnoremap N N:echo 'Match ' . searchcount().current . ' of ' . searchcount().total<CR>