-- Auto-initialization if user doesn't call setup()
if vim.g.loaded_auto_save then
  return
end

vim.g.loaded_auto_save = 1

-- Auto-setup with defaults if no manual setup
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    if not vim.g.auto_save_setup_called then
      require("auto-save").setup()
    end
  end,
})
