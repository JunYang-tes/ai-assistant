(local async (require :plenary.async))
(local popup (require :plenary.popup))

(local get-input
  (async.wrap (fn [win-opts 
                   ;; success text
                   callback]
                (let [win-id (popup.create
                               [""]
                               (or win-opts
                                   {}))
                      buf (vim.api.nvim_win_get_buf win-id)]
                  (fn on-enter []
                    (vim.api.nvim_win_close win-id true)
                    (callback true (table.concat
                                     (vim.api.nvim_buf_get_lines
                                       buf 0 -1 false))))
                  (vim.keymap.set
                    :i "<CR>" on-enter {:buffer buf})))
              2))

{: get-input}
