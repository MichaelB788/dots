vim.pack.add({ "https://github.com/nvim-mini/mini.pick" }, { confirm = false })

require("mini.pick").setup()

-- Find files
vim.keymap.set("n", "<leader>f", ":Pick files<CR>")

-- Seach help files
vim.keymap.set("n", "<leader>h", ":Pick help<CR>")

-- Grep search
vim.keymap.set("n", "<leader>g", ":Pick grep_live<CR>")
