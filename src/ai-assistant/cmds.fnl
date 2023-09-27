(local list (require :ai-assistant.list))

(fn is-cmd [content]
  (= (string.sub content 1 1)
     "/"))

(fn execute [cmd cmds]
  (let [cmd (-> cmd
                (string.sub 2)
                (vim.split " ")
                (list.map #(vim.split $1 "=")))]
    (each [_ [cmd val] (ipairs cmd)]
      (let [f (. cmds cmd)]
        (when f
          (f val))))))

{: is-cmd
 : execute}
