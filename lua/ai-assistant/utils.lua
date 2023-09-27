local function get_buf_content()
end
local function get_buf_content0(bufnr)
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
end
return {["get-buf-content"] = get_buf_content0}
