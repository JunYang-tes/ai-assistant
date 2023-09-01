;; fennel-ls: macro-file
(fn Type [Name T]
    `(local ,Name ,T))

(fn General [Name ...]
  (let [args [...]
        body (. args (length args))]
    (table.remove args)
    `(local ,Name (fn ,args ,body))))

; (General TT S M
;          (Table [
;                  :a (Fn [S] M)
;                  :b (Fn [M] S)]))
; (TT String String {:a 1 :b 2})

(fn Types
  []
  (let [S (sym :String)
        N (sym :Number)
        Nil (sym :Nil)
        OneOf (sym :OneOf)
        T (sym :Table)]
    `(local {: ,S : ,N : ,Nil : ,OneOf : ,T} (require :ai-assistant.type-hint))))
(fn defn [args ret ...]
  (let [args-type []
        args []
        body [...]]
    `(setmetatable {:ret ,ret
                    :args ,args-type}
                   {:__f (fn [_ ...] ,body)})))

{: Type
 : Types
 : General
 : defn}
