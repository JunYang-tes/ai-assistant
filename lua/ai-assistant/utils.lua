local async = require("plenary.async")
local function sync_for_test(async0)
  local done = false
  local ret = nil
  local function _1_(r)
    done = true
    ret = r
    return nil
  end
  async0.run(async0, _1_)
  while not done do
  end
  return done
end
return sync_for_test
