-- Set clipboard to use the system clipboard
vim.opt.clipboard = "unnamedplus"

-- Show line numbers
vim.opt.number = true

-- Show relative line numbers
-- vim.opt.relativenumber = true

-- Enable mouse support
vim.opt.mouse = "a"

-- Ignore case when searching
vim.opt.ignorecase = true

-- Show whitespace characters
vim.opt.list = true

-- Show tabs as 8 character cells
vim.opt.tabstop = 8

-- Always use spaces instead of tabs
vim.opt.expandtab = true

-- Show tabs as 4 character cells
vim.opt.tabstop = 4

-- Show tabs as clearly
vim.opt.softtabstop = 0

-- Set tabs as 4 spaces
vim.opt.shiftwidth = 4

-- Press tab key for spaces
vim.opt.smarttab = true

vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
]]
