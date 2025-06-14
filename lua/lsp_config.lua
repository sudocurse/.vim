-- =============================================================================
-- LSP Configuration (Neovim)
-- =============================================================================

-- Only proceed if LSP is enabled and we have lspconfig
if vim.g.enable_lsp == 0 then
  return
end

local has_lspconfig, lspconfig = pcall(require, 'lspconfig')
if not has_lspconfig then
  return
end

-- LSP key mappings
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Buffer-local mappings
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

-- Enhanced hover and signature help
local max_width = math.max(math.floor(vim.o.columns * 0.7), 100)
local max_height = math.max(math.floor(vim.o.lines * 0.3), 30)

local handlers = {}
handlers['textDocument/hover'] = vim.lsp.with(
  vim.lsp.handlers.hover,
  { border = 'rounded', max_width = max_width, max_height = max_height }
)

handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  { border = 'rounded', max_width = max_width, max_height = max_height }
)

-- Python LSP Configuration (if Python development is enabled)
if vim.g.enable_python_dev ~= 0 then
  local python3_host_prog = vim.g.python3_host_prog or 'python3'
  
  lspconfig.pylsp.setup({
    on_attach = on_attach,
    handlers = handlers,
    cmd = { python3_host_prog, '-m', 'pylsp' },
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = {
            maxLineLength = 88
          }
        }
      }
    }
  })
end

-- Add other language servers here based on enabled features
-- Example: TypeScript/JavaScript
if vim.g.enable_web_dev ~= 0 then
  -- lspconfig.tsserver.setup({
  --   on_attach = on_attach,
  --   handlers = handlers,
  -- })
end