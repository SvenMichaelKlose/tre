;;;;; Caroshi – Copyright (c) 2009–2010,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun alist-assignments (x &key (padding ", ") (quote-char #\"))
  (apply #'+ (pad (mapcar #'((k v)
                              (+ k "=" (literal-string (string v) quote-char quote-char)))
                          (symbol-names (carlist x) :downcase? t)
                          (cdrlist x))
                  padding)))

(defun kwlist-alist (x)
  (filter [cons _. ._.] (group x 2)))

(defun alist-kwlist (x)
  (mapcan [list _. ._] x))

(defun kwlist-evalist (x)
  (list 'backquote (filter [list _. (list 'quasiquote ._)]
                           (kwlist-alist x))))

(define-filter alist-cassignments (x)
  (list (downcase (symbol-name x.)) "=" .x))
