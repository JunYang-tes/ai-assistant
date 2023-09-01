(fn filter [list should-remain?]
  (icollect [_ v (ipairs list)]
    (if (should-remain? v)
        v)))

(fn some [list predict?]
  (var found false)
  (each [_ item (ipairs list) :until found]
    (if (predict? item)
      (set found true)))
  found)

(fn map [list f]
  (icollect [i v (ipairs list)]
    (f v i)))

(fn flatmap [list f]
  (let [r []]
    (each [_ item (ipairs (map list f))]
      (if (not= (type item) :table)
        (table.insert r item)
        (each [_ item (ipairs item)]
          (table.insert r item))))
    r))

(fn reduce [list accumulator init]
  (var ret init)
  (each [i v (ipairs list)]
    (set ret (accumulator v ret)))
  ret)

(fn every [list predict?]
  (reduce
    list
    (fn [item acc]
      (and acc (predict? item)))
    true))

(fn first [list map predict]
  (var r nil)
  (each [i v (ipairs list) :until r]
    (let [m (map v)]
      (if (predict m)
        (set r m))))
  r)


{: filter
 : flatmap
 : first
 : reduce
 : every
 : some
 : map}
