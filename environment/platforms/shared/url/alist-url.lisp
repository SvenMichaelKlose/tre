(defun assoc-url (x)
  (concat-stringtree
      (? x "?" "")
      (pad (@ [list (encode-u-r-i-component _.)
                    "="
                    (encode-u-r-i-component ._)]
              x)
           "&")))
