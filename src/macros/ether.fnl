;; fennel-ls: macro-file

(fn err [message]
  "Make an error object"
  `{:kind :err
     :__ether__ true
     :message ,message})

(fn is-ok [value]
  `(do
     (let [v# ,value]
       (and (= (type v#) :table)
            (= (. v# :__ether__) true)
            (= (. v# :kind) :ok)))))
  ;`(and
  ;   (= (type ,value) :table)
  ;   (= (. ,value :kind) :ok)
  ;   (= (. ,value :__ether__) true)))

(fn ok [value]
  "make a ok object,if it's already a ok just return it"
  (let [ok-sym (gensym)]
    `(do (let [,ok-sym ,value
               is-ok# ,(is-ok ok-sym)]
           (if is-ok#
             ,ok-sym
             {:kind :ok
              :__ether__ true
              :value ,ok-sym})))))
 ; `(if ,(is-ok value)
 ;    ,value
 ;    {:kind :ok
 ;     :__ether__ true
 ;     :value ,value}))

(fn is-err [value]
  `(not ,(is-ok value)))

(fn is-ether [value]
  `(and
     (=
      (type ,value) :table)
     (= (. ,value :__ether__) true)))

(fn no-err [ls]
  "Return the if there is no error object in the argument list"
  (let [item (gensym)]
    `(do
      (var has-err# true)
      (each [_# ,item (ipairs ,ls)]
        (if (and
              ,(is-ether item)
              ,(is-err item))
          (set has-err# false)))
      has-err#)))

(fn first-err [ls]
  "Return the first error object in ls or nil"
  (let [item (gensym)]
    `(do
       (var fierst_err# nil)
       (var i# 1)
       (var done# false)
       (while (<= i# (length ,ls))
         (let [,item (. ,ls i#)]
           (when (and 
                   ,(is-ether item)
                   ,(is-err item))
             (set fierst_err# ,item)
             (set i# (+ (length ,ls) 1))))
         (set i# (+ i# 1)))
       fierst_err#)))

(fn unwrap [value]
  "If value is ok returns value.value else return itself"
  (let [cond (is-ok value)]
    `(if ,cond
       (. ,value :value)
       ,value)))

(fn make-body [bindings body]
  (let [new-bindings []
        if-cond (no-err bindings)]
    (each [_ name (ipairs bindings)]
      ;; assert name is a symbol
      (assert (sym? name) "Expect symbol")
      (table.insert new-bindings
                    name)
      (table.insert new-bindings
                    (unwrap name)))
    (let [true-part `(let ,new-bindings
                       ,(ok `(do
                               ,(table.unpack body))))
          false-part (first-err bindings)]
      `(if ,if-cond
         ,true-part
         ,false-part))))

(fn make-bindings [symbols forms]
  (let [r []
        syms []]
    (let [first-sym (. symbols 1)
          first-form (. forms 1)]
      (table.insert syms first-sym)
      (table.insert r first-sym)
      (table.insert r first-form))
    (for [i 2 (length symbols)]
      (let [sym (. symbols i)
            form (. forms i)]
        (table.insert r sym)
        (table.insert r (make-body syms [form]))))
        ;(table.insert syms sym)))
    r))

;; A convenient way to work with ether
;; For example,
;; (let? [a (fn-a)
;;        b (fn-b a)
;;        c (fn-c a b)]
;;   (+ a b c))
;; Will be expanded to
;; (let [a (fn-a)
;;       b (if (no-err [a])
;;           (let [a (unwrap a)]
;;             (fn-b a))
;;           a)
;;       c (if (no-err [a b])
;;           (let [a (unwrap a)
;;                 b (unwrap b)]
;;             (fn-c a b))
;;           b)]
;;   (if (no-err [a b c])
;;     (let [a (unwrap a)
;;           b (unwrap b)
;;           c (unwrap c)]
;;       (+ a b c))
;;     c))
;; fn-a/fn-b/fn-c can returns an ether object or a normal value
(fn let? [bindings ...]
  (let [symbols []
        forms []]
    (assert (sequence? bindings) (.."Expect list, but got a "
                                    (type bindings)))
    (assert (= (% (length bindings)
                2)
               0) (.. "Expect even number of name/value bindings"))
    (assert (not= (length [...])
                  0) "Expect body")
    (for [i 1 (length bindings) 2]
      (let [sym (. bindings i)]
        (assert (sym? sym)
                (.. "Expect symbol,but got a "
                    (type sym)
                    "\n"
                    (view sym)))
        (table.insert symbols sym))
      (table.insert forms (. bindings (+ i 1))))
    (let [new-bindings (make-bindings symbols forms)
          body (make-body symbols [...])]
      `(let ,new-bindings
          ,body))))
{: err
 : ok
 : is-err
 : is-ok
 : unwrap
 : let?}
