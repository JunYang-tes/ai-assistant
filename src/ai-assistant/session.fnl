(import-macros {: Types
                : Type} :type-hint)
(local log (require :ai-assistant.log))
(local list (require :ai-assistant.list))

(fn role-setting [buffer]
  (let [filtetype :TODO
        content (table.concat
                  (vim.api.nvim_buf_get_lines
                    buffer 0 -1 false))
        filename (vim.api.nvim_buf_get_name buffer)]
    (.. "You are a skilled programmer and you are pairing programming with a person named Blob \n"
                       "Currently editing file name is " filename
                       "The file content is quoted by \"---begein---\" and \"---end---\",see below\n"
                       "---begin---\n"
                       content
                       "---end---\n"
                       "Blob will ask you to write some code, you should reply code directly without explaination unless "
                       "you are asked to explain.\n"
                       "Please use markdown format to write your code.\n")))

(fn create-session [ctx buffer]
 (ctx.provider.create-session
    {:role-setting (role-setting buffer)}))

(fn get-session [ctx buffer]
  (let [session (. ctx :sessions buffer)]
    (if (= nil session)
      (let [session (create-session ctx buffer)]
        (tset ctx.sessions buffer session)
        session)
      session)))
(fn get-messages [ctx session]
  (-> session
         ctx.provider.filter-message
         (list.map (fn [msg]
                     {:state msg.state
                      :content (ctx.provider.get-message-content msg)}))))
(fn send-message [ctx session message]
  (ctx.provider.send-message session message))
{: get-session
 : get-messages
 : send-message}
