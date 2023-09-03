(local list (require :ai-assistant.list))

(fn make-type [f type-name]
  (setmetatable
    {: type-name}
    {:__call #(f $2)}))

(fn atom-type [test type-name got]
  (make-type
    (fn [input]
      (if (not (test input))
        (string.format "Expected %s, got %s" type-name (got input))
        nil))
    type-name))

(fn general-got [input]
  (string.format "%s, %s" (type input)
                 (vim.inspect input)))

(local String (atom-type
                #(= (type $1) :string)
                :String
                general-got))

(local Number (atom-type
                #(= (type $1) :number)
                :Number
                general-got))
(local Bool (atom-type
              #(= (type $1) :boolean)
              :Bool
              general-got))
(local Nil (atom-type
             #(= (type $1) :nil)
             :Bool
             general-got))
(local Any (make-type #nil :Any))
(fn OneOf [...]
  (let [types [...]]
    (make-type
      (fn [input]
        (let [list (list.map input types)]
          (if (list.some list #(= $1 nil))
            nil
            (string.format "Expected one of %s, got %s"
                           (table.concat (list.map types #(. $1 :type-name))) 
                           (general-got input)))))
      :OneOf)))
(fn Table [key-values]
  (let [
        size (length key-values)]
    (make-type
      (fn [input]
        (if (not= (type input) :table)
          (string.format "Expected table, got %s" (general-got input)) 
          (let [got (general-got input)]
            (var msg nil)
            (for [i 1 size 2]
              (let [prop (. key-values i)
                    type- (. key-values (+ i 1))]
                (let [check-message (type- (. input prop))]
                  (if (not= nil check-message)
                    (set msg (string.format
                                "Type check failed for field %s:\n %s \n %s"
                                prop
                                check-message
                                got))))))
            msg)))
      :Table)))

(fn List [item-type]
  (make-type
    (fn [input]
      (if (not= (type input) :table)
        (string.format "Expected list, got %s" (general-got input)) 
        (let [err (list.first input item-type #(not= $1 nil))]
          (if err
            (string.format "Expected List of %s, got %s\n"
                           (. item-type :type-name) err)
            nil))))
    :List))
(fn Map [key-type value-type]
  (fn [input]
    (if (not= (type input) :table)
      (string.format "Expected Map, got %s" (general-got input))
      (do
        (var msg true)
        (each [key value (pairs input)]
          (let [key-message (key-type key)
                value-message (value-type value)]
            (if (or (not= nil key-message)
                    (not= nil value-message))
              (set msg (or key-message value-message)))))
        msg))))

(fn Const [value]
  (make-type
    (fn [input]
      (if (= input value)
        nil
        (string.format "Expected %s, got %s" (tostring value) (tostring input))))))
;; We can just do type check on fn object
; (Type FnObject (Table
;                  [:args (List (f [Any] Boolean))
;                   :ret (f [Any] Boolean)]))
(fn Fn [args ret]
  (make-type
    (fn [input]
      nil)
    :Fn))
(local Void (make-type #nil :Void))

{: String
 : Number
 : Any
 : Nil
 : Map
 : List
 : Fn
 : Const
 : Void
 : Table
 : OneOf}
