local function filter(list, should_remain_3f)
  local tbl_17_auto = {}
  local i_18_auto = #tbl_17_auto
  for _, v in ipairs(list) do
    local val_19_auto
    if should_remain_3f(v) then
      val_19_auto = v
    else
      val_19_auto = nil
    end
    if (nil ~= val_19_auto) then
      i_18_auto = (i_18_auto + 1)
      do end (tbl_17_auto)[i_18_auto] = val_19_auto
    else
    end
  end
  return tbl_17_auto
end
local function some(list, predict_3f)
  local found = false
  for _, item in ipairs(list) do
    if found then break end
    if predict_3f(item) then
      found = true
    else
    end
  end
  return found
end
local function map(list, f)
  local tbl_17_auto = {}
  local i_18_auto = #tbl_17_auto
  for i, v in ipairs(list) do
    local val_19_auto = f(v, i)
    if (nil ~= val_19_auto) then
      i_18_auto = (i_18_auto + 1)
      do end (tbl_17_auto)[i_18_auto] = val_19_auto
    else
    end
  end
  return tbl_17_auto
end
local function flatmap(list, f)
  local r = {}
  for _, item in ipairs(map(list, f)) do
    if (type(item) ~= "table") then
      table.insert(r, item)
    else
      for _0, item0 in ipairs(item) do
        table.insert(r, item0)
      end
    end
  end
  return r
end
local function reduce(list, accumulator, init)
  local ret = init
  for i, v in ipairs(list) do
    ret = accumulator(v, ret)
  end
  return ret
end
local function every(list, predict_3f)
  local function _6_(item, acc)
    return (acc and predict_3f(item))
  end
  return reduce(list, _6_, true)
end
local function first(list, map0, predict)
  local r = nil
  for i, v in ipairs(list) do
    if r then break end
    local m = map0(v)
    if predict(m) then
      r = m
    else
    end
  end
  return r
end
return {filter = filter, flatmap = flatmap, first = first, reduce = reduce, every = every, some = some, map = map}
