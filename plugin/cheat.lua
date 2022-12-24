if vim.g.loaded_chtsh then
  return
end
vim.g.loaded_chtsh = true
local cheat = require "cheat"
cheat.setup()
