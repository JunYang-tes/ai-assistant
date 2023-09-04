#! env fennel
(local inspect (require :inspect))
(local stringx (require :pl.stringx))

(fn os-name []
  (let [binary-format (: package.cpath
                         :match
                         "%p[\\|/]?%p(%a+)")]
    (case binary-format
      :dll :windows
      :so :linux
      :dylib :macos)))

(fn read-popen [cmd]
 (with-open [in (io.popen cmd)]
  (icollect [i v (in:lines)] i)))

(fn get-change-time [file]
  (-> (read-popen
        (case (os-name)
          :macos (.. "stat -f '%m' " file)
          :linux (.. "stat -c %Y " file)))
      (. 1)
      tonumber))
(fn get-src-list []
  (let [files
        (read-popen "find src -type f ")
        src (icollect [_ v (ipairs files)]
              (if (not (stringx.startswith v :src/macros))
                v))]
    src))

(fn get-output-file [file]
  (-> file 
      (stringx.replace "src" "lua")
      (stringx.replace "fnl" "lua")))
(fn get-dir [path]
  (let [index (stringx.rfind path "/")]
    (string.sub path 1 index)))

(fn compile [file]
  (print (.. "compiling " file))
  (let [tgt (get-output-file file)
        tgt-dir (get-dir tgt)]
    (os.execute (.. "mkdir -p " tgt-dir))
    (os.execute (.. :fennel " "
                    :--add-macro-path " \"./src/macros/?.fnl\" "
                    :--compile " " file
                    ">"
                    tgt))))
(fn not-exits [file]
  (let [f (io.open file :r)]
    (if f
        (do 
          (io.close f)
          false)
      true)))

(fn test-should-be-compile [file]
  (let [tgt (get-output-file file)]
    (or
      (not-exits tgt)
      (> (get-change-time file)
         (get-change-time tgt)))))

(fn run []
  (let [files (get-src-list)
        need-compile (icollect [_ v (ipairs files)]
                       (if (test-should-be-compile v) v))]
    (each [_ v (ipairs need-compile)]
      (compile v))))
(run)
