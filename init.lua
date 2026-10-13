-- ~/.vim/init.lua : the whole Neovim config. Sourced from ~/.config/nvim/init.vim.
-- Plugins: minpac.  :PluginUpdate installs/updates, :PluginClean removes unlisted ones.
--
-- On home-manager hosts config-flake sets vim.g.nix_managed before sourcing this
-- file. Nix then owns the binary, plugins (programs.neovim.plugins), the python
-- host (pylsp lives inside it) and CLI tools, so the minpac and venv blocks below
-- are skipped. Keep the plugin list here and the one in
-- home-manager/_mixins/users/ankeet/neovim.nix in sync by hand.
local nix_managed = vim.g.nix_managed == true
local is_mac = vim.fn.has('mac') == 1

-- Options -------------------------------------------------------------------
vim.g.mapleader = ','
-- Python host: the nix wrapper sets python3_host_prog itself; elsewhere use the
-- venv at ~/.vim/vimpy (python -m venv vimpy && vimpy/bin/pip install -r requirements.txt)
local vimpy = vim.fn.expand('~/.vim/vimpy/bin/python')
if not nix_managed and vim.fn.executable(vimpy) == 1 then
  vim.g.python3_host_prog = vimpy
end

local o = vim.o
o.number, o.relativenumber, o.showcmd = true, true, true
o.shiftwidth, o.tabstop, o.expandtab = 4, 4, true
o.ignorecase, o.smartcase = true, true   -- the old config set smartcase alone, which is a no-op
o.clipboard = 'unnamedplus'
o.maxmempattern = 8000
o.textwidth = 400
o.undofile = true
o.undodir = vim.fn.expand('~/.vim/undodir') .. '/'
o.directory = vim.fn.expand('~/.vim/swap') .. '/,/tmp/vim/swap/'
vim.fn.mkdir(vim.fn.expand('~/.vim/undodir'), 'p')   -- both are gitignored, so a
vim.fn.mkdir(vim.fn.expand('~/.vim/swap'), 'p')      -- fresh clone lacks them
o.foldmethod = 'indent'
vim.opt.foldopen:append('jump')
o.winborder = 'rounded'                  -- LSP hover / signature floats
o.completeopt = 'menuone,noselect'
vim.g.xml_syntax_folding = 1
vim.cmd.colorscheme('habamax')

-- Plugins (minpac) ------------------------------------------------------------
-- Skipped under nix: programs.neovim.plugins puts the same set on the packpath.
if not nix_managed then
local minpac_dir = vim.fn.expand('~/.vim/pack/minpac/opt/minpac')
if vim.fn.isdirectory(minpac_dir) == 0 then
  vim.fn.system({ 'git', 'clone', '--depth=1', 'https://github.com/k-takata/minpac.git', minpac_dir })
end
vim.cmd('packadd minpac')
vim.fn['minpac#init']()
local function add(repo, opts) vim.fn['minpac#add'](repo, opts or vim.empty_dict()) end

add('k-takata/minpac', { type = 'opt' })
-- editing
add('tpope/vim-sensible')
add('tpope/vim-commentary')        -- gcc, gc{motion}
add('tpope/vim-surround')          -- cs"' ds" ysiw"
add('tpope/vim-repeat')            -- . repeats plugin edits
add('tpope/vim-unimpaired')        -- [e ]e, yo{x}, [<Space> ...
add('mbbill/undotree')
-- git
add('tpope/vim-fugitive')
add('airblade/vim-gitgutter')
-- ui
add('vim-airline/vim-airline')
add('vim-airline/vim-airline-themes')
add('nathanaelkane/vim-indent-guides')
add('preservim/tagbar')
-- files
add('francoiscabrol/ranger.vim')
add('rbgrouleff/bclose.vim')       -- needed by ranger.vim; gives ,bd
add('junegunn/fzf')
add('junegunn/fzf.vim')
-- languages / completion
add('sheerun/vim-polyglot')
add('neovim/nvim-lspconfig')       -- only for its lsp/*.lua server definitions
add('saghen/blink.cmp', { rev = 'v1.10.2' })  -- pinned tag so it fetches a prebuilt matcher
add('prettier/vim-prettier')
add('vim-scripts/dbext.vim')
-- on demand (packadd below)
add('tpope/vim-fireplace', { type = 'opt' })
add('tidalcycles/vim-tidal', { type = 'opt' })
add('tpope/vim-scriptease', { type = 'opt' })

vim.api.nvim_create_user_command('PluginUpdate', function() vim.fn['minpac#update']() end, {})
vim.api.nvim_create_user_command('PluginClean', function() vim.fn['minpac#clean']() end, {})
end -- not nix_managed

-- Rarely used language stacks load only when their files show up. This is the
-- replacement for the old g:enable_* switches.
local lazy = vim.api.nvim_create_augroup('user_lazy_packs', { clear = true })
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = lazy, pattern = { '*.clj', '*.cljs', '*.cljc', '*.edn' }, once = true,
  command = 'packadd vim-fireplace',
})
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  group = lazy, pattern = '*.tidal', once = true,
  command = 'packadd vim-tidal',
})

-- Plugin settings -------------------------------------------------------------
vim.g.airline_theme = 'behelit'
vim.g['airline#extensions#tabline#enabled'] = 1
vim.g.airline_powerline_fonts = 0

vim.g.indent_guides_start_level = 1
vim.g.indent_guides_auto_colors = 1
vim.g.indent_guides_guide_size = 1
vim.g.indent_guides_enable_on_vim_startup = 1

vim.g.ranger_replace_netrw = 1
vim.g.ranger_map_keys = 0            -- we map it ourselves below

if is_mac then
  vim.g.dbext_default_profile_Notes =
    'type=SQLITE:SQLITE_bin=/usr/local/bin/sqlite3:dbname=/Users/ankeet.presswala/Library/Group\\ Containers/group.com.apple.notes/NoteStore.sqlite'
end

-- LSP (lua/lsp_config.lua); completion is in after/plugin/completion.lua
require('lsp_config')

-- Mappings --------------------------------------------------------------------
local map = vim.keymap.set
map({ 'n', 'v', 'o' }, ';', ':')
map('n', '<C-j>', 'ddp',   { desc = 'move line down' })
map('n', '<C-k>', 'ddkkp', { desc = 'move line up' })

map('n', '<C-p>', '<Cmd>Files<CR>',   { desc = 'fzf files' })
map('n', ',b',    '<Cmd>Buffers<CR>', { desc = 'fzf buffers' })
map('n', ',/',    '<Cmd>Rg<CR>',      { desc = 'fzf ripgrep' })
map('n', ',f',    '<Cmd>Ranger<CR>',  { desc = 'ranger at current file' })
map('n', '-',     '<Cmd>RangerCurrentDirectory<CR>', { desc = 'ranger in buffer dir' })

map('n', ',u',  '<Cmd>UndotreeToggle<CR>')
map('n', ',t',  '<Cmd>TagbarToggle<CR>')
map('n', ',ig', '<Plug>IndentGuidesToggle')

map('n', ',gs', '<Cmd>Git<CR>')
map('n', ',gd', '<Cmd>Gdiffsplit<CR>')
map('n', ',gc', '<Cmd>Git commit<CR>')
map('n', ',gp', '<Cmd>Git push<CR>')

-- :P {ex command}  ->  output in a new window
vim.api.nvim_create_user_command('P', function(a)
  vim.cmd('redir @a | silent ' .. a.args .. ' | redir END | new | put a')
end, { nargs = 1, complete = 'command' })

-- Filetype bits ---------------------------------------------------------------
vim.api.nvim_create_autocmd('FileType', { pattern = 'xml', command = 'setlocal foldmethod=syntax' })
vim.api.nvim_create_autocmd('FileType', { pattern = 'tidal', command = 'setlocal commentstring=--\\ %s' })

-- hacks/*.vim (iTerm split command lives there; mac only)
if is_mac then
  for _, f in ipairs(vim.fn.glob('~/.vim/hacks/*.vim', true, true)) do vim.cmd.source(f) end
end
