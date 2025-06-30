local M = {}
local api = vim.api
local uv = vim.uv
local fn = vim.fn
local schedule_wrap = vim.schedule_wrap
local cmd = vim.cmd

function M.reload()
	package.loaded["auto-save"] = nil
	package.loaded["auto-save.init"] = nil

	local reloaded = require("auto-save")
	reloaded.setup(M.last_config or {})

	print("✅ Plugin reloaded!")
	return reloaded
end

local config = require("auto-save.config")

function M.setup(user_configs)
	config.setup(user_configs)
	M.last_config = user_configs
	print("[auto-save] Setup!")

	-- M.enable()
	local group = vim.api.nvim_create_augroup("AutoSave", { clear = true })
	api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
		group = group,
		callback = M.debounced_save,
	})
end

function M.enable()
	print("[auto-save] Enable")
	local timer = vim.uv.new_timer()
	local delay = 3000
	timer:start(
		1000,
		delay,
		vim.schedule_wrap(function()
			vim.api.nvim_command('echomsg "Auto save file"')
		end)
	)
end

function M.should_save()
	if vim.fn.expand("%") == "" then
		return false
	end

	if not vim.bo.modifiable then
		return false
	end

	if not vim.bo.modified then
		return false
	end

	if vim.bo.readonly then
		return false
	end

	return true
end

local timer = vim.uv.new_timer()
local DELAY = 1000

function M.debounced_save()
	if timer then
		timer:stop()
	end

	timer:start(
		DELAY,
		0,
		vim.schedule_wrap(function()
			if M.should_save() then
				vim.cmd("silent! write")
				local file_name = vim.fn.expand("%")
				if file_name == "" then
					file_name = "[No Name]"
				end
				vim.notify("Auto save: " .. file_name, vim.log.levels.INFO)
			end
		end)
	)
end

function M.disable() end

local nvim_cmd = vim.api.nvim_create_user_command

nvim_cmd("ASReload", function()
	M.reload()
end, { desc = "Reload auto-save plugin" })

return M
