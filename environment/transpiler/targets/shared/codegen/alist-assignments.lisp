(defun alist-assignments (x &key (padding ", ") (quote-char #\"))
  (apply #'+ (pad (@ #'((k v)
                         (+ k "=" (literal-string (string v) quote-char quote-char)))
                     (symbol-names (carlist x) :downcase? t)
                     (cdrlist x))
                  padding)))

(defun kwlist-alist (x)
  (@ [cons _. ._.] (group x 2)))

(defun alist-kwlist (x)
  (mapcan [list _. ._] x))

(defun kwlist-evalist (x)
  (list 'backquote (@ [list _. (list 'quasiquote ._)]
                      (kwlist-alist x))))

(define-filter alist-cassignments (x)
  (list (downcase (symbol-name x.)) "=" .x))
