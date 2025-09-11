vim.keymap.set(
  'i',
  '<C-j>',
  function()
    if vim.fn['coc#pum#visible']() ~= 0 then
      return vim.fn['coc#pum#next'](1)
    else
      return vim.fn['coc#refresh']()
    end
  end,
  { expr = true, noremap = true, silent = true }
)
vim.keymap.set(
  'i',
  '<C-k>',
  function()
    if vim.fn['coc#pum#visible']() ~= 0 then
      return vim.fn['coc#pum#prev'](1)
    else
      return '<C-k>'
    end
  end,
  { expr = true, noremap = true, silent = true }
)

vim.keymap.set(
  'i',
  '<tab>',
  function()
    if vim.fn['coc#pum#visible']() ~= 0 then
      return vim.fn['coc#pum#confirm']()
    end

    local ok, suggestion = pcall(require, 'copilot.suggestion')
    if ok and suggestion.is_visible() then
      suggestion.accept()
      return ''
    end

    return '<tab>'
  end,
  { expr = true, noremap = true, silent = true }
)

vim.keymap.set(
  'i',
  '<esc>',
  function()
    if vim.fn['coc#pum#visible']() ~= 0 then
      if vim.fn['coc#pum#info']().inserted then
        return vim.fn['coc#pum#cancel']()
      end
    end
    return '<esc>'
  end,
  { expr = true, noremap = true, silent = true }
)

vim.keymap.set('n', '[g', '<Plug>(coc-diagnostic-prev)', { silent = true })
vim.keymap.set('n', ']g', '<Plug>(coc-diagnostic-next)', { silent = true })

vim.keymap.set('n', 'gd', '<Plug>(coc-definition)', { silent = true })

vim.keymap.set('n', '<leader>fx', '<Plug>(coc-fix-current)')

vim.keymap.set('n', '<leader>ff', '<Plug>(coc-format)')
vim.keymap.set('x', '<leader>ff', '<Plug>(coc-format-selected)')

vim.keymap.set('n', '<leader>ac', '<Plug>(coc-codeaction-cursor)')
vim.keymap.set('x', '<leader>ac', '<Plug>(coc-codeaction-selected)')

vim.keymap.set('n', '<leader>rn', '<Plug>(coc-rename)')

vim.cmd([[
  augroup cocsettings
    autocmd!
    autocmd CursorHold * silent call CocActionAsync('highlight')
    autocmd FileType javascript,typescript,typescriptreact,rust,json
          \ setl formatexpr=CocAction('formatSelected')
  augroup end
]])
