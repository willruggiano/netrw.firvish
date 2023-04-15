local Job = require "plenary.job"
local Path = require "plenary.path"
local devicons = require "firvish.v2.devicons"

---@class PathEntry
---@field path Path
---@field highlight fun(number, number, number)

local M = {}

---@param cwd Path
---@return PathEntry[]
function M.entries(cwd)
  local paths = {}

  -- stylua: ignore start
  Job
    :new({
      command = "fd",
      args = { "--color", "never", "--maxdepth", "1" },
      ---@diagnostic disable-next-line: assign-type-mismatch
      cwd = tostring(cwd),
      on_stdout = function(_, pathname, _)
        local entry = { path = cwd / pathname }
        if devicons.enabled then
          local hl_group
          entry.icon, hl_group = devicons.get_icon(entry.path)
          entry.highlight = function(bufnr, ns, lnum)
            devicons.add_highlight(bufnr, ns, lnum, hl_group)
          end
        end
        table.insert(paths, entry)
      end
    })
    :sync()
  -- stylua: ignore end

  return paths
end

return M
