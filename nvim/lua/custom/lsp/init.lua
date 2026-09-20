local M = {}

require('mason').setup()
require('mason-lspconfig').setup()

local capabilities = require('blink.cmp').get_lsp_capabilities()

local function on_attach(_, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<Leader>lf', function() vim.lsp.buf.format({ async = true }) end, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
end

function M.setup(server, opts)
  vim.lsp.config(server, vim.tbl_deep_extend('force', {
    capabilities = capabilities,
    on_attach = on_attach,
  }, opts or {}))
  vim.lsp.enable(server)
end

return M
