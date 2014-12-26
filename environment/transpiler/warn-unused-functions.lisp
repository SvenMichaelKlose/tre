; tré – Copyright (c) 2013–2014 Sven Michael Klose <pixel@copei.de>

(defun warn-unused-functions ()
  (alet (defined-functions)
    (dolist (i (+ (hashkeys (used-functions))
                  (hashkeys (expander-macros (expander-get (std-macro-expander))))
                  (hashkeys (expander-macros (expander-get (codegen-expander))))
                  *macros*))
      (hremove ! i))
    (dolist (i (hashkeys !))
      (alet (symbol-name i)
        (unless (| (tail? ! "_TREEXP")
                   (head? ! "~"))
          (warn "Unused function ~A." i))))))
