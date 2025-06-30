---@class auto-save: auto-save.api
local M = {}
local api = vim.api
local uv = vim.uv
local fn = vim.fn
local schedule_wrap = vim.schedule_wrap
local cmd = vim.cmd
local core = require("auto-save.core")
local log = require("auto-save.log")
local commands = require("auto-save.commands")

local config = require("auto-save.config")

---@param options? AutoSave.Config
function M.setup(options)
	config.setup(options)
	commands.setup()

	print("[auto-save] Setup!")

	M.setup_autosave_callback()
end

function M.setup_autosave_callback()
	local group = vim.api.nvim_create_augroup("AutoSave", { clear = true })
	api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
		group = group,
		callback = M.debounced_save,
	})
end

local debounce_timer = nil

function M.debounced_save()
	if debounce_timer then
		debounce_timer:stop()
		debounce_timer:close()
	end

	local delay = config.options.delay
	debounce_timer = vim.uv.new_timer
	debounce_timer:start(
		delay,
		0,
		vim.schedule_wrap(function()
			if core.should_save() then
				M.perform_save()
			end

			if debounce_timer then
				debounce_timer:close()
				debounce_timer = nil
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
function M.enable() end

return M
