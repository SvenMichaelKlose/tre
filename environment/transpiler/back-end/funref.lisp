;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun codegen-funref-lexical (fi-sym)
  (place-assign (place-expand-funref-lexical (get-funinfo-by-sym fi-sym))))
