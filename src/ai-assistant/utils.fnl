(fn get-buf-content [])

(fn get-buf-content [bufnr]
  (table.concat
    (vim.api.nvim_buf_get_lines
      bufnr
      0
      -1
      false)
    "\n"))

{: get-buf-content}
