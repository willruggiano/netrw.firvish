local t = setmetatable({}, {
  __index = function(t, name)
    local bufnr = tostring(vim.api.nvim_get_current_buf())
    local bs = rawget(t, bufnr)
    if bs == nil then
      bs = {}
      rawset(t, bufnr, bs)
    end
    return bs[name]
  end,
  __newindex = function(t, name, value)
    local bufnr = tostring(vim.api.nvim_get_current_buf())
    local bs = rawget(t, bufnr)
    if bs == nil then
      bs = {}
      rawset(t, bufnr, bs)
    end
    bs[name] = value
  end,
})

return t
