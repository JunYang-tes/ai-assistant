autocmd BufWritePost *.fnl :! ./build.fnl
Luadev
nmap <F5> <Plug>(Luadev-RunLine)
nmap <F6> <Cmd>lua require('luadev').exec(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"))<CR>
execute 'edit' expand("<sfile>:p:h") . '/t.ts'
tabnew
