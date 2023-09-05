local _local_1_ = require("ai-assistant.types")
local Profile = _local_1_["Profile"]
local _local_2_ = require("ai-assistant.type-hint")
local Fn = _local_2_["Fn"]
local List = _local_2_["List"]
local Number = _local_2_["Nil"]
local Number0 = _local_2_["Number"]
local OneOf = _local_2_["OneOf"]
local String = _local_2_["String"]
local Table = _local_2_["Table"]
local Bufnr = Number0
local CreateProfile = Fn({Bufnr}, Profile)
local function profile_content(buffer)
  local filtetype = "TODO"
  local filename = vim.api.nvim_buf_get_name(buffer)
  return ("You are a skilled programmer and you are pairing programming with me.\n" .. "Currently editing file name is " .. filename .. "\n." .. "The file content is quoted by \"---begein---\" and \"---end---\"\n" .. "I will ask you to write some code, you should reply code directly without explaination unless " .. "you are asked to explain.\n" .. "Please use markdown format to write your code.\n")
end
local function create_profile(bufnr)
  local function init()
    return profile_content(bufnr)
  end
  local function update()
    local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    return ("The lastest file content is \n" .. "---begin---\n" .. content .. "\n---end---\n")
  end
  return {init = init, update = update}
end
return create_profile
