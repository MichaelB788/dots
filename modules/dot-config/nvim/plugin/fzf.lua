vim.pack.add({
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/nvim-tree/nvim-web-devicons"
}, { confirm = false })

require("fzf-lua").setup({
    winopts = {
        preview = {
            hidden = true
        }
    }
})

local fzf = require('fzf-lua')
vim.keymap.set('n', '<leader>f', fzf.files)
vim.keymap.set('n', '<leader>g', fzf.live_grep)
