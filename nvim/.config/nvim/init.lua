-- ── Bootstrap lazy.nvim ──────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key must be set before plugins load
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"

-- ── Core modules ──────────────────────────────────────────────────────
require("core.options")
require("core.keymaps")

-- ── Plugins ───────────────────────────────────────────────────────────
require("lazy").setup("plugins", {
    change_detection = { notify = false },
    checker          = { enabled = true, notify = false },
    ui               = { border = "rounded" },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip", "matchit", "matchparen",
                "netrwPlugin", "tarPlugin", "tohtml",
                "tutor", "zipPlugin",
            },
        },
    },
})
