" Use <C-j>, <C-k> to navigate completion menu.
" <C-j> opens completion menu
inoremap <silent><expr><C-j>
      \ coc#pum#visible() ? coc#pum#next(1) : coc#refresh()
inoremap <silent><expr><C-k>
      \ coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"
inoremap <silent><expr><C-l>
      \ coc#pum#visible() ? coc#pum#scroll(1) : "\<C-l>"
inoremap <silent><expr><C-h>
      \ coc#pum#visible() ? coc#pum#scroll(0) : "\<C-h>"

let g:copilot_no_tab_map = v:true
inoremap <silent><expr><tab> coc#pum#visible() ? coc#pum#confirm() : "\<Tab>"
function! s:initTab()
  if exists("*copilot#Accept")
    inoremap <silent><expr><tab>
          \ coc#pum#visible() && coc#pum#info()['inserted'] ? coc#pum#confirm() :
          \ coc#pum#visible() && copilot#GetDisplayedSuggestion()['text'] ==# '' ? coc#pum#confirm() :
          \ copilot#Accept("\<Tab>")
  endif
endfunction

inoremap <silent><expr><Esc>
      \ coc#pum#visible() && coc#pum#info()['inserted'] ? coc#pum#cancel() : "\<Esc>"

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)

nmap <leader>fx <Plug>(coc-fix-current)

nmap <leader>ff <Plug>(coc-format)
xmap <leader>ff <Plug>(coc-format-selected)

augroup cocsettings
  autocmd!
  if v:vim_did_enter
    call s:initTab()
  else
    autocmd VimEnter * call s:initTab()
  endif
  autocmd CursorHold * silent call CocActionAsync('highlight')
  autocmd FileType javascript,typescript,typescriptreact,rust,json
        \ setl formatexpr=CocAction('formatSelected')
augroup end

nmap <leader>ac <Plug>(coc-codeaction-cursor)
xmap <leader>ac <Plug>(coc-codeaction-selected)

nmap <leader>rn <Plug>(coc-rename)
