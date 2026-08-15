vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" }, { confirm = false })

require('nvim-treesitter').install { 'rust', 'cpp', 'c', 'python' }

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'h*', 'c*', 'rs', 'py' },
  callback = function() vim.treesitter.start() end,
})
