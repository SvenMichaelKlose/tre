(functional butlast)

(fn butlast (plist)
  (? .plist
     (. plist. (butlast .plist))))
