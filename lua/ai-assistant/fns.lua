local function compose(f, g)
  local function _1_(...)
    return f(g(...))
  end
  return _1_
end
local function last_element(list)
  return list[#list]
end
return {compose = compose, ["last-element"] = last_element}
