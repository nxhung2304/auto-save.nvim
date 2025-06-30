local M = {}

local bo = vim.bo
local fn = vim.fn

M.has_filename = function()
	return fn.expand("%") ~= ""
end

M.can_edit = function ()
	return bo.modifiable
end

M.was_change = function ()
	return bo.modified
end

M.read_only = function ()
	return bo.readonly
end

function M.should_save()
	if not M.has_filename() then
		return false
	end

	if not M.can_edit() then
		return false
	end

	if not M.was_change() then
		return false
	end

	if M.read_only() then
		return false
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
