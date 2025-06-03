-- Plugin setup
require('packer').startup(function(use)

	  -- Telescope (fuzzy finder)
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    requires = { {'nvim-lua/plenary.nvim'} }
  }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' } -- make telescope faster

  -- Themes
  use "ellisonleao/gruvbox.nvim"
  
  -- Packer
  use 'wbthomason/packer.nvim'

  -- LSP config
  use 'neovim/nvim-lspconfig'          -- Collection of configs for built-in LSP

  -- Autocompletion
  use 'hrsh7th/nvim-cmp'               -- Completion plugin
  use 'hrsh7th/cmp-nvim-lsp'           -- LSP source for nvim-cmp
  use 'L3MON4D3/LuaSnip'               -- Snippet engine
  use 'saadparwaiz1/cmp_luasnip'       -- Snippet source for nvim-cmp
  use {
  'nvim-treesitter/nvim-treesitter',
  run = ':TSUpdate'
}
	use 'nvimtools/none-ls.nvim'
	use 'nvim-lua/plenary.nvim'
-- autocompletition tsx
use 'windwp/nvim-ts-autotag'

  -- File explorer (like VS Code sidebar)
  use {
    'nvim-tree/nvim-tree.lua',
    requires = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup()
    end
  }
  -- Git plugins
  -- show modifications inline
    use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end
  }
  -- Compare code versions
    use {
    'sindrets/diffview.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }
  -- Git interface
   use 'tpope/vim-fugitive'

  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Setup LSP servers
local lspconfig = require('lspconfig')
lspconfig.pyright.setup({})
lspconfig.ts_ls.setup({})

require('nvim-ts-autotag').setup()
-- Set up tsx highliter
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "tsx", "typescript", "javascript", "html", "css" },
  highlight = {
    enable = true,
  },
}
require('nvim-ts-autotag').setup()
-- Set up null-ls (formatter)
local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier.with({
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html", "css" },
    }),
  },
})

-- Setup nvim-cmp
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  completion = {
  	entries_limit = 5
  },
  mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true })
      else
        fallback()
      end
    end,
	  ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' }
  },
})

-- set up telescope
require('telescope').setup{
  defaults = {
    layout_strategy = 'horizontal',
    layout_config = {
      preview_width = 0.6,
    },
    file_ignore_patterns = {"node_modules", "%.git"},
  }
}

require('telescope').load_extension('fzf') -- to make telescope faster


-- Basic configs
vim.opt.number = true
vim.opt.relativenumber = true

vim.o.background = "dark"
vim.cmd[[colorscheme gruvbox]] -- Theme configs

-- Shortcuts
vim.g.mapleader = " "

vim.keymap.set('n', '<leader>b', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>fc", function()
  vim.lsp.buf.format({ async = true })
end, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', {})
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', {})
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', {})
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', {})
-- Diffview keymaps
vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Open Git diff view" })
vim.keymap.set("n", "<leader>gq", ":DiffviewClose<CR>", { desc = "Close Git diff view" })
-- Open a terminal
vim.keymap.set('n', '<leader>t', function()
  vim.cmd('vsplit | terminal')
  vim.cmd('lcd ' .. vim.loop.cwd())
end, { desc = "Open terminal in current working directory" })

-- Easier window navigation with Ctrl + h/j/k/l
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Move to left window" })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Move to below window" })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Move to above window" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Move to right window" })
