(local async (require :plenary.async))
(fn sync-for-test [async]
  (var done false)
  (var ret nil)
  (async.run
    async
    (fn [r]
      (set done true)
      (set ret r)))
  (while (not done))
  done)
