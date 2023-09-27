(import-macros {: is-ok} :ether)
(local {: options} (require :ai-assistant.options))
(local {: completion} (require :ai-assistant.openai))
(local list (require :ai-assistant.list))
(local log (require :ai-assistant.log))

(fn create [{: profile & rest}]
  (let [init-profile (profile.init)
        session {:messages
                 (if init-profile
                   [{:state :sent
                     :id 0
                     :data {:role :system
                            :content (profile.init)}}]
                   [])
                 :model (or rest.model
                            :gpt-3.5-turbo)}]
    (fn get-message-content [msg]
      (assert (not= nil msg) "NIL")
      (. msg :data :content))

    (fn to-general-message [msg]
      (assert (not= nil msg) "No message")
      {:state msg.state
       :id msg.id
       :error msg.error
       :role msg.role
       :content (get-message-content msg)})

    (fn get-messages []
      (-> session.messages
        (list.filter #(not= (. $1 :data :role) :system))
        (list.map to-general-message)))

    (fn emit-event [name msg]
      (let [cb (. session name)]
        (cb (to-general-message msg))))

    (fn send-message [text]
      (let [msg {:state :sending
                 :id (+ 1 (length session.messages))
                 :role :user
                 :error nil
                 :data {:role :user
                        :content text}}]
        (table.insert session.messages
                      msg)
        (emit-event :on-new-message msg)
        (let [resp (completion
                     {:model session.model
                      :messages (list.map session.messages
                                          #(. $1 :data))})]
          (if (is-ok resp)
            (do
              (tset msg :state :sent)
              (emit-event :on-message-change msg)
              (let [resp-msg {:state :sent
                              :role :ai
                              :id (+ (length session.messages) 1)
                              :data {:role :assistant
                                     :content (. resp :value :choices 1 :message :content)}}]
                (table.insert session.messages resp-msg)
                (emit-event :on-new-message resp-msg)))
            (do
              (tset msg :error resp.message.message)
              (tset msg :state :failed)
              (emit-event :on-message-change msg))))))

    (fn update-profile []
      (let [profile (and
                      (= (type profile.update) :function)
                      (profile.update))]
        (if profile
          (let [message {:state :sent
                         :id (+ (length session.messages) 1)
                         :data {:role :system
                                :content profile}}]
            (table.insert session.messages
                          message)))))

    (fn set-handlers [new update]
      (tset session :on-new-message new)
      (tset session :on-message-change update))

    (fn clear []
      (let [init (profile.init)
            messages (if init
                       [{:state :sent
                         :id 0
                         :data {:role :system
                                :content init}}]
                       [])]
        (tset session :messages messages)
        (update-profile)))

    {: get-messages
     :name :openai
     :model (fn [model]
              (if model
                (do
                  (tset session :model model)
                  model)
                session.model))
     : set-handlers
     : update-profile
     : clear
     : send-message}))
