-- プロジェクト直下に ./docker-ruby-lsp (docker compose exec -i <service> ruby-lsp を
-- exec するラッパースクリプト) があれば、そちらを優先して使う
local function ruby_lsp_cmd()
  local wrapper = vim.fn.getcwd() .. '/docker-ruby-lsp'
  if vim.uv.fs_stat(wrapper) then
    return { wrapper }
  end
  return { 'ruby-lsp' }
end

require('custom.lsp').setup('ruby_lsp', {
  cmd = ruby_lsp_cmd(),
  init_options = {
    formatter = 'auto',
  },
})
