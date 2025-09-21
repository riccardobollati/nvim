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
  use "n1ghtmare/noirblaze-vim"
  
  -- Packer
  use 'wbthomason/packer.nvim'

  -- LSP config
  use 'neovim/nvim-lspconfig'          -- Collection of configs for built-in LSP

  -- Comment lines
  use {
    'numToStr/Comment.nvim',
      config = function()
        require('Comment').setup()
      end
  }
  -- markers
  use "chentoast/marks.nvim"
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
      require('nvim-tree')
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
lspconfig.clangd.setup({})

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

local on_attach = function(client, bufnr)
  -- Optional: buffer-local keymaps for LSP (you already have some global ones)
  local bufmap = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end
end

require('nvim-ts-autotag').setup()
-- marks
require'marks'.setup {}
-- Set up tsx highliter
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "tsx", "typescript", "javascript", "html", "css", "hcl", "terraform" },
  highlight = {
    enable = true,
  },
}
lspconfig.terraformls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = { ["terraform-ls"] = { } }, -- defaults are good
})

-- Filetype tweaks for Terraform/HCL
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.tfvars" },
  callback = function(args)
    vim.bo[args.buf].filetype = "terraform"
  end,
})

-- (Optional) Treat .terraformrc / terraform.rc as hcl
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { ".terraformrc", "terraform.rc", "*.hcl" },
  callback = function(args)
    vim.bo[args.buf].filetype = "hcl"
  end,
})

require('nvim-ts-autotag').setup()
-- Set up null-ls (formatter)
-- Set up null-ls (formatter + tflint with guards)
local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier.with({
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html", "css" },
    }),
        null_ls.builtins.formatting.clang_format.with({
      filetypes = { "c", "cpp" },
    }),
        null_ls.builtins.formatting.black.with({
      extra_args = { "--fast" }, -- optional: faster, skips some checks
    }),
  },
})
-- Setup nvim-tree
require('nvim-tree').setup {
  filters = {
    dotfiles = false,  
  },
  git = {
    ignore = false,    
  }
}

-- Setup nvim-cmp
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
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
    { name = 'nvim_lsp' , max_item_count = 5 },
    { name = 'luasnip' , max_item_count = 5},
    { name = 'buffer' , max_item_count = 5}
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
  },
  pickers = {
    find_files = {
      hidden = true
    }
  }
}

require('telescope').load_extension('fzf') -- to make telescope faster

-- Auto indentation
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.expandtab = true
vim.o.shiftwidth = 2  -- number of spaces per indentation level
vim.o.tabstop = 2     -- number of spaces that a <Tab> inserts

-- Basic configs
vim.opt.number = true
vim.opt.relativenumber = true

-- theme configs
vim.o.background = "dark"
vim.cmd[[colorscheme gruvbox]] -- Theme configs
-- vim.cmd("colorscheme noirblaze")

-- Shortcuts
vim.g.mapleader = " "

vim.keymap.set('n', '<leader>b', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>v", ":vsplit | wincmd l <CR>", { desc = "open a vertical split and move to it" })
vim.keymap.set("n", "<leader>h", ":split | wincmd j <CR>", { desc = "open a vertical split and move to it" })

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>fc", function()
  vim.lsp.buf.format({ async = true })
end, { noremap = true, silent = true })

vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', {})
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', {})
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', {})
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', {})
-- Go to definition bindings
vim.keymap.set('n', 'gdn', function()
  vim.cmd('vsplit')  -- open a vertical split
  vim.cmd('wincmd l')  -- move to the right split

  vim.lsp.buf.definition()  -- jump to definition
end, { desc = "Go to definition in vertical split" })

vim.keymap.set('n', 'gds', function()
vim.lsp.buf.definition()
end, { desc = "Go to definition in the current page" })


-- Diffview keymaps
vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Open Git diff view" })
vim.keymap.set("n", "<leader>gq", ":DiffviewClose<CR>", { desc = "Close Git diff view" })
-- Open a terminal
vim.keymap.set('n', '<leader>t', ':terminal<CR>')
vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })

-- Easier window navigation with Ctrl + h/j/k/l
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Move to left window" })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Move to below window" })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Move to above window" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Move to right window" })

-- Window resiszing
vim.keymap.set('n', '<C-Up>',    ':resize +2<CR>')
vim.keymap.set('n', '<C-Down>',  ':resize -2<CR>')
vim.keymap.set('n', '<C-Left>',  ':vertical resize -2<CR>')
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>')

-- these shortucs maximize the cirrent window size and restore it to the original
-- Variable to store previous window sizes
local window_restore = {}

-- Maximize current window
vim.keymap.set("n", "<leader>wm", function()
  -- Save current window dimensions
  local winid = vim.api.nvim_get_current_win()
  window_restore[winid] = {
    width = vim.api.nvim_win_get_width(winid),
    height = vim.api.nvim_win_get_height(winid)
  }

  -- Maximize window
  vim.cmd("wincmd |") -- Maximize horizontally
  vim.cmd("wincmd _") -- Maximize vertically
end, { desc = "Maximize current window" })

-- see function desc
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
-- Restore previous window size
vim.keymap.set("n", "<leader>wr", function()
  local winid = vim.api.nvim_get_current_win()
  local size = window_restore[winid]

  if size then
    vim.api.nvim_win_set_width(winid, size.width)
    vim.api.nvim_win_set_height(winid, size.height)
  else
    vim.notify("No previous window size saved", vim.log.levels.WARN)
  end
end, { desc = "Restore previous window size" })
