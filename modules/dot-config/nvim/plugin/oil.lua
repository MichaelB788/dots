vim.pack.add({ "https://github.com/stevearc/oil.nvim" }, { confirm = false })

require("oil").setup()
local oil = require("oil")
vim.keymap.set("n", "<leader>e", oil.open_float)
