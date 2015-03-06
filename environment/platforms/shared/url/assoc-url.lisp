; tré – Copyright (c) 2009,2014–2015 Sven Michael Klose <pixel@copei.de>

(defun assoc-url (x)
  (concat-stringtree
      (? x "?" "")
      (pad (@ [list (encode-u-r-i-component _.)
                    "="
                    (encode-u-r-i-component ._)]
              x)
           "&")))
