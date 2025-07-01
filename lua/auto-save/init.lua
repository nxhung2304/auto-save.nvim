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

local state = {
	enabled = false,
	group = nil,
	timer = nil,
}

---@param options? AutoSave.Config
function M.setup(options)
	config.setup(options)
	commands.setup()

	state.enabled = config.options.enabled

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
	if file_name == "" then
		file_name = "[No Name]"
	end
	local message = "Auto save: " .. file_name

	log.info(message)
end

function M.perform_save()
	local ok, err = pcall(function()
		vim.cmd("silent! write")
	end)

	if ok then
		local file_name = fn.expand("%")
		log.info("Saved: " .. file_name)
	else
		log.error("Save failed: " .. tostring(err))
	end
end

function M.enable()
	if state.enabled then
		return
	end

	state.enabled = true

	M.setup_autosave_callback()
	log.info("Auto-save enabled")
end

function M.disable()
	if not state.enabled then
		return
	end

	state.enabled = false

	if state.group then
		api.nvim_del_augroup_by_id(state.group)
	end

	if state.timer then
		state.timer:close()
		state.timer = nil
	end

	log.info("Auto-save disabled")
end

return M
