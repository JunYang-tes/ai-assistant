local profiles = require("ai-assistant.profiles")
local _local_1_ = require("ai-assistant.options")
local options = _local_1_["options"]
local _local_2_ = require("ai-assistant.sessions.session-manager")
local session_manager = _local_2_["session-manager"]
local create_openai_session = require("ai-assistant.sessions.openai")
local managers = {openai = session_manager(create_openai_session)}
local async = require("plenary.async")
local _local_3_ = require("ai-assistant.chats-render")
local make_render = _local_3_["make-render"]
local log = require("ai-assistant.log")
local function get_ui(name)
  if (name == "floating") then
    local floating = require("ai-assistant.floating-ui")
    return floating["make-floating"]()
  else
    return nil
  end
end
local function run_profile(profile)
  local manager = managers[options.provider]
  local ui = get_ui(options.ui)
  local session = manager["get-session"]({profile = profile, ["openai-model"] = options["openai-model"]})
  local chats = ui["get-chars-win"]()
  local chats_render = make_render(chats, session["get-messages"]())
  local function _5_()
    local function _6_(msg)
      local function _7_()
        return chats_render.add(msg)
      end
      return vim.schedule(_7_)
    end
    local function _8_(msg)
      local function _9_()
        return chats_render.update(msg)
      end
      return vim.schedule(_9_)
    end
    session["set-handlers"](_6_, _8_)
    session["update-profile"]()
    local function _10_(content)
      local function _11_()
        return session["send-message"](content)
      end
      return async.run(_11_)
    end
    return ui["on-submit"](_10_)
  end
  return async.run(_5_)
end
local function run_with_buf(buf, profile)
  local profile0
  if profiles["is-profile"](profile) then
    profile0 = profile
  else
    profile0 = profiles["buffer-related-profiles"](profile, buf)
  end
  return run_profile(profile0)
end
local function run_general()
  return run_profile(profiles["buffer-independent-profiles"]("general", "global-chat"))
end
return {["run-with-buf"] = run_with_buf, ["run-general"] = run_general}
