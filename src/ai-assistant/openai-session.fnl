(import-macros {: is-ok} :ether)
(local {: options} (require :ai-assistant.options))
(local {: completion} (require :ai-assistant.openai))
(local list (require :ai-assistant.list))
(local log (require :ai-assistant.log))

(fn create-session [{: role-setting}]
  {:messages [{:state :sent ;sending failed
               :data
                  {:role :system
                   :content role-setting}}]
   :model options.openai-model})

(fn send-message [session message]
  (let [msg
        {:state :sending
         :role :user
         :id (+ (length session.messages) 1)
         :error nil
         :data
          {:role :user
           :content message}}]
    (table.insert session.messages
                  msg)
    (session.on-new-message msg)
    (log.warn :Messages session)
    (let [resp (completion
                 {:model session.model
                  :messages (list.map session.messages
                                      #(. $1 :data))})]
      (log.warn "RESP")
      (log.warn resp)
      (if (is-ok resp)
        (do
          (tset msg :state :sent)
          (session.on-message-change msg)
          (let [resp-msg {:state :sent
                          :role :ai
                          :id (+ (length session.messages) 1)
                          :data {:role :assistant
                                 :content (. resp :value :choices 1 :message :content)}}]
            (table.insert session.messages resp-msg)
            (session.on-new-message resp-msg)))
        (do
          (tset msg :error resp.message.message)
          (tset msg :state :failed)
          (session.on-message-change msg))))))

(fn get-message-content [msg]
  (. msg :data :content))

(fn filter-message [session]
  (list.filter
    session.messages
    #(not= (. $1 :data :role) :system)))


{: create-session
 : get-message-content
 : filter-message
 : send-message}
