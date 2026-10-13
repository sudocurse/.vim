-- blink.cmp: LSP + path + buffer-word + snippet completion. Lives in after/plugin so
-- the plugin is on the runtimepath by the time this runs.
local ok, blink = pcall(require, 'blink.cmp')
if not ok then return end

blink.setup({
  -- 'enter' preset: <CR> accepts, <C-n>/<C-p> move, <C-e> dismiss, <C-space> show docs.
  -- Tab/S-Tab added to match the old ncm2 habit.
  keymap = {
    preset = 'enter',
    ['<Tab>']   = { 'select_next', 'snippet_forward',  'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    -- by default buffer words only appear when the LSP returns nothing; show both
    providers = { lsp = { fallbacks = {} } },
  },
  completion = {
    list = { selection = { preselect = false, auto_insert = true } },
    documentation = { auto_show = true, auto_show_delay_ms = 300 },
  },
  signature = { enabled = true },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
})

-- advertise completion capabilities to every LSP server
vim.lsp.config('*', { capabilities = blink.get_lsp_capabilities() })
