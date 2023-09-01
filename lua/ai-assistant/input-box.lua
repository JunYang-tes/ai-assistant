local async = require("plenary.async")
local popup = require("plenary.popup")
local get_input
local function _1_(win_opts, callback)
  local win_id = popup.create({""}, (win_opts or {}))
  local buf = vim.api.nvim_win_get_buf(win_id)
  local function on_enter()
    vim.api.nvim_win_close(win_id, true)
    return callback(true, table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false)))
  end
  return vim.keymap.set("i", "<CR>", on_enter, {buffer = buf})
end
get_input = async.wrap(_1_, 2)
return {["get-input"] = get_input}
