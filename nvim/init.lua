-- keybinds --
vim.g.mapleader = "~"

-- see keybinds
vim.keymap.set("n", "<leader>?",
   "<cmd>WhichKey<CR>",
   { desc = "Show Keybinds" })

-- adj config
vim.keymap.set("n", "<leader>c",
   "<cmd>edit ~/.config/nvim/init.lua<CR>",
   { desc = "Edit Config" })

-- general --
vim.opt.number = true
vim.opt.relativenumber = true

-- 3-space tabs
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
vim.opt.expandtab = true

-- clipboard
vim.opt.clipboard = "unnamedplus"

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- display diagnostics (errors/warnings from the lsp)
vim.diagnostic.config({
   virtual_text = true,      -- show messages beside the line
   signs = true,             -- icons in the sign column
   underline = true,         -- underline bad code
   update_in_insert = false, -- don't spam while typing
   severity_sort = true,
})

-- lazy.nvim --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then -- so i can just copy the config later
   vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
   })
end

vim.opt.rtp:prepend(lazypath)

-- plugins
require("lazy").setup({

   -- custom start screen
   {
      "goolord/alpha-nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
         local alpha = require("alpha")
         local dashboard = require("alpha.themes.dashboard")
         local palette = require("inabakumidnight.palette")

         local imagepath = vim.fn.stdpath("config") .. "/lagtrain.jpg"
         local handle = io.popen("ascii-image-converter " .. imagepath .. " -cfb --threshold 180")
         local header = handle:read("*a")
         handle:close()

         dashboard.section.header.val = vim.split(header, "\n")

         local palette = require("inabakumidnight.palette")

         vim.api.nvim_set_hl(0, "AlphaHeader", {
            fg = palette.yellow_light,
         })

         vim.api.nvim_set_hl(0, "AlphaButtons", {
            fg = palette.red_light,
         })

         vim.api.nvim_set_hl(0, "AlphaShortcut", {
            fg = palette.red_lighter,
         })

         dashboard.section.header.opts.hl = "AlphaHeader"

         dashboard.section.buttons.val = {
            dashboard.button("e", "New File", ":ene<CR>"),
            dashboard.button("f", "Find File", ":FzfLua files<CR>"),
            dashboard.button("q", "Quit", ":qa<CR>"),
         }

         -- actually change button color ???
         for _, button in ipairs(dashboard.section.buttons.val) do
            button.opts.hl = "AlphaButtons"
            button.opts.hl_shortcut = "AlphaShortcut"
         end

         alpha.setup(dashboard.config)
      end,
   },

   -- show available keybinds while typing
   {
      "folke/which-key.nvim",

      event = "VeryLazy",

      opts = {},
   },

   -- fzf
   {
      "ibhagwan/fzf-lua",

      dependencies = {
         "nvim-tree/nvim-web-devicons",
      },

      config = function()
         local fzf = require("fzf-lua")

         vim.keymap.set("n", "<leader>ff", fzf.files,
            { desc = "Find Files" })

         vim.keymap.set("n", "<leader>fg", fzf.live_grep,
            { desc = "Live Grep" })
      end,
   },

   -- syntax highlighting w/treesitter
   {
      "nvim-treesitter/nvim-treesitter",
      branch = "main",

      lazy = false,

      build = ":TSUpdate",

      config = function()
         local languages = {
            "lua",
            "python",
            "rust",
            "c",
            "cpp",
            "bash",
            "markdown",
            "markdown_inline",
            "json",
            "toml",
         }

         require("nvim-treesitter").install(languages)

         vim.api.nvim_create_autocmd("FileType", {
            pattern = {
               "lua",
               "python",
               "rust",
               "c",
               "cpp",
               "bash",
               "markdown",
               "json",
               "java",
               "javascript",
            },
            callback = function()
               vim.treesitter.start()
            end,
         })
      end,
   },

   -- mason for language servers
   {
      "williamboman/mason.nvim",

      opts = {},
   },

   {
      "williamboman/mason-lspconfig.nvim",

      dependencies = {
         "williamboman/mason.nvim",
         "neovim/nvim-lspconfig",
      },

      config = function()
         require("mason").setup()

         require("mason-lspconfig").setup({
         })

         vim.keymap.set("n", "<leader>f", function()
            require("conform").format({
               lsp_fallback = true,
               async = false,
               timeout_ms = 500,
            })
         end, { desc = "Format File" })

         vim.lsp.enable(require("mason-lspconfig").get_installed_servers())
         -- lsp shortcuts
         vim.keymap.set("n", "K",
            vim.lsp.buf.hover,
            { desc = "Hover Documentation" })

         vim.keymap.set("n", "gd",
            vim.lsp.buf.definition,
            { desc = "Go to Definition" })

         vim.keymap.set("n", "gr",
            vim.lsp.buf.references,
            { desc = "Find References" })

         vim.keymap.set("n", "<leader>rn",
            vim.lsp.buf.rename,
            { desc = "Rename Symbol" })

         vim.keymap.set("n", "<leader>ca",
            vim.lsp.buf.code_action,
            { desc = "Code Actions" })
      end,
   },

   -- automatic formatting
   {
      "stevearc/conform.nvim",

      opts = {

         format_on_save = {
            timeout_ms = 500,
            lsp_fallback = true,
         },

      },
   },

   -- linting
   {
      "mfussenegger/nvim-lint",

      config = function()
         local lint = require("lint")

         vim.api.nvim_create_autocmd({
            "BufWritePost",
            "BufEnter",
            "InsertLeave",
         }, {

            callback = function()
               lint.try_lint()
            end,

         })
      end,
   },

   -- theme
   {
      dir = "~/Projects/inabakumidnight.nvim",
      lazy = false,
      priority = 1000,
      config = function()
         vim.cmd.colorscheme("inabakumidnight")
      end,
   },

})
