local function _1_(buf)
  local function init()
    return ("This is the doc.json file of Swagger. Please generate corresponding API functions using TypeScript based on this file. Before generating, you need to ask me whether to use fetch, axios or other similar libraries. You should also inform me about which APIs are available so that I can confirm which ones you will be generating. The content of doc.json will be located between ---begin--- and ---end---." .. "\n---begin---\n" .. table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) .. "\n---end---\n")
  end
  local function update()
  end
  return {init = init, update = update}
end
return _1_
