local _local_1_ = require("ai-assistant.fns")
local last_element = _local_1_["last-element"]
local log = require("ai-assistant.log")
local function curl_response_handler(handler)
  local function _2_(callback)
    local function _3_(resp)
      local function _7_()
        if (0 == resp.exit) then
          local ok_3f, data = pcall(handler, resp.body)
          if ok_3f then
            local _4_ = data
            local is_ether_3_auto
            do
              local v_1_auto = _4_
              is_ether_3_auto = ((type(v_1_auto) == "table") and ((v_1_auto).__ether__ == true))
            end
            if is_ether_3_auto then
              return _4_
            else
              return {__ether__ = true, kind = "ok", value = _4_}
            end
          else
            return {__ether__ = true, kind = "err", message = ("Failed to parse body " .. tostring(data) .. "\n The response " .. resp.body)}
          end
        else
          return {__ether__ = true, kind = "err", message = string.format("HTTP status %d\nCurl exit %d \n %s", resp.status, resp.exit, resp.body)}
        end
      end
      return callback(_7_())
    end
    return _3_
  end
  return _2_
end
local function _8_(body)
  return body
end
local function _9_(body)
  local function parse(data)
    return string.gmatch(data, "data:(.)")
  end
  local list = vim.split(body, "\n\n")
  local last = last_element(list)
  if (nil == last) then
    return {}
  else
    return vim.json.decode(string.sub(last, 6))
  end
end
return {json = curl_response_handler(vim.json.decode), text = curl_response_handler(_8_), event = curl_response_handler(_9_)}
