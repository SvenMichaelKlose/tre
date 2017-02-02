(fn assoc-url (x)
  (+ (& x
        (list "?"))
     (pad (@ [list (encode-u-r-i-component _.) "=" (encode-u-r-i-component ._)] x) "&")))
