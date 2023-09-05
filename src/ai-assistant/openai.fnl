(import-macros {: let?
                : err} :ether)
(local async (require :plenary.async))
(local curl (require :plenary.curl))
(local {: json
        : event} (require :ai-assistant.http-utils))
(local log (require :ai-assistant.log))
(local {: options} (require :ai-assistant.options))

(local completion
  (async.wrap
    (fn [{
          : model
          ;; List of message
          ;; a message is 
          ;;  :role one of system,user,assistant,function
          ;;  :content string
          : messages
          : temperature
          : top_p
          : n } callback]
      (async.run
        (fn []
          (let [body (vim.json.encode
                       {: model
                        : messages
                        : temperature
                        : top_p
                        : n
                        :stream false})
                body-path (os.tmpname)
                (_ fd) (async.uv.fs_open body-path :w 438)]
            (async.uv.fs_write fd body)
            (async.uv.fs_close fd)
            (curl.post
              {:url (.. options.openai-host "/v1/chat/completions")
               :headers {:Authorization 
                         (.. "Bearer " options.openai-key)}
               ; :body (vim.json.encode
               ;         {: model
               ;          : messages
               ;          : temperature
               ;          : top_p
               ;          : n
               ;          :stream false})
               :body body-path
               :callback (json
                           (fn [res]
                             (vim.loop.fs_unlink body-path)
                             (callback
                               (let? [res res]
                                 (if (= nil res.error)
                                   res
                                   (err res.error))))))})))))
    2))

{: completion}
