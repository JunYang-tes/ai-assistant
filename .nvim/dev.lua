-- reload = require("plenary.reload").reload_module
-- reload("ai-assistant.session")
-- reload("ai-assistant.type-hint")
-- local S = require("ai-assistant.session").Session
-- print(S({mode="gpt",messages={
--   {state="sent",data=
--   {role="user", content="What is the answer to life, the universe, and everything?"}
-- }
-- }}))
--


--reload("ai-assistant.openai")
-- local run =require("plenary.async").run
-- local completion = require("ai-assistant.openai").completion
-- local log = require("ai-assistant.log")
-- print(vim.api.nvim_buf_get_name(0))
-- run(function ()
--   log.warn(vim.inspect(completion({
--     model = "gpt-3.5-turbo",
--     messages = {
--       {role="user", content="What is the answer to life, the universe, and everything?"},
--     }
--   })))
-- end)

reload = require("plenary.reload").reload_module
reload("ai-assistant.floating-ui")
reload("ai-assistant.run")
reload("ai-assistant.http-utils")
reload("ai-assistant.openai-session")
reload("ai-assistant.opeanai")
reload("ai-assistant.options")
reload("ai-assistant.session")
reload("ai-assistant.openai")
reload("ai-assistant.window")
reload("ai-assistant.chats-render")
-- require("ai-assistant.chats-render").test()
-- print(vim.inspect(vim.api.nvim_list_wins()))
-- print(vim.inspect(vim.api.nvim_win_get_height(1017)))
-- print(vim.inspect(vim.api.nvim_win_get_position(1017)))
-- print(vim.inspect(require("ai-assistant.window")["get-editor-size"]()))
require("ai-assistant.run")(1)
