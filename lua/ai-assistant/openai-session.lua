local _local_1_ = require("ai-assistant.options")
local options = _local_1_["options"]
local _local_2_ = require("ai-assistant.openai")
local completion = _local_2_["completion"]
local list = require("ai-assistant.list")
local log = require("ai-assistant.log")
local function create_session(_3_)
  local _arg_4_ = _3_
  local role_setting = _arg_4_["role-setting"]
  return {messages = {{state = "sent", data = {role = "system", content = role_setting}}}, model = options["openai-model"]}
end
local function send_message(session, message)
  local msg = {state = "sending", error = nil, data = {role = "user", content = message}}
  table.insert(session.messages, msg)
  session["notify-message-change"]()
  log.warn("Messages", session)
  local resp
  local function _5_(_241)
    return (_241).data
  end
  resp = completion({model = session.model, messages = list.map(session.messages, _5_)})
  local _6_
  do
    local v_1_auto = resp
    _6_ = ((type(v_1_auto) == "table") and ((v_1_auto).__ether__ == true) and ((v_1_auto).kind == "ok"))
  end
  if _6_ then
    msg["state"] = "sent"
    table.insert(session.messages, {state = "sent", data = {role = "assistant", content = resp.value.choices[1].message.content}})
  else
    msg["error"] = resp.message
    msg["state"] = "failed"
  end
  return session["notify-message-change"]()
end
local function get_message_content(msg)
  return msg.data.content
end
local function filter_message(session)
  local function _9_(_241)
    return ((_241).data.role ~= "system")
  end
  return list.filter(session.messages, _9_)
end
return {["create-session"] = create_session, ["get-message-content"] = get_message_content, ["filter-message"] = filter_message, ["send-message"] = send_message}
