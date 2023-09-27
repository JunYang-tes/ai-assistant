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
  local function _6_()
    local body = vim.json.encode({model = model, messages = messages, temperature = temperature, top_p = top_p, n = n, stream = false})
    local body_path = os.tmpname()
    local _, fd = async.uv.fs_open(body_path, "w", 438)
    async.uv.fs_write(fd, body)
    async.uv.fs_close(fd)
    local function _7_(res)
      vim.loop.fs_unlink(body_path)
      local function _11_()
        local res0 = res
        local _12_
        do
          local has_err_4_auto = true
          for __5_auto, _8_ in ipairs({res0}) do
            local _13_
            do
              local v_2_auto = _8_
              _13_ = ((type(v_2_auto) == "table") and ((v_2_auto).__ether__ == true) and ((v_2_auto).kind == "ok"))
            end
            if (((type(_8_) == "table") and ((_8_).__ether__ == true)) and not _13_) then
              has_err_4_auto = false
            else
            end
          end
          _12_ = has_err_4_auto
        end
        if _12_ then
          local res1
          local _16_
          do
            local v_2_auto = res0
            _16_ = ((type(v_2_auto) == "table") and ((v_2_auto).__ether__ == true) and ((v_2_auto).kind == "ok"))
          end
          if _16_ then
            res1 = (res0).value
          else
            res1 = res0
          end
          local _9_
          do
            if (nil == res1.error) then
              _9_ = res1
            else
              _9_ = {__ether__ = true, kind = "err", message = res1.error}
            end
          end
          local is_ether_3_auto
          do
            local v_1_auto = _9_
            is_ether_3_auto = ((type(v_1_auto) == "table") and ((v_1_auto).__ether__ == true))
          end
          if is_ether_3_auto then
            return _9_
          else
            return {__ether__ = true, kind = "ok", value = _9_}
          end
        else
          local fierst_err_6_auto = nil
          local i_7_auto = 1
          local done_8_auto = false
          while (i_7_auto <= #{res0}) do
            do
              local _10_ = ({res0})[i_7_auto]
              local _21_
              do
                local v_2_auto = _10_
                _21_ = ((type(v_2_auto) == "table") and ((v_2_auto).__ether__ == true) and ((v_2_auto).kind == "ok"))
              end
              if (((type(_10_) == "table") and ((_10_).__ether__ == true)) and not _21_) then
                fierst_err_6_auto = _10_
                i_7_auto = (#{res0} + 1)
              else
              end
            end
            i_7_auto = (i_7_auto + 1)
          end
          return fierst_err_6_auto
        end
      end
      return callback(_11_())
    end
    return curl.post({url = (options["openai-host"] .. "/v1/chat/completions"), headers = {Authorization = ("Bearer " .. options["openai-key"])}, body = body_path, callback = json(_7_)})
  end
  return async.run(_6_)
end
completion = async.wrap(_5_, 2)
return {completion = completion}
