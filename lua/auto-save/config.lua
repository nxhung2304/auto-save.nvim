local M = {}

---@class AutoSave.Config
local defaults = {
	delay = 1,
	enabled = true,
}

---@type AutoSave.Config
M.options = {}

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", defaults, options or {})
end

return M
