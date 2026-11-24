local M = {}

-- Returns abs path cwd from buf name "term://{cwd}//{pid}:{cmd}"
-- or nil for a non-terminal buf
function M.term_cwd(buf)
	local name = vim.api.nvim_buf_get_name(buf)
	local cwd = name:match("^term://(.-)//%d+:")
	if cwd == nil then
		return nil
	end
	return vim.fs.normalize(cwd)
end

M.opts = {
	-- Configurable fn used to determine what to do when t<CR> is pressed;
	-- it will be passed a list of loaded term bufs
	fn = function(term_bufs)
		local abs_cwd = vim.fs.normalize(vim.fn.getcwd())
		for _, buf in ipairs(term_bufs) do
			if M.term_cwd(buf) == abs_cwd then
				vim.api.nvim_set_current_buf(buf)
				return
			end
		end
		vim.cmd.terminal()
	end,
}

function M.setup(opts)
	M.opts = vim.tbl_deep_extend("force", M.opts, opts or {})

	vim.keymap.set("n", "t<CR>", function()
		local term_bufs = vim.tbl_filter(function(buf)
			return vim.api.nvim_buf_is_loaded(buf)
				and vim.bo[buf].buftype == "terminal"
		end, vim.api.nvim_list_bufs())

		M.opts.fn(term_bufs)
	end)
end

return M
