local _local_1_ = require("ai-assistant.options")
local options = _local_1_["options"]
local _local_2_ = require("ai-assistant.openai")
local completion = _local_2_["completion"]
local list = require("ai-assistant.list")
local log = require("ai-assistant.log")
local function create(_3_)
  local _arg_4_ = _3_
  local profile = _arg_4_["profile"]
  local rest = (function (t, k, e) local mt = getmetatable(t) if 'table' == type(mt) and mt.__fennelrest then return mt.__fennelrest(t, k) elseif e then local rest = {} for k, v in pairs(t) do if not e[k] then rest[k] = v end end return rest else return {(table.unpack or unpack)(t, k)} end end)(_arg_4_, rest, {["profile"] = true})
  local init_profile = profile.init()
  local session
  local _5_
  if init_profile then
    _5_ = {{state = "sent", id = 0, data = {role = "system", content = profile.init()}}}
  else
    _5_ = {}
  end
  session = {messages = _5_}
  local model = (rest["openai-model"] or "gpt-3.5-turbo")
  local function get_message_content(msg)
    assert((nil ~= msg), "NIL")
    return msg.data.content
  end
  local function to_general_message(msg)
    assert((nil ~= msg), "No message")
    return {state = msg.state, id = msg.id, error = msg.error, role = msg.role, content = get_message_content(msg)}
  end
  local function get_messages()
    local function _7_(_241)
      return ((_241).data.role ~= "system")
    end
    return list.map(list.filter(session.messages, _7_), to_general_message)
  end
  local function emit_event(name, msg)
    local cb = session[name]
    return cb(to_general_message(msg))
  end
  local function send_message(text)
    local msg = {state = "sending", id = (1 + #session.messages), role = "user", error = nil, data = {role = "user", content = text}}
    table.insert(session.messages, msg)
    emit_event("on-new-message", msg)
    local resp
    local function _8_(_241)
      return (_241).data
    end
    resp = completion({model = model, messages = list.map(session.messages, _8_)})
    local _9_
    do
      local v_2_auto = resp
      _9_ = ((type(v_2_auto) == "table") and ((v_2_auto).__ether__ == true) and ((v_2_auto).kind == "ok"))
    end
    if _9_ then
      msg["state"] = "sent"
      emit_event("on-message-change", msg)
      local resp_msg = {state = "sent", role = "ai", id = (#session.messages + 1), data = {role = "assistant", content = resp.value.choices[1].message.content}}
      table.insert(session.messages, resp_msg)
      return emit_event("on-new-message", resp_msg)
    else
      msg["error"] = resp.message.message
      msg["state"] = "failed"
      return emit_event("on-message-change", msg)
    end
  end
  local function update_profile()
    local profile0 = profile.update()
    if profile0 then
      local message = {state = "sent", id = (#session.messages + 1), data = {role = "system", content = profile0}}
      table.insert(session.messages, message)
    else
    end
    return log.warn(session)
  end
  local function set_handlers(new, update)
    session["on-new-message"] = new
    session["on-message-change"] = update
    return nil
  end
  return {["get-messages"] = get_messages, name = "openai", ["set-handlers"] = set_handlers, ["update-profile"] = update_profile, ["send-message"] = send_message}
end
return create
