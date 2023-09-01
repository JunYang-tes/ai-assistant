local async = require("plenary.async")
local curl = require("plenary.curl")
local _local_1_ = require("ai-assistant.http-utils")
local json = _local_1_["json"]
local event = _local_1_["event"]
local log = require("ai-assistant.log")
local User_Agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
local function make_url(path)
  return ("https://claude.ai" .. path)
end
local function cookie(session_key)
  return string.format("sessionKey=%s", session_key)
end
local get_organizations
local function _2_(session_key, callback)
  return curl.get({url = make_url("/api/organizations"), headers = {accept = "application/json", ["User-Agent"] = User_Agent, cookie = cookie(session_key)}, callback = json(callback)})
end
get_organizations = async.wrap(_2_, 2)
local get_conversations
local function _3_(session_key, id, callback)
  return curl.get({url = make_url(string.format("/api/organizations/%s/chat_conversations", id)), headers = {accept = "application/json", ["User-Agent"] = User_Agent, cookie = cookie(session_key)}, callback = json(callback)})
end
get_conversations = async.wrap(_3_, 3)
local get_conversation
local function _6_(_4_, callback)
  local _arg_5_ = _4_
  local session_key = _arg_5_["session-key"]
  local org_id = _arg_5_["org-id"]
  local conversation_id = _arg_5_["conversation-id"]
  return curl.get({url = make_url(string.format("/api/organizations/%s/chat_conversations/%s", org_id, conversation_id)), headers = {accept = "application/json", ["User-Agent"] = User_Agent, cookie = cookie(session_key)}, callback = json(callback)})
end
get_conversation = async.wrap(_6_, 2)
local send_message
local function _9_(_7_, callback)
  local _arg_8_ = _7_
  local session_key = _arg_8_["session-key"]
  local message = _arg_8_["message"]
  local org_id = _arg_8_["org-id"]
  local attachments = _arg_8_["attachments"]
  local model = _arg_8_["model"]
  local conversation_id = _arg_8_["conversation-id"]
  return curl.post({url = make_url("/api/append_message"), headers = {["content-type"] = "application/json", ["User-Agent"] = User_Agent, accept = "text/event-stream, text/event-stream", cookie = cookie(session_key)}, body = vim.json.encode({organization_uuid = org_id, conversation_uuid = conversation_id, attachments = (attachments or {}), text = message, completion = {prompt = message, model = (model or "claude-2"), incremental = false}}), callback = event(callback)})
end
send_message = async.wrap(_9_, 2)
return {["get-organizations"] = get_organizations, ["get-conversations"] = get_conversations, ["get-conversation"] = get_conversation, ["send-message"] = send_message, modles = {"claude-2", "claude-1.3", "claude-instant", "claude-instant-100k"}}
