---@class auto-save: auto-save.api
local M = {}
local api = vim.api
local uv = vim.uv
local fn = vim.fn
local schedule_wrap = vim.schedule_wrap
local cmd = vim.cmd
local core = require("auto-save.core")
local log = require("auto-save.log")

function M.reload()
	package.loaded["auto-save"] = nil
	package.loaded["auto-save.init"] = nil

	local reloaded = require("auto-save")
	reloaded.setup(M.last_config or {})

	print("✅ Plugin reloaded!")
	return reloaded
end

local config = require("auto-save.config")

---@param options? AutoSave.Config
function M.setup(options)
	config.setup(options)
	M.last_config = options
	print("[auto-save] Setup!")

	M.save_autocmd()
end

function M.save_autocmd()
	local group = vim.api.nvim_create_augroup("AutoSave", { clear = true })
	api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
		group = group,
		callback = M.debounced_save,
	})
end

function M.enable() end

function M.debounced_save()
	local timer = vim.uv.new_timer()
	if timer then
		timer:stop()
	end

	local delay = config.options.delay
	timer:start(
		delay,
		0,
		vim.schedule_wrap(function()
			if core.should_save() then
				M.perform_save()
			end
		end)
	)
end

function M.perform_save()
	vim.cmd("silent! write")

	local file_name = vim.fn.expand("%")
	log.info(file_name)
end

function M.disable() end

local nvim_cmd = vim.api.nvim_create_user_command

nvim_cmd("ASReload", function()
	M.reload()
end, { desc = "Reload auto-save plugin" })

return M
