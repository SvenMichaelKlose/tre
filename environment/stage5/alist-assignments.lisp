;;;;; Caroshi – Copyright (c) 2009–2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun alist-assignments (x &key (padding ", ") (quote-char #\"))
  (apply #'+ (pad (mapcar #'((k v)
                              (+ k "=" (literal-string (string v) quote-char quote-char)))
                          (symbol-names (carlist x) :downcase? t)
                          (cdrlist x))
                  padding)))
