local M = {}

local api = vim.api
local core = require("auto-save.core")

function M.setup()
	M.setup_reload_command()
  M.setup_toggle_command()
end

function M.setup_reload_command()
	api.nvim_create_user_command("ASReload", function()
		core.reload()
	end, { desc = "Reload auto-save plugin" })
end

function M.setup_toggle_command()
	api.nvim_create_user_command("ASToggle", function()
		core.toggle()
	end, { desc = "Toggle auto-save plugin" })
end

return M
