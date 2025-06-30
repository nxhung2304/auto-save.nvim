local M = {}

local bo = vim.bo
local fn = vim.fn

M.file_exist = function()
	return fn.expand("%") == ""
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
	if not M.file_exist then
		return false
	end

	if not M.can_edit then
		return false
	end

	if not M.was_change then
		return false
	end

	if M.read_only then
		return false
	end

	return true
end

return M
