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

" Jump to the start of the current function
function! JumpToCurrentFunctionStart()
  if &filetype ==# 'python'
    call s:JumpToCurrentFunctionStartPython()
  else
    call s:JumpToCurrentFunctionStartBrace()
  endif
endfunction

" Python: find enclosing def/class by indentation
function! s:JumpToCurrentFunctionStartPython()
  let save_pos = getpos('.')
  let cur_lnum = line('.')

  " Get indentation of current line; if blank, use next non-blank line's indent
  let cur_indent = indent(cur_lnum)
  if getline(cur_lnum) =~# '^\s*$'
    let nb = nextnonblank(cur_lnum)
    if nb > 0
      let cur_indent = indent(nb)
    endif
  endif

  " If cursor is on a def/class line, look for the enclosing scope above it
  if getline(cur_lnum) =~# '^\s*\(def\|class\)\>'
    let cur_indent = indent(cur_lnum)
  endif

  let lnum = cur_lnum - 1
  while lnum >= 1
    let line = getline(lnum)
    " Skip blank lines and comments
    if line =~# '^\s*$' || line =~# '^\s*#'
      let lnum -= 1
      continue
    endif
    " Look for def/class with strictly less indentation
    if indent(lnum) < cur_indent && line =~# '^\s*\(def\|class\)\>'
      call cursor(lnum, 1)
      normal! ^
      return
    endif
    let lnum -= 1
  endwhile

  call setpos('.', save_pos)
  echo "Not inside a function"
endfunction

" C/C++/Java and similar brace-based languages
function! s:JumpToCurrentFunctionStartBrace()
  let save_pos = getpos('.')
  let flags = 'bcW'

  for _ in range(20)
    if searchpair('{', '', '}', flags) == 0
      call setpos('.', save_pos)
      echo "Not inside a function"
      return
    endif
    let flags = 'bW'

    let brace_lnum = line('.')

    " Gather context before { to distinguish functions from control structures
    let context = ''
    let lnum = max([1, brace_lnum - 10])
    while lnum <= brace_lnum
      let context .= getline(lnum) . ' '
      let lnum += 1
    endwhile
    let context = substitute(context, '{.*$', '', '')
    let context = substitute(context, '\s\+', ' ', 'g')
    let context = substitute(context, '^\s*\|\s*$', '', 'g')

    " Skip control-flow structures — keep searching outward
    if context =~# '\<\(else\|do\|try\)\s*$'
        \ || context =~# '\<\(if\|for\|while\|switch\|catch\)\s*(.*)\s*$'
      continue
    endif

    " Found a function brace — walk up to find the declaration start
    let func_start = brace_lnum
    if getline(brace_lnum) =~# '^\s*{\s*$'
      let func_start = brace_lnum - 1
    endif
    while func_start > 1
      let prev = getline(func_start - 1)
      if prev =~# '^\s*$' || prev =~# '[;{}]\s*$' || prev =~# '^\s*#'
          \ || prev =~# '^\s*//' || prev =~# '^\s*/\*' || prev =~# '\*/\s*$'
        break
      endif
      let func_start -= 1
    endwhile

    call cursor(func_start, 1)
    normal! ^
    return
  endfor

  call setpos('.', save_pos)
  echo "Not inside a function"
endfunction

nnoremap <silent> [F :call JumpToCurrentFunctionStart()<CR>

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
nnoremap * :let @/ = '\<'.expand('<cword>').'\>'<CR>:set hlsearch<CR>:echo 'Match ' . searchcount().current . ' of ' . searchcount().total<CR>

" Remap * in visual mode to search for the selected text without jumping
xnoremap * y:let @/ = '\V'.escape(@", '/\')<CR>:set hlsearch<CR>:echo 'Match ' . searchcount().current . ' of ' . searchcount().total<CR>

" Remap n to show the current match count and total count after moving to the next match
nnoremap n n:echo 'Match ' . searchcount().current . ' of ' . searchcount().total<CR>

" Remap N to show the current match count and total count after moving to the previous match
nnoremap N N:echo 'Match ' . searchcount().current . ' of ' . searchcount().total<CR>
" Toggle line numbers and relative line numbers
function! ToggleNumbers()
  if &number || &relativenumber
    set nonumber norelativenumber
  else
    set number relativenumber
  endif
endfunction

command! ToggleNumbers call ToggleNumbers()
nnoremap <leader>lt :ToggleNumbers<CR>


"mll theme
set background=light " or light if you want light mode
colorscheme gruvbox

" matchpairs <> only valid for cpp and cu
augroup cpp_brackets
  autocmd!
  autocmd FileType cpp,cu setlocal matchpairs+=<:>
augroup END


" OSC 52: yank to local clipboard over SSH
function! Osc52Yank() abort
    let encoded = system('base64 -w0', @0)
    let encoded = substitute(encoded, '\n$', '', '')
    call writefile(["\x1b]52;c;" . encoded . "\x07"], '/dev/tty', 'b')
endfunction

augroup osc52_yank
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | call Osc52Yank() | endif
augroup END
