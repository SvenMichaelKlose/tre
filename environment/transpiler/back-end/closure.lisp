;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun codegen-closure-lexical (fi-sym)
  (place-assign (place-expand-closure-lexical (get-funinfo-by-sym fi-sym))))
