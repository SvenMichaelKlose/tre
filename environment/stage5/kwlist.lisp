;;;;; tré – Copyrigt (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun kwlist-alist (x)
  (filter [cons _. ._.] (group x 2)))

(defun alist-kwlist (x)
  (mapcan [list _. ._] x))

(defun kwlist-evalist (x)
  (list 'backquote (filter [list _. (list 'quasiquote ._)]
                           (kwlist-alist x))))

(define-filter alist-cassignments (x)
  (list (string-downcase (symbol-name x.)) "=" .x))
