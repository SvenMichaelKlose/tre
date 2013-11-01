;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun codegen-closure-lexical (name)
  (alet (get-funinfo name)
    (place-assign (? (funinfo-fast-scope? !)
                     (place-expand-0 (funinfo-parent !) (funinfo-ghost !))
                     (place-expand-closure-lexical !)))))
