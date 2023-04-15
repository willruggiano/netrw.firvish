local has_trash = vim.fn.executable "trash" == 1

local M = {}

function M.delete(path)
  if has_trash then
    os.execute("trash " .. path.filename)
  else
    path:rm { recursive = path:is_dir() }
  end
end

return M
