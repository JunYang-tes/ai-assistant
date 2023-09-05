local list = require("ai-assistant.list")
local _local_1_ = require("ai-assistant.types")
local Profile = _local_1_["Profile"]
local Context = _local_1_["Context"]
local function session_manager(create_session)
  local sessions = {}
  local function get_session(_2_)
    local _arg_3_ = _2_
    local profile = _arg_3_["profile"]
    local opts = _arg_3_
    local session = sessions[profile]
    if not session then
      local session0 = create_session(opts)
      do end (sessions)[profile] = session0
      return session0
    else
      return session
    end
  end
  return {["get-session"] = get_session}
end
return {["session-manager"] = session_manager}
