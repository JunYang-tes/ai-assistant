(import-macros {: Types
                : General
                : Type} :type-hint)
(local {: String
        : Number
        : Const
        : OneOf
        : Nil
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

(Type OnNewMessage (Fn [Message] Void))
(Type OnUpdateMessage (Fn [Message] Void))
(Type Session (Table
                [:get-messages (Fn [] (List Message))
                 :name String
                 :model (Fn [(OneOf String Nil)] String)
                 :update-profile (Fn [] Void)
                 :set-handlers (Fn [OnNewMessage OnUpdateMessage] Void)
                 :send-message (Fn [String] Void)]))

(Type Profile
      (Table
        [:init (Fn [] String)
         :update (Fn [] (OneOf
                          String
                          Nil))]))

{: Message
 : Role
 : Profile}
