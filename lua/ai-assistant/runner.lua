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
local cmds = require("ai-assistant.cmds")
local inspect = require("inspect")
local function get_ui(name)
  if (name == "floating") then
    local floating = require("ai-assistant.floating-ui")
    return floating["make-floating"]()
  else
    return nil
  end
end
local function get_modal()
  return options[(options.provider .. "-" .. "model")]
end
local function run_profile(profile)
  local manager = managers[options.provider]
  local ui = get_ui(options.ui)
  local session = manager["get-session"]({profile = profile, model = get_modal()})
  local chats = ui["get-chars-win"]()
  local chats_render = make_render(chats, session["get-messages"]())
  local function _5_()
    local t_6_ = profile
    if (nil ~= t_6_) then
      t_6_ = (t_6_).name
    else
    end
    return t_6_
  end
  ui["update-title"](((_5_() or "Chats") .. "(" .. session.name .. "/" .. session.model() .. ")"))
  local function _8_()
    local function _9_(msg)
      local function _10_()
        return chats_render.add(msg)
      end
      return vim.schedule(_10_)
    end
    local function _11_(msg)
      local function _12_()
        return chats_render.update(msg)
      end
      return vim.schedule(_12_)
    end
    session["set-handlers"](_9_, _11_)
    session["update-profile"]()
    local function _13_(content)
      if cmds["is-cmd"](content) then
        local function _14_()
          chats_render.clear()
          return session.clear()
        end
        local function _15_(_241)
          return session.model(_241)
        end
        return cmds.execute(content, {clear = _14_, model = _15_})
      else
        local function _16_()
          return session["send-message"](content)
        end
        return async.run(_16_)
      end
    end
    return ui["on-submit"](_13_)
  end
  return async.run(_8_)
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
  return run_profile(profiles["buffer-independent-profiles"]("general", "general"))
end
local function run_translator()
  return run_profile(profiles["buffer-independent-profiles"]("translator", "translator"))
end
local function run_without_buf(profile)
  return run_profile(profiles["buffer-independent-profiles"](profile, profile))
end
return {["run-with-buf"] = run_with_buf, ["run-general"] = run_general, ["run-translator"] = run_translator, ["run-without-buf"] = run_without_buf, ["run-profile"] = run_profile}
