# Vim config cheat sheet

Neovim 0.12, plugins via minpac. Last rewritten 2026-10-13 (see section 5 for what changed).

## 1. How it loads

```
vim (alias) -> nvim
  ~/.config/nvim/init.vim        3 lines: put ~/.vim on runtimepath, source ~/.vim/init.lua
  ~/.vim/init.lua                options, minpac plugin list, plugin settings, mappings
    lua/lsp_config.lua           Python LSP (pylsp, or pyright when $TOUCH is set)
    after/plugin/completion.lua  blink.cmp setup (runs after plugins are on the path)
    after/ftplugin/python.lua    textwidth 88, ,r runs the file
    plugin/gnupg.vim             transparent *.gpg editing
    hacks/cwd_split_iterm.vim    :UseriTermSplitCwd (python in hacks/itermcontrol.py)
  ~/.vim/vimpy/                  venv (untracked); requirements.txt rebuilds it
```

`.vimrc` is still here for `/usr/bin/vim` and `ginit.vim`, but nvim does not read it.

Maintenance:

```
:PluginUpdate          install new / update all     (minpac#update)
:PluginClean           delete plugins no longer listed in init.lua
python3 -m venv ~/.vim/vimpy && ~/.vim/vimpy/bin/pip install -r ~/.vim/requirements.txt
```

Rarely used stacks are `opt` plugins loaded on demand instead of global switches:
vim-fireplace loads on the first `.clj/.cljs/.cljc/.edn` buffer, vim-tidal on `.tidal`,
vim-scriptease with `:packadd vim-scriptease`.

## 2. Plugins

| Plugin | What you get | Keys / commands |
|---|---|---|
| vim-sensible | sane defaults | `<C-L>` clear search highlight |
| vim-commentary | toggle comments | `gcc`, `gc{motion}`, `gc` (visual), `gcu` |
| vim-surround | change/delete/add surroundings | `cs"'`, `ds"`, `ysiw"`, `yss)`, `S"` in visual |
| vim-repeat | `.` repeats surround/commentary/unimpaired edits | `.` |
| vim-unimpaired | bracket pairs | `[e ]e` move line, `[<Space> ]<Space>` blank line, `yon` number, `yow` wrap, `yos` spell, `yoh` hlsearch, `[u ]u` url en/decode, `[x ]x` xml, `[p ]p` put with indent |
| undotree | visual undo history (persistent) | `,u` |
| vim-fugitive | git | `,gs` status (`-` stage, `cc` commit, `dv` diff, `=` inline diff), `,gd` diffsplit, `,gc` commit, `,gp` push, `:Git blame`, `:Git log --oneline`, `:GBrowse` |
| vim-gitgutter | diff signs | `]c [c` hunks, `,hp` preview, `,hs` stage, `,hu` undo, `ic`/`ac` hunk text objects, `:GitGutterFold`, `:GitGutterQuickFix` |
| vim-airline + themes | status line, buffer tabline, theme `behelit` | `:AirlineTheme <Tab>` |
| vim-indent-guides | indent columns (on at start) | `,ig` |
| tagbar | symbol outline (ctags) | `,t` |
| ranger.vim + bclose | file picker, replaces netrw | `,f` ranger at file, `-` ranger in buffer dir, `,bd` close buffer keep window |
| fzf + fzf.vim | fuzzy everything (fzf, rg on PATH) | `<C-p>` files, `,b` buffers, `,/` ripgrep, `:Lines`, `:BLines`, `:Marks`, `:Commits`, `:Helptags`, `:History`, `:Files %:h` |
| vim-polyglot | syntax/indent for ~600 filetypes, `:Sleuth` indent detection | automatic |
| nvim-lspconfig | server definitions only (`lsp/*.lua`); setup is native | see LSP |
| blink.cmp | completion popup: LSP + paths + buffer words + snippets | see Completion |
| vim-prettier | `:Prettier` when the project has prettier in node_modules | `,p` |
| dbext.vim | SQL client; profile `Notes` = Apple Notes sqlite | `,sbp` pick profile, `,se` run SQL under cursor, `,st` select from table, `,sdt` describe table, `,sh` history |
| gnupg.vim | edit `*.gpg`/`*.asc` transparently | `:GPGEditRecipients` |
| minpac (opt) | plugin manager | `:PluginUpdate`, `:PluginClean` |
| vim-fireplace, vim-tidal, vim-scriptease (opt) | Clojure REPL, Tidal, vimscript debugging | load on demand |

## 3. Keys and commands you own

| Key | Does |
|---|---|
| `,` | leader |
| `;` | `:` |
| `<C-j>` / `<C-k>` | move line down / up (`]e`/`[e` do the same) |
| `<C-p>` `,b` `,/` | fzf files / buffers / ripgrep |
| `,f` `-` | ranger at current file / in buffer directory |
| `,u` `,t` `,ig` | undotree / tagbar / indent guides |
| `,gs ,gd ,gc ,gp` | fugitive status / diff / commit / push |
| `,r` (python) | save and run the file |
| `:P {ex cmd}` | run an ex command, output in a new window |
| `:UseriTermSplitCwd` | split iTerm2 pane in the buffer's cwd |
| folds | `foldmethod=indent`, xml by syntax; `zR` open all, `zM` close all, `zo`/`zc`, `zj`/`zk` next/prev fold |

### LSP (Python)

- Normal buffers: pylsp from `~/.vim/vimpy` (pyflakes, pycodestyle at 88 cols, mccabe, jedi formatting).
- `TOUCH=1 nvim`: pyright from PATH, analysing against TouchDesigner's bundled Python 3.11.

| Key | Does |
|---|---|
| `gd` `gD` `<space>D` | definition / declaration / type definition |
| `K` | hover (nvim default) |
| `grn` `gra` `grr` `gri` `grt` `gO` | rename / code action / references / implementation / type def / symbols (nvim defaults) |
| `<space>rn` `<space>ca` | rename / code action (old habit, same thing) |
| `<space>f` | format buffer via LSP; `gq{motion}` also formats through the LSP |
| `<C-s>` (insert) | signature help |
| `[d ]d` `[D ]D` `<C-w>d` | diagnostics next/prev/first/last/float |
| `<space>e` `<space>q` | line diagnostics float / all to location list |
| `:checkhealth vim.lsp`, `:LspRestart`, `:LspLog` | status |

### Completion (blink.cmp)

| Key | Does |
|---|---|
| typing | popup opens automatically with LSP, path, buffer-word and snippet items |
| `<Tab>` / `<S-Tab>` or `<C-n>` / `<C-p>` | next / previous item |
| `<CR>` | accept (inserts a newline if nothing selected) |
| `<C-e>` | dismiss |
| `<C-space>` | open menu / toggle docs |
| `<C-k>` (insert) | toggle signature help |
| `<C-x><C-f>` `<C-x><C-l>` `<C-n>` | native path / whole-line / buffer completion still work |

## 4. Things still worth a decision

- **Copilot** is not installed. `~/.config/github-copilot` auth exists and `ginit.vim` maps `<Tab>` to `copilot#Accept()`. Add `add('github/copilot.vim')` to init.lua if you want it; blink has a Copilot source too.
- **A Python formatter.** pylsp formats through jedi today; `~/.vim/vimpy/bin/pip install python-lsp-ruff` adds ruff format + lint, or `yapf` / `autopep8`. See 6 (vim-autoformat).
- **`.vimrc` and `ginit.vim`** still describe the old setup (ncm, Copilot, FZF). Your call per the shared-config plan.
- `ignorecase` is now on. The old config set `smartcase` alone, which does nothing without it. Remove `o.ignorecase` in init.lua if you preferred strictly case-sensitive search.

## 5. What changed on 2026-10-13

Removed: the `config/` feature-switch layer, `ncm-autocomplete.vim`, `lua/completion.lua`,
`.gitmodules` and the three submodule gitlinks, all `pack/*` dirs except `pack/minpac`
(dbext moved to minpac), `ftplugin/python.vim` (it ran `minpac#add` on every Python buffer),
the seven `test_*.vim` files, old `config.vimrc*`, `cleanup_plugins.sh`, `fix_python_setup.sh`,
the three planning docs, `roulette`, `tags`, `.idea/`, empty `autoload/` and `include/`,
the duplicate iTerm script, syntastic, ncm2 + nvim-yarp + sources, vim-autoformat,
vim-vinegar, Color-Scheme-Explorer, solarized, Zenburn pack copy (`colors/zenburn.vim` stays).
`vimpy/` is untracked from git (28 MB venv); `.gitignore` covers `vimpy/` and `.idea/`.

Added: vim-surround, vim-repeat and vim-fugitive (they were mapped or documented but never
installed), fzf + fzf.vim, blink.cmp, pyflakes/pycodestyle/mccabe in the venv (pylsp shipped
no linters, so it published zero diagnostics).

Fixed: the LSP on_attach crash (`vim.lsp.buf.formatting` no longer exists), pylsp configured
twice, deprecated `vim.lsp.with` / `goto_prev` / `nvim_buf_set_option`, the TouchDesigner
branch (it launched TouchDesigner's python *as* the pyright server), `,f` being silently taken
by ranger, `<C-p>` with no fzf, and two synchronous Python shell-outs at startup
(startup 135 ms -> 118 ms).

## 6. Dropped plugins: what covered them, and how to try the alternatives

All of these were either never loading or are now duplicated by Neovim 0.12 built-ins or by a plugin that stays. Each subsection: what it did, what covers it now (and what is honestly lost), and a 5-minute trial.

### syntastic

**Was:** on-save syntax/lint checking that ran external checkers and put results in the location list and sign column. It was never activated in this config, so nothing is lost in practice.

**Covered by:** `vim.diagnostic` (built-in) fed by `vim.lsp`. pyright attaches to Python buffers and publishes diagnostics with no extra setup. Default keys: `]d` / `[d` next/prev diagnostic, `]D` / `[D` last/first, `<C-w>d` float at cursor. Strict superset of syntastic for any language with an LSP server. Also built-in, syntastic-style: `:compiler <name>` + `:make %` runs a checker and fills quickfix (`:copen`). Neovim ships `compiler/pyright.vim`, `ruff.vim`, `mypy.vim`, `pylint.vim`, `eslint.vim`, `tsc.vim`, `shellcheck.vim`, `yamllint.vim`, `jsonlint.vim` and more (`:compiler <Tab>`).

**Caveat:** the pylsp venv at `~/.vim/vimpy` has no `pyflakes`/`pycodestyle` installed, so pylsp currently contributes zero diagnostics; pyright is the only source. Install them if you want style warnings too.

**Try it in 5 minutes**
```vim
" 1. LSP diagnostics (pyright) — open any .py and:
:lua vim.diagnostic.setloclist()      " all diagnostics -> location list
:lua vim.diagnostic.setqflist()       " -> quickfix
]d  [d  <C-w>d                        " jump / float
:lua vim.diagnostic.config({ virtual_lines = { current_line = true } })   " 0.11+ inline rendering
:lua vim.diagnostic.config({ virtual_lines = false, virtual_text = true })

" 2. Classic :make into quickfix (pyright is on PATH; no LSP needed):
:compiler pyright | make % | copen
:compiler tsc | make                  " in a TS project
```
```sh
# optional: give pylsp its own linters (pycodestyle/pyflakes are its defaults once present)
~/.vim/vimpy/bin/pip install pyflakes pycodestyle mccabe
```

### vimproc.vim

**Was:** a compiled async process library required by old Shougo plugins (unite, vimshell, neocomplete). The directory was empty and nothing depended on it.

**Covered by:** Neovim's own job APIs: `vim.system()`, `vim.fn.jobstart()`, `:terminal`, and `vim.uv`. Strict superset; nothing to replace.

**Try it in 5 minutes**
```vim
:lua print(vim.system({'git','status','--short'}, {text=true}):wait().stdout)
:lua vim.system({'sleep','2'}, {}, function(r) vim.schedule(function() vim.notify('done '..r.code) end) end)
:terminal rg --files | head        " :term is already async
```

### HeyPlug

**Was:** unknown; empty directory, never loaded. No upstream project by that name exists on GitHub (closest is `hey-network/hey.vim`, a dead "ask Hey a question about selected code" wrapper). Nothing to replace; delete and move on.

### vim-bookmarks

**Was:** per-line bookmarks with a text annotation, sign column markers, `:BookmarkShowAll` list, persisted to disk. Empty directory, never loaded.

**Covered by:** native marks. `ma`..`mz` buffer-local, `mA`..`mZ` global and persisted across sessions by `'shada'` (default `'100` keeps marks for 100 files). Jump with `` `a `` (exact position) or `'a` (line); `]'` / `['` walk to the next/previous lowercase-marked line (no plugin needed, though unimpaired-style). `:marks` lists, `:delmarks a-z` / `:delmarks!` clears. fzf.vim adds `:Marks` (fuzzy list of all marks, preview included). **Genuinely lost:** free-text annotations and sign-column indicators. If you want those back, `marks.nvim` is the modern replacement.

**Try it in 5 minutes**
```vim
ma          " set, then move away
'a  `a      " jump line / jump exact
mB          " global mark: survives :q and works from any file
:marks      " built-in list
:Marks      " fzf.vim fuzzy list with preview
]'  ['      " next / prev marked line in this buffer
:delmarks a-z
```
Optional plugin (annotations + signs):
```vim
call minpac#add('chentoast/marks.nvim')
```
```lua
require('marks').setup({ bookmark_0 = { sign = '!', annotate = true } })
-- mx set, dmx delete, m, next free mark, m] / m[ next/prev, m: preview,
-- m0 bookmark group 0 (prompts for annotation), :MarksListBuf / :BookmarksListAll
```

### ncm2 + nvim-yarp + ncm2-bufword + ncm2-path

**Was:** the as-you-type completion popup, Python-backed via yarp, sourcing buffer words and filesystem paths (no LSP source was configured).

**Covered by, two ways:**

1. **No plugin — Neovim 0.12 `'autocomplete'`.** Vim-native popup as you type, pulling from the `'complete'` sources in order (`.` current buffer, `w` windows, `b` buffers, `u` unloaded, `t` tags, `F`/`o` function/omnifunc; 0.12 added `F`, `o` and `^N` per-source limits). Add LSP with `vim.lsp.completion.enable(..., {autotrigger=true})` or just `o` in `'complete'` since LSP sets `'omnifunc'` on attach. Paths: `<C-x><C-f>` on demand (not automatic). This is roughly ncm2 parity minus auto path popup.
2. **blink.cmp (already adopted).** Default sources `{ 'lsp', 'path', 'snippets', 'buffer' }`, so buffer words and paths are back automatically, plus LSP. Default keys: `<C-space>` open/docs, `<C-n>`/`<C-p>` move, `<C-y>` accept, `<C-e>` dismiss, `<C-k>` signature. Strict superset of ncm2 and no Python/yarp dependency. Note: the buffer source only shows when LSP returns nothing; set `sources.providers.lsp.fallbacks = {}` to always mix them in.

**Try it in 5 minutes**
```vim
" A. Built-in only. Start a plugin-free instance so blink cannot interfere:
"      nvim --clean some.py
:set autocomplete complete=.^5,w^5,b^5,u^5 completeopt=menuone,noselect,popup
" then type; <C-n>/<C-p> move, <C-y> accept, <C-e> dismiss
:set autocompletedelay=120            " if it feels twitchy
" add LSP to the native popup (in your real config, where pyright attaches): append ,o to 'complete'
" explicit sources on demand, work regardless of plugin:
i<C-x><C-f>    " path       i<C-x><C-o>  omni/LSP     i<C-x><C-l>  whole line
i<C-n>         " buffer words, plain old way

" B. blink.cmp (normal startup): type ./ or / for paths, any word for buffer words,
"    <C-space> to force the menu open; compare feel against A.
```

### vim-autoformat

**Was:** `:Autoformat` ran an external formatter per filetype; with none installed it fell back to Vim's `gq`, so it was effectively `gggqG` with extra steps.

**Covered by:**
- `gq{motion}` / `gggqG`: when an LSP that supports formatting is attached, Neovim sets `'formatexpr'` to `vim.lsp.formatexpr()` on LspAttach, so `gq` *is* LSP formatting. `gw` keeps Vim's internal reflow.
- `:lua vim.lsp.buf.format()` (sync, `{async=true}`, `{name='pylsp'}`, `{range=...}` or visual select then call). 
- `=`/`gg=G` re-indents via `'indentexpr'` (polyglot ships per-language indent files), `:retab`, and `'formatprg'` to pipe through any CLI (`:set formatprg=prettier\ --stdin-filepath\ %`).
- vim-prettier stays for JS/TS/CSS/MD (`:Prettier`), but `prettier` is not on PATH, so it only works in projects with a local `node_modules/.bin/prettier`.

**Genuinely missing today:** a Python formatter. pylsp 1.12 formats only if `autopep8` or `yapf` is in its venv (or `python-lsp-ruff` / `python-lsp-black`); pyright never formats. `black`, `ruff` are not on PATH. One `pip install` fixes it; conform.nvim is the plugin route if you want formatters that are not LSP-backed (prettier, stylua, shfmt) under one `gq`.

**Try it in 5 minutes**
```sh
# give pylsp a formatter (pick one); ruff also brings linting diagnostics
~/.vim/vimpy/bin/pip install "python-lsp-ruff"        # ruff format + ruff check
# or: ~/.vim/vimpy/bin/pip install yapf   /  autopep8   /  python-lsp-black
```
```vim
:lsp restart
:lua =vim.lsp.get_clients({name='pylsp'})[1].server_capabilities.documentFormattingProvider   " want: true
gggqG                                   " whole file via formatexpr
Vjjgq                                   " range
:lua vim.lsp.buf.format({ name = 'pylsp', timeout_ms = 2000 })
:'<,'>!python3 -m json.tool             " ad-hoc filter is still the fastest formatter for JSON
:setl formatexpr= formatprg=jq\ . | normal gggqG   " formatprg is IGNORED while formatexpr is set, so clear it first
```
Optional plugin (multi-tool, non-LSP formatters, format-on-save):
```vim
call minpac#add('stevearc/conform.nvim')
```
```lua
require('conform').setup({ formatters_by_ft = { python = { 'ruff_format' }, javascript = { 'prettier' }, lua = { 'stylua' } },
                           format_on_save = { timeout_ms = 500, lsp_format = 'fallback' } })
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"   -- gq now routes through conform; :ConformInfo shows what is found
```

### vim-vinegar

**Was:** `-` opens netrw at the current file's directory (cursor on the file), `-` again goes up, with tidied netrw defaults. In this config netrw's auto-open was already overridden by `ranger.vim` (`g:ranger_replace_netrw = 1`), so `-` was the only part in use.

**Covered by:**
- **ranger.vim (stays):** `<leader>f` / `:Ranger` opens ranger at the current file; `:RangerCurrentDirectory`, `:RangerWorkingDirectory`. This is already the richer file browser.
- **netrw (built-in, still shipped in 0.12.6 as `pack/dist/opt/netrw`, loaded by default):** `:Explore` (`:Ex`) opens the current file's directory, `-` goes up, `%` new file, `d` new dir, `D` delete, `R` rename, `gh` toggle dotfiles. ranger.vim only removes the "open directory on `nvim .`" autocmd; `:Ex` still works. Map `-` to `:Ex` and you have 90% of vinegar; what you lose is vinegar's cursor-on-current-file and its `.`/`y.` path helpers.
- **fzf.vim (stays):** `:Files %:h` is often what `-` was really for.

**Try it in 5 minutes**
```vim
:Ex             " netrw at this file's directory; press - to go up, <CR> to open
:nnoremap - :Ex<CR>
:Ranger         " compare with ranger.vim
:Files %:h      " fzf in the current file's directory
```
Optional plugin (edit a directory like a buffer; modern vinegar):
```vim
call minpac#add('stevearc/oil.nvim')
```
```lua
require('oil').setup({ default_file_explorer = false })   -- false keeps ranger.vim owning `nvim .`
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
-- inside: - up, <CR> open, g. dotfiles, g? help; rename/delete/move by editing lines then :w
```
