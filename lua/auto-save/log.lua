local M = {}

function M.info(message)
	vim.notify(message, vim.log.levels.INFO)
end

return M
