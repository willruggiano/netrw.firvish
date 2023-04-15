local ok, devicons = pcall(require, "nvim-web-devicons")
local FOLDER_ICON_NAME = "netrw_firvish_icon"

local M = {}

function M.setup()
  if ok then
    if not devicons.get_icon(FOLDER_ICON_NAME) then
      devicons.set_icon {
        [FOLDER_ICON_NAME] = {
          icon = "",
          color = "#7ebae4",
          name = "NetrwFirvishFolderIcon",
        },
      }
    end
    M.icon_width = string.len(devicons.get_icon("", "", { default = true }))
  end
  return ok
end

function M.get_icon(file)
  assert(ok, "invariant violated: nvim-web-devicons is not available")
  local filename = file.filename
  if file:is_dir() then
    filename = FOLDER_ICON_NAME
  end
  return devicons.get_icon(filename, string.match(filename, "%a+$"), { default = true })
end

function M.add_highlight(buffer, namespace, lnum, higroup)
  local col_start, col_end = #" ", M.icon_width + #" "
  vim.api.nvim_buf_add_highlight(buffer.bufnr, namespace, higroup, lnum - 1, col_start, col_end)
end

return M
