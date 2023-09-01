local vim_log = require("vim.lsp.log")
local function log(level_name)
  local function _1_(...)
    local f = vim_log[level_name]
    return f("ai-assistant", ...)
  end
  return _1_
end
return {info = log("info"), error = log("error"), warn = log("warn")}
