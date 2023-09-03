local _local_1_ = require("ai-assistant.types")
local Message = _local_1_["Message"]
local MessageState = _local_1_["MessageState"]
local Role = _local_1_["Role"]
local _local_2_ = require("ai-assistant.window")
local set_lines = _local_2_["set-lines"]
local list = require("ai-assistant.list")
local log = require("ai-assistant.log")
local marker_ns = vim.api.nvim_create_namespace("marker")
vim.api.nvim_command("hi AiAssistantState_sending guifg=orange")
vim.api.nvim_command("hi AiAssistantState_failed guifg=red")
local function state_marker(bufnr, state, line, id)
  return vim.api.nvim_buf_set_extmark(bufnr, marker_ns, line, 0, {id = id, virt_text = {{state, ("AiAssistantState_" .. state)}}, virt_text_pos = "eol"})
end
local function break_line(line)
  local function impl(line0, ret)
    if (#line0 <= 100) then
      table.insert(ret, line0)
      return ret
    else
      local sub = string.sub(line0, 1, 100)
      local rest = string.sub(line0, 101)
      local function _3_()
        table.insert(ret, sub)
        return ret
      end
      return impl(rest, _3_())
    end
  end
  return impl(line, {})
end
local function wrap_virt_lines(error)
  local lines = vim.split(error, "\n")
  local virt_liens = {}
  for _, line in ipairs(lines) do
    if (#line < 100) then
      table.insert(virt_liens, {{line, "AiAssistantState_failed"}})
    else
      for _0, line0 in ipairs(break_line(line)) do
        table.insert(virt_liens, {{line0, "AiAssistantState_failed"}})
      end
    end
  end
  return virt_liens
end
local function error_marker(bufnr, error, line)
  return vim.api.nvim_buf_set_extmark(bufnr, marker_ns, line, 0, {virt_lines = wrap_virt_lines(error)})
end
local function body_lines(message)
  local start = (1 + message["start-line"])
  local _end = (message["start-line"] + #message.content)
  return {start, _end}
end
local function end_line(message)
  local _let_6_ = body_lines(message)
  local _end = _let_6_[1]
  return _end
end
local function update_message_state(win, message)
  local _7_
  if (message.state == "sent") then
    _7_ = ""
  else
    _7_ = message.state
  end
  message["header-marker-id"] = state_marker(win["get-bufnr"](), _7_, message["start-line"], message["header-marker-id"])
  return nil
end
local function show_message_header(win, message)
  local _9_
  if (message.role == "user") then
    _9_ = {"\240\159\145\168[Me]"}
  else
    _9_ = {"\240\159\164\150[AI]"}
  end
  set_lines(win, _9_, message["start-line"], (1 + message["start-line"]))
  return update_message_state(win, message)
end
local function show_message_body(win, message)
  return set_lines(win, message.content, unpack(body_lines(message)))
end
local function to_renderable_message(message, start_line)
  local content = vim.split(message.content, "\n")
  table.insert(content, "")
  return {["start-line"] = start_line, content = content, id = message.id, role = message.role, state = message.state}
end
local function show_message(win, message)
  show_message_header(win, message)
  return show_message_body(win, message)
end
local function make_render(win, messages)
  local messages0
  do
    local msgs = {}
    for i = 1, #messages do
      local previous = msgs[(i - 1)]
      local function _12_()
        if previous then
          return body_lines(previous)
        else
          return {0, -1}
        end
      end
      local _let_11_ = _12_()
      local _ = _let_11_[1]
      local end_line0 = _let_11_[2]
      local start_line = (end_line0 + 1)
      table.insert(msgs, to_renderable_message(messages[i], start_line))
    end
    messages0 = msgs
  end
  for _, m in ipairs(messages0) do
    show_message(win, m)
  end
  local function _13_(msg)
    local last = (messages0)[#messages0]
    local function _15_()
      if last then
        return body_lines(last)
      else
        return {0, -1}
      end
    end
    local _let_14_ = _15_()
    local _ = _let_14_[1]
    local end_line0 = _let_14_[2]
    local start_line = (end_line0 + 1)
    local msg0 = to_renderable_message(msg, start_line)
    table.insert(messages0, msg0)
    return show_message(win, msg0)
  end
  local function _16_(msg)
    local m
    local function _17_(_241)
      return _241
    end
    local function _18_(_241)
      return (_241.id == msg.id)
    end
    m = list.first(messages0, _17_, _18_)
    if m then
      m["state"] = msg.state
      m["error"] = msg.error
      if m.error then
        error_marker(win["get-bufnr"](), m.error, end_line(m))
      else
      end
      return update_message_state(win, m)
    else
      return nil
    end
  end
  return {add = _13_, update = _16_}
end
return {["make-render"] = make_render}
