(fn compose [f g]
  (fn [...]
    (f (g ...))))

(fn last-element [list]
  (. list (length list)))

{: compose
 : last-element}
