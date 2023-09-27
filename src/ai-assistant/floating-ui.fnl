(local {: float
        : markdown
        : get-content
        : get-editor-size
        : close
        : winopt
        : set-title
        : buf-keymap
        : set-lines } (require :ai-assistant.window))

(fn make-floating
  []
  (let [[editor-width editor-height] (get-editor-size)
        width (math.floor (* 0.8 editor-width))
        height (math.floor (* 0.8 editor-height))
        input-height 5
        chats-height (- height input-height)
        row (math.floor (/ (- editor-height  height) 2))
        col (math.floor (/ (- editor-width width) 2))
        chats (float
                {: width
                 :height chats-height
                 : row
                 : col
                 :title "Chats"
                 :border :single
                 :relative :editor} true)
        input (float
                {: width
                 :height input-height
                 :row (+ row chats-height 2)
                 :title "Input(Send:Shift Enter)"
                 :border :single
                 : col
                 :relative :editor})
        input-winid (input.get-winid)
        chats-winid (chats.get-winid)]
    (vim.api.nvim_create_autocmd
      :WinClosed
      {:pattern [(tostring chats-winid)
                 (tostring input-winid)]
       :once true
       :callback (fn []
                   (close input)
                   (close chats))})
    (-> chats
        (markdown [])
        (buf-keymap
          :n
          :<esc>
          #(close chats))
        (buf-keymap
          :n
          :<c-j>
          #(vim.api.nvim_set_current_win (input.get-winid)))
        (winopt {:wrap true}))

    (-> input
        (winopt {:wrap true})
        (buf-keymap
          :n
          :<esc>
          #(close input))
        (buf-keymap
          [:n :i]
          :<c-k>
          #(vim.api.nvim_set_current_win (chats.get-winid))))

    (vim.api.nvim_set_current_win (input.get-winid))
    {:update (fn [content]
               (if (not chats.closed)
                 (set-lines chats content)))
     :update-title (fn [title]
                     (set-title chats title))
     :get-chars-win #chats
     :on-submit (fn [cb]
                  (buf-keymap
                    input
                    [:n :i] "<s-cr>"
                    (fn []
                      (let [content (get-content input)]
                        (set-lines input [])
                        (cb content)))))}))


{: make-floating}
