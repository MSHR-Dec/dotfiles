local vim = vim

-- lazy.nvim 本体が無ければ取得（初回のみ / setup.sh でも導入している）
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
    }, true, {})
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- appearance
  'Mofiqul/dracula.nvim',
  { 'nvim-treesitter/nvim-treesitter', branch = 'main', build = ':TSUpdate' },
  'nvim-lualine/lualine.nvim',
  'akinsho/bufferline.nvim',
  'petertriho/nvim-scrollbar',
  'nvimdev/indentmini.nvim',
  'ryanoasis/vim-devicons',
  'nvim-tree/nvim-web-devicons',
  'nvimdev/dashboard-nvim',

  -- git
  'lewis6991/gitsigns.nvim',
  'tpope/vim-fugitive',
  'linrongbin16/gitlinker.nvim',

  -- edit
  'tpope/vim-surround',
  'roobert/search-replace.nvim',

  -- tools
  { 'akinsho/toggleterm.nvim', version = '*' },
  'nvim-lua/plenary.nvim',
  'nvim-telescope/telescope.nvim',
  'voldikss/vim-floaterm',
  'stevearc/aerial.nvim',

  -- filetype
  'ixru/nvim-markdown',
  'MeanderingProgrammer/render-markdown.nvim',
  'hashivim/vim-terraform',

  -- completion
  { 'saghen/blink.cmp', version = '1.*' },
  'rafamadriz/friendly-snippets',

  -- lsp
  'neovim/nvim-lspconfig',
  'mason-org/mason.nvim',
  'mason-org/mason-lspconfig.nvim',
})
