-- theme
require("dracula").setup({
  colors = { bg = "#2B2B2B" },
  transparent_bg = true,
  overrides = {
    Visual   = { bg = "#574778" },
    VisualNOS = { bg = "#574778" },
  },
})
vim.cmd.colorscheme('dracula')

-- nvim-treesitter (main ブランチ)
require("nvim-treesitter").install({
  "go", "hcl", "terraform", "lua", "vim", "vimdoc",
  "json", "yaml", "markdown", "markdown_inline",
})
vim.api.nvim_create_autocmd("FileType", {
  -- パーサ名ではなく filetype で指定する (vimdoc -> help)
  pattern = {
    "go", "hcl", "terraform", "lua", "vim", "help",
    "json", "yaml", "markdown",
  },
  callback = function() vim.treesitter.start() end,
})

-- render-markdown.nvim
-- ambiwidth=double だと既定の見出しサイン '󰫎 ' が3セル幅になり
-- nvim_buf_set_extmark が Invalid 'sign_text' で失敗するため末尾スペースを外す
require("render-markdown").setup({
  heading = {
    sign = true,
    signs = { "󰫎" },
    icons = {},
    width = 'block',
    backgrounds = {},
  },
  bullet = { icons = '•' },
})

-- 言語指定のないコードブロックを 'plain' として描画する
-- render-markdown は info_string ノードが無いと言語行を描画しないため
-- (render/markdown/code.lua の Render:language が早期 return する)
-- 疑似の info/language ノードを注入して既定の描画経路に乗せる
local ok_devicons, devicons = pcall(require, 'nvim-web-devicons')
if ok_devicons then
  devicons.set_icon_by_filetype({ plain = 'txt' })
end

local ok_code, code = pcall(require, 'render-markdown.render.markdown.code')
if ok_code then
  local code_setup = code.setup
  code.setup = function(self)
    local enabled = code_setup(self)
    if enabled and not self.data.language then
      local delim = self.node:child('fenced_code_block_delimiter', self.node.start_row)
      if delim then
        local pos = {
          start_row = delim.start_row, start_col = delim.end_col,
          end_row = delim.start_row, end_col = delim.end_col,
        }
        self.data.info = vim.tbl_extend('force', pos, { text = '' })
        self.data.language = vim.tbl_extend('force', pos, { text = 'plain' })
      end
    end
    return enabled
  end
end

-- dashboard-nvim
require("dashboard").setup({
  theme = "hyper",
  config = {
    week_header = { enable = true },
    shortcut = {
      { desc = "Files", group = "@property",      key = "f", action = "FzfLua files" },
      { desc = "Grep",  group = "Label",          key = "g", action = "FzfLua live_grep" },
      { desc = "yazi",  group = "DiagnosticHint", key = "b",
        action = "FloatermNew --width=0.9 --height=0.9 --title=yazi yazi" },
      { desc = "Update Plugins", group = "String", key = "u", action = "Lazy sync" },
    },
    project = { enable = true, limit = 8, action = "FzfLua files cwd=" },
    mru = { limit = 10 },
  },
})
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0)
    if arg == "" or vim.fn.isdirectory(arg) ~= 1 then return end
    local dirbuf = vim.api.nvim_get_current_buf()
    vim.cmd.cd(arg)
    vim.cmd("Dashboard")
    pcall(vim.api.nvim_buf_delete, dirbuf, { force = true })
  end,
})

-- lualine.nvim
require("lualine").setup({
  sections = {
    lualine_c = {
      function() return vim.fn.fnamemodify(vim.fn.expand("%"), ":.") end,
      { "aerial", dense = true, depth = -1, colored = true },
    },
  },
})

-- nvim-scrollbar
local colors = require("dracula").colors()
require("scrollbar").setup({
  handle = { color = colors.visual },
  marks = {
    Search = { color = colors.yellow },
    Error  = { color = colors.red },
    Warn   = { color = colors.orange },
    Info   = { color = colors.green },
    Hint   = { color = colors.cyan },
    Misc   = { color = colors.purple },
  },
})

-- bufferline.nvim
require("bufferline").setup({})
vim.keymap.set("n", "<Leader>w", "<cmd>bd<cr>", { desc = "Close current buffer" })

require("gitsigns").setup({
  current_line_blame = true,
})
vim.keymap.set("n", "ghu", function() require("gitsigns").reset_hunk() end)
vim.keymap.set("n", "ghp", function() require("gitsigns").preview_hunk() end)

-- gitlinker.nvim (GitHub URL for current line / visual selection)
require("gitlinker").setup()
vim.keymap.set({ "n", "v" }, "<Leader>gy", "<cmd>GitLink<cr>", { desc = "copy git link" })
vim.keymap.set({ "n", "v" }, "<Leader>gY", "<cmd>GitLink!<cr>", { desc = "open git link in browser" })

-- indentmini.nvim
vim.cmd.highlight("IndentLine guifg=#767676")
vim.cmd.highlight("IndentLineCurrent guifg=#af00ff")
require("indentmini").setup()
