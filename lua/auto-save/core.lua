local M = {}

local bo = vim.bo
local fn = vim.fn
local log = require("auto-save.log")

M.has_filename = function()
	return fn.expand("%") ~= ""
end

M.can_edit = function()
	return bo.modifiable
end

M.was_change = function()
	return bo.modified
end

M.read_only = function()
	return bo.readonly
end

function M.should_save()
	local checks = {
		{ condition = not M.has_filename(), reason = "No filename" },
		{ condition = not M.can_edit(), reason = "Not modifiable" },
		{ condition = not M.was_change(), reason = "No changes" },
		{ condition = M.read_only(), reason = "Read only" },
	}

	for _, check in ipairs(checks) do
		if check.condition then
			log.debug("Skip save: " .. check.reason)
			return false
		end
	end

	return true
end

function M.reload()
	package.loaded["auto-save"] = nil
	package.loaded["auto-save.init"] = nil

	local reloaded = require("auto-save")
	reloaded.setup(M.last_config or {})

	print("✅ Plugin reloaded!")
	return reloaded
end

function M.toggle()
	print("[auto-save] Toggle")
end

return M
