;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun codegen-closure-scope (name)
  (alet (get-funinfo name)
    (place-assign (? (funinfo-fast-scope? !)
                     (place-expand-0 (funinfo-parent !) (funinfo-scope-arg !))
                     (place-expand-closure-scope !)))))
