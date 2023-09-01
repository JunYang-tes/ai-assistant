(import-macros {: Types
                : General
                : Type} :type-hint)
(local {: String
        : Number
        : OneOf
        : List
        : Any
        : Map
        : Fn
        : Void
        : Table} (require :ai-assistant.type-hint))
;(Types)
(Type Message (Table
                [:state String
                 :content String]))
(Type Session (Table
                [:messages (List Message)
                 :mode String]))
(General Provider SessionImpl MessageImpl
         (Table
           [:send-message (Fn [SessionImpl] Void)
            :filter-message (Fn [SessionImpl] (List MessageImpl))
            :get-message-content (Fn [MessageImpl] String)
            :create-session (Fn [(Table [:role-setting String] SessionImpl)])]))

(General Context SessionImpl MessageImpl
         (Table
           [:sessions (Map Number SessionImpl)
            :provider (Provider SessionImpl MessageImpl)]))

{: Message
 : Session
 : Provider
 : Context}
