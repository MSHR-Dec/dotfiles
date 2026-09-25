-- toggleterm.nvim
local brush_path = vim.fn.executable("/opt/homebrew/bin/brush") == 1 and "/opt/homebrew/bin/brush"
  or vim.fn.executable("/home/linuxbrew/.linuxbrew/bin/brush") == 1 and "/home/linuxbrew/.linuxbrew/bin/brush"
  or nil
local login_shell = brush_path and (brush_path .. " --login") or "/bin/bash --login"

require("toggleterm").setup({
  size = vim.o.lines * 0.25,
  open_mapping = [[<c-t>]],
  direction = "horizontal",
  shell = login_shell,
})
vim.keymap.set("t", "<F1>", [[<c-\><c-n>]], { noremap = true })
vim.keymap.set("v", "<Leader>s", ":ToggleTermSendVisualSelection<cr>",
  { desc = "send selection to terminal" })
vim.keymap.set("n", "<Leader>tig", function() require("tig").toggle() end)
vim.keymap.set("n", "<Leader>tt", function()
  require("toggleterm.terminal").Terminal:new({ direction = "tab" }):toggle()
end, { desc = "terminal (own tab)" })
-- Requirement:
--  Set "fullscreen" to `gui.screenMode` in the config
--  see: https://github.com/jesseduffield/lazydocker/blob/master/docs/Config.md
vim.keymap.set("n", "<Leader>lzd", function()
  require("toggleterm.terminal").Terminal:new({
    cmd = "lazydocker", direction = "float",
  }):toggle()
end)
vim.keymap.set("n", "<Leader>lzg", function()
  require("toggleterm.terminal").Terminal:new({
    cmd = "lazygit", direction = "float",
  }):toggle()
end, { desc = "lazygit" })

-- vim-floaterm for yazi
vim.g.floaterm_opener = "edit"
-- floaterm は GIT_EDITOR を乗っ取るが、バージョン判定が文字列比較のため
-- ('0.12.5' <= '0.4.4' が真) 旧 nvim 向けの分岐に入り、ジョブ単位ではなく
-- nvim プロセス全体に setenv してしまう。toggleterm 内の git まで巻き込まれる
vim.g.floaterm_giteditor = false
vim.api.nvim_set_hl(0, "Floaterm", { bg = "#2B2B2B" })
vim.api.nvim_set_hl(0, "FloatermBorder", { bg = "#2B2B2B" })
vim.keymap.set("n", "<C-b>", function()
  vim.cmd(("FloatermNew --width=0.9 --height=0.9 --title=yazi yazi %s"):format(vim.fn.fnameescape(vim.fn.getcwd())))
end, { desc = "yazi" })

-- fzf-lua
local fzf = require("fzf-lua")

local ignore_dirs = {
  "tmp", ".claude", "sig", "node_modules", ".git",
  "dist", "public", "vendor", "bin", "__pycache__",
  ".venv", "venv", "jvm", "jars",
}
local fd_excludes = table.concat(
  vim.tbl_map(function(d) return "--exclude " .. d end, ignore_dirs), " ")
local rg_globs = table.concat(
  vim.tbl_map(function(d) return ("--glob '!%s/**'"):format(d) end, ignore_dirs), " ")

fzf.setup({
  files = {
    fd_opts = "--color=never --type f --type l --hidden --follow " .. fd_excludes,
  },
  grep = {
    rg_opts = "--column --line-number --no-heading --color=always --smart-case "
      .. "--max-columns=4096 " .. rg_globs .. " -e",
  },
})

vim.keymap.set("n", "<Leader>fg", function()
  fzf.fzf_exec("fd --type d --hidden --follow " .. fd_excludes, {
    prompt = "Dir> ",
    actions = {
      ["default"] = function(selected)
        if not selected or not selected[1] then return end
        local dir = vim.fn.fnamemodify(selected[1], ":p")
        fzf.live_grep({ cwd = dir, winopts = { title = (" %s "):format(dir) } })
      end,
    },
  })
end, { desc = "live_grep in dir" })
vim.keymap.set("n", "<Leader>fG", fzf.live_grep)
vim.keymap.set("n", "<Leader>ff", fzf.grep_curbuf)
vim.keymap.set("n", "<Leader>fF", fzf.files)
vim.keymap.set("n", "<Leader>fb", fzf.buffers)

-- search-replace
require("search-replace").setup({
  default_replace_single_buffer_options = "gcI",
  default_replace_multi_buffer_options = "egcI",
})
vim.keymap.set("n", "<Leader>r", "<cmd>SearchReplaceSingleBufferOpen<cr>")
vim.keymap.set("v", "<C-r>", "<cmd>SearchReplaceSingleBufferVisualSelection<cr>")

-- vim-terraform
vim.g.terraform_fmt_on_save = 1

-- aerial.nvim (outline, treesitter only / no LSP)
require("aerial").setup({
  backends = { "treesitter" },
  layout = {
    default_direction = "float",
    max_width = 0.4,
    min_width = 40,
    max_height = 0.3,
    min_height = 20,
  },
  keymaps = {
    ["j"] = "actions.next",
    ["k"] = "actions.prev",
  },
})
vim.keymap.set("n", "<Leader>o", "<cmd>AerialToggle<cr>", { desc = "outline" })

vim.keymap.set("n", "<Leader>fo", function() require("aerial").fzf_lua_picker() end,
  { desc = "search symbols (aerial)" })

-- .documents
local docs_dir = vim.fn.expand("~/.documents")

vim.keymap.set("n", "<Leader>nb", function()
  vim.cmd(("FloatermNew --width=0.9 --height=0.9 --title=documents yazi %s"):format(vim.fn.fnameescape(docs_dir)))
end, { noremap = true, desc = "documents: yazi" })
vim.keymap.set("n", "<Leader>nl", function()
  require("fzf-lua").live_grep({ cwd = docs_dir, winopts = { title = " Documents Grep " } })
end, { noremap = true, desc = "documents: grep" })
