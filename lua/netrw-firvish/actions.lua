local has_trash = vim.fn.executable "trash" == 1

local M = {}

function M.delete(path)
  if has_trash then
    os.execute("trash " .. path.filename)
  else
    if path:is_dir() then
      path:rmdir()
    else
      path:rm()
    end
  end
end

return M
