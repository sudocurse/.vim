-- LSP setup using the native API (nvim 0.11+). Server definitions (cmd, filetypes,
-- root markers) come from nvim-lspconfig's lsp/*.lua; we only override what differs.

local python = vim.g.python3_host_prog or 'python3'

if os.getenv('TOUCH') then
  -- TouchDesigner: run pyright (from PATH) and point it at TD's bundled interpreter.
  vim.lsp.config('pyright', {
    settings = {
      python = {
        pythonPath = '/Applications/TouchDesigner.app/Contents/Frameworks/Python.framework/Versions/3.11/bin/python3.11',
      },
    },
  })
  vim.lsp.enable('pyright')
else
  vim.lsp.config('pylsp', {
    cmd = { python, '-m', 'pylsp' },
    settings = { pylsp = { plugins = { pycodestyle = { maxLineLength = 88 } } } },
  })
  vim.lsp.enable('pylsp')
end

-- Diagnostics (global). [d ]d [D ]D and <C-w>d are nvim defaults.
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { desc = 'line diagnostics' })
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, { desc = 'diagnostics to loclist' })

-- Buffer mappings on attach. nvim already provides: K hover, grn rename, gra code
-- action, grr references, gri implementation, grt type definition, gO symbols,
-- <C-s> signature help (insert), <C-]> definition via tagfunc.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user_lsp', { clear = true }),
  callback = function(ev)
    local function m(lhs, rhs, desc)
      vim.keymap.set('n', lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
    end
    m('gd',        vim.lsp.buf.definition,      'LSP definition')
    m('gD',        vim.lsp.buf.declaration,     'LSP declaration')
    m('<space>D',  vim.lsp.buf.type_definition, 'LSP type definition')
    m('<space>rn', vim.lsp.buf.rename,          'LSP rename')
    m('<space>ca', vim.lsp.buf.code_action,     'LSP code action')
    m('<space>f',  function() vim.lsp.buf.format({ async = true }) end, 'LSP format')
  end,
})
