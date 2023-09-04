local async = require("plenary.async")
local list = require("ai-assistant.list")
local _local_1_ = require("ai-assistant.options")
local options = _local_1_["options"]
local floating = require("ai-assistant.floating-ui")
local _local_2_ = require("ai-assistant.session")
local get_session = _local_2_["get-session"]
local get_messages = _local_2_["get-messages"]
local set_handlers = _local_2_["set-handlers"]
local send_message = _local_2_["send-message"]
local _local_3_ = require("ai-assistant.chats-render")
local make_render = _local_3_["make-render"]
local log = require("ai-assistant.log")
local running_context = {}
local function create_context(ctx_name)
  if (ctx_name == "openai") then
    local openai_provider = require("ai-assistant.openai-session")
    local openai_context = {sessions = {}, provider = openai_provider}
    return openai_context
  else
    return nil
  end
end
local function get_context(ctx_name)
  local ctx = (running_context[ctx_name] or create_context(ctx_name))
  do end (running_context)[ctx_name] = ctx
  return ctx
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
  local function _6_()
    local ui = get_ui(options.ui)
    local ctx = get_context(options.context)
    local session = get_session(ctx, buf)
    local chats = ui["get-chars-win"]()
    local chats_render = make_render(chats, get_messages(ctx, session))
    local function _7_(new)
      local function _8_()
        return chats_render.add(new)
      end
      return vim.schedule(_8_)
    end
    local function _9_(updated)
      local function _10_()
        return chats_render.update(updated)
      end
      return vim.schedule(_10_)
    end
    set_handlers(ctx, session, _7_, _9_)
    local function _11_(content)
      local function _12_()
        return send_message(ctx, session, content)
      end
      return async.run(_12_)
    end
    return ui["on-submit"](_11_)
  end
  return async.run(_6_)
end
return run
