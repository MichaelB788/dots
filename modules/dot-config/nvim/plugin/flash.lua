vim.pack.add({ "https://github.com/folke/flash.nvim" }, { confirm = false })

require("flash").setup()

vim.keymap.set("n", "<leader>j", function() require("flash").jump() end)
