(import-macros {: Types
                : General
                : Type} :type-hint)
(local {: Profile} (require :ai-assistant.types))
(Types)
(Type Bufnr Number)
(Type CreateProfile
      (Fn [Bufnr] Profile))

(fn profile-content [buffer]
  (let [filtetype :TODO
        filename (vim.api.nvim_buf_get_name buffer)]
    (.. "You are a skilled programmer and you are pairing programming with me.\n"
                       "Currently editing file name is " filename "\n."
                       "The file content is quoted by \"---begein---\" and \"---end---\"\n"
                       "I will ask you to write some code, you should reply code directly without explaination unless "
                       "you are asked to explain.\n"
                       "Please use markdown format to write your code.\n")))
(fn create-profile [bufnr]
  (fn init []
    (profile-content bufnr))
  (fn update []
    (let [content (table.concat
                    (vim.api.nvim_buf_get_lines
                       bufnr 0 -1 false))]
      (.. "The lastest file content is \n"
          "---begin---\n"
          content
          "\n---end---\n")))
  {: init
   : update})
