vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      check = {
        command = 'clippy',
      },
      inlayHints = {
        typeHints = {
          enable = false,
        },
        chainingHints = {
          enable = false,
        },
        parameterHints = {
          enable = false,
        },
      },
    },
  },
})

vim.lsp.enable('rust_analyzer')
vim.lsp.enable('nixd')
vim.lsp.enable('pyright')
vim.lsp.enable('tailwindcss')
vim.lsp.enable('ts_ls')

vim.lsp.inlay_hint.enable()
vim.cmd('set completeopt+=menuone,noselect,popup')

vim.keymap.del('n', ']d')
vim.keymap.del('n', '[d')
vim.keymap.del('n', ']D')
vim.keymap.del('n', '[D')

vim.keymap.set(
  'i',
  '<C-j>',
  function()
    if vim.fn['pumvisible']() ~= 0 then
      return '<C-n>'
    else
      return '<C-x><C-o>'
    end
  end,
  { expr = true, noremap = true, silent = true }
)

vim.keymap.set(
  'i',
  '<C-k>',
  function()
    if vim.fn['pumvisible']() ~= 0 then
      return '<C-p>'
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
    if vim.fn['pumvisible']() ~= 0 then
      return '<C-y>'
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
    if vim.fn['pumvisible']() ~= 0 then
      return '<C-e>'
    end
    return '<esc>'
  end,
  { expr = true, noremap = true, silent = true }
)

vim.keymap.set(
  'n',
  ']g',
  function() vim.diagnostic.jump({ count = 1 }) end,
  { noremap = true, silent = true }
)

vim.keymap.set(
  'n',
  '[g',
  function() vim.diagnostic.jump({ count = -1 }) end,
  { noremap = true, silent = true }
)

vim.keymap.set('n', 'gd', '<C-]>', { noremap = true })

vim.keymap.set(
  'n',
  '<leader>ac',
  function() vim.lsp.buf.code_action() end
)

vim.keymap.set(
  'x',
  '<leader>ac',
  function() vim.lsp.buf.code_action() end
)

vim.keymap.set(
  'n',
  '<leader>ff',
  function() vim.lsp.buf.format() end
)

vim.keymap.set(
  'x',
  '<leader>ff',
  function() vim.lsp.buf.format() end
)

vim.keymap.set(
  'n',
  '<leader>rn',
  function() vim.lsp.buf.rename() end
)

vim.keymap.set(
  'i',
  '<C-s>',
  function() vim.lsp.buf.signature_help({ border = 'rounded' }) end,
  { noremap = true }
)

local augroup = vim.api.nvim_create_augroup('tirr.lsp', {})

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(args)
    local client_id = args.data.client_id
    local client = assert(vim.lsp.get_client_by_id(client_id))
    local bufnr = args.buf

    if vim.b[bufnr].tirrLsp == nil then
      vim.b[bufnr].tirrLsp = {
        numHighlightable = 0,
      }
    end

    local tirrLsp = vim.b[bufnr].tirrLsp

    vim.keymap.set(
      'n',
      'K',
      function() vim.lsp.buf.hover({ border = 'rounded' }) end,
      { buffer = bufnr, noremap = true }
    )

    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client_id, bufnr, { autotrigger = true })
    end

    if client:supports_method('textDocument/documentHighlight') then
      if tirrLsp.numHighlightable == 0 then
        local holdId = vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = bufnr,
          callback = function() vim.lsp.buf.document_highlight() end,
        })

        local moveId = vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = bufnr,
          callback = function() vim.lsp.buf.clear_references() end,
        })

        tirrLsp.autocmds = { holdId, moveId }
      end

      tirrLsp.numHighlightable = tirrLsp.numHighlightable + 1
    end
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  group = augroup,
  callback = function(args)
    local client_id = args.data.client_id
    local client = assert(vim.lsp.get_client_by_id(client_id))
    local bufnr = args.buf
    local tirrLsp = vim.b[bufnr].tirrLsp

    if client:supports_method('textDocument/documentHighlight') then
      tirrLsp.numHighlightable = tirrLsp.numHighlightable - 1

      if tirrLsp.numHighlightable == 0 then
        for _, id in ipairs(tirrLsp.autocmds) do
          vim.api.nvim_del_autocmd(id)
        end
        tirrLsp.autocmds = nil
      end
    end
  end
})

vim.api.nvim_set_hl(0, 'LspCodeLens', { fg = '#d0d0d0', ctermfg = 252 })
vim.api.nvim_set_hl(0, 'LspInlayHint', { fg = '#add4fb', ctermfg = 153, italic = true })
vim.api.nvim_set_hl(0, 'LspReferenceText', { bg = '#585858', ctermbg = 240 })

vim.api.nvim_set_hl(0, 'rustEnumVariant', { fg = '#5fc1c1', ctermfg = 80 })
vim.api.nvim_set_hl(0, '@lsp.type.enumMember.rust', { link = 'rustEnumVariant' })
vim.api.nvim_set_hl(0, '@lsp.type.interface.rust', { fg = '#a1a1f4', ctermfg = 147 })
vim.api.nvim_set_hl(0, '@lsp.type.keyword.rust', { link = '@lsp' })
vim.api.nvim_set_hl(0, '@lsp.type.property.rust', { link = '@lsp' })
vim.api.nvim_set_hl(0, '@lsp.type.namespace.rust', { link = 'Include' })
vim.api.nvim_set_hl(0, '@lsp.type.builtinType.rust', { link = 'Type' })
vim.api.nvim_set_hl(0, '@lsp.type.typeAlias.rust', { link = 'Type' })
vim.api.nvim_set_hl(0, '@lsp.mod.crateRoot.rust', { bold = true })
vim.api.nvim_set_hl(0, '@lsp.mod.unsafe.rust', { sp = '#d78787', underline = true })
vim.api.nvim_set_hl(0, '@lsp.typemod.comment.documentation.rust', { link = 'Special' })
vim.api.nvim_set_hl(0, '@lsp.typemod.keyword.crateRoot.rust', { link = '@lsp.type.namespace.rust' })
vim.api.nvim_set_hl(0, '@lsp.typemod.keyword.unsafe.rust', { nocombine = true })
vim.api.nvim_set_hl(0, '@lsp.typemod.variable.mutable.rust', { sp = 'fg', underline = true })
