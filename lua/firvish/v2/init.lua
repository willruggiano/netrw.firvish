local Path = require "plenary.path"
local devicons = require "firvish.v2.devicons"
local lib = require "firvish.lib"
local utils = require "firvish.v2.utils"

local state = {
  cwd = Path:new(vim.loop.cwd()),
  hl_ns = vim.api.nvim_create_namespace "firvish-highlights",
}

local bufferstate = require "firvish.v2.bufferstate"

local function set_bufferstate(path)
  bufferstate.entries = utils.entries(path)
end

local function set_lines_quietly(bufnr, start_, end_, strict, lines)
  vim.api.nvim_buf_set_lines(bufnr, start_, end_, strict, lines)
  vim.api.nvim_buf_set_option(bufnr, "modified", false)
end

local function set_lines()
  local highlights = {}
  local fn = function(entry)
    if entry.highlight then
      table.insert(highlights, entry.highlight)
    end
    local line = tostring(entry.path)
    if entry.icon then
      line = entry.icon .. "  " .. line
    end
    return line
  end
  set_lines_quietly(0, 0, -1, false, vim.tbl_map(fn, bufferstate.entries))
  vim.api.nvim_buf_clear_namespace(0, state.hl_ns, 0, -1)
  for i, hi in ipairs(highlights) do
    hi(0, state.hl_ns, i)
  end
end

local function set_keymaps()
  vim.keymap.set("n", "<CR>", function()
    local path = lib.get_cursor_line()
    if devicons.enabled then
      path = string.match(path, "^.*  (.*)$")
    end
    vim.cmd.edit(path)
    if Path:new(path):is_dir() then
      vim.api.nvim_buf_set_option(0, "filetype", "firvish")
    end
  end, { buffer = true, desc = "Open file under cursor" })
end

---@param path Path
local function init(path)
  vim.api.nvim_buf_set_name(0, tostring(path))
  set_bufferstate(path)
  set_lines()
  set_keymaps()
end

local M = {}

function M.setup()
  vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
      state.cwd = Path:new(vim.loop.cwd())
    end,
  })

  vim.keymap.set("n", "-", M.up, { desc = "Open parent directory" })
end

function M.init()
  local name = vim.fn.expand "%:p"
  local path = Path:new(name)
  if name ~= "" and path:is_dir() then
    init(path)
  end
end

function M.up()
  local name = vim.fn.expand "%:p"
  if name ~= "" then
    local path = Path:new(name)
    vim.cmd.edit(tostring(path:parent()))
    vim.api.nvim_buf_set_option(0, "filetype", "firvish")
  else
    print "[firvish.nvim] error: no parent to open"
  end
end

return M
