(import-macros {: Types
                : General
                : Type} :type-hint)
(local {: String
        : Number
        : Const
        : OneOf
        : List
        : Any
        : Map
        : Fn
        : Void
        : Table} (require :ai-assistant.type-hint))
;(Types)
(Type Role (OneOf
             (Const :ai)
             (Const :user)))

(Type MessageState (OneOf
                     (Const :sending)
                     (Const :sent)
                     (Const :failed)))
(Type Message (Table
                [:state MessageState
                 :id Number
                 :role Role
                 :content String]))

(General Provider SessionImpl MessageImpl
         ;; MessageImpl must have id
         (Table
           [:send-message (Fn [SessionImpl] Void)
            :filter-message (Fn [SessionImpl] (List MessageImpl))
            :on-new-message (Fn [MessageImpl] Void)
            :on-message-change (Fn [MessageImpl] Void)
            :get-message-content (Fn [MessageImpl] String)
            :create-session (Fn [(Table [:role-setting String] SessionImpl)])]))

(General Context SessionImpl MessageImpl
         (Table
           [:sessions (Map Number SessionImpl)
            :provider (Provider SessionImpl MessageImpl)]))

{: Message
 : Role
 : Provider
 : Context}
