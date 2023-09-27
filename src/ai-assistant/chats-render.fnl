(import-macros {: Types
                : General
                : Param
                : Type} :type-hint)
(local {: Message
        : MessageState
        : Role } (require :ai-assistant.types))
(local {: set-lines
        : clear} (require :ai-assistant.window))
(local list (require :ai-assistant.list))
(local log (require :ai-assistant.log))
; (local {: Number
;         : String} (require :ai-assistant.type-hint))
; (Types)
; (Type RenderableMessage
;       (Table
;         [:start-line Number
;          :header-marker-id (OneOf Number Nil)
;          :state MessageState
;          :error (OneOf String Nil)
;          :get-end-line (Fn [] Number)
;          :role Role
;          :content (List String)]))
(local marker-ns (vim.api.nvim_create_namespace "marker"))
; (vim.api.nvim_set_hl marker-ns :AiAssistantState_sending
;                      {:fg "orange"
;                       :guifg :orange})
; (vim.api.nvim_set_hl marker-ns :AiAssistantStateFailed
;                      {:fg :red})
(vim.api.nvim_command (.. "hi AiAssistantState_sending guifg=orange"))
(vim.api.nvim_command (.. "hi AiAssistantState_failed guifg=red"))
(fn state-marker [bufnr state line id]
  (vim.api.nvim_buf_set_extmark
    bufnr
    marker-ns
    line
    0
    {: id
     :virt_text [[state (.. :AiAssistantState_ state)]]
     :virt_text_pos :eol}))

(fn break-line [line]
  (fn impl [line ret]
    (if (<= (length line) 100)
      (do
        (table.insert ret line)
        ret)
      (let [sub (string.sub line 1 100)
            rest (string.sub line 101)]
        (impl rest (do
                     (table.insert ret sub)
                     ret)))))
  (impl line []))

(fn wrap-virt-lines [error]
  (let [lines (vim.split error "\n")
        virt-liens []]
    (each [_ line (ipairs lines)]
      (if (< (length line) 100)
        (table.insert virt-liens [[line :AiAssistantState_failed]])
        (each [_ line (ipairs (break-line line))]
          (table.insert virt-liens [[line :AiAssistantState_failed]]))))
    virt-liens))

(fn error-marker [bufnr error line]
  (vim.api.nvim_buf_set_extmark
    bufnr
    marker-ns
    line
    0
    {
     :virt_lines (wrap-virt-lines error)}))

(fn body-lines [message]
  (let [start (+ 1 message.start-line)
        end (+ message.start-line (length message.content))]
    [start end]))

(fn end-line [message]
  (let [[end] (body-lines message)]
    end))

(fn update-message-state [win message]
  (tset message :header-marker-id
    (state-marker
      (win.get-bufnr)
      (if (= message.state :sent)
        ""
        message.state)
      message.start-line
      message.header-marker-id)))

(fn show-message-header [win message]
  (-> win
      (set-lines
        (if (= message.role :user)
            ["👨[Me]"]
            ["🤖[AI]"])
        (. message :start-line)
        (+ 1 message.start-line)))
  (update-message-state win message))


(fn show-message-body [win message]
  (-> win
      (set-lines
        message.content
        (unpack (body-lines message)))))

(fn to-renderable-message [ message start-line]
  (let [content (vim.split message.content "\n")]
    ; add a empty line
    (table.insert content "")
    {: start-line
     : content
     :id message.id
     :role message.role
     :state message.state}))

(fn show-message [win message]
  (show-message-header win message)
  (show-message-body win message))

(fn make-render [win messages]
  (let [messages 
                (let [msgs []]
                  (for [i 1 (length messages)]
                    (let [previous (. msgs (- i 1))
                          [_ end-line] (if previous (body-lines previous) [0 -1])
                          start-line (+ end-line 1)]
                      (table.insert msgs
                                    (to-renderable-message
                                      (. messages i)
                                      start-line))))
                  msgs)]
    (each [_ m (ipairs messages)]
      (show-message
        win
        m))
    {:add (fn [msg]
            (let [last (. messages (length messages))
                  [_ end-line] (if last (body-lines last) [0 -1])
                  start-line (+ end-line 1)
                  msg (to-renderable-message
                        msg start-line)]
              (table.insert messages msg)
              (show-message
                win msg)))
     :clear (fn [] (clear win))
     :update (fn [msg]
               (let [m (list.first messages
                                   #$1
                                   #(= $1.id msg.id))]
                 (if m
                   (do
                     (tset m :state msg.state)
                     (tset m :error msg.error)
                     (if m.error
                       (error-marker
                         (win.get-bufnr)
                         m.error
                         (end-line m)))
                     (update-message-state
                       win
                       m)))))}))

{: make-render}

