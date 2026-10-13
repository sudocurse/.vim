vim.bo.textwidth = 88
vim.keymap.set('n', ',r', '<Cmd>w<CR><Cmd>!python3 %<CR>', { buffer = true, desc = 'run file' })
