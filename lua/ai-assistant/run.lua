local async = require("plenary.async")
local list = require("ai-assistant.list")
local _local_1_ = require("ai-assistant.options")
local options = _local_1_["options"]
local floating = require("ai-assistant.floating-ui")
local _local_2_ = require("ai-assistant.session")
local get_session = _local_2_["get-session"]
local get_messages = _local_2_["get-messages"]
local send_message = _local_2_["send-message"]
local log = require("ai-assistant.log")
local function get_context(ctx_name)
  if (ctx_name == "openai") then
    local openai_provider = require("ai-assistant.openai-session")
    local openai_context = {sessions = {}, provider = openai_provider}
    return openai_context
  else
    return nil
  end
end
local function get_ui(name)
  if (name == "floating") then
    local floating0 = require("ai-assistant.floating-ui")
    return floating0["make-floating"]()
  else
    return nil
  end
end
local function run(buf)
  local function _5_()
    print(vim.inspect(options))
    local ui = get_ui(options.ui)
    local ctx = get_context(options.context)
    local session = get_session(ctx, buf)
    local function _6_()
      local messages = get_messages(ctx, session)
      local function _7_()
        local function _8_(_2410)
          return (_2410).content
        end
        return ui.update(list.map(messages, _8_))
      end
      return vim.schedule(_7_)
    end
    session["notify-message-change"] = _6_
    local function _9_(content)
      local function _10_()
        return send_message(ctx, session, content)
      end
      return async.run(_10_)
    end
    return ui["on-submit"](_9_)
  end
  return async.run(_5_)
end
return run
