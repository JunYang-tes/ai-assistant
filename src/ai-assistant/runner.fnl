(local profiles (require :ai-assistant.profiles))
(local {: options} (require :ai-assistant.options))
(local {: session-manager} (require :ai-assistant.sessions.session-manager))
(local create-openai-session (require :ai-assistant.sessions.openai))
(local managers
  {:openai (session-manager create-openai-session)})
(local async (require :plenary.async))
(local {: make-render} (require :ai-assistant.chats-render))
(local log (require :ai-assistant.log))

(fn get-ui [name]
  (if (= name :floating)
    (let [floating (require :ai-assistant.floating-ui)]
      (floating.make-floating))))

(fn run-profile [profile]
  (let [
        manager (. managers
                   options.provider)
        ui (get-ui options.ui)
        session (manager.get-session {: profile
                                      :openai-model options.openai-model})
        chats (ui.get-chars-win)
        chats-render (make-render chats
                                  (session.get-messages))]
    (async.run (fn []
                 (session.set-handlers
                   (fn [msg]
                     (vim.schedule #(chats-render.add msg)))
                   (fn [msg]
                     (vim.schedule #(chats-render.update msg))))
                 (session.update-profile)
                 (ui.on-submit
                   (fn [content]
                     (async.run #(session.send-message content))))))))

(fn run-with-buf [buf profile]
  (let [profile (if (profiles.is-profile profile)
                  profile
                  (profiles.buffer-related-profiles profile buf))]
    (run-profile profile)))

(fn run-general []
  (run-profile (profiles.buffer-independent-profiles
                 :general
                 :global-chat)))


{: run-with-buf
 : run-general}
