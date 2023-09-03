local log = require("ai-assistant.log")
local list = require("ai-assistant.list")
local function role_setting(buffer)
  local filtetype = "TODO"
  local content = table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false))
  local filename = vim.api.nvim_buf_get_name(buffer)
  return ("You are a skilled programmer and you are pairing programming with a person named Blob \n" .. "Currently editing file name is " .. filename .. "The file content is quoted by \"---begein---\" and \"---end---\",see below\n" .. "---begin---\n" .. content .. "---end---\n" .. "Blob will ask you to write some code, you should reply code directly without explaination unless " .. "you are asked to explain.\n" .. "Please use markdown format to write your code.\n")
end
local function create_session(ctx, buffer)
  return ctx.provider["create-session"]({["role-setting"] = role_setting(buffer)})
end
local function get_session(ctx, buffer)
  local session = ctx.sessions[buffer]
  if (nil == session) then
    local session0 = create_session(ctx, buffer)
    do end (ctx.sessions)[buffer] = session0
    return session0
  else
    return session
  end
end
local function convert_to_message(ctx, provider_message)
  return {state = provider_message.state, id = provider_message.id, error = provider_message.error, role = provider_message.role, content = ctx.provider["get-message-content"](provider_message)}
end
local function get_messages(ctx, session)
  local function _2_(msg)
    return convert_to_message(ctx, msg)
  end
  return list.map(ctx.provider["filter-message"](session), _2_)
end
local function send_message(ctx, session, message)
  return ctx.provider["send-message"](session, message)
end
local function set_handlers(ctx, session, new, update)
  local function _3_(msg)
    return new(convert_to_message(ctx, msg))
  end
  session["on-new-message"] = _3_
  local function _4_(msg)
    return update(convert_to_message(ctx, msg))
  end
  session["on-message-change"] = _4_
  return nil
end
return {["get-session"] = get_session, ["get-messages"] = get_messages, ["set-handlers"] = set_handlers, ["send-message"] = send_message}
