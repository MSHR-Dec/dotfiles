require('common')
require('plugins')

-- 初回起動（プラグイン未取得）時に落ちないようにする
for _, mod in ipairs({ 'appearances', 'tools', 'custom.requirements' }) do
  local ok, err = pcall(require, mod)
  if not ok then
    vim.notify(mod .. ': ' .. err, vim.log.levels.WARN)
  end
end
