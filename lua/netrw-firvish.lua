---@mod netrw-firvish
---@brief [[
---|netrw| replacement implemented as a firvish.nvim plugin.
---@brief ]]

local Path = require "plenary.path"

local actions = require "netrw-firvish.actions"
local devicons = require "netrw-firvish.devicons"

---@package
local Extension = {}
Extension.__index = Extension

---@package
Extension.bufname = "firvish://netrw"

---@package
Extension.config = {
  -- classify = true,
  devicons = devicons.setup(),
  remove_file = actions.delete,
  show_hidden = false,
}

---@package
Extension.state = {
  cwd = Path:new(vim.loop.cwd()),
}

local function pattern()
  if Extension.config.devicons then
    return "^.*  (.*)$"
  else
    return "^(.*)$"
  end
end

local function reconstruct(line)
  local match = string.match(line, pattern())
  if match ~= nil then
    return match
  else
    error("Failed to parse line: '" .. line .. "'")
  end
end

local function file_from_line(line)
  local filename = reconstruct(line)
  return Extension.state.cwd / filename
end

local function file_at_cursor()
  local line = require("firvish.lib").get_cursor_line()
  return file_from_line(line)
end

---@package
function Extension.new(opts)
  Extension.config = vim.tbl_deep_extend("force", Extension.config, opts)

  local obj = {}

  obj.keymaps = {
    n = {
      ["-"] = {
        callback = function()
          Extension.state.cwd = Extension.state.cwd:parent()
          vim.cmd.edit()
        end,
        desc = "Go to parent directory",
      },
      ["<CR>"] = {
        callback = function()
          local file = file_at_cursor()
          if file:is_dir() then
            Extension.state.cwd = file
            vim.cmd.edit()
          else
            vim.cmd.edit(tostring(file))
          end
        end,
        desc = "Open file or directory",
      },
      ["."] = {
        callback = function()
          Extension.config.show_hidden = not Extension.config.show_hidden
          vim.cmd.edit()
        end,
        desc = "Toggle hidden files",
      },
    },
  }
  obj.options = {
    bufhidden = "hide",
    filetype = "firvish",
  }

  return setmetatable(obj, Extension)
end

local Job = require "firvish.types.job"
local function ls_files(pattern, show_hidden)
  local files = {}
  local cwd = Extension.state.cwd
  local job = Job.new(0, {
    command = "fd",
    args = { "--color", "never", "--maxdepth", "1" },
    cwd = tostring(cwd),
    on_start = function() end,
    on_exit = function() end,
    on_stdout = function(_, data)
      table.insert(files, Path:new(data))
    end,
  })
  job:sync()
  return files
end

local function reconstruct_from_buffer(buffer)
  local files = {}
  for _, line in ipairs(buffer:get_lines()) do
    table.insert(files, file_from_line(line))
  end
  return files
end

local function compute_difference(current, desired)
  return vim.tbl_filter(function(maybe_delete)
    for _, keep in ipairs(desired) do
      if maybe_delete:normalize(Extension.config.cwd) == keep:normalize(Extension.config.cwd) then
        return false
      end
    end
    return true
  end, current)
end

local namespace = vim.api.nvim_create_namespace "netrw-firvish"

local function set_lines(buffer, pattern, show_hidden)
  local lines = {}
  local highlights = {}
  for _, file in ipairs(ls_files()) do
    if Extension.config.devicons then
      local icon, higroup = devicons.get_icon(Extension.state.cwd / file)
      table.insert(lines, icon .. "  " .. file.filename)
      table.insert(highlights, higroup)
    else
      table.insert(lines, file.filename)
    end
  end
  buffer:set_lines(lines)
  for i, higroup in ipairs(highlights) do
    devicons.add_highlight(buffer, namespace, i, higroup)
  end
  buffer.opt.modified = false
end

local function delete_file(path)
  if vim.fn.confirm("Delete?: " .. path.filename, "&Yes\n&No", 1) ~= 1 then
    return
  end
  Extension.config.remove_file(path)
end

---@package
function Extension:on_buf_enter(buffer)
  set_lines(buffer)
end

---@package
function Extension:on_buf_write_cmd(buffer)
  local current = ls_files()
  local desired = reconstruct_from_buffer(buffer)
  local diff = compute_difference(current, desired)
  for _, file in ipairs(diff) do
    delete_file(file)
  end
  buffer.opt.modified = false
end

---@package
function Extension:on_buf_write_post(buffer)
  set_lines(buffer)
end

---@package
function Extension:update(buffer, args)
  Extension.config.filter = args.fargs[2]
  Extension.config.show_hidden = args.bang
  set_lines(buffer, args.fargs[2], args.bang)
end

---@package
local M = {}

---@package
function M.setup(opts)
  require("firvish").register_extension("netrw", Extension.new(opts or {}))

  vim.keymap.set("n", "-", function()
    vim.cmd.edit(Extension.bufname)
  end, { desc = "File explorer" })
end

return M
