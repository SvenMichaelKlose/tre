; tré – Copyright (c) 2014 Sven Michael Klose <pixel@hugbox.org>

(defun alien-package? (x)
  (| (not (symbol-package x))
     (string== "COMMON-LISP" (package-name (symbol-package x)))
     (string== "SB-EXT" (package-name (symbol-package x)))))
