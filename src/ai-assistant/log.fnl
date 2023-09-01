(local vim-log (require :vim.lsp.log))
(fn log [level-name]
  (fn [...]
    (let [f (. vim-log level-name)]
      (f "ai-assistant" ...))))

{:info (log :info)
 :error (log :error)
 :warn (log :warn)}
