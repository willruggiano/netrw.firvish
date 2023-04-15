---@mod netrw-firvish
---@brief [[
---This is a template for a firvish.nvim lua plugin.
---@brief ]]

---@package
local Extension = {}
Extension.__index = Extension

---@package
Extension.bufname = "firvish://netrw"

---@package
function Extension.new()
  assert(false, "you must implement this")
end

---@package
function Extension:on_buf_enter(buffer)
  assert(false, "you must implement this")
end

---@package
function Extension:on_buf_write_cmd(buffer)
  assert(false, "implement this if your plugin uses a buffer of type 'acwrite'")
end

---@package
function Extension:on_buf_write_post(buffer)
  assert(false, "implement this if your plugin uses a buffer of type 'acwrite'")
end

---@package
function Extension:update(buffer, args)
  assert(false, "implement this if your plugin should be runnable via :Firvish <plugin>")
end

---@package
local M = {}

---@package
function M.setup()
  require("firvish").register_extension("netrw", Extension.new())
end

return M
