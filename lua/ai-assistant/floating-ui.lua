local _local_1_ = require("ai-assistant.window")
local float = _local_1_["float"]
local markdown = _local_1_["markdown"]
local get_content = _local_1_["get-content"]
local get_editor_size = _local_1_["get-editor-size"]
local close = _local_1_["close"]
local winopt = _local_1_["winopt"]
local set_title = _local_1_["set-title"]
local buf_keymap = _local_1_["buf-keymap"]
local set_lines = _local_1_["set-lines"]
local function make_floating()
  local _let_2_ = get_editor_size()
  local editor_width = _let_2_[1]
  local editor_height = _let_2_[2]
  local width = math.floor((0.8 * editor_width))
  local height = math.floor((0.8 * editor_height))
  local input_height = 5
  local chats_height = (height - input_height)
  local row = math.floor(((editor_height - height) / 2))
  local col = math.floor(((editor_width - width) / 2))
  local chats = float({width = width, height = chats_height, row = row, col = col, title = "Chats", border = "single", relative = "editor"}, true)
  local input = float({width = width, height = input_height, row = (row + chats_height + 2), title = "Input(Send:Shift Enter)", border = "single", col = col, relative = "editor"})
  local input_winid = input["get-winid"]()
  local chats_winid = chats["get-winid"]()
  local function _3_()
    close(input)
    return close(chats)
  end
  vim.api.nvim_create_autocmd("WinClosed", {pattern = {tostring(chats_winid), tostring(input_winid)}, once = true, callback = _3_})
  local function _4_()
    return close(chats)
  end
  local function _5_()
    return vim.api.nvim_set_current_win(input["get-winid"]())
  end
  winopt(buf_keymap(buf_keymap(markdown(chats, {}), "n", "<esc>", _4_), "n", "<c-j>", _5_), {wrap = true})
  local function _6_()
    return close(input)
  end
  local function _7_()
    return vim.api.nvim_set_current_win(chats["get-winid"]())
  end
  buf_keymap(buf_keymap(winopt(input, {wrap = true}), "n", "<esc>", _6_), {"n", "i"}, "<c-k>", _7_)
  vim.api.nvim_set_current_win(input["get-winid"]())
  local function _8_(content)
    if not chats.closed then
      return set_lines(chats, content)
    else
      return nil
    end
  end
  local function _10_(title)
    return set_title(chats, title)
  end
  local function _11_()
    return chats
  end
  local function _12_(cb)
    local function _13_()
      local content = get_content(input)
      set_lines(input, {})
      return cb(content)
    end
    return buf_keymap(input, {"n", "i"}, "<s-cr>", _13_)
  end
  return {update = _8_, ["update-title"] = _10_, ["get-chars-win"] = _11_, ["on-submit"] = _12_}
end
return {["make-floating"] = make_floating}
