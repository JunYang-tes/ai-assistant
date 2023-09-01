local _local_1_ = require("ai-assistant.type-hint")
local String = _local_1_["String"]
local Number = _local_1_["Number"]
local OneOf = _local_1_["OneOf"]
local List = _local_1_["List"]
local Any = _local_1_["Any"]
local Map = _local_1_["Map"]
local Fn = _local_1_["Fn"]
local Void = _local_1_["Void"]
local Table = _local_1_["Table"]
local Message = Table({"state", String, "content", String})
local Session = Table({"messages", List(Message), "mode", String})
local Provider
local function _2_(SessionImpl, MessageImpl)
  return Table({"send-message", Fn({SessionImpl}, Void), "filter-message", Fn({SessionImpl}, List(MessageImpl)), "get-message-content", Fn({MessageImpl}, String), "create-session", Fn({Table({"role-setting", String}, SessionImpl)})})
end
Provider = _2_
local Context
local function _3_(SessionImpl, MessageImpl)
  return Table({"sessions", Map(Number, SessionImpl), "provider", Provider(SessionImpl, MessageImpl)})
end
Context = _3_
return {Message = Message, Session = Session, Provider = Provider, Context = Context}
