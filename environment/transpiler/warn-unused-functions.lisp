; tré – Copyright (c) 2013–2015 Sven Michael Klose <pixel@copei.de>

(defun warn-unused-functions ()
  (alet (defined-functions)
    (@ [hremove ! _]
       (+ (hashkeys (used-functions))
          (hashkeys (expander-macros (std-macro-expander)))
          (hashkeys (expander-macros (codegen-expander)))
          *macros*))
    (@ [alet (symbol-name _)
         (| (tail? ! "_TREEXP")
            (head? ! "~")
            (warn "Unused function ~A." _))]
       (hashkeys !))))
