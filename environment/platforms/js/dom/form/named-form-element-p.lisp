;;;;; tré – Copyright (c) 2009–2010 Sven Michael Klose <pixel@copei.de>

(defun named-form-element? (x)
  (x.has-tag-name-in? '("form" "select" "input" "textarea")))
