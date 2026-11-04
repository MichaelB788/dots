vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" }, { confirm = false })

require('nvim-treesitter').install { 'go', 'c', 'cpp', 'rust' }

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go', 'c', 'cpp', 'rust' },
  callback = function()
    vim.treesitter.start()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldmethod = 'expr'
    vim.wo[0][0].foldlevel = 99
  end,
})
