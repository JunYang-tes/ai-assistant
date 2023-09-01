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
local function get_messages(ctx, session)
  local function _2_(msg)
    return {state = msg.state, content = ctx.provider["get-message-content"](msg)}
  end
  return list.map(ctx.provider["filter-message"](session), _2_)
end
local function send_message(ctx, session, message)
  return ctx.provider["send-message"](session, message)
end
return {["get-session"] = get_session, ["get-messages"] = get_messages, ["send-message"] = send_message}
