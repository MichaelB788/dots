-- LSP Plugins
vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
}, { confirm = false })

-- Diagnostics
vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	virtual_text = { spacing = 2, prefix = "●" },
	float = { border = "rounded", source = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.INFO] = "",
			[vim.diagnostic.severity.HINT] = "󰌵",
		},
	},
})

-- Shared capabilities for every server
vim.lsp.config("*", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

-- LSP Servers
local servers = {
	clangd = {
		cmd = {
			"clangd",
			"--background-index",
			"--clang-tidy",
			"--completion-style=detailed",
		},
	},

	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				check = { command = "clippy" },
				cargo = { allFeatures = true },
			},
		},
	},

	-- pylsp handles completion/navigation; ruff handles lint + format
	pylsp = {
		settings = {
			pylsp = {
				plugins = {
					pycodestyle = { enabled = false },
					mccabe = { enabled = false },
					pyflakes = { enabled = false },
					autopep8 = { enabled = false },
					yapf = { enabled = false },
					black = { enabled = false },
					pylsp_black = { enabled = false },
				},
			},
		},
	},
	ruff = {},

	-- runs shellcheck and shfmt automatically if they are on PATH
	bashls = {
		filetypes = { "sh", "bash" },
	},

	-- handy for editing your own nvim config
	lua_ls = {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				workspace = {
					checkThirdParty = false,
					library = { vim.env.VIMRUNTIME },
				},
				diagnostics = { globals = { "vim" } },
				telemetry = { enable = false },
			},
		},
	},
}

for name, config in pairs(servers) do
	vim.lsp.config(name, config)
	vim.lsp.enable(name)
end

-- Formatting (conform: external formatters first, LSP as fallback)
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		python = { "ruff_fix", "ruff_format" },
		-- c, cpp, rust: no entry, so conform falls back to clangd / rust-analyzer
	},
	format_on_save = {
		timeout_ms = 1000,
		lsp_format = "fallback",
	},
})

-- Linting for tools that have no language server
local lint = require("lint")
lint.linters_by_ft = {
	c = { "cppcheck" },
	cpp = { "cppcheck" },
}
table.insert(lint.linters.cppcheck.args, "--suppress=unusedStructMember")

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
	group = vim.api.nvim_create_augroup("lint-on-save", { clear = true }),
	callback = function()
		lint.try_lint()
	end,
})

-- Global keybindings
vim.keymap.set("n", "<leader>xx", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ lsp_format = "fallback" })
end, { desc = "Format buffer" })

-- Buffer-local bindings and features, set only when a server attaches
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		local buf = args.buf

		local function map(lhs, rhs, desc, mode)
			vim.keymap.set(mode or "n", lhs, rhs, { buffer = buf, desc = "LSP: " .. desc })
		end

		map("gd", vim.lsp.buf.definition, "Go to definition")
		map("gD", vim.lsp.buf.declaration, "Go to declaration")
		map("<leader>rn", vim.lsp.buf.rename, "Rename")
		map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "v" })
		map("<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")
		-- Built into Neovim 0.11+: K (hover), grr (references), gri (implementation),
		-- grt (type definition), gO (outline), <C-s> in insert mode (signature help)

		if client:supports_method("textDocument/implementation") then
			map("gi", vim.lsp.buf.implementation, "Go to implementation")
		end

		-- Switch between header and source in C/C++
		if client.name == "clangd" then
			map("<leader>h", "<cmd>LspClangdSwitchSourceHeader<cr>", "Switch source/header")
		end

		-- Inlay hints, toggleable
		if client:supports_method("textDocument/inlayHint") then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
			end, "Toggle inlay hints")
		end

		-- Highlight other references to the symbol under the cursor
		if client:supports_method("textDocument/documentHighlight") then
			local group = vim.api.nvim_create_augroup("lsp-highlight-" .. buf, { clear = true })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				group = group,
				buffer = buf,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				group = group,
				buffer = buf,
				callback = vim.lsp.buf.clear_references,
			})
		end
	end,
})
