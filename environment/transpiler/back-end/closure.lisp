;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun codegen-closure-lexical (name)
  (place-assign (place-expand-closure-lexical (get-funinfo name))))
