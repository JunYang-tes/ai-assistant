local list = require("ai-assistant.list")
local _local_1_ = require("ai-assistant.utils")
local get_buf_content = _local_1_["get-buf-content"]
local function float(float_opt, enter)
  vim.validate({float_opt = {float_opt, "t", true}})
  local bufnr = (float_opt.bufnr or vim.api.nvim_create_buf(false, false))
  local winid = vim.api.nvim_open_win(bufnr, enter, float_opt)
  local function _2_()
    return bufnr
  end
  local function _3_()
    return winid
  end
  return {["get-bufnr"] = _2_, ["get-winid"] = _3_, closed = false}
end
local function normal(direct, bufnr)
  local split_below = vim.opt.splitbelow
  local bufnr0 = (bufnr or vim.api.nvim_create_buf(false, false))
  do end (vim.opt)["splitbelow"] = true
  vim.cmd[direct]("new")
  do end (vim.opt)["splitbelow"] = split_below
  local winid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(winid, bufnr0)
  local function _4_()
    return bufnr0
  end
  local function _5_()
    return winid
  end
  return {["get-bufnr"] = _4_, ["get-winid"] = _5_}
end
local function bufopt(win, opt)
  local bufnr = win["get-bufnr"]()
  for key, val in pairs(opt) do
    vim.api.nvim_buf_set_option(bufnr, key, val)
  end
  return win
end
local function winopt(win, opt)
  local winid = win["get-winid"]()
  for key, val in pairs(opt) do
    vim.api.nvim_win_set_option(winid, key, val)
  end
  return win
end
local function set_win_config(win, config)
  local winid = win["get-winid"]()
  vim.api.nvim_win_set_config(winid, config)
  return win
end
local function set_title(win, title)
  return set_win_config(win, {title = title})
end
local function mul_lines(lines)
  local ls = {}
  for _, line in ipairs(lines) do
    local splited = vim.split(line, "\n")
    for _0, l in ipairs(splited) do
      table.insert(ls, l)
    end
  end
  return ls
end
local function set_lines(win, lines, start, _end)
  do
    local modifiable = vim.api.nvim_buf_get_option(win["get-bufnr"](), "modifiable")
    bufopt(win, {modifiable = true})
    vim.api.nvim_buf_set_lines(win["get-bufnr"](), (start or 0), (_end or -1), false, mul_lines(lines))
    bufopt(win, {modifiable = modifiable})
  end
  return win
end
local function highlight(win, normal0, border)
  vim.api.nvim_set_option_value("winhl", ("Normal:" .. normal0 .. ",FloatBorder" .. border), {scope = "local", win = win["get-winid"]()})
  return win
end
local function markdown(win, content, start, _end)
  return winopt(bufopt(set_lines(win, content, start, _end), {filetype = "markdown", buftype = "nofile", modifiable = false}), {conceallevel = 2, concealcursor = "niv"})
end
local function set_width(win, width)
  vim.api.nvim_win_set_width(win["get-winid"](), width)
  return width
end
local function set_height(win, height)
  vim.api.nvim_win_set_height(win["get-winid"](), height)
  return height
end
local function buf_keymap(win, mode, keys, cb)
  vim.keymap.set(mode, keys, cb, {buffer = win["get-bufnr"]()})
  return win
end
local function get_content(win)
  return get_buf_content(win["get-bufnr"]())
end
local function get_editor_size()
  local wins = vim.api.nvim_list_wins()
  local size
  local function _6_(winid)
    local _let_7_ = vim.api.nvim_win_get_position(winid)
    local row = _let_7_[1]
    local col = _let_7_[2]
    local width = vim.api.nvim_win_get_width(winid)
    local height = vim.api.nvim_win_get_height(winid)
    return {(width + col), (height + row)}
  end
  size = list.map(wins, _6_)
  local function _8_(_241, _242)
    local _let_9_ = _241
    local w = _let_9_[1]
    local h = _let_9_[2]
    local _let_10_ = _242
    local mw = _let_10_[1]
    local mh = _let_10_[2]
    return {math.max(w, mw), math.max(h, mh)}
  end
  return list.reduce(size, _8_, {0, 0})
end
local function demo()
  return markdown(float({width = 50, height = 10, row = 10, col = 10, relative = "editor"}, true), {"```typescript", "function hello(){", "\9console.log()", "}", "```"})
end
local function close(win)
  if not win.closed then
    win["closed"] = true
    vim.api.nvim_win_close(win["get-winid"](), true)
    return vim.api.nvim_buf_delete(win["get-bufnr"](), {force = true})
  else
    return nil
  end
end
local function clear(win)
  local bufnr = win["get-bufnr"]()
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  return set_lines(win, {}, 0, line_count)
end
return {float = float, ["get-content"] = get_content, close = close, demo = demo, highlight = highlight, clear = clear, normal = normal, bufopt = bufopt, winopt = winopt, ["buf-keymap"] = buf_keymap, ["get-editor-size"] = get_editor_size, markdown = markdown, ["set-win-config"] = set_win_config, ["set-title"] = set_title, ["set-lines"] = set_lines, ["set-height"] = set_height, ["set-width"] = set_width}
