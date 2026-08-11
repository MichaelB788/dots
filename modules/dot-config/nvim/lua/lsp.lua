-- LSP Plugins
vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/hrsh7th/cmp-nvim-lsp",
}, { confirm = false })

-- LSP Servers
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = { vim.env.VIMRUNTIME },
        },
        runtime = { version = "LuaJIT" },
      },
    },
  },
  clangd = {},
  rust_analyzer = {},
  bashls = {},
  pylsp = {},
}

-- Enable LSP capabilities
local capabilities = require("cmp_nvim_lsp").default_capabilities()
for name, config in pairs(servers) do
  config.capabilities = capabilities
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attatch", {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    -- Go to implementation (only for filetypes which support it)
    if client:supports_method("textDocument/implementation") then
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
    end

    if
        not client:supports_method("textDocument/willSaveWaitUntil")
        and client:supports_method("textDocument/formatting")
    then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
  end,
})

-- LSP Keybindings
vim.keymap.set("n", "<leader>xx", vim.diagnostic.setloclist)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
