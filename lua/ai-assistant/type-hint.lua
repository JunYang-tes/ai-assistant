local list = require("ai-assistant.list")
local function make_type(f, type_name)
  local function _1_(_241, _242)
    return f(_242)
  end
  return setmetatable({["type-name"] = type_name}, {__call = _1_})
end
local function atom_type(test, type_name, got)
  local function _2_(input)
    if not test(input) then
      return string.format("Expected %s, got %s", type_name, got(input))
    else
      return nil
    end
  end
  return make_type(_2_, type_name)
end
local function general_got(input)
  return string.format("%s, %s", type(input), vim.inspect(input))
end
local String
local function _4_(_241)
  return (type(_241) == "string")
end
String = atom_type(_4_, "String", general_got)
local Number
local function _5_(_241)
  return (type(_241) == "number")
end
Number = atom_type(_5_, "Number", general_got)
local Bool
local function _6_(_241)
  return (type(_241) == "boolean")
end
Bool = atom_type(_6_, "Bool", general_got)
local Nil
local function _7_(_241)
  return (type(_241) == "nil")
end
Nil = atom_type(_7_, "Bool", general_got)
local Any
local function _8_()
  return nil
end
Any = make_type(_8_, "Any")
local function OneOf(...)
  local types = {...}
  local function _9_(input)
    local list0 = list.map(input, types)
    local function _10_(_241)
      return (_241 == nil)
    end
    if list0.some(list0, _10_) then
      return nil
    else
      local function _11_(_241)
        return (_241)["type-name"]
      end
      return string.format("Expected one of %s, got %s", table.concat(list0.map(types, _11_)), general_got(input))
    end
  end
  return make_type(_9_, "OneOf")
end
local function Table(key_values)
  local size = #key_values
  local function _13_(input)
    if (type(input) ~= "table") then
      return string.format("Expected table, got %s", general_got(input))
    else
      local got = general_got(input)
      local msg = nil
      for i = 1, size, 2 do
        local prop = key_values[i]
        local type_ = key_values[(i + 1)]
        local check_message = type_(input[prop])
        if (nil ~= check_message) then
          msg = string.format("Type check failed for field %s:\n %s \n %s", prop, check_message, got)
        else
        end
      end
      return msg
    end
  end
  return make_type(_13_, "Table")
end
local function List(item_type)
  local function _16_(input)
    if (type(input) ~= "table") then
      return string.format("Expected list, got %s", general_got(input))
    else
      local err
      local function _17_(_241)
        return (_241 ~= nil)
      end
      err = list.first(input, item_type, _17_)
      if err then
        return string.format("Expected List of %s, got %s\n", item_type["type-name"], err)
      else
        return nil
      end
    end
  end
  return make_type(_16_, "List")
end
local function Map(key_type, value_type)
  local function _20_(input)
    if (type(input) ~= "table") then
      return string.format("Expected Map, got %s", general_got(input))
    else
      local msg = true
      for key, value in pairs(input) do
        local key_message = key_type(key)
        local value_message = value_type(value)
        if ((nil ~= key_message) or (nil ~= value_message)) then
          msg = (key_message or value_message)
        else
        end
      end
      return msg
    end
  end
  return _20_
end
local function Fn(args, ret)
  local function _23_(input)
    return nil
  end
  return make_type(_23_, "Fn")
end
local Void
local function _24_()
  return nil
end
Void = make_type(_24_, "Void")
return {String = String, Number = Number, Any = Any, Nil = Nil, Map = Map, List = List, Fn = Fn, Void = Void, Table = Table, OneOf = OneOf}
