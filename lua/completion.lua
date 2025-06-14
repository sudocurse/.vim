-- LSP Configuration with comprehensive error handling
if vim.g.enable_lsp == 0 then
  return
end

local has_lspconfig, lspconfig = pcall(require, 'lspconfig')
if not has_lspconfig then
  return
end

-- Use the configured Python path
local python3_host_prog = vim.g.python3_host_prog or vim.fn.expand('~/.vim/vimpy/bin/python')

-- Verify Python and pylsp availability
if not vim.fn.executable(python3_host_prog) then
  return
end

local pylsp_check = vim.fn.system(python3_host_prog .. ' -c "import pylsp" 2>/dev/null; echo $?')
if pylsp_check:match("0") == nil then
  return
end

-- LSP key mappings
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

local on_attach = function(client, bufnr)
  -- Set omnifunc
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Buffer-local mappings with explicit nil checks
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  
  -- Only map functions that exist
  if vim.lsp.buf.declaration then
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  end
  
  if vim.lsp.buf.definition then
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  end
  
  if vim.lsp.buf.hover then
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  end
  
  if vim.lsp.buf.implementation then
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  end
  
  if vim.lsp.buf.signature_help then
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  end
  
  if vim.lsp.buf.add_workspace_folder then
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  end
  
  if vim.lsp.buf.remove_workspace_folder then
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  end
  
  if vim.lsp.buf.list_workspace_folders then
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
  end
  
  if vim.lsp.buf.type_definition then
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  end
  
  if vim.lsp.buf.rename then
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  end
  
  if vim.lsp.buf.code_action then
    vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  end
  
  if vim.lsp.buf.references then
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  end
  
  -- Format function (handle different Neovim versions)
  if vim.lsp.buf.format then
    vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
  elseif vim.lsp.buf.formatting then
    vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
  end
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

-- Python LSP setup
pcall(function()
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
end)