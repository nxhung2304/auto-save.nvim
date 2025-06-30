local M = {}

function M.info(file_name)
	if file_name == "" then
		file_name = "[No Name]"
	end

	vim.notify("Auto save: " .. file_name, vim.log.levels.INFO)
end

return M
