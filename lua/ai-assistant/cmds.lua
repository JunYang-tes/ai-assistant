local list = require("ai-assistant.list")
local function is_cmd(content)
  return (string.sub(content, 1, 1) == "/")
end
local function execute(cmd, cmds)
  local cmd0
  local function _1_(_241)
    return vim.split(_241, "=")
  end
  cmd0 = list.map(vim.split(string.sub(cmd, 2), " "), _1_)
  for _, _2_ in ipairs(cmd0) do
    local _each_3_ = _2_
    local cmd1 = _each_3_[1]
    local val = _each_3_[2]
    local f = cmds[cmd1]
    if f then
      f(val)
    else
    end
  end
  return nil
end
return {["is-cmd"] = is_cmd, execute = execute}
