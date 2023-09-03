(local async (require :plenary.async))
(local list (require :ai-assistant.list))
(local {: options} (require :ai-assistant.options))
(local floating (require :ai-assistant.floating-ui))
(local {: get-session
        : get-messages
        : set-handlers
        : send-message} (require :ai-assistant.session))
(local {: make-render} (require :ai-assistant.chats-render))
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
                     session (get-session ctx buf)
                     chats (ui.get-chars-win)
                     chats-render (make-render chats
                                               (get-messages ctx session))]
                 (set-handlers ctx session
                               (fn [new]
                                 (vim.schedule
                                   #(chats-render.add new)))
                               (fn [updated]
                                 (vim.schedule
                                  #(chats-render.update updated))))
                 (ui.on-submit
                   (fn [content]
                     (async.run #(send-message ctx session content))))))))
