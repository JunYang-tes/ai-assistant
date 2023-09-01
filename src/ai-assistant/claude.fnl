(local async (require :plenary.async))
(local curl (require :plenary.curl))
(local {: json
        : event} (require :ai-assistant.http-utils))
(local log (require :ai-assistant.log))

(local User-Agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36")

(fn make-url [path]
  (.. :https://claude.ai
      path))

(fn cookie [session-key]
  (string.format "sessionKey=%s" session-key))

;; Error object
;; :detail :string
;; :error {:message :string
;;         :type :string}

;; Attachment
;;  :extracted_content :string
;;  :file_name :string
;;  :file_size :string
;;  :file_type :string

;; Returns a list of organizations
;; organization
;; :uuid string
;; :name string
;; :settings {:claude_console_privacy string}
;; :capabilities [:chat]
;; :join_token string
;; :created_at string
;; :updated_at string
;; :active_flags list-of-unknow
(local get-organizations
  (async.wrap (fn [session-key callback]
                (curl.get
                   {:url (make-url :/api/organizations)
                    :headers {:accept :application/json
                              : User-Agent
                              :cookie (cookie session-key)}
                    :callback (json callback)}))
              2))
(local get-conversations
  ;; Returns a list of converstion
  ;; converstion
  ;; :name string
  ;; :summary string
  ;; :uuid string
  (async.wrap (fn [session-key id callback]
                (curl.get
                   {:url (make-url (string.format 
                                     "/api/organizations/%s/chat_conversations"
                                     id))
                    :headers {:accept :application/json
                              : User-Agent
                              :cookie (cookie session-key)}
                    :callback (json callback)}))
              3)) 
;; Conversation
;; :name string
;; :chat_messages list of message
;; message
;;  :uuid string
;;  :index number
;;  :sender :human | :assistant
;;  :text string
(local get-conversation
  (async.wrap (fn [{: session-key
                    : org-id
                    : conversation-id} callback]
                (curl.get
                  {:url (make-url
                          (string.format
                            "/api/organizations/%s/chat_conversations/%s"
                            org-id conversation-id))
                   :headers {:accept :application/json
                             : User-Agent
                             :cookie (cookie session-key)}
                   :callback (json callback)}))
              2))
;; Response
;; :completion string
;; :stop_reason :stop_sequence | string
;; :mode string
;; :stop :\n\nHuman | string
;; :log_id string
;; :messageLimit {:type :within_limit | string}
(local send-message
  (async.wrap (fn [{: session-key
                    : message
                    : org-id
                    : attachments
                    : model
                    : conversation-id } callback]
                (curl.post
                  {:url (make-url :/api/append_message)
                   :headers {:content-type :application/json
                             : User-Agent
                             :accept "text/event-stream, text/event-stream"
                             :cookie (cookie session-key)}
                   :body (vim.json.encode
                            {:organization_uuid org-id
                             :conversation_uuid conversation-id
                             :attachments (or attachments [])
                             :text message
                             :completion {:prompt message
                                          :incremental false
                                          ;:timezone :America/New_York
                                          :model (or model :claude-2)}})
                   :callback (event callback)}))
              2))

{: get-organizations
 : get-conversations
 : get-conversation
 : send-message
 :modles [:claude-2
          :claude-1.3
          :claude-instant
          :claude-instant-100k]}
