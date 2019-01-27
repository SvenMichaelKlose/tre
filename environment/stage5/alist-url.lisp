(fn assoc-url (x)
  (string-concat (& x
                    (list "?"))
                 (pad (@ [list (encode-u-r-i-component _.) "=" (encode-u-r-i-component ._)] x) "&")))
