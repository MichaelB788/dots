vim.pack.add({ "https://github.com/danhat1020/colorscheme-picker.nvim" }, { confirm = false })

require("colorscheme-picker").setup()

vim.keymap.set('n', '<leader>tt', '<cmd>ColorschemePick<cr>')
