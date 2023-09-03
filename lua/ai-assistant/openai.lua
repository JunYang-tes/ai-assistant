local async = require("plenary.async")
local curl = require("plenary.curl")
local _local_1_ = require("ai-assistant.http-utils")
local json = _local_1_["json"]
local event = _local_1_["event"]
local log = require("ai-assistant.log")
local _local_2_ = require("ai-assistant.options")
local options = _local_2_["options"]
local completion
local function _5_(_3_, callback)
  local _arg_4_ = _3_
  local model = _arg_4_["model"]
  local messages = _arg_4_["messages"]
  local temperature = _arg_4_["temperature"]
  local top_p = _arg_4_["top_p"]
  local n = _arg_4_["n"]
  local function _6_(res)
    local function _10_()
      local res0 = res
      local _11_
      do
        local has_err_4_auto = true
        for __5_auto, _7_ in ipairs({res0}) do
          local _12_
          do
            local v_2_auto = _7_
            _12_ = ((type(v_2_auto) == "table") and ((v_2_auto).__ether__ == true) and ((v_2_auto).kind == "ok"))
          end
          if (((type(_7_) == "table") and ((_7_).__ether__ == true)) and not _12_) then
            has_err_4_auto = false
          else
          end
        end
        _11_ = has_err_4_auto
      end
      if _11_ then
        local res1
        local _15_
        do
          local v_2_auto = res0
          _15_ = ((type(v_2_auto) == "table") and ((v_2_auto).__ether__ == true) and ((v_2_auto).kind == "ok"))
        end
        if _15_ then
          res1 = (res0).value
        else
          res1 = res0
        end
        local _8_
        do
          if (nil == res1.error) then
            _8_ = res1
          else
            _8_ = {__ether__ = true, kind = "err", message = res1.error}
          end
        end
        local is_ether_3_auto
        do
          local v_1_auto = _8_
          is_ether_3_auto = ((type(v_1_auto) == "table") and ((v_1_auto).__ether__ == true))
        end
        if is_ether_3_auto then
          return _8_
        else
          return {__ether__ = true, kind = "ok", value = _8_}
        end
      else
        local fierst_err_6_auto = nil
        local i_7_auto = 1
        local done_8_auto = false
        while (i_7_auto <= #{res0}) do
          do
            local _9_ = ({res0})[i_7_auto]
            local _20_
            do
              local v_2_auto = _9_
              _20_ = ((type(v_2_auto) == "table") and ((v_2_auto).__ether__ == true) and ((v_2_auto).kind == "ok"))
            end
            if (((type(_9_) == "table") and ((_9_).__ether__ == true)) and not _20_) then
              fierst_err_6_auto = _9_
              i_7_auto = (#{res0} + 1)
            else
            end
          end
          i_7_auto = (i_7_auto + 1)
        end
        return fierst_err_6_auto
      end
    end
    return callback(_10_())
  end
  return curl.post({url = (options["openai-host"] .. "/v1/chat/completions"), headers = {Authorization = ("Bearer " .. options["openai-key"])}, body = vim.json.encode({model = model, messages = messages, temperature = temperature, top_p = top_p, n = n, stream = false}), callback = json(_6_)})
end
completion = async.wrap(_5_, 2)
return {completion = completion}
