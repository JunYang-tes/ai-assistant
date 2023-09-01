local list = require("ai-assistant.list")
local function float(float_opt, enter)
  vim.validate({float_opt = {float_opt, "t", true}})
  local bufnr = (float_opt.bufnr or vim.api.nvim_create_buf(false, false))
  local winid = vim.api.nvim_open_win(bufnr, enter, float_opt)
  local function _1_()
    return bufnr
  end
  local function _2_()
    return winid
  end
  return {["get-bufnr"] = _1_, ["get-winid"] = _2_, closed = false}
end
local function normal(direct, bufnr)
  local split_below = vim.opt.splitbelow
  local bufnr0 = (bufnr or vim.api.nvim_create_buf(false, false))
  do end (vim.opt)["splitbelow"] = true
  vim.cmd[direct]("new")
  do end (vim.opt)["splitbelow"] = split_below
  local winid = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(winid, bufnr0)
  local function _3_()
    return bufnr0
  end
  local function _4_()
    return winid
  end
  return {["get-bufnr"] = _3_, ["get-winid"] = _4_}
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
  return table.concat(vim.api.nvim_buf_get_lines(win["get-bufnr"](), 0, -1, false))
end
local function get_editor_size()
  local wins = vim.api.nvim_list_wins()
  local size
  local function _5_(winid)
    local _let_6_ = vim.api.nvim_win_get_position(winid)
    local row = _let_6_[1]
    local col = _let_6_[2]
    local width = vim.api.nvim_win_get_width(winid)
    local height = vim.api.nvim_win_get_height(winid)
    return {(width + col), (height + row)}
  end
  size = list.map(wins, _5_)
  local function _7_(_241, _242)
    local _let_8_ = _241
    local w = _let_8_[1]
    local h = _let_8_[2]
    local _let_9_ = _242
    local mw = _let_9_[1]
    local mh = _let_9_[2]
    return {math.max(w, mw), math.max(h, mh)}
  end
  return list.reduce(size, _7_, {0, 0})
end
local function demo()
  return markdown(float({width = 50, height = 10, row = 10, col = 10, relative = "editor"}, true), {"```typescript", "function hello(){", "\9console.log()", "}", "```"})
end
local function close(win)
  win["closed"] = true
  return vim.api.nvim_win_close(win["get-winid"](), true)
end
return {float = float, ["get-content"] = get_content, close = close, demo = demo, highlight = highlight, normal = normal, bufopt = bufopt, winopt = winopt, ["buf-keymap"] = buf_keymap, ["get-editor-size"] = get_editor_size, markdown = markdown, ["set-lines"] = set_lines, ["set-height"] = set_height, ["set-width"] = set_width}
