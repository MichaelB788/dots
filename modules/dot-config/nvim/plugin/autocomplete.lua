vim.pack.add({
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/garymjr/nvim-snippets",
}, { confirm = false })

require("nvim-autopairs").setup()

local cmp = require("cmp")
cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
		end,
	},
	performance = {
		max_view_entries = 10,
	},
	formatting = {
		fields = { "abbr" },
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({ { name = "nvim_lsp" } }, { { name = "buffer" } }),
})

local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
