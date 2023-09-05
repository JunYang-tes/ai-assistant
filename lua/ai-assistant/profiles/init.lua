local pair_programmer = require("ai-assistant.profiles.pair-programmer")
local general = require("ai-assistant.profiles.general")
local function profile(kind)
  local profiles = {}
  local function _1_(name, bufnr)
    local p = profiles[bufnr]
    if not p then
      local p0 = kind[name](bufnr)
      do end (profiles)[bufnr] = p0
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
return {["buffer-related-profiles"] = profile({["pair-programmer"] = pair_programmer}), ["buffer-independent-profiles"] = profile({general = general}), ["is-profile"] = is_profile}
