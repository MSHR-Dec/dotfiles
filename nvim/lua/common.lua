vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 使わない provider を無効化（起動時の実行ファイル探索を省く）
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- netrw は使わない（ディレクトリで開かれたらダッシュボードを出す）
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- options
vim.opt.ambiwidth = "single"
vim.opt.cinoptions:append(":0")
vim.opt.clipboard = { "unnamedplus" }
vim.opt.cmdheight = 1
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.matchtime = 1
vim.opt.number = true
vim.opt.showmatch = true
vim.opt.shiftwidth = 0
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.title = true
vim.opt.updatetime = 400
vim.opt.writebackup = false

-- keymaps
vim.keymap.set("n", "x", "\"_x")
vim.keymap.set("n", "s", "\"_s")
vim.keymap.set("n", "<c-n>", "<cmd>bnext<cr>", { remap = true })
vim.keymap.set("n", "<c-p>", "<cmd>bprev<cr>", { remap = true })
vim.keymap.set("n", "<Leader>;", "<cmd>nohlsearch<cr>", { remap = true })
vim.keymap.set("n", "<Leader>jq", "<cmd>%!jq '.'<cr>", { remap = true })
vim.keymap.set("n", "<Leader>m", "<cmd>e memo.md<cr>", { desc = "open memo.md" })
vim.keymap.set("n", "<Leader>vs", "<cmd>vsplit<cr><C-w>w<cr>", { remap = true })
vim.keymap.set("n", "<Leader>nu", "<cmd>set number!<cr>")
vim.keymap.set("n", "<Leader>wr", "<cmd>set wrap!<cr>")
vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<cr><Esc>", { noremap = true, silent = true })
vim.keymap.set("n", "<c-h>", "<c-w>h")
vim.keymap.set("n", "<c-j>", "<c-w>j")
vim.keymap.set("n", "<c-k>", "<c-w>k")
vim.keymap.set("n", "<c-l>", "<c-w>l")
vim.keymap.set("n", "<c-up>", "<cmd>resize -2<cr>")
vim.keymap.set("n", "<c-down>", "<cmd>resize +2<cr>")
vim.keymap.set("n", "<c-left>", "<cmd>vertical resize -10<cr>")
vim.keymap.set("n", "<c-right>", "<cmd>vertical resize +10<cr>")
vim.keymap.set("t", "<c-up>", "<cmd>resize -2<cr>")
vim.keymap.set("t", "<c-down>", "<cmd>resize +2<cr>")
vim.keymap.set("t", "<c-left>", "<cmd>vertical resize -10<cr>")
vim.keymap.set("t", "<c-right>", "<cmd>vertical resize +10<cr>")
vim.keymap.set("t", "<c-j>", "<cmd>wincmd j<cr>")
vim.keymap.set("t", "<c-k>", "<cmd>wincmd k<cr>")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- insert mode: emacs-like cursor movement
vim.keymap.set("i", "<c-p>", "<Up>")
vim.keymap.set("i", "<c-n>", "<Down>")
vim.keymap.set("i", "<c-b>", "<Left>")
vim.keymap.set("i", "<c-f>", "<Right>")
vim.keymap.set("i", "<c-a>", "<Home>")
vim.keymap.set("i", "<c-e>", "<End>")
vim.keymap.set("i", "<c-h>", "<BS>")
vim.keymap.set("i", "<c-d>", "<Del>")
