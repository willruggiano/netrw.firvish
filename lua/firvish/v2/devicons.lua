local ok, devicons = pcall(require, "nvim-web-devicons")

local DIRECTORY_ICON_NAME = "file-directory"
local DEFAULT_ICON = ""

local M = {
  enabled = ok,
}

if ok then
  local has_nonicons, nonicons = pcall(require, "nvim-nonicons")

  M.width = string.len(devicons.get_icon("", "", { default = true }))

  devicons.set_icon {
    [DIRECTORY_ICON_NAME] = {
      icon = has_nonicons and nonicons.get(DIRECTORY_ICON_NAME) or DEFAULT_ICON,
      color = "#7ebae4",
      name = "FileDirectoryNode",
    },
  }
end

---@param path Path
function M.get_icon(path)
  assert(M.enabled, "invariant violated: nvim-web-devicons is not available")
  local filename = path.filename
  if path:is_dir() then
    filename = DIRECTORY_ICON_NAME
  end
  return devicons.get_icon(filename, string.match(filename, "%a+$"), { default = true })
end

function M.add_highlight(bufnr, namespace, lnum, higroup)
  local col_start, col_end = #" ", M.width + #" "
  vim.api.nvim_buf_add_highlight(bufnr, namespace, higroup, lnum - 1, col_start, col_end)
end

return M
