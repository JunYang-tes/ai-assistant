(import-macros {: err : ok} :ether)
(local {: last-element} (require :ai-assistant.fns))
(local log (require :ai-assistant.log))
(fn curl-response-handler [handler]
  (fn [callback]
    (fn [resp]
      (callback
        (if (= 0 resp.exit)
          (let [(ok? data) (pcall handler resp.body)]
            (if ok?
              (ok data)
              (err (.. "Failed to parse body "
                       (tostring data)
                       "\n The response " resp.body))))
          (err (string.format
                       "HTTP status %d\nCurl exit %d \n %s"
                       resp.status
                       resp.exit
                       resp.body)))))))

{:json (curl-response-handler vim.json.decode)
 :text (curl-response-handler (fn [body] body))
 :event (curl-response-handler 
          (fn [body]
            (fn parse [data]
              (string.gmatch data "data:(.)"))
            (let [list (vim.split body "\n\n")
                  last (last-element list)]
              (if (= nil last)
                {}
                (vim.json.decode
                  ;; last starts with data: 
                  (string.sub last 6))))))}
