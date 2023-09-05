;; (-> (float opt)
;;     (buffer-opt opt)
;;     (win-opt opt)
;;     (get-id)
(local list (require :ai-assistant.list))

(fn float [float_opt enter]
  (vim.validate
    {:float_opt [float_opt :t true]})
  (let [bufnr (or float_opt.bufnr
                  (vim.api.nvim_create_buf false false))
        winid (vim.api.nvim_open_win bufnr enter float_opt)]
    {:get-bufnr #bufnr
     :closed false
     :get-winid #winid}))

(fn normal [direct bufnr]
  (let [split-below vim.opt.splitbelow
        bufnr (or bufnr
                  (vim.api.nvim_create_buf false false))]
    (tset vim.opt :splitbelow true)
    ((. vim :cmd direct) :new)
    (tset vim.opt :splitbelow split-below)
    (let [winid (vim.api.nvim_get_current_win)]
      (vim.api.nvim_win_set_buf
        winid bufnr)
      {:get-bufnr #bufnr
       :get-winid #winid})))

(fn bufopt [win opt]
  (let [bufnr (win.get-bufnr)]
    (each [key val (pairs opt)]
      (vim.api.nvim_buf_set_option bufnr key val))
      ;(vim.api.nvim_buf_set_option key val { :buf bufnr}))
    win))

(fn winopt [win opt]
  (let [winid (win.get-winid)]
    (each [key val (pairs opt)]
      (vim.api.nvim_win_set_option winid
                                   key val))
    win))

(fn mul-lines [lines]
  (let [ls []]
    (each [_ line (ipairs lines)]
      (let [splited (vim.split line "\n")]
        (each [_ l (ipairs splited)]
          (table.insert ls l))))
    ls))

(fn set-lines [win lines start end]
  (let [modifiable (vim.api.nvim_buf_get_option
                     (win.get-bufnr)
                     :modifiable)]
    (bufopt win {:modifiable true})
    (vim.api.nvim_buf_set_lines
      (win.get-bufnr)
      (or start 0)
      (or end -1)
      false
      (mul-lines lines))
    (bufopt win {:modifiable modifiable}))
  win)

(fn highlight [win normal border]
  (vim.api.nvim_set_option_value
    :winhl
    (.. "Normal:" normal ",FloatBorder" border)
    {:scope :local
     :win (win.get-winid)})
  win)

(fn markdown [win content start end]
  (-> win
      (set-lines content start end)
      (bufopt {:filetype :markdown
               :modifiable false
               :buftype :nofile})
      (winopt {:conceallevel 2
               :concealcursor :niv})))

(fn set-width [win width]
  (vim.api.nvim_win_set_width
    (win.get-winid)
    width)
  width)

(fn set-height [win height]
  (vim.api.nvim_win_set_height
    (win.get-winid)
    height)
  height)

(fn buf-keymap [win mode keys cb]
  (vim.keymap.set
    mode keys cb {:buffer (win.get-bufnr)})
  win)

(fn get-content [win]
  (table.concat
    (vim.api.nvim_buf_get_lines
      (win.get-bufnr)
      0
      -1
      false)))

(fn get-editor-size []
  (let [wins (vim.api.nvim_list_wins)
        size (list.map wins
                       (fn [winid]
                         (let [[row col] (vim.api.nvim_win_get_position winid)
                               width (vim.api.nvim_win_get_width winid)
                               height (vim.api.nvim_win_get_height winid)]
                           [(+ width col)
                            (+ height row)])))]
    (list.reduce
      size
      #(let [[w h] $1
             [mw mh] $2]
        [(math.max w mw)
         (math.max h mh)])
      [0 0])))

(fn demo []
  (-> (float {:width 50
              :height 10
              :row 10
              :col 10
              :relative :editor} true)
      (markdown
        ["```typescript"
         "function hello(){"
         "\tconsole.log()"
         "}"
         "```"])))
(fn close [win]
  (if (not win.closed)
    (do
      (tset win :closed true)
      (vim.api.nvim_win_close (win.get-winid) true)
      (vim.api.nvim_buf_delete (win.get-bufnr) {:force true}))))

{: float
 : get-content
 : close
 : demo
 : highlight
 : normal
 : bufopt
 : winopt
 : buf-keymap
 : get-editor-size
 : markdown
 : set-lines
 : set-height
 : set-width}
