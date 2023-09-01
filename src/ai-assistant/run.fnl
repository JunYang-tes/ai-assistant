(local async (require :plenary.async))
(local list (require :ai-assistant.list))
(local {: options} (require :ai-assistant.options))
(local floating (require :ai-assistant.floating-ui))
(local {: get-session
        : get-messages
        : send-message} (require :ai-assistant.session))
(local log (require :ai-assistant.log))

(fn get-context [ctx-name]
  (if (= ctx-name :openai)
    (let [openai-provider (require :ai-assistant.openai-session)
          openai-context {:sessions {} :provider openai-provider}]
      openai-context)))
(fn get-ui [name]
  (if (= name :floating)
    (let [floating (require :ai-assistant.floating-ui)]
      (floating.make-floating))))

(fn run [buf]
  (async.run (fn []
               (print (vim.inspect options))
               (let [ui (get-ui options.ui)
                     ctx (get-context options.context)
                     session (get-session ctx buf)]
                 (tset session :notify-message-change
                       (fn []
                         (let [messages (get-messages ctx session)]
                           (vim.schedule
                             #(ui.update
                               (list.map messages #(. $1 :content)))))))
                 (ui.on-submit
                   (fn [content]
                     (async.run #(send-message ctx session content))))))))
