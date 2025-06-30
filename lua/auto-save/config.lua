local M = {}

local default_config = {
	delay = 1,
	enabled = true,
}

local current_config = {}

function M.setup(user_config)
  current_config = vim.tbl_deep_extend("force", default_config, user_config or {})
end

function M.get()
  return current_config
end

function M.get_default()
  return default_config
end

return M
