local pair_programmer = require("ai-assistant.profiles.pair-programmer")
local swagger = require("ai-assistant.profiles.swagger")
local general = require("ai-assistant.profiles.general")
local translator = require("ai-assistant.profiles.translator")
local secretary = require("ai-assistant.profiles.secretary")
local function profile(kind)
  local profiles = {}
  local function _1_(name, bufnr)
    local p = profiles[bufnr]
    if not p then
      local p0 = kind[name](bufnr)
      do end (p0)["name"] = name
      profiles[bufnr] = p0
      return p0
    else
      return p
    end
  end
  return _1_
end
local function is_profile(obj)
  return ((type(obj) == "table") and (type(obj.init) == "function") and (type(obj.update) == "function"))
end
return {["buffer-related-profiles"] = profile({["pair-programmer"] = pair_programmer, swagger = swagger}), ["buffer-independent-profiles"] = profile({general = general, secretary = secretary, translator = translator}), ["is-profile"] = is_profile}
