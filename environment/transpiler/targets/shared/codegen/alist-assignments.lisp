(fn alist-assignments (x &key (padding ", ") (quote-char #\"))
  (*> #'+
      (pad (@ #'((k v)
                  (+ k "=" (literal-string (string v) quote-char quote-char)))
              (@ #'downcase (@ #'symbol-name (carlist x)))
              (cdrlist x))
           padding)))

(fn kwlist-alist (x)
  (@ [. _. ._.] (group x 2)))

(fn alist-kwlist (x)
  (+@ [… _. ._] x))

(fn kwlist-evalist (x)
  (… 'backquote (@ [… _. (… 'quasiquote ._)]
                   (kwlist-alist x))))

(define-filter alist-cassignments (x)
  (… (downcase (symbol-name x.)) "=" .x))
